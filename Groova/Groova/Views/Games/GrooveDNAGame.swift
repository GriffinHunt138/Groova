//
//  GrooveDNAGame.swift
//  Groova
//
//  F1.5 Groove DNA. The hi-hats are drawn as a ribbon of eight dot pairs, like a strand of DNA.
//  Drag the ribbon sideways to pull every second dot later: that's swing, and you hear it the
//  moment you move. Tap the four beat pads to accent them and the ribbon swells where they hit.
//

import Foundation
import QuartzCore
import SwiftUI

struct GrooveDNAGame: View {
    let task: GameTask
    let rounds: [DNARound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }
    private struct Feel: Equatable { var swing: Double; var accents: Set<Int> }

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var swing = 0.0
    @State private var dragFrom: Double?
    @State private var accents: Set<Int> = []
    @State private var hearingTarget = false
    @State private var wentSloppy = false
    @State private var saved: [Feel] = []
    @State private var blindOrder: [Int] = [0, 1]
    @State private var lastTick = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [DNARound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: DNARound { rounds[min(game.index, rounds.count - 1)] }

    private var targetSwing: Double? { if case .swing(let t) = round.mode { return t }; return nil }
    private var targetAccents: Set<Int>? { if case .accent(let t) = round.mode { return t }; return nil }
    private var usesAccents: Bool {
        switch round.mode {
        case .accent, .fingerprint: return true
        default: return false
        }
    }

    /// Swing as producers read it: 50% is straight, 75% is full shuffle.
    private func percent(_ s: Double) -> Int { Int((50 + s * 50).rounded()) }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: usesAccents ? 380 : 320) { stage }
                    if phase == .playing { helpers }
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: primaryTitle,
                       primaryEnabled: primaryEnabled,
                       onPrimary: primary,
                       onContinue: next,
                       onRetry: retry,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onChange(of: transport.step) { _, s in if phase == .playing { clock.follow(s) } }
        .onDisappear {
            transport.stop()
            AudioEngine.shared.resetEffects()
        }
    }

    private var primaryTitle: String {
        guard phase == .playing else { return "Start the groove" }
        if round.mode == .fingerprint {
            return saved.count == 0 ? "Save as feel A" : saved.count == 1 ? "Save as feel B" : "Pick one below"
        }
        if case .swing(.none) = round.mode { return "Lock this feel" }
        return "Check"
    }

    private var primaryEnabled: Bool {
        guard phase == .playing else { return phase == .ready }
        if round.mode == .fingerprint { return saved.count < 2 }
        return !hearingTarget
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { _ in
            let pos = clock.now()
            let step = pos.map { $0.truncatingRemainder(dividingBy: 16) } ?? -1
            VStack(spacing: 14) {
                HStack {
                    StageTag(text: hearingTarget ? "Target feel" : (phase == .playing ? "Drag the ribbon" : task.name),
                             color: hearingTarget ? Theme.gold : (phase == .playing ? accent : GameStyle.nightDim))
                    Spacer()
                    swingReadout
                }
                Spacer(minLength: 0)
                ribbon(step: step)
                if usesAccents { accentPads(step: step) }
                Spacer(minLength: 0)
            }
            .padding(14)
        }
    }

    private var swingReadout: some View {
        let shown = hearingTarget ? (targetSwing ?? swing) : swing
        let sloppy = shown > 0.4
        return HStack(spacing: 6) {
            Image(systemName: sloppy ? "exclamationmark.triangle.fill" : "metronome.fill")
            Text("SWING \(percent(shown))%").contentTransition(.numericText())
        }
        .font(.label(12, weight: .black))
        .foregroundStyle(sloppy ? Theme.miss : GameStyle.nightText)
        .padding(.horizontal, 10).frame(height: 26)
        .background(Capsule().fill(GameStyle.nightRaised))
    }

    private func ribbon(step: Double) -> some View {
        let shown = hearingTarget ? (targetSwing ?? swing) : swing
        let shownAccents = hearingTarget ? (targetAccents ?? accents) : accents
        let wobble = shown > 0.4 ? (shown - 0.4) * 60 : 0
        return GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let cell = w / 16
            let xOf: (Int) -> CGFloat = { s in cell * (CGFloat(s) + 0.5 + (s % 2 == 1 ? CGFloat(shown) : 0)) }
            ZStack {
                // Target band.
                if let t = targetSwing, round.showRange, !hearingTarget {
                    ForEach(0..<8, id: \.self) { k in
                        Capsule()
                            .fill(Theme.gold.opacity(0.18))
                            .frame(width: cell * 0.14 * 2 + 14, height: h * 0.8)
                            .position(x: cell * (CGFloat(2 * k + 1) + 0.5 + CGFloat(t)), y: h / 2)
                    }
                }
                // The strand.
                Path { p in
                    for s in 0..<16 {
                        let y = h / 2 + (s % 2 == 0 ? -1 : 1) * h * 0.22 + CGFloat(sin(Double(s) * 2.1) * wobble)
                        let pt = CGPoint(x: xOf(s), y: y)
                        if s == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                    }
                }
                .stroke(GameStyle.ink.opacity(0.14), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                ForEach(0..<16, id: \.self) { s in
                    let on = round.groove.hat[s]
                    let accented = usesAccents && s % 4 == 0 && shownAccents.contains(s / 4)
                    let lit = step >= 0 && abs(step - Double(s) - (s % 2 == 1 ? shown : 0)) < 0.5
                    let size: CGFloat = (accented ? 26 : (s % 2 == 0 ? 18 : 15)) * (lit ? 1.35 : 1)
                    let color = s % 2 == 0 ? GameStyle.hat : accent
                    let y = h / 2 + (s % 2 == 0 ? -1 : 1) * h * 0.22 + CGFloat(sin(Double(s) * 2.1) * wobble)
                    Circle()
                        .fill(on ? color.opacity(lit ? 1 : 0.7) : GameStyle.ink.opacity(0.08))
                        .frame(width: size, height: size)
                        .shadow(color: lit ? color : .clear, radius: 10)
                        .overlay(accented ? Circle().strokeBorder(Theme.gold, lineWidth: 3) : nil)
                        .position(x: xOf(s), y: y)
                }
                // Beat lines.
                ForEach(0..<4, id: \.self) { b in
                    Text("\(b + 1)")
                        .font(.mono(11))
                        .foregroundStyle(GameStyle.nightDim)
                        .position(x: cell * (CGFloat(b * 4) + 0.5), y: h - 6)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { v in
                        guard phase == .playing, !hearingTarget else { return }
                        if dragFrom == nil { dragFrom = swing }
                        let s = max(0, min(0.5, (dragFrom ?? 0) + Double(v.translation.width / (cell * 2))))
                        setSwing(s)
                    }
                    .onEnded { _ in dragFrom = nil }
            )
        }
        .frame(height: 150)
        .accessibilityElement()
        .accessibilityLabel("Swing")
        .accessibilityValue("\(percent(swing)) percent")
        .accessibilityAdjustableAction { dir in
            switch dir {
            case .increment: setSwing(min(0.5, swing + 0.05))
            case .decrement: setSwing(max(0, swing - 0.05))
            default: break
            }
        }
    }

    private func accentPads(step: Double) -> some View {
        HStack(spacing: 10) {
            ForEach(0..<4, id: \.self) { b in
                let on = accents.contains(b)
                let now = step >= 0 && Int(step / 4) == b
                Button {
                    toggleAccent(b)
                } label: {
                    VStack(spacing: 2) {
                        Text("\(b + 1)").font(.display(22))
                        Text(on ? "LOUD" : "soft").font(.label(10, weight: .black)).tracking(0.6)
                    }
                    .frame(maxWidth: .infinity).frame(height: 66)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(on ? Theme.gold.opacity(now ? 1 : 0.75) : GameStyle.nightRaised))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(now ? GameStyle.ink.opacity(0.7) : GameStyle.nightLine, lineWidth: 2))
                    .foregroundStyle(on ? Color.white : GameStyle.nightText)
                }
                .buttonStyle(PressScaleStyle(scale: 0.94))
                .disabled(phase != .playing || hearingTarget)
            }
        }
    }

    @ViewBuilder private var helpers: some View {
        switch round.mode {
        case .swing(.some):
            targetButton
        case .accent:
            targetButton
        case .sloppy:
            sloppyMeter
        case .fingerprint:
            fingerprintPanel
        default:
            EmptyView()
        }
    }

    private var targetButton: some View {
        Button(action: toggleTarget) {
            Label(hearingTarget ? "Back to mine" : "Hear the target", systemImage: hearingTarget ? "arrow.uturn.left" : "ear")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ChunkyButtonStyle(color: hearingTarget ? Theme.gold : Theme.surfaceHigh, textColor: Theme.text, height: 54))
    }

    private var sloppyMeter: some View {
        HStack(spacing: 12) {
            checkRow(done: wentSloppy, "Push past 70% and hear it fall apart")
            checkRow(done: wentSloppy && swing >= 0.1 && swing <= 0.3, "Pull back into the pocket, 55 to 65%")
        }
    }

    private func checkRow(done: Bool, _ s: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? Theme.success : Theme.textTertiary)
            Text(s).font(.label(13, weight: .bold)).foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 12)
    }

    @ViewBuilder private var fingerprintPanel: some View {
        if saved.count < 2 {
            HStack(spacing: 10) {
                ForEach(0..<2, id: \.self) { i in
                    VStack(spacing: 4) {
                        Text(i == 0 ? "Feel A" : "Feel B").font(.label(14, weight: .heavy))
                        Text(i < saved.count ? describe(saved[i]) : "Not saved yet")
                            .font(.label(12, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .card(padding: 12)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Same notes, two feels. Hear both, then pick your favourite.")
                    .font(.label(15, weight: .heavy)).foregroundStyle(Theme.text)
                HStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { i in
                        Button { audition(blindOrder[i]) } label: {
                            Label("Mystery \(i + 1)", systemImage: "play.fill").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                    }
                }
                HStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { i in
                        Button { pick(blindOrder[i]) } label: {
                            Text("Pick \(i + 1)").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 50))
                    }
                }
            }
            .card(padding: 14)
        }
    }

    private func describe(_ f: Feel) -> String {
        let a = f.accents.isEmpty ? "no accents" : "accents on " + f.accents.sorted().map { "\($0 + 1)" }.joined(separator: " & ")
        return "Swing \(percent(f.swing))%, \(a)"
    }

    // MARK: Sound

    private func hatAccent(_ set: Set<Int>) -> [Float] {
        guard usesAccents else { return [] }
        return (0..<Pattern.steps).map { s in (s % 4 == 0 && set.contains(s / 4)) ? 1.0 : 0.45 }
    }

    private func setSwing(_ s: Double) {
        let old = swing
        swing = s
        AudioEngine.shared.update(swing: s)
        // A click for every 5% you move.
        let tick = Int(s * 20)
        if tick != lastTick { lastTick = tick; Haptics.select() }
        if s > 0.4, !wentSloppy, round.mode == .sloppy {
            wentSloppy = true
            Haptics.warning()
        }
        if old != s, game.feedback?.kind == .retry { withAnimation { game.feedback = nil } }
    }

    private func toggleAccent(_ b: Int) {
        Haptics.tap()
        if accents.contains(b) { accents.remove(b) } else { accents.insert(b) }
        AudioEngine.shared.update(hatAccent: hatAccent(accents))
        if game.feedback?.kind == .retry { withAnimation { game.feedback = nil } }
    }

    private func toggleTarget() {
        Haptics.select()
        hearingTarget.toggle()
        let s = hearingTarget ? (targetSwing ?? swing) : swing
        let a = hearingTarget ? (targetAccents ?? accents) : accents
        AudioEngine.shared.update(swing: s)
        AudioEngine.shared.update(hatAccent: hatAccent(a))
    }

    private func audition(_ i: Int) {
        Haptics.tap()
        let f = saved[i]
        AudioEngine.shared.update(swing: f.swing)
        AudioEngine.shared.update(hatAccent: hatAccent(f.accents))
    }

    // MARK: Flow

    private func primary() {
        if phase != .playing { start(); return }
        switch round.mode {
        case .swing(let t):
            if let t {
                let d = abs(swing - t)
                if d <= 0.07 {
                    finish()
                    game.pass(max(0.7, 1 - d * 3), "Swing \(percent(swing))%, right in the target's pocket.")
                } else {
                    game.miss(swing < t ? "Not swung enough yet. Drag the ribbon further right." : "Too much swing. Ease the ribbon back left.",
                              score: max(0, 1 - d * 4))
                }
            } else if swing < 0.08 {
                game.miss("That's still straight. Drag the ribbon right and hear the hats start to skip.")
            } else {
                finish()
                game.pass(1, "Swing \(percent(swing))%. Same hats, but now they lean and bounce.")
            }
        case .accent(let t):
            if accents == t {
                finish()
                game.pass(1, "Accents match. Loud and soft hits give the same notes a shape.")
            } else {
                let off = t.symmetricDifference(accents).count
                game.miss("\(off) beat\(off == 1 ? " is" : "s are") off. Hear the target and listen for which hats jump out.",
                          score: max(0, 1 - Double(off) / 4))
            }
        case .sloppy:
            if !wentSloppy {
                game.miss("First push it too far, past 70%, so you know what sloppy sounds like.")
            } else if swing < 0.1 || swing > 0.3 {
                game.miss(swing > 0.3 ? "Still a bit drunk. Pull it back toward 60%." : "That's gone stiff. Give it a touch of swing.")
            } else {
                finish()
                game.pass(1, "You found the pocket at \(percent(swing))%. Too much swing falls apart, a little makes it groove.")
            }
        case .fingerprint:
            let f = Feel(swing: swing, accents: accents)
            if saved.count == 1 {
                let a = saved[0]
                guard abs(a.swing - f.swing) > 0.08 || a.accents != f.accents else {
                    game.miss("Feel B sounds the same as A. Change the swing or the accents so it has its own DNA.")
                    return
                }
            }
            Haptics.success()
            withAnimation { saved.append(f) }
            if saved.count == 2 { blindOrder = Bool.random() ? [0, 1] : [1, 0] }
        }
    }

    private func pick(_ i: Int) {
        Haptics.success()
        let f = saved[i]
        swing = f.swing
        accents = f.accents
        AudioEngine.shared.update(swing: f.swing)
        AudioEngine.shared.update(hatAccent: hatAccent(f.accents))
        finish()
        game.pass(1, "You picked feel \(i == 0 ? "A" : "B"): \(describe(f)). That's your groove fingerprint.", title: "Your DNA")
    }

    private func start() {
        clock.reset(bpm: round.bpm)
        hearingTarget = false
        wentSloppy = false
        saved = []
        lastTick = Int(swing * 20)
        withAnimation { phase = .playing }
        transport.play(round.groove, genre: genre, source: .user, bars: nil, swing: swing, bpm: round.bpm)
        AudioEngine.shared.update(hatAccent: hatAccent(accents))
    }

    private func finish() {
        hearingTarget = false
        withAnimation { phase = .done }
    }

    private func retry() {
        withAnimation { game.feedback = nil }
        if phase != .playing { start() }
    }

    private func next() {
        transport.stop()
        AudioEngine.shared.resetEffects()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            swing = 0
            accents = []
        }
    }
}
