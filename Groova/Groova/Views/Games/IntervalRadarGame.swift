//
//  IntervalRadarGame.swift
//  Groova
//
//  F2.3 Interval Radar. A sonar screen with a sweeping beam. The gold centre dot is the first
//  note; drag the second dot round and out, and the two pings play the distance between them.
//  Clockwise is up, counter-clockwise is down, and further out is a bigger jump.
//

import Foundation
import QuartzCore
import SwiftUI

/// "Same note", "Whole step", "5th" and so on.
nonisolated func intervalName(_ d: Int) -> String {
    let a = abs(d)
    let names = [0: "Same note", 1: "Half step", 2: "Whole step", 3: "Minor 3rd", 4: "Major 3rd", 5: "4th",
                 7: "5th", 9: "6th", 12: "Octave"]
    let n = names[a] ?? "\(a) semitones"
    return d == 0 ? n : n + (d > 0 ? " up" : " down")
}

struct IntervalRadarGame: View {
    let task: GameTask
    let rounds: [RadarRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }
    private enum Zone: String, CaseIterable { case same = "SAME", near = "NEAR", far = "FAR" }

    @State private var game: GameProgress
    @State private var phase: Phase = .ready
    @State private var distance = 0
    @State private var reach = 0.0        // 0...1 radius for zone rounds
    @State private var maxReached = 0
    @State private var part = 0
    @State private var mistakes = 0
    @State private var locked: [Int] = []
    @State private var ping = 0.0
    @State private var signature = 7
    @State private var motif: [Int] = []
    @State private var pingTask: Task<Void, Never>?
    @Environment(\.accent) private var accent

    private let patch = SynthPatch.keys

