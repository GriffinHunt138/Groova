//
//  PlayAlongGame.swift
//  Groova
//
//  Core game: Play Along. The band loops without your part. Notes fall toward a line and you
//  hit the pads as they land: Perfect, Good or Miss, with a combo. Later bars can hide the
//  notes so you keep the groove going by feel.
//

import Foundation
import QuartzCore
import SwiftUI

struct PlayAlongGame: View {
    let task: GameTask
    let config: PlayAlongConfig
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }
    private enum Grade { case perfect, good, miss }
    private struct Target { var pos: Double; var lane: Int }

    @State private var game = GameProgress(total: 1)
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var targets: [Target] = []
    @State private var grades: [Int: Grade] = [:]
    @State private var offsets: [Double] = []
    @State private var combo = 0
    @State private var bestCombo = 0
    @State private var lit: Set<Int> = []
    @State private var held: Set<Int> = []
    @State private var callout = ""
    @State private var calloutID = 0
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    /// Steps of music visible above the line.
    private static let lookahead: Double = 16
    /// Timing windows, in sixteenth-note steps either side of the note.
    private static let perfectWindow: Double = 0.6
    private static let goodWindow: Double = 1.4
    private static let countIn = Pattern(hat: [0, 4, 8, 12])

    var body: some View {
        VStack(spacing: 0) {
            TimelineView(.animation(paused: phase != .playing)) { _ in
                let pos = clock.now() ?? -1
                VStack(spacing: 14) {
                    hud(pos: pos)
                        .padding(.top, 12)
                    status(pos: pos)
                    highway(pos: pos)
                    pads
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            StepFooter(feedback: game.feedback,
                       primaryTitle: phase == .playing ? "Playing…" : "Start",
                       primaryEnabled: phase == .ready,
                       onPrimary: start,
                       onContinue: { transport.stop(); onComplete(game.average) },
                       onRetry: reset)
        }
        .onChange(of: transport.step) { _, s in
            guard phase == .playing else { return }
            clock.follow(s)
            sweepMisses()
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running, phase == .playing { finish() }
        }
        .onDisappear { transport.stop() }
    }

    // MARK: Top bar

    private func hud(pos: Double) -> some View {
        let bar = max(0, Int(pos / 16))
        let barText: String = phase == .playing && bar >= 1 ? "Bar \(min(bar, config.bars)) of \(config.bars)" : "\(config.bars) bars"
        return HStack {
            Text(barText)
                .font(.label(15, weight: .heavy))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16, weight: .black))
                Text("\(combo)")
                    .font(.label(17, weight: .black))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(combo > 0 ? accent : Theme.surfaceHigh)
            .animation(.spring(response: 0.3), value: combo)
        }
    }

    // MARK: Status

    private func isGhost(bar: Int) -> Bool {
        guard let g = config.ghostFrom else { return false }
        return bar >= g
    }

    private func statusText(pos: Double) -> String {
        switch phase {
        case .ready: return task.name
        case .done: return "Done"
        case .playing: break
        }
        if pos < 0 { return "Get ready" }
        if pos < 16 {
            let beat = Int(pos / 4)
            return beat <= 0 ? "Ready" : "\(max(1, 4 - beat))"
        }
        return isGhost(bar: Int(pos / 16)) ? "Feel it" : "Play"
    }

    private func status(pos: Double) -> some View {
        let text = statusText(pos: pos)
        let good = callout == "Perfect" || callout == "Good"
        let ready = phase == .ready
        let sub: String = ready ? task.tagline : callout
        let subSize: CGFloat = ready ? 15 : 17
        let subWeight: Font.Weight = ready ? .semibold : .black
        let subColor: Color = ready ? Theme.textSecondary : (good ? accent : Theme.textTertiary)
        return VStack(spacing: 4) {
            Text(text)
                .font(.display(30))
                .foregroundStyle(Theme.text)
                .contentTransition(.opacity)
                .animation(.easeOut(duration: 0.15), value: text)
            Text(sub)
                .font(.label(subSize, weight: subWeight))
                .foregroundStyle(subColor)
                .multilineTextAlignment(.center)
                .id(calloutID)
                .transition(.scale(scale: 1.3).combined(with: .opacity))
                .frame(height: 22)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Falling notes

    private func highway(pos: Double) -> some View {
        let n = max(1, config.lanes.count)
        let ts = targets
        let gs = grades
        let ink = accent
        let ghostFrom = config.ghostFrom
        let look = Self.lookahead
        return Canvas { ctx, size in
            let laneW = size.width / CGFloat(n)
            let lineY = size.height - 16
            let travel = lineY - 8
            for l in 0..<n {
                let r = CGRect(x: CGFloat(l) * laneW + 4, y: 0, width: laneW - 8, height: size.height)
                ctx.fill(Path(roundedRect: r, cornerRadius: 18), with: .color(Theme.surfaceRaised))
            }
            // Beat lines scrolling down with the music.
            let firstBeat = Int((max(0, pos) / 4).rounded(.down))
            for b in firstBeat...(firstBeat + 5) {
                let d = Double(b * 4) - pos
                if d < 0 || d > look { continue }
                let y = lineY - CGFloat(d / look) * travel
                var line = Path()
                line.move(to: CGPoint(x: 8, y: y))
                line.addLine(to: CGPoint(x: size.width - 8, y: y))
                ctx.stroke(line, with: .color(Theme.surfaceHigh), lineWidth: b % 4 == 0 ? 2 : 1)
            }
            // The line you hit on.
            var hit = Path()
            hit.move(to: CGPoint(x: 4, y: lineY))
            hit.addLine(to: CGPoint(x: size.width - 4, y: lineY))
            ctx.stroke(hit, with: .color(ink), lineWidth: 3)
            // Notes.
            let noteW = min(laneW - 24, 72)
            for i in ts.indices {
                let t = ts[i]
                let d = t.pos - pos
                if d > look || d < -3 { continue }
                let grade = gs[i]
                if grade == .perfect || grade == .good { continue }
                if let g = ghostFrom, Int(t.pos / 16) >= g { continue }
                let y = lineY - CGFloat(d / look) * travel
                let cx = (CGFloat(t.lane) + 0.5) * laneW
                let rect = CGRect(x: cx - noteW / 2, y: y - 9, width: noteW, height: 18)
                let color: Color = grade == .miss ? Theme.surfaceHigh : ink
                ctx.fill(Path(roundedRect: rect, cornerRadius: 9), with: .color(color))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }

    // MARK: Pads

    private var pads: some View {
        HStack(spacing: 8) {
            ForEach(0..<config.lanes.count, id: \.self) { l in
                pad(l)
            }
        }
    }

    private func pad(_ l: Int) -> some View {
        let t = config.lanes[l]
        let on = lit.contains(l)
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)
        let fill: Color = on ? accent : accent.opacity(0.12)
        let ink: Color = on ? Color.white : accent
        let scale: CGFloat = on ? 0.96 : 1
        return VStack(spacing: 6) {
            Image(systemName: t.symbol)
                .font(.system(size: 24, weight: .black))
            Text(t.name)
                .font(.label(15, weight: .black))
        }
        .foregroundStyle(ink)
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .background(shape.fill(fill))
        .background(shape.fill(Theme.surface))
        .background(shape.fill(accent.opacity(0.22)).offset(y: 5))
        .scaleEffect(scale)
        .animation(.easeOut(duration: 0.07), value: on)
        .contentShape(shape)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in press(l) }
            .onEnded { _ in held.remove(l) })
        .accessibilityLabel(t.name)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { press(l); held.remove(l) }
    }

    // MARK: Playing

    private func press(_ l: Int) {
        guard !held.contains(l) else { return }
        held.insert(l)
        AudioEngine.shared.trigger(config.lanes[l], kit: transport.kit(for: genre), velocity: 1)
        Haptics.tap()
        light(l)
        guard phase == .playing, let pos = clock.now() else { return }
        var best: Int? = nil
        var bestD = Double.infinity
        for i in targets.indices where targets[i].lane == l && grades[i] == nil {
            let d = pos - targets[i].pos
            if abs(d) <= Self.goodWindow && abs(d) < abs(bestD) {
                best = i
                bestD = d
            }
        }
        if let i = best {
            let grade: Grade = abs(bestD) <= Self.perfectWindow ? .perfect : .good
            grades[i] = grade
            offsets.append(bestD / 4)
            combo += 1
            bestCombo = max(bestCombo, combo)
            say(grade == .perfect ? "Perfect" : "Good")
        } else if pos >= 16 {
            combo = 0
            say("Off the beat")
        }
    }

    private func light(_ l: Int) {
        lit.insert(l)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            lit.remove(l)
        }
    }

    private func say(_ text: String) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            callout = text
            calloutID += 1
        }
    }

    /// Notes that slid past the line without a hit count as misses.
    private func sweepMisses() {
        guard let pos = clock.now() else { return }
        var missed = false
        for i in targets.indices where grades[i] == nil && pos - targets[i].pos > Self.goodWindow {
            grades[i] = .miss
            missed = true
        }
        if missed {
            combo = 0
            say("Miss")
        }
    }

    private func start() {
        let backing = config.groove.without(Set(config.lanes))
        var seq: [Pattern] = [Self.countIn]
        var ts: [Target] = []
        for b in 1...max(1, config.bars) {
            seq.append(backing)
            for (l, track) in config.lanes.enumerated() {
                let row = config.groove[track]
                for s in 0..<Pattern.steps where row[s] {
                    ts.append(Target(pos: Double(b * 16 + s), lane: l))
                }
            }
        }
        targets = ts.sorted { $0.pos < $1.pos }
        grades = [:]
        offsets = []
        combo = 0
        bestCombo = 0
        callout = ""
        clock.reset(bpm: config.bpm)
        withAnimation { phase = .playing }
        transport.play(seq[0], genre: genre, source: .reference, bars: seq.count, swing: 0, bpm: config.bpm,
                       sequence: seq, barsPerSection: 1)
    }

    private func finish() {
        withAnimation { phase = .done }
        var perfect = 0
        var good = 0
        for g in grades.values {
            if g == .perfect { perfect += 1 } else if g == .good { good += 1 }
        }
        let total = max(1, targets.count)
        let missed = max(0, total - perfect - good)
        let score = (Double(perfect) + 0.7 * Double(good)) / Double(total)
        let line = "\(perfect) perfect, \(good) good, \(missed) missed. Best combo \(bestCombo)."
        if score >= config.threshold {
            game.pass(score, line + timingAdvice(offsets))
        } else {
            game.miss(line + " Tap right as each note touches the line.", score: score)
        }
    }

    private func reset() {
        transport.stop()
        withAnimation {
            game.feedback = nil
            phase = .ready
            callout = ""
            combo = 0
        }
    }
}
