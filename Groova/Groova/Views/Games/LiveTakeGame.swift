//
//  LiveTakeGame.swift
//  Groova
//
//  F5.5 The Live Take. A compact performance desk: four channel strips and big scene pads. The
//  track keeps moving while you launch Intro, Main, Change and End. Every launch lands on the
//  next bar line, so your take always sounds musical, and the timeline fills with what you played.
//

import Foundation
import QuartzCore
import SwiftUI

struct LiveTakeGame: View {
    let task: GameTask
    let rounds: [LiveRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let sceneNames = ["Intro", "Main", "Change", "End"]
    static let sceneColors: [Color] = [GameStyle.chords, GameStyle.kick, GameStyle.lead, GameStyle.snare]
    static let channelNames = ["Drums", "Bass", "Chords", "Lead"]
    static let channelColors: [Color] = [GameStyle.kick, GameStyle.bass, GameStyle.chords, GameStyle.lead]
    static let palettes: [[Int]] = [[0, 1, 0, 0], [1, 0, 2, 1]]
    static let paletteNames = ["Punchy", "Mellow"]
    static let fillNames = ["Snare roll", "Kick pickup"]
    static let breathNames = ["Pause", "Echo"]
    /// Guided cue bars for Intro, Main, Change and End, for a 12-bar take.
    static let cues = [1, 3, 7, 9]

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var playing = false
    @State private var scene: Int = -1
    @State private var queued: Int?
    @State private var take: [Int] = []
    @State private var launches: [(scene: Int, bar: Int)] = []
    @State private var muted: Set<Int> = []
    @State private var palette: Int?
    @State private var useImported = false
    @State private var heardChannels: Set<Int> = []
    @State private var fill: Int?
    @State private var breath: Int?
    @State private var replayTake: [Int]?
    @State private var selectedLaunch: Int?
    @State private var replayed = false
    @State private var name = ""
    @State private var favourite = 0
    @State private var endedAt: Int?
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [LiveRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: LiveRound { rounds[min(game.index, rounds.count - 1)] }
    private var bars: Int { round.bars }

    // MARK: Sound

    private var lineup: [Int] {
        if useImported, let p = GoldShelf.load(GoldShelf.palette), p.count == 4 { return p.map { Int($0) } }
        return Self.palettes[palette ?? 0]
    }

    private var leadPatch: SynthPatch {
        if useImported, let s = GoldShelf.load(GoldShelf.synth), s.count == 3 {
            return SynthSurgeryGame.patch(SculptShape(attack: s[0], release: s[1], filter: s[2]))
        }
        return Band.lead[lineup[3] % 3].patch
    }

    private var kit: DrumKit { Band.kit(genre, lineup: lineup) }

    private static func scenePattern(_ s: Int) -> Pattern {
        switch s {
        case 0: return Pattern(hat: FKit.eighths, chords: SongKit.chordBed)
        case 1: return SongKit.verse
        case 2: return Pattern(bass: [NoteEvent(0, 41, 6), NoteEvent(8, 43, 6)], chords: SongKit.chordBedB)
        case 3: return SongKit.outro
        default: return Pattern(hat: FKit.quarters)
        }
    }

    private static func sceneLead(_ s: Int) -> [NoteEvent] {
        switch s {
        case 1: return Stems.lead
        case 2: return SongKit.leadB
        default: return []
        }
    }

    private func pattern(_ s: Int) -> Pattern {
        var p = Self.scenePattern(s)
        if muted.contains(0), s >= 0 { for t in DrumTrack.allCases { p[t] = Array(repeating: false, count: 16) } }
        if muted.contains(1) { p.bass = [] }
        if muted.contains(2) { p.chords = [] }
        return p
    }

    /// The current bar with the transition into the queued scene.
    private func withTransition(_ p: Pattern, into next: Int) -> Pattern {
        var p = p
        if next == 1, scene != 1, let f = fill ?? defaultFill {
            let src = f == 0 ? SongKit.fill : Pattern(kick: [0, 8, 12, 14, 15], clap: [4], hat: [0, 2, 4, 6])
            for t in DrumTrack.allCases { for s in 8..<16 { p[t][s] = src[t][s] } }
        }
        if next == 2, (breath ?? defaultBreath) != nil {
            p = SongKit.splice(p, Pattern(), at: 12)
        }
        return p
    }

    private var defaultFill: Int? {
        switch round.mode {
        case .guided, .playback, .free: return 0
        default: return nil
        }
    }

    private var defaultBreath: Int? {
        if case .free = round.mode { return 0 }
        return nil
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    top
                    GameStage(height: 300) { desk }
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
        .onChange(of: transport.isRunning) { _, running in
            if !running, playing { stopped() }
        }
        .onDisappear { transport.stop() }
    }

    // MARK: Timeline and desk

    @ViewBuilder private var top: some View {
        TimelineView(.animation(paused: !playing)) { _ in
            VStack(alignment: .leading, spacing: 8) {
                Text("TIMELINE").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
                GeometryReader { g in
                    let bw = g.size.width / CGFloat(bars)
                    let pos = playing ? (clock.now() ?? 0) / 16 : -1
                    let shown = replayTake ?? take
                    ZStack(alignment: .topLeading) {
                        ForEach(0..<bars, id: \.self) { b in
                            let s = b < shown.count ? shown[b] : -2
                            RoundedRectangle(cornerRadius: 5)
                                .fill(s >= 0 ? Self.sceneColors[s] : (s == -1 ? Theme.surfaceHigh : Theme.surfaceRaised))
                                .frame(width: bw - 3, height: 34)
                                .offset(x: bw * CGFloat(b))
                            Text("\(b + 1)").font(.label(9, weight: .black)).foregroundStyle(Theme.textTertiary)
                                .offset(x: bw * CGFloat(b) + 3, y: 38)
                        }
                        if case .guided = round.mode {
                            ForEach(0..<4, id: \.self) { i in
                                let cue = Self.cues[i]
                                let soon = pos >= Double(cue) - 1 && pos < Double(cue)
                                VStack(spacing: 1) {
                                    Text(Self.sceneNames[i].uppercased()).font(.label(8, weight: .black))
                                        .foregroundStyle(soon ? Theme.gold : Theme.textSecondary)
                                    Image(systemName: "arrowtriangle.down.fill").font(.system(size: 8))
                                        .foregroundStyle(soon ? Theme.gold : Theme.textTertiary)
                                }
                                .scaleEffect(soon ? 1.25 : 1)
                                .offset(x: bw * CGFloat(cue) - 14, y: -22)
                            }
                        }
                        if case .refine = round.mode {
                            ForEach(Array(launches.enumerated()), id: \.offset) { i, l in
                                Button { selectedLaunch = i; Haptics.select() } label: {
                                    Circle().fill(selectedLaunch == i ? Theme.gold : Color.white)
                                        .frame(width: 18, height: 18)
                                        .overlay(Circle().strokeBorder(Self.sceneColors[l.scene], lineWidth: 3))
                                }
                                .buttonStyle(.plain)
                                .offset(x: bw * CGFloat(l.bar) - 9, y: 8)
                            }
                        }
                        if case .release = round.mode {
                            RoundedRectangle(cornerRadius: 6).strokeBorder(Theme.gold, lineWidth: 3)
                                .frame(width: bw * 2, height: 40)
                                .offset(x: bw * CGFloat(favourite), y: -3)
                        }
                        if pos >= 0 {
                            Rectangle().fill(Theme.text).frame(width: 2, height: 42).offset(x: bw * CGFloat(pos), y: -4)
                        }
                    }
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0).onChanged { d in
                        guard case .release = round.mode else { return }
                        let b = min(bars - 2, max(0, Int(d.location.x / bw - 0.5)))
                        if b != favourite { favourite = b; Haptics.select() }
                    })
                }
                .frame(height: 50)
                .padding(.top, round.mode == .guided ? 20 : 0)
            }
            .card(padding: 14)
        }
    }

