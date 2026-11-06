//
//  DownbeatGame.swift
//  Groova
//
//  F1.1 Downbeat Hunter. A big dial with four notches, 1 to 4, and a light that steps round it
//  with the beat. Tap LOCK on every 1. Some rounds have you turn the dial until its 1 lands
//  on the real downbeat, or find the 1 when the clip starts in the middle of a bar.
//

import Foundation
import QuartzCore
import SwiftUI

struct DownbeatGame: View {
    let task: GameTask
    let rounds: [DownbeatRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var taps: [Double] = []      // in steps since bar 0
    @State private var hits: Set<Int> = []
    @State private var lockFlash = 0.0
    @State private var touching = false
    /// Align: which real beat the dial's 1 sits on. 0 is right.
    @State private var offset = 0
    @State private var knurl = 0.0
    @State private var dragStart: (angle: Double, offset: Int, knurl: Double)?
    @State private var choice = 0
    @State private var replaying = false
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [DownbeatRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
        if case .align(let o) = rounds.first?.mode { _offset = State(initialValue: o) }
    }

    private var round: DownbeatRound { rounds[min(game.index, rounds.count - 1)] }
    private var loop: Pattern { round.choices.isEmpty ? round.loop : round.choices[min(choice, round.choices.count - 1)].loop }
    private var isAlign: Bool { if case .align = round.mode { return true }; return false }
    private var startBeat: Int { if case .lock(let b) = round.mode { return b }; return 0 }
    private var breakBars: [Int] { if case .follow(let b) = round.mode { return b }; return [] }

    /// Where the real 1s fall, in transport steps. Bar 0 is for listening.
    private var targets: [Double] {
        guard !isAlign else { return [] }
        let first = (16 - startBeat * 4) % 16
        return stride(from: first + 16, to: round.bars * 16 - 1, by: 16).map(Double.init)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if !round.choices.isEmpty && phase == .ready { loopPicker }
                    GameStage(height: 360) { stage }
                    if isAlign && phase == .playing { turnButtons }
                    if phase == .done && !targets.isEmpty {
                        TimingStrip(targets: targets.map { $0 - 16 }, hits: hits, taps: taps.map { $0 - 16 }.filter { $0 >= -1 },
                                    length: Double((round.bars - 1) * 16),
                                    caption: "Dots are the real downbeats. Lines are your locks.")
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        if round.mode == .accent { replayButton }
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: primaryTitle,
                       primaryEnabled: phase == .ready || (isAlign && phase == .playing),
                       onPrimary: primary,
                       onContinue: next,
                       onRetry: reset,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onChange(of: transport.step) { _, s in
            guard phase == .playing else { return }
            clock.follow(s)
            if isAlign, s >= 0, s % 4 == 0, ((s / 4) - offset + 4) % 4 == 0 {
                // The dial's 1 clicks, so you can hear where it thinks the bar starts.
                AudioEngine.shared.trigger(.perc, kit: transport.kit(for: genre), velocity: 1)
            }
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running, phase == .playing, !isAlign { finish() }
            if !running { replaying = false }
        }
        .onDisappear { transport.stop() }
    }

    private var primaryTitle: String {
        if isAlign { return phase == .playing ? "Check" : "Start" }
        return phase == .playing ? "Hunting…" : "Start"
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { _ in
            scene(pos: clock.now())
        }
    }

    private func scene(pos: Double?) -> some View {
        let p = pos ?? -1
        let bar = p >= 0 ? Int(p / 16) : -1
        let beatInBar = p >= 0 ? Int(p / 4) % 4 : -1
        let inBeat = p >= 0 ? (p / 4) - floor(p / 4) : 1
        let inBreak = breakBars.contains(bar)
        // Which notch is lit. Lock rounds don't show it: that's the hunt.
        let lit: Int? = {
            guard phase == .playing, beatInBar >= 0 else { return nil }
            switch round.mode {
            case .lock: return nil
            case .align: return (beatInBar - offset + 4) % 4
            default: return inBreak ? nil : beatInBar
            }
        }()
        let glow = max(0, 1 - inBeat * 2.5)
        let tag: String = {
            guard phase == .playing else { return phase == .done ? "\(hits.count) of \(targets.count) locked" : task.name }
            if isAlign { return "Turn the dial" }
            if bar == 0 { return "Listen" }
            if inBreak { return "Break · keep counting" }
            return "Lock the 1"
        }()
        return ZStack {
            Color.black.opacity(inBreak ? 0.4 : 0).animation(.easeInOut(duration: 0.4), value: inBreak)
            dial(lit: lit, glow: glow, pulse: round.mode == .lock && phase == .playing ? glow : 0)
            VStack {
                HStack {
                    StageTag(text: tag, color: bar > 0 && !inBreak ? accent : GameStyle.nightDim)
                    Spacer()
                    if round.mode == .accent { StageTag(text: "Lock = kick + crash", color: Theme.gold) }
                }
                Spacer()
            }
            .padding(14)
        }
    }

    private func dial(lit: Int?, glow: Double, pulse: Double) -> some View {
        let size: CGFloat = 262
        return ZStack {
            // The knurled ring you turn.
            Circle()
                .stroke(GameStyle.nightRaised, lineWidth: 34)
            Circle()
                .stroke(Color.white.opacity(isAlign ? 0.22 : 0.08), style: StrokeStyle(lineWidth: 26, dash: [2, 9]))
                .rotationEffect(.degrees(knurl))
                .padding(4)
            // Four notches.
            ForEach(0..<4, id: \.self) { i in
                let on = lit == i
                let one = i == 0
                let color = one ? Theme.gold : accent
                let showLabel = round.mode != .lock
                ZStack {
                    Circle()
                        .fill(on ? color : GameStyle.night)
                        .frame(width: one ? 46 : 38, height: one ? 46 : 38)
                        .shadow(color: on ? color.opacity(0.9 * max(0.4, glow)) : .clear, radius: 16)
                        .overlay(Circle().strokeBorder(on ? Color.white.opacity(0.8) : color.opacity(0.45), lineWidth: 2))
                    Text(showLabel ? "\(i + 1)" : "·")
                        .font(.display(one ? 22 : 18))
                        .foregroundStyle(on ? Color.black.opacity(0.75) : GameStyle.nightText)
                }
                .scaleEffect(on ? 1 + glow * 0.18 : 1)
                .offset(y: -size / 2 + 2)
                .rotationEffect(.degrees(Double(i) * 90))
            }
            // LOCK.
            lockButton(pulse: pulse)
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .gesture(isAlign && phase == .playing ? turnGesture(size: size) : nil)
    }

    private func lockButton(pulse: Double) -> some View {
        let label = isAlign ? "TURN" : "LOCK"
        return Circle()
            .fill(RadialGradient(colors: [accent.opacity(0.4 + lockFlash * 0.6 + pulse * 0.25), GameStyle.nightRaised],
                                 center: .center, startRadius: 4, endRadius: 80))
            .frame(width: 140, height: 140)
            .overlay(Circle().strokeBorder(accent.opacity(0.6), lineWidth: 3))
            .overlay(
                VStack(spacing: 2) {
                    Image(systemName: isAlign ? "arrow.triangle.2.circlepath" : "lock.fill")
                        .font(.system(size: 24, weight: .black))
                    Text(label).font(.label(16, weight: .black)).tracking(1.2)
                }
                .foregroundStyle(GameStyle.nightText)
            )
            .scaleEffect(1 - lockFlash * 0.07)
            .contentShape(Circle())
            .gesture(isAlign ? nil : DragGesture(minimumDistance: 0)
                .onChanged { _ in if !touching { lock() } }
                .onEnded { _ in touching = false })
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { lock(); touching = false }
    }

    private func turnGesture(size: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { v in
                let c = size / 2
                let a = atan2(Double(v.location.y - c), Double(v.location.x - c)) * 180 / .pi
                if dragStart == nil { dragStart = (a, offset, knurl) }
                guard let s = dragStart else { return }
                var d = a - s.angle
                if d > 180 { d -= 360 }
                if d < -180 { d += 360 }
                knurl = s.knurl + d
                let clicks = Int((d / 70).rounded())
                let o = ((s.offset + clicks) % 4 + 4) % 4
                if o != offset {
                    offset = o
                    Haptics.select()
                }
            }
            .onEnded { _ in dragStart = nil }
    }

    private var turnButtons: some View {
        HStack(spacing: 12) {
            Button { turn(-1) } label: { Label("Earlier", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
            Button { turn(1) } label: { Label("Later", systemImage: "arrow.clockwise").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
        }
    }

    private var loopPicker: some View {
        HStack(spacing: 10) {
            ForEach(Array(round.choices.enumerated()), id: \.offset) { i, c in
                Button {
                    Haptics.select()
                    choice = i
                    transport.play(c.loop, genre: genre, source: .demo, bars: 1, swing: 0, bpm: round.bpm)
                } label: {
                    Text(c.name).font(.label(15, weight: .heavy)).frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: choice == i ? accent : Theme.surfaceHigh,
                                               textColor: choice == i ? Theme.onBrand : Theme.text, height: 54))
            }
        }
    }

    private var replayButton: some View {
        Button(action: replay) {
            Label(replaying ? "Playing your take…" : "Hear your take", systemImage: "play.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ChunkyButtonStyle(color: Theme.gold, textColor: Theme.text, height: 54, enabled: !replaying))
        .disabled(replaying)
    }

    // MARK: Actions

    private func turn(_ d: Int) {
        Haptics.select()
        withAnimation(.spring(response: 0.3)) {
            offset = ((offset + d) % 4 + 4) % 4
            knurl += Double(d) * 70
        }
    }

    private func lock() {
        touching = true
        Haptics.thump()
        let kit = transport.kit(for: genre)
        if round.mode == .accent {
            AudioEngine.shared.trigger(.kick, kit: kit, velocity: 1)
            AudioEngine.shared.trigger(.openHat, kit: kit, velocity: 1)
        } else {
            AudioEngine.shared.trigger(.perc, kit: kit, velocity: 0.8)
        }
        withAnimation(.easeOut(duration: 0.04)) { lockFlash = 1 }
        withAnimation(.easeOut(duration: 0.3).delay(0.05)) { lockFlash = 0 }
        guard phase == .playing, let pos = clock.now() else { return }
        taps.append(pos)
        let (h, _) = matchTaps(taps, to: targets, window: 1.6)
        if h != hits { withAnimation { hits = h } }
    }

    private func primary() {
        if isAlign && phase == .playing { check(); return }
        start()
    }

    private func start() {
        taps = []
        hits = []
        clock.reset(bpm: round.bpm)
        if case .align(let o) = round.mode, phase == .ready, game.feedback == nil { offset = o }
        withAnimation { phase = .playing }
        let base = loop.shifted(by: -startBeat * 4)
        if isAlign {
            transport.play(base, genre: genre, source: .reference, bars: nil, swing: 0, bpm: round.bpm)
            return
        }
        let seq: [Pattern] = (0..<round.bars).map { breakBars.contains($0) ? round.breakLoop : base }
        transport.play(seq[0], genre: genre, source: .reference, bars: round.bars, swing: 0, bpm: round.bpm,
                       sequence: breakBars.isEmpty ? [] : seq, barsPerSection: 1)
    }

    private func check() {
        if offset == 0 {
            transport.stop()
            withAnimation { phase = .done }
            game.pass(1, "The dial's 1 now lands on the heaviest hit. That's the downbeat.")
        } else {
            game.miss("Not yet. Listen for the biggest hit of the bar, then turn until the gold 1 lights with it.")
            Task {
                try? await Task.sleep(for: .milliseconds(1400))
                if phase == .playing, game.feedback?.kind == .retry { withAnimation { game.feedback = nil } }
            }
        }
    }

    private func finish() {
        let (h, offsets) = matchTaps(taps, to: targets, window: 1.6)
        hits = h
        let counted = taps.filter { $0 >= 14 }.count
        let extras = max(0, counted - h.count)
        let n = max(1, targets.count)
        let score = max(0, Double(h.count) / Double(n) - Double(extras) * 0.06)
        withAnimation { phase = .done }
        let advice = timingAdvice(offsets.map { $0 / 4 })
        if score >= 0.6 {
            let msg: String
            switch round.mode {
            case .lock: msg = "You found the 1 even though the clip started in the middle."
            case .follow: msg = "You kept counting through the break and landed back on the 1."
            case .accent: msg = "Every downbeat got its crash. Hear how the bar now feels announced."
            default: msg = "\(h.count) of \(n) downbeats locked."
            }
            game.pass(score, msg + advice)
        } else {
            let hint = extras > 1 ? " Only tap once per bar, on the 1." : " Count 1, 2, 3, 4 under your breath and tap on 1."
            game.miss("\(h.count) of \(n) downbeats locked." + advice + hint, score: score)
        }
    }

    private func replay() {
        var take = loop
        for t in taps where t >= 14 {
            let s = Int(t.rounded()) % 16
            take.openHat[s] = true
            take.kick[s] = true
        }
        replaying = true
        transport.play(take, genre: genre, source: .demo, bars: 2, swing: 0, bpm: round.bpm)
    }

    private func reset() {
        transport.stop()
        withAnimation {
            game.feedback = nil
            phase = .ready
            taps = []
            hits = []
        }
        if case .align(let o) = round.mode { offset = o }
    }

    private func next() {
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            taps = []
            hits = []
            if case .align(let o) = round.mode { offset = o } else { offset = 0 }
        }
    }
}
