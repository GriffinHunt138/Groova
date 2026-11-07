//
//  ControlRoomGame.swift
//  Groova
//
//  F0.3 Change the Feeling. A silent 12-second scene, someone walking to a door, scored live
//  with three big controls: HARMONY, MOVEMENT and COLOR. The melody never changes. The scene
//  itself reacts to the score, so you see the mood you hear.
//

import Foundation
import QuartzCore
import SwiftUI

struct ControlRoomGame: View {
    let task: GameTask
    let score: ControlRoomScore
    let rounds: [ControlRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, replay, done }
    private struct Edit { var pos: Double; var lever: Int; var value: Int }

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    /// Harmony, movement, color: 0 or 1 each.
    @State private var levers = [0, 0, 0]
    @State private var touched: Set<Int> = []
    @State private var swaps = 0
    @State private var pair = 0
    @State private var spotMisses = 0
    @State private var spotRight = 0
    @State private var revealLever: Int?
    @State private var edits: [Edit] = []
    @State private var cuePos: Double?
    @State private var replayIndex = 0
    @State private var playedPair = false
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }
    private let filmSteps = 64.0  // four bars
    private let doorStep = 32.0   // the door opens at bar 3

    init(task: GameTask, score: ControlRoomScore, rounds: [ControlRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.score = score
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: ControlRound { rounds[min(game.index, rounds.count - 1)] }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 230) { film }
                    controls
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
        .onAppear(perform: setUp)
        .onChange(of: game.index) { _, _ in setUp() }
        .onChange(of: transport.step) { _, s in
            guard phase == .playing || phase == .replay else { return }
            clock.follow(s)
            if phase == .replay { applyReplay() }
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running { ended() }
        }
        .onDisappear { transport.stop() }
    }

    // MARK: Round setup

    private func setUp() {
        touched = []
        swaps = 0
        pair = 0
        spotMisses = 0
        spotRight = 0
        playedPair = false
        revealLever = nil
        edits = []
        cuePos = nil
        phase = .ready
        switch round.mode {
        case .swap(let a, _): levers = a
        case .explore: levers = [0, 0, 0]
        case .spot(let pairs): levers = pairs.first?.0 ?? [0, 0, 0]
        case .brief(_, let start, _): levers = start
        case .cue(let start, _): levers = start
        case .perform(let start): levers = start
        }
    }

    private var unlocked: Set<Int> {
        switch round.mode {
        case .swap, .spot: return []
        case .explore, .perform: return [0, 1, 2]
        case .brief(_, _, let u): return Set(u)
        case .cue(_, let lever): return [lever]
        }
    }

    // MARK: Sound

    private func compose(_ l: [Int]) -> Pattern {
        let bed = score.movement[l[1]].merged(with: score.harmony[l[0]])
        return K.melody(score.melody, over: bed)
    }

    private func kit(_ l: [Int]) -> DrumKit {
        var k = transport.kit(for: genre)
        SoundParam.chordCutoff.apply(score.color[l[2]], to: &k)
        return k
    }

    private func play(_ l: [Int], source: PlaySource = .user, bars: Int? = 4) {
        clock.reset(bpm: score.bpm)
        transport.play(compose(l), genre: genre, source: source, bars: bars, swing: 0, bpm: score.bpm, kit: kit(l))
    }

    private func push(_ l: [Int]) {
        transport.liveUpdate(compose(l))
        AudioEngine.shared.update(kit: kit(l))
    }

    // MARK: Film

    /// 0...1 through the scene.
    private func filmPos() -> Double {
        guard let s = clock.now() else { return 0 }
        return (s.truncatingRemainder(dividingBy: filmSteps)) / filmSteps
    }

    private var film: some View {
        TimelineView(.animation(paused: !(phase == .playing || phase == .replay))) { _ in
            let p = (phase == .playing || phase == .replay) ? filmPos() : (phase == .done ? 1 : 0)
            scene(p)
        }
    }

    private func scene(_ p: Double) -> some View {
        let minor = levers[0] == 1
        let busy = levers[1] == 1
        let bright = levers[2] == 1
        let light = minor ? Color(hex: 0x4A2EC0) : Theme.brand
        let open = max(0, min(1, (p - 0.5) / 0.12))
        let walk = min(1, p / 0.5)
        let bob = sin(p * .pi * (busy ? 64 : 32)) * (busy ? 5 : 2.5)
        return GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let floorY = h * 0.78
            let doorX = w * 0.74
            ZStack(alignment: .topLeading) {
                // Sky.
                LinearGradient(colors: [minor ? Color(hex: 0xE4DEFF) : Theme.brandSoft,
                                        GameStyle.night], startPoint: .top, endPoint: .bottom)
                    .opacity(bright ? 1 : 0.75)
                // Floor.
                Rectangle().fill(GameStyle.nightRaised).frame(height: h - floorY).offset(y: floorY)
                // The door and the light behind it.
                RoundedRectangle(cornerRadius: 6)
                    .fill(light.opacity(0.25 + 0.75 * open))
                    .frame(width: 54, height: 96)
                    .shadow(color: light.opacity(open), radius: 30 * open + (bright ? 8 : 0))
                    .offset(x: doorX, y: floorY - 96)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.surfaceHigh)
                    .frame(width: 54 * (1 - open * 0.85), height: 96)
                    .offset(x: doorX, y: floorY - 96)
                // Light spilling on the floor.
                Ellipse()
                    .fill(light.opacity(0.45 * open))
                    .frame(width: 160 * open + 1, height: 24)
                    .blur(radius: 8)
                    .offset(x: doorX - 50, y: floorY - 6)
                // The person.
                VStack(spacing: 2) {
                    Circle().fill(GameStyle.ink.opacity(0.9)).frame(width: 16, height: 16)
                    Capsule().fill(GameStyle.ink.opacity(0.85)).frame(width: 12, height: 34)
                }
                .offset(x: w * 0.08 + (doorX - 30 - w * 0.08) * walk, y: floorY - 52 + bob)
                // The playhead along the bottom.
                Capsule().fill(GameStyle.nightLine).frame(width: w - 32, height: 6).offset(x: 16, y: h - 16)
                Capsule().fill(accent).frame(width: max(6, (w - 32) * p), height: 6).offset(x: 16, y: h - 16)
                Circle().fill(GameStyle.ink).frame(width: 10, height: 10).offset(x: 16 + (w - 32) * 0.5 - 5, y: h - 18)
                if let c = cuePos {
                    Capsule().fill(Theme.gold).frame(width: 4, height: 16).offset(x: 16 + (w - 32) * c - 2, y: h - 21)
                }
                HStack {
                    StageTag(text: sceneTag)
                    Spacer()
                    StageTag(text: "Melody locked", color: GameStyle.nightDim)
                }
                .padding(12)
            }
        }
    }

    private var sceneTag: String {
        switch phase {
        case .ready: return "Scene 1 · The door"
        case .replay: return "Your cut"
        case .done: return "Cut"
        case .playing:
            if case .spot = round.mode { return transport.section == 0 ? "Clip A" : "Clip B" }
            return "Rolling"
        }
    }

    // MARK: Controls

    @ViewBuilder private var controls: some View {
        if case .swap = round.mode {
            HStack(spacing: 12) {
                swapButton("Score A", 0)
                swapButton("Score B", 1)
            }
        } else {
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { i in dial(i) }
            }
        }
        if case .spot(let pairs) = round.mode {
            Text("Pair \(min(pair + 1, pairs.count)) of \(pairs.count). Play it, then tap the control that changed.")
                .font(.label(14, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        if case .brief = round.mode {
            Button("Hear the reference") {
                Haptics.tap()
                if case .brief(let target, _, _) = round.mode { play(target, source: .reference, bars: 2); phase = .playing }
            }
            .buttonStyle(GhostButtonStyle(height: 46, textColor: accent))
        }
    }

    private func swapButton(_ title: String, _ i: Int) -> some View {
        let isOn: Bool = {
            if case .swap(let a, let b) = round.mode { return levers == (i == 0 ? a : b) }
            return false
        }()
        return Button(title) {
            guard case .swap(let a, let b) = round.mode else { return }
            Haptics.select()
            levers = i == 0 ? a : b
            swaps += 1
            push(levers)
        }
        .buttonStyle(ChunkyButtonStyle(color: isOn ? accent : Theme.surfaceHigh, textColor: isOn ? Theme.onBrand : Theme.text, height: 64))
    }

    private static let leverNames = ["HARMONY", "MOVEMENT", "COLOR"]
    private static let leverSymbols = ["pianokeys", "figure.run", "paintpalette.fill"]

    private func dial(_ i: Int) -> some View {
        let isSpot: Bool = { if case .spot = round.mode { return true }; return false }()
        let canTurn = unlocked.contains(i)
        let active = canTurn || isSpot
        let on = levers[i] == 1
        let highlight = revealLever == i
        return Button {
            tapDial(i)
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(Theme.surfaceRaised)
                    Circle().strokeBorder(highlight ? Theme.gold : (active ? accent : Theme.stroke), lineWidth: 4)
                    // The pointer swings between the two positions.
                    Capsule()
                        .fill(active ? accent : Theme.textTertiary)
                        .frame(width: 6, height: 26)
                        .offset(y: -14)
                        .rotationEffect(.degrees(on ? 50 : -50))
                        .animation(.spring(response: 0.35, dampingFraction: 0.55), value: on)
                    Image(systemName: canTurn || isSpot ? Self.leverSymbols[i] : "lock.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(active ? accent : Theme.textTertiary)
                        .offset(y: 14)
                }
                .frame(width: 86, height: 86)
                Text(Self.leverNames[i]).font(.label(12, weight: .black)).tracking(0.6).foregroundStyle(Theme.text)
                Text(score.names[i][levers[i]]).font(.label(13, weight: .bold)).foregroundStyle(Theme.textSecondary)
                    .contentTransition(.opacity)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(highlight ? Theme.gold.opacity(0.15) : Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Theme.stroke, lineWidth: Theme.border))
        }
        .buttonStyle(PressScaleStyle())
        .opacity(active ? 1 : 0.55)
        .accessibilityLabel("\(Self.leverNames[i].capitalized), \(score.names[i][levers[i]])")
    }

    private func tapDial(_ i: Int) {
        if case .spot(let pairs) = round.mode {
            guard playedPair else { Haptics.warning(); return }
            let answer = pairs[min(pair, pairs.count - 1)].1
            if i == answer {
                Haptics.success()
                withAnimation { revealLever = i }
                spotRight += 1
                Task { try? await Task.sleep(for: .milliseconds(700)); nextPair(pairs) }
            } else {
                Haptics.warning()
                AudioEngine.shared.playNudge()
                spotMisses += 1
            }
            return
        }
        guard unlocked.contains(i) else { Haptics.warning(); return }
        Haptics.thump()
        withAnimation(.spring(response: 0.3)) { levers[i] = 1 - levers[i] }
        touched.insert(i)
        if phase == .playing {
            push(levers)
            if let pos = clock.now() { edits.append(Edit(pos: pos, lever: i, value: levers[i])) }
            if case .cue = round.mode, cuePos == nil, let s = clock.now() { cuePos = min(1, s / filmSteps) }
        }
    }

    private func nextPair(_ pairs: [([Int], Int)]) {
        revealLever = nil
        playedPair = false
        transport.stop()
        phase = .ready
        if pair + 1 >= pairs.count {
            let s = Double(pairs.count) / Double(pairs.count + spotMisses)
            game.pass(s, spotMisses == 0 ? "You heard exactly which control moved, every time." :
                        "All found. Changing one thing at a time is how producers hear what each part does.")
        } else {
            pair += 1
            levers = pairs[pair].0
        }
    }

    // MARK: Buttons

    private var primaryTitle: String {
        switch round.mode {
        case .swap, .explore: return phase == .playing ? "Done" : "Roll the scene"
        case .spot: return phase == .playing ? "Listening…" : "Play the pair"
        case .brief: return "Check my score"
        case .cue: return phase == .playing ? "Rolling…" : "Roll the scene"
        case .perform: return phase == .playing ? "Rolling…" : (phase == .replay ? "Your cut…" : "Roll and score it")
        }
    }

    private var primaryEnabled: Bool {
        switch round.mode {
        case .swap: return phase != .playing || swaps >= 2
        case .explore: return phase != .playing || touched.count == 3
        case .spot, .cue, .perform: return phase == .ready
        case .brief: return true
        }
    }

    private func primary() {
        switch round.mode {
        case .swap:
            if phase == .playing { transport.stop(); game.pass(1, "Same film, same melody. Only the score changed, and the whole scene felt different.") }
            else { play(levers, bars: nil); phase = .playing }
        case .explore:
            if phase == .playing { transport.stop(); game.pass(1, "Harmony sets the mood, movement sets the energy, color sets the shine.") }
            else { play(levers, bars: nil); phase = .playing }
        case .spot(let pairs):
            let p = pairs[min(pair, pairs.count - 1)]
            var changed = p.0
            changed[p.1] = 1 - changed[p.1]
            levers = p.0
            clock.reset(bpm: score.bpm)
            transport.play(compose(p.0), genre: genre, source: .compare, bars: 4, swing: 0, bpm: score.bpm,
                           kit: kit(p.0), sequence: [compose(p.0), compose(changed)], barsPerSection: 2)
            phase = .playing
            playedPair = true
        case .brief(let target, _, let u):
            transport.stop()
            let ok = u.allSatisfy { levers[$0] == target[$0] }
            if ok { game.pass(1, "That matches the brief. You changed only what the scene needed.") }
            else { game.miss("Not quite. Hear the reference again and listen to one control at a time.") }
        case .cue, .perform:
            edits = []
            cuePos = nil
            play(levers, bars: 4)
            phase = .playing
        }
    }

    private func ended() {
        switch phase {
        case .playing:
            phase = .ready
            if case .cue = round.mode { judgeCue() }
            if case .perform = round.mode { startReplay() }
            if case .spot = round.mode { levers = changedLevers() }
        case .replay:
            phase = .done
            game.pass(1, "That's your 12-second score. Same melody, your story.", title: "Your cut")
        default: break
        }
    }

    private func changedLevers() -> [Int] {
        guard case .spot(let pairs) = round.mode else { return levers }
        let p = pairs[min(pair, pairs.count - 1)]
        var l = p.0
        l[p.1] = 1 - l[p.1]
        return l
    }

    private func judgeCue() {
        guard let c = cuePos else {
            game.miss("Make your change as the door opens. Watch the white dot on the timeline.")
            return
        }
        let errBeats = abs(c * filmSteps - doorStep) / 4
        let s = max(0, 1 - errBeats / 2)
        if errBeats <= 1 {
            game.pass(s, errBeats < 0.35 ? "Right on the cut. The music turned as the door opened." : "Close to the cut. Within a beat of the door.")
        } else {
            game.miss(c * filmSteps < doorStep ? "Too early. Wait for the door, then turn it." : "Too late. Turn it the moment the door opens.",
                      score: s)
        }
    }

    private var performStart: [Int] {
        if case .perform(let s) = round.mode { return s }
        return [0, 0, 0]
    }

    private func startReplay() {
        let changed = Set(edits.filter { $0.pos >= 2 }.map(\.lever))
        guard changed.count >= 2 else {
            game.miss("Use at least two controls while the scene rolls, so the music clearly turns.")
            levers = performStart
            return
        }
        levers = performStart
        replayIndex = 0
        play(levers, bars: 4)
        phase = .replay
    }

    private func applyReplay() {
        guard let now = clock.now() else { return }
        var changed = false
        while replayIndex < edits.count, edits[replayIndex].pos <= now {
            let e = edits[replayIndex]
            levers[e.lever] = e.value
            replayIndex += 1
            changed = true
        }
        if changed { push(levers) }
    }

    private func reset() {
        transport.stop()
        game.feedback = nil
        setUp()
    }

    private func next() {
        transport.stop()
        if game.advance() { onComplete(game.average) }
    }
}
