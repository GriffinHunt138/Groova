//
//  ChordLockGame.swift
//  Groova
//
//  F3.1 Chord Lock. Three glowing tone beams make one harmonic lock. Lift and lower each beam
//  with your finger; the chord re-sounds every time you move. When the three line up with the
//  hidden chord, the lock ring closes and the full chord rings out.
//

import Foundation
import SwiftUI

struct ChordLockGame: View {
    let task: GameTask
    let rounds: [LockRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }

    static let low = 48, high = 84

    @State private var game: GameProgress
    @State private var phase: Phase = .ready
    @State private var beams: [Int] = [60, 64, 67]
    @State private var shown = 3
    @State private var movable: [Bool] = [true, true, true]
    @State private var picking = false
    @State private var link = 0
    @State private var unlocked: [[Int]] = []
    @State private var opened = 0.0
    @State private var dragStart: [Int: Int] = [:]
    @State private var root = 60
    @State private var minor = false
    @State private var voicingA: [Int] = []
    @State private var voicingB: [Int] = []
    @State private var pulse: Task<Void, Never>?
    @Environment(\.accent) private var accent

    private let patch = SynthPatch.keys
    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [LockRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: LockRound { rounds[min(game.index, rounds.count - 1)] }

    /// What the beams must make right now, if anything.
    private var target: [Int]? {
        switch round.mode {
        case .reveal(let t): return t.pitches
        case .build(let t, _, _): return t.pitches
        case .wrongBeam(let t, _, _): return t.pitches
        case .chain(let ts, _): return ts[min(link, ts.count - 1)].pitches
        case .voicing: return Triad(root: root, minor: minor).pitches
        default: return nil
        }
    }

    private var ghost: Bool { if case .build(_, _, let g) = round.mode { return g }; return false }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if round.mode == .voicing, phase != .done { rootPicker }
                    GameStage(height: 380) { stage }
                    if phase == .playing { controls }
                    if phase == .done, round.mode == .alternate, game.feedback == nil { keepButtons }
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
        .onDisappear {
            pulse?.cancel()
            transport.stop()
        }
    }

    private var primaryTitle: String {
        switch phase {
        case .ready: return round.mode == .alternate ? "Play both shapes" : "Open the lock"
        case .done: return "Unlocked"
        case .playing:
            if case .reveal = round.mode { return shown < 3 ? "Reveal two more beams" : "That's a chord" }
            if round.mode == .revoice { return "Check the shape" }
            return "Line them up"
        }
    }

    private var primaryEnabled: Bool {
        if phase == .ready { return true }
        guard phase == .playing else { return false }
        if case .reveal = round.mode { return true }
        return round.mode == .revoice
    }

    // MARK: Stage

