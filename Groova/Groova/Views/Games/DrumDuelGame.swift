//
//  DrumDuelGame.swift
//  Groova
//
//  F0.2 Build a Beat. Three huge pads: kick, snare and hat. The game plays a call and you
//  answer it with your hands. No grid. Gold records your own call and answer.
//

import Foundation
import QuartzCore
import SwiftUI

struct DrumDuelGame: View {
    let task: GameTask
    let rounds: [DuelRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }
    private struct Hit: Equatable { var pos: Double; var track: DrumTrack }

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var taps: [Hit] = []
    @State private var flash: [DrumTrack: Double] = [:]
    @State private var tried: [DrumTrack: Int] = [:]
    /// Gold: your recorded call and answer, quantised to the grid.
    @State private var myCall: Pattern?
    @State private var myAnswer: Pattern?
    /// What's playing, one pattern per bar, and which bars are yours to answer.
    @State private var bars: [Pattern] = []
    @State private var answerBars: Set<Int> = []
    @State private var targets: [Hit] = []
    @Environment(\.accent) private var accent

    private let pads: [DrumTrack] = [.kick, .clap, .hat]
    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [DuelRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: DuelRound { rounds[min(game.index, rounds.count - 1)] }
    private static let click = Pattern(hat: [0, 4, 8, 12])

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 360) { stage }
                    if phase == .done, !targets.isEmpty { strip }
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: primaryTitle,
                       primaryEnabled: primaryEnabled,
                       onPrimary: primary,
                       onContinue: next,
                       onRetry: reset,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onChange(of: transport.step) { _, s in
            guard phase == .playing else { return }
            clock.follow(s)
            lightCall(s)
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running, phase == .playing, round.mode != .free { finish() }
        }
        .onDisappear { transport.stop() }
    }

    private var primaryTitle: String {
        switch (round.mode, phase) {
        case (.free, .playing): return "I've met them all"
        case (_, .playing): return "Listening…"
        case (.duet, _): return "Play the duet"
        case (.invent, _), (.answer, _): return "Record"
        default: return "Start"
        }
    }

    private var primaryEnabled: Bool {
        if round.mode == .free, phase == .playing { return pads.allSatisfy { (tried[$0] ?? 0) >= 2 } }
        return phase == .ready
    }

    // MARK: Stage

    private var currentBar: Int { clock.bar }
    private var inAnswer: Bool { phase == .playing && answerBars.contains(currentBar) }

    private var stageTag: String {
        guard phase == .playing else { return phase == .done ? "Duel over" : "Ready" }
        switch round.mode {
        case .free: return "Play freely"
        case .invent: return currentBar == 0 ? "Count-in" : "Recording"
        case .duet: return "Your duet"
        default:
            if currentBar == 0 { return "Count-in" }
            return inAnswer ? "Your answer" : "Listen"
        }
    }

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { _ in
            let pos = clock.now() ?? -1
            VStack(spacing: 16) {
                HStack {
                    StageTag(text: stageTag, color: inAnswer || round.mode == .invent ? accent : GameStyle.nightDim)
                    Spacer()
                    beatDots(pos: pos)
                }
                Spacer(minLength: 0)
                HStack(spacing: 12) {
                    ForEach(pads, id: \.self) { t in pad(t, pos: pos) }
                }
                Spacer(minLength: 0)
            }
            .padding(16)
        }
    }

    private func beatDots(pos: Double) -> some View {
        let beat = pos >= 0 ? Int(pos / 4) % 4 : -1
        return HStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { i in
                Circle().fill(beat == i ? Color.white : GameStyle.nightLine).frame(width: 9, height: 9)
            }
        }
    }

    private func pad(_ t: DrumTrack, pos: Double) -> some View {
        let color = GameStyle.color(t)
        let lit = flash[t] ?? 0
        // Cue: glow just before a hit you should play.
        let cue = round.cues && inAnswer && targets.contains { $0.track == t && $0.pos - pos > -0.4 && $0.pos - pos < 1.6 }
        let hideName = round.hideLabels && phase == .playing && !inAnswer && currentBar > 0
        return VStack(spacing: 10) {
            Image(systemName: t.symbol)
                .font(.system(size: 30, weight: .black))
            Text(hideName ? "?" : t.name.uppercased())
                .font(.label(14, weight: .black)).tracking(0.6)
        }
        .foregroundStyle(Color.white.opacity(0.9 + lit * 0.1))
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(color.opacity(0.32 + lit * 0.68))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(cue ? Color.white : color.opacity(0.6), lineWidth: cue ? 4 : 2)
        )
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(color.opacity(0.5)).offset(y: 6))
        .shadow(color: color.opacity(lit), radius: 24)
        .scaleEffect(1 - lit * 0.05)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0).onChanged { _ in press(t) }.onEnded { _ in _ = held.remove(t) })
        .accessibilityLabel(t.name)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { press(t); _ = held.remove(t) }
    }

    @State private var held: Set<DrumTrack> = []

    private var strip: some View {
        let targetPos = targets.map(\.pos)
        let tapPos = taps.map(\.pos)
        let (hits, _) = matchTaps(tapPos, to: targetPos, window: 1.6)
        let start = Double((answerBars.min() ?? 0) * 16)
        return TimingStrip(targets: targetPos.map { $0 - start }, hits: hits, taps: tapPos.map { $0 - start }.filter { $0 >= -1 },
                           length: Double(max(1, answerBars.count) * 16),
                           caption: "Dots are the hits you answered. Lines are your taps.")
    }

    // MARK: Playing

    private func press(_ t: DrumTrack) {
        guard !held.contains(t) else { return }
        held.insert(t)
        Haptics.tap()
        AudioEngine.shared.trigger(t, kit: transport.kit(for: genre), velocity: 1)
        tried[t, default: 0] += 1
        pulse(t)
        if phase == .playing, let pos = clock.now() { taps.append(Hit(pos: pos, track: t)) }
    }

    private func pulse(_ t: DrumTrack) {
        withAnimation(.easeOut(duration: 0.04)) { flash[t] = 1 }
        withAnimation(.easeOut(duration: 0.28).delay(0.05)) { flash[t] = 0 }
    }

    /// Light the pads as the call plays, so you see what you hear.
    private func lightCall(_ step: Int) {
        guard step >= 0, currentBar < bars.count, !answerBars.contains(currentBar), currentBar > 0 else { return }
        guard !(round.hideLabels) else { return }
        let p = bars[currentBar]
        for t in pads where p[t][step] { pulse(t) }
    }

    private func primary() {
        if round.mode == .free, phase == .playing {
            transport.stop()
            withAnimation { phase = .done }
            game.pass(1, "Low thump, sharp crack, bright tick. Those three jobs make most beats.")
            return
        }
        start()
    }

    private func start() {
        taps = []
        targets = []
        answerBars = []
        tried = [:]
        clock.reset(bpm: round.bpm)
        var seq: [Pattern] = [Self.click]
        switch round.mode {
        case .free:
            seq = [round.backing.isEmpty ? Self.click : round.backing]
        case .echo:
            for _ in 0..<max(1, round.repeats) {
                for c in round.call {
                    seq.append(c)
                }
                for c in round.call {
                    answerBars.insert(seq.count)
                    addTargets(c, bar: seq.count)
                    seq.append(round.backing)
                }
            }
        case .role(let t):
            let groove = round.call.first ?? Pattern()
            for _ in 0..<max(2, round.repeats) {
                answerBars.insert(seq.count)
                addTargets(groove, bar: seq.count, only: t)
                seq.append(groove.without([t]).merged(with: round.backing))
            }
        case .invent:
            answerBars.insert(seq.count)
            seq.append(round.backing.isEmpty ? Self.click : round.backing)
        case .answer:
            seq.append(myCall ?? Pattern())
            answerBars.insert(seq.count)
            seq.append(round.backing.isEmpty ? Self.click : round.backing)
        case .duet:
            let call = myCall ?? Pattern(), answer = myAnswer ?? Pattern()
            seq = [call.merged(with: round.backing), answer.merged(with: round.backing),
                   call.merged(with: round.backing), answer.merged(with: round.backing)]
        }
        bars = seq
        withAnimation { phase = .playing }
        let loopForever = round.mode == .free
        transport.play(seq[0], genre: genre, source: .reference, bars: loopForever ? nil : seq.count, swing: 0, bpm: round.bpm,
                       sequence: seq.count > 1 ? seq : [], barsPerSection: 1)
    }

    private func addTargets(_ p: Pattern, bar: Int, only: DrumTrack? = nil) {
        for t in pads where only == nil || only == t {
            for s in 0..<Pattern.steps where p[t][s] { targets.append(Hit(pos: Double(bar * 16 + s), track: t)) }
        }
        targets.sort { $0.pos < $1.pos }
    }

    /// Your taps in one bar, snapped to the nearest step.
    private func recorded(bar: Int) -> Pattern {
        var p = Pattern()
        for h in taps {
            let rel = h.pos - Double(bar * 16)
            let s = Int(rel.rounded())
            if s >= 0, s < Pattern.steps { p[h.track][s] = true }
            else if s == Pattern.steps { p[h.track][0] = true }
        }
        return p
    }

    private func finish() {
        withAnimation { phase = .done }
        switch round.mode {
        case .free: return
        case .invent:
            let bar = answerBars.first ?? 1
            let p = recorded(bar: bar)
            let missing = pads.filter { p.hits($0) == 0 }
            if missing.isEmpty {
                myCall = p
                game.pass(1, "That's your call. Hear it loop, then answer it next.")
                transport.play(p, genre: genre, source: .user, bars: 2, swing: 0, bpm: round.bpm)
            } else {
                game.miss("Use all three pads in your bar. Missing: \(missing.map(\.name).joined(separator: ", ")).")
            }
        case .answer:
            let bar = answerBars.first ?? 2
            let p = recorded(bar: bar)
            let call = myCall ?? Pattern()
            var same = 0, changed = 0
            for t in pads {
                for s in 0..<Pattern.steps {
                    if p[t][s] && call[t][s] { same += 1 } else if p[t][s] != call[t][s] { changed += 1 }
                }
            }
            if p.isEmpty {
                game.miss("Nothing recorded. Tap the pads during the bar after your call.")
            } else if same == 0 {
                game.miss("Keep at least one hit from your call, so it sounds like a reply.")
            } else if changed == 0 {
                game.miss("That's an exact copy. Change at least one hit or rest.")
            } else {
                myAnswer = p
                game.pass(1, "Same idea, new twist. That's a call and an answer.")
            }
        case .duet:
            game.pass(1, "Two bars, one conversation. That's your first beat.", title: "Your beat")
        case .echo, .role:
            let (hits, offsets) = matchTaps(taps.map(\.pos), to: targets.map(\.pos), window: 1.6)
            // Hits on the right pad.
            var right = 0
            var used = Set<Int>()
            for target in targets {
                if let j = taps.indices.first(where: { !used.contains($0) && taps[$0].track == target.track && abs(taps[$0].pos - target.pos) <= 1.6 }) {
                    used.insert(j)
                    right += 1
                }
            }
            let answered = taps.filter { h in answerBars.contains(Int(floor((h.pos + 1) / 16))) }.count
            let extras = max(0, answered - right)
            let n = max(1, targets.count)
            let score = max(0, Double(right) / Double(n) - Double(extras) * 0.05)
            let detail = "Timing \(hits.count) of \(n), drums right \(right) of \(n)."
            if score >= round.threshold {
                game.pass(score, detail + timingAdvice(offsets.map { $0 / 4 }))
            } else {
                game.miss(detail + " Watch which pad lights during the call, then copy it.", score: score)
            }
        }
    }

    private func reset() {
        transport.stop()
        withAnimation {
            game.feedback = nil
            phase = .ready
            taps = []
        }
    }

    private func next() {
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            taps = []
            targets = []
        }
    }
}
