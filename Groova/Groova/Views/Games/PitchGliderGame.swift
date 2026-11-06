//
//  PitchGliderGame.swift
//  Groova
//
//  F2.1 Pitch Glider. A little glowing glider drifts left to right through the dark. Slide your
//  finger up and down and it climbs and dives, singing the pitch it's at. No keys, no note names:
//  you follow the shape you hear, and Gold turns your flight path into a melody.
//

import Foundation
import QuartzCore
import SwiftUI

struct PitchGliderGame: View {
    let task: GameTask
    let rounds: [GliderRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, listening, flying, done }
    private struct Mark: Equatable { var x: Double; var row: Int }

    /// C major from C4 to C5, low to high.
    static let rows = [60, 62, 64, 65, 67, 69, 71, 72]

    @State private var game: GameProgress
    @State private var phase: Phase = .ready
    @State private var row = 3
    @State private var userRow = 3
    @State private var flightStart: Double?
    @State private var flightBeats = 4
    @State private var autoUntil = 0
    @State private var reference: [Int] = []
    @State private var path: [Mark] = []
    @State private var refPath: [Mark] = []
    @State private var sampled: [Int] = []
    @State private var drawn: [Int] = []
    @State private var drawnB: [Int] = []
    @State private var matchedBeats = 0
    @State private var backing = 0
    @State private var runner: Task<Void, Never>?
    @Environment(\.accent) private var accent