    init(task: GameTask, rounds: [RadarRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: RadarRound { rounds[min(game.index, rounds.count - 1)] }

    /// The note the current distance is measured from.
    private var from: Int {
        switch round.mode {
        case .chain, .motif, .reply: return round.root + locked.reduce(0, +)
        default: return round.root
        }
    }

    /// The distances the dial can land on.
    private var allowed: [Int] {
        switch round.mode {
        case .grow: return Array(0...12)
        case .match(_, let c, _): return c
        case .pick(let c): return c
        default: return Array(-12...12)
        }
    }

    private var signed: Bool {
        switch round.mode {
        case .match(_, _, let d): return d
        case .grow, .zones, .pick: return false
        default: return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 360) { stage }
                    if phase == .playing { controls }
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: primaryTitle,
                       primaryEnabled: primaryEnabled,
                       onPrimary: primary,
                       onContinue: next,
                       onRetry: retry,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onDisappear { pingTask?.cancel() }
    }

    private var primaryTitle: String {
        guard phase == .playing else { return "Switch on the radar" }
        switch round.mode {
        case .grow: return maxReached >= 7 ? "I can hear it grow" : "Pull further out"
        case .zones: return "Drop the dot in a zone"
        case .pick: return "Make it my jump"
        case .motif, .reply: return part == 0 ? "Lock the first jump" : "Lock the second jump"
        case .chain: return "Lock this jump"
        case .match: return "Check"
        }
    }

    private var primaryEnabled: Bool {
        guard phase == .playing else { return phase == .ready }
        switch round.mode {
        case .grow: return maxReached >= 7
        case .zones: return false
        default: return true
        }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { t in
            let sweep = t.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3) / 3 * 360
            GeometryReader { geo in
                let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2 + 10)
                let r = min(geo.size.width, geo.size.height) / 2 - 34
                radar(c: c, r: r, sweep: sweep)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { v in drag(v.location, c: c, r: r) }
                        .onEnded { _ in dropped() })
            }
        }
    }

    private func dotPoint(c: CGPoint, r: CGFloat) -> CGPoint {
        if case .zones = round.mode {
            return CGPoint(x: c.x, y: c.y - r * CGFloat(reach))
        }
        let a = Double(distance) * 30 - 90
        let rad = distance == 0 ? 0 : r * CGFloat(0.3 + Double(min(12, abs(distance))) / 12 * 0.7)
        return CGPoint(x: c.x + rad * CGFloat(cos(a * .pi / 180)), y: c.y + rad * CGFloat(sin(a * .pi / 180)))
    }

    private func radar(c: CGPoint, r: CGFloat, sweep: Double) -> some View {
        let p = dotPoint(c: c, r: r)
        let isZones: Bool = { if case .zones = round.mode { return true }; return false }()
        return ZStack {
            // Rings and spokes.
            ForEach(1...3, id: \.self) { i in
                Circle().stroke(GameStyle.nightLine, lineWidth: 1.5)
                    .frame(width: r * 2 * CGFloat(i) / 3, height: r * 2 * CGFloat(i) / 3).position(c)
            }
            if isZones {
                ForEach(Array(Zone.allCases.enumerated()), id: \.offset) { i, z in
                    Text(z.rawValue).font(.label(11, weight: .black)).tracking(1)
                        .foregroundStyle(zone(reach) == z && phase == .playing ? Theme.gold : GameStyle.nightDim)
                        .position(x: c.x + 34, y: c.y - r * CGFloat([0.08, 0.5, 0.88][i]))
                }
            } else {
                ForEach(0..<12, id: \.self) { i in
                    let a = Double(i) * 30 - 90
                    Text(i == 0 ? "0" : "\(i)")
                        .font(.mono(10))
                        .foregroundStyle(GameStyle.nightDim.opacity(allowed.contains(i) || allowed.contains(i - 12) ? 1 : 0.3))
                        .position(x: c.x + (r + 16) * CGFloat(cos(a * .pi / 180)), y: c.y + (r + 16) * CGFloat(sin(a * .pi / 180)))
                }
            }
            // Sweeping beam.
            Path { path in
                path.move(to: c)
                path.addArc(center: c, radius: r, startAngle: .degrees(sweep - 30), endAngle: .degrees(sweep), clockwise: false)
                path.closeSubpath()
            }
            .fill(LinearGradient(colors: [Theme.success.opacity(0), Theme.success.opacity(0.22)], startPoint: .leading, endPoint: .trailing))
            // The link between the pings.
            Path { path in path.move(to: c); path.addLine(to: p) }
                .stroke(accent.opacity(0.6), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 6]))
            // Centre ping.
            Circle().fill(Theme.gold).frame(width: 26, height: 26).shadow(color: Theme.gold, radius: 10).position(c)
            Circle().stroke(Theme.gold.opacity(ping), lineWidth: 3)
                .frame(width: 26 + (1 - ping) * 60, height: 26 + (1 - ping) * 60).position(c)
            // Second ping, the one you move.
            Circle().fill(accent).frame(width: 34, height: 34)
                .overlay(Circle().strokeBorder(GameStyle.ink.opacity(0.8), lineWidth: 2))
                .shadow(color: accent, radius: 12)
                .position(p)
            Circle().stroke(accent.opacity(ping), lineWidth: 3)
                .frame(width: 34 + (1 - ping) * 70, height: 34 + (1 - ping) * 70).position(p)
            VStack {
                HStack {
                    StageTag(text: phase == .playing ? readout : task.name, color: phase == .playing ? accent : GameStyle.nightDim)
                    Spacer()
                    if case .zones(let pairs) = round.mode, phase == .playing {
                        StageTag(text: "Pair \(min(part + 1, pairs.count)) of \(pairs.count)")
                    }
                    if case .chain(let d) = round.mode, phase == .playing {
                        StageTag(text: "Jump \(min(part + 1, d.count)) of \(d.count)")
                    }
                }
                Spacer()
            }
            .padding(14)
        }
    }

    private var readout: String {
        if case .zones = round.mode { return zone(reach).rawValue }
        if case .match = round.mode { return "\(abs(distance)) apart" }
        return intervalName(distance)
    }

    private func zone(_ r: Double) -> Zone { r < 0.2 ? .same : r < 0.62 ? .near : .far }

    // MARK: Controls

    @ViewBuilder private var controls: some View {
        switch round.mode {
        case .pick(let c):
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(c, id: \.self) { d in
                    Button {
                        set(d)
                    } label: {
                        Text(intervalName(d).replacingOccurrences(of: " up", with: "")).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: distance == d ? accent : Theme.surfaceHigh,
                                                   textColor: distance == d ? Theme.onBrand : Theme.text, height: 52))
                }
            }
        case .match, .chain, .zones:
            HStack(spacing: 10) {
                Button { playReference() } label: { Label("Hear the target", systemImage: "ear").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.gold, textColor: Theme.text, height: 52))
                if !isZones { stepButtons }
            }
        default:
            stepButtons
        }
    }

    private var isZones: Bool { if case .zones = round.mode { return true }; return false }

    private var stepButtons: some View {
        HStack(spacing: 8) {
            Button { nudge(-1) } label: { Image(systemName: "minus").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
            Button { nudge(1) } label: { Image(systemName: "plus").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
        }
    }

    // MARK: Touch and sound

    private func drag(_ loc: CGPoint, c: CGPoint, r: CGFloat) {
        guard phase == .playing else { return }
        let dx = Double(loc.x - c.x), dy = Double(loc.y - c.y)
        let dist = sqrt(dx * dx + dy * dy) / Double(r)
        if isZones {
            let old = zone(reach)
            reach = max(0, min(1, dist))
            if zone(reach) != old { Haptics.select() }
            return
        }
        if dist < 0.22 { set(nearestAllowed(0)); return }
        var a = atan2(dy, dx) * 180 / .pi + 90     // 0 at the top, clockwise
        if a < 0 { a += 360 }
        var d = Int((a / 30).rounded()) % 12
        if signed, d > 6 { d -= 12 }               // left half is down
        if d == 0, dist > 0.85 { d = 12 }           // far out at the top is an octave
        set(nearestAllowed(d))
    }

    private func nearestAllowed(_ d: Int) -> Int {
        allowed.min { abs($0 - d) < abs($1 - d) } ?? d
    }

    private func nudge(_ by: Int) {
        let sorted = allowed.sorted()
        guard let i = sorted.firstIndex(of: distance) ?? sorted.firstIndex(where: { $0 >= distance }) else { return }
        let j = max(0, min(sorted.count - 1, i + by))
        set(sorted[j])
    }

    private func set(_ d: Int) {
        guard d != distance || phase != .playing else { return }
        Haptics.select()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { distance = d }
        maxReached = max(maxReached, abs(d))
        pings(from, from + d)
        if game.feedback?.kind == .retry { withAnimation { game.feedback = nil } }
    }

    private func pings(_ notes: Int...) { pingNotes(notes) }

    private func pingNotes(_ notes: [Int], gap: Double = 0.32) {
        pingTask?.cancel()
        pingTask = Task {
            for n in notes {
                if Task.isCancelled { return }
                guard n > 0 else {
                    try? await Task.sleep(for: .milliseconds(Int(gap * 1000)))
                    continue
                }
                AudioEngine.shared.playNote(n, seconds: gap * 0.9, patch: patch)
                withAnimation(.easeOut(duration: 0.03)) { ping = 1 }
                withAnimation(.easeOut(duration: 0.4).delay(0.03)) { ping = 0 }
                try? await Task.sleep(for: .milliseconds(Int(gap * 1000)))
            }
        }
    }

    private func dropped() {
        guard phase == .playing, case .zones(let pairs) = round.mode, part < pairs.count else { return }
        let d = pairs[part]
        let want: Zone = d == 0 ? .same : abs(d) <= 2 ? .near : .far
        if zone(reach) == want {
            Haptics.success()
            part += 1
            if part == pairs.count {
                finish(max(0.5, 1 - Double(mistakes) * 0.15), "Same, near and far: you can hear distance now.")
            } else {
                withAnimation { reach = 0.5 }
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    playReference()
                }
            }
        } else {
            mistakes += 1
            Haptics.warning()
            AudioEngine.shared.playNudge()
            playReference()
        }
    }

    private func playReference() {
        switch round.mode {
        case .zones(let pairs):
            let d = pairs[min(part, pairs.count - 1)]
            pingNotes([round.root, round.root + d])
        case .match(let t, _, _):
            pingNotes([round.root, round.root + t])
        case .chain(let ds):
            var notes = [round.root]
            for d in ds { notes.append(notes.last! + d) }
            pingNotes(notes, gap: 0.45)
        default: break
        }
    }

    // MARK: Flow

    private func primary() {
        if phase != .playing { start(); return }
        switch round.mode {
        case .grow:
            finish(1, "Same note, a step, then wider leaps. Each distance has its own sound.")
        case .match(let t, _, _):
            if distance == t {
                finish(max(0.5, 1 - Double(mistakes) * 0.2), "\(intervalName(t)). Your pings match the target.")
            } else {
                mistakes += 1
                game.miss(abs(distance) == abs(t) ? "Right size, wrong direction." :
                            (abs(distance) < abs(t) ? "Too close. The target jumps further." : "Too far. The target is a smaller jump."),
                          score: 0.4)
                playReference()
            }
        case .chain(let ds):
            if distance == ds[part] {
                Haptics.success()
                locked.append(distance)
                part += 1
                if part == ds.count {
                    finish(max(0.5, 1 - Double(mistakes) * 0.15), "Both jumps locked. Hear them as one phrase.")
                    var notes = [round.root]
                    for d in ds { notes.append(notes.last! + d) }
                    pingNotes(notes, gap: 0.45)
                } else {
                    withAnimation { distance = 0 }
                }
            } else {
                mistakes += 1
                game.miss("Not that jump. Hear the target and listen to just the next two notes.", score: 0.4)
            }
        case .pick:
            signature = distance
            finish(1, "\(intervalName(distance)) is your signature jump.", title: "Your jump")
            pingNotes([round.root, round.root + distance, round.root], gap: 0.4)
        case .motif, .reply:
            locked.append(distance)
            part += 1
            if part < 2 {
                let start = round.mode == .reply ? (motif.count > 1 ? motif[1] : 0) : 0
                withAnimation { distance = start }
                pingNotes([from, from + start])
                return
            }
            let mine = locked
            if mine.allSatisfy({ $0 == 0 }) {
                game.miss("Three of the same note. Give your motif at least one jump.")
                resetParts()
            } else if round.mode == .reply, mine == motif {
                game.miss("That's the same motif. Change one of the jumps to answer it.")
                resetParts()
            } else {
                let notes = [round.root, round.root + mine[0], round.root + mine[0] + mine[1]]
                if round.mode == .motif {
                    motif = mine
                    finish(1, "Your motif: \(notes.map { noteName($0) }.joined(separator: " → ")).", title: "Your motif")
                    pingNotes(notes, gap: 0.42)
                } else {
                    let a = [round.root, round.root + motif[0], round.root + motif[0] + motif[1]]
                    finish(1, "Question, then answer. Same opening, a new jump to finish.", title: "Question and answer")
                    pingNotes(a + [0] + notes, gap: 0.42)
                }
            }
        case .zones: break
        }
    }

    private func resetParts() {
        locked = []
        part = 0
        distance = round.mode == .reply ? (motif.first ?? signature) : signature
    }

    private func start() {
        part = 0
        mistakes = 0
        locked = []
        maxReached = 0
        reach = 0.5
        switch round.mode {
        case .motif, .reply: distance = round.mode == .reply ? (motif.first ?? signature) : signature
        case .pick(let c): distance = c.first ?? 0
        case .match(_, let c, _): distance = c.first ?? 0
        default: distance = 0
        }
        withAnimation { phase = .playing }
        switch round.mode {
        case .zones, .match, .chain: playReference()
        default: pingNotes([from, from + distance])
        }
    }

    private func finish(_ score: Double, _ msg: String, title: String? = nil) {
        withAnimation { phase = .done }
        game.pass(score, msg, title: title)
    }

    private func retry() {
        withAnimation { game.feedback = nil }
        if phase == .done { phase = .ready }
    }

    private func next() {
        pingTask?.cancel()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            distance = 0
        }
    }
}
