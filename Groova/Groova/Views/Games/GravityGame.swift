//
//  GravityGame.swift
//  Groova
//
//  F1.4 Gravity Groove. The kick is a puck that bounces along the floor, landing on every beat.
//  You hold the snare launcher, pull back and let go: the snare puck flies in an arc and lands
//  one beat later with a crack. A ghost marker shows where it will land if you let go now.
//

import Foundation
import QuartzCore
import SwiftUI

struct GravityGame: View {
    let task: GameTask
    let rounds: [GravityRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }
    private struct Flight: Identifiable { let id = UUID(); let launch: Double; var land: Double { launch + GravityGame.flight } }

    /// Flight time in steps: let go one beat before you want the snare.
    static let flight = 4.0

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var flights: [Flight] = []
    @State private var landings: [Double] = []
    @State private var splash: [Double: Double] = [:]
    @State private var holding = false
    @State private var pull: CGFloat = 0
    @State private var hits: Set<Int> = []
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [GravityRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: GravityRound { rounds[min(game.index, rounds.count - 1)] }

    /// The bars before you play: one count-in, plus a reference bar pair for copy rounds.
    private var leadBars: Int {
        switch round.mode {
        case .copy: return 2
        case .watch: return 0
        default: return 1
        }
    }

    private var zoneSteps: [Int] {
        switch round.mode {
        case .land(let s, _), .copy(let s): return s
        default: return []
        }
    }

    private var showZone: Bool {
        switch round.mode {
        case .land(_, let z): return z
        case .watch: return false
        case .copy: return phase == .done
        case .perform: return false
        }
    }

    private var targets: [Double] {
        guard !zoneSteps.isEmpty else { return [] }
        return (leadBars..<(leadBars + round.bars)).flatMap { bar in zoneSteps.map { Double(bar * 16 + $0) } }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 360) { stage }
                    if phase == .done, !targets.isEmpty {
                        TimingStrip(targets: targets.map { $0 - Double(leadBars * 16) }, hits: hits,
                                    taps: landings.map { $0 - Double(leadBars * 16) }.filter { $0 >= -1 },
                                    length: Double(round.bars * 16),
                                    caption: "Dots are where the snare belongs. Lines are where yours landed.")
                    }
                    if phase == .done, round.mode == .perform { compareButtons }
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: primaryTitle,
                       primaryEnabled: phase == .ready || (round.mode == .watch && phase == .playing && landings.count >= 4),
                       onPrimary: primary,
                       onContinue: next,
                       onRetry: reset,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onChange(of: transport.step) { _, s in if phase == .playing { clock.follow(s) } }
        .onChange(of: transport.isRunning) { _, running in
            if !running, phase == .playing, round.mode != .watch { finish() }
        }
        .onDisappear { transport.stop() }
    }

    private var primaryTitle: String {
        if round.mode == .watch, phase == .playing { return landings.count >= 4 ? "Got the feel" : "Land \(4 - landings.count) more" }
        return phase == .playing ? "Playing…" : "Start"
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { _ in
            GeometryReader { geo in
                scene(size: geo.size, pos: clock.now())
            }
        }
    }

