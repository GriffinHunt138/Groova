//
//  BlackoutGame.swift
//  Groova
//
//  F0.1 Tap the Pulse. A dark stage with one luminous ring. Every tap on the beat lights a
//  segment of the ring; the guide light fades out and you keep the pulse alive by feel.
//

import Foundation
import QuartzCore
import SwiftUI

struct BlackoutGame: View {
    let task: GameTask
    let rounds: [PulseRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var pace: Double?
    @State private var taps: [Double] = []   // in beats since bar 0
    @State private var hits: Set<Int> = []
    @State private var tapFlash = 0.0
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [PulseRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: PulseRound { rounds[min(game.index, rounds.count - 1)] }
    private var bpm: Double { pace ?? round.bpm }
    private var totalBars: Int { 1 + Int((Double(round.beats) / 4).rounded(.up)) }
    private var targets: [Double] { (0..<round.beats).map { Double(4 + $0) } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if !round.paces.isEmpty && phase == .ready { pacePicker }
                    stage
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                    if phase == .done {
                        TimingStrip(targets: targets.map { $0 * 4 }, hits: hits, taps: taps.map { $0 * 4 },
                                    length: Double(totalBars * 16))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: phase == .playing ? "Keep it alive…" : "Start",
                       primaryEnabled: phase == .ready && (round.paces.isEmpty || pace != nil),
                       onPrimary: start,
                       onContinue: next,
                       onRetry: reset,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onChange(of: transport.step) { _, s in if phase == .playing { clock.follow(s) } }
        .onChange(of: transport.isRunning) { _, running in if !running, phase == .playing { finish() } }
        .onDisappear { transport.stop() }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { _ in
            ringScene(beat: clock.now().map { $0 / 4 })
        }
    }

    /// The ring at a moment in time. `beat` is beats since the count-in started.
    private func ringScene(beat: Double?) -> some View {
        let b = beat ?? -1
        let whole = Int(floor(b))
        let phaseInBeat = b - floor(b)
        let guided = phase == .playing && b >= 0 && !round.hiddenStart && (whole < 4 || whole - 4 < round.guideBeats)
        let pulse = guided ? max(0, 1 - phaseInBeat * 3) : 0
        let decoy = round.decoys && phase == .playing && whole >= 4 && whole % 2 == 1 && abs(phaseInBeat - 0.5) < 0.12
        let label: String = {
            switch phase {
            case .ready: return "Press start"
            case .done: return "\(hits.count) of \(round.beats)"
            case .playing:
                if b < 0 { return "Listen" }
                if whole < 4 { return round.hiddenStart ? "Find it" : (whole == 0 ? "Ready" : "\(4 - whole)") }
                return guided ? "Tap" : "Keep going"
            }
        }()
        return ZStack {
            ZStack {
                // Segments: one per beat you need to keep.
                ForEach(0..<round.beats, id: \.self) { i in
                    let gap = 0.012
                    Circle()
                        .trim(from: Double(i) / Double(round.beats) + gap, to: Double(i + 1) / Double(round.beats) - gap)
                        .stroke(hits.contains(i) ? accent : Theme.surfaceHigh,
                                style: StrokeStyle(lineWidth: 24, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .shadow(color: hits.contains(i) ? accent.opacity(0.45) : .clear, radius: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: hits.contains(i))
                }
                .frame(width: 320, height: 320)
                // The guide light.
                Circle()
                    .stroke(pulse > 0 ? accent.opacity(0.25 + pulse * 0.75) : Theme.stroke, lineWidth: 4 + pulse * 6)
                    .frame(width: 262 + pulse * 12, height: 262 + pulse * 12)
                    .shadow(color: accent.opacity(pulse), radius: 20 * pulse)
                if decoy {
                    Circle()
                        .stroke(Theme.gold.opacity(0.85), lineWidth: 8)
                        .frame(width: 272, height: 272)
                        .shadow(color: Theme.gold, radius: 18)
                }
                // The pad.
                Circle()
                    .fill(RadialGradient(colors: [accent.opacity(0.18 + tapFlash * 0.6), Theme.surfaceRaised],
                                         center: .center, startRadius: 4, endRadius: 125))
                    .frame(width: 226, height: 226)
                    .scaleEffect(1 - tapFlash * 0.06)
                    .overlay(
                        Text(label)
                            .font(.display(label.count > 3 ? 28 : 56))
                            .foregroundStyle(Theme.text)
                            .contentTransition(.numericText())
                    )
            }
            .contentShape(Circle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { _ in if !touching { touchDown() } }.onEnded { _ in touching = false })
        }
    }

    @State private var touching = false

    private var pacePicker: some View {
        HStack(spacing: 10) {
            ForEach(round.paces, id: \.self) { p in
                let name = p < 90 ? "Slow" : p < 110 ? "Medium" : "Fast"
                Button {
                    Haptics.select()
                    pace = p
                } label: {
                    VStack(spacing: 2) {
                        Text(name).font(.label(15, weight: .heavy))
                        Text("\(Int(p)) BPM").font(.label(12, weight: .bold)).opacity(0.75)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: pace == p ? accent : Theme.surfaceHigh,
                                               textColor: pace == p ? Theme.onBrand : Theme.text, height: 58))
            }
        }
    }

    // MARK: Actions

    private func touchDown() {
        touching = true
        Haptics.tap()
        if let s = round.tapSound { AudioEngine.shared.trigger(s, kit: transport.kit(for: genre), velocity: 1) }
        withAnimation(.easeOut(duration: 0.04)) { tapFlash = 1 }
        withAnimation(.easeOut(duration: 0.3).delay(0.05)) { tapFlash = 0 }
        guard phase == .playing, let pos = clock.now() else { return }
        let beat = pos / 4
        taps.append(beat)
        // Light the segment as soon as a tap lands on its beat.
        let (h, _) = matchTaps(taps, to: targets, window: round.tolerance)
        if h != hits { withAnimation { hits = h } }
    }

    private func start() {
        taps = []
        hits = []
        clock.reset(bpm: bpm)
        let bars = totalBars
        let seq: [Pattern] = (0..<bars).map { bar in
            (round.dropBars.contains(bar) ? round.pad : round.loop).without(round.mute)
        }
        withAnimation { phase = .playing }
        transport.play(seq[0], genre: genre, source: .reference, bars: bars, swing: 0, bpm: bpm,
                       sequence: round.dropBars.isEmpty ? [] : seq, barsPerSection: 1)
    }

    private func finish() {
        let (h, offsets) = matchTaps(taps, to: targets, window: round.tolerance)
        hits = h
        let counted = taps.filter { $0 >= 3.6 }.count
        let extras = max(0, counted - h.count)
        let score = max(0, Double(h.count) / Double(round.beats) - Double(extras) * 0.04)
        withAnimation { phase = .done }
        if score >= round.threshold {
            let msg = score > 0.95 ? "You kept every beat alive, even in the dark." : "\(h.count) of \(round.beats) beats kept alive."
            game.pass(score, msg + timingAdvice(offsets))
        } else {
            game.miss("\(h.count) of \(round.beats) beats landed." + timingAdvice(offsets) + " Nod your head with the count-in, then keep nodding.",
                      score: score)
        }
    }

    private func reset() {
        transport.stop()
        withAnimation {
            game.feedback = nil
            phase = .ready
            taps = []
            hits = []
        }
    }

    private func next() {
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            taps = []
            hits = []
            pace = nil
        }
    }
}
