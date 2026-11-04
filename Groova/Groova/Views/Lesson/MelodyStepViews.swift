//
//  MelodyStepViews.swift
//  Groova
//
//  Keyboard and piano-roll exercises.
//

import Foundation
import SwiftUI

// MARK: - Keyboard

struct KeyboardStepView: View {
    let task: KeyboardTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var progress = 0
    @State private var lit = Set<Int>()
    @State private var shake = 0
    @State private var feedback: StepFeedback?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 26) {
                    StepPrompt(title: task.prompt, detail: task.body, badge: "Play")
                    HStack(spacing: 12) {
                        ForEach(Array(task.sequence.enumerated()), id: \.offset) { i, note in
                            let done = i < progress
                            let next = i == progress
                            Text(NoteName.name(note))
                                .font(.display(30))
                                .foregroundStyle(done ? Theme.background : (next ? genre.color : Theme.textTertiary))
                                .frame(width: 72, height: 72)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(done ? genre.color : Theme.surfaceRaised)
                                        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .strokeBorder(next ? genre.color : Theme.stroke, lineWidth: next ? 2 : 1))
                                )
                                .scaleEffect(next ? 1.06 : 1)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: progress)
                        }
                    }
                    .keyframeAnimator(initialValue: 0.0, trigger: shake) { view, x in
                        view.offset(x: x)
                    } keyframes: { _ in
                        KeyframeTrack {
                            SpringKeyframe(-10, duration: 0.06)
                            SpringKeyframe(10, duration: 0.08)
                            SpringKeyframe(-6, duration: 0.08)
                            SpringKeyframe(0, duration: 0.1)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Text(progress >= task.sequence.count ? "Play anything you like — it all fits." : "Find the glowing key.")
                        .font(.label(14, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(20)
            }
            PianoKeyboard(low: task.lowNote, high: task.highNote, highlighted: lit,
                          target: progress < task.sequence.count ? task.sequence[progress] : nil,
                          color: genre.color) { note in
                play(note)
            }
            .frame(height: 190)
            .padding(.horizontal, 12)

            StepFooter(feedback: feedback, primaryTitle: "Continue", primaryEnabled: false,
                       onPrimary: {}, onContinue: { onComplete(1) }, onRetry: {})
        }
    }

    private func play(_ note: Int) {
        AudioEngine.shared.playNote(note, seconds: 0.5, patch: Transport.shared.kit(for: genre).bass)
        flash(note)
        guard progress < task.sequence.count else { return }
        if note == task.sequence[progress] {
            progress += 1
            if progress == task.sequence.count {
                Haptics.success()
                // Play it back as a chord: the notes you just found, together.
                AudioEngine.shared.playChord(task.sequence.map { $0 + 12 }, seconds: 0.8, patch: .keys, delay: 0.35)
                withAnimation {
                    feedback = StepFeedback(kind: .success, title: "That's a chord!",
                                            message: "Played together, A, C and E make A minor — dark and soulful.",
                                            score: nil)
                }
            }
        } else if note % 12 != task.sequence[progress] % 12 {
            shake += 1
        } else {
            progress += 1   // right note, other octave: count it
        }
    }

    private func flash(_ note: Int) {
        lit.insert(note)
        Task {
            try? await Task.sleep(for: .seconds(0.25))
            lit.remove(note)
        }
    }
}

// MARK: - Piano roll

struct PianoRollStepView: View {
    let task: PianoRollTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var notes: [NoteEvent] = []
    @State private var feedback: StepFeedback?
    @State private var correct = Set<UUID>()
    @State private var wrong = Set<UUID>()
    @State private var ghosts: [NoteEvent] = []
    @State private var fails = 0
    @State private var lastScore = 0.0

    private var transport: Transport { Transport.shared }

    private var isRecreate: Bool { if case .recreate = task.mode { true } else { false } }
    private var isCreate: Bool { if case .create = task.mode { true } else { false } }

    init(task: PianoRollTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _notes = State(initialValue: task.start.map { var n = $0; n.id = UUID(); return n })
    }

    private var isLead: Bool { task.voice == .lead }

    /// Puts notes on the right instrument: the bass synth, or the keys for a lead line.
    private func with(_ line: [NoteEvent], on base: Pattern) -> Pattern {
        var p = base
        if isLead {
            p.chords += line.map { ChordEvent(step: $0.step, pitches: [$0.pitch], length: $0.length) }
        } else {
            p.bass = line
        }
        return p
    }