    private var stage: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let top: CGFloat = 60, bottom = h - 30
            let yOf: (Int) -> CGFloat = { p in bottom - (bottom - top) * CGFloat(p - Self.low) / CGFloat(Self.high - Self.low) }
            let colW = w / 3
            let isLocked = matched
            ZStack(alignment: .topLeading) {
                // The lock ring behind the beams.
                Circle()
                    .trim(from: 0, to: 0.15 + opened * 0.85)
                    .stroke(isLocked ? Theme.gold : GameStyle.nightLine, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: min(w, h) * 0.7, height: min(w, h) * 0.7)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: isLocked ? Theme.gold : .clear, radius: 16)
                    .position(x: w / 2, y: h / 2 + 10)
                // Octave guide lines.
                ForEach([48, 60, 72, 84], id: \.self) { p in
                    Rectangle().fill(Color.white.opacity(0.06)).frame(width: w - 20, height: 1).position(x: w / 2, y: yOf(p))
                    Text("C\(p / 12 - 1)").font(.mono(9)).foregroundStyle(GameStyle.nightDim).position(x: 16, y: yOf(p) - 8)
                }
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { i in
                        ZStack {
                            if i < shown {
                                beam(i, x: colW / 2, y: yOf(beams[i]), bottom: bottom, color: beamColor(i))
                            }
                            if ghost, let t = target, i < shown {
                                Capsule().strokeBorder(Color.white.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                                    .frame(width: colW * 0.62, height: 18)
                                    .position(x: colW / 2, y: yOf(t[i]))
                            }
                        }
                        .frame(width: colW, height: h)
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { v in drag(i, dy: v.translation.height, span: (bottom - top)) }
                            .onEnded { v in
                                dragStart[i] = nil
                                if abs(v.translation.height) < 6 { tapBeam(i) }
                            })
                        .accessibilityLabel("Beam \(i + 1), \(noteName(beams[i], octave: true))")
                        .accessibilityAdjustableAction { dir in
                            if dir == .increment { move(i, 1) } else if dir == .decrement { move(i, -1) }
                        }
                    }
                }
                HStack {
                    StageTag(text: tag, color: isLocked ? Theme.gold : (phase == .playing ? accent : GameStyle.nightDim))
                    Spacer()
                    if case .chain(let ts, _) = round.mode, phase == .playing {
                        StageTag(text: "Lock \(min(link + 1, ts.count)) of \(ts.count)")
                    }
                }
                .padding(14)
            }
        }
    }

    private var tag: String {
        switch phase {
        case .ready: return task.name
        case .done: return "Unlocked"
        case .playing:
            if picking { return "Tap the wrong beam" }
            if matched { return "Locked in" }
            return "Calibrating"
        }
    }

    private func beamColor(_ i: Int) -> Color { [GameStyle.kick, GameStyle.hat, GameStyle.lead][i] }

    private func beam(_ i: Int, x: CGFloat, y: CGFloat, bottom: CGFloat, color: Color) -> some View {
        let can = movable[i] && phase == .playing && !picking
        return ZStack {
            // The light column.
            Rectangle()
                .fill(LinearGradient(colors: [color.opacity(0.0), color.opacity(0.55)], startPoint: .bottom, endPoint: .top))
                .frame(width: 26, height: max(0, bottom - y))
                .position(x: x, y: (y + bottom) / 2)
            // The head you drag.
            Capsule()
                .fill(color)
                .frame(width: 82, height: 34)
                .overlay(Text(noteName(beams[i], octave: true)).font(.label(13, weight: .black)).foregroundStyle(.white))
                .overlay(Capsule().strokeBorder(Color.white.opacity(can ? 0.9 : 0.25), lineWidth: can ? 3 : 1.5))
                .shadow(color: color, radius: matched ? 18 : 8)
                .position(x: x, y: y)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: y)
            if !movable[i], phase == .playing {
                Image(systemName: "lock.fill").font(.system(size: 11, weight: .black)).foregroundStyle(GameStyle.nightDim)
                    .position(x: x + 50, y: y)
            }
        }
    }

    private var matched: Bool {
        guard phase != .ready, let t = target else { return false }
        if ghost { return beams == t }
        return Set(beams.map { $0 % 12 }) == Set(t.map { $0 % 12 }) && Set(beams.map { $0 % 12 }).count == 3
    }

    // MARK: Controls

    @ViewBuilder private var controls: some View {
        HStack(spacing: 8) {
            ForEach(0..<shown, id: \.self) { i in
                VStack(spacing: 6) {
                    Button { move(i, 1) } label: { Image(systemName: "chevron.up").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 42, enabled: movable[i] && !picking))
                    Button { move(i, -1) } label: { Image(systemName: "chevron.down").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 42, enabled: movable[i] && !picking))
                }
                .disabled(!movable[i] || picking)
            }
        }
        if hasReference {
            Button { strike(target ?? beams, seconds: 1.4) } label: {
                Label("Hear the target chord", systemImage: "ear").frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: Theme.gold, textColor: Theme.text, height: 52))
        }
    }

    private var hasReference: Bool {
        switch round.mode {
        case .wrongBeam, .chain: return true
        case .build(_, _, let g): return !g
        default: return false
        }
    }

    private var rootPicker: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach([60, 65, 57], id: \.self) { r in
                    Button { root = r; Haptics.select() } label: { Text(noteName(r)).frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: root == r ? accent : Theme.surfaceHigh,
                                                       textColor: root == r ? Theme.onBrand : Theme.text, height: 48))
                }
            }
            HStack(spacing: 8) {
                ForEach([false, true], id: \.self) { m in
                    Button { minor = m; Haptics.select() } label: { Text(m ? "Minor" : "Major").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: minor == m ? accent : Theme.surfaceHigh,
                                                       textColor: minor == m ? Theme.onBrand : Theme.text, height: 48))
                }
            }
        }
    }

    private var keepButtons: some View {
        HStack(spacing: 10) {
            Button { keep(voicingA, "first") } label: { Text("Keep shape A").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 52))
            Button { keep(voicingB, "second") } label: { Text("Keep shape B").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 52))
        }
    }

    // MARK: Touch and sound

    private func strike(_ p: [Int], seconds: Double = 0.7) {
        AudioEngine.shared.playChord(p, seconds: seconds, patch: patch)
    }

    private func drag(_ i: Int, dy: CGFloat, span: CGFloat) {
        guard movable[i], phase == .playing, !picking else { return }
        if dragStart[i] == nil { dragStart[i] = beams[i] }
        let per = span / CGFloat(Self.high - Self.low)
        let p = max(Self.low, min(Self.high, (dragStart[i] ?? beams[i]) - Int((dy / per).rounded())))
        if p != beams[i] { set(i, p) }
    }

    private func move(_ i: Int, _ by: Int) {
        set(i, max(Self.low, min(Self.high, beams[i] + by)))
    }

    private func set(_ i: Int, _ p: Int) {
        Haptics.select()
        beams[i] = p
        strike(Array(beams.prefix(shown)))
        if game.feedback?.kind == .retry { withAnimation { game.feedback = nil } }
        checkLock()
    }

    private func tapBeam(_ i: Int) {
        guard phase == .playing else { return }
        if picking, case .wrongBeam(_, let wrong, _) = round.mode {
            if i == wrong {
                Haptics.success()
                picking = false
                movable = (0..<3).map { $0 == wrong }
            } else {
                game.miss("That beam is fine. Hear the target again and listen for the one that rubs.")
            }
            return
        }
        AudioEngine.shared.playNote(beams[i], seconds: 0.6, patch: patch)
    }

    private func checkLock() {
        guard matched, phase == .playing else { return }
        Haptics.success()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { opened = 1 }
        strike(beams, seconds: 1.6)
        switch round.mode {
        case .build(let t, _, _):
            finish("\(t.name): root, third and fifth, sounding as one.")
        case .wrongBeam(let t, _, _):
            finish("Fixed. One note out of place was enough to change the whole \(t.name) chord.")
        case .chain(let ts, let missing):
            unlocked.append(beams)
            if link + 1 < ts.count {
                Task {
                    try? await Task.sleep(for: .milliseconds(700))
                    link += 1
                    withAnimation { opened = 0 }
                    load(ts[link], missing: missing[min(link, missing.count - 1)])
                }
            } else {
                finish("All three locks open. Hear them as a progression.")
                playProgression(unlocked)
            }
        case .voicing:
            voicingA = beams
            finish("\(Triad(root: root, minor: minor).name) built from its root, third and fifth.", title: "Your chord")
        default: break
        }
    }

    private func load(_ t: Triad, missing: Int) {
        var b = t.pitches
        b[missing] = t.root
        beams = b
        movable = (0..<3).map { $0 == missing }
        strike(b)
    }

    private func playProgression(_ chords: [[Int]]) {
        pulse?.cancel()
        pulse = Task {
            for c in chords {
                if Task.isCancelled { return }
                strike(c, seconds: 1.1)
                try? await Task.sleep(for: .milliseconds(1200))
            }
        }
    }

    // MARK: Flow

    private func primary() {
        if phase == .ready { start(); return }
        switch round.mode {
        case .reveal(let t):
            if shown < 3 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { shown = 3; opened = 1 }
                beams = t.pitches
                strike(beams, seconds: 1.6)
            } else {
                finish("One note is a pitch. Three together make a chord.")
            }
        case .revoice:
            let same = Set(beams.map { $0 % 12 }) == Set(voicingA.map { $0 % 12 })
            let moved = zip(beams, voicingA).filter { $0 != $1 }
            if !same {
                game.miss("Those aren't the same three notes any more. Move a beam a whole octave, 12 steps, so it keeps its name.")
            } else if moved.isEmpty {
                game.miss("That's the same shape. Move one beam up or down an octave.")
            } else {
                voicingB = beams
                withAnimation { opened = 1 }
                finish("Same chord, new shape. That's a voicing.", title: "Two voicings")
                playProgression([voicingA, voicingB])
            }
        default: break
        }
    }

    private func start() {
        opened = 0
        link = 0
        unlocked = []
        picking = false
        shown = 3
        movable = [true, true, true]
        switch round.mode {
        case .reveal(let t):
            shown = 1
            beams = t.pitches
            movable = [false, false, false]
            AudioEngine.shared.playNote(t.root, seconds: 1, patch: patch)
        case .build(let t, let locked, _):
            beams = (0..<3).map { locked[$0] ? t.pitches[$0] : t.root }
            movable = locked.map { !$0 }
        case .wrongBeam(let t, let wrong, let by):
            var b = t.pitches
            b[wrong] += by
            beams = b
            picking = true
            movable = [false, false, false]
            strike(b)
        case .chain(let ts, let missing):
            load(ts[0], missing: missing.first ?? 1)
        case .voicing:
            beams = [root, root, root]
        case .revoice:
            beams = voicingA.isEmpty ? Triad.c.pitches : voicingA
        case .alternate:
            let a = voicingA.isEmpty ? Triad.c.pitches : voicingA
            let b = voicingB.isEmpty ? [a[1], a[2], a[0] + 12] : voicingB
            voicingA = a
            voicingB = b
            transport.play(Pattern(kick: [0, 8], hat: [4, 12], chords: [ChordEvent(step: 0, pitches: a, length: 7),
                                                                         ChordEvent(step: 8, pitches: b, length: 7)]),
                           genre: genre, source: .reference, bars: nil, swing: 0, bpm: 84)
            withAnimation { phase = .done }
            return
        }
        withAnimation { phase = .playing }
        if case .build = round.mode { strike(beams) }
        if case .voicing = round.mode { strike(beams) }
    }

    private func keep(_ v: [Int], _ which: String) {
        Haptics.success()
        transport.stop()
        strike(v, seconds: 1.6)
        game.pass(1, "You kept the \(which) shape: \(v.map { noteName($0, octave: true) }.joined(separator: " ")).", title: "Saved")
    }

    private func finish(_ msg: String, title: String? = nil) {
        withAnimation { phase = .done }
        game.pass(1, msg, title: title)
    }

    private func retry() {
        withAnimation { game.feedback = nil }
        if phase == .done { phase = .ready }
    }

    private func next() {
        pulse?.cancel()
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            opened = 0
        }
    }
}
