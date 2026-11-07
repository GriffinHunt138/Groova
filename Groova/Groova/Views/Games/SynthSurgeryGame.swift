//
//  SynthSurgeryGame.swift
//  Groova
//
//  F4.2 Synth Surgery. The sound is a living waveform sculpture. Drag its front edge to change
//  the attack, drag the end of its tail to change the release, and pull the dark veil down over
//  it to filter out brightness. The loop plays the whole time, so every move is heard.
//

import Foundation
import QuartzCore
import SwiftUI

struct SynthSurgeryGame: View {
    let task: GameTask
    let rounds: [SurgeryRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let roles = ["Pluck", "Pad", "Lead"]
    static let rolePresets = [SculptShape(attack: 0.02, release: 0.1, filter: 0.65),
                              SculptShape(attack: 0.75, release: 0.85, filter: 0.35),
                              SculptShape(attack: 0.06, release: 0.45, filter: 0.85)]

    @State private var game: GameProgress
    @State private var shape = SculptShape()
    @State private var grab: SurgeryTool?
    @State private var ranges: [SurgeryTool: ClosedRange<Double>] = [:]
    @State private var playing = false
    @State private var hearingTarget = false
    @State private var role: Int?
    @State private var versionA: SculptShape?
    @State private var versionB: SculptShape?
    @State private var ab: Int?
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [SurgeryRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: SurgeryRound { rounds[min(game.index, rounds.count - 1)] }

    /// The tools this round lets you use.
    private var tools: Set<SurgeryTool> {
        switch round.mode {
        case .explore(let t): return [t]
        case .match(_, _, let t, _): return t
        case .role, .inTrack: return []
        case .design: return Set(SurgeryTool.allCases)
        }
    }

    private var target: SculptShape? {
        if case .match(let t, _, _, _) = round.mode { return t }
        return nil
    }

    static func patch(_ s: SculptShape) -> SynthPatch {
        SynthPatch(saw: 0.7, square: 0.1, sine: 0.35, detuneCents: 8, cutoff: Float(150 * pow(2, s.filter * 5.5)),
                   envAmount: 300, filterDecay: 0.2, resonance: 0.15, attack: Float(0.002 + s.attack * s.attack * 0.8),
                   decay: Float(0.08 + s.release * 1.2), sustain: Float(0.15 + 0.5 * s.release),
                   release: Float(0.03 + s.release), gain: 0.3)
    }

    private var loop: Pattern {
        switch round.mode {
        case .explore(.attack): return K.melody(K.tune([(0, 60, 7), (8, 67, 7)]))
        case .explore(.release): return K.melody(K.tune([(0, 60, 1), (4, 64, 1), (8, 67, 1), (12, 72, 1)]))
        case .inTrack: return K.melody(K.tune([(0, 72, 2), (2, 69, 2), (4, 67, 4), (8, 64, 2), (10, 67, 2), (12, 69, 3)]),
                                       over: FKit.beatBass)
        default: return K.melody(K.tune([(0, 60, 3), (4, 64, 3), (8, 67, 3), (12, 72, 3)]))
        }
    }

    private var sounding: SculptShape {
        if hearingTarget, let target { return target }
        if case .inTrack = round.mode { return (ab == 1 ? versionB : versionA) ?? shape }
        return shape
    }

    private var kit: DrumKit {
        var k = transport.kit(for: genre)
        k.chords = Self.patch(sounding)
        return k
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if case .role = round.mode { rolePicker }
                    GameStage(height: 300) { stage }
                    below
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
        .onAppear(perform: setup)
        .onChange(of: shape) { _, _ in if playing { AudioEngine.shared.update(kit: kit) } }
        .onChange(of: hearingTarget) { _, _ in if playing { AudioEngine.shared.update(kit: kit) } }
        .onChange(of: ab) { _, _ in if playing { AudioEngine.shared.update(kit: kit) } }
        .onDisappear { transport.stop() }
    }

    // MARK: Stage

    private var stage: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack(alignment: .topLeading) {
                sculpture(sounding, size: geo.size, color: hearingTarget ? Theme.gold : accent)
                if let target, showsTarget, !hearingTarget {
                    Self.outline(target, size: geo.size)
                        .stroke(Theme.gold.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
                // The veil: everything under it loses brightness.
                let veil = h * CGFloat(1 - sounding.filter)
                Rectangle()
                    .fill(LinearGradient(colors: [Theme.background.opacity(0.9), Theme.background.opacity(0.55)], startPoint: .top, endPoint: .bottom))
                    .frame(width: w, height: veil)
                if tools.contains(.filter) {
                    handle("FILTER", color: GameStyle.chords, horizontal: true)
                        .position(x: w / 2, y: max(16, veil))
                }
                if tools.contains(.attack) {
                    handle("ATTACK", color: GameStyle.snare, horizontal: false)
                        .position(x: w * CGFloat(Self.attackX(sounding)), y: h / 2)
                }
                if tools.contains(.release) {
                    handle("TAIL", color: Theme.gold, horizontal: false)
                        .position(x: w * CGFloat(Self.tailX(sounding)), y: h / 2)
                }
                StageTag(text: tag, color: playing ? accent : GameStyle.nightDim).padding(14)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { d in drag(d, size: geo.size) }
                .onEnded { _ in grab = nil; Haptics.soft() })
        }
    }

    private var showsTarget: Bool {
        if case .match(_, _, _, let show) = round.mode { return show }
        return false
    }

    private var tag: String {
        if hearingTarget { return "Target" }
        switch round.mode {
        case .explore(.attack): return "Drag the front edge"
        case .explore(.release): return "Drag the tail"
        case .explore(.filter): return "Pull the veil"
        case .inTrack: return ab == 1 ? "Version B" : "Version A"
        case .design(let second): return second ? "Version B" : "Version A"
        default: return playing ? "Live" : task.name
        }
    }

    static func attackX(_ s: SculptShape) -> Double { 0.04 + 0.36 * s.attack }
    static func tailX(_ s: SculptShape) -> Double { max(attackX(s) + 0.1, 0.34 + 0.62 * s.release) }

    static func amp(_ x: Double, _ s: SculptShape) -> Double {
        let xa = attackX(s), xr = tailX(s)
        if x < xa { return pow(max(0, x / xa), 0.7) }
        if x < xr {
            let u = (x - xa) / (xr - xa)
            return pow(1 - u, 1.8 - s.release * 1.2)
        }
        return 0
    }

    static func outline(_ s: SculptShape, size: CGSize) -> Path {
        var p = Path()
        let mid = size.height / 2, top = size.height * 0.42
        p.move(to: CGPoint(x: 0, y: mid))
        for i in 0...80 {
            let x = Double(i) / 80
            p.addLine(to: CGPoint(x: size.width * CGFloat(x), y: mid - top * CGFloat(amp(x, s))))
        }
        for i in (0...80).reversed() {
            let x = Double(i) / 80
            p.addLine(to: CGPoint(x: size.width * CGFloat(x), y: mid + top * CGFloat(amp(x, s))))
        }
        p.closeSubpath()
        return p
    }

    /// The waveform: an envelope silhouette whose edge gets jagged as the filter opens.
    private func sculpture(_ s: SculptShape, size: CGSize, color: Color) -> some View {
        TimelineView(.animation(paused: !playing)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            Canvas { c, sz in
                let mid = sz.height / 2, top = sz.height * 0.42
                let f = s.filter
                var x: CGFloat = 0
                while x < sz.width {
                    let xn = Double(x / sz.width)
                    let a = Self.amp(xn, s)
                    if a > 0.01 {
                        let k = xn * .pi * 2
                        let wave = sin(k * 14 + t * 3) + f * 0.6 * sin(k * 42 - t * 5) + f * 0.35 * sin(k * 77 + t * 7)
                        let edge = 0.6 + 0.4 * abs(wave) / (1 + 0.95 * f)
                        let hgt = top * CGFloat(a * edge)
                        var line = Path()
                        line.move(to: CGPoint(x: x, y: mid - hgt))
                        line.addLine(to: CGPoint(x: x, y: mid + hgt))
                        c.stroke(line, with: .color(color.opacity(0.35 + 0.6 * a)), lineWidth: 2)
                    }
                    x += 4
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func handle(_ label: String, color: Color, horizontal: Bool) -> some View {
        VStack(spacing: 4) {
            if horizontal {
                Capsule().fill(color).frame(width: 90, height: 8).shadow(color: color, radius: 8)
            } else {
                Capsule().fill(color).frame(width: 8, height: 120).shadow(color: color, radius: 8)
            }
            Text(label).font(.label(10, weight: .black)).tracking(1).foregroundStyle(color)
        }
    }

    private func drag(_ d: DragGesture.Value, size: CGSize) {
        guard !tools.isEmpty, !hearingTarget else { return }
        let x = Double(d.location.x / size.width), y = Double(d.location.y / size.height)
        if grab == nil {
            let sx = Double(d.startLocation.x / size.width)
            if tools.contains(.attack), abs(sx - Self.attackX(shape)) < 0.1 { grab = .attack }
            else if tools.contains(.release), abs(sx - Self.tailX(shape)) < 0.1 { grab = .release }
            else if tools.contains(.filter) { grab = .filter }
            else { grab = tools.count == 1 ? tools.first : nil }
            Haptics.tap()
        }
        guard let grab else { return }
        var s = shape
        switch grab {
        case .attack: s.attack = min(1, max(0, (x - 0.04) / 0.36))
        case .release: s.release = min(1, max(0, (x - 0.34) / 0.62))
        case .filter: s.filter = min(1, max(0, 1 - y))
        }
        shape = s
        let v = grab == .attack ? s.attack : grab == .release ? s.release : s.filter
        let r = ranges[grab] ?? v...v
        ranges[grab] = min(r.lowerBound, v)...max(r.upperBound, v)
        if !playing { startLoop() }
    }

    // MARK: Below

    private var rolePicker: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                ChoiceTile(title: Self.roles[i], symbol: ["guitars.fill", "cloud.fill", "music.mic"][i],
                           color: [GameStyle.lead, GameStyle.chords, GameStyle.snare][i], selected: role == i) {
                    role = i
                    shape = Self.rolePresets[i]
                    Haptics.select()
                    if !playing { startLoop() }
                }
            }
        }
    }

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .match:
            Button { hearingTarget.toggle(); if !playing { startLoop() } } label: {
                Label(hearingTarget ? "Back to mine" : "Hear the target", systemImage: hearingTarget ? "arrow.uturn.left" : "ear")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: hearingTarget ? Theme.gold : Theme.surfaceHigh, textColor: Theme.text, height: 52))
        case .inTrack:
            VStack(spacing: 10) {
                ABSwitch(a: "Hear A", b: "Hear B", current: playing ? ab : nil) { i in
                    ab = i
                    if !playing { startLoop() }
                }
                if game.feedback == nil {
                    HStack(spacing: 10) {
                        Button { keep(0) } label: { Text("Keep A").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: accent, height: 50))
                        Button { keep(1) } label: { Text("Keep B").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: accent, height: 50))
                    }
                }
            }
        default:
            if playing {
                Button { transport.stop(); playing = false } label: {
                    Label("Stop the loop", systemImage: "stop.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 48))
            }
        }
    }

