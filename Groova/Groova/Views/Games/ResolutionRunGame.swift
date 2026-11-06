//
//  ResolutionRunGame.swift
//  Groova
//
//  F3.3 Resolution Run. A glowing orb runs along a path of chord blocks. It stops at a closed
//  gate, and the gate only opens when you pick the chord that takes the music where it wants
//  to go. Tension pulls the orb forward; arrival lets it rest at home.
//

import Foundation
import QuartzCore
import SwiftUI

struct ResolutionRunGame: View {
    let task: GameTask
    let rounds: [RunRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, listening, playing, done }

    @State private var game: GameProgress
    @State private var phase: Phase = .ready
    @State private var blocks: [Triad?] = []
    @State private var at: Int?
    @State private var gateOpen = false
    @State private var homeTapAt: Double?
    @State private var lastChordStart: Double?
    @State private var home: Triad = .c
    @State private var middles: [Triad] = []
    @State private var ending: Triad?
    @State private var runner: Task<Void, Never>?
    @Environment(\.accent) private var accent

    private let patch = SynthPatch.keys

    init(task: GameTask, rounds: [RunRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: RunRound { rounds[min(game.index, rounds.count - 1)] }
    private var bar: Double { 60 / round.bpm * 4 * 0.5 }

    /// Where Gold routes can end without coming home.
    private var openEnding: Triad { home.minor ? .e : .g }
    private var palette: [Triad] { if case .route(let p) = round.mode { return p }; return [.am, .f, .dm, .g] }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 300) { stage }
                    if phase == .playing || isGold { below }
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

    private var isGold: Bool {
        switch round.mode {
        case .destination, .route, .endings: return true
        default: return false
        }
    }

    private var primaryTitle: String {
        switch phase {
        case .ready:
            switch round.mode {
            case .destination: return "Set this as home"
            case .route: return "Build the route"
            case .endings: return "Hear both endings"
            default: return "Start the run"
            }
        case .listening: return "Running…"
        case .done: return "Arrived"
        case .playing:
            if case .route = round.mode { return "Lock the route" }
            if case .follow = round.mode { return "Waiting for home…" }
            return "Choose below"
        }
    }

    private var primaryEnabled: Bool {
        if phase == .ready { return true }
        if case .route = round.mode, phase == .playing { return middles.count == 2 }
        return false
    }

    // MARK: Stage

    private var stage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let n = max(1, blocks.count)
            let cell = (w - 28) / CGFloat(n)
            let y = geo.size.height / 2 + 14
            ZStack(alignment: .topLeading) {
                // The track.
                Capsule().fill(GameStyle.nightLine).frame(width: w - 40, height: 6).position(x: w / 2, y: y)
                ForEach(0..<blocks.count, id: \.self) { i in
                    block(i, blocks[i])
                        .frame(width: cell - 8, height: 92)
                        .position(x: 14 + cell * (CGFloat(i) + 0.5), y: y)
                }
                // The runner.
                if let at, at < blocks.count {
                    Circle().fill(Color.white).frame(width: 22, height: 22)
                        .shadow(color: accent, radius: 14)
                        .position(x: 14 + cell * (CGFloat(at) + 0.5), y: y - 62)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: at)
                }
                StageTag(text: tag, color: phase == .playing ? accent : GameStyle.nightDim).padding(14)
            }
        }
    }

    private var tag: String {
        switch phase {
        case .ready: return task.name
        case .listening: return "Follow the run"
        case .done: return gateOpen ? "Gate open" : "Arrived"
        case .playing:
            if case .follow = round.mode { return "Tap HOME when it lands" }
            return "The gate is closed"
        }
    }

    private func block(_ i: Int, _ t: Triad?) -> some View {
        let isGate = t == nil
        let lit = at == i
        let isHome = t.map { $0 == home && i == blocks.count - 1 } ?? false
        return ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(lit ? accent.opacity(0.85) : (isGate ? GameStyle.night : GameStyle.nightRaised))
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(isGate ? Theme.gold.opacity(0.8) : (isHome ? Theme.gold : GameStyle.nightLine),
                              style: StrokeStyle(lineWidth: isGate ? 3 : 2, dash: isGate ? [6, 5] : []))
            VStack(spacing: 4) {
                Image(systemName: isGate ? "lock.fill" : (isHome ? "house.fill" : "music.note"))
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(isGate ? Theme.gold : GameStyle.nightDim)
                Text(t.map { showNames ? $0.name : "?" } ?? "?")
                    .font(.display(18))
                    .foregroundStyle(GameStyle.nightText)
            }
        }
        .scaleEffect(lit ? 1.08 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: lit)
        .onTapGesture { tapBlock(i) }
    }

    /// Ear-first rounds hide the names until the gate opens.
    private var showNames: Bool {
        if case .gate(_, _, _, let ref) = round.mode, !ref.isEmpty, phase != .done { return false }
        return true
    }

    // MARK: Below

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .gate(let lead, let options, _, let ref):
            VStack(spacing: 10) {
                if !ref.isEmpty {
                    Button { run(ref) } label: { Label("Hear the reference", systemImage: "ear").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: Theme.gold, textColor: Theme.text, height: 50))
                }
                optionRows(options.map { lead + [$0] }, names: options.map { showNames ? $0.name : "Ending \(options.firstIndex(of: $0)! + 1)" }) { i in
                    choose(i)
                }
            }
        case .slot(let route, let missing, let options):
            VStack(spacing: 10) {
                Button { run(route) } label: { Label("Hear the reference", systemImage: "ear").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.gold, textColor: Theme.text, height: 50))
                optionRows(options.map { o in route.enumerated().map { $0.offset == missing ? o : $0.element } },
                           names: options.map(\.name)) { i in choose(i) }
            }
        case .follow:
            Button(action: tapHome) {
                Label("HOME", systemImage: "house.fill").font(.label(20, weight: .black)).frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: Theme.gold, textColor: Theme.text, height: 74))
        case .destination(let homes):
            HStack(spacing: 10) {
                ForEach(homes, id: \.self) { h in
                    Button { pickHome(h) } label: { Label(h.name, systemImage: "house.fill").frame(maxWidth: .infinity) }
                        .buttonStyle(ChunkyButtonStyle(color: home == h ? accent : Theme.surfaceHigh,
                                                       textColor: home == h ? Theme.onBrand : Theme.text, height: 54))
                }
            }
        case .route:
            VStack(alignment: .leading, spacing: 10) {
                Text("Tap the two middle blocks to change them").font(.label(14, weight: .heavy)).foregroundStyle(Theme.text)
                Button { run(blocks.compactMap { $0 }) } label: { Label("Play the route", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
            }
        case .endings:
            let start = [home] + (middles.count == 2 ? middles : [.f, .g])
            optionRows([start + [home], start + [openEnding]],
                       names: ["Resolved: \(home.name)", "Open: \(openEnding.name)"]) { i in keepEnding(i == 0 ? home : openEnding) }
        }
    }

    private func optionRows(_ routes: [[Triad]], names: [String], pick: @escaping (Int) -> Void) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(routes.enumerated()), id: \.offset) { i, r in
                HStack(spacing: 10) {
                    Button { run(Array(r.suffix(3))) } label: {
                        Label(names[i], systemImage: "play.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                    Button { pick(i) } label: { Text("Choose").frame(width: 92) }
                        .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 50))
                }
            }
        }
        .card(padding: 14)
    }

    // MARK: Sound

    private func sound(_ t: Triad) {
        AudioEngine.shared.playChord(t.pitches + [t.root - 12, t.root - 24], seconds: bar * 0.95, patch: patch)
    }

    /// Runs the orb along the route, a chord per block.
    private func run(_ route: [Triad], light: Bool = true, then: (() -> Void)? = nil) {
        runner?.cancel()
        let b = bar
        runner = Task {
            for (i, t) in route.enumerated() {
                if Task.isCancelled { return }
                if light { withAnimation { at = min(i, max(0, blocks.count - 1)) } }
                if i == route.count - 1 { lastChordStart = CACurrentMediaTime() }
                sound(t)
                try? await Task.sleep(for: .milliseconds(Int(b * 1000)))
            }
            if !Task.isCancelled { then?() }
        }
    }

    // MARK: Touch

    private func tapBlock(_ i: Int) {
        if case .route = round.mode, phase == .playing, i == 1 || i == 2 {
            Haptics.select()
            let cur = blocks[i] ?? palette[0]
            let nextChord = palette[((palette.firstIndex(of: cur) ?? -1) + 1) % palette.count]
            blocks[i] = nextChord
            middles = [blocks[1], blocks[2]].compactMap { $0 }
            sound(nextChord)
            return
        }
        if let t = blocks[i] { sound(t) }
    }

    private func tapHome() {
        Haptics.thump()
        homeTapAt = CACurrentMediaTime()
        AudioEngine.shared.playChord(home.pitches, seconds: 0.4, patch: patch, delay: 0)
    }

    private func choose(_ i: Int) {
        Haptics.tap()
        switch round.mode {
        case .gate(let lead, let options, let answer, _):
            let o = options[i]
            if let answer, i != answer {
                game.miss("\(o.name) works too, but it leaves the phrase hanging. Here the reference lands on \(options[answer].name).", score: 0.5)
                withAnimation { phase = .done }
                blocks = lead.map { Optional($0) } + [o]
                run(lead + [o])
            } else {
                openGate(with: o, route: lead + [o], msg: "\(o.name) opens the gate. After that tension, it feels like arriving.")
            }
        case .slot(let route, let missing, let options):
            let o = options[i]
            if o == route[missing] {
                openGate(with: o, route: route, msg: "\(o.name) fills the gap, and the route matches the reference.", at: missing)
            } else {
                game.miss("\(o.name) fits the key, but it isn't what the reference plays. Hear it again.", score: 0.4)
            }
        default: break
        }
    }

    private func openGate(with o: Triad, route: [Triad], msg: String, at slot: Int? = nil) {
        Haptics.success()
        let idx = slot ?? (blocks.count - 1)
        if idx < blocks.count { blocks[idx] = o }
        withAnimation(.spring) { gateOpen = true; phase = .done }
        game.pass(1, msg, title: "Gate open")
        run(route)
    }

    private func pickHome(_ h: Triad) {
        Haptics.select()
        home = h
        blocks = [h, nil, nil, h]
        sound(h)
    }

    private func keepEnding(_ e: Triad) {
        Haptics.success()
        ending = e
        let start = [home] + (middles.count == 2 ? middles : [.f, .g])
        blocks = (start + [e]).map { Optional($0) }
        run(start + [e])
        withAnimation { phase = .done }
        game.pass(1, e == home ? "You chose to land at home. The story resolves."
                               : "You chose to leave it open on \(e.name). The story ends on a question.", title: "Your story")
    }

    // MARK: Flow

    private func primary() {
        if phase == .ready { start(); return }
        if case .route = round.mode, middles.count == 2 {
            withAnimation { phase = .done }
            game.pass(1, "Your route: \(([home] + middles).map(\.name).joined(separator: " → ")) and then…", title: "Route set")
            run([home] + middles)
        }
    }

    private func start() {
        gateOpen = false
        homeTapAt = nil
        at = nil
        switch round.mode {
        case .gate(let lead, _, _, let ref):
            blocks = lead.map { Optional($0) } + [nil]
            phase = .listening
            if ref.isEmpty {
                run(lead) { withAnimation { phase = .playing } }
            } else {
                run(ref, light: false) {
                    Task {
                        try? await Task.sleep(for: .milliseconds(400))
                        run(lead) { withAnimation { phase = .playing } }
                    }
                }
            }
        case .slot(let route, let missing, _):
            blocks = route.enumerated().map { $0.offset == missing ? nil : $0.element }
            phase = .listening
            run(route) { withAnimation { phase = .playing } }
        case .follow(let route, let h):
            home = h
            blocks = route.map { Optional($0) }
            withAnimation { phase = .playing }
            run(route) {
                Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    judgeFollow()
                }
            }
        case .destination(let homes):
            if blocks.isEmpty { pickHome(homes.first ?? .c) }
            withAnimation { phase = .done }
            game.pass(1, "Home is \(home.name). Every route you build now will be pulled back towards it.", title: "Home set")
        case .route:
            blocks = [home, palette[0], palette[1], nil]
            middles = [palette[0], palette[1]]
            withAnimation { phase = .playing }
        case .endings:
            let start = [home] + (middles.count == 2 ? middles : [.f, .g])
            blocks = start.map { Optional($0) } + [nil]
            withAnimation { phase = .playing }
        }
    }

    private func judgeFollow() {
        withAnimation { phase = .done }
        guard let t = homeTapAt, let s = lastChordStart else {
            game.miss("You didn't tap HOME. Listen for the chord where the run comes to rest.")
            return
        }
        let d = t - s
        if d >= -0.15, d <= bar {
            game.pass(1, "Right on arrival. The last chord is home, and the run comes to rest.")
        } else if d < -0.15 {
            game.miss("Too early. The run hadn't come home yet. Wait for the final chord.", score: 0.4)
        } else {
            game.miss("A little late. Tap the moment the last chord lands.", score: 0.6)
        }
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
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            at = nil
            gateOpen = false
            if !isGold { blocks = [] }
        }
    }
}