    private var desk: some View {
        TimelineView(.animation(paused: !playing)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            VStack(spacing: 12) {
                // Channel strips.
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { c in
                        let live = playing && !muted.contains(c) && channelActive(c)
                        Button { tapChannel(c) } label: {
                            VStack(spacing: 6) {
                                HStack(alignment: .bottom, spacing: 3) {
                                    ForEach(0..<3, id: \.self) { k in
                                        Capsule().fill(Self.channelColors[c].opacity(live ? 1 : 0.2))
                                            .frame(width: 6, height: live ? 10 + 22 * abs(sin(t * (5 + Double(k)) + Double(c))) : 8)
                                    }
                                }
                                .frame(height: 34, alignment: .bottom)
                                Text(Self.channelNames[c]).font(.label(10, weight: .black)).foregroundStyle(.white)
                                Text(muted.contains(c) ? "MUTED" : "ON").font(.label(9, weight: .black))
                                    .foregroundStyle(muted.contains(c) ? GameStyle.snare : GameStyle.nightDim)
                            }
                            .frame(maxWidth: .infinity, minHeight: 86)
                            .background(RoundedRectangle(cornerRadius: 14).fill(GameStyle.nightRaised))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(heardChannels.contains(c) && round.mode == .load(imports: false) ? Self.channelColors[c] : .clear, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                    }
                }
                // Scene pads.
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { s in
                        let isOn = scene == s
                        let isQueued = queued == s
                        let blink = isQueued ? 0.5 + 0.5 * sin(t * 12) : 0
                        Button { launch(s) } label: {
                            VStack(spacing: 4) {
                                Image(systemName: ["sunrise.fill", "flame.fill", "arrow.triangle.branch", "moon.stars.fill"][s])
                                    .font(.system(size: 20, weight: .black))
                                Text(showsSceneNames ? Self.sceneNames[s].uppercased() : "SCENE \(s + 1)")
                                    .font(.label(11, weight: .black))
                            }
                            .foregroundStyle(isOn ? Theme.onBrand : GameStyle.nightText)
                            .frame(maxWidth: .infinity, minHeight: 110)
                            .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(isOn ? Self.sceneColors[s] : Self.sceneColors[s].opacity(0.18 + 0.4 * blink)))
                            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Self.sceneColors[s].opacity(0.7), lineWidth: 2))
                            .scaleEffect(isOn ? 1.03 : 1)
                        }
                        .buttonStyle(.plain)
                        .disabled(!performing)
                        .opacity(performing ? 1 : 0.5)
                    }
                }
            }
            .padding(14)
        }
    }

    private var showsSceneNames: Bool { true }

    private var performing: Bool {
        guard playing, replayTake == nil, endedAt == nil else { return false }
        switch round.mode {
        case .guided, .cued, .free: return true
        default: return false
        }
    }

    private func channelActive(_ c: Int) -> Bool {
        let p = Self.scenePattern(scene)
        switch c {
        case 0: return p.kick.contains(true) || p.hat.contains(true)
        case 1: return !p.bass.isEmpty
        case 2: return !p.chords.isEmpty
        default: return !Self.sceneLead(scene).isEmpty
        }
    }

    // MARK: Below

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .load(let imports):
            VStack(alignment: .leading, spacing: 10) {
                Text("Tap a channel to hear that layer alone. Then choose the band's sound.")
                    .font(.label(13, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                HStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { i in
                        ChoiceTile(title: Self.paletteNames[i], symbol: i == 0 ? "bolt.fill" : "cloud.fill", color: accent,
                                   selected: palette == i && !useImported) {
                            palette = i
                            useImported = false
                            preview(scene: 1)
                        }
                    }
                    if imports {
                        let has = GoldShelf.load(GoldShelf.palette) != nil || GoldShelf.load(GoldShelf.synth) != nil
                        ChoiceTile(title: has ? "My Gold sounds" : "Starter kit", symbol: "star.fill", color: Theme.gold,
                                   selected: useImported) {
                            if has { useImported = true; palette = palette ?? 0 } else { palette = 1 }
                            preview(scene: 1)
                        }
                    }
                }
                if imports { importNote }
            }
        case .transitions:
            VStack(alignment: .leading, spacing: 10) {
                Text("FILL INTO MAIN").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
                HStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { i in
                        ChoiceTile(title: Self.fillNames[i], symbol: "circle.grid.3x3.fill", color: Theme.gold, selected: fill == i) {
                            fill = i
                            previewTransition(into: 1)
                        }
                    }
                }
                Text("BREATH BEFORE THE CHANGE").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
                HStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { i in
                        ChoiceTile(title: Self.breathNames[i], symbol: i == 0 ? "pause.fill" : "dot.radiowaves.right",
                                   color: Theme.gold, selected: breath == i) {
                            breath = i
                            previewTransition(into: 2)
                        }
                    }
                }
            }
        case .refine:
            HStack(spacing: 10) {
                Button { nudge(-1) } label: { Label("Earlier", systemImage: "chevron.left").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                    .disabled(selectedLaunch == nil)
                Button { nudge(1) } label: { Label("Later", systemImage: "chevron.right").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                    .disabled(selectedLaunch == nil)
            }
        case .release:
            VStack(spacing: 10) {
                TextField("Name your track", text: $name)
                    .font(.label(17, weight: .heavy))
                    .padding(.horizontal, 14).frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surfaceHigh))
                Text("Drag the gold box on the timeline to your favourite moment.")
                    .font(.label(13, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                Button { playFavourite() } label: { Label("Play my favourite bit", systemImage: "star.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
            }
        default:
            EmptyView()
        }
    }

    @ViewBuilder private var importNote: some View {
        let band = GoldShelf.load(GoldShelf.palette) != nil
        let synth = GoldShelf.load(GoldShelf.synth) != nil
        if band || synth {
            Label("Bringing in \([band ? "your band from Sound Casting" : nil, synth ? "your synth from Synth Surgery" : nil].compactMap { $0 }.joined(separator: " and ")).",
                  systemImage: "star.fill")
                .font(.label(13, weight: .semibold)).foregroundStyle(Theme.textSecondary)
        } else {
            Text("No Gold creations yet, so you'll get a starter kit. Finish F4 Gold to bring your own sounds here.")
                .font(.label(13, weight: .semibold)).foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: Performance

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        playing = false
        scene = -1
        queued = nil
        muted = []
        heardChannels = []
        replayTake = nil
        selectedLaunch = nil
        replayed = false
        endedAt = nil
        switch round.mode {
        case .guided, .cued, .free:
            take = []
            launches = []
        default:
            break
        }
    }

    private func start() {
        clock.reset(bpm: round.bpm)
        scene = -1
        queued = nil
        endedAt = nil
        if replayTake == nil { take = Array(repeating: -1, count: bars); launches = [] }
        transport.play(pattern(-1), genre: genre, source: .user, bars: bars, bpm: round.bpm, kit: kit)
        playing = true
        Haptics.thump()
    }

    private func launch(_ s: Int) {
        guard performing else { return }
        if let last = launches.last?.scene, last == 3 { return }
        queued = s
        Haptics.thump()
        // The fill or breath plays in what's left of this bar.
        transport.liveUpdate(withTransition(pattern(scene), into: s))
    }

    private func onStep(_ s: Int) {
        let step = s % 16
        let bar = clock.bar
        if step == 0 {
            if let q = queued {
                scene = q
                queued = nil
                if replayTake == nil {
                    launches.append((q, bar))
                    if q == 3 { endedAt = bar }
                }
            }
            if replayTake == nil, bar < take.count { take[bar] = scene }
        }
        if let replayTake, step == 8, bar + 1 < replayTake.count, replayTake[bar + 1] != scene {
            let q = replayTake[bar + 1]
            queued = q
            transport.liveUpdate(withTransition(pattern(scene), into: q))
        }
        if step == 15 {
            if let q = queued {
                transport.liveUpdate(pattern(q))
            } else if scene == 3 {
                transport.liveUpdate(Pattern())
            }
        }
        if step == 12, queued == 2, (breath ?? defaultBreath) == 1 {
            for (k, p) in [64, 60].enumerated() {
                AudioEngine.shared.playNote(p, seconds: 0.15, patch: kit.chords, velocity: 0.5, delay: Double(k) * clock.stepSeconds * 2)
            }
        }
        if !muted.contains(3), scene >= 0, endedAt.map({ bar <= $0 }) ?? true {
            playLead(Self.sceneLead(scene), step: step, patch: leadPatch, level: 1, stepSeconds: clock.stepSeconds)
        }
    }

    private func stopped() {
        playing = false
        if replayTake != nil {
            replayed = true
            replayTake = nil
        }
    }

    private func tapChannel(_ c: Int) {
        Haptics.select()
        if case .load = round.mode {
            heardChannels.insert(c)
            var p = Self.scenePattern(1)
            if c != 0 { for t in DrumTrack.allCases { p[t] = Array(repeating: false, count: 16) } }
            if c != 1 { p.bass = [] }
            if c != 2 { p.chords = [] }
            transport.play(p, genre: genre, source: .demo, bars: 1, bpm: round.bpm, kit: kit)
            if c == 3 {
                for n in Stems.lead {
                    AudioEngine.shared.playNote(n.pitch, seconds: Double(n.length) * 60 / round.bpm / 4, patch: leadPatch,
                                                delay: Double(n.step) * 60 / round.bpm / 4)
                }
            }
            return
        }
        if muted.contains(c) { muted.remove(c) } else { muted.insert(c) }
        if playing { transport.liveUpdate(pattern(scene)) }
    }

    private func preview(scene s: Int) {
        Haptics.select()
        transport.play(Self.scenePattern(s), genre: genre, source: .demo, bars: 1, bpm: round.bpm, kit: kit)
        for n in Self.sceneLead(s) {
            AudioEngine.shared.playNote(n.pitch, seconds: Double(n.length) * 60 / round.bpm / 4, patch: leadPatch,
                                        delay: Double(n.step) * 60 / round.bpm / 4)
        }
    }

    private func previewTransition(into s: Int) {
        Haptics.select()
        let from = s == 1 ? 0 : 1
        let seq = [withTransition(Self.scenePattern(from), into: s), Self.scenePattern(s)]
        transport.play(Pattern(), genre: genre, source: .demo, bars: 2, bpm: round.bpm, kit: kit, sequence: seq, barsPerSection: 1)
    }

    private func playBack(_ t: [Int]) {
        replayTake = t
        clock.reset(bpm: round.bpm)
        scene = t.first ?? -1
        queued = nil
        endedAt = nil
        transport.play(pattern(scene), genre: genre, source: .user, bars: t.count, bpm: round.bpm, kit: kit)
        playing = true
    }

    private func nudge(_ d: Int) {
        guard let i = selectedLaunch, i < launches.count else { return }
        let lo = i > 0 ? launches[i - 1].bar + 1 : 1
        let hi = i + 1 < launches.count ? launches[i + 1].bar - 1 : bars - 2
        let nb = min(hi, max(lo, launches[i].bar + d))
        guard nb != launches[i].bar else { return }
        launches[i].bar = nb
        take = Self.takeFrom(launches, bars: bars)
        Haptics.select()
        playBack(take)
    }

    static func takeFrom(_ launches: [(scene: Int, bar: Int)], bars: Int) -> [Int] {
        var t = Array(repeating: -1, count: bars)
        var cur = -1
        for b in 0..<bars {
            if let l = launches.last(where: { $0.bar == b }) { cur = l.scene }
            t[b] = cur
        }
        return t
    }

    private func playFavourite() {
        let t = take.isEmpty ? Self.takeFrom([(0, 1), (1, 3), (2, 7), (3, 9)], bars: bars) : take
        let slice = Array(t[min(favourite, t.count - 1)..<min(t.count, favourite + 2)])
        playBack(slice)
    }

    // MARK: Flow

    private var primaryTitle: String {
        if playing && replayTake == nil && performing { return endedAt == nil ? "Performing…" : "Letting it ring…" }
        if playing { return "Listening…" }
        switch round.mode {
        case .load: return "Load this palette"
        case .guided, .cued, .free: return take.contains(where: { $0 >= 0 }) ? "Check my take" : "Start the take"
        case .playback: return replayed ? "Save my first track" : "Hear the whole take"
        case .transitions: return "Use these transitions"
        case .refine: return replayed ? "Commit the take" : "Pick a launch to move"
        case .release: return "Release the take"
        }
    }

    private var primaryEnabled: Bool {
        if playing { return false }
        switch round.mode {
        case .load(let imports): return heardChannels.count >= (imports ? 1 : 2) && (palette != nil || useImported)
        case .transitions: return fill != nil && breath != nil
        case .refine: return replayed
        case .release: return true
        default: return true
        }
    }

    private func primary() {
        switch round.mode {
        case .load:
            transport.stop()
            game.pass(1, useImported ? "Your own sounds are loaded on the desk." : "\(Self.paletteNames[palette ?? 0]) palette loaded. Time to perform.")
        case .guided:
            if !take.contains(where: { $0 >= 0 }) { start(); return }
            judge(cued: true)
        case .cued, .free:
            if !take.contains(where: { $0 >= 0 }) { start(); return }
            judge(cued: false)
        case .playback:
            if !replayed {
                playBack(take.contains(where: { $0 >= 0 }) ? take : Self.takeFrom([(0, 1), (1, 3), (2, 7), (3, 9)], bars: bars))
                return
            }
            GoldShelf.save("take", take.map(Double.init))
            game.pass(1, "That's your first complete track: a start, a middle, a change and an ending.")
        case .transitions:
            transport.stop()
            game.pass(1, "\(Self.fillNames[fill ?? 0]) into the main part, a \(Self.breathNames[breath ?? 0].lowercased()) before the change. The show is planned.")
        case .refine:
            game.pass(1, "Take committed. Fixing one moment is how real takes get finished.")
        case .release:
            GoldShelf.saveName("take", name.isEmpty ? "My first song" : name)
            GoldShelf.save("take", take.map(Double.init))
            GoldShelf.save("favourite", [Double(favourite)])
            transport.stop()
            game.pass(1, "“\(name.isEmpty ? "My first song" : name)” is finished and saved. You made a whole song.")
        }
    }

    private func judge(cued: Bool) {
        let order = launches.map { $0.scene }
        let names = Set(order)
        guard names.contains(0), names.contains(1), names.contains(3) else {
            game.miss("Launch Intro, Main and End at least, so the take has a beginning, a middle and an ending.")
            take = []
            return
        }
        guard order.last == 3 else {
            game.miss("Finish with End so the track stops on purpose.")
            take = []
            return
        }
        if case .free = round.mode, !names.contains(2) {
            game.miss("Add a Change somewhere in the middle, so something contrasts before the end.")
            take = []
            return
        }
        if cued {
            var total = 0.0
            for (i, cue) in Self.cues.enumerated() {
                if let l = launches.first(where: { $0.scene == i }) {
                    total += max(0, 1 - Double(abs(l.bar - cue)) * 0.35)
                }
            }
            let score = total / 4
            if score < 0.5 {
                game.miss("Close. Watch the gold arrows and tap the pad in the bar just before each cue.", score: score)
                take = []
                return
            }
            game.pass(score, "Every scene came in on a bar line. That's a complete performance.")
        } else {
            game.pass(1, "Your take has a real shape: \(order.map { Self.sceneNames[$0] }.joined(separator: " → ")).")
        }
    }

    private func retry() {
        withAnimation { game.feedback = nil }
    }

    private func next() {
        transport.stop()
        if game.advance() {
            onComplete(game.average)
            return
        }
        setup()
    }
}
