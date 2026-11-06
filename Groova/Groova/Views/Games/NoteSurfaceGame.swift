//
//  NoteSurfaceGame.swift
//  Groova
//
//  Three F2 games that share one engine but each has its own playing surface:
//
//  Keyboard Maze (F2.2): a real keyboard as a map. A pulse of light travels from key to key,
//  and letters appear only after you find the right one.
//  Harmonic Gravity (F2.4): notes orbit a glowing home. Your melody leaves a comet trail and
//  home glows brighter when you land on it.
//  Echo Chase (F2.5): five touch lanes in a dark room. The echo plays with the lights off,
//  then you chase it with your fingers.
//

import Foundation
import SwiftUI

struct NoteSurfaceGame: View {
    let task: GameTask
    let surface: NoteSurface
    let rounds: [NoteRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, listening, playing, done }

    @State private var game: GameProgress
    @State private var phase: Phase = .ready
    @State private var played: [Int] = []
    @State private var lit: Int?
    @State private var litID = 0
    @State private var wrong: Int?
    @State private var mistakes = 0
    @State private var revealed: Set<Int> = []
    @State private var myCall: [Int] = []
    @State private var myAnswer: [Int] = []
    @State private var listenTask: Task<Void, Never>?
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }
    private let patch = SynthPatch.keys

    init(task: GameTask, surface: NoteSurface, rounds: [NoteRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.surface = surface
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: NoteRound { rounds[min(game.index, rounds.count - 1)] }
    private var face: NoteSurface { round.surface ?? surface }
    private var beat: Double { 60 / round.bpm }

    /// How many notes you need to play this round.
    private var needed: Int {
        switch round.mode {
        case .explore(let n): return n
        case .find(let t, _): return t.count
        case .echo(let t, _, _): return t.count
        case .compose(let n, _, _, _): return n
        case .answer: return max(1, myCall.count)
        case .retrace: return max(1, myCall.count)
        case .spot, .ending, .duet: return 0
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: stageHeight) { stage }
                    below
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
            listenTask?.cancel()
            transport.stop()
        }
    }

    private var stageHeight: CGFloat {
        switch face {
        case .keyboard: return 300
        case .orbit: return 360
        case .strip: return 330
        case .pads: return 320
        }
    }

    private var primaryTitle: String {
        switch phase {
        case .listening: return "Listen…"
        case .playing: return needed > 0 ? "\(played.count) of \(needed)" : "Your pick"
        case .done: return "Done"
        case .ready:
            switch round.mode {
            case .explore, .find, .compose: return "Start"
            case .duet: return "Play the conversation"
            default: return "Listen"
            }
        }
    }

    // MARK: Stage

    private var stage: some View {
        VStack(spacing: 12) {
            HStack {
                StageTag(text: tag, color: phase == .playing ? accent : GameStyle.nightDim)
                Spacer()
                if needed > 0, phase == .playing { progressDots }
            }
            Spacer(minLength: 0)
            switch face {
            case .strip(let notes): strip(notes)
            case .keyboard(let low, let high): keyboard(low: low, high: high)
            case .orbit(let home, let notes, let outside): orbit(home: home, notes: notes, outside: outside)
            case .pads(let notes): hotline(notes)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }

    private var tag: String {
        switch phase {
        case .ready: return task.name
        case .listening:
            if case .echo(_, _, let gap) = round.mode, gap > 0, lit == nil { return "Hold it in your head" }
            return "Listen"
        case .playing:
            switch round.mode {
            case .spot: return "Which note changed?"
            case .ending: return "Pick an ending"
            case .compose, .answer: return "Write it"
            default: return "Your turn"
            }
        case .done: return "Caught it"
        }
    }

    private var progressDots: some View {
        HStack(spacing: 5) {
            ForEach(0..<needed, id: \.self) { i in
                Circle().fill(i < played.count ? accent : GameStyle.nightLine).frame(width: 9, height: 9)
            }
        }
    }

    /// Lights hidden while the echo plays, unless the round shows them.
    private var showLights: Bool {
        if phase != .listening { return true }
        switch round.mode {
        case .echo(_, let show, _): return show
        case .retrace: return false
        default: return true
        }
    }

    // MARK: Echo Chase: five lanes

    private func strip(_ notes: [Int]) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(notes.enumerated()), id: \.offset) { i, n in
                let on = lit == n && showLights
                let bad = wrong == n
                let u = Double(i) / Double(max(1, notes.count - 1))
                let color = Color(hue: 0.74 - u * 0.62, saturation: 0.7, brightness: 0.95)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(bad ? Theme.miss : color.opacity(on ? 1 : (phase == .listening && !showLights ? 0.12 : 0.32)))
                    .overlay(alignment: .top) {
                        Circle().fill(Color.white.opacity(on ? 0.95 : 0.2)).frame(width: 16, height: 16).padding(.top, 12)
                            .shadow(color: .white.opacity(on ? 1 : 0), radius: 10)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(on ? 0.8 : 0.1), lineWidth: 2))
                    .shadow(color: on ? color : .clear, radius: 18)
                    .frame(height: 120 + CGFloat(i) * 26)
                    .scaleEffect(on ? 1.04 : 1, anchor: .bottom)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: on)
                    .contentShape(Rectangle())
                    .onTapGesture { tap(n) }
                    .accessibilityLabel("Lane \(i + 1)")
                    .accessibilityAddTraits(.isButton)
            }
        }
    }

    // MARK: Hook Hotline: five pads in an arc

    private func hotline(_ notes: [Int]) -> some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                ForEach(Array(notes.enumerated()), id: \.offset) { i, n in
                    let u = Double(i) / Double(max(1, notes.count - 1))
                    let a = (200 + u * 140) * .pi / 180
                    let x = w / 2 + CGFloat(cos(a)) * w * 0.4
                    let y = h * 0.92 + CGFloat(sin(a)) * h * 0.78
                    let on = lit == n && showLights
                    let color = [GameStyle.kick, GameStyle.hat, Theme.success, GameStyle.lead, GameStyle.snare][i % 5]
                    ZStack {
                        Circle().fill(wrong == n ? Theme.miss : color.opacity(on ? 1 : 0.35))
                        Circle().strokeBorder(Color.white.opacity(on ? 0.9 : 0.15), lineWidth: 3)
                        Circle().stroke(color.opacity(on ? 0.6 : 0), lineWidth: 6).scaleEffect(on ? 1.5 : 1)
                        Text(round.labels ? noteName(n) : "")
                            .font(.label(15, weight: .black))
                            .foregroundStyle(on ? Color.black.opacity(0.7) : GameStyle.nightText)
                    }
                    .frame(width: 68, height: 68)
                    .scaleEffect(on ? 1.12 : 1)
                    .shadow(color: on ? color : .clear, radius: 18)
                    .animation(.spring(response: 0.22, dampingFraction: 0.55), value: on)
                    .position(x: x, y: y)
                    .onTapGesture { tap(n) }
                    .accessibilityLabel("Pad \(i + 1)")
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
        .frame(height: 230)
    }

    // MARK: Keyboard Maze: the map

    private func keyboard(low: Int, high: Int) -> some View {
        let whites = (low...high).filter { !isBlackKey($0) }
        return GeometryReader { geo in
            let w = geo.size.width / CGFloat(max(1, whites.count))
            let h = geo.size.height
            ZStack(alignment: .topLeading) {
                ForEach(Array(whites.enumerated()), id: \.offset) { i, n in
                    let on = lit == n && showLights
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(wrong == n ? Theme.miss.opacity(0.8) : (on ? accent : Color.white.opacity(0.9)))
                        .overlay(alignment: .bottom) {
                            if showLabel(n) {
                                Text(noteName(n)).font(.label(13, weight: .black))
                                    .foregroundStyle(on ? Color.white : GameStyle.night.opacity(0.7))
                                    .padding(.bottom, 10)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .frame(width: w - 4, height: h)
                        .offset(x: CGFloat(i) * w + 2)
                        .onTapGesture { tap(n) }
                }
                ForEach(Array(whites.enumerated()), id: \.offset) { i, n in
                    if n + 1 <= high, isBlackKey(n + 1) {
                        let b = n + 1
                        let on = lit == b && showLights
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(wrong == b ? Theme.miss : (on ? accent : GameStyle.night))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
                            .frame(width: w * 0.6, height: h * 0.6)
                            .offset(x: CGFloat(i + 1) * w - w * 0.3)
                            .onTapGesture { tap(b) }
                    }
                }
                // The pulse of light travelling between keys.
                if let l = lit, showLights, let x = keyX(l, whites: whites, w: w) {
                    Circle()
                        .fill(Theme.gold)
                        .frame(width: 14, height: 14)
                        .shadow(color: Theme.gold, radius: 10)
                        .offset(x: x - 7, y: isBlackKey(l) ? h * 0.6 - 26 : h - 44)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: litID)
                }
            }
        }
        .frame(height: 200)
    }

    private func keyX(_ n: Int, whites: [Int], w: CGFloat) -> CGFloat? {
        if let i = whites.firstIndex(of: n) { return CGFloat(i) * w + w / 2 }
        if let i = whites.firstIndex(of: n - 1) { return CGFloat(i + 1) * w }
        return nil
    }

    private func showLabel(_ n: Int) -> Bool {
        if revealed.contains(n) { return true }
        if case .find(_, let reveal) = round.mode, reveal { return false }
        return round.labels
    }

    // MARK: Harmonic Gravity: the orbit

    private func orbit(home: Int, notes: [Int], outside: Int?) -> some View {
        let ring = notes.filter { $0 != home }
        let all = ring + (outside.map { [$0] } ?? [])
        let atHome = played.last.map { $0 % 12 == home % 12 } ?? false
        return GeometryReader { geo in
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let r = min(geo.size.width, geo.size.height) / 2 - 30
            let point: (Int) -> CGPoint = { n in
                if n == home { return c }
                guard let i = all.firstIndex(of: n) else { return c }
                let a = Double(i) / Double(all.count) * 2 * .pi - .pi / 2
                return CGPoint(x: c.x + r * CGFloat(cos(a)), y: c.y + r * CGFloat(sin(a)))
            }
            ZStack {
                Circle().stroke(GameStyle.nightLine, lineWidth: 2).frame(width: r * 2, height: r * 2).position(c)
                // Comet trail of what you've played.
                Path { p in
                    for (i, n) in played.suffix(6).enumerated() {
                        if i == 0 { p.move(to: point(n)) } else { p.addLine(to: point(n)) }
                    }
                }
                .stroke(LinearGradient(colors: [accent.opacity(0), accent], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                // Home.
                let homeOn = lit.map { $0 % 12 == home % 12 } ?? false
                Circle()
                    .fill(RadialGradient(colors: [Theme.gold.opacity(homeOn || atHome ? 1 : 0.55), Theme.gold.opacity(0.05)],
                                         center: .center, startRadius: 4, endRadius: atHome ? 70 : 50))
                    .frame(width: 120, height: 120)
                    .position(c)
                    .animation(.easeOut(duration: 0.4), value: atHome)
                planet(home, label: "\(noteName(home)) · home", size: 58, color: Theme.gold, on: homeOn)
                    .position(c)
                ForEach(all, id: \.self) { n in
                    let isOut = n == outside
                    planet(n, label: noteName(n), size: 44, color: isOut ? GameStyle.snare : accent, on: lit == n, dashed: isOut)
                        .position(point(n))
                }
            }
        }
        .frame(height: 290)
    }

    private func planet(_ n: Int, label: String, size: CGFloat, color: Color, on: Bool, dashed: Bool = false) -> some View {
        let show = on && showLights
        return ZStack {
            Circle().fill(wrong == n ? Theme.miss : (show ? color : GameStyle.nightRaised))
            Circle().strokeBorder(color.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: dashed ? [4, 4] : []))
            Text(round.labels || revealed.contains(n) ? label : "")
                .font(.label(label.count > 3 ? 10 : 14, weight: .black))
                .foregroundStyle(show ? Color.black.opacity(0.75) : GameStyle.nightText)
                .lineLimit(1).minimumScaleFactor(0.6)
        }
        .frame(width: size, height: size)
        .scaleEffect(show ? 1.18 : 1)
        .shadow(color: show ? color : .clear, radius: 14)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: show)
        .contentShape(Circle())
        .onTapGesture { tap(n) }
        .accessibilityLabel(noteName(n))
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Below the stage

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .spot(let a, _) where phase == .playing:
            VStack(alignment: .leading, spacing: 10) {
                Text("Tap the note that changed").font(.label(15, weight: .heavy)).foregroundStyle(Theme.text)
                HStack(spacing: 8) {
                    ForEach(0..<a.count, id: \.self) { i in
                        Button { spot(i) } label: { Text("\(i + 1)").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
                    }
                }
            }
            .card(padding: 14)
        case .ending(let lead, let options, _) where phase == .playing:
            VStack(alignment: .leading, spacing: 10) {
                Text("Hear each ending, then choose").font(.label(15, weight: .heavy)).foregroundStyle(Theme.text)
                ForEach(Array(options.enumerated()), id: \.offset) { i, o in
                    HStack(spacing: 10) {
                        Button { listen(lead + [o]) } label: {
                            Label("Ending \(i + 1)", systemImage: "play.fill").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                        Button { choose(o) } label: { Text("Choose").frame(width: 90) }
                            .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 50))
                    }
                }
            }
            .card(padding: 14)
        default:
            if phase == .playing, needed > 0 { playControls }
            if phase == .done, !played.isEmpty { replayRow }
        }
    }

    private var playControls: some View {
        HStack(spacing: 10) {
            if hasReference {
                Button { replayReference() } label: { Label("Hear it again", systemImage: "ear").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
            }
            Button {
                Haptics.soft()
                if !played.isEmpty { withAnimation { _ = played.removeLast() } }
            } label: { Label("Undo", systemImage: "arrow.uturn.backward").frame(maxWidth: .infinity) }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50, enabled: !played.isEmpty))
                .disabled(played.isEmpty)
        }
    }

    private var replayRow: some View {
        Button { listen(played, light: true) } label: { Label("Play what you played", systemImage: "play.fill").frame(maxWidth: .infinity) }
            .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 52))
    }

    private var hasReference: Bool {
        switch round.mode {
        case .echo, .retrace: return true
        default: return false
        }
    }

    // MARK: Sound

    private func sound(_ n: Int) {
        AudioEngine.shared.playNote(n, seconds: beat * 0.8, patch: patch)
        litID += 1
        withAnimation(.easeOut(duration: 0.05)) { lit = n }
        let id = litID
        Task {
            try? await Task.sleep(for: .milliseconds(Int(beat * 700)))
            if litID == id { withAnimation(.easeOut(duration: 0.2)) { lit = nil } }
        }
    }

    /// Plays notes one per beat. Lights follow if the round allows it.
    private func listen(_ notes: [Int], light: Bool = true, then: (() -> Void)? = nil) {
        listenTask?.cancel()
        let b = beat
        listenTask = Task {
            for n in notes {
                if Task.isCancelled { return }
                // 0 is a rest.
                if n > 0 { AudioEngine.shared.playNote(n, seconds: b * 0.8, patch: patch) }
                litID += 1
                withAnimation(.easeOut(duration: 0.05)) { lit = light && n > 0 ? n : nil }
                try? await Task.sleep(for: .milliseconds(Int(b * 1000)))
            }
            withAnimation { lit = nil }
            if !Task.isCancelled { then?() }
        }
    }

    private var reference: [Int] {
        switch round.mode {
        case .echo(let t, _, _): return t
        case .retrace: return myCall
        default: return []
        }
    }

    private func replayReference() {
        Haptics.tap()
        let show: Bool = { if case .echo(_, let s, _) = round.mode { return s }; return false }()
        listen(reference, light: show)
    }

    // MARK: Flow

    private func start() {
        played = []
        mistakes = 0
        revealed = []
        wrong = nil
        if !round.backing.isEmpty {
            transport.play(round.backing, genre: genre, source: .reference, bars: nil, swing: 0, bpm: round.bpm)
        }
        switch round.mode {
        case .explore, .find, .compose:
            withAnimation { phase = .playing }
        case .echo(let t, let show, let gap):
            phase = .listening
            listen(t, light: show) {
                Task {
                    try? await Task.sleep(for: .milliseconds(Int(Double(gap * 4) * beat * 1000)))
                    withAnimation { phase = .playing }
                }
            }
        case .spot(let a, let b):
            phase = .listening
            listen(a + [0]) { listen(b) { withAnimation { phase = .playing } } }
        case .ending(let lead, _, _):
            phase = .listening
            listen(lead) { withAnimation { phase = .playing } }
        case .answer:
            phase = .listening
            listen(myCall) { withAnimation { phase = .playing } }
        case .retrace:
            phase = .listening
            listen(myCall, light: false) { withAnimation { phase = .playing } }
        case .duet:
            phase = .listening
            let both = myCall + myAnswer
            listen(both + both) {
                withAnimation { phase = .done }
                game.pass(1, "Call, then answer. Eight notes, one musical conversation.", title: "Your duet")
            }
        }
    }

    private func tap(_ n: Int) {
        guard n > 0 else { return }
        Haptics.tap()
        sound(n)
        guard phase == .playing, needed > 0, played.count < needed else { return }
        switch round.mode {
        case .find(let t, _):
            let want = t[played.count]
            if n == want {
                played.append(n)
                withAnimation(.spring) { _ = revealed.insert(n) }
                if played.count == t.count {
                    finish(Double(max(0.4, 1 - Double(mistakes) * 0.1)),
                           mistakes == 0 ? "Found every one first try." : "Found them all, with \(mistakes) wrong turn\(mistakes == 1 ? "" : "s").")
                }
            } else {
                mistakes += 1
                Haptics.warning()
                flashWrong(n)
            }
        default:
            withAnimation { played.append(n) }
            if played.count == needed { judge() }
        }
    }

    private func flashWrong(_ n: Int) {
        withAnimation(.easeOut(duration: 0.05)) { wrong = n }
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            withAnimation { wrong = nil }
        }
    }

    private func judge() {
        switch round.mode {
        case .explore:
            finish(1, "Every key you touched made a sound. Now you know the map.")
        case .echo(let t, _, _):
            grade(played, against: t)
        case .retrace:
            grade(played, against: myCall)
        case .compose(_, let s, let end, let shape):
            if let s, played.first != s {
                miss("Start on \(noteName(s)), then go wherever you like.")
            } else if !end.isEmpty, let last = played.last, !end.contains(where: { $0 % 12 == last % 12 }) {
                miss("End on \(end.map { noteName($0) }.joined(separator: " or ")) so the phrase lands.")
            } else if shape, !hasStepAndLeap(played) {
                miss("Use at least one small step and one bigger leap.")
            } else if Set(played).count == 1 {
                miss("That's one note over and over. Give it some movement.")
            } else {
                myCall = played
                finish(1, "That's yours: \(played.map { noteName($0) }.joined(separator: " "))." + detourNote, title: "Your phrase")
                listen(played)
            }
        case .answer(let keep):
            let k = min(keep, myCall.count)
            if Array(played.prefix(k)) != Array(myCall.prefix(k)) {
                miss("Start with the same first \(k) notes as your call, so it sounds like a reply.")
            } else if played == myCall {
                miss("That's an exact copy. Change the ending.")
            } else {
                myAnswer = played
                finish(1, "Same start, new ending. That's an answer.")
                listen(myCall + played)
            }
        default: break
        }
    }

    private var detourNote: String {
        if case .orbit(_, _, let out?) = face, played.contains(out) {
            return " Your \(noteName(out)) steps outside the key, which adds a little tension before home."
        }
        return ""
    }

    private func hasStepAndLeap(_ p: [Int]) -> Bool {
        let d = zip(p, p.dropFirst()).map { abs($1 - $0) }
        return d.contains { $0 > 0 && $0 <= 2 } && d.contains { $0 >= 3 }
    }

    private func grade(_ mine: [Int], against t: [Int]) {
        let right = zip(mine, t).filter { $0 == $1 }.count
        let score = Double(right) / Double(max(1, t.count))
        if score >= 0.75 {
            finish(score, right == t.count ? "Every note caught." : "\(right) of \(t.count) notes caught.")
        } else {
            let shapeRight = zip(zip(mine, mine.dropFirst()), zip(t, t.dropFirst()))
                .filter { ($0.1 - $0.0).signum() == ($1.1 - $1.0).signum() }.count
            let hint = shapeRight >= t.count - 1 ? " The shape was right, the notes were a little off." : " Hum it back first, then play."
            game.miss("\(right) of \(t.count) notes caught." + hint, score: score)
            withAnimation { phase = .done }
        }
    }

    private func spot(_ i: Int) {
        guard case .spot(let a, let b) = round.mode else { return }
        Haptics.tap()
        if i < a.count, i < b.count, a[i] != b[i] {
            finish(1, "Note \(i + 1) changed, from \(noteName(a[i])) to \(noteName(b[i])).")
        } else {
            game.miss("Not that one. Hear them again and follow along note by note.")
            withAnimation { phase = .done }
        }
    }

    private func choose(_ o: Int) {
        guard case .ending(let lead, _, let answer) = round.mode else { return }
        Haptics.tap()
        listen(lead + [o])
        if let answer, o != answer {
            game.miss("Both are allowed, but here \(noteName(answer)) sounds more settled over what's underneath.", score: 0.5)
            withAnimation { phase = .done }
        } else {
            finish(1, answer == nil ? "Good pick. Both endings work, they just feel different." : "\(noteName(o)) fits what's underneath, so the phrase comes to rest.")
        }
    }

    private func finish(_ score: Double, _ msg: String, title: String? = nil) {
        withAnimation { phase = .done }
        game.pass(score, msg, title: title)
    }

    private func miss(_ msg: String) {
        game.miss(msg)
        withAnimation { phase = .done }
    }

    private func retry() {
        listenTask?.cancel()
        transport.stop()
        withAnimation {
            game.feedback = nil
            phase = .ready
            played = []
        }
    }

    private func next() {
        listenTask?.cancel()
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            played = []
            revealed = []
        }
    }
}
