//
//  ChordImpostorGame.swift
//  Groova
//
//  F3.2 Chord Impostor. A shell game for your ears. A line of cups each hides a chord, and one
//  of them has a different third. Cups lift as their chord plays; tap to hear one again, then
//  catch the impostor. Inside each cup three ribbons show root, third and fifth.
//

import Foundation
import SwiftUI

struct ChordImpostorGame: View {
    let task: GameTask
    let rounds: [ImpostorRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, listening, playing, done }

    @State private var game: GameProgress
    @State private var phase: Phase = .ready
    @State private var cups: [Triad] = []
    @State private var lifted: Int?
    @State private var selected: Int?
    @State private var caught: Int?
    @State private var flips = 0
    @State private var reveal = false
    @State private var phrase: [Triad] = [.c, .am, .f, .g]
    @State private var twisted: [Triad] = []
    @State private var runner: Task<Void, Never>?
    @Environment(\.accent) private var accent

    private let patch = SynthPatch.keys

    init(task: GameTask, rounds: [ImpostorRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: ImpostorRound { rounds[min(game.index, rounds.count - 1)] }
    private var isReverse: Bool { if case .reverse = round.mode { return true }; return false }
    private var gap: Double { 60 / round.bpm * 2 }

    /// The odd one out: the only cup whose quality differs from the rest.
    private func odd(_ t: [Triad]) -> Int? {
        let minors = t.filter(\.minor).count
        let wantMinor = minors * 2 <= t.count
        return t.firstIndex { $0.minor == wantMinor }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if case .choose(let options) = round.mode, phase != .done { phrasePicker(options) }
                    GameStage(height: 330) { stage }
                    if phase == .playing || phase == .done { extras }
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
        .onDisappear { runner?.cancel() }
    }

    private var primaryTitle: String {
        switch phase {
        case .ready:
            switch round.mode {
            case .choose: return "Keep this phrase"
            case .reveal: return "Perform the reveal"
            case .morph, .twist: return "Start"
            default: return "Shuffle the cups"
            }
        case .listening: return "Listen…"
        case .done: return "Done"
        case .playing:
            switch round.mode {
            case .morph: return flips >= 2 ? "I hear the change" : "Flip the third"
            case .twist: return "Lock the twist"
            case .reverse: return caught == nil ? "Catch the impostor" : "Flip it back"
            default: return "Catch the impostor"
            }
        }
    }

    private var primaryEnabled: Bool {
        switch phase {
        case .ready: return true
        case .playing:
            switch round.mode {
            case .morph: return flips >= 2
            case .twist: return zip(twisted, phrase).filter { $0 != $1 }.count == 1
            case .reverse: return caught == nil ? selected != nil : false
            default: return selected != nil
            }
        default: return false
        }
    }

    // MARK: Stage

    private var stage: some View {
        VStack(spacing: 14) {
            HStack {
                StageTag(text: tag, color: phase == .playing ? accent : GameStyle.nightDim)
                Spacer()
                if case .edit = round.mode, phase != .ready { StageTag(text: "Version B") }
            }
            Spacer(minLength: 0)
            if case .morph = round.mode {
                if let t = cups.first { bigCup(t) }
            } else {
                HStack(spacing: 8) {
                    ForEach(Array(cups.enumerated()), id: \.offset) { i, t in cup(i, t) }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }

    private var tag: String {
        switch phase {
        case .ready: return task.name
        case .listening: return "Watch the cups"
        case .done: return reveal ? "Revealed" : "Caught"
        case .playing:
            switch round.mode {
            case .morph: return "Swipe the middle ribbon"
            case .twist: return "Tap one cup to twist it"
            case .reverse where caught != nil: return "Flip the lever"
            default: return "Tap to hear, then catch"
            }
        }
    }

    private func cup(_ i: Int, _ t: Triad) -> some View {
        let up = lifted == i
        let sel = selected == i
        let showName = phase == .done || reveal || round.mode == .twist || isPhraseMode
        let highlight = (phase == .done && odd(cups) == i) || (round.mode == .twist && twisted.indices.contains(i) && twisted[i] != phrase[i])
        return VStack(spacing: 8) {
            ribbons(t, compact: true, glowThird: highlight)
                .frame(height: 74)
            Text(showName ? t.name : "\(i + 1)")
                .font(.display(showName ? 17 : 20))
                .foregroundStyle(GameStyle.nightText)
            if isReverse, caught == i, phase == .playing {
                Button { flip(i) } label: {
                    Image(systemName: "arrow.up.arrow.down").font(.system(size: 14, weight: .black))
                        .frame(width: 40, height: 30)
                        .background(Capsule().fill(Theme.gold))
                        .foregroundStyle(Color.black.opacity(0.8))
                }
                .buttonStyle(PressScaleStyle(scale: 0.9))
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(GameStyle.nightRaised))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(sel ? accent : (highlight ? Theme.gold : GameStyle.nightLine), lineWidth: sel || highlight ? 3 : 2))
        .offset(y: up ? -18 : 0)
        .shadow(color: up ? accent.opacity(0.7) : .clear, radius: 16)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: up)
        .contentShape(Rectangle())
        .onTapGesture { tapCup(i) }
        .accessibilityLabel(showName ? t.name : "Cup \(i + 1)")
        .accessibilityAddTraits(.isButton)
    }

    private var isPhraseMode: Bool {
        switch round.mode {
        case .choose, .twist, .reveal: return true
        default: return false
        }
    }

    /// Root, third and fifth as three ribbons. The third sits lower when it's minor.
    private func ribbons(_ t: Triad, compact: Bool, glowThird: Bool) -> some View {
        GeometryReader { geo in
            let h = geo.size.height, w = geo.size.width
            let y: (Int) -> CGFloat = { semis in h - h * CGFloat(semis) / 8 - 4 }
            ZStack {
                ForEach(0..<3, id: \.self) { v in
                    let semis = [0, t.minor ? 3 : 4, 7][v]
                    let color = [GameStyle.kick, glowThird ? Theme.gold : GameStyle.snare, GameStyle.hat][v]
                    Capsule().fill(color)
                        .frame(width: w * (compact ? 0.7 : 0.6), height: compact ? 8 : 18)
                        .shadow(color: v == 1 && glowThird ? Theme.gold : .clear, radius: 10)
                        .position(x: w / 2, y: y(semis))
                        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: t.minor)
                }
            }
        }
    }

    private func bigCup(_ t: Triad) -> some View {
        VStack(spacing: 12) {
            ribbons(t, compact: false, glowThird: true)
                .frame(height: 170)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 14).onEnded { v in
                    let down = v.translation.height > 0
                    if down != t.minor { flip(0) }
                })
                .onTapGesture { flip(0) }
            Text(t.name).font(.display(34)).foregroundStyle(GameStyle.nightText).contentTransition(.numericText())
            Text(t.minor ? "Third lowered: minor" : "Third up: major")
                .font(.label(13, weight: .bold)).foregroundStyle(GameStyle.nightDim)
        }
        .padding(.horizontal, 40)
    }

    // MARK: Extras

    @ViewBuilder private var extras: some View {
        switch round.mode {
        case .lineup, .edit, .reverse:
            Button { play(cups) } label: { Label("Play the line-up again", systemImage: "play.fill").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
        case .twist:
            HStack(spacing: 10) {
                Button { play(phrase) } label: { Label("Pass 1", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                Button { play(twisted) } label: { Label("Pass 2", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
            }
        default:
            EmptyView()
        }
    }

    private func phrasePicker(_ options: [[Triad]]) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, p in
                Button {
                    Haptics.select()
                    phrase = p
                    cups = p
                    play(p)
                } label: {
                    Label(p.map(\.name).joined(separator: " → "), systemImage: "play.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: phrase == p ? accent : Theme.surfaceHigh,
                                               textColor: phrase == p ? Theme.onBrand : Theme.text, height: 50))
            }
        }
    }

    // MARK: Sound

    private func sound(_ t: Triad, seconds: Double? = nil) {
        AudioEngine.shared.playChord(t.pitches + [t.root - 12], seconds: seconds ?? gap * 0.9, patch: patch)
    }

    private func play(_ line: [Triad], then: (() -> Void)? = nil) {
        runner?.cancel()
        let g = gap
        runner = Task {
            for (i, t) in line.enumerated() {
                if Task.isCancelled { return }
                withAnimation { lifted = i }
                sound(t)
                try? await Task.sleep(for: .milliseconds(Int(g * 1000)))
            }
            withAnimation { lifted = nil }
            if !Task.isCancelled { then?() }
        }
    }

    private func tapCup(_ i: Int) {
        guard i < cups.count else { return }
        Haptics.tap()
        if round.mode == .twist, phase == .playing {
            // Tap a cup to twist its third. Only one may change.
            twisted[i] = twisted[i] == phrase[i] ? phrase[i].flipped : phrase[i]
            cups = twisted
            sound(cups[i])
            return
        }
        sound(cups[i])
        withAnimation { lifted = i }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            if lifted == i { withAnimation { lifted = nil } }
        }
        if phase == .playing, caught == nil { withAnimation { selected = i } }
    }

    private func flip(_ i: Int) {
        guard phase == .playing, i < cups.count else { return }
        Haptics.thump()
        withAnimation { cups[i] = cups[i].flipped }
        sound(cups[i], seconds: 1.2)
        flips += 1
        if isReverse, odd(cups) == nil {
            withAnimation { phase = .done }
            game.pass(1, "Flipped back. One note, the third, turned it from \(cups[i].minor ? "major to minor" : "minor to major").")
            play(cups)
        }
    }

    // MARK: Flow

    private func primary() {
        if phase == .ready { start(); return }
        switch round.mode {
        case .morph:
            finish("Only the middle note moved, one step. That one step is the whole difference between major and minor.")
        case .twist:
            withAnimation { phase = .done }
            game.pass(1, "Your twist is planted. Same phrase, one chord with a different third.", title: "Twisted")
        default:
            guard let s = selected else { return }
            let answer: Int? = {
                if case .edit(let a, let b) = round.mode { return zip(a, b).enumerated().first { $0.element.0 != $0.element.1 }?.offset }
                return odd(cups)
            }()
            if s == answer {
                if isReverse {
                    caught = s
                    Haptics.success()
                    return
                }
                finish("Cup \(s + 1) was the impostor: \(cups[s].name). Only its third was different.")
            } else {
                game.miss("Not that cup. Listen for the one that feels darker or brighter than the rest.", score: 0.4)
                withAnimation { phase = .done; reveal = true }
            }
        }
    }

    private func start() {
        selected = nil
        caught = nil
        flips = 0
        reveal = false
        switch round.mode {
        case .morph(let t):
            cups = [t]
            withAnimation { phase = .playing }
            sound(t, seconds: 1.2)
        case .lineup(let t), .reverse(let t):
            cups = t
            phase = .listening
            play(t) { withAnimation { phase = .playing } }
        case .edit(let a, let b):
            cups = b
            phase = .listening
            play(a) {
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    play(b) { withAnimation { phase = .playing } }
                }
            }
        case .choose:
            cups = phrase
            withAnimation { phase = .done }
            game.pass(1, "Your phrase: \(phrase.map(\.name).joined(separator: " → ")).", title: "Phrase chosen")
            play(phrase)
        case .twist:
            twisted = phrase
            cups = phrase
            withAnimation { phase = .playing }
            play(phrase)
        case .reveal:
            let twist = twisted.isEmpty ? phrase : twisted
            cups = phrase
            reveal = true
            phase = .listening
            play(phrase) {
                cups = twist
                play(twist) {
                    withAnimation { phase = .done }
                    game.pass(1, "Original, then the twist. One flipped third changes the story the chords tell.", title: "The reveal")
                }
            }
        }
    }

    private func finish(_ msg: String) {
        withAnimation { phase = .done; reveal = true }
        game.pass(1, msg)
        play(cups)
    }

    private func retry() {
        runner?.cancel()
        withAnimation {
            game.feedback = nil
            phase = .ready
            reveal = false
        }
    }

    private func next() {
        runner?.cancel()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            reveal = false
            selected = nil
            caught = nil
        }
    }
}
