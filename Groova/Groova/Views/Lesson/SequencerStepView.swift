//
//  SequencerStepView.swift
//  Groova
//
//  Drum exercises: follow a rule, recreate by ear, or create freely.
//

import Foundation
import SwiftUI

struct SequencerStepView: View {
    let task: SequencerTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var pattern: Pattern
    @State private var swing: Double
    @State private var feedback: StepFeedback?
    @State private var marks: [DrumTrack: [Int: CellMark]] = [:]
    @State private var rowAccuracy: [DrumTrack: Double] = [:]
    @State private var fails = 0
    @State private var lastScore = 0.0

    private var transport: Transport { Transport.shared }

    init(task: SequencerTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _pattern = State(initialValue: task.start)
        _swing = State(initialValue: task.swingControl ? 0 : genre.swing)
    }

    private var isRecreate: Bool { if case .recreate = task.mode { true } else { false } }
    private var isCreate: Bool { if case .create = task.mode { true } else { false } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: subtitle, badge: badge)
                    transportBar
                    if transport.isPlaying(.compare) { CompareCaption() }
                    StepSequencerGrid(pattern: $pattern, tracks: task.tracks, editable: task.editable,
                                      playhead: transport.step, marks: marks, swing: swing,
                                      beatGuide: task.showBeatGuide, kit: transport.kit(for: genre), rowAccuracy: rowAccuracy)
                    if task.swingControl { swingControl }
                    if feedback == nil, fails > 0, isRecreate {
                        Label(task.hint, systemImage: "lightbulb.fill")
                            .font(.label(14, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .card(padding: 14)
                            .transition(.opacity)
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: feedback,
                       primaryTitle: isCreate ? "Done" : "Check",
                       primaryEnabled: canCheck,
                       onPrimary: check,
                       onContinue: { transport.stop(); onComplete(lastScore) },
                       onRetry: retry,
                       helpTitle: fails >= 2 && !isCreate ? "Show me" : nil,
                       onHelp: showAnswer)
        }
        .onChange(of: pattern) { _, new in
            transport.liveUpdate(new)
            if feedback?.kind == .retry || !marks.isEmpty {
                withAnimation { feedback = nil; marks = [:]; rowAccuracy = [:] }
            }
        }
        .onChange(of: swing) { _, s in AudioEngine.shared.update(swing: s) }
        .onDisappear { transport.stop() }
    }

    private var badge: String {
        switch task.mode {
        case .rule: "Build"
        case .recreate: "Listen & recreate"
        case .create: "Your turn"
        }
    }

    private var subtitle: String? {
        switch task.mode {
        case .recreate: "Play the reference as often as you like."
        case .create: task.hint
        case .rule: task.hint
        }
    }

    // MARK: Transport

