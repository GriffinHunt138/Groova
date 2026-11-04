//
//  ChordStepViews.swift
//  Groova
//
//  Chord exercises: build a chord on the keyboard, pick what you hear, and place stabs in a chord lane.
//

import Foundation
import SwiftUI

// MARK: - Chord builder

struct ChordBuilderStepView: View {
    let task: ChordBuilderTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var selected: [Int]
    @State private var feedback: StepFeedback?
    @State private var fails = 0

    init(task: ChordBuilderTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _selected = State(initialValue: task.start)
    }

    private var sortedSelection: [Int] { selected.sorted() }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    StepPrompt(title: task.prompt, detail: task.body, badge: "Build a chord")
                    noteSlots
                    HStack {
                        TransportButton(title: "Hear it", symbol: "speaker.wave.2.fill", active: false,
                                        color: genre.color) { strum() }
                            .disabled(selected.isEmpty)
                            .opacity(selected.isEmpty ? 0.5 : 1)
                        Spacer()
                        if !selected.isEmpty {
                            Button("Clear") {
                                Haptics.soft()
                                withAnimation { selected = [] }
                            }
                            .font(.label(15, weight: .heavy))
                            .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    Text("Tap a key to add it. Tap it again to take it out.")
                        .font(.label(14, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
            }
            PianoKeyboard(low: task.lowNote, high: task.highNote, highlighted: Set(selected),
                          color: genre.color) { note in toggle(note) }
                .frame(height: 190)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            StepFooter(feedback: feedback, primaryTitle: "Check", primaryEnabled: !selected.isEmpty,
                       onPrimary: check,
                       onContinue: { onComplete(1) },
                       onRetry: { withAnimation { feedback = nil } },
                       helpTitle: fails >= 2 ? "Show me" : nil,
                       onHelp: {
                           withAnimation {
                               selected = task.target.pitches.filter { (task.lowNote...task.highNote).contains($0) }
                               feedback = nil
                           }
                           strum()
                       })
        }
        .onChange(of: selected) { _, _ in
            if feedback?.kind == .retry { withAnimation { feedback = nil } }
        }
    }

    private var noteSlots: some View {
        let count = max(task.target.pitches.count, selected.count)
        return HStack(spacing: 10) {
            ForEach(0..<count, id: \.self) { i in
                let has = i < sortedSelection.count
                Text(has ? NoteName.name(sortedSelection[i]) : "?")
                    .font(.display(26))
                    .foregroundStyle(has ? Theme.onBrand : Theme.textTertiary)
                    .frame(width: 62, height: 62)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(has ? genre.color : Theme.surface)
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(has ? .clear : Theme.stroke,
                                              style: StrokeStyle(lineWidth: Theme.border, dash: has ? [] : [5, 4])))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(has ? Theme.lip(for: genre.color) : .clear)
                            .offset(y: 4)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: has)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func toggle(_ note: Int) {
        if let i = selected.firstIndex(of: note) {
            selected.remove(at: i)
        } else {
            selected.append(note)
            AudioEngine.shared.playNote(note, seconds: 0.45, patch: .keys)
        }
    }

    private func strum() {
        guard !selected.isEmpty else { return }
        AudioEngine.shared.playChord(sortedSelection, seconds: 0.9, patch: .keys)
    }

    private func check() {
        let have = Set(selected.map { (($0 % 12) + 12) % 12 })
        let want = task.target.pitchClasses
        if have == want && selected.count == want.count {
            strum()
            Haptics.success()
            withAnimation {
                feedback = StepFeedback(kind: .success, title: "That's \(task.target.name)!",
                                        message: "\(sortedSelection.map { NoteName.name($0) }.joined(separator: ", ")) together.",
                                        score: nil)
            }
            return
        }
        fails += 1
        let wrong = have.subtracting(want).count
        let missing = want.subtracting(have).count
        var parts: [String] = []
        if wrong > 0 { parts.append("\(wrong) note\(wrong == 1 ? " doesn't" : "s don't") belong") }
        if missing > 0 { parts.append("\(missing) still missing") }
        if parts.isEmpty { parts.append("Each note only once") }
        if fails >= 2 {
            let names = task.target.pitches.sorted().map { NoteName.name($0) }.joined(separator: ", ")
            parts.append("The answer is \(names)")
        }
        AudioEngine.shared.playNudge()
        Haptics.warning()
        withAnimation {
            feedback = StepFeedback(kind: .retry, title: Cheer.near(0.6),
                                    message: parts.joined(separator: ". ") + ".", score: nil)
        }
    }
}

// MARK: - Ear choice

struct EarChoiceStepView: View {
    let task: EarChoiceTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var round = 0
    @State private var picked: Int?
    @State private var firstTry = 0
    @State private var missedThisRound = false
    @State private var feedback: StepFeedback?
    @State private var playing = false

    private var current: EarRound { task.rounds[min(round, task.rounds.count - 1)] }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    StepPrompt(title: task.prompt, detail: task.body,
                               badge: "Ear training · \(round + 1) of \(task.rounds.count)")
                    Button(action: play) {
                        VStack(spacing: 10) {
                            Image(systemName: playing ? "speaker.wave.3.fill" : "play.fill")
                                .font(.system(size: 34, weight: .black))
                                .symbolEffect(.variableColor.iterative, isActive: playing)
                            Text(current.chords.count > 1 ? "Play the chords" : "Play the chord")
                                .font(.label(15, weight: .heavy))
                        }
                        .foregroundStyle(Theme.onBrand)
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                    }
                    .buttonStyle(LipStyle(fill: genre.color, lip: Theme.lip(for: genre.color), border: .clear,
                                          radius: 22, depth: 5))

                    VStack(spacing: 12) {
                        ForEach(Array(current.options.enumerated()), id: \.offset) { i, option in
                            optionButton(i, option)
                        }
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: feedback, primaryTitle: "Check", primaryEnabled: picked != nil,
                       onPrimary: check, onContinue: next,
                       onRetry: { withAnimation { feedback = nil; picked = nil } })
        }
        .task(id: round) {
            try? await Task.sleep(for: .milliseconds(450))
            play()
        }
    }

