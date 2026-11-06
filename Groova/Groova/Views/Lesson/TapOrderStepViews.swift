//
//  TapOrderStepViews.swift
//  Groova
//
//  Two hands-on steps. The tap pad: tap a big pad in time with the music and see how close you
//  were. The tile arranger: tap tiles into slots to build a progression, a flip or a song.
//

import Foundation
import QuartzCore
import SwiftUI

// MARK: - Tap pad

struct TapStepView: View {
    let task: TapTask
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }

    @State private var phase: Phase = .ready
    @State private var taps: [Double] = []
    @State private var startTime: Double?
    @State private var bar = 0
    @State private var down = false
    @State private var flash = false
    @State private var hits: Set<Int> = []
    @State private var feedback: StepFeedback?
    @State private var fails = 0
    @State private var lastScore = 0.0

    private var transport: Transport { Transport.shared }
    private var bpm: Double { task.bpm ?? genre.bpm }
    private var stepSeconds: Double { 60 / bpm / 4 }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: task.body, badge: "Tap along")
                    lights
                    pad
                    if phase == .done { timeline.card(padding: 14) }
                }
                .padding(20)
            }
            StepFooter(feedback: feedback,
                       primaryTitle: phase == .playing ? "Listening…" : "Start",
                       primaryEnabled: phase == .ready,
                       onPrimary: start,
                       onContinue: { transport.stop(); onComplete(lastScore) },
                       onRetry: reset)
        }
        .onChange(of: transport.step) { old, new in
            guard phase == .playing else { return }
            if startTime == nil, new >= 0 {
                startTime = CACurrentMediaTime() - Double(new) * stepSeconds
            } else if new >= 0, old >= 0, new < old {
                bar += 1
            }
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running, phase == .playing { finish() }
        }
        .onDisappear { transport.stop() }
    }

    // MARK: Parts

    private var guideOn: Bool { phase == .playing && bar < task.guideBars }

    private var lights: some View {
        let beat = transport.step >= 0 ? transport.step / 4 : -1
        return VStack(spacing: 10) {
            HStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { i in
                    let lit = guideOn && beat == i
                    Circle()
                        .fill(lit ? genre.color : Theme.surfaceHigh)
                        .frame(width: 22, height: 22)
                        .scaleEffect(lit ? 1.25 : 1)
                        .shadow(color: lit ? genre.color.opacity(0.6) : .clear, radius: 8)
                        .animation(.easeOut(duration: 0.08), value: lit)
                }
            }
            HStack(spacing: 4) {
                ForEach(0..<task.totalBars, id: \.self) { b in
                    Capsule()
                        .fill(phase == .done || (phase == .playing && b < bar) ? genre.color
                              : (phase == .playing && b == bar ? genre.color.opacity(0.45) : Theme.surfaceHigh))
                        .frame(height: 6)
                }
            }
            Text(statusLine)
                .font(.label(14, weight: .bold))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .card(padding: 16)
    }

    private var statusLine: String {
        switch phase {
        case .ready: return task.guideBars >= task.totalBars ? "The lights show the beat" : "The lights fade. Keep going on your own"
        case .playing: return guideOn ? "Bar \(bar + 1) of \(task.totalBars)" : "Lights off. Keep it going"
        case .done: return "\(hits.count) of \(task.targets.count) \(task.unit) on time"
        }
    }

    private var pad: some View {
        ZStack {
            Circle()
                .fill(Theme.brandLip)
                .offset(y: down ? 2 : 8)
            Circle()
                .fill(flash ? genre.color.opacity(0.8) : genre.color)
                .offset(y: down ? 2 : 0)
            VStack(spacing: 6) {
                Image(systemName: "hand.tap.fill").font(.system(size: 34, weight: .black))
                Text(task.padLabel).font(.display(26))
            }
            .foregroundStyle(.white)
            .offset(y: down ? 2 : 0)
        }
        .frame(width: 210, height: 218)
        .frame(maxWidth: .infinity)
        .contentShape(Circle())
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !down else { return }
                down = true
                hit()
            }
            .onEnded { _ in down = false })
        .accessibilityLabel(task.padLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { hit() }
    }

    private var timeline: some View {
        let total = Double(max(1, task.totalSteps))
        return VStack(alignment: .leading, spacing: 8) {
            Text("YOUR TIMING").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surfaceRaised).frame(height: 10)
                    ForEach(Array(task.targets.enumerated()), id: \.offset) { i, t in
                        Circle()
                            .fill(hits.contains(i) ? Theme.success : Theme.miss.opacity(0.35))
                            .frame(width: 14, height: 14)
                            .offset(x: w * Double(t) / total - 7)
                    }
                    ForEach(Array(taps.enumerated()), id: \.offset) { _, t in
                        Capsule()
                            .fill(Theme.text)
                            .frame(width: 3, height: 26)
                            .offset(x: w * min(1, max(0, t / total)) - 1.5)
                    }
                }
                .frame(height: 26)
            }
            .frame(height: 26)
            Text("Dots are where the \(task.unit) belong. Lines are your taps.")
                .font(.label(13, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: Actions

    private func hit() {
        Haptics.tap()
        if let s = task.sound { AudioEngine.shared.trigger(s, kit: transport.kit(for: genre), velocity: 0.9) }
        withAnimation(.easeOut(duration: 0.05)) { flash = true }
        withAnimation(.easeOut(duration: 0.2).delay(0.06)) { flash = false }
        guard phase == .playing, let t0 = startTime else { return }
        taps.append((CACurrentMediaTime() - t0) / stepSeconds)
    }

    private func start() {
        taps = []
        hits = []
        bar = 0
        startTime = nil
        phase = .playing
        if task.loops.count == 1 {
            transport.play(task.loops[0], genre: genre, source: .user, bars: task.totalBars,
                           swing: task.swing, bpm: task.bpm)
        } else {
            transport.play(Pattern(), genre: genre, source: .user, bars: task.totalBars, swing: task.swing,
                           bpm: task.bpm, sequence: task.loops, barsPerSection: task.barsEach)
        }
    }

    private func reset() {
        withAnimation {
            feedback = nil
            phase = .ready
            taps = []
            hits = []
        }
    }

    private func finish() {
        phase = .done
        // Match each target to the closest unused tap within tolerance.
        var used = Set<Int>()
        var matched = Set<Int>()
        for (i, target) in task.targets.enumerated() {
            var best: (Int, Double)?
            for (j, t) in taps.enumerated() where !used.contains(j) {
                let d = abs(t - Double(target))
                if d <= task.tolerance, d < (best?.1 ?? .infinity) { best = (j, d) }
            }
            if let b = best {
                used.insert(b.0)
                matched.insert(i)
            }
        }
        let extra = max(0, taps.count - used.count - max(1, task.targets.count / 8))
        let score = Double(matched.count) / Double(max(1, task.targets.count + extra))
        lastScore = score
        withAnimation { hits = matched }
        if score >= task.threshold {
            let msg = score >= 0.95 ? "Rock solid. That's real timing." : "Locked in. A couple drifted, and the timeline shows which."
            withAnimation { feedback = StepFeedback(kind: .success, title: Cheer.win(), message: msg, score: score) }
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            fails += 1
            let early = taps.isEmpty ? "" : advice()
            withAnimation {
                feedback = StepFeedback(kind: fails >= 3 ? .reveal : .retry, title: Cheer.near(score),
                                        message: taps.isEmpty ? "No taps landed. Hit the pad while the music plays." : early,
                                        score: score)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }

    /// Early, late or just too many.
    private func advice() -> String {
        var offsets: [Double] = []
        for t in taps {
            if let nearest = task.targets.min(by: { abs(Double($0) - t) < abs(Double($1) - t) }) {
                offsets.append(t - Double(nearest))
            }
        }
        let mean = offsets.reduce(0, +) / Double(max(1, offsets.count))
        if taps.count > task.targets.count * 3 / 2 { return "Too many taps. Wait for each one, then hit it once." }
        if mean < -0.4 { return "You're rushing a little. Let the sound arrive, then tap." }
        if mean > 0.4 { return "You're a touch late. Feel it coming and tap with it." }
        return "Close. Listen for the sound you're tapping and lock onto it."
    }
}

// MARK: - Tile arranger

struct OrderStepView: View {
    let task: OrderTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var slots: [Int?]
    @State private var marks: [Int: Bool] = [:]
    @State private var feedback: StepFeedback?
    @State private var fails = 0
    @State private var lastScore = 0.0

    private var transport: Transport { Transport.shared }

    init(task: OrderTask, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.genre = genre
        self.onComplete = onComplete
        var s = [Int?](repeating: nil, count: task.slots)
        for (i, v) in task.start.enumerated() where i < s.count { s[i] = v }
        _slots = State(initialValue: s)
    }

    private var isRecreate: Bool { if case .recreate = task.mode { true } else { false } }
    private var isCreate: Bool { if case .create = task.mode { true } else { false } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    StepPrompt(title: task.prompt, detail: task.hint, badge: badge)
                    transportBar
                    slotRow.card(padding: 14)
                    pool
                }
                .padding(20)
            }
            StepFooter(feedback: feedback,
                       primaryTitle: isCreate ? "Done" : "Check",
                       primaryEnabled: slots.allSatisfy { $0 != nil },
                       onPrimary: check,
                       onContinue: { transport.stop(); onComplete(lastScore) },
                       onRetry: { withAnimation { feedback = nil } },
                       helpTitle: fails >= 2 && !isCreate ? "Show me" : nil,
                       onHelp: {
                           withAnimation {
                               slots = task.answer.map { Optional($0) }
                               marks = [:]
                               feedback = nil
                           }
                       })
        }
        .onChange(of: slots) { _, s in
            if transport.isPlaying(.user) { AudioEngine.shared.update(sequence: s.map(task.pattern)) }
            if feedback?.kind == .retry || !marks.isEmpty { withAnimation { feedback = nil; marks = [:] } }
        }
        .onDisappear { transport.stop() }
    }

    private var badge: String {
        switch task.mode {
        case .rule: "Put it in order"
        case .recreate: "Listen & rebuild"
        case .create: "Your order"
        }
    }

    private var transportBar: some View {
        HStack(spacing: 10) {
            if isRecreate {
                TransportButton(title: "Reference", symbol: transport.isPlaying(.reference) ? "stop.fill" : "ear.fill",
                                active: transport.isPlaying(.reference), color: Theme.text) {
                    play(task.answer.map { Optional($0) }, source: .reference)
                }
            }
            TransportButton(title: isRecreate ? "Yours" : "Play it",
                            symbol: transport.isPlaying(.user) ? "stop.fill" : "play.fill",
                            active: transport.isPlaying(.user), color: genre.color) {
                play(slots, source: .user)
            }
            Spacer(minLength: 0)
        }
    }

    private func play(_ s: [Int?], source: PlaySource) {
        if transport.isPlaying(source) { transport.stop(); return }
        transport.play(Pattern(), genre: genre, source: source, bars: s.count * task.barsEach, swing: task.swing,
                       bpm: task.bpm, sequence: s.map(task.pattern), barsPerSection: task.barsEach)
    }

    private func preview(_ i: Int) {
        transport.play(task.pattern(i), genre: genre, source: .demo, bars: task.barsEach, swing: task.swing,
                       bpm: task.bpm)
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: min(4, max(1, task.slots)))
    }

    private var slotRow: some View {
        let playing = transport.isPlaying(.user) || transport.isPlaying(.reference) ? transport.section : -1
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<task.slots, id: \.self) { i in
                let name = i < task.slotNames.count ? task.slotNames[i] : "\(i + 1)"
                SlotTile(label: name, tile: slots[i].map { task.tiles[$0] }, playing: playing == i,
                         locked: task.locked.contains(i), mark: marks[i])
                    .onTapGesture {
                        Haptics.tap()
                        if task.locked.contains(i) {
                            if let t = slots[i] { preview(t) }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { slots[i] = nil }
                        }
                    }
            }
        }
    }

    private var pool: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TAP TO HEAR AND PLACE").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Array(task.tiles.enumerated()), id: \.offset) { i, tile in
                    Button {
                        Haptics.tap()
                        preview(i)
                        if let empty = (0..<slots.count).first(where: { slots[$0] == nil && !task.locked.contains($0) }) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { slots[empty] = i }
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Text(tile.name).font(.display(20)).lineLimit(1).minimumScaleFactor(0.6)
                            if !tile.tag.isEmpty {
                                Text(tile.tag).font(.label(12, weight: .bold)).opacity(0.85).lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: genre.color, height: 64))
                }
            }
        }
    }

    private func check() {
        if isCreate {
            if case .create(.variedSections) = task.mode {
                for i in 1..<max(1, slots.count) where slots[i].map({ task.tiles[$0].name }) == slots[i - 1].map({ task.tiles[$0].name }) {
                    fails += 1
                    withAnimation {
                        feedback = StepFeedback(kind: .retry, title: "Same twice in a row",
                                                message: "Slots \(i) and \(i + 1) are the same. Change one so the music moves.",
                                                score: nil)
                    }
                    AudioEngine.shared.playNudge()
                    return
                }
            }
            lastScore = 1
            withAnimation {
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: "That's your order. Play it back and hear the story it tells.", score: nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
            return
        }
        var m: [Int: Bool] = [:]
        for i in 0..<task.slots {
            let want = i < task.answer.count ? task.tiles[task.answer[i]].name : nil
            let got = slots[i].map { task.tiles[$0].name }
            m[i] = want == got
        }
        let right = m.values.filter { $0 }.count
        let score = Double(right) / Double(max(1, task.slots))
        lastScore = score
        let threshold = task.mode.isRule ? 0.999 : task.threshold
        if score >= threshold {
            withAnimation {
                marks = m
                feedback = StepFeedback(kind: .success, title: Cheer.win(), message: "Every tile is in the right place.",
                                        score: isRecreate ? score : nil)
            }
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            fails += 1
            withAnimation {
                marks = m
                feedback = StepFeedback(kind: .retry, title: Cheer.near(score),
                                        message: "\(task.slots - right) in the wrong place (red). " + (isRecreate ? "Play the reference again." : task.hint),
                                        score: isRecreate ? score : nil)
            }
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }
}

extension TaskMode {
    var isRule: Bool { if case .rule = self { true } else { false } }
}

private struct SlotTile: View {
    let label: String
    let tile: OrderTile?
    let playing: Bool
    let locked: Bool
    let mark: Bool?

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        let fill: Color = mark == false ? Theme.miss : (mark == true ? Theme.success : (tile == nil ? Theme.surfaceRaised : Theme.brand))
        VStack(spacing: 2) {
            Text(label.uppercased())
                .font(.label(10, weight: .black))
                .foregroundStyle(tile == nil ? Theme.textTertiary : .white.opacity(0.8))
                .lineLimit(1).minimumScaleFactor(0.6)
            Text(tile?.name ?? "+")
                .font(.display(tile == nil ? 22 : 17))
                .foregroundStyle(tile == nil ? Theme.textTertiary : .white)
                .lineLimit(1).minimumScaleFactor(0.5)
            if locked {
                Image(systemName: "lock.fill").font(.system(size: 9, weight: .black)).foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 66)
        .background(shape.fill(fill))
        .overlay(shape.strokeBorder(playing ? Theme.gold : (tile == nil ? Theme.stroke : .clear),
                                    style: StrokeStyle(lineWidth: playing ? 3 : 2, dash: tile == nil && !playing ? [5, 4] : [])))
        .scaleEffect(playing ? 1.05 : 1)
        .animation(.easeOut(duration: 0.12), value: playing)
    }
}
