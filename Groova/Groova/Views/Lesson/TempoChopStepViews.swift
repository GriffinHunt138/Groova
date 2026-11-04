//
//  TempoChopStepViews.swift
//  Groova
//
//  Two lesson steps: finding a tempo (by number or by ear), and placing vocal chops in a loop.
//

import Foundation
import SwiftUI

// MARK: - Tempo

struct TempoStepView: View {
    let task: TempoTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var bpm: Double
    @State private var feedback: StepFeedback?
    @State private var fails = 0
    @State private var lastScore = 1.0
    @State private var moved = false
    @State private var taps: [Date] = []

    private var transport: Transport { Transport.shared }

    init(task: TempoTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _bpm = State(initialValue: task.start)
    }

    private var rounded: Int { Int(bpm.rounded()) }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: task.body, badge: badge)
                    transportBar
                    readout
                    controls
                    if feedback == nil, fails > 0 {
                        Label(hint, systemImage: "lightbulb.fill")
                            .font(.label(14, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .card(padding: 14)
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: feedback,
                       primaryTitle: task.target == nil ? "Done" : "Check",
                       primaryEnabled: task.target != nil || moved,
                       onPrimary: check,
                       onContinue: { transport.stop(); onComplete(lastScore) },
                       onRetry: { withAnimation { feedback = nil } },
                       helpTitle: fails >= 2 && task.target != nil ? "Show me" : nil,
                       onHelp: {
                           guard let t = task.target else { return }
                           withAnimation { bpm = t; feedback = nil }
                       })
        }
        .onChange(of: bpm) { _, new in
            moved = true
            if transport.isPlaying(.user) { transport.liveUpdate(bpm: new) }
            if feedback?.kind == .retry { withAnimation { feedback = nil } }
        }
        .onDisappear { transport.stop() }
    }

    private var badge: String {
        if task.target == nil { return "Explore tempo" }
        return task.byEar ? "Listen & match" : "Tempo"
    }

    private var hint: String {
        guard let t = task.target else { return "" }
        if task.byEar {
            return "Play both and listen to the kicks. If yours drifts ahead, slow it down. If it falls behind, speed it up."
        }
        return "Drag the slider or use the buttons until the number reads \(Int(t))."
    }

    private var transportBar: some View {
        HStack(spacing: 10) {
            if task.byEar, let target = task.target {
                TransportButton(title: "Reference", symbol: transport.isPlaying(.reference) ? "stop.fill" : "ear.fill",
                                active: transport.isPlaying(.reference), color: Theme.text) {
                    if transport.isPlaying(.reference) { transport.stop() } else {
                        transport.play(task.loop, genre: genre, source: .reference, swing: task.swing, bpm: target)
                    }
                }
            }
            TransportButton(title: task.byEar ? "Yours" : "Play",
                            symbol: transport.isPlaying(.user) ? "stop.fill" : "play.fill",
                            active: transport.isPlaying(.user), color: genre.color) {
                if transport.isPlaying(.user) { transport.stop() } else {
                    transport.play(task.loop, genre: genre, source: .user, swing: task.swing, bpm: bpm)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var readout: some View {
        let beat = transport.isPlaying(.user) && transport.step >= 0 && transport.step % 4 == 0
        return VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(rounded)")
                    .font(.display(64)).monospacedDigit()
                    .foregroundStyle(Theme.text)
                    .contentTransition(.numericText())
                Text("BPM").font(.label(16, weight: .black)).foregroundStyle(Theme.textTertiary)
            }
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(transport.isPlaying(.user) && transport.step / 4 == i ? genre.color : Theme.surfaceHigh)
                        .frame(width: 12, height: 12)
                }
            }
            .scaleEffect(beat ? 1.08 : 1)
            .animation(.easeOut(duration: 0.08), value: beat)
            if let t = task.target, !task.byEar {
                Text("Target: \(Int(t)) BPM").font(.label(14, weight: .bold)).foregroundStyle(Theme.textSecondary)
            } else if task.byEar {
                Text("Match the reference").font(.label(14, weight: .bold)).foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .card()
    }

    private var controls: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                nudge("minus", -1)
                Slider(value: $bpm, in: TempoTask.range, step: 1)
                    .tint(genre.color)
                    .accessibilityLabel("Tempo")
                    .accessibilityValue("\(rounded) BPM")
                nudge("plus", 1)
            }
            Button {
                tap()
            } label: {
                Label("Tap along", systemImage: "hand.tap.fill")
                    .font(.label(16, weight: .heavy))
                    .foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(LipStyle(fill: Theme.surface, lip: Theme.stroke, border: Theme.stroke, radius: 16))
            .accessibilityHint("Tap on each beat to set the tempo")
        }
    }

    private func nudge(_ symbol: String, _ by: Double) -> some View {
        Button {
            Haptics.select()
            bpm = min(TempoTask.range.upperBound, max(TempoTask.range.lowerBound, bpm.rounded() + by))
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(Theme.text)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(LipStyle(fill: Theme.surface, lip: Theme.stroke, border: Theme.stroke, radius: 14))
        .accessibilityLabel(by > 0 ? "Faster" : "Slower")
    }

    /// Tap tempo: the average gap between the last few taps.
    private func tap() {
        Haptics.tap()
        let now = Date()
        if let last = taps.last, now.timeIntervalSince(last) > 2 { taps = [] }
        taps = Array((taps + [now]).suffix(6))
        guard taps.count >= 3, let first = taps.first, let last = taps.last else { return }
        let gap = last.timeIntervalSince(first) / Double(taps.count - 1)
        guard gap > 0 else { return }
        bpm = min(TempoTask.range.upperBound, max(TempoTask.range.lowerBound, (60 / gap).rounded()))
    }

    private func check() {
        guard let target = task.target else {
            lastScore = 1
            withAnimation {
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: "Same loop, new energy. Tempo changes how a groove feels before anything else does.",
                                        score: nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
            return
        }
        let off = Double(rounded) - target
        if abs(off) <= task.tolerance {
            lastScore = max(0.6, 1 - abs(off) / (task.tolerance * 3))
            withAnimation {
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: abs(off) < 0.5 ? "Exactly \(Int(target)) BPM." : "Within \(Int(abs(off).rounded())) BPM. Locked in.",
                                        score: task.byEar ? lastScore : nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            fails += 1
            let msg = off < 0 ? "Yours is too slow. Speed it up." : "Yours is too fast. Bring it down."
            withAnimation {
                feedback = StepFeedback(kind: .retry, title: abs(off) <= 8 ? "So close" : "Not yet",
                                        message: msg, score: nil)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }
}

// MARK: - Vocal chops

/// A lane of vocal chops on a loop. Works like the chord lane, but sung by the Sandbox vocal synth.
struct ChopLaneStepView: View {
    let task: ChordLaneTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var cells: [Int?]
    @State private var brush = 0
    @State private var showAnswer = false
    @State private var feedback: StepFeedback?
    @State private var marks: [Int: CellMark] = [:]
    @State private var fails = 0
    @State private var lastScore = 0.0

    private var transport: Transport { Transport.shared }
    private var chops: [VoxChop] { task.chops ?? [] }

    init(task: ChordLaneTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _cells = State(initialValue: task.cells(task.start))
    }

    private var isRecreate: Bool { if case .recreate = task.mode { true } else { false } }
    private var isCreate: Bool { if case .create = task.mode { true } else { false } }

    private func song(_ lanes: [[Int?]]) -> JamSong {
        ChopSong.song(backing: task.backing, kit: transport.kit(for: genre), chops: chops, lanes: lanes,
                      length: task.stabLength, vox: task.vox)
    }

    private var playheadStep: Int {
        transport.isPlaying(.reference) || transport.isPlaying(.jamLoop) || transport.isPlaying(.jamSong)
            ? transport.step : -1
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: subtitle, badge: badge)
                    transportBar
                    if transport.isPlaying(.jamSong) { CompareCaption() }
                    palette
                    VStack(spacing: 10) {
                        PatternGlyph(pattern: task.backing.keeping(Set(DrumTrack.allCases), bass: false, chords: false),
                                     color: Theme.textTertiary, playhead: playheadStep)
                            .frame(height: 26)
                        StepNumbers(playhead: playheadStep, beatGuide: true)
                        ChordLaneRow(cells: $cells, names: chops.map(\.name), brush: brush,
                                     playhead: playheadStep, marks: marks) { idx in
                            if !transport.isRunning { audition(idx) }
                        }
                    }
                    .card()
                    if showAnswer, !isCreate {
                        Label(answerText, systemImage: "checkmark.circle.fill")
                            .font(.label(14, weight: .bold))
                            .foregroundStyle(Theme.successInk)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous).fill(Theme.successSoft))
                            .transition(.opacity)
                    }
                    if feedback == nil, fails > 0, isRecreate {
                        Label(task.hint, systemImage: "lightbulb.fill")
                            .font(.label(14, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .card(padding: 14)
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: feedback,
                       primaryTitle: isCreate ? "Done" : "Check",
                       primaryEnabled: canCheck,
                       onPrimary: check,
                       onContinue: { transport.stop(); onComplete(lastScore) },
                       onRetry: { withAnimation { feedback = nil } },
                       helpTitle: fails >= 2 && !isCreate ? "Show me" : nil,
                       onHelp: {
                           withAnimation {
                               cells = task.cells(task.target)
                               feedback = nil
                               marks = [:]
                           }
                       })
        }
        .onChange(of: cells) { _, new in
            if transport.isPlaying(.jamLoop) { transport.liveUpdate(jam: song([new])) }
            if transport.isPlaying(.jamSong) { transport.liveUpdate(jam: song([task.cells(task.target), new])) }
            if feedback?.kind == .retry || !marks.isEmpty {
                withAnimation { feedback = nil; marks = [:]; showAnswer = false }
            }
        }
        .onDisappear { transport.stop() }
    }

    private var badge: String {
        switch task.mode {
        case .rule: "Vocal chops"
        case .recreate: "Listen & recreate"
        case .create: "Your turn"
        }
    }

    private var subtitle: String? {
        if case .recreate = task.mode { return "Play the reference as often as you like." }
        return task.hint
    }

    private func toggle(_ source: PlaySource, _ lanes: @autoclosure () -> [[Int?]]) {
        if transport.isPlaying(source) { transport.stop(); return }
        transport.play(jam: song(lanes()), source: source, bpm: genre.bpm, swing: genre.swing)
    }

    private var transportBar: some View {
        HStack(spacing: 10) {
            if isRecreate {
                TransportButton(title: "Reference", symbol: transport.isPlaying(.reference) ? "stop.fill" : "ear.fill",
                                active: transport.isPlaying(.reference), color: Theme.text) {
                    toggle(.reference, [task.cells(task.target)])
                }
            }
            TransportButton(title: isRecreate ? "Yours" : "Play",
                            symbol: transport.isPlaying(.jamLoop) ? "stop.fill" : "play.fill",
                            active: transport.isPlaying(.jamLoop), color: genre.color) {
                toggle(.jamLoop, [cells])
            }
            if isRecreate {
                TransportButton(title: "Both", symbol: transport.isPlaying(.jamSong) ? "stop.fill" : "headphones",
                                active: transport.isPlaying(.jamSong), color: Theme.text) {
                    toggle(.jamSong, [task.cells(task.target), cells])
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var palette: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(chops.enumerated()), id: \.offset) { i, chop in
                    let on = brush == i
                    Button {
                        Haptics.select()
                        brush = i
                        audition(i)
                    } label: {
                        VStack(spacing: 1) {
                            Text(chop.name).font(.label(16, weight: .heavy))
                            Text(NoteName.name(chop.pitch)).font(.label(11, weight: .bold)).opacity(0.75)
                        }
                        .foregroundStyle(on ? Theme.onBrand : Theme.text)
                        .padding(.horizontal, 14)
                        .frame(minWidth: 64)
                        .frame(height: 50)
                    }
                    .buttonStyle(LipStyle(fill: on ? genre.color : Theme.surface,
                                          lip: on ? Theme.lip(for: genre.color) : Theme.stroke,
                                          border: on ? .clear : Theme.stroke, radius: 14))
                    .accessibilityLabel("\(chop.name) chop on \(NoteName.name(chop.pitch))")
                }
            }
            .padding(.bottom, 6)
        }
    }

    private func audition(_ idx: Int) {
        guard idx >= 0, idx < chops.count else { return }
        let c = chops[idx]
        let seconds = Double(task.stabLength) * 15 / genre.bpm
        AudioEngine.shared.playVox(c.pitch, seconds: max(0.15, seconds), from: c.from, to: c.to, settings: task.vox)
    }

    private var chopCount: Int { cells.compactMap { $0 }.count }

    private var answerText: String {
        let groups = chops.indices.compactMap { idx -> String? in
            let steps = task.target.filter { $0.value == idx }.keys.sorted().map { "\($0 + 1)" }
            return steps.isEmpty ? nil : "\(chops[idx].name) on step\(steps.count == 1 ? "" : "s") \(steps.joined(separator: ", "))"
        }
        return "Answer: " + groups.joined(separator: " · ")
    }

    private var canCheck: Bool {
        if case .create(.chordsAtLeast(let n)) = task.mode { return chopCount >= n }
        return chopCount > 0
    }

    private func check() {
        if isCreate {
            lastScore = 1
            let offbeats = cells.enumerated().filter { $0.element != nil && $0.offset % 4 != 0 }.count
            let msg = offbeats * 2 >= chopCount
                ? "Chops between the kicks bounce off the beat. That's how a vocal hook grabs the dance floor."
                : "Chops on the beat sound bold and chant-like. Try sliding one off the beat to make it bounce."
            withAnimation { feedback = StepFeedback(kind: .success, title: Cheer.win(), message: msg, score: nil) }
            AudioEngine.shared.playSuccess()
            Haptics.success()
            return
        }
        let r = Scoring.chordLane(user: cells, reference: task.cells(task.target))
        lastScore = r.accuracy
        let threshold: Double = { if case .rule = task.mode { return 0.999 } else { return task.threshold } }()
        if r.accuracy >= threshold {
            withAnimation {
                marks = r.marks
                showAnswer = true
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: r.accuracy >= 0.999 ? "Right chops, right place."
                                                                     : "Close enough to groove. Differences highlighted.",
                                        score: isRecreate ? r.accuracy : nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            fails += 1
            let reveal = !isRecreate || fails >= 2
            withAnimation {
                marks = r.marks.filter { reveal || $0.value != .missed }
                showAnswer = reveal
                let wrong = r.marks.values.filter { $0 == .extra }.count
                let missed = r.marks.values.filter { $0 == .missed }.count
                var parts: [String] = []
                if wrong > 0 { parts.append("\(wrong) in red \(wrong == 1 ? "is" : "are") the wrong chop or in the wrong place") }
                if missed > 0 { parts.append(reveal ? "\(missed) missing (dashed)" : "\(missed) still missing") }
                let summary = parts.isEmpty ? "" : parts.joined(separator: ", ") + ". "
                feedback = StepFeedback(kind: .retry, title: Cheer.near(r.accuracy),
                                        message: summary + (isRecreate ? "Replay the reference and compare." : task.hint),
                                        score: isRecreate ? r.accuracy : nil)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }
}