    private let patch = SynthPatch.keys
    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [GliderRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: GliderRound { rounds[min(game.index, rounds.count - 1)] }
    private var beat: Double { 60 / round.bpm }

    private func rowOf(_ midi: Int) -> Int {
        Self.rows.enumerated().min { abs($0.element - midi) < abs($1.element - midi) }?.offset ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 340) { stage }
                    if phase == .ready, round.mode == .showcase { backingPicker }
                    if phase == .done { afterFlight }
                }
                .padding(20)
            }
            StepFooter(feedback: game.feedback,
                       primaryTitle: primaryTitle,
                       primaryEnabled: phase == .ready,
                       onPrimary: start,
                       onContinue: next,
                       onRetry: retry,
                       helpTitle: game.canSkip ? "Skip round" : nil,
                       onHelp: { game.skip(); next() })
        }
        .onDisappear {
            runner?.cancel()
            transport.stop()
        }
    }

    private var primaryTitle: String {
        switch phase {
        case .listening: return "Listen…"
        case .flying: return "Fly!"
        case .done: return "Landed"
        case .ready:
            switch round.mode {
            case .draw: return "Take off"
            case .showcase: return "Play my flight"
            default: return "Listen, then fly"
            }
        }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase == .ready || phase == .done)) { _ in
            GeometryReader { geo in
                scene(size: geo.size, x: progress())
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0).onChanged { v in steer(y: v.location.y, h: geo.size.height) })
            }
        }
    }

    /// 0...1 across the flight, or nil before it starts.
    private func progress() -> Double? {
        guard let s = flightStart else { return nil }
        return max(0, min(1, (CACurrentMediaTime() - s) / (Double(flightBeats) * beat)))
    }

    private func y(_ r: Int, h: CGFloat) -> CGFloat {
        let top: CGFloat = 54, bottom = h - 34
        return bottom - (bottom - top) * CGFloat(r) / CGFloat(Self.rows.count - 1)
    }

    private func scene(size: CGSize, x: Double?) -> some View {
        let w = size.width, h = size.height
        let left: CGFloat = 30, right = w - 30
        let px: (Double) -> CGFloat = { left + (right - left) * CGFloat($0) }
        let showTrail: Bool = {
            if case .follow(let t) = round.mode { return t }
            return false
        }()
        let holdTarget: Int? = { if case .hold(let t) = round.mode { return t }; return nil }()
        let matched = holdTarget.map { Self.rows[userRow] == $0 } ?? false
        return ZStack(alignment: .topLeading) {
            // Faint altitude lines, no names.
            ForEach(0..<Self.rows.count, id: \.self) { r in
                Rectangle().fill(Color.white.opacity(r == 0 || r == Self.rows.count - 1 ? 0.08 : 0.04))
                    .frame(width: right - left, height: 1)
                    .position(x: (left + right) / 2, y: y(r, h: h))
            }
            // The ghost of the melody you heard.
            if !refPath.isEmpty, (showTrail && phase == .flying) || phase == .done || phase == .listening {
                trail(refPath, px: px, h: h)
                    .stroke(Color.white.opacity(phase == .listening ? 0.35 : 0.18),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
            }
            // Your path.
            if !path.isEmpty {
                trail(path, px: px, h: h)
                    .stroke(accent, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .shadow(color: accent, radius: 6)
            }
            // The glider.
            let gx = px(x ?? 0)
            let gy = y(phase == .flying && autoUntil <= beatIndex(x) ? userRow : row, h: h)
            Image(systemName: "paperplane.fill")
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(matched ? Theme.gold : Color.white)
                .shadow(color: matched ? Theme.gold : accent, radius: matched ? 18 : 10)
                .rotationEffect(.degrees(-10))
                .position(x: gx, y: gy)
                .animation(.spring(response: 0.18, dampingFraction: 0.75), value: gy)
            HStack {
                StageTag(text: tag, color: phase == .flying ? accent : GameStyle.nightDim)
                Spacer()
                if holdTarget != nil, phase == .flying {
                    StageTag(text: matched ? "Locked on" : "Searching", color: matched ? Theme.gold : GameStyle.nightDim)
                }
            }
            .padding(14)
        }
        .frame(width: w, height: h)
    }

    private var tag: String {
        switch phase {
        case .ready: return task.name
        case .listening: return "Listen"
        case .flying: return autoUntil > 0 && sampled.count < autoUntil ? "Your melody" : "Your flight"
        case .done: return "Landed"
        }
    }

    private func beatIndex(_ x: Double?) -> Int { Int((x ?? 0) * Double(flightBeats)) }

    private func trail(_ marks: [Mark], px: (Double) -> CGFloat, h: CGFloat) -> Path {
        Path { p in
            for (i, m) in marks.enumerated() {
                let pt = CGPoint(x: px(m.x), y: y(m.row, h: h))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
        }
    }

    // MARK: Below

    private var backingPicker: some View {
        HStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { i in
                Button {
                    Haptics.select()
                    backing = i
                } label: {
                    Label(i == 0 ? "Soft keys" : "Beat", systemImage: i == 0 ? "pianokeys" : "music.note").frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: backing == i ? accent : Theme.surfaceHigh,
                                               textColor: backing == i ? Theme.onBrand : Theme.text, height: 52))
            }
        }
    }

    @ViewBuilder private var afterFlight: some View {
        if round.mode == .redraw || round.mode == .showcase, !drawn.isEmpty, !drawnB.isEmpty {
            HStack(spacing: 10) {
                Button { playMelody(drawn) } label: { Label("Flight A", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
                Button { playMelody(drawnB) } label: { Label("Flight B", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
            }
            if round.mode == .showcase, game.feedback == nil {
                HStack(spacing: 10) {
                    Button { keep(drawn, "A") } label: { Text("Keep A").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 52))
                    Button { keep(drawnB, "B") } label: { Text("Keep B").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 52))
                }
            }
        } else if !sampled.isEmpty {
            Button { playMelody(sampled.map { Self.rows[$0] }) } label: {
                Label("Hear your flight", systemImage: "play.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 52))
        }
    }

    // MARK: Touch and sound

    private func steer(y: CGFloat, h: CGFloat) {
        guard phase == .flying else { return }
        if autoUntil > beatIndex(progress()) { return }
        let top: CGFloat = 54, bottom = h - 34
        let u = Double((bottom - y) / (bottom - top))
        let r = max(0, min(Self.rows.count - 1, Int((u * Double(Self.rows.count - 1)).rounded())))
        if r != userRow {
            userRow = r
            Haptics.select()
            AudioEngine.shared.playNote(Self.rows[r], seconds: beat * 0.7, patch: patch, velocity: 0.8)
        }
    }

    private func playMelody(_ notes: [Int]) {
        runner?.cancel()
        let b = beat
        runner = Task {
            for n in notes {
                if Task.isCancelled { return }
                AudioEngine.shared.playNote(n, seconds: b * 0.85, patch: patch)
                try? await Task.sleep(for: .milliseconds(Int(b * 1000)))
            }
        }
    }

    // MARK: Flow

    private func start() {
        runner?.cancel()
        path = []
        refPath = []
        sampled = []
        matchedBeats = 0
        autoUntil = 0
        switch round.mode {
        case .follow, .changed:
            reference = round.notes
            listenThenFly(round.notes)
        case .hold(let t):
            reference = [t]
            userRow = (rowOf(t) + 4) % Self.rows.count
            fly(beats: 10, guide: t)
        case .draw:
            reference = []
            fly(beats: 5)
        case .redraw:
            guard drawn.count >= 5 else { fly(beats: 5); return }
            autoUntil = 3
            fly(beats: 5, auto: drawn.map { rowOf($0) })
        case .showcase:
            let p: Pattern = backing == 0 ? Pattern(chords: [K.ch(0, .c, 7), K.ch(8, .am, 7)])
                                          : Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 6, 10, 14])
            transport.play(p, genre: genre, source: .reference, bars: nil, swing: 0, bpm: round.bpm)
            withAnimation { phase = .done }
            if drawnB.isEmpty { drawnB = drawn }
            playMelody(drawn)
        }
    }

    /// Hear the reference with the glider flying it, then take the controls.
    private func listenThenFly(_ notes: [Int]) {
        withAnimation { phase = .listening }
        var first: [Int] = []
        if case .changed(let f) = round.mode { first = f }
        let b = beat
        runner = Task {
            for phrase in (first.isEmpty ? [notes] : [first, notes]) {
                refPath = []
                flightBeats = phrase.count
                flightStart = CACurrentMediaTime()
                for (i, n) in phrase.enumerated() {
                    if Task.isCancelled { return }
                    let r = rowOf(n)
                    row = r
                    refPath.append(Mark(x: Double(i) / Double(phrase.count), row: r))
                    refPath.append(Mark(x: Double(i + 1) / Double(phrase.count) - 0.001, row: r))
                    AudioEngine.shared.playNote(n, seconds: b * 0.85, patch: patch)
                    try? await Task.sleep(for: .milliseconds(Int(b * 1000)))
                }
                try? await Task.sleep(for: .milliseconds(Int(b * 500)))
            }
            if Task.isCancelled { return }
            fly(beats: notes.count)
        }
    }

    /// Your flight: the glider crosses the screen and samples where you hold it once per beat.
    private func fly(beats: Int, guide: Int? = nil, auto: [Int] = []) {
        flightBeats = beats
        userRow = guide == nil ? (auto.first ?? rowOf(reference.first ?? 64)) : userRow
        row = userRow
        let b = beat
        runner?.cancel()
        runner = Task {
            // A one-beat breath so you can get your finger down.
            withAnimation { phase = .flying }
            flightStart = nil
            AudioEngine.shared.playNote(Self.rows[userRow], seconds: b * 0.5, patch: patch, velocity: 0.5)
            try? await Task.sleep(for: .milliseconds(Int(b * 1000)))
            flightStart = CACurrentMediaTime()
            for i in 0..<beats {
                if Task.isCancelled { return }
                if let guide { AudioEngine.shared.playNote(guide, seconds: b * 0.6, patch: .rhodes, velocity: 0.7) }
                if i < autoUntil, i < auto.count {
                    row = auto[i]
                    userRow = auto[i]
                    AudioEngine.shared.playNote(Self.rows[auto[i]], seconds: b * 0.85, patch: patch)
                } else if i == autoUntil, autoUntil > 0 {
                    AudioEngine.shared.playNote(Self.rows[userRow], seconds: b * 0.7, patch: patch, velocity: 0.8)
                }
                try? await Task.sleep(for: .milliseconds(Int(b * 500)))
                sampled.append(userRow)
                path.append(Mark(x: (Double(i) + 0.5) / Double(beats), row: userRow))
                if let guide {
                    matchedBeats = Self.rows[userRow] == guide ? matchedBeats + 1 : 0
                    if matchedBeats >= 2 {
                        land()
                        return
                    }
                }
                try? await Task.sleep(for: .milliseconds(Int(b * 500)))
            }
            if !Task.isCancelled { land() }
        }
    }

    private func land() {
        flightStart = nil
        withAnimation { phase = .done }
        let mine = sampled.map { Self.rows[$0] }
        switch round.mode {
        case .follow, .changed:
            let want = directions(reference)
            let got = directions(mine)
            var right = zip(want, got).filter { $0 == $1 }.count
            var total = max(1, want.count)
            if case .changed = round.mode, let w = want.last, let g = got.last {
                // The ending is what changed: it counts double.
                right += w == g ? 1 : 0
                total += 1
            }
            let score = Double(right) / Double(total)
            if score >= 0.66 {
                game.pass(score, score > 0.99 ? "You flew the exact shape: \(shapeWords(want))." : "Close to the shape: \(shapeWords(want)).")
            } else {
                game.miss("The melody went \(shapeWords(want)). You flew \(shapeWords(got)). Hum it first, then fly.", score: score)
            }
        case .hold(let t):
            if matchedBeats >= 2 {
                game.pass(1, "Locked on. When two pitches match, they blend into one.")
            } else {
                game.miss("Not quite matched. Slide slowly and listen for the moment the two sounds stop rubbing. That's \(noteName(t)).")
            }
        case .draw:
            if Set(mine).count < 2 {
                game.miss("That flight stayed level the whole way. Climb or dive at least once.")
            } else {
                drawn = mine
                drawnB = []
                game.pass(1, "Your flight became five notes: \(mine.map { noteName($0) }.joined(separator: " ")).", title: "Your melody")
                playMelody(mine)
            }
        case .redraw:
            if drawn.count >= 5, Array(mine.suffix(2)) == Array(drawn.suffix(2)) {
                game.miss("Same ending as before. Fly the last two beats somewhere new.")
            } else {
                drawnB = mine
                game.pass(1, "Same start, new ending. Play both flights and hear the difference.")
            }
        case .showcase: break
        }
    }

    private func keep(_ m: [Int], _ name: String) {
        Haptics.success()
        playMelody(m)
        game.pass(1, "Flight \(name) is yours: \(m.map { noteName($0) }.joined(separator: " ")). A melody you drew by ear.", title: "Saved")
    }

    private func directions(_ notes: [Int]) -> [Int] { zip(notes, notes.dropFirst()).map { ($1 - $0).signum() } }

    private func shapeWords(_ d: [Int]) -> String {
        d.map { $0 > 0 ? "up" : $0 < 0 ? "down" : "level" }.joined(separator: ", ")
    }

    private func retry() {
        runner?.cancel()
        withAnimation {
            game.feedback = nil
            phase = .ready
        }
    }

    private func next() {
        runner?.cancel()
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            path = []
            refPath = []
            sampled = []
        }
    }
}