    // MARK: Flow

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        ranges = [:]
        hearingTarget = false
        switch round.mode {
        case .explore(let t):
            shape = SculptShape(attack: t == .attack ? 0 : 0.05, release: t == .release ? 0.9 : 0.3, filter: t == .filter ? 1 : 0.8)
        case .match(_, let start, _, _):
            shape = start
        case .design(let second):
            shape = second ? (versionA ?? Self.rolePresets[role ?? 0]) : Self.rolePresets[role ?? 0]
        case .inTrack:
            ab = 0
        case .role:
            break
        }
    }

    private func startLoop() {
        transport.play(loop, genre: genre, source: .user, bpm: 96, kit: kit)
        playing = true
    }

    private var primaryTitle: String {
        switch round.mode {
        case .explore: return playing ? "I hear it" : "Start the sound"
        case .match: return "Check"
        case .role: return role.map { "Design a \(Self.roles[$0].lowercased())" } ?? "Pick a role"
        case .design(let second): return second ? "Save version B" : "Save version A"
        case .inTrack: return "Pick one above"
        }
    }

    private var primaryEnabled: Bool {
        switch round.mode {
        case .explore(let t):
            guard playing else { return true }
            return (ranges[t].map { $0.upperBound - $0.lowerBound } ?? 0) >= 0.5
        case .match: return !hearingTarget
        case .role: return role != nil
        case .design: return true
        case .inTrack: return false
        }
    }

    private func primary() {
        switch round.mode {
        case .explore(let t):
            if !playing { startLoop(); return }
            let lines: [SurgeryTool: String] = [
                .attack: "A sharp front edge snaps. A wide one swells in like a pad. Same note, new arrival.",
                .release: "A short tail is staccato and tight. A long one lets each note hang into the next.",
                .filter: "The veil takes away the bright edge. Same notes, darker colour.",
            ]
            game.pass(1, lines[t] ?? "")
        case .match(let target, _, let tools, _):
            let d = shape.distance(target, tools: tools)
            if d < 0.16 {
                game.pass(max(0.6, 1 - d * 2), "Your sound lines up with the target.")
            } else {
                game.miss(hint(target, tools: tools), score: max(0, 1 - d * 2))
            }
        case .role:
            game.pass(1, "A \(Self.roles[role ?? 0].lowercased()) it is. Now shape your own.")
        case .design(let second):
            if second {
                guard let a = versionA, shape.distance(a, tools: Set(SurgeryTool.allCases)) >= 0.25 else {
                    game.miss("Version B sounds almost the same as A. Move at least one edge a long way.")
                    return
                }
                versionB = shape
                game.pass(1, "Two versions of your instrument, same notes. Next you'll hear both in a track.")
            } else {
                versionA = shape
                game.pass(1, "Version A saved. Now make a contrasting B.")
            }
        case .inTrack:
            break
        }
    }

    private func keep(_ i: Int) {
        let s = (i == 0 ? versionA : versionB) ?? shape
        GoldShelf.save(GoldShelf.synth, [s.attack, s.release, s.filter])
        transport.stop()
        playing = false
        game.pass(1, "Saved version \(i == 0 ? "A" : "B") as your instrument. It'll be waiting in your mini-track.")
    }

    private func hint(_ t: SculptShape, tools: Set<SurgeryTool>) -> String {
        var worst: (SurgeryTool, Double) = (.attack, 0)
        for tool in tools {
            let d: Double
            switch tool {
            case .attack: d = shape.attack - t.attack
            case .release: d = shape.release - t.release
            case .filter: d = shape.filter - t.filter
            }
            if abs(d) > abs(worst.1) { worst = (tool, d) }
        }
        switch worst.0 {
        case .attack: return worst.1 > 0 ? "Your sound arrives too slowly. Sharpen the front edge." : "The target swells in more gently than yours."
        case .release: return worst.1 > 0 ? "Your notes ring on too long. Trim the tail." : "The target's notes hang on longer. Stretch the tail."
        case .filter: return worst.1 > 0 ? "Yours is brighter than the target. Pull the veil down." : "The target is brighter. Lift the veil."
        }
    }

    private func retry() {
        withAnimation { game.feedback = nil }
    }

    private func next() {
        if game.advance() {
            transport.stop()
            onComplete(game.average)
            return
        }
        transport.stop()
        playing = false
        setup()
    }
}
