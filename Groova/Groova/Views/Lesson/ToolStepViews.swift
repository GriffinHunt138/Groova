//
//  ToolStepViews.swift
//  Groova
//
//  Sound Lab (shape a sound), Mixer (balance a groove) and Arrangement board (build a track).
//

import Foundation
import SwiftUI

/// Reference / Yours switch used by the matching tools.
private struct ABPicker: View {
    @Binding var reference: Bool

    var body: some View {
        Picker("Listen to", selection: $reference) {
            Text("Reference").tag(true)
            Text("Yours").tag(false)
        }
        .pickerStyle(.segmented)
    }
}

private struct GoalRow: View {
    let text: String
    let done: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(done ? Theme.success : Theme.textTertiary)
                .contentTransition(.symbolEffect(.replace))
            Text(text)
                .font(.label(15, weight: .bold))
                .foregroundStyle(done ? Theme.text : Theme.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Sound Lab

struct SoundLabStepView: View {
    let task: SoundLabTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var values: [Double]
    @State private var revealed = false
    @State private var low: [Double]
    @State private var high: [Double]
    @State private var reference = false
    @State private var paused = false
    @State private var feedback: StepFeedback?
    @State private var lastScore = 1.0
    @State private var fails = 0

    private var transport: Transport { Transport.shared }
    private var isMatch: Bool { task.target != nil }

    init(task: SoundLabTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _values = State(initialValue: task.start)
        _low = State(initialValue: task.start)
        _high = State(initialValue: task.start)
    }

    private var swept: [Bool] { zip(low, high).map { $1 - $0 >= 0.6 } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: task.body, badge: isMatch ? "Sound match" : "Sound lab")
                    HStack(spacing: 10) {
                        TransportButton(title: paused ? "Play" : "Stop", symbol: paused ? "play.fill" : "stop.fill",
                                        active: !paused, color: genre.color) { togglePlay() }
                        Spacer()
                    }
                    if isMatch { ABPicker(reference: $reference) }
                    HStack(spacing: task.params.count > 2 ? 8 : 24) {
                        ForEach(Array(task.params.enumerated()), id: \.offset) { i, p in
                            let t = revealed ? task.target?[i] : nil
                            Knob(value: binding(i), label: p.label, valueText: p.valueText(values[i]),
                                 color: genre.color, size: task.params.count > 2 ? 96 : 112,
                                 target: t, targetText: t.map { p.valueText($0) })
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(reference ? 0.45 : 1)
                    .allowsHitTesting(!reference)

                    // Always your sound, never the reference, so matching stays by ear.
                    WaveformPreview(kit: task.kit(base: genre.kit, values: values), sound: PreviewSound(task.params),
                                    dimmed: reference)

                    if isMatch {
                        Text("Switch between Reference and Yours, and turn the knobs until they sound the same. Scored on knob positions.")
                            .font(.label(13, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(task.params.enumerated()), id: \.offset) { i, p in
                                GoalRow(text: "Sweep \(p.label.lowercased()) from low to high", done: swept[i])
                            }
                        }
                        .card()
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: feedback,
                       primaryTitle: isMatch ? "Check" : "Continue",
                       primaryEnabled: isMatch || swept.allSatisfy { $0 },
                       onPrimary: check,
                       onContinue: { transport.stop(); onComplete(lastScore) },
                       onRetry: { withAnimation { feedback = nil } },
                       helpTitle: fails >= 2 ? "Show me" : nil,
                       onHelp: {
                           if let t = task.target { withAnimation { values = t; feedback = nil; revealed = true } }
                       })
        }
        .task {
            try? await Task.sleep(for: .milliseconds(450))
            transport.play(task.loop, genre: genre, source: .demo, kit: currentKit)
        }
        .onChange(of: values) { _, _ in apply() }
        .onChange(of: reference) { _, _ in apply(); Haptics.select() }
        .onDisappear { transport.stop() }
    }

    private func binding(_ i: Int) -> Binding<Double> {
        Binding(get: { values[i] }, set: { v in
            values[i] = v
            low[i] = min(low[i], v)
            high[i] = max(high[i], v)
            if feedback?.kind == .retry { withAnimation { feedback = nil } }
        })
    }

    private var currentKit: DrumKit {
        task.kit(base: genre.kit, values: reference ? (task.target ?? values) : values)
    }

    private func apply() {
        AudioEngine.shared.update(kit: currentKit)
    }

    private func togglePlay() {
        if paused {
            transport.play(task.loop, genre: genre, source: .demo, kit: currentKit)
        } else {
            transport.stop()
        }
        paused.toggle()
    }

    private func check() {
        guard let target = task.target else {
            lastScore = 1
            withAnimation {
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: "You've heard the whole range. Now you know what each knob does.", score: nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
            return
        }
        let diffs = zip(values, target).map { $0 - $1 }
        let score = diffs.map { max(0, 1 - abs($0) / 0.4) }.reduce(0, +) / Double(max(1, diffs.count))
        lastScore = score
        if score >= task.threshold {
            let answer = zip(task.params, target).map { "\($0.label) \($0.valueText($1))" }.joined(separator: ", ")
            withAnimation {
                revealed = true
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: "The reference was \(answer). Green dots show it on the knobs.",
                                        score: score)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            fails += 1
            var worst = 0
            for i in diffs.indices where abs(diffs[i]) > abs(diffs[worst]) { worst = i }
            let p = task.params[worst]
            let dir = diffs[worst] > 0 ? "too high" : "too low"
            withAnimation {
                feedback = StepFeedback(kind: .retry, title: Cheer.near(score),
                                        message: "Listen to \(p.label.lowercased()): yours is \(dir).", score: score)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }
}

// MARK: - Mixer

struct MixerStepView: View {
    let task: MixerTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var values: [Double]
    @State private var revealed = false
    @State private var reference = false
    @State private var paused = false
    @State private var feedback: StepFeedback?
    @State private var lastScore = 1.0
    @State private var fails = 0

    private var transport: Transport { Transport.shared }
    private var isMatch: Bool { task.target != nil }

    init(task: MixerTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _values = State(initialValue: task.start)
    }

    private var moved: [Bool] { zip(values, task.start).map { abs($0 - $1) >= 0.25 } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: task.body, badge: isMatch ? "Mix match" : "Mixer")
                    HStack(spacing: 10) {
                        TransportButton(title: paused ? "Play" : "Stop", symbol: paused ? "play.fill" : "stop.fill",
                                        active: !paused, color: genre.color) { togglePlay() }
                        Spacer()
                    }
                    if isMatch { ABPicker(reference: $reference) }
                    VStack(spacing: 18) {
                        ForEach(Array(task.channels.enumerated()), id: \.offset) { i, ch in
                            fader(i, ch)
                        }
                    }
                    .card()
                    .opacity(reference ? 0.45 : 1)
                    .allowsHitTesting(!reference)
                    Text(isMatch ? "Switch between Reference and Yours until the balance sounds the same."
                                 : "Move every slider and listen to how the groove changes.")
                        .font(.label(13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
            }
            StepFooter(feedback: feedback,
                       primaryTitle: isMatch ? "Check" : "Continue",
                       primaryEnabled: isMatch || moved.allSatisfy { $0 },
                       onPrimary: check,
                       onContinue: { transport.stop(); onComplete(lastScore) },
                       onRetry: { withAnimation { feedback = nil } },
                       helpTitle: fails >= 2 ? "Show me" : nil,
                       onHelp: {
                           if let t = task.target { withAnimation { values = t; feedback = nil; revealed = true } }
                       })
        }
        .task {
            try? await Task.sleep(for: .milliseconds(450))
            apply()
            transport.play(task.loop, genre: genre, source: .demo)
        }
        .onChange(of: values) { _, _ in
            apply()
            if feedback?.kind == .retry { withAnimation { feedback = nil } }
        }
        .onChange(of: reference) { _, _ in apply(); Haptics.select() }
        .onDisappear {
            transport.stop()
            AudioEngine.shared.resetEffects()
        }
    }

    private func fader(_ i: Int, _ ch: MixChannel) -> some View {
        let v = values[i]
        let target = revealed ? task.target?[i] : nil
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ch.label).font(.label(15, weight: .heavy)).foregroundStyle(Theme.text)
                if ch == .sidechain {
                    Text("sidechain").font(.label(12, weight: .bold)).foregroundStyle(Theme.textTertiary)
                }
                Spacer()
                if let target {
                    Text("Answer: \(valueText(ch, target))")
                        .font(.label(12, weight: .heavy)).foregroundStyle(Theme.successInk)
                }
                Text(valueText(ch, v)).font(.mono(13, weight: .bold)).foregroundStyle(Theme.textSecondary)
            }
            Slider(value: Binding(get: { values[i] }, set: { values[i] = $0 }), in: 0...1,
                   onEditingChanged: { editing in if !editing { Haptics.select() } })
                .tint(genre.color)
                .overlay {
                    if let target {
                        GeometryReader { geo in
                            // Slider thumbs travel inset by about half a thumb (14pt) at each end.
                            let x = 14 + (geo.size.width - 28) * target
                            Capsule()
                                .fill(Theme.success)
                                .frame(width: 5, height: 22)
                                .position(x: x, y: geo.size.height / 2)
                        }
                        .allowsHitTesting(false)
                    }
                }
        }
    }

    private func valueText(_ ch: MixChannel, _ v: Double) -> String {
        ch == .sidechain ? "\(Int(v * 100))%" : levelText(v)
    }

    private func levelText(_ v: Double) -> String {
        if v < 0.02 { return "off" }
        let db = 20 * log10(MixerTask.level(v))
        return db >= 0 ? String(format: "+%.0f dB", db) : String(format: "%.0f dB", db)
    }

    private func apply() {
        let vals = reference ? (task.target ?? values) : values
        var drums: [DrumTrack: Double] = [:]
        var bass = 1.0, chords = 1.0, side = 0.0
        for (ch, v) in zip(task.channels, vals) {
            switch ch {
            case .drum(let t): drums[t] = MixerTask.level(v)
            case .bass: bass = MixerTask.level(v)
            case .chords: chords = MixerTask.level(v)
            case .sidechain: side = v
            }
        }
        AudioEngine.shared.setMix(drums: drums, bass: bass, chords: chords, sidechain: side)
    }

    private func togglePlay() {
        if paused {
            apply()
            transport.play(task.loop, genre: genre, source: .demo)
        } else {
            transport.stop()
        }
        paused.toggle()
    }

    private func check() {
        guard let target = task.target else {
            lastScore = 1
            withAnimation {
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: "Every level changes the feel. That's mixing.", score: nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
            return
        }
        let diffs = zip(values, target).map { $0 - $1 }
        let score = diffs.map { max(0, 1 - abs($0) / 0.35) }.reduce(0, +) / Double(max(1, diffs.count))
        lastScore = score
        if score >= task.threshold {
            let answer = zip(task.channels, target).map { "\($0.label) \(valueText($0, $1))" }.joined(separator: ", ")
            withAnimation {
                revealed = true
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: "The reference was \(answer). Green marks show it on the sliders.",
                                        score: score)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            fails += 1
            var worst = 0
            for i in diffs.indices where abs(diffs[i]) > abs(diffs[worst]) { worst = i }
            let ch = task.channels[worst]
            let msg: String = ch == .sidechain
                ? (diffs[worst] > 0 ? "There's too much pump." : "It needs more pump.")
                : "The \(ch.label.lowercased()) is too \(diffs[worst] > 0 ? "loud" : "quiet")."
            withAnimation {
                feedback = StepFeedback(kind: .retry, title: Cheer.near(score), message: msg, score: score)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }
}

// MARK: - Arrangement board

struct ArrangementStepView: View {
    let task: ArrangementTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var grid: [[Bool]]
    @State private var marks: [Int: CellMark] = [:]
    @State private var feedback: StepFeedback?
    @State private var fails = 0
    @State private var lastScore = 0.0

    private var transport: Transport { Transport.shared }

    init(task: ArrangementTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        _grid = State(initialValue: task.grid(task.start))
    }

    private var isRecreate: Bool { if case .recreate = task.mode { true } else { false } }
    private var isCreate: Bool { if case .create = task.mode { true } else { false } }
    private var totalBars: Int { task.sections.count * task.barsPerSection }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: subtitle, badge: badge)
                    transportBar
                    board.card(padding: 14)
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
                           withAnimation { grid = task.grid(task.target); feedback = nil; marks = [:] }
                       })
        }
        .onChange(of: grid) { _, g in
            if transport.isPlaying(.user) { AudioEngine.shared.update(sequence: task.patterns(g)) }
            if feedback?.kind == .retry || !marks.isEmpty { withAnimation { feedback = nil; marks = [:] } }
        }
        .onDisappear { transport.stop() }
    }

    private var badge: String {
        switch task.mode {
        case .rule: "Arrange"
        case .recreate: "Listen & recreate"
        case .create: "Your turn"
        }
    }

    private var subtitle: String? {
        switch task.mode {
        case .recreate: "Listen to the reference play through, then switch parts on and off to match it."
        case .create: task.hint
        case .rule: task.hint
        }
    }

    private var transportBar: some View {
        HStack(spacing: 10) {
            if isRecreate {
                TransportButton(title: "Reference", symbol: transport.isPlaying(.reference) ? "stop.fill" : "ear.fill",
                                active: transport.isPlaying(.reference), color: Theme.text) {
                    play(task.grid(task.target), source: .reference)
                }
            }
            TransportButton(title: isRecreate ? "Yours" : "Play it through",
                            symbol: transport.isPlaying(.user) ? "stop.fill" : "play.fill",
                            active: transport.isPlaying(.user), color: genre.color) {
                play(grid, source: .user)
            }
            Spacer(minLength: 0)
        }
    }

    private func play(_ g: [[Bool]], source: PlaySource) {
        if transport.isPlaying(source) { transport.stop(); return }
        transport.play(Pattern(), genre: genre, source: source, bars: totalBars,
                       sequence: task.patterns(g), barsPerSection: task.barsPerSection)
    }

    private var board: some View {
        let playing = transport.isRunning ? transport.section : -1
        return VStack(spacing: 8) {
            HStack(spacing: 6) {
                Color.clear.frame(width: 74, height: 1)
                ForEach(Array(task.sections.enumerated()), id: \.offset) { s, name in
                    Text(name)
                        .font(.label(12, weight: .black))
                        .foregroundStyle(s == playing ? Theme.brand : Theme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                }
            }
            ForEach(Array(task.lanes.enumerated()), id: \.offset) { l, lane in
                HStack(spacing: 6) {
                    Text(lane.name)
                        .font(.label(14, weight: .heavy))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: 74, alignment: .leading)
                    ForEach(0..<task.sections.count, id: \.self) { s in
                        let idx = l * task.sections.count + s
                        ArrangeCell(on: grid[l][s], isPlaying: s == playing, mark: marks[idx])
                            .onTapGesture {
                                Haptics.tap()
                                grid[l][s].toggle()
                            }
                    }
                }
            }
        }
    }

    private var canCheck: Bool {
        if isCreate { return variedEnough }
        return grid.contains { $0.contains(true) }
    }

    private var variedEnough: Bool {
        let cols = (0..<task.sections.count).map { s in grid.map { $0[s] } }
        guard cols.allSatisfy({ $0.contains(true) }) else { return false }
        for s in 1..<max(1, cols.count) where cols[s] == cols[s - 1] { return false }
        return true
    }

    private func check() {
        if isCreate {
            lastScore = 1
            let first = grid.map { $0.first ?? false }.filter { $0 }.count
            let most = (0..<task.sections.count).map { s in grid.filter { $0[s] }.count }.max() ?? 0
            let msg = most > first
                ? "Starting small and building up gives the drop its punch. That's arrangement."
                : "Every section feels different. Try starting with fewer parts so the big moments hit harder."
            withAnimation { feedback = StepFeedback(kind: .success, title: Cheer.win(), message: msg, score: nil) }
            AudioEngine.shared.playSuccess()
            Haptics.success()
            return
        }
        let user = grid.flatMap { $0 }
        let ref = task.grid(task.target).flatMap { $0 }
        let r = Scoring.rhythm(user: user, reference: ref)
        lastScore = r.accuracy
        let threshold: Double = { if case .rule = task.mode { return 0.999 } else { return task.threshold } }()
        if r.accuracy >= threshold {
            withAnimation {
                marks = r.marks
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: r.accuracy >= 0.999 ? "Every section is spot on." : "Close. The differences are highlighted.",
                                        score: isRecreate ? r.accuracy : nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            fails += 1
            let reveal = !isRecreate || fails >= 2
            let extra = r.marks.values.filter { $0 == .extra }.count
            let missed = r.marks.values.filter { $0 == .missed }.count
            var parts: [String] = []
            if extra > 0 { parts.append("\(extra) part\(extra == 1 ? "" : "s") playing where \(extra == 1 ? "it shouldn't" : "they shouldn't") (red)") }
            if missed > 0 { parts.append(reveal ? "\(missed) missing (dashed)" : "\(missed) still missing") }
            withAnimation {
                marks = r.marks.filter { reveal || $0.value != .missed }
                feedback = StepFeedback(kind: .retry, title: Cheer.near(r.accuracy),
                                        message: parts.joined(separator: ", ") + ". " + (isRecreate ? "Listen again." : task.hint),
                                        score: isRecreate ? r.accuracy : nil)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }
}

struct ArrangeCell: View {
    let on: Bool
    let isPlaying: Bool
    let mark: CellMark?

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        let fill: Color = mark == .extra ? Theme.miss : (mark == .correct ? Theme.success : Theme.brand)
        let lip: Color = mark == .extra ? Theme.missLip : (mark == .correct ? Theme.successLip : Theme.brandLip)
        ZStack {
            if on {
                shape.fill(lip).offset(y: 4)
                shape.fill(fill).brightness(isPlaying ? 0.1 : 0)
            } else {
                shape.fill(isPlaying ? Theme.brandSoft : Theme.surfaceRaised)
                shape.strokeBorder(isPlaying ? Theme.brandBorder : Theme.stroke, lineWidth: Theme.border)
            }
            if mark == .missed {
                shape.fill(Theme.successSoft)
                shape.strokeBorder(Theme.successLip, style: StrokeStyle(lineWidth: 2.5, dash: [5, 3]))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .padding(.bottom, 4)
        .contentShape(Rectangle())
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: on)
    }
}
