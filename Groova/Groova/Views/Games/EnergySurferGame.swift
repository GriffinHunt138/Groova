//
//  EnergySurferGame.swift
//  Groova
//
//  F5.2 Energy Surfer. The track is a wave you ride. Slide your finger up and down the stage to
//  move between five prepared levels, from chords alone up to everything at full tilt. Each move
//  lands on the next bar line, and your ride draws the song's energy curve behind you.
//

import Foundation
import QuartzCore
import SwiftUI

struct EnergySurferGame: View {
    let task: GameTask
    let rounds: [SurferRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let levelNames = ["Chords", "+ Hats", "+ Kick & bass", "+ Melody", "Everything"]
    static let narratives = ["Slow rise", "Surprise drop", "Two peaks"]
    static let narrativeShapes: [[Int]] = [[0, 1, 1, 2, 2, 3, 3, 4], [3, 3, 4, 4, 0, 0, 3, 4], [1, 3, 4, 2, 1, 3, 4, 1]]

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var level = 3
    @State private var playingLevel = 3
    @State private var recorded: [Int] = []
    @State private var playing = false
    @State private var auto: [Int]?
    @State private var heardRef = false
    @State private var previewedSparse = false
    @State private var sparseNext = false
    @State private var narrative: Int?
    @State private var arc: [Int] = []
    @State private var heardAB: Set<Int> = []
    @State private var ab: Int?
    @State private var done = false
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [SurferRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: SurferRound { rounds[min(game.index, rounds.count - 1)] }

    private var ghost: [Int]? {
        switch round.mode {
        case .follow(let p): return p
        case .match(let p): return done ? p : nil
        default: return nil
        }
    }

    private var bars: Int {
        switch round.mode {
        case .flat: return 4
        case .follow(let p), .match(let p): return p.count
        case .rest(let b), .ride(let b): return b
        case .narrative: return 8
        case .replay: return max(4, arc.count)
        }
    }

    private var hidesWave: Bool {
        if case .replay = round.mode { return true }
        if case .match = round.mode, auto != nil { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if case .narrative = round.mode { narrativePicker }
                    GameStage(height: 320) { stage }
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
            if !running, playing { finished() }
        }
        .onDisappear { transport.stop() }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: !playing)) { _ in
            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                let left: CGFloat = 16, right = w - 16, top: CGFloat = 50, bottom = h - 24
                let barW = (right - left) / CGFloat(max(1, bars))
                let yOf: (Double) -> CGFloat = { l in bottom - (bottom - top) * CGFloat((l + 0.5) / 5) }
                let pos = playing ? min(Double(bars), (clock.now() ?? 0) / 16) : -1
                ZStack(alignment: .topLeading) {
                    // Level bands.
                    ForEach(0..<5, id: \.self) { l in
                        Rectangle().fill(Color.white.opacity(l == level && !hidesWave ? 0.07 : 0.025))
                            .frame(width: right - left, height: (bottom - top) / 5 - 2)
                            .position(x: (left + right) / 2, y: yOf(Double(l)))
                        Text(Self.levelNames[l].uppercased()).font(.label(9, weight: .black)).tracking(0.6)
                            .foregroundStyle(GameStyle.nightDim.opacity(hidesWave ? 0 : 1))
                            .position(x: left + 50, y: yOf(Double(l)) - (bottom - top) / 10 + 9)
                    }
                    // Bar lines.
                    ForEach(0...bars, id: \.self) { b in
                        Rectangle().fill(Color.white.opacity(0.06)).frame(width: 1, height: bottom - top + 10)
                            .position(x: left + barW * CGFloat(b), y: (top + bottom) / 2)
                    }
                    if !hidesWave {
                        if let ghost {
                            wavePath(ghost, left: left, barW: barW, yOf: yOf)
                                .stroke(Theme.gold.opacity(0.75), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 6]))
                        }
                        let shown = recorded.filter { $0 >= 0 }
                        if !shown.isEmpty {
                            wavePath(shown, left: left, barW: barW, yOf: yOf)
                                .stroke(accent, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                .shadow(color: accent, radius: 8)
                        }
                        if playing || !recorded.isEmpty {
                            let x = left + barW * CGFloat(max(0, pos))
                            let y = yOf(Double(playing ? level : playingLevel))
                            Capsule().fill(Color.white).frame(width: 34, height: 12)
                                .rotationEffect(.degrees(-12))
                                .shadow(color: accent, radius: 10)
                                .position(x: playing ? x : left + barW * CGFloat(recorded.count), y: y)
                        }
                    }
                    if pos >= 0 {
                        Rectangle().fill(Color.white.opacity(0.4)).frame(width: 2, height: bottom - top + 14)
                            .position(x: left + barW * CGFloat(pos), y: (top + bottom) / 2)
                    }
                    HStack {
                        StageTag(text: tag, color: playing ? accent : GameStyle.nightDim)
                        Spacer()
                        if case .rest = round.mode {
                            Label("Volume locked", systemImage: "lock.fill").font(.label(11, weight: .black))
                                .foregroundStyle(GameStyle.nightDim)
                                .padding(.horizontal, 10).frame(height: 26)
                                .background(Capsule().fill(GameStyle.nightRaised))
                        }
                    }
                    .padding(14)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { d in
                    guard controllable else { return }
                    let l = Int(((bottom - d.location.y) / (bottom - top) * 5).rounded(.down))
                    let nl = min(4, max(0, l))
                    if nl != level {
                        level = nl
                        Haptics.select()
                    }
                })
            }
        }
    }

    private func wavePath(_ levels: [Int], left: CGFloat, barW: CGFloat, yOf: (Double) -> CGFloat) -> Path {
        var p = Path()
        for (i, l) in levels.enumerated() {
            let y = yOf(Double(l))
            let x0 = left + barW * CGFloat(i), x1 = x0 + barW
            if i == 0 {
                p.move(to: CGPoint(x: x0, y: y))
            } else {
                let prev = p.currentPoint ?? CGPoint(x: x0, y: y)
                p.addCurve(to: CGPoint(x: x0 + barW * 0.25, y: y), control1: CGPoint(x: prev.x + barW * 0.15, y: prev.y),
                           control2: CGPoint(x: x0 + barW * 0.1, y: y))
            }
            p.addLine(to: CGPoint(x: x1 - barW * 0.05, y: y))
        }
        return p
    }

    private var controllable: Bool {
        if auto != nil { return false }
        switch round.mode {
        case .flat, .narrative, .replay: return false
        default: return true
        }
    }

    private var tag: String {
        if auto != nil { return hidesWave ? "Listen" : "Reference" }
        switch round.mode {
        case .flat: return sparseNext ? "Sparse next bar" : "Flat"
        case .replay: return ab == 0 ? "Flat loop" : ab == 1 ? "Your arc" : "Blind replay"
        default:
            if playing { return "Bar \(min(bars, clock.bar + 1)) of \(bars)" }
            return recorded.isEmpty ? "Slide up and down to ride" : "Your ride"
        }
    }

    // MARK: Below

    private var narrativePicker: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                Button {
                    narrative = i
                    Haptics.select()
                    play(auto: Self.narrativeShapes[i])
                } label: {
                    VStack(spacing: 8) {
                        GeometryReader { g in
                            let shape = Self.narrativeShapes[i]
                            Path { p in
                                for (k, l) in shape.enumerated() {
                                    let pt = CGPoint(x: g.size.width * CGFloat(k) / CGFloat(shape.count - 1),
                                                     y: g.size.height * (1 - CGFloat(l) / 4))
                                    if k == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                                }
                            }
                            .stroke(narrative == i ? Theme.onBrand : accent, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        }
                        .frame(height: 36)
                        Text(Self.narratives[i]).font(.label(13, weight: .heavy))
                    }
                    .foregroundStyle(narrative == i ? Theme.onBrand : Theme.text)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 18).fill(narrative == i ? accent : Theme.surfaceHigh))
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .flat:
            Button {
                sparseNext = true
                previewedSparse = true
                if !playing { play() }
                Haptics.tap()
            } label: {
                Label("Preview the sparse version", systemImage: "chart.line.downtrend.xyaxis").frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: sparseNext ? Theme.gold : Theme.surfaceHigh, textColor: Theme.text, height: 52))
        case .match(let p):
            Button { play(auto: p) } label: {
                Label(heardRef ? "Hear the reference again" : "Hear the reference", systemImage: "ear").frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
            .disabled(playing)
        case .replay:
            ABSwitch(a: "Flat loop", b: "Your arc", current: playing ? ab : nil) { i in
                ab = i
                heardAB.insert(i)
                play(auto: i == 0 ? Array(repeating: 3, count: bars) : arc)
            }
        default:
            EmptyView()
        }
    }

    // MARK: Sound

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        recorded = []
        auto = nil
        heardRef = false
        previewedSparse = false
        sparseNext = false
        heardAB = []
        ab = nil
        done = false
        switch round.mode {
        case .follow(let p), .match(let p): level = p.first ?? 1
        case .rest: level = 4
        case .ride: level = 1
        default: level = 3
        }
        if arc.isEmpty, let saved = GoldShelf.load(GoldShelf.arc) { arc = saved.map { Int($0) } }
        if arc.isEmpty { arc = Self.narrativeShapes[narrative ?? 0] }
    }

    private func play(auto path: [Int]? = nil) {
        auto = path
        let start = path?.first ?? level
        playingLevel = start
        if path == nil { recorded = Array(repeating: -1, count: bars); recorded[0] = start } else { recorded = [] }
        clock.reset(bpm: round.bpm)
        transport.play(SongKit.energy(start), genre: genre, source: .user, bars: path?.count ?? bars, bpm: round.bpm)
        playing = true
    }

    private func onStep(_ s: Int) {
        let step = s % 16
        let bar = clock.bar
        if step == 0, auto == nil, bar < recorded.count {
            recorded[bar] = playingLevel
        }
        guard step == 15 else { return }
        var nextLevel: Int
        if let auto {
            nextLevel = auto[min(auto.count - 1, bar + 1)]
            level = nextLevel
        } else if case .flat = round.mode {
            nextLevel = sparseNext ? 1 : 3
            if playingLevel == 1 { sparseNext = false; nextLevel = 3 }
            level = nextLevel
        } else {
            nextLevel = level
        }
        playingLevel = nextLevel
        transport.liveUpdate(SongKit.energy(nextLevel))
    }

    private func finished() {
        playing = false
        if auto != nil {
            if case .match = round.mode { heardRef = true }
            auto = nil
        }
    }

    // MARK: Flow

    private var primaryTitle: String {
        if playing { return auto != nil ? "Listening…" : "Riding…" }
        switch round.mode {
        case .flat: return previewedSparse ? "I hear the contrast" : "Play the loop"
        case .follow, .rest, .ride: return recorded.isEmpty ? "Start riding" : "Check my ride"
        case .match: return recorded.isEmpty ? "Ride from memory" : "Check my ride"
        case .narrative: return "Ride this story"
        case .replay: return "Keep my arc"
        }
    }

    private var primaryEnabled: Bool {
        if playing { return false }
        switch round.mode {
        case .flat: return true
        case .match: return heardRef
        case .narrative: return narrative != nil
        case .replay: return heardAB.count == 2
        default: return true
        }
    }

    private func primary() {
        switch round.mode {
        case .flat:
            if !previewedSparse { play(); return }
            transport.stop()
            game.pass(1, "Full all the time feels flat. A sparse bar makes the full one hit harder when it comes back.")
        case .follow(let p), .match(let p):
            if recorded.isEmpty { play(); return }
            let right = zip(recorded, p).filter { $0 == $1 }.count
            let near = zip(recorded, p).filter { abs($0 - $1) == 1 }.count
            let score = (Double(right) + Double(near) * 0.5) / Double(p.count)
            done = true
            if score >= 0.7 {
                game.pass(score, "Your ride follows the shape. Same music, and the energy rose and fell where it should.")
            } else {
                game.miss("Your ride drifted from the path. Watch the gold line and move just before each bar.", score: score)
                recorded = []
            }
        case .rest(let b):
            if recorded.isEmpty { play(); return }
            let middle = recorded.dropFirst().dropLast()
            let rested = middle.contains { $0 >= 0 && $0 <= 1 }
            let back = (recorded.last ?? 0) >= 3
            if rested && back {
                game.pass(1, "You carved out a rest, and the return lands like a new arrival. No volume knob needed.")
            } else if !rested {
                game.miss("It never gets a breath. Drop down to the chords for a bar or two before the end.")
                recorded = []
            } else {
                game.miss("Nice rest. Now bring everything back for the last of the \(b) bars.")
                recorded = []
            }
        case .narrative:
            transport.stop()
            game.pass(1, "\(Self.narratives[narrative ?? 0]) it is. Now ride it yourself. It doesn't have to match exactly.")
        case .ride:
            if recorded.isEmpty { play(); return }
            let lv = recorded.filter { $0 >= 0 }
            guard let lo = lv.min(), let hi = lv.max(), hi - lo >= 2 else {
                game.miss("Your ride stayed almost level. Give it real highs and lows.")
                recorded = []
                return
            }
            arc = lv
            GoldShelf.save(GoldShelf.arc, lv.map(Double.init))
            game.pass(1, "That's your arc. Next, hear it without the picture.")
        case .replay:
            transport.stop()
            GoldShelf.save(GoldShelf.arc, arc.map(Double.init))
            game.pass(1, "Saved your performed arc. Same loop as the flat version, a completely different journey.")
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
