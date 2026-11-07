//
//  AcousticArchitectGame.swift
//  Groova
//
//  F4.3 Acoustic Architect. A top-down floor plan of rooms. Drag the sound source into a room and
//  it plays in that space: ripples spread to the walls and fade as slowly as the room rings. The
//  echo tunnel sends discrete repeats down a corridor instead of a wash.
//

import Foundation
import QuartzCore
import SwiftUI

struct AcousticArchitectGame: View {
    let task: GameTask
    let rounds: [ArchitectRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private struct Room: Equatable {
        var name: String
        var rect: CGRect
        var space: ReverbSpace?
        var tunnel = false
    }

    static let sources = ["Clap", "Synth stab", "Piano", "Percussion"]

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var pos = CGPoint(x: 0.5, y: 0.9)
    @State private var visited: Set<String> = []
    @State private var hits: [Double] = []
    @State private var playing = false
    @State private var source = 0
    @State private var echoSteps = 4
    @State private var hearingRef = false
    @State private var selectedCard: Int?
    @State private var assigned: [Int: Int] = [:]
    @State private var cardPlayed: [Int: Double] = [:]
    @State private var choice: Int?
    @State private var recording = false
    @State private var recorded: [Double] = []
    @State private var echoThrow = false
    @State private var journey: [Double] = []
    @State private var ab: Int?
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }
    private var engine: AudioEngine { AudioEngine.shared }

