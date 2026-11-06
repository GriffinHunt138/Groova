//
//  LoopReactorGame.swift
//  Groova
//
//  F0.4 My First Loop. Four concentric rings, drums, bass, chords and melody, spin around one
//  clock. Tap a ring to bring it in or take it out; it switches on the next bar, like a clip
//  launcher. You perform the loop like a tiny DJ set, you don't edit notes.
//

import Foundation
import QuartzCore
import SwiftUI

struct LoopReactorGame: View {
    let task: GameTask
    let layers: [ReactorLayer]
    let rounds: [ReactorRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, replay, done }

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var active: Set<Int> = []
    @State private var queued: Set<Int> = []   // rings that flip at the next bar
    @State private var variant: [Int] = [0, 0, 0, 0]
    @State private var late: Int?               // the ring that's a beat out
    @State private var syncQueued = false
    @State private var fullBars = 0
    @State private var wrongTaps = 0
    @State private var barLog: [Set<Int>] = []
    @State private var startBar = 0
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }
    private let colors: [Color] = [GameStyle.kick, GameStyle.bass, GameStyle.chords, GameStyle.lead]

    init(task: GameTask, layers: [ReactorLayer], rounds: [ReactorRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.layers = layers
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: ReactorRound { rounds[min(game.index, rounds.count - 1)] }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if case .energy(let t) = round.mode { energyTargets(t) }
                    GameStage(height: 360) { reactor }
                    if round.mode == .choose { variantPicker }
                    if case .sync = round.mode, phase == .playing { syncButton }
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: primaryTitle,
                       primaryEnabled: phase == .ready,
                       onPrimary: start,
                       onContinue: next,
                       onRetry: reset,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onAppear(perform: setUp)
        .onChange(of: game.index) { _, _ in setUp() }
        .onChange(of: transport.step) { old, s in
            guard phase == .playing || phase == .replay else { return }
            clock.follow(s)
            if phase == .playing {
                if s == 15 { launchQueued() }
                if s >= 0, old >= 0, s < old { barEnded() }
            }
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running, phase == .playing, round.mode == .perform { judgePerformance() }
            if !running, phase == .replay {
                phase = .done
                game.pass(1, "That's your first live loop: drums in, the band builds, then it breathes out.", title: "Your take")
            }
        }
        .onDisappear { transport.stop() }
    }

    private var primaryTitle: String {
        switch phase {
        case .ready: return round.mode == .perform ? "Record four bars" : "Start the reactor"
        case .replay: return "Your take…"
        default: return "Reactor running"
        }
    }

    // MARK: Round setup

    private func setUp() {
        transport.stop()
        phase = .ready
        queued = []
        variant = [0, 0, 0, 0]
        late = nil
        syncQueued = false
        fullBars = 0
        wrongTaps = 0
        barLog = []
        switch round.mode {
        case .missing(let i): active = Set(0..<layers.count).subtracting([i])
        case .sync(let i):
            active = Set(0..<layers.count)
            late = i
        default: active = []
        }
    }

    // MARK: Sound

    private func mix(_ on: Set<Int>) -> Pattern {
        var p = Pattern()
        for i in on.sorted() where i < layers.count {
            let vs = layers[i].variants
            var part = vs[min(variant[i], vs.count - 1)]
            if late == i { part = part.shifted(by: 4) }
            p = p.merged(with: part)
        }
        return p
    }

    private func start() {
        clock.reset(bpm: round.bpm)
        startBar = 0
        phase = .playing
        let bars: Int? = round.mode == .perform ? 4 : nil
        barLog = round.mode == .perform ? [active] : []
        transport.play(mix(active), genre: genre, source: .user, bars: bars, swing: 0, bpm: round.bpm)
    }

    /// Step 15: whatever was queued starts on the coming downbeat.
    private func launchQueued() {
        var changed = false
        if !queued.isEmpty {
            active.formSymmetricDifference(queued)
            queued = []
            changed = true
        }
        if syncQueued {
            late = nil
            syncQueued = false
            changed = true
        }
        if changed { transport.liveUpdate(mix(active)) }
    }

    private func barEnded() {
        let bar = clock.bar
        switch round.mode {
        case .build, .choose:
            fullBars = active.count == layers.count ? fullBars + 1 : 0
            if fullBars >= 2 { win(1, "Four layers locked to one clock. That's a loop.") }
        case .missing(let i):
            if active.count == layers.count {
                win(wrongTaps == 0 ? 1 : 0.7, "\(layers[i].name) was missing. You heard the hole and filled it.")
            }
        case .energy(let targets):
            // Bar 0 is a lead-in. At each new bar, log what's playing in it.
            barLog.append(active)
            if barLog.count > targets.count {
                let results = zip(barLog, targets).map { $0.count == $1 }
                let s = Double(results.filter { $0 }.count) / Double(targets.count)
                transport.stop()
                phase = .ready
                if s >= 0.6 { game.pass(s, "You shaped the energy: thin, then fuller, then everything.") }
                else { game.miss("Queue rings a bar early. They switch on at the next downbeat, not instantly.", score: s) }
            }
        case .sync:
            if late == nil, active.count == layers.count { win(1, "Back in sync. A clip launched on the bar line always lines up.") }
        case .perform:
            barLog.append(active)
        }
        _ = bar
    }

    private func win(_ s: Double, _ msg: String) {
        transport.stop()
        phase = .done
        game.pass(s, msg)
    }

    private func judgePerformance() {
        transport.stop()
        let log = barLog
        let full = log.contains { $0.count == layers.count }
        let entry = zip(log, log.dropFirst()).contains { $1.count > $0.count } || (log.first?.isEmpty == false)
        let exit = zip(log, log.dropFirst()).contains { $1.count < $0.count }
        guard full, entry, exit else {
            phase = .ready
            var need: [String] = []
            if !full { need.append("one bar with all four rings") }
            if !exit { need.append("take one ring out near the end") }
            game.miss("Almost. Your four bars need " + need.joined(separator: " and ") + ".")
            return
        }
        // Play it back exactly as performed.
        let seq = log.map { mix($0) }
        clock.reset(bpm: round.bpm)
        phase = .replay
        transport.play(seq[0], genre: genre, source: .reference, bars: seq.count, swing: 0, bpm: round.bpm,
                       sequence: seq, barsPerSection: 1)
    }

    // MARK: Taps

    private func tapRing(_ i: Int) {
        guard phase == .playing || phase == .ready else { return }
        Haptics.thump()
        if case .missing(let m) = round.mode, i != m { wrongTaps += 1 }
        if phase == .ready {
            // Before the start, rings switch straight away.
            if active.contains(i) { active.remove(i) } else { active.insert(i) }
            return
        }
        if queued.contains(i) { queued.remove(i) } else { queued.insert(i) }
    }

    // MARK: Views

    private var reactor: some View {
        TimelineView(.animation(paused: !(phase == .playing || phase == .replay))) { _ in
            let pos = clock.now() ?? 0
            let angle = (pos.truncatingRemainder(dividingBy: 16)) / 16
            GeometryReader { g in
                let size = min(g.size.width, g.size.height) - 24
                let center = CGPoint(x: g.size.width / 2, y: g.size.height / 2)
                ZStack {
                    ForEach(0..<layers.count, id: \.self) { i in
                        ring(i, size: size, angle: angle)
                    }
                    // The clock hand.
                    Capsule()
                        .fill(Color.white.opacity(phase == .ready ? 0.15 : 0.8))
                        .frame(width: 3, height: size / 2)
                        .offset(y: -size / 4)
                        .rotationEffect(.degrees(angle * 360))
                    // The centre pulse.
                    let beatPhase = (pos / 4).truncatingRemainder(dividingBy: 1)
                    Circle()
                        .fill(accent.opacity(phase == .ready ? 0.4 : 0.55 + 0.45 * max(0, 1 - beatPhase * 3)))
                        .frame(width: size * 0.2, height: size * 0.2)
                        .overlay(
                            Text(phase == .ready ? "OFF" : "\(Int(pos / 16) % 4 + 1)")
                                .font(.display(20)).foregroundStyle(Color.white)
                        )
                }
                .position(center)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onEnded { v in
                    let dx = v.location.x - center.x, dy = v.location.y - center.y
                    let r = sqrt(dx * dx + dy * dy) / (size / 2)
                    if let i = ringIndex(r) { tapRing(i) }
                })
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(0..<layers.count, id: \.self) { i in
                        HStack(spacing: 6) {
                            Circle().fill(colors[i % colors.count]).frame(width: 8, height: 8)
                            Text(layers[i].name).font(.label(11, weight: .black)).foregroundStyle(GameStyle.nightDim)
                        }
                    }
                }
                .padding(14)
            }
        }
    }

    /// Ring radii as a share of the reactor: drums inside, melody outside.
    private func radius(_ i: Int) -> Double { 0.36 + Double(i) * 0.19 }

    private func ringIndex(_ r: Double) -> Int? {
        for i in 0..<layers.count where abs(r - radius(i)) < 0.095 { return i }
        return nil
    }

    private func hitSteps(_ i: Int) -> [Int] {
        let vs = layers[i].variants
        var p = vs[min(variant[i], vs.count - 1)]
        if late == i { p = p.shifted(by: 4) }
        var steps = Set<Int>()
        for t in DrumTrack.allCases { for s in 0..<16 where p[t][s] { steps.insert(s) } }
        for n in p.bass { steps.insert(n.step) }
        for c in p.chords { steps.insert(c.step) }
        return steps.sorted()
    }

    private func ring(_ i: Int, size: Double, angle: Double) -> some View {
        let on = active.contains(i)
        let q = queued.contains(i)
        let color = colors[i % colors.count]
        let d = size * radius(i)
        return ZStack {
            Circle()
                .stroke(on ? color.opacity(0.55) : GameStyle.nightLine,
                        style: StrokeStyle(lineWidth: size * 0.085, dash: q ? [6, 6] : []))
                .frame(width: d, height: d)
                .shadow(color: on ? color.opacity(0.6) : .clear, radius: 10)
            // Hits sit round the ring and flare as the hand passes them.
            ForEach(hitSteps(i), id: \.self) { s in
                let a = Double(s) / 16
                let near = on && phase != .ready && (angle - a + 1).truncatingRemainder(dividingBy: 1) < 0.06
                Circle()
                    .fill(on ? (near ? Color.white : color) : GameStyle.nightLine)
                    .frame(width: near ? 13 : 8, height: near ? 13 : 8)
                    .offset(y: -d / 2)
                    .rotationEffect(.degrees(a * 360))
            }
        }
        .animation(.spring(response: 0.3), value: on)
    }

    private func energyTargets(_ t: [Int]) -> some View {
        let current = phase == .playing ? clock.bar - 1 : -1
        return HStack(spacing: 10) {
            ForEach(Array(t.enumerated()), id: \.offset) { i, n in
                VStack(spacing: 4) {
                    Text("BAR \(i + 1)").font(.label(11, weight: .black)).foregroundStyle(Theme.textTertiary)
                    HStack(spacing: 3) {
                        ForEach(0..<layers.count, id: \.self) { k in
                            Capsule().fill(k < n ? accent : Theme.surfaceHigh).frame(width: 8, height: 18)
                        }
                    }
                    Text("\(n) ring\(n == 1 ? "" : "s")").font(.label(12, weight: .bold)).foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 14).fill(current == i ? Theme.brandSoft : Theme.surface))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(current == i ? accent : Theme.stroke, lineWidth: 2))
            }
        }
    }

    private var variantPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PICK A VERSION").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
            ForEach(0..<layers.count, id: \.self) { i in
                if layers[i].variants.count > 1 {
                    HStack(spacing: 8) {
                        Text(layers[i].name).font(.label(15, weight: .heavy)).foregroundStyle(Theme.text)
                            .frame(width: 80, alignment: .leading)
                        ForEach(0..<layers[i].variants.count, id: \.self) { v in
                            Button(v == 0 ? "A" : "B") {
                                Haptics.select()
                                variant[i] = v
                                if phase == .playing, active.contains(i) { transport.liveUpdate(mix(active)) }
                            }
                            .buttonStyle(ChunkyButtonStyle(color: variant[i] == v ? colors[i % colors.count] : Theme.surfaceHigh,
                                                           textColor: variant[i] == v ? Theme.onBrand : Theme.text, height: 44))
                        }
                    }
                }
            }
        }
        .card(padding: 14)
    }

    private var syncButton: some View {
        Button(syncQueued ? "Syncing on the next bar…" : "SYNC") {
            Haptics.thump()
            syncQueued = true
        }
        .buttonStyle(ChunkyButtonStyle(color: syncQueued ? Theme.surfaceHigh : Theme.gold, textColor: Theme.text, height: 60))
        .disabled(syncQueued || late == nil)
    }

    // MARK: Moving on

    private func reset() {
        game.feedback = nil
        setUp()
    }

    private func next() {
        transport.stop()
        if game.advance() { onComplete(game.average) }
    }
}