    private var transportBar: some View {
        HStack(spacing: 10) {
            if isRecreate {
                TransportButton(title: "Reference", symbol: transport.isPlaying(.reference) ? "stop.fill" : "ear.fill",
                                active: transport.isPlaying(.reference), color: Theme.text) {
                    transport.toggle(task.target, genre: genre, source: .reference, bars: 2, swing: swing)
                }
            }
            TransportButton(title: isRecreate ? "Yours" : "Play",
                            symbol: transport.isPlaying(.user) ? "stop.fill" : "play.fill",
                            active: transport.isPlaying(.user), color: genre.color) {
                transport.toggle(pattern, genre: genre, source: .user, swing: swing)
            }
            if isRecreate {
                TransportButton(title: "Both", symbol: transport.isPlaying(.compare) ? "stop.fill" : "headphones",
                                active: transport.isPlaying(.compare), color: Theme.text) {
                    if transport.isPlaying(.compare) { transport.stop() } else {
                        transport.play(pattern, genre: genre, source: .compare, swing: swing, overlay: task.target)
                    }
                }
            }
            Spacer(minLength: 0)
            if !isRecreate {
                Text("\(Int(genre.bpm)) BPM")
                    .font(.mono(12, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
    }

    private var swingControl: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Swing").font(.label(15, weight: .bold)).foregroundStyle(Theme.text)
                Spacer()
                Text("\(Int(swing * 200))%")
                    .font(.mono(15, weight: .bold))
                    .foregroundStyle(genre.color)
                    .contentTransition(.numericText())
            }
            Slider(value: $swing, in: 0...0.45, onEditingChanged: { editing in
                if !editing { Haptics.select() }
            })
            .tint(genre.color)
            Text(swing < 0.12 ? "Straight and robotic" : swing < 0.25 ? "A little lazy…" : "That's the shuffle.")
                .font(.label(13)).foregroundStyle(Theme.textSecondary)
        }
        .card()
        .task {
            try? await Task.sleep(for: .milliseconds(450))
            if !transport.isPlaying(.user) { transport.play(pattern, genre: genre, source: .user, swing: swing) }
        }
    }

    // MARK: Grading

    private var canCheck: Bool {
        switch task.mode {
        case .create(let goal):
            switch goal {
            case .atLeast(let track, let n): return pattern.hits(track) >= n
            case .swingAtLeast(let s): return swing >= s
            case .notesAtLeast(let n): return pattern.bass.count >= n
            case .chordsAtLeast(let n): return pattern.chords.count >= n
            case .variedSections: return true
            }
        default:
            return task.editable.contains { pattern.hits($0) > 0 }
        }
    }

    private func check() {
        if isCreate {
            lastScore = 1
            withAnimation { feedback = StepFeedback(kind: .success, title: Cheer.win(), message: creativeMessage, score: nil) }
            succeed()
            return
        }
        var user: [Bool] = []
        var ref: [Bool] = []
        var newMarks: [DrumTrack: [Int: CellMark]] = [:]
        var accs: [DrumTrack: Double] = [:]
        for t in task.tracks where task.editable.contains(t) {
            user += pattern[t]
            ref += task.target[t]
            let r = Scoring.rhythm(user: pattern[t], reference: task.target[t])
            newMarks[t] = r.marks
            accs[t] = r.accuracy
        }
        let score = Scoring.rhythm(user: user, reference: ref).accuracy
        lastScore = score
        let threshold: Double = { if case .rule = task.mode { return 0.999 } else { return task.threshold } }()

        if score >= threshold {
            withAnimation {
                marks = newMarks
                rowAccuracy = task.editable.count > 1 ? accs : [:]
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: score >= 0.999 ? "Perfect match." : "Good enough to groove. Tiny differences highlighted.",
                                        score: isRecreate ? score : nil)
            }
            succeed()
        } else {
            fails += 1
            let revealMisses = !isRecreate || fails >= 2
            withAnimation {
                marks = newMarks.mapValues { m in m.filter { revealMisses || $0.value != .missed } }
                rowAccuracy = task.editable.count > 1 ? accs : [:]
                feedback = StepFeedback(kind: .retry, title: Cheer.near(score), message: retryMessage(newMarks, revealMisses),
                                        score: isRecreate ? score : nil)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }

    private func retryMessage(_ m: [DrumTrack: [Int: CellMark]], _ reveal: Bool) -> String {
        let extras = m.values.flatMap(\.values).filter { $0 == .extra }.count
        let missed = m.values.flatMap(\.values).filter { $0 == .missed }.count
        var parts: [String] = []
        if extras > 0 { parts.append("\(extras) hit\(extras == 1 ? "" : "s") in the wrong place (red)") }
        if missed > 0 { parts.append(reveal ? "\(missed) missing (dashed)" : "\(missed) still missing") }
        let summary = parts.isEmpty ? "" : parts.joined(separator: ", ") + ". "
        return summary + (isRecreate ? "Replay the reference and compare." : task.hint)
    }

    private var creativeMessage: String {
        switch task.mode {
        case .create(.atLeast(let track, _)):
            let hits = pattern[track]
            let offbeats = hits.enumerated().filter { $0.element && $0.offset % 2 == 1 }.count
            if offbeats >= 3 { return "Those in-between \(track.name.lowercased())s make it shuffle. That's groove." }
            if pattern.hits(track) >= 10 { return "Busy and driving — great energy for a peak-time track." }
            return "Simple and spacious. Space is a musical choice, too."
        case .create(.swingAtLeast):
            return "Feel that? Swing delays every other 16th so the groove skips instead of marching."
        default:
            return "Nice — that's yours."
        }
    }

    private func succeed() {
        AudioEngine.shared.playSuccess()
        Haptics.success()
    }

    private func retry() {
        withAnimation { feedback = nil }
    }

    private func showAnswer() {
        withAnimation {
            for t in task.editable { pattern[t] = task.target[t] }
            feedback = nil
            marks = [:]
        }
    }
}
