//
//  SongJigsawGame.swift
//  Groova
//
//  F5.4 Song Jigsaw. Each section of a song is a big audio postcard. Flip one to hear it, drop
//  postcards into the frame to build the song, and play it through while the card that's
//  playing glows. Whole sections, not notes: this is arranging.
//

import Foundation
import QuartzCore
import SwiftUI

struct SongJigsawGame: View {
    let task: GameTask
    let cards: [SongSection]
    let rounds: [JigsawRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let colors: [Color] = [GameStyle.chords, GameStyle.kick, Color(hex: 0x5CE0B8), GameStyle.lead, GameStyle.snare, Color(hex: 0xFF8A3D)]
    static let symbols = ["sunrise.fill", "flame.fill", "sparkles", "moon.stars.fill", "waveform.path", "bolt.fill"]

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var slots: [Int?] = []
    @State private var flipped: Set<Int> = []
    @State private var heard: Set<Int> = []
    @State private var playingCard: Int?
    @State private var playingSong = false
    @State private var selectedSlot: Int?
    @State private var selectedCard: Int?
    @State private var storyA: [Int]?
    @State private var heardAB: Set<Int> = []
    @State private var playedThrough = false
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, cards: [SongSection], rounds: [JigsawRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.cards = cards
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: JigsawRound { rounds[min(game.index, rounds.count - 1)] }

    private var hidesNames: Bool {
        if case .assemble(_, let show) = round.mode { return !show }
        return false
    }

    private var placed: [Int] { slots.compactMap { $0 } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 230) { tray }
                    if showsFrame { frame }
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
            guard playingSong else { return }
            clock.follow(s)
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running {
                if playingSong { playedThrough = true }
                playingSong = false
                playingCard = nil
            }
        }
        .onDisappear { transport.stop() }
    }

    private var showsFrame: Bool {
        if case .preview = round.mode { return false }
        return true
    }

    // MARK: Tray

    private var tray: some View {
        let cols = cards.count > 4 ? 3 : 2
        return VStack(spacing: 10) {
            ForEach(0..<Int((Double(cards.count) / Double(cols)).rounded(.up)), id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<cols, id: \.self) { c in
                        let i = row * cols + c
                        if i < cards.count {
                            postcard(i)
                        } else {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(12)
    }

    private func postcard(_ i: Int) -> some View {
        let isFlipped = flipped.contains(i)
        let isPlaying = playingCard == i || (playingSong && activeCard == i)
        let color = Self.colors[i % Self.colors.count]
        return Button { tapCard(i) } label: {
            ZStack {
                // Front.
                VStack(spacing: 4) {
                    Image(systemName: hidesNames ? "questionmark" : Self.symbols[i % Self.symbols.count])
                        .font(.system(size: 20, weight: .black))
                    Text(hidesNames ? "Card \(["A", "B", "C", "D", "E", "F"][i % 6])" : cards[i].name)
                        .font(.label(13, weight: .heavy))
                }
                .foregroundStyle(.white)
                .opacity(isFlipped ? 0 : 1)
                // Back: the section's layers.
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { l in
                        Capsule().fill(cards[i].layers[l] ? Color.white : Color.white.opacity(0.15))
                            .frame(width: 6, height: isPlaying ? 30 : 18)
                    }
                }
                .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
                .opacity(isFlipped ? 1 : 0)
            }
            .frame(maxWidth: .infinity, minHeight: 88)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [color, color.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(selectedCard == i ? Color.white : (isPlaying ? Theme.gold : .clear), lineWidth: 3))
            .shadow(color: isPlaying ? color : .clear, radius: 12)
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (0, 1, 0), perspective: 0.6)
            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isFlipped)
        }
        .buttonStyle(.plain)
    }

    // MARK: Frame

    private var activeSlot: Int? {
        guard playingSong, previewOrder == nil else { return nil }
        return activeIndex(in: placed)
    }

    private func activeIndex(in order: [Int]) -> Int? {
        guard playingSong, let p = clock.now() else { return nil }
        let bar = Int(p / 16)
        var at = 0
        for (k, c) in order.enumerated() {
            if bar < at + cards[c].bars { return k }
            at += cards[c].bars
        }
        return nil
    }

    private var activeCard: Int? {
        let order = previewOrder ?? placed
        return activeIndex(in: order).map { order[$0] }
    }

