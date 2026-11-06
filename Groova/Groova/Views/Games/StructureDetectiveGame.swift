//
//  StructureDetectiveGame.swift
//  Groova
//
//  F5.1 Structure Detective. A song plays under a map of plain, unlabeled bars. Slam MARK the
//  moment the music changes. Then the X-ray opens: four stem lanes show what entered, left or
//  came back, and your marks sit on top of the real boundaries.
//

import Foundation
import QuartzCore
import SwiftUI

struct StructureDetectiveGame: View {
    let task: GameTask
    let rounds: [DetectiveRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let laneNames = ["Drums", "Bass", "Chords", "Melody"]
    static let laneColors: [Color] = [GameStyle.kick, GameStyle.bass, GameStyle.chords, GameStyle.lead]
    static let partNames = ["Start", "Main", "Change", "End"]
    static let sectionColors: [Color] = [GameStyle.chords, GameStyle.kick, GameStyle.lead, GameStyle.snare, Color(hex: 0x5CE0B8)]

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var playing = false
    @State private var heardOnce = false
    @State private var marks: [Double] = []
    @State private var revealed = false
    @State private var lanePick: Int?
    @State private var decoyPick: Bool?
    @State private var orderPicks: [Int] = []
    @State private var cardOrder: [Int] = []
    @State private var regionNames: [Int: Int] = [:]
    @State private var naming: Int?
    @State private var flash: Double?
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [DetectiveRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: DetectiveRound { rounds[min(game.index, rounds.count - 1)] }
    private var song: [SongSection] { round.song }
    private var totalBars: Int { song.reduce(0) { $0 + $1.bars } }
    private var boundaries: [Int] { SongKit.boundaries(song) }

    private var crash: (bar: Int, real: Bool)? {
        if case .decoy(let b, let r) = round.mode { return (b, r) }
        return nil
    }

    private var barPatterns: [Pattern] {
        var bars = SongKit.bars(song)
        if let crash, crash.bar < bars.count {
            bars[crash.bar].openHat[0] = true
            bars[crash.bar].perc[0] = true
            bars[crash.bar].kick[0] = true
        }
        return bars
    }

    /// Which section a bar is in.
    private func sectionIndex(_ bar: Int) -> Int {
        var at = 0
        for (i, s) in song.enumerated() {
            if bar < at + s.bars { return i }
            at += s.bars
        }
        return max(0, song.count - 1)
    }

    /// Regions for naming: your marks if they line up, otherwise the real boundaries.
    private var regions: [Int] {
        let snapped = Array(Set(marks.map { Int($0.rounded()) })).filter { $0 > 0 && $0 < totalBars }.sorted()
        return [0] + (snapped.count == boundaries.count ? snapped : boundaries)
    }

    private var showsXRay: Bool {
        if revealed { return true }
        if case .evidence = round.mode { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: showsXRay ? 330 : 250) { stage }
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
            if let crash, clock.bar == crash.bar, s == 0 { flash = CACurrentMediaTime() }
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running, playing {
                playing = false
                heardOnce = true
            }
        }
        .onDisappear { transport.stop() }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: !playing && flash == nil)) { _ in
            GeometryReader { geo in
                let w = geo.size.width - 28
                let barW = w / CGFloat(max(1, totalBars))
                let pos = playing ? (clock.now().map { $0 / 16 } ?? 0) : -1
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        StageTag(text: tag, color: playing ? accent : GameStyle.nightDim)
                        Spacer()
                        if playing, let p = clock.now() {
                            Text("Bar \(min(totalBars, Int(p / 16) + 1)) of \(totalBars)").font(.label(12, weight: .heavy))
                                .foregroundStyle(GameStyle.nightDim)
                        }
                    }
                    // The map: plain bars, with your marks.
                    ZStack(alignment: .topLeading) {
                        ForEach(0..<totalBars, id: \.self) { b in
                            let sec = sectionIndex(b)
                            let lit = pos >= Double(b)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(revealed ? Self.sectionColors[sec % 5].opacity(lit ? 0.6 : 0.35)
                                               : Color.white.opacity(lit ? 0.18 : 0.06))
                                .frame(width: barW - 4, height: 56)
                                .offset(x: barW * CGFloat(b))
                        }
                        if revealed {
                            ForEach(Array(song.enumerated()), id: \.offset) { i, s in
                                let start = song.prefix(i).reduce(0) { $0 + $1.bars }
                                Text(s.name).font(.label(10, weight: .black)).foregroundStyle(.white)
                                    .offset(x: barW * CGFloat(start) + 6, y: 6)
                            }
                            ForEach(boundaries, id: \.self) { b in
                                Rectangle().fill(Color.white).frame(width: 3, height: 70)
                                    .offset(x: barW * CGFloat(b) - 3, y: -7)
                            }
                        }
                        ForEach(Array(marks.enumerated()), id: \.offset) { _, m in
                            VStack(spacing: 0) {
                                Image(systemName: "flag.fill").font(.system(size: 14, weight: .black)).foregroundStyle(Theme.gold)
                                Rectangle().fill(Theme.gold).frame(width: 2, height: 52)
                            }
                            .offset(x: barW * CGFloat(m) - 2, y: -14)
                        }
                        if let flash, CACurrentMediaTime() - flash < 0.6, let crash {
                            Circle().fill(Color.white.opacity(0.8 - (CACurrentMediaTime() - flash)))
                                .frame(width: 44, height: 44).blur(radius: 6)
                                .offset(x: barW * CGFloat(crash.bar) - 10, y: 6)
                        }
                        if pos >= 0 {
                            Rectangle().fill(Color.white).frame(width: 2, height: 70)
                                .offset(x: barW * CGFloat(pos), y: -7)
                        }
                    }
                    .frame(width: w, height: 56, alignment: .topLeading)
                    if showsXRay { xray(barW: barW, pos: pos) }
                }
                .padding(14)
            }
        }
    }

    /// Four stem lanes, lit bar by bar where each part plays.
    private func xray(barW: CGFloat, pos: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(0..<4, id: \.self) { lane in
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        ForEach(0..<totalBars, id: \.self) { b in
                            let on = song[sectionIndex(b)].layers[lane]
                            let lit = revealed || pos >= Double(b)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(on ? Self.laneColors[lane].opacity(lit ? 0.85 : 0.25) : Color.white.opacity(0.03))
                                .frame(width: barW - 4, height: 18)
                                .offset(x: barW * CGFloat(b))
                        }
                    }
                    .frame(width: barW * CGFloat(totalBars), height: 18, alignment: .leading)
                }
                .overlay(alignment: .leading) {
                    Button {
                        guard case .evidence = round.mode else { return }
                        lanePick = lane
                        Haptics.select()
                    } label: {
                        Text(Self.laneNames[lane]).font(.label(10, weight: .black))
                            .foregroundStyle(lanePick == lane ? Theme.onBrand : .white)
                            .padding(.horizontal, 8).frame(height: 18)
                            .background(Capsule().fill(lanePick == lane ? Self.laneColors[lane] : Color.black.opacity(0.55)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var tag: String {
        if revealed { return "X-ray" }
        switch round.mode {
        case .mark: return playing ? "Listen and mark" : "Unlabeled map"
        case .evidence: return "Which layer changed?"
        case .decoy: return playing ? "Listen" : "Real change or decoy?"
        case .order: return "Order the evidence"
        case .label: return "Name the parts"
        }
    }

    // MARK: Below

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .mark:
            markPad
        case .decoy:
            if heardOnce, !revealed {
                HStack(spacing: 10) {
                    ChoiceTile(title: "A new section", symbol: "rectangle.split.2x1.fill", color: accent, selected: decoyPick == true) {
                        decoyPick = true
                    }
                    ChoiceTile(title: "Just a crash", symbol: "sparkle", color: GameStyle.chords, selected: decoyPick == false) {
                        decoyPick = false
                    }
                }
            }
        case .order:
            VStack(alignment: .leading, spacing: 10) {
                Text("Tap the cards in the order you heard them. Tap a card's speaker to hear it again.")
                    .font(.label(13, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                HStack(spacing: 10) {
                    ForEach(cardOrder, id: \.self) { i in
                        let placed = orderPicks.firstIndex(of: i)
                        VStack(spacing: 8) {
                            Button { preview(i) } label: {
                                Image(systemName: "speaker.wave.2.fill").font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity, minHeight: 34)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surfaceHigh))
                            }
                            .buttonStyle(.plain)
                            ChoiceTile(title: song[i].name, symbol: placed.map { "\($0 + 1).circle.fill" }, color: Self.sectionColors[i % 5],
                                       selected: placed != nil) {
                                if let placed { orderPicks.remove(at: placed) } else { orderPicks.append(i) }
                                Haptics.select()
                            }
                        }
                    }
                }
            }
        case .label:
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { n in
                        ChoiceTile(title: Self.partNames[n], color: Self.sectionColors[n], selected: naming == n) {
                            naming = n
                            Haptics.select()
                        }
                    }
                }
                Text("Pick a name, then tap a part of your map.").font(.label(13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                HStack(spacing: 6) {
                    ForEach(Array(regions.enumerated()), id: \.offset) { r, _ in
                        Button {
                            if let naming { regionNames[r] = naming }
                            Haptics.thump()
                        } label: {
                            Text(regionNames[r].map { Self.partNames[$0] } ?? "Part \(r + 1)")
                                .font(.label(13, weight: .heavy))
                                .foregroundStyle(regionNames[r] != nil ? Theme.onBrand : Theme.text)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(RoundedRectangle(cornerRadius: 14)
                                    .fill(regionNames[r].map { Self.sectionColors[$0] } ?? Theme.surfaceHigh))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        case .evidence:
            EmptyView()
        }
    }

    /// The big MARK pad.
    private var markPad: some View {
        Button {
            guard playing, let p = clock.now() else { return }
            marks.append(p / 16)
            Haptics.thump()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "flag.fill").font(.system(size: 26, weight: .black))
                Text("MARK").font(.display(24))
            }
            .foregroundStyle(playing ? Theme.onBrand : Theme.textTertiary)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(playing ? accent : Theme.surfaceHigh))
        }
        .buttonStyle(.plain)
        .disabled(!playing)
    }

    // MARK: Sound

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        playing = false
        heardOnce = false
        revealed = false
        lanePick = nil
        decoyPick = nil
        orderPicks = []
        regionNames = [:]
        naming = nil
        flash = nil
        if case .label = round.mode {} else { marks = [] }
        cardOrder = Array(song.indices).shuffled()
        if cardOrder == Array(song.indices), song.count > 1 { cardOrder.reverse() }
    }

    private func playSong() {
        clock.reset(bpm: round.bpm)
        if case .mark = round.mode { marks = [] }
        transport.play(Pattern(), genre: genre, source: .user, bars: totalBars, bpm: round.bpm,
                       sequence: barPatterns, barsPerSection: 1)
        playing = true
        Haptics.tap()
    }

    private func preview(_ i: Int) {
        transport.play(song[i].pattern, genre: genre, source: .demo, bars: 1, bpm: round.bpm)
        playing = false
    }

    // MARK: Flow

    private var primaryTitle: String {
        if playing { return "Listening…" }
        switch round.mode {
        case .mark: return heardOnce ? (revealed ? "Play again" : "Reveal the map") : "Play the song"
        case .evidence: return heardOnce || lanePick != nil ? "Check" : "Play with the X-ray"
        case .decoy: return heardOnce ? "Check" : "Play the song"
        case .order: return heardOnce ? "Check the order" : "Play the song"
        case .label: return heardOnce ? "Check the names" : "Play the song"
        }
    }

    private var primaryEnabled: Bool {
        if playing { return false }
        switch round.mode {
        case .mark: return true
        case .evidence: return !(heardOnce || lanePick != nil) || lanePick != nil
        case .decoy: return !heardOnce || decoyPick != nil
        case .order: return !heardOnce || orderPicks.count == song.count
        case .label: return !heardOnce || regionNames.count == regions.count
        }
    }

    private func primary() {
        switch round.mode {
        case .mark:
            if !heardOnce || revealed {
                revealed = false
                playSong()
                return
            }
            judgeMarks()
        case .evidence:
            if !heardOnce && lanePick == nil { playSong(); return }
            let changed = (0..<4).filter { song[0].layers[$0] != song[min(1, song.count - 1)].layers[$0] }
            if let lanePick, changed.contains(lanePick) {
                let entered = song[min(1, song.count - 1)].layers[lanePick]
                game.pass(game.fails == 0 ? 1 : 0.7, "The \(Self.laneNames[lanePick].lowercased()) \(entered ? "came in" : "dropped out") right on the boundary. That's a section change.")
            } else {
                game.miss("That lane keeps going across the boundary. Look for a lane that starts or stops right there.")
                lanePick = nil
            }
        case .decoy(_, let real):
            if !heardOnce { playSong(); return }
            revealed = true
            if decoyPick == real {
                game.pass(game.fails == 0 ? 1 : 0.7, real ? "The crash came with new parts. A real change." : "Just a crash. The same parts kept playing before and after it.")
            } else {
                game.miss(real ? "Look at the X-ray: the parts changed at the crash, so it was a real boundary." : "The X-ray shows the same parts either side of the crash. A loud hit isn't a new section.")
                decoyPick = nil
            }
        case .order:
            if !heardOnce { playSong(); return }
            if orderPicks == Array(song.indices) {
                revealed = true
                game.pass(game.fails == 0 ? 1 : 0.7, "That's the order it played: \(song.map(\.name).joined(separator: ", ")).")
            } else {
                game.miss("Not quite. Hear each card again: which one is thin, which is full, which one winds down?")
                orderPicks = []
            }
        case .label:
            if !heardOnce { playSong(); return }
            let n = regions.count
            if regionNames[0] == 0, regionNames[n - 1] == 3 {
                revealed = true
                game.pass(1, "Your map: \((0..<n).map { Self.partNames[regionNames[$0] ?? 1] }.joined(separator: ", ")). That's how you heard the journey.")
            } else {
                game.miss("Start the map with Start and finish it with End. The middle is yours to name.")
            }
        }
    }

    private func judgeMarks() {
        var hit = Set<Int>()
        var extras = 0
        for m in marks {
            if let b = boundaries.first(where: { abs(Double($0) - m) <= 0.75 }) { hit.insert(b) } else { extras += 1 }
        }
        revealed = true
        let score = Double(hit.count) / Double(max(1, boundaries.count + max(0, extras - 1)))
        if hit.count == boundaries.count, extras <= 1 {
            game.pass(max(0.6, score), boundaries.count == 1 ? "Right on the change. The X-ray shows what came in." : "You found every boundary. The X-ray shows what changed at each one.")
        } else if hit.count < boundaries.count {
            game.miss("You caught \(hit.count) of \(boundaries.count). Listen for whole parts coming in or dropping out.", score: score)
        } else {
            game.miss("You found the changes, but marked a few spots where nothing changed. Mark only the big moments.", score: score)
        }
    }

    private func retry() {
        withAnimation { game.feedback = nil }
        revealed = false
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
