//
//  TimeSlicerGame.swift
//  Groova
//
//  F1.2 Time Slicer. Four glowing beat blocks. Swipe down on a block to slice it into halves,
//  then quarters; swipe up or double-tap to join it again. Every slice is a hi-hat you hear
//  straight away, and each one flashes as the playhead passes.
//

import Foundation
import QuartzCore
import SwiftUI

struct TimeSlicerGame: View {
    let task: GameTask
    let rounds: [SliceRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }
    private enum Shape: String, CaseIterable { case rising = "Rising", falling = "Falling", wave = "Wave" }

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var slices: [Int] = [1, 1, 1, 1]
    @State private var cut: [Double] = [0, 0, 0, 0]
    @State private var hearingTarget = false
    @State private var shape: Shape?
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [SliceRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
        _slices = State(initialValue: rounds.first?.start ?? [1, 1, 1, 1])
    }

    private var round: SliceRound { rounds[min(game.index, rounds.count - 1)] }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if round.mode == .shape { shapePicker }
                    GameStage(height: 340) { stage }
                    if phase == .playing, !round.showTarget, !round.target.isEmpty { targetToggle }
                    legend
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: phase == .playing ? "Check" : "Start slicing",
                       primaryEnabled: phase == .ready || (phase == .playing && (round.mode != .shape || shape != nil)),
                       onPrimary: primary,
                       onContinue: next,
                       onRetry: retry,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onChange(of: transport.step) { _, s in if phase == .playing { clock.follow(s) } }
        .onDisappear { transport.stop() }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { _ in
            let pos = clock.now()
            let step = pos.map { $0.truncatingRemainder(dividingBy: 16) } ?? -1
            VStack(spacing: 14) {
                HStack {
                    StageTag(text: hearingTarget ? "Target" : (phase == .playing ? "Slice" : task.name),
                             color: hearingTarget ? Theme.gold : (phase == .playing ? accent : GameStyle.nightDim))
                    Spacer()
                    StageTag(text: "\(slices.reduce(0, +)) hats")
                }
                Spacer(minLength: 0)
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { b in
                        VStack(spacing: 8) {
                            if round.showTarget, !round.target.isEmpty { targetTicks(round.target[b]) }
                            block(b, step: hearingTarget ? -1 : step)
                            Text(countLabel(slices[b], beat: b))
                                .font(.mono(12))
                                .foregroundStyle(GameStyle.nightDim)
                                .lineLimit(1).minimumScaleFactor(0.6)
                        }
                    }
                }
                Spacer(minLength: 0)
                HStack(spacing: 6) {
                    Image(systemName: "hand.draw.fill")
                    Text("Swipe down to slice · swipe up or double-tap to join")
                }
                .font(.label(12, weight: .bold))
                .foregroundStyle(GameStyle.nightDim)
            }
            .padding(14)
        }
    }

    private func block(_ b: Int, step: Double) -> some View {
        let d = slices[b]
        let color = sliceColor(d)
        return HStack(spacing: 3) {
            ForEach(0..<d, id: \.self) { k in
                let len = 4.0 / Double(d)
                let start = Double(b * 4) + Double(k) * len
                let into = step - start
                let glow = (into >= 0 && into < len) ? max(0, 1 - into / len * 1.4) : 0
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.35 + glow * 0.65))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(GameStyle.ink.opacity(0.15 + glow * 0.7), lineWidth: 2))
                    .shadow(color: color.opacity(glow), radius: 12)
                    .scaleEffect(y: 1 + glow * 0.04)
            }
        }
        .frame(height: 170)
        .overlay(
            // The knife flash when you slice.
            Rectangle().fill(accent).frame(width: 3).opacity(cut[b]).blur(radius: 1)
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 18)
                .onEnded { v in
                    guard abs(v.translation.height) > abs(v.translation.width) else { return }
                    if v.translation.height > 0 { split(b) } else { join(b) }
                }
        )
        .simultaneousGesture(TapGesture(count: 2).onEnded { join(b) })
        .simultaneousGesture(TapGesture(count: 1).onEnded { tick(b) })
        .accessibilityLabel("Beat \(b + 1), \(d) slices")
        .accessibilityAdjustableAction { dir in
            switch dir {
            case .increment: split(b)
            case .decrement: join(b)
            default: break
            }
        }
    }

    private func targetTicks(_ d: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<d, id: \.self) { _ in
                Capsule().strokeBorder(Theme.gold.opacity(0.8), lineWidth: 2).frame(height: 10)
            }
        }
    }

    private func sliceColor(_ d: Int) -> Color {
        switch d {
        case 1: GameStyle.kick
        case 2: GameStyle.hat
        default: GameStyle.lead
        }
    }

    private func countLabel(_ d: Int, beat: Int) -> String {
        let n = "\(beat + 1)"
        switch d {
        case 1: return n
        case 2: return "\(n) &"
        default: return "\(n) e & a"
        }
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendItem(GameStyle.kick, "Whole beat")
            legendItem(GameStyle.hat, "Halves (8ths)")
            legendItem(GameStyle.lead, "Quarters (16ths)")
        }
        .frame(maxWidth: .infinity)
    }

    private func legendItem(_ c: Color, _ s: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3).fill(c).frame(width: 12, height: 12)
            Text(s).font(.label(12, weight: .bold)).foregroundStyle(Theme.textSecondary)
        }
    }

    private var shapePicker: some View {
        HStack(spacing: 10) {
            ForEach(Shape.allCases, id: \.self) { s in
                Button {
                    Haptics.select()
                    shape = s
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: s == .rising ? "chart.line.uptrend.xyaxis" : s == .falling ? "chart.line.downtrend.xyaxis" : "water.waves")
                        Text(s.rawValue).font(.label(14, weight: .heavy))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: shape == s ? accent : Theme.surfaceHigh,
                                               textColor: shape == s ? Theme.onBrand : Theme.text, height: 58))
            }
        }
    }

    private var targetToggle: some View {
        Button(action: toggleTarget) {
            Label(hearingTarget ? "Back to mine" : "Hear the target", systemImage: hearingTarget ? "arrow.uturn.left" : "ear")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ChunkyButtonStyle(color: hearingTarget ? Theme.gold : Theme.surfaceHigh, textColor: Theme.text, height: 54))
    }

    // MARK: Sound

    private func pattern(_ s: [Int]) -> Pattern {
        var p = round.backing
        for b in 0..<4 {
            let d = max(1, s[b])
            for k in 0..<d { p.hat[b * 4 + k * (4 / d)] = true }
        }
        return p
    }

    private func split(_ b: Int) {
        guard slices[b] < 4 else { Haptics.warning(); return }
        Haptics.thump()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { slices[b] *= 2 }
        withAnimation(.easeOut(duration: 0.05)) { cut[b] = 1 }
        withAnimation(.easeOut(duration: 0.35).delay(0.06)) { cut[b] = 0 }
        changed()
    }

    private func join(_ b: Int) {
        guard slices[b] > 1 else { return }
        Haptics.soft()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { slices[b] /= 2 }
        changed()
    }

    private func tick(_ b: Int) {
        Haptics.tap()
        AudioEngine.shared.trigger(.hat, kit: transport.kit(for: genre), velocity: 1)
    }

    private func changed() {
        if game.feedback?.kind == .retry { withAnimation { game.feedback = nil } }
        AudioEngine.shared.trigger(.hat, kit: transport.kit(for: genre), velocity: 1)
        if phase == .playing, !hearingTarget { transport.liveUpdate(pattern(slices)) }
    }

    private func toggleTarget() {
        Haptics.select()
        hearingTarget.toggle()
        clock.reset(bpm: round.bpm)
        transport.play(pattern(hearingTarget ? round.target : slices), genre: genre, source: hearingTarget ? .reference : .user,
                       bars: nil, swing: 0, bpm: round.bpm)
    }

    // MARK: Flow

    private func primary() {
        if phase == .playing { check() } else { start() }
    }

    private func start() {
        clock.reset(bpm: round.bpm)
        hearingTarget = false
        withAnimation { phase = .playing }
        transport.play(pattern(slices), genre: genre, source: .user, bars: nil, swing: 0, bpm: round.bpm)
    }

    private func check() {
        switch round.mode {
        case .match, .fix:
            let wrong = (0..<4).filter { slices[$0] != round.target[$0] }
            if wrong.isEmpty {
                done()
                game.pass(1, round.mode == .fix ? "Fixed. That beat was too busy, now it sits with the rest."
                                              : "Slices match. You can hear the beat split into equal parts.")
            } else {
                let names = wrong.map { "\($0 + 1)" }.joined(separator: ", ")
                let hint = round.showTarget ? "Count the gold ticks above each block." : "Hear the target again and count the hats in each beat."
                game.miss("Beat \(names) \(wrong.count == 1 ? "doesn't" : "don't") match yet. \(hint)",
                          score: Double(4 - wrong.count) / 4)
            }
        case .shape:
            let sparse = slices.contains(1), busy = slices.contains(4)
            let rising = zip(slices, slices.dropFirst()).allSatisfy { $0 <= $1 }
            let falling = zip(slices, slices.dropFirst()).allSatisfy { $0 >= $1 }
            let fits: Bool = {
                switch shape {
                case .rising: return rising
                case .falling: return falling
                case .wave: return !rising && !falling
                case nil: return false
                }
            }()
            if !sparse || !busy {
                game.miss("Use at least one whole beat and one beat in quarters, so there's a clear sparse and busy part.")
            } else if !fits {
                game.miss("That doesn't read as \(shape?.rawValue.lowercased() ?? "a shape") yet. Look at the blocks left to right.")
            } else {
                done()
                game.pass(1, "That's density as a shape. Busier beats push forward, sparse ones breathe.", title: "Shaped")
            }
        }
    }

    private func done() {
        withAnimation { phase = .done }
        if hearingTarget {
            hearingTarget = false
            transport.play(pattern(slices), genre: genre, source: .user, bars: 2, swing: 0, bpm: round.bpm)
        }
    }

    private func retry() {
        withAnimation { game.feedback = nil }
        if phase != .playing { start() }
    }

    private func next() {
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            hearingTarget = false
            shape = nil
            slices = round.start
        }
    }
}
