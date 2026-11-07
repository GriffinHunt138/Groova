//
//  ForensicsGame.swift
//  Groova
//
//  F1.3 Drum Forensics. A dark mixing console with three channel strips: kick, snare and hat.
//  Each strip has a live level meter and the drum's "fingerprint" drawn as a shape. You solo,
//  mute and label strips with your fingers to work out which drum is which.
//

import Foundation
import QuartzCore
import SwiftUI

struct ForensicsGame: View {
    let task: GameTask
    let rounds: [ForensicsRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var muted: Set<DrumTrack> = []
    @State private var solo: DrumTrack?
    @State private var soloed: Set<DrumTrack> = []
    @State private var labels: [Int: DrumTrack] = [:]
    @State private var picked: DrumTrack?
    @State private var opened: [DrumTrack] = []
    @State private var answer: DrumTrack?
    @State private var filterLifted = false
    @State private var kitChoice: [DrumTrack: Int] = [.kick: 0, .clap: 0, .hat: 0]
    @State private var entries: [DrumTrack: Int] = [:]
    @State private var flash: [DrumTrack: Double] = [:]
    @Environment(\.accent) private var accent

    private let drums: [DrumTrack] = [.kick, .clap, .hat]
    private static let kits: [DrumKit] = [.house, .hipHop, .pop, .rnb]
    private static let kitNames = ["House", "Hip-hop", "Pop", "R&B"]
    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [ForensicsRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: ForensicsRound { rounds[min(game.index, rounds.count - 1)] }

    /// Which drum each strip carries, left to right. Identify rounds shuffle them.
    private var order: [DrumTrack] {
        if case .identify(let k) = round.mode {
            let shuffles: [[DrumTrack]] = [[.hat, .kick, .clap], [.clap, .hat, .kick], [.kick, .hat, .clap], [.hat, .clap, .kick]]
            return shuffles[k % shuffles.count]
        }
        return drums
    }

    private var kit: DrumKit {
        switch round.mode {
        case .identify(let k): return Self.kits[k % Self.kits.count]
        case .chooseKit: return composite
        default: return transport.kit(for: genre)
        }
    }

    /// Gold: kick, snare and hat each picked from kit A or kit B.
    private var composite: DrumKit {
        let a = DrumKit.house, b = DrumKit.hipHop
        var k = a
        let kSrc = (kitChoice[.kick] ?? 0) == 0 ? a : b
        k.kickStartHz = kSrc.kickStartHz; k.kickEndHz = kSrc.kickEndHz; k.kickPitchDecay = kSrc.kickPitchDecay
        k.kickDecay = kSrc.kickDecay; k.kickDrive = kSrc.kickDrive; k.kickClick = kSrc.kickClick; k.kickGain = kSrc.kickGain
        let cSrc = (kitChoice[.clap] ?? 0) == 0 ? a : b
        k.clapTone = cSrc.clapTone; k.clapDecay = cSrc.clapDecay; k.clapGain = cSrc.clapGain
        let hSrc = (kitChoice[.hat] ?? 0) == 0 ? a : b
        k.hatTone = hSrc.hatTone; k.hatDecay = hSrc.hatDecay; k.openHatDecay = hSrc.openHatDecay; k.hatGain = hSrc.hatGain
        return k
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 380) { stage }
                    if phase != .ready { extras }
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
        .onChange(of: transport.step) { _, s in
            guard phase == .playing else { return }
            clock.follow(s)
            light(s)
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running, phase == .playing, round.mode == .entrance { judgeEntrance() }
        }
        .onDisappear {
            transport.stop()
            AudioEngine.shared.resetEffects()
            AudioEngine.shared.update(kit: transport.kit(for: genre))
        }
    }

    // MARK: Footer

    private var primaryTitle: String {
        guard phase == .playing else { return "Open the console" }
        switch round.mode {
        case .fingerprints: return "I know them"
        case .identify: return "Check labels"
        case .chooseKit: return "Lock in my kit"
        case .entrance: return "Recording…"
        default: return "Solve it"
        }
    }

    private var primaryEnabled: Bool {
        guard phase == .playing else { return phase == .ready }
        switch round.mode {
        case .fingerprints: return soloed.isSuperset(of: drums)
        case .identify: return labels.count == 3
        case .chooseKit: return true
        default: return false
        }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { _ in
            let pos = clock.now() ?? -1
            VStack(spacing: 12) {
                HStack {
                    StageTag(text: stageTag(pos: pos), color: phase == .playing ? accent : GameStyle.nightDim)
                    Spacer()
                    if round.mode == .filtered, phase != .ready { filterBadge }
                    if case .identify(let k) = round.mode { StageTag(text: "\(Self.kitNames[k % 4]) kit", color: Theme.gold) }
                }
                HStack(spacing: 10) {
                    ForEach(Array(order.enumerated()), id: \.offset) { i, t in strip(i, t, pos: pos) }
                }
                if case .identify = round.mode, phase == .playing { labelTray }
            }
            .padding(14)
        }
    }

    private func stageTag(pos: Double) -> String {
        guard phase == .playing else { return phase == .done ? "Case closed" : task.name }
        switch round.mode {
        case .fingerprints: return "Solo each strip"
        case .identify: return "Solo, then label"
        case .restore: return "Bring them back"
        case .filtered: return "Something's missing"
        case .added: return Int(max(0, pos) / 32) % 2 == 0 ? "Version A" : "Version B"
        case .chooseKit: return "Build your kit"
        case .entrance: return "Bar \(min(4, max(1, clock.bar + 1))) of 4"
        }
    }

    private var filterBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "dial.medium.fill")
            Text(filterLifted ? "FILTER OPEN" : "LOW-PASS 400 Hz")
        }
        .font(.label(11, weight: .black))
        .foregroundStyle(filterLifted ? Theme.success : Theme.gold)
        .padding(.horizontal, 10).frame(height: 26)
        .background(Capsule().fill(GameStyle.nightRaised))
    }

    private func isAudible(_ t: DrumTrack) -> Bool {
        if let solo { return solo == t }
        return !muted.contains(t)
    }

    private func hidden(_ t: DrumTrack) -> Bool {
        if case .identify = round.mode { return phase != .done }
        if round.mode == .filtered || isAdded { return phase != .done }
        return false
    }

    private var isAdded: Bool { if case .added = round.mode { return true }; return false }

    private func strip(_ i: Int, _ t: DrumTrack, pos: Double) -> some View {
        let color = hidden(t) ? GameStyle.nightDim : GameStyle.color(t)
        let level = isAudible(t) ? (flash[t] ?? 0) : 0
        let label: String = {
            if case .identify = round.mode, phase != .done { return labels[i]?.name.uppercased() ?? "CH \(i + 1)" }
            return hidden(t) ? "CH \(i + 1)" : t.name.uppercased()
        }()
        return VStack(spacing: 10) {
            Text(label)
                .font(.label(13, weight: .black)).tracking(0.6)
                .foregroundStyle(labels[i] != nil ? Theme.gold : GameStyle.nightText)
                .lineLimit(1).minimumScaleFactor(0.7)
            Fingerprint(track: hidden(t) ? nil : t, energy: level)
                .stroke(color.opacity(0.4 + level * 0.6), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(height: 54)
                .shadow(color: color.opacity(level), radius: 8)
            meter(level: level, color: color)
            controls(t)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(GameStyle.nightRaised))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(solo == t ? Theme.gold : (picked != nil ? accent.opacity(0.6) : GameStyle.nightLine), lineWidth: solo == t ? 3 : 2))
        .contentShape(Rectangle())
        .onTapGesture { stripTapped(i, t) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private func meter(level: Double, color: Color) -> some View {
        VStack(spacing: 3) {
            ForEach((0..<8).reversed(), id: \.self) { seg in
                let on = level * 8 > Double(seg)
                RoundedRectangle(cornerRadius: 2)
                    .fill(on ? (seg > 5 ? Theme.gold : color) : GameStyle.ink.opacity(0.06))
                    .frame(height: 7)
            }
        }
        .frame(width: 34)
    }

    @ViewBuilder private func controls(_ t: DrumTrack) -> some View {
        switch round.mode {
        case .chooseKit:
            HStack(spacing: 4) {
                ForEach(0..<2, id: \.self) { k in
                    let on = (kitChoice[t] ?? 0) == k
                    Text(k == 0 ? "A" : "B")
                        .font(.label(14, weight: .black))
                        .frame(maxWidth: .infinity).frame(height: 34)
                        .background(RoundedRectangle(cornerRadius: 10).fill(on ? accent : GameStyle.nightRaised))
                        .foregroundStyle(GameStyle.nightText)
                        .onTapGesture { pickKit(t, k) }
                }
            }
        default:
            let icon: String = {
                switch round.mode {
                case .restore, .entrance: return isAudible(t) ? "speaker.wave.2.fill" : "speaker.slash.fill"
                default: return solo == t ? "headphones" : "headphones"
                }
            }()
            let on = round.mode == .restore || round.mode == .entrance ? isAudible(t) : solo == t
            Image(systemName: icon)
                .font(.system(size: 16, weight: .black))
                .frame(maxWidth: .infinity).frame(height: 34)
                .background(RoundedRectangle(cornerRadius: 10).fill(on ? accent : GameStyle.nightRaised))
                .foregroundStyle(on ? Color.white : GameStyle.nightText)
        }
    }

    private var labelTray: some View {
        HStack(spacing: 8) {
            ForEach(drums, id: \.self) { t in
                let used = labels.values.contains(t)
                Button {
                    Haptics.select()
                    picked = picked == t ? nil : t
                } label: {
                    Text(t.name)
                        .font(.label(14, weight: .heavy))
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(Capsule().fill(picked == t ? accent : GameStyle.nightRaised))
                        .overlay(Capsule().strokeBorder(used ? Theme.gold.opacity(0.7) : GameStyle.nightLine, lineWidth: 2))
                        .foregroundStyle(GameStyle.nightText)
                }
                .buttonStyle(PressScaleStyle(scale: 0.95))
            }
        }
    }

    // MARK: Below the stage

    @ViewBuilder private var extras: some View {
        switch round.mode {
        case .filtered:
            if phase == .playing {
                if answer == nil { question("Which drum disappeared?", choices: drums) }
                else { liftButton }
            }
        case .added:
            if phase == .playing { question("What got added in version B?", choices: [.kick, .clap, .hat, .openHat, .perc]) }
        case .entrance:
            if phase == .done { compareButtons }
        default:
            EmptyView()
        }
    }

    private func question(_ q: String, choices: [DrumTrack]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(q).font(.label(16, weight: .heavy)).foregroundStyle(Theme.text)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
                ForEach(choices, id: \.self) { t in
                    Button { guess(t) } label: {
                        Label(t.name, systemImage: t.symbol).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: GameStyle.color(t), textColor: Theme.onBrand, height: 50))
                }
            }
        }
        .card(padding: 14)
    }

    private var liftButton: some View {
        Button(action: liftFilter) {
            Label("Lift the filter", systemImage: "dial.high.fill").frame(maxWidth: .infinity)
        }
        .buttonStyle(ChunkyButtonStyle(color: Theme.gold, textColor: Theme.text, height: 56))
    }

    private var compareButtons: some View {
        HStack(spacing: 10) {
            Button { playEntrance() } label: { Label("Yours", systemImage: "play.fill").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 52))
            Button {
                transport.play(round.groove, genre: genre, source: .demo, bars: 4, swing: 0, bpm: round.bpm)
            } label: { Label("All at once", systemImage: "play").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
        }
    }

    // MARK: Sound and touch

    private func group(_ t: DrumTrack) -> Set<DrumTrack> { t == .hat ? [.hat, .openHat] : [t] }

    private func pushMutes() {
        var m = Set<DrumTrack>()
        for t in drums where !isAudible(t) { m.formUnion(group(t)) }
        if solo != nil { m.insert(.perc) }
        AudioEngine.shared.update(mutedDrums: m, bassMuted: solo != nil, chordsMuted: solo != nil)
    }

    /// Bounce the meters as each drum plays.
    private func light(_ s: Int) {
        guard s >= 0 else { return }
        let p = currentPattern
        for t in drums where group(t).contains(where: { p[$0][s] }) {
            withAnimation(.easeOut(duration: 0.03)) { flash[t] = 1 }
            withAnimation(.easeOut(duration: t == .kick ? 0.45 : 0.22).delay(0.03)) { flash[t] = 0 }
        }
    }

    private var currentPattern: Pattern {
        if case .added(let extra) = round.mode, clock.bar % 4 < 2 { return round.groove.without([extra]) }
        return round.groove
    }

    private func stripTapped(_ i: Int, _ t: DrumTrack) {
        guard phase == .playing else { return }
        Haptics.tap()
        switch round.mode {
        case .fingerprints:
            solo = solo == t ? nil : t
            if solo != nil { soloed.insert(t) }
        case .identify:
            if let picked {
                labels = labels.filter { $0.value != picked }
                labels[i] = picked
                self.picked = nil
                Haptics.select()
            } else {
                solo = solo == t ? nil : t
            }
        case .restore:
            guard muted.contains(t) else { return }
            let want = drums.first { muted.contains($0) }
            if t == want {
                muted.remove(t)
                opened.append(t)
                if muted.isEmpty {
                    withAnimation { phase = .done }
                    game.pass(1, "Kick holds the floor, snare marks the backbeat, hats keep time on top. Built from the bottom up.")
                }
            } else {
                game.miss("Start from the bottom. Which drum is the floor everything stands on?")
                Task {
                    try? await Task.sleep(for: .milliseconds(1500))
                    if phase == .playing, game.feedback?.kind == .retry { withAnimation { game.feedback = nil } }
                }
            }
        case .entrance:
            guard muted.contains(t) else { return }
            muted.remove(t)
            entries[t] = clock.bar
        case .filtered, .added, .chooseKit:
            solo = solo == t ? nil : t
        }
        pushMutes()
    }

    private func pickKit(_ t: DrumTrack, _ k: Int) {
        guard phase == .playing else { return }
        Haptics.select()
        kitChoice[t] = k
        AudioEngine.shared.update(kit: composite)
        AudioEngine.shared.trigger(t, kit: composite, velocity: 1)
    }

    private func guess(_ t: DrumTrack) {
        Haptics.tap()
        switch round.mode {
        case .filtered:
            let lost: DrumTrack = .hat
            if t == lost {
                answer = t
                Haptics.success()
            } else {
                game.miss("Listen higher. The filter cuts the brightest sounds first.")
            }
        case .added(let extra):
            let right = t == extra || (extra == .openHat && t == .hat)
            withAnimation { phase = .done }
            if right {
                game.pass(1, "Version B adds the \(extra.name.lowercased()). One new layer changes the whole feel.")
            } else {
                game.miss("Not quite. Version B added the \(extra.name.lowercased()). Listen for what's new in bar 3.")
            }
        default: break
        }
    }

    private func liftFilter() {
        Haptics.thump()
        withAnimation { filterLifted = true }
        AudioEngine.shared.setFilter(cutoff: 20_000, resonance: 0)
        withAnimation { phase = .done }
        game.pass(1, "Hats live up high, so a low-pass filter hides them first. Now they're back.")
    }

    // MARK: Flow

    private func primary() {
        if phase != .playing { start(); return }
        switch round.mode {
        case .fingerprints:
            finishPlaying()
            game.pass(1, "Kick is a low thump, snare a noisy crack, hat a thin tick. Three fingerprints.")
        case .identify:
            let right = (0..<3).filter { labels[$0] == order[$0] }.count
            if right == 3 {
                finishPlaying()
                game.pass(1, "All three labelled, even in a new kit. Same jobs, different sounds.")
            } else {
                game.miss("\(right) of 3 labels are right. Solo each channel and ask: low thump, crack, or tick?",
                          score: Double(right) / 3)
            }
        case .chooseKit:
            let picks = Set(drums.map { kitChoice[$0] ?? 0 })
            finishPlaying()
            game.pass(1, picks.count > 1 ? "A kit of your own, built from two. That's how producers find their sound."
                                         : "A clean kit from one source. Try mixing A and B next time to find something new.",
                      title: "Your kit")
        default: break
        }
    }

    private func start() {
        clock.reset(bpm: round.bpm)
        solo = nil
        soloed = []
        labels = [:]
        picked = nil
        opened = []
        answer = nil
        filterLifted = false
        entries = [:]
        muted = []
        AudioEngine.shared.resetEffects()
        var bars: Int? = nil
        var seq: [Pattern] = []
        switch round.mode {
        case .restore, .entrance: muted = Set(drums)
        case .added(let extra):
            let base = round.groove.without([extra])
            seq = [base, base, round.groove, round.groove]
        default: break
        }
        if round.mode == .entrance { bars = 4 }
        withAnimation { phase = .playing }
        transport.play(seq.first ?? round.groove, genre: genre, source: .reference, bars: bars, swing: 0, bpm: round.bpm,
                       kit: kit, sequence: seq, barsPerSection: 1)
        pushMutes()
        if round.mode == .filtered { AudioEngine.shared.setFilter(cutoff: 400, resonance: 0.2) }
    }

    private func finishPlaying() {
        solo = nil
        pushMutes()
        withAnimation { phase = .done }
    }

    private func judgeEntrance() {
        withAnimation { phase = .done }
        let bars = Set(entries.values)
        if entries.count < 3 {
            game.miss("Bring all three drums in before the four bars end. Tap a strip to open it.")
        } else if bars.count < 2 {
            game.miss("They all came in together. Stagger them so each one gets its own moment.")
        } else {
            game.pass(1, "Each drum got its own entrance. That's how a track builds anticipation.", title: "Grand entrance")
            playEntrance()
        }
    }

    /// Replays your entrance: each drum joins on the bar you opened it.
    private func playEntrance() {
        let seq: [Pattern] = (0..<4).map { bar in
            round.groove.without(Set(drums.filter { (entries[$0] ?? 9) > bar }.flatMap { group($0) }))
        }
        AudioEngine.shared.update(mutedDrums: [], bassMuted: false, chordsMuted: false)
        transport.play(seq[0], genre: genre, source: .demo, bars: 4, swing: 0, bpm: round.bpm, sequence: seq, barsPerSection: 1)
    }

    private func retry() {
        withAnimation { game.feedback = nil }
        if phase == .done || round.mode == .entrance {
            transport.stop()
            phase = .ready
        }
    }

    private func next() {
        transport.stop()
        AudioEngine.shared.resetEffects()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            kitChoice = [.kick: 0, .clap: 0, .hat: 0]
        }
    }
}

/// A drum's sound drawn as a line: kick is a low, fat swell; snare a noisy burst; hat a thin, fast flutter.
private struct Fingerprint: Shape {
    let track: DrumTrack?
    var energy: Double
    var animatableData: Double {
        get { energy }
        set { energy = newValue }
    }

    func path(in r: CGRect) -> Path {
        var p = Path()
        let mid = r.midY
        let n = 40
        for i in 0...n {
            let x = r.minX + r.width * CGFloat(i) / CGFloat(n)
            let u = Double(i) / Double(n)
            let amp = Double(r.height / 2) * (0.35 + energy * 0.65)
            let y: Double = {
                switch track {
                case .kick: return sin(u * .pi * 2.2) * exp(-u * 2.2) * amp
                case .clap: return sin(Double(i) * 2.7) * cos(Double(i) * 1.3) * exp(-u * 3.5) * amp
                case .hat, .openHat: return sin(u * .pi * 18) * exp(-u * 6) * amp * 0.7
                case .perc: return sin(u * .pi * 7) * exp(-u * 5) * amp
                case nil: return sin(u * .pi * 4) * 0.15 * amp
                }
            }()
            let pt = CGPoint(x: x, y: mid - CGFloat(y))
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        return p
    }
}