    private func scene(size: CGSize, pos: Double?) -> some View {
        let w = size.width, h = size.height
        let left: CGFloat = 22, right: CGFloat = w - 92
        let floorY = h - 96
        let p = pos ?? -1
        let inBar = p >= 0 ? p.truncatingRemainder(dividingBy: 16) : -1
        let x: (Double) -> CGFloat = { s in left + (right - left) * CGFloat(s.truncatingRemainder(dividingBy: 16) / 16) }
        let bar = p >= 0 ? Int(p / 16) : -1
        let listening = bar >= 0 && bar < leadBars
        // Kick puck rides the playhead and touches the floor on every kick.
        let kicks = (0..<16).filter { round.kick.kick[$0] }
        let bounce: CGFloat = {
            guard inBar >= 0, !kicks.isEmpty else { return 0 }
            let prev = kicks.last { Double($0) <= inBar } ?? (kicks.last! - 16)
            let nxt = kicks.first { Double($0) > inBar } ?? (kicks.first! + 16)
            let u = (inBar - Double(prev)) / Double(nxt - prev)
            return CGFloat(sin(u * .pi)) * CGFloat(min(110, Double(nxt - prev) * 28))
        }()
        let launcher = CGPoint(x: w - 46, y: floorY)
        let ghost = p >= 0 ? x(p + Self.flight) : left
        let tag: String = {
            guard phase == .playing else { return phase == .done ? "\(hits.count) of \(targets.count) landed" : task.name }
            if case .copy = round.mode, listening { return "Listen" }
            if listening { return "Count-in" }
            return "Let go one beat early"
        }()

        return ZStack(alignment: .topLeading) {
            // Floor and beat ticks.
            Rectangle().fill(GameStyle.nightLine).frame(width: right - left, height: 3).position(x: (left + right) / 2, y: floorY + 16)
            ForEach(0..<16, id: \.self) { s in
                let beat = s % 4 == 0
                let zone = showZone && zoneSteps.contains(s)
                RoundedRectangle(cornerRadius: 3)
                    .fill(zone ? Theme.gold.opacity(0.35) : GameStyle.ink.opacity(beat ? 0.18 : 0.06))
                    .frame(width: zone ? 22 : 3, height: zone ? 14 : (beat ? 14 : 7))
                    .position(x: x(Double(s)), y: floorY + 16)
            }
            // Landings this bar.
            ForEach(Array(landings.enumerated()), id: \.offset) { _, l in
                if p >= 0, Int(l / 16) == bar || (Int(l / 16) == bar - 1 && inBar < 2) {
                    let s = splash[l] ?? 0
                    Circle().fill(GameStyle.snare.opacity(0.85))
                        .frame(width: 12, height: 12)
                        .position(x: x(l), y: floorY + 16)
                    Circle().stroke(GameStyle.snare.opacity(s), lineWidth: 3)
                        .frame(width: 20 + (1 - s) * 50, height: 20 + (1 - s) * 50)
                        .position(x: x(l), y: floorY + 4)
                }
            }
            // Ghost landing marker while you hold.
            if holding, phase == .playing {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(GameStyle.snare.opacity(0.8))
                    .position(x: ghost, y: floorY - 30)
            }
            // Playhead.
            if inBar >= 0 {
                Rectangle().fill(GameStyle.ink.opacity(0.08)).frame(width: 2, height: floorY - 40)
                    .position(x: x(inBar), y: (floorY + 40) / 2)
            }
            // Kick puck.
            puck(color: GameStyle.kick, symbol: "circle.fill", size: 40)
                .position(x: inBar >= 0 ? x(inBar) : left, y: floorY - bounce)
            // Snare pucks in flight.
            ForEach(flights) { f in
                let u = max(0, min(1, (p - f.launch) / Self.flight))
                let fx = launcher.x + (x(f.land) - launcher.x) * CGFloat(u)
                let fy = floorY - CGFloat(sin(u * .pi)) * 150
                puck(color: GameStyle.snare, symbol: "bolt.fill", size: 30)
                    .position(x: fx, y: fy)
            }
            // The launcher.
            launcherView
                .position(x: launcher.x, y: launcher.y + 14 + pull * 0.4)
            StageTag(text: tag, color: listening || phase != .playing ? GameStyle.nightDim : accent)
                .padding(14)
        }
        .frame(width: w, height: h)
    }

    private func puck(color: Color, symbol: String, size: CGFloat) -> some View {
        Circle()
            .fill(RadialGradient(colors: [color, color.opacity(0.6)], center: .topLeading, startRadius: 2, endRadius: size))
            .frame(width: size, height: size)
            .shadow(color: color.opacity(0.8), radius: 10)
    }