    private func optionButton(_ i: Int, _ option: String) -> some View {
        let isPicked = picked == i
        let isAnswer = i == current.answer
        let done = feedback != nil
        let wrongPick = done && isPicked && !isAnswer
        let fill: Color = done && isAnswer ? Theme.successSoft : (wrongPick ? Theme.missSoft : (isPicked ? Theme.brandSoft : Theme.surface))
        let border: Color = done && isAnswer ? Theme.successLip : (wrongPick ? Theme.missLip : (isPicked ? Theme.brandBorder : Theme.stroke))
        let ink: Color = done && isAnswer ? Theme.successInk : (wrongPick ? Theme.missInk : (isPicked ? Theme.brand : Theme.text))
        return Button {
            guard feedback == nil else { return }
            Haptics.select()
            picked = i
        } label: {
            Text(option)
                .font(.label(18, weight: .heavy))
                .foregroundStyle(ink)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
        }
        .buttonStyle(LipStyle(fill: fill, lip: border, border: border, radius: 16))
    }

    private func play() {
        playing = true
        for (i, chord) in current.chords.enumerated() {
            AudioEngine.shared.playChord(chord.pitches, seconds: 0.75, patch: SoundFlavor.earPatch(Transport.shared.flavor + round),
                                         delay: Double(i) * 0.85)
        }
        let length = Double(current.chords.count) * 0.85 + 0.2
        Task {
            try? await Task.sleep(for: .seconds(length))
            playing = false
        }
    }

    private func check() {
        guard let picked else { return }
        if picked == current.answer {
            if !missedThisRound { firstTry += 1 }
            AudioEngine.shared.playSuccess()
            Haptics.success()
            withAnimation {
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: current.explain.isEmpty ? "Your ears are getting sharp." : current.explain,
                                        score: nil)
            }
        } else {
            missedThisRound = true
            AudioEngine.shared.playNudge()
            Haptics.warning()
            let answer = current.options[current.answer]
            withAnimation {
                feedback = StepFeedback(kind: .reveal, title: "Not quite",
                                        message: "It was \(answer). " + (current.explain.isEmpty ? "Tap play to hear it again." : current.explain),
                                        score: nil)
            }
        }
    }

    private func next() {
        if round + 1 >= task.rounds.count {
            onComplete(Double(firstTry) / Double(max(1, task.rounds.count)))
        } else {
            withAnimation {
                round += 1
                picked = nil
                missedThisRound = false
                feedback = nil
            }
        }
    }
}

// MARK: - Chord lane

struct ChordLaneStepView: View {
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

    init(task: ChordLaneTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _cells = State(initialValue: task.cells(task.start))
    }