    private var userPattern: Pattern { with(notes, on: task.backing) }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt,
                               detail: isRecreate ? "Tap to place a note. Drag right to stretch it, drag a note to move it, tap it to delete." : task.hint,
                               badge: isRecreate ? "Listen & recreate" : (isCreate ? "Your turn" : "Piano roll"))
                    HStack(spacing: 10) {
                        if isRecreate {
                            TransportButton(title: "Reference",
                                            symbol: transport.isPlaying(.reference) ? "stop.fill" : "ear.fill",
                                            active: transport.isPlaying(.reference), color: Theme.text) {
                                transport.toggle(with(task.target, on: task.backing), genre: genre,
                                                 source: .reference, bars: 2)
                            }
                        }
                        TransportButton(title: isRecreate ? "Yours" : "Play",
                                        symbol: transport.isPlaying(.user) ? "stop.fill" : "play.fill",
                                        active: transport.isPlaying(.user), color: genre.color) {
                            transport.toggle(userPattern, genre: genre, source: .user)
                        }
                        if isRecreate {
                            TransportButton(title: "Both",
                                            symbol: transport.isPlaying(.compare) ? "stop.fill" : "headphones",
                                            active: transport.isPlaying(.compare), color: Theme.text) {
                                if transport.isPlaying(.compare) { transport.stop() } else {
                                    transport.play(userPattern, genre: genre, source: .compare,
                                                   overlay: with(task.target, on: Pattern()))
                                }
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    if transport.isPlaying(.compare) { CompareCaption() }
                    PatternGlyph(pattern: task.backing.keeping(Set(DrumTrack.allCases), bass: false, chords: false),
                                 color: genre.color, playhead: transport.step)
                        .frame(height: 30)
                        .opacity(0.7)
                    if !task.backing.chords.isEmpty {
                        ChordStrip(chords: task.backing.chords, playhead: transport.step)
                    }
                    PianoRollGrid(notes: $notes, rows: task.rows, playhead: transport.step,
                                  patch: isLead ? transport.kit(for: genre).chords : transport.kit(for: genre).bass, correct: correct, wrong: wrong, ghosts: ghosts)
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
            StepFooter(feedback: feedback, primaryTitle: isCreate ? "Done" : "Check", primaryEnabled: canCheck,
                       onPrimary: check, onContinue: { transport.stop(); onComplete(lastScore) },
                       onRetry: { withAnimation { feedback = nil } },
                       helpTitle: fails >= 2 && !isCreate ? "Show me" : nil,
                       onHelp: {
                           withAnimation {
                               notes = task.target.map { var n = $0; n.id = UUID(); return n }
                               feedback = nil; ghosts = []; wrong = []; correct = []
                           }
                       })
        }
        .onChange(of: notes) { _, _ in
            transport.liveUpdate(userPattern)
            if feedback?.kind == .retry || !wrong.isEmpty || !correct.isEmpty {
                withAnimation { feedback = nil; wrong = []; correct = [] }
            }
        }
        .onDisappear { transport.stop() }
    }

    private var canCheck: Bool {
        if case .create(.notesAtLeast(let n)) = task.mode { return notes.count >= n }
        return !notes.isEmpty
    }

    private func check() {
        if isCreate {
            lastScore = 1
            let offKick = notes.filter { !task.backing.kick[$0.step] }.count
            let msg: String
            if isLead {
                let pitches = Set(notes.map(\.pitch)).count
                msg = pitches >= 3
                    ? "That's a real melody. Hum it back: if you can, it's a hook."
                    : "A riff with just a couple of notes can be the catchiest part. Try adding one more pitch next time."
            } else {
                msg = offKick >= notes.count / 2
                    ? "Notes between the kicks give it bounce. That's a real house bassline."
                    : "Notes on the kick feel heavy and solid. Try a few offbeats too, next time."
            }
            withAnimation { feedback = StepFeedback(kind: .success, title: Cheer.win(), message: msg, score: nil) }
            AudioEngine.shared.playSuccess()
            Haptics.success()
            return
        }
        let s = Scoring.melody(user: notes, reference: task.target)
        lastScore = s.accuracy
        let threshold: Double = { if case .rule = task.mode { return 0.999 } else { return task.threshold } }()
        if s.accuracy >= threshold {
            withAnimation {
                correct = s.correctNotes; wrong = s.wrongNotes
                ghosts = task.target.filter { t in !notes.contains(where: { $0 == t }) }
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: s.accuracy >= 0.999 ? "Pitch, timing and length all spot on."
                                                                      : "Groovy. Dashed outlines show the exact notes.",
                                        score: isRecreate ? s.accuracy : nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            fails += 1
            let reveal = !isRecreate || fails >= 2
            withAnimation {
                correct = s.correctNotes
                wrong = s.wrongNotes
                ghosts = reveal ? task.target.filter { t in !notes.contains(where: { $0 == t }) } : []
                feedback = StepFeedback(kind: .retry, title: Cheer.near(s.accuracy),
                                        message: melodyHint(s, reveal: reveal), score: isRecreate ? s.accuracy : nil)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }

    private func melodyHint(_ s: MelodyScore, reveal: Bool) -> String {
        var parts: [String] = []
        if !s.wrongNotes.isEmpty { parts.append("Red notes have the wrong pitch, length or timing") }
        if !s.missedSteps.isEmpty {
            parts.append(reveal ? "dashed outlines show what's missing" : "\(s.missedSteps.count) note\(s.missedSteps.count == 1 ? " is" : "s are") missing")
        }
        return (parts.isEmpty ? "" : parts.joined(separator: "; ") + ". ") + (isRecreate ? "Listen again." : "")
    }
}