    private var launcherView: some View {
        let stretch = min(1, pull / 60)
        return VStack(spacing: 4) {
            Circle()
                .fill(GameStyle.snare.opacity(holding ? 1 : 0.7))
                .frame(width: 62, height: 62)
                .overlay(Image(systemName: holding ? "arrow.up" : "hand.point.up.left.fill")
                    .font(.system(size: 22, weight: .black)).foregroundStyle(.white))
                .scaleEffect(x: 1 + stretch * 0.1, y: 1 - stretch * 0.15)
                .shadow(color: GameStyle.snare.opacity(holding ? 0.9 : 0.3), radius: 14)
            Text(holding ? "LET GO" : "HOLD")
                .font(.label(11, weight: .black)).tracking(1)
                .foregroundStyle(GameStyle.nightText)
        }
        .frame(width: 88, height: 110)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { v in
                    if !holding { Haptics.soft() }
                    holding = true
                    pull = max(0, min(80, v.translation.height))
                }
                .onEnded { _ in
                    holding = false
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { pull = 0 }
                    launch()
                }
        )
        .accessibilityLabel("Snare launcher")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { launch() }
    }

    private var compareButtons: some View {
        HStack(spacing: 10) {
            Button { playTake(quantize: false) } label: { Label("Yours", systemImage: "play.fill").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 52))
            Button { playTake(quantize: true) } label: { Label("Only on beats", systemImage: "play").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
        }
    }

    // MARK: Actions

    private func launch() {
        guard phase == .playing, let pos = clock.now() else { return }
        Haptics.tap()
        let f = Flight(launch: pos)
        flights.append(f)
        let wait = Self.flight * clock.stepSeconds
        let kit = transport.kit(for: genre)
        Task {
            try? await Task.sleep(for: .milliseconds(Int(wait * 1000)))
            guard phase == .playing || round.mode == .perform else { return }
            AudioEngine.shared.trigger(.clap, kit: kit, velocity: 1)
            Haptics.thump()
            flights.removeAll { $0.id == f.id }
            landings.append(f.land)
            splash[f.land] = 1
            withAnimation(.easeOut(duration: 0.5)) { splash[f.land] = 0 }
            let (h, _) = matchTaps(landings, to: targets, window: 0.8)
            if h != hits { withAnimation { hits = h } }
        }
    }

    private func primary() {
        if round.mode == .watch, phase == .playing {
            transport.stop()
            withAnimation { phase = .done }
            game.pass(1, "Let go a beat early and the snare lands right where you want it. That's anticipation.")
            return
        }
        start()
    }

    private func start() {
        flights = []
        landings = []
        splash = [:]
        hits = []
        clock.reset(bpm: round.bpm)
        withAnimation { phase = .playing }
        let kick = round.kick
        if round.mode == .watch {
            transport.play(kick, genre: genre, source: .reference, bars: nil, swing: 0, bpm: round.bpm)
            return
        }
        var lead: [Pattern] = [kick]
        if case .copy(let steps) = round.mode {
            var ref = kick
            for s in steps { ref.clap[s] = true }
            lead = [ref, ref]
        }
        let seq = lead + Array(repeating: kick, count: round.bars)
        transport.play(seq[0], genre: genre, source: .reference, bars: seq.count, swing: 0, bpm: round.bpm,
                       sequence: seq, barsPerSection: 1)
    }

    private func finish() {
        // Let the last snare in the air land first.
        let wait = flights.isEmpty ? 0 : Self.flight * clock.stepSeconds + 0.05
        Task {
            try? await Task.sleep(for: .milliseconds(Int(wait * 1000)))
            judge()
        }
    }

    private func judge() {
        withAnimation { phase = .done }
        let played = landings.filter { $0 >= Double(leadBars * 16) - 1 }
        if round.mode == .perform {
            let offbeat = played.filter { Int($0.rounded()) % 4 != 0 }.count
            if played.count < 3 {
                game.miss("Throw more snares. Aim for at least a few in the four bars.")
            } else if offbeat < 2 {
                game.miss("Everything landed on the beats. Let go half a beat later now and then, so some land in between.")
            } else {
                game.pass(1, "\(offbeat) snares landed between the beats. Hear how they bounce against the kick.", title: "Your groove")
                playTake(quantize: false)
            }
            return
        }
        let (h, offsets) = matchTaps(played, to: targets, window: 0.8)
        hits = h
        let extras = max(0, played.count - h.count)
        let n = max(1, targets.count)
        let score = max(0, Double(h.count) / Double(n) - Double(extras) * 0.05)
        let advice = timingAdvice(offsets.map { $0 / 4 })
        if score >= 0.6 {
            game.pass(score, "\(h.count) of \(n) snares landed in place." + advice)
        } else {
            game.miss("\(h.count) of \(n) landed." + advice + " Let go when the kick puck is one beat before the zone.", score: score)
        }
    }

    private func playTake(quantize: Bool) {
        let played = landings.filter { $0 >= Double(leadBars * 16) - 1 }
        var bars = [Pattern](repeating: round.kick, count: max(1, round.bars))
        for l in played {
            let raw = Int(l.rounded()) - leadBars * 16
            let s = quantize ? Int((Double(raw) / 4).rounded()) * 4 : raw
            let b = s / 16, st = ((s % 16) + 16) % 16
            if b >= 0, b < bars.count { bars[b].clap[st] = true }
        }
        transport.play(bars[0], genre: genre, source: .demo, bars: bars.count, swing: 0, bpm: round.bpm,
                       sequence: bars, barsPerSection: 1)
    }

    private func reset() {
        transport.stop()
        withAnimation {
            game.feedback = nil
            phase = .ready
            flights = []
            landings = []
            hits = []
        }
    }

    private func next() {
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            flights = []
            landings = []
            hits = []
        }
    }
}