    private var isRecreate: Bool { if case .recreate = task.mode { true } else { false } }
    private var isCreate: Bool { if case .create = task.mode { true } else { false } }

    private var userPattern: Pattern {
        var p = task.backing
        p.chords = task.chords(cells)
        return p
    }

    private var referencePattern: Pattern {
        var p = task.backing
        p.chords = task.chords(task.cells(task.target))
        return p
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: subtitle, badge: badge)
                    transportBar
                    if transport.isPlaying(.compare) { CompareCaption() }
                    if task.palette.count > 1 || isCreate { palette }
                    VStack(spacing: 10) {
                        PatternGlyph(pattern: task.backing.keeping(Set(DrumTrack.allCases), bass: false, chords: false),
                                     color: Theme.textTertiary, playhead: transport.step)
                            .frame(height: 26)
                        StepNumbers(playhead: transport.step, beatGuide: true)
                        ChordLaneRow(cells: $cells, names: task.palette.map(\.name), brush: brush,
                                     playhead: transport.step, marks: marks) { idx in
                            if !transport.isRunning {
                                AudioEngine.shared.playChord(task.palette[idx].pitches, seconds: 0.3,
                                                             patch: Transport.shared.kit(for: genre).chords)
                            }
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
        .onChange(of: cells) { _, _ in
            transport.liveUpdate(userPattern)
            if feedback?.kind == .retry || !marks.isEmpty {
                withAnimation { feedback = nil; marks = [:]; showAnswer = false }
            }
        }
        .onDisappear { transport.stop() }
    }

    private var badge: String {
        switch task.mode {
        case .rule: "Chords"
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

    private var transportBar: some View {
        HStack(spacing: 10) {
            if isRecreate {
                TransportButton(title: "Reference", symbol: transport.isPlaying(.reference) ? "stop.fill" : "ear.fill",
                                active: transport.isPlaying(.reference), color: Theme.text) {
                    transport.toggle(referencePattern, genre: genre, source: .reference, bars: 2)
                }
            }
            TransportButton(title: isRecreate ? "Yours" : "Play",
                            symbol: transport.isPlaying(.user) ? "stop.fill" : "play.fill",
                            active: transport.isPlaying(.user), color: genre.color) {
                transport.toggle(userPattern, genre: genre, source: .user)
            }
            if isRecreate {
                TransportButton(title: "Both", symbol: transport.isPlaying(.compare) ? "stop.fill" : "headphones",
                                active: transport.isPlaying(.compare), color: Theme.text) {
                    if transport.isPlaying(.compare) { transport.stop() } else {
                        var ref = Pattern()
                        ref.chords = task.chords(task.cells(task.target))
                        transport.play(userPattern, genre: genre, source: .compare, overlay: ref)
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var palette: some View {
        HStack(spacing: 10) {
            ForEach(Array(task.palette.enumerated()), id: \.offset) { i, chord in
                let on = brush == i
                Button {
                    Haptics.select()
                    brush = i
                    AudioEngine.shared.playChord(chord.pitches, seconds: 0.45, patch: Transport.shared.kit(for: genre).chords)
                } label: {
                    Text(chord.name)
                        .font(.label(16, weight: .heavy))
                        .foregroundStyle(on ? Theme.onBrand : Theme.text)
                        .padding(.horizontal, 14)
                        .frame(minWidth: 64)
                        .frame(height: 44)
                }
                .buttonStyle(LipStyle(fill: on ? genre.color : Theme.surface,
                                      lip: on ? Theme.lip(for: genre.color) : Theme.stroke,
                                      border: on ? .clear : Theme.stroke, radius: 14))
            }
            Spacer(minLength: 0)
        }
    }

    private var chordCount: Int { cells.compactMap { $0 }.count }

    /// "Am7 on steps 3, 7 · Dm7 on steps 11, 15"
    private var answerText: String {
        let groups = task.palette.indices.compactMap { idx -> String? in
            let steps = task.target.filter { $0.value == idx }.keys.sorted().map { "\($0 + 1)" }
            return steps.isEmpty ? nil : "\(task.palette[idx].name) on step\(steps.count == 1 ? "" : "s") \(steps.joined(separator: ", "))"
        }
        return "Answer: " + groups.joined(separator: " · ")
    }

    private var canCheck: Bool {
        if case .create(.chordsAtLeast(let n)) = task.mode { return chordCount >= n }
        return chordCount > 0
    }

    private func check() {
        if isCreate {
            lastScore = 1
            let offbeats = cells.enumerated().filter { $0.element != nil && $0.offset % 4 != 0 }.count
            let msg = offbeats * 2 >= chordCount
                ? "Stabs that dodge the kick push the groove forward. Very house."
                : "Chords on the beat feel solid and anthemic. Try a few offbeats next time."
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
                                        message: r.accuracy >= 0.999 ? "Right chords, right time."
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
                feedback = StepFeedback(kind: .retry, title: Cheer.near(r.accuracy),
                                        message: retryMessage(r.marks, reveal), score: isRecreate ? r.accuracy : nil)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }

    private func retryMessage(_ m: [Int: CellMark], _ reveal: Bool) -> String {
        let wrong = m.values.filter { $0 == .extra }.count
        let missed = m.values.filter { $0 == .missed }.count
        var parts: [String] = []
        if wrong > 0 { parts.append("\(wrong) in red \(wrong == 1 ? "is" : "are") the wrong chord or in the wrong place") }
        if missed > 0 { parts.append(reveal ? "\(missed) missing (dashed)" : "\(missed) still missing") }
        let summary = parts.isEmpty ? "" : parts.joined(separator: ", ") + ". "
        return summary + (isRecreate ? "Replay the reference and compare." : task.hint)
    }
}

/// One row of 16 chord cells. Tap to place the current brush chord, tap again to remove, drag to paint.
struct ChordLaneRow: View {
    @Binding var cells: [Int?]
    let names: [String]
    let brush: Int
    let playhead: Int
    let marks: [Int: CellMark]
    var onPlace: (Int) -> Void

    @State private var painting = false
    @State private var paintValue: Int?
    @State private var lastIndex = -1

    var body: some View {
        GeometryReader { geo in
            let m = GridMetrics(width: geo.size.width)
            ZStack(alignment: .topLeading) {
                ForEach(0..<16, id: \.self) { i in
                    ChordCell(name: cells[i].map { names[$0] }, isBeat: i % 4 == 0,
                              isPlayhead: i == playhead, mark: marks[i])
                        .frame(width: m.cell, height: geo.size.height)
                        .offset(x: m.x(i))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let i = min(15, max(0, m.index(at: g.location.x)))
                        if !painting {
                            painting = true
                            paintValue = cells[i] == brush ? nil : brush
                        }
                        guard i != lastIndex else { return }
                        lastIndex = i
                        apply(paintValue, at: i)
                    }
                    .onEnded { g in
                        // A quick tap in a ScrollView can skip onChanged.
                        if lastIndex == -1 {
                            let i = min(15, max(0, m.index(at: g.location.x)))
                            apply(cells[i] == brush ? nil : brush, at: i)
                        }
                        painting = false
                        paintValue = nil
                        lastIndex = -1
                    }
            )
        }
        .frame(height: 64)
    }

    private func apply(_ value: Int?, at i: Int) {
        guard cells[i] != value else { return }
        cells[i] = value
        Haptics.tap()
        if let value { onPlace(value) }
    }
}

struct ChordCell: View {
    let name: String?
    let isBeat: Bool
    let isPlayhead: Bool
    let mark: CellMark?

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 9, style: .continuous)
        let fill: Color = mark == .extra ? Theme.miss : (mark == .correct ? Theme.success : Theme.brand)
        let lip: Color = mark == .extra ? Theme.missLip : (mark == .correct ? Theme.successLip : Theme.brandLip)
        ZStack {
            if let name {
                shape.fill(lip).offset(y: 4)
                shape.fill(fill).brightness(isPlayhead ? 0.12 : 0)
                Text(name)
                    .font(.label(11, weight: .black))
                    .foregroundStyle(Theme.onBrand)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .rotationEffect(.degrees(-90))
                    .fixedSize()
            } else {
                shape.fill(isPlayhead ? Theme.brandSoft : (isBeat ? Theme.surfaceRaised : Theme.surface))
                shape.strokeBorder(isPlayhead ? Theme.brandBorder : Theme.stroke, lineWidth: Theme.border)
            }
            if mark == .missed {
                shape.fill(Theme.successSoft)
                shape.strokeBorder(Theme.successLip, style: StrokeStyle(lineWidth: 2.5, dash: [5, 3]))
            }
        }
        .padding(.bottom, 4)
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: name)
    }
}