    private var frame: some View {
        TimelineView(.animation(paused: !playingSong)) { _ in
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR SONG").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
                HStack(spacing: 6) {
                    ForEach(slots.indices, id: \.self) { k in
                        slotView(k)
                    }
                }
            }
            .card(padding: 14)
        }
    }

    private func slotView(_ k: Int) -> some View {
        let c = slots[k]
        let on = activeSlot != nil && slotIndexInPlaced(k) == activeSlot
        let label: String = {
            if case .assemble(let order, true) = round.mode, k < order.count, c == nil { return cards[order[k]].name }
            return c.map { hidesNames ? ["A", "B", "C", "D", "E", "F"][$0 % 6] : cards[$0].name } ?? "\(k + 1)"
        }()
        return Button { tapSlot(k) } label: {
            Text(label)
                .font(.label(12, weight: .heavy))
                .lineLimit(1).minimumScaleFactor(0.6)
                .foregroundStyle(c == nil ? Theme.textTertiary : .white)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(RoundedRectangle(cornerRadius: 14)
                    .fill(c.map { Self.colors[$0 % Self.colors.count] } ?? Theme.surfaceHigh))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(selectedSlot == k ? accent : (on ? Theme.gold : .clear), lineWidth: 3))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Theme.textTertiary.opacity(c == nil ? 0.5 : 0), style: StrokeStyle(lineWidth: 2, dash: [4, 4])))
                .scaleEffect(on ? 1.06 : 1)
                .shadow(color: on ? Theme.gold.opacity(0.7) : .clear, radius: 10)
        }
        .buttonStyle(.plain)
    }

    private func slotIndexInPlaced(_ k: Int) -> Int? {
        guard slots[k] != nil else { return nil }
        return slots.prefix(k).compactMap { $0 }.count
    }

    // MARK: Below

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .assemble(let order, let show):
            HStack(spacing: 10) {
                if !show {
                    Button { playSong(order) } label: { Label("Hear the reference", systemImage: "ear").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                }
                if placed.count == slots.count {
                    Button { playSong(placed) } label: { Label("Play mine", systemImage: "play.fill").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                }
            }
        case .story, .duplicate:
            if placed.count >= 2 {
                Button { playSong(placed) } label: { Label("Play the song", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
            }
        case .versionB:
            VStack(spacing: 10) {
                Text("Tap two cards in your song to swap them, or tap a postcard then a slot to replace one.")
                    .font(.label(13, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                ABSwitch(a: "Version A", b: "Version B", current: nil) { i in
                    heardAB.insert(i)
                    playSong(i == 0 ? (storyA ?? placed) : placed)
                }
            }
        default:
            EmptyView()
        }
    }

    // MARK: Interaction

    private func tapCard(_ i: Int) {
        Haptics.tap()
        withAnimation { _ = flipped.insert(i) }
        heard.insert(i)
        playingSong = false
        playingCard = i
        transport.play(cards[i].pattern, genre: genre, source: .demo, bars: min(2, cards[i].bars), bpm: round.bpm)
        switch round.mode {
        case .preview:
            break
        case .duplicate, .versionB:
            selectedCard = i
        default:
            if let k = slots.firstIndex(where: { $0 == nil }) {
                withAnimation(.spring(response: 0.35)) { slots[k] = i }
                Haptics.thump()
            }
        }
    }

    private func tapSlot(_ k: Int) {
        Haptics.select()
        if let card = selectedCard {
            withAnimation(.spring(response: 0.35)) { slots[k] = card }
            selectedCard = nil
            replaced = k
            return
        }
        switch round.mode {
        case .story, .versionB:
            if let s = selectedSlot {
                if s == k {
                    if case .story = round.mode { withAnimation { slots[k] = nil } }
                } else {
                    withAnimation(.spring(response: 0.35)) { slots.swapAt(s, k) }
                }
                selectedSlot = nil
            } else if slots[k] != nil {
                selectedSlot = k
            }
        case .assemble:
            withAnimation { slots[k] = nil }
        default:
            break
        }
    }

    @State private var replaced: Int?

    private func playSong(_ order: [Int]) {
        guard !order.isEmpty else { return }
        let sections = order.map { cards[$0] }
        let total = sections.reduce(0) { $0 + $1.bars }
        clock.reset(bpm: round.bpm)
        if order != placed { previewOrder = order } else { previewOrder = nil }
        transport.play(Pattern(), genre: genre, source: .user, bars: total, bpm: round.bpm,
                       sequence: SongKit.bars(sections), barsPerSection: 1)
        playingCard = nil
        playingSong = true
        Haptics.tap()
    }

    @State private var previewOrder: [Int]?

    // MARK: Flow

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        flipped = []
        heard = []
        selectedSlot = nil
        selectedCard = nil
        heardAB = []
        playedThrough = false
        replaced = nil
        switch round.mode {
        case .preview: slots = []
        case .assemble(let order, _): slots = Array(repeating: nil, count: order.count)
        case .duplicate(let draft, _): slots = draft.map { Optional($0) }
        case .playthrough(let order): slots = order.map { Optional($0) }
        case .story: slots = Array(repeating: nil, count: 5)
        case .versionB: slots = (storyA ?? Array(cards.indices.prefix(4))).map { Optional($0) }
        }
    }

    private var primaryTitle: String {
        switch round.mode {
        case .preview: return "I've heard every card"
        case .assemble: return "Check the song"
        case .duplicate: return "Keep the change"
        case .playthrough: return playingSong ? "Playing…" : (playedThrough ? "That's a song" : "Play it through")
        case .story: return "Save my story"
        case .versionB: return "Keep version B"
        }
    }

    private var primaryEnabled: Bool {
        switch round.mode {
        case .preview: return heard.count >= cards.count
        case .assemble: return placed.count == slots.count
        case .duplicate: return replaced != nil
        case .playthrough: return !playingSong
        case .story: return placed.count >= 4
        case .versionB: return heardAB.count == 2
        }
    }

    private func primary() {
        switch round.mode {
        case .preview:
            transport.stop()
            game.pass(1, "Every postcard has its own job. Some open, some build, one finishes.")
        case .assemble(let order, _):
            if placed == order {
                playSong(placed)
                game.pass(game.fails == 0 ? 1 : 0.7, "That's the song. Each card lands on a bar line, so it plays as one piece.")
            } else {
                let right = zip(placed, order).filter { $0 == $1 }.count
                game.miss("\(right) of \(order.count) are in the right place. Listen for which card opens quietly and which one winds down.",
                          score: Double(right) / Double(order.count))
            }
        case .duplicate(let draft, let fresh):
            guard let k = replaced, slots[k] == fresh else {
                game.miss("Tap the new postcard, then tap one of the repeats to replace it.")
                return
            }
            if draft.filter({ $0 == draft[k] }).count >= 2 {
                playSong(placed)
                game.pass(game.fails == 0 ? 1 : 0.7, "One repeat became a variation, and the song stopped going round in circles.")
            } else {
                game.miss("That card only appeared once. Replace one of the repeats instead.")
                slots = draft.map { Optional($0) }
                replaced = nil
            }
        case .playthrough(let order):
            if !playedThrough {
                playSong(order)
                return
            }
            game.pass(1, "Start to finish, no gaps. A handful of postcards in the right order is a whole song.")
        case .story:
            let order = placed
            let names = order.map { cards[$0].name.lowercased() }
            if !(names.first?.contains("intro") ?? false) {
                game.miss("Open your story with the intro card.")
            } else if !(names.last?.contains("outro") ?? false) {
                game.miss("Finish with the outro so the song has an ending.")
            } else if !names.contains(where: { $0.contains("break") || $0.contains("variation") }) {
                game.miss("Add a contrasting card, the break or the variation, so something changes.")
            } else if zip(order, order.dropFirst()).contains(where: { $0 == $1 }) {
                game.miss("Two of the same card sit side by side. Swap one so neighbours differ.")
            } else {
                storyA = order
                GoldShelf.save(GoldShelf.song, order.map(Double.init))
                game.pass(1, "Your story: \(order.map { cards[$0].name }.joined(separator: ", ")). Next, make a version B.")
            }
        case .versionB:
            guard placed != storyA else {
                game.miss("Version B is the same as A. Swap two cards or replace one.")
                return
            }
            transport.stop()
            GoldShelf.save(GoldShelf.song, placed.map(Double.init))
            game.pass(1, "Saved version B. Same cards, a different story.")
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