    init(task: GameTask, rounds: [ArchitectRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: ArchitectRound { rounds[min(game.index, rounds.count - 1)] }

    // MARK: Layout

    private static let dryZone = Room(name: "Open air", rect: CGRect(x: 0.04, y: 0.82, width: 0.92, height: 0.14), space: nil)
    private static let mic = CGPoint(x: 0.14, y: 0.45)

    private var rooms: [Room] {
        switch round.mode {
        case .rooms(let spaces):
            let n = CGFloat(max(1, spaces.count))
            return spaces.enumerated().map { i, s in
                let slot = 0.92 / n
                let hgt = min(0.66, 0.3 + 0.36 * CGFloat(s.seconds / 4))
                let wid = slot - 0.04 - (0.3 - hgt / 2.2) * slot * 0.6
                return Room(name: s.name, rect: CGRect(x: 0.04 + slot * CGFloat(i) + (slot - wid) / 2, y: 0.42 - hgt / 2 + 0.06,
                                                       width: wid, height: hgt), space: s)
            } + [Self.dryZone]
        case .tunnel:
            return [Room(name: "Hall", rect: CGRect(x: 0.04, y: 0.14, width: 0.42, height: 0.6), space: .hall),
                    Room(name: "Echo tunnel", rect: CGRect(x: 0.5, y: 0.36, width: 0.46, height: 0.16), space: nil, tunnel: true),
                    Self.dryZone]
        case .identify(let clips):
            let spaces = Array(Set(clips.compactMap { $0 })).sorted { $0.rawValue < $1.rawValue }
            let n = CGFloat(max(1, spaces.count))
            return spaces.enumerated().map { i, s in
                let slot = 0.92 / n
                let hgt = min(0.6, 0.28 + 0.34 * CGFloat(s.seconds / 4))
                return Room(name: s.name, rect: CGRect(x: 0.04 + slot * CGFloat(i) + 0.01, y: 0.44 - hgt / 2,
                                                       width: slot - 0.02, height: hgt), space: s)
            } + [Room(name: "Dry", rect: Self.dryZone.rect, space: nil)]
        case .echoTime:
            let len = 0.12 + 0.1 * CGFloat(echoSteps)
            return [Room(name: "Echo tunnel", rect: CGRect(x: 0.06, y: 0.36, width: min(0.9, len), height: 0.18), space: nil, tunnel: true)]
        case .wetFix, .journey, .reveal:
            return [Room(name: "Hall", rect: CGRect(x: 0.04, y: 0.08, width: 0.92, height: 0.84), space: .hall)]
        case .outlier, .chooseSource:
            return []
        }
    }

    private var currentRoom: Room? {
        let p = pos
        return rooms.first { $0.rect.contains(p) }
    }

    /// How wet the source sounds where it stands.
    private var wet: Double {
        switch round.mode {
        case .wetFix, .journey:
            let d = hypot(Double(pos.x - Self.mic.x), Double(pos.y - Self.mic.y))
            return min(1, max(0, d / 0.82))
        case .echoTime:
            return 0
        default:
            guard let s = currentRoom?.space else { return 0 }
            return [0.3, 0.38, 0.45, 0.55][s.rawValue]
        }
    }

    private var sourceSteps: [Int] {
        switch round.mode {
        case .journey, .reveal: return [0, 4, 8, 12]
        case .echoTime: return [0]
        default: return [4, 12]
        }
    }

    private var echoOn: Bool {
        if hearingRef { return true }
        switch round.mode {
        case .tunnel: return currentRoom?.tunnel == true
        case .echoTime: return true
        default: return false
        }
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    stageArea
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
        .onChange(of: transport.step) { _, s in
            guard playing else { return }
            clock.follow(s)
            onStep(s)
        }
        .onChange(of: pos) { _, _ in applySpace() }
        .onDisappear {
            transport.stop()
            engine.resetEffects()
        }
    }

    @ViewBuilder private var stageArea: some View {
        switch round.mode {
        case .outlier(let spaces): GameStage(height: 250) { clipCards(spaces.map { Optional($0) }, pick: true) }
        case .chooseSource: GameStage(height: 250) { sourcePicker }
        default: GameStage(height: 320) { plan }
        }
    }

    // MARK: Floor plan

    private var plan: some View {
        TimelineView(.animation(paused: !playing && cardPlayed.isEmpty)) { _ in
            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                let now = CACurrentMediaTime()
                ZStack(alignment: .topLeading) {
                    ForEach(Array(rooms.enumerated()), id: \.offset) { i, room in
                        roomView(room, index: i, size: geo.size, now: now)
                    }
                    if case .wetFix = round.mode { micView.position(x: w * Self.mic.x, y: h * Self.mic.y) }
                    if case .journey = round.mode { micView.position(x: w * Self.mic.x, y: h * Self.mic.y) }
                    if showsSource {
                        sourcePuck.position(x: w * pos.x, y: h * pos.y)
                    }
                    if case .echoTime = round.mode, let r = rooms.first {
                        Capsule().fill(Theme.gold).frame(width: 10, height: h * r.rect.height + 16)
                            .shadow(color: Theme.gold, radius: 8)
                            .position(x: w * r.rect.maxX, y: h * r.rect.midY)
                        Text("DRAG THE END").font(.label(10, weight: .black)).foregroundStyle(Theme.gold)
                            .position(x: min(w - 50, w * r.rect.maxX), y: h * r.rect.maxY + 22)
                    }
                    StageTag(text: tag, color: playing ? accent : GameStyle.nightDim).padding(14)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { d in drag(d, size: geo.size) }
                    .onEnded { d in dragEnd(d, size: geo.size) })
            }
        }
    }

    private var showsSource: Bool {
        switch round.mode {
        case .identify, .echoTime, .reveal: return false
        default: return true
        }
    }

    private func roomView(_ room: Room, index: Int, size: CGSize, now: Double) -> some View {
        let r = CGRect(x: room.rect.minX * size.width, y: room.rect.minY * size.height,
                       width: room.rect.width * size.width, height: room.rect.height * size.height)
        let here = currentRoom == room && showsSource
        let tail = room.space?.seconds ?? 0.15
        let color: Color = room.tunnel ? Theme.gold : room.space == nil ? GameStyle.nightDim : GameStyle.chords
        return ZStack {
            RoundedRectangle(cornerRadius: room.space == nil && !room.tunnel ? 12 : 18)
                .fill(color.opacity(here ? 0.16 : 0.06))
            RoundedRectangle(cornerRadius: room.space == nil && !room.tunnel ? 12 : 18)
                .strokeBorder(color.opacity(here ? 0.9 : 0.4), style: StrokeStyle(lineWidth: room.space == nil && !room.tunnel ? 1.5 : 3,
                                                                                  dash: room.space == nil && !room.tunnel ? [4, 4] : []))
            // Ripples: rings from the source that fade as slowly as the room rings.
            if here, !room.tunnel {
                let local = CGPoint(x: pos.x * size.width - r.minX, y: pos.y * size.height - r.minY)
                ForEach(Array(hits.suffix(4).enumerated()), id: \.offset) { _, t in
                    let age = now - t
                    if age >= 0, age < tail + 0.1 {
                        let k = age / (tail + 0.1)
                        ForEach(0..<3, id: \.self) { ring in
                            let rr = CGFloat(k) * max(r.width, r.height) * (0.5 + 0.35 * CGFloat(ring))
                            Circle().stroke(GameStyle.ink.opacity((1 - k) * 0.5 / Double(ring + 1)), lineWidth: 2)
                                .frame(width: rr * 2, height: rr * 2)
                                .position(local)
                        }
                    }
                }
            }
            // Tunnel: one dot per echo, sliding away.
            if room.tunnel {
                let reps = 4
                ForEach(0..<reps, id: \.self) { k in
                    let x = r.width * CGFloat(k + 1) / CGFloat(reps + 1)
                    Rectangle().fill(Theme.gold.opacity(0.25)).frame(width: 2, height: r.height - 10)
                        .position(x: x, y: r.height / 2)
                }
                if let last = hits.last, echoOn {
                    let age = (now - last) / clock.stepSeconds
                    ForEach(1...reps, id: \.self) { k in
                        let at = Double(k * echoSteps)
                        if age >= at, age < at + 2.5 {
                            Circle().fill(Theme.gold.opacity(pow(0.7, Double(k))))
                                .frame(width: 18, height: 18)
                                .shadow(color: Theme.gold, radius: 8)
                                .position(x: r.width * CGFloat(k) / CGFloat(reps + 1), y: r.height / 2)
                        }
                    }
                }
            }
            // Cards dropped into this room.
            if case .identify = round.mode {
                HStack(spacing: 4) {
                    ForEach(assigned.filter { $0.value == index }.map(\.key).sorted(), id: \.self) { c in
                        Text("\(c + 1)").font(.label(13, weight: .black)).foregroundStyle(Theme.onBrand)
                            .frame(width: 26, height: 26).background(Circle().fill(accent))
                    }
                }
                .position(x: r.width / 2, y: r.height - 18)
            }
            Text(room.name.uppercased()).font(.label(10, weight: .black)).tracking(1)
                .foregroundStyle(color.opacity(0.9))
                .position(x: r.width / 2, y: 14)
        }
        .frame(width: r.width, height: r.height)
        .position(x: r.midX, y: r.midY)
    }

    private var sourcePuck: some View {
        ZStack {
            Circle().fill(GameStyle.snare).frame(width: 44, height: 44).shadow(color: GameStyle.snare, radius: playing ? 12 : 4)
            Image(systemName: ["hands.clap.fill", "waveform", "pianokeys", "circle.hexagongrid.fill"][source])
                .font(.system(size: 18, weight: .black)).foregroundStyle(.white)
        }
    }

    private var micView: some View {
        VStack(spacing: 2) {
            Image(systemName: "ear.fill").font(.system(size: 22, weight: .black)).foregroundStyle(.white)
            Text("YOU").font(.label(9, weight: .black)).foregroundStyle(GameStyle.nightDim)
        }
    }

    private var tag: String {
        if hearingRef { return "Target" }
        if recording { return "Recording · beat \(min(4, recorded.count / 4 + 1))" }
        switch round.mode {
        case .echoTime: return "Echo every \(echoSteps) step\(echoSteps == 1 ? "" : "s")"
        case .wetFix, .journey: return "Wet \(Int(wet * 100))%"
        case .identify: return selectedCard == nil ? "Pick a clip below" : "Tap a room for clip \((selectedCard ?? 0) + 1)"
        default:
            guard showsSource else { return task.name }
            if let r = currentRoom { return r.tunnel ? "Echo tunnel" : r.space == nil ? "Dry" : r.name }
            return "Dry"
        }
    }

    private func drag(_ d: DragGesture.Value, size: CGSize) {
        let p = CGPoint(x: min(0.97, max(0.03, d.location.x / size.width)), y: min(0.95, max(0.05, d.location.y / size.height)))
        switch round.mode {
        case .identify, .reveal:
            return
        case .echoTime:
            let steps = Int(((p.x - 0.18) / 0.1).rounded()) + 1
            let s = min(8, max(1, steps))
            if s != echoSteps {
                echoSteps = s
                Haptics.select()
            }
        default:
            pos = p
            if !playing { startLoop() }
        }
    }

    private func dragEnd(_ d: DragGesture.Value, size: CGSize) {
        guard case .identify(let clips) = round.mode, let card = selectedCard else { return }
        let p = CGPoint(x: d.location.x / size.width, y: d.location.y / size.height)
        guard let idx = rooms.firstIndex(where: { $0.rect.contains(p) }) else { return }
        withAnimation(.spring(response: 0.35)) {
            assigned[card] = idx
            selectedCard = (0..<clips.count).first { assigned[$0] == nil }
        }
        Haptics.thump()
    }

    // MARK: Cards and pickers

    private func clipCards(_ clips: [ReverbSpace?], pick: Bool) -> some View {
        HStack(spacing: 10) {
            ForEach(Array(clips.enumerated()), id: \.offset) { i, s in
                Button {
                    playClip(s, card: i)
                    if pick { choice = i } else { selectedCard = i }
                } label: {
                    VStack(spacing: 8) {
                        TimelineView(.animation(paused: cardPlayed[i] == nil)) { _ in
                            let age = cardPlayed[i].map { CACurrentMediaTime() - $0 } ?? 9
                            let tail = s?.seconds ?? 0.15
                            ZStack {
                                ForEach(0..<3, id: \.self) { ring in
                                    let k = min(1, age / (tail + 0.1))
                                    Circle().stroke(GameStyle.ink.opacity(age < tail + 0.1 ? (1 - k) * 0.6 / Double(ring + 1) : 0.08), lineWidth: 2)
                                        .frame(width: 20 + CGFloat(k) * 50 * CGFloat(ring + 1) / 2, height: 20 + CGFloat(k) * 50 * CGFloat(ring + 1) / 2)
                                }
                                Image(systemName: "hands.clap.fill").font(.system(size: 18, weight: .black)).foregroundStyle(accent)
                            }
                            .frame(height: 90)
                        }
                        Text(pick ? "Clip \(["A", "B", "C", "D"][i % 4])" : "Clip \(i + 1)").font(.label(13, weight: .heavy))
                            .foregroundStyle(GameStyle.nightText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 18).fill(GameStyle.nightRaised))
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(
                        (pick ? choice == i : selectedCard == i) ? accent : (assigned[i] != nil ? Theme.success.opacity(0.6) : .clear), lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
    }

    private var sourcePicker: some View {
        VStack(spacing: 10) {
            StageTag(text: "Choose a source", color: accent)
            HStack(spacing: 10) {
                ForEach(1..<4, id: \.self) { i in
                    ChoiceTile(title: Self.sources[i], symbol: ["", "waveform", "pianokeys", "circle.hexagongrid.fill"][i],
                               color: [GameStyle.snare, GameStyle.chords, GameStyle.lead, GameStyle.kick][i], selected: source == i) {
                        source = i
                        engine.setReverb(mix: 0, space: .room)
                        fire(i, velocity: 1)
                        Haptics.select()
                    }
                }
            }
        }
        .padding(14)
    }

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .identify(let clips):
            VStack(alignment: .leading, spacing: 8) {
                Text("Tap a clip to hear it, then tap the room it belongs in.").font(.label(13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                GameStage(height: 150) { clipCards(clips, pick: false) }
            }
        case .echoTime(let t):
            Button(action: { toggleRef(echo: t) }) {
                Label(hearingRef ? "Back to mine" : "Hear the target", systemImage: hearingRef ? "arrow.uturn.left" : "ear")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: hearingRef ? Theme.gold : Theme.surfaceHigh, textColor: Theme.text, height: 52))
        case .wetFix:
            ABSwitch(a: "Before", b: "Yours", current: playing ? ab : nil) { i in
                ab = i
                if !playing { startLoop() }
                applySpace()
            }
        case .journey:
            VStack(spacing: 10) {
                automationLane(recorded)
                HStack(spacing: 10) {
                    Button { echoThrow.toggle(); Haptics.select() } label: {
                        Label(echoThrow ? "Echo on last hit" : "Add an echo throw", systemImage: "dot.radiowaves.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: echoThrow ? Theme.gold : Theme.surfaceHigh, textColor: Theme.text, height: 50))
                }
            }
        case .reveal:
            VStack(spacing: 10) {
                automationLane(journey)
                ABSwitch(a: "Dry", b: "Your journey", current: playing ? ab : nil) { i in
                    ab = i
                    startLoop()
                }
            }
        default:
            EmptyView()
        }
    }

    private func automationLane(_ values: [Double]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SPACE OVER FOUR BEATS").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(0..<16, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < values.count ? GameStyle.chords : Theme.surfaceHigh)
                        .frame(height: 6 + 44 * CGFloat(i < values.count ? values[i] : 0))
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .card(padding: 14)
    }

    // MARK: Sound

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        hits = []
        visited = []
        assigned = [:]
        cardPlayed = [:]
        choice = nil
        hearingRef = false
        recording = false
        recorded = []
        ab = nil
        switch round.mode {
        case .wetFix: pos = CGPoint(x: 0.9, y: 0.85)
        case .journey: pos = CGPoint(x: 0.24, y: 0.5)
        case .echoTime: echoSteps = 6
        case .identify: selectedCard = 0
        default: pos = CGPoint(x: 0.5, y: 0.9)
        }
        if case .tunnel = round.mode { source = 0 }
        if case .rooms = round.mode { source = 0 }
    }

    private func startLoop() {
        clock.reset(bpm: round.bpm)
        transport.play(Pattern(), genre: genre, source: .user, bpm: round.bpm)
        playing = true
        applySpace()
    }

    private func applySpace() {
        if let r = currentRoom { visited.insert(r.name) }
        switch round.mode {
        case .wetFix:
            engine.setReverb(mix: ab == 0 ? 0.95 : wet, space: .hall)
        case .journey:
            if !recording { engine.setReverb(mix: wet, space: .hall) }
        case .reveal:
            break
        case .echoTime:
            engine.setReverb(mix: 0, space: .room)
        default:
            engine.setReverb(mix: wet, space: currentRoom?.space ?? .room)
        }
    }

    private func onStep(_ s: Int) {
        let step = s % 16
        if case .journey = round.mode, recording {
            recorded.append(wet)
            engine.setReverb(mix: wet, space: .hall)
            if recorded.count >= 16 {
                recording = false
                journey = recorded
                Haptics.success()
            }
        }
        if case .reveal = round.mode, ab == 1, step < journey.count {
            engine.setReverb(mix: journey[step], space: .hall)
        }
        guard sourceSteps.contains(step) else { return }
        fire(source, velocity: 1)
        hits.append(CACurrentMediaTime())
        if hits.count > 8 { hits.removeFirst() }
        let throwing: Bool = {
            if case .reveal = round.mode { return ab == 1 && step == 12 && echoThrow }
            if case .journey = round.mode { return echoThrow && step == 12 }
            return false
        }()
        if echoOn || throwing {
            let spacing = throwing ? 4 : (hearingRef ? refEcho : echoSteps)
            let which = source, step = clock.stepSeconds
            Task { @MainActor in
                for k in 1...3 {
                    try? await Task.sleep(for: .milliseconds(Int(Double(spacing) * step * 1000)))
                    fire(which, velocity: Float(pow(0.55, Double(k))))
                }
            }
        }
    }

    private var refEcho: Int {
        if case .echoTime(let t) = round.mode { return t }
        return 4
    }

    private func fire(_ which: Int, velocity: Float) {
        let kit = transport.kit(for: genre)
        switch which {
        case 1: engine.playChord([57, 60, 64], seconds: 0.18, patch: .stab)
        case 2: engine.playNote(64, seconds: 0.3, patch: .popPiano, velocity: velocity)
        case 3: engine.trigger(.perc, kit: kit, velocity: velocity)
        default: engine.trigger(.clap, kit: kit, velocity: velocity)
        }
        if which == 1, velocity < 1 {
            // Quieter echo of the stab.
            engine.playNote(64, seconds: 0.12, patch: .stab, velocity: velocity)
        }
    }

    private func playClip(_ space: ReverbSpace?, card: Int) {
        transport.stop()
        playing = false
        engine.setReverb(mix: space == nil ? 0 : [0.35, 0.4, 0.5, 0.6][space!.rawValue], space: space ?? .room)
        fire(0, velocity: 1)
        cardPlayed[card] = CACurrentMediaTime()
        Haptics.tap()
    }

    private func toggleRef(echo: Int) {
        hearingRef.toggle()
        if !playing { startLoop() }
    }

    // MARK: Flow

    private var primaryTitle: String {
        switch round.mode {
        case .rooms, .tunnel: return playing ? "I hear the difference" : "Drag the source"
        case .identify, .echoTime, .wetFix, .outlier: return "Check"
        case .chooseSource: return "Use this source"
        case .journey:
            if recording { return "Recording…" }
            return journey.count == 16 ? "Keep this journey" : "Record the journey"
        case .reveal: return "Save the moment"
        }
    }

    private var primaryEnabled: Bool {
        switch round.mode {
        case .rooms(let spaces): return visited.intersection(Set(spaces.map(\.name))).count >= spaces.count && visited.contains("Open air")
        case .tunnel: return visited.contains("Hall") && visited.contains("Echo tunnel")
        case .identify(let clips): return assigned.count == clips.count
        case .echoTime: return playing && !hearingRef
        case .wetFix: return playing
        case .outlier: return choice != nil
        case .chooseSource: return source > 0
        case .journey: return !recording
        case .reveal: return ab != nil
        }
    }

    private func primary() {
        switch round.mode {
        case .rooms:
            game.pass(1, "Same clap every time. The bigger the room, the longer its tail rings after the hit.")
        case .tunnel:
            game.pass(1, "The room is a smooth wash of reflections. The tunnel gives you separate, countable repeats. That's delay.")
        case .identify(let clips):
            var right = 0
            for (i, s) in clips.enumerated() where rooms[assigned[i] ?? 0].space == s { right += 1 }
            if right == clips.count {
                game.pass(game.fails == 0 ? 1 : 0.7, "Every clip is in its room. Short tail, small room. Long tail, big space.")
            } else {
                game.miss("\(right) of \(clips.count) are right. Listen to how long each clip rings after the hit.",
                          score: Double(right) / Double(clips.count))
                assigned = [:]
                selectedCard = 0
            }
        case .echoTime(let t):
            if echoSteps == t {
                game.pass(game.fails == 0 ? 1 : 0.7, "Your echoes land with the target's, \(t == 2 ? "every half beat" : "every \(t) steps").")
            } else {
                game.miss(echoSteps > t ? "Your echoes come too slowly. Shorten the tunnel." : "Your echoes come too fast. Stretch the tunnel.")
            }
        case .wetFix(let target):
            if abs(wet - target) < 0.13 {
                game.pass(max(0.6, 1 - abs(wet - target) * 3), "Now the melody is clear and still has some room around it.")
            } else {
                game.miss(wet > target ? "Still muddy. Bring the source closer to you." : "Now it's bone dry. Let it drift back a little.")
            }
        case .outlier(let spaces):
            let odd = spaces.indices.first { i in spaces.filter { $0 == spaces[i] }.count == 1 } ?? 0
            if choice == odd {
                game.pass(game.fails == 0 ? 1 : 0.7, "Clip \(["A", "B", "C"][odd]) came from a different space. Its tail gave it away.")
            } else {
                game.miss("Two clips share a room. Compare how long each one rings, not how loud it is.")
                choice = nil
            }
        case .chooseSource:
            game.pass(1, "\(Self.sources[source]) it is. Now give it a journey.")
        case .journey:
            if journey.count < 16 {
                recorded = []
                recording = true
                if !playing { startLoop() }
                Haptics.thump()
                return
            }
            let rise = (journey.suffix(4).reduce(0, +) - journey.prefix(4).reduce(0, +)) / 4
            if rise < 0.25 {
                game.miss("Start close to your ear and drift far away by the last beat.")
                journey = []
                recorded = []
                return
            }
            if !echoThrow {
                game.miss("Nearly. Add one echo throw on the last hit.")
                return
            }
            GoldShelf.save(GoldShelf.journey, journey + [1])
            game.pass(1, "Close and dry, then far and wide, with an echo to finish. That's a spatial moment.")
        case .reveal:
            transport.stop()
            playing = false
            game.pass(1, "Saved your spatial moment. It's yours to reuse in your mini-track.")
        }
    }

    private func retry() {
        withAnimation { game.feedback = nil }
    }

    private func next() {
        if game.advance() {
            transport.stop()
            engine.resetEffects()
            onComplete(game.average)
            return
        }
        transport.stop()
        playing = false
        engine.setReverb(mix: 0, space: .room)
        setup()
    }
}
