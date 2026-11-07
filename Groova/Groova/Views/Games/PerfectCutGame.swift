//
//  PerfectCutGame.swift
//  Groova
//
//  F5.3 The Perfect Cut. A cutting board with two sections on a four-bar timeline. Scrub the
//  scissors to move the cut, drop a pause, a fill or an echo tail in front of it, and audition
//  the join. Small timing moves make an edit smooth, awkward, abrupt or exciting.
//

import Foundation
import QuartzCore
import SwiftUI

struct PerfectCutGame: View {
    let task: GameTask
    let rounds: [CutRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let sectionNames = ["Verse", "Breakdown", "Chorus", "Variation"]
    static let sectionPatterns = [SongKit.verse, SongKit.breakdown, SongKit.main, SongKit.variation]
    static let fills = ["Snare roll", "Kick pickup", "Hat rush"]
    static let fillPatterns = [SongKit.fill,
                               Pattern(kick: [0, 8, 12, 14, 15], clap: [4], hat: [0, 2, 4, 6]),
                               Pattern(kick: [0, 8], clap: [4], hat: Array(8..<16), openHat: [14])]
    static let totalSteps = 64

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var cut = 32
    @State private var join: CutJoin = .hard
    @State private var fillIndex = 0
    @State private var sectionA = 0
    @State private var sectionB = 2
    @State private var playing = false
    @State private var heard: Set<String> = []
    @State private var choice: Int?
    @State private var lateIsA = false
    @State private var earMark: Double?
    @State private var revealed = false
    @State private var forced: (cut: Int, join: CutJoin, late: Bool)?
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }
    private var engine: AudioEngine { AudioEngine.shared }

    init(task: GameTask, rounds: [CutRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: CutRound { rounds[min(game.index, rounds.count - 1)] }
    private var a: Pattern { Self.sectionPatterns[sectionA] }
    private var b: Pattern {
        if case .markByEar = round.mode { return a }
        return Self.sectionPatterns[sectionB]
    }

    private var gridHidden: Bool {
        if case .markByEar = round.mode { return !revealed }
        return false
    }

    private var snapsToBars: Bool {
        if case .direct = round.mode { return true }
        return false
    }

    // MARK: Building the edit

    /// Four bars: A up to the cut, B after it, with the join in front of the cut.
    private func bars(cut: Int, join: CutJoin, late: Bool = false) -> [Pattern] {
        var out: [Pattern] = []
        for bar in 0..<4 {
            let s0 = bar * 16
            if cut <= s0 { out.append(b) } else if cut >= s0 + 16 { out.append(a) } else { out.append(SongKit.splice(a, b, at: cut - s0)) }
        }
        let jb = max(0, (cut - 1) / 16)
        let end = cut - jb * 16
        switch join {
        case .pause, .echo:
            let orig = out[jb]
            out[jb] = SongKit.splice(orig, Pattern(), at: max(0, end - 4))
            if end < 16 { out[jb] = SongKit.splice(out[jb], orig, at: end) }
        case .fill:
            let f = Self.fillPatterns[fillIndex]
            let shift = late ? 2 : 0
            var p = out[jb]
            for t in DrumTrack.allCases {
                for s in 8..<16 {
                    let at = s - (16 - end) + shift
                    if at >= 0, at < 16 { p[t][at] = f[t][s] }
                }
            }
            // A late fill also delays the arrival of B by an eighth.
            if late {
                for t in DrumTrack.allCases where jb + 1 < 4 {
                    out[jb + 1][t][0] = false
                    out[jb + 1][t][1] = false
                }
            }
            out[jb] = p
        case .hard:
            break
        }
        return out
    }

    private func current() -> (cut: Int, join: CutJoin, late: Bool) {
        forced ?? (cut, join, false)
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if case .choose = round.mode { chooser }
                    GameStage(height: 250) { board }
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
            echoTail(s)
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running { playing = false }
        }
        .onDisappear { transport.stop() }
    }

    // MARK: Cutting board

    private var board: some View {
        TimelineView(.animation(paused: !playing)) { _ in
            GeometryReader { geo in
                let left: CGFloat = 14, w = geo.size.width - 28
                let sw = w / CGFloat(Self.totalSteps)
                let h = geo.size.height
                let pos = playing ? (clock.now() ?? 0) : -1
                let edit = current()
                ZStack(alignment: .topLeading) {
                    // Grid.
                    if !gridHidden {
                        ForEach(0...16, id: \.self) { q in
                            Rectangle().fill(GameStyle.ink.opacity(q % 4 == 0 ? 0.3 : 0.08))
                                .frame(width: q % 4 == 0 ? 2 : 1, height: h - 70)
                                .position(x: left + sw * CGFloat(q * 4), y: 40 + (h - 70) / 2)
                        }
                        ForEach(0..<4, id: \.self) { bar in
                            Text("\(bar + 1)").font(.label(10, weight: .black)).foregroundStyle(GameStyle.nightDim)
                                .position(x: left + sw * CGFloat(bar * 16 + 8), y: h - 18)
                        }
                    }
                    // Clips, drawn as step-by-step waveforms.
                    let edited = bars(cut: edit.cut, join: edit.join, late: edit.late)
                    ForEach(0..<Self.totalSteps, id: \.self) { s in
                        let p = edited[s / 16]
                        let e = energy(p, s % 16)
                        let fromB = s >= edit.cut
                        let inJoin = edit.join != .hard && s < edit.cut && s >= edit.cut - (edit.join == .fill ? 8 : 4)
                        let color: Color = inJoin ? Theme.gold : (fromB ? GameStyle.lead : GameStyle.chords)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color.opacity(e == 0 ? 0.12 : (pos >= Double(s) ? 1 : 0.6)))
                            .frame(width: max(2, sw - 1.5), height: max(4, CGFloat(e) * 20))
                            .position(x: left + sw * (CGFloat(s) + 0.5), y: 40 + (h - 70) / 2)
                    }
                    // Clip names.
                    Text(Self.sectionNames[sectionA].uppercased()).font(.label(10, weight: .black))
                        .foregroundStyle(GameStyle.chords).position(x: left + 40, y: 40)
                    if showsScissors {
                        Text(Self.sectionNames[sectionB].uppercased()).font(.label(10, weight: .black))
                            .foregroundStyle(GameStyle.lead)
                            .position(x: min(left + w - 40, left + sw * CGFloat(edit.cut) + 40), y: 40)
                    }
                    // Scissors.
                    if showsScissors {
                        let x = left + sw * CGFloat(edit.cut)
                        VStack(spacing: 2) {
                            Image(systemName: "scissors").font(.system(size: 18, weight: .black))
                                .foregroundStyle(edit.cut % 16 == 0 ? Theme.gold : GameStyle.snare)
                            Rectangle().fill(edit.cut % 16 == 0 ? Theme.gold : GameStyle.snare).frame(width: 3, height: h - 80)
                        }
                        .position(x: x, y: 26 + (h - 80) / 2 + 10)
                    }
                    if let earMark {
                        Image(systemName: "flag.fill").font(.system(size: 16, weight: .black)).foregroundStyle(Theme.gold)
                            .position(x: left + sw * CGFloat(earMark * 16), y: 24)
                    }
                    if revealed, case .markByEar(let bar) = round.mode {
                        Rectangle().fill(GameStyle.ink).frame(width: 3, height: h - 60)
                            .position(x: left + sw * CGFloat(bar * 16), y: 40 + (h - 70) / 2)
                    }
                    if pos >= 0 {
                        Rectangle().fill(GameStyle.ink.opacity(0.7)).frame(width: 2, height: h - 60)
                            .position(x: left + sw * CGFloat(pos), y: 40 + (h - 70) / 2)
                    }
                    StageTag(text: tag, color: playing ? accent : GameStyle.nightDim).padding(12)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { d in
                    guard canScrub else { return }
                    var s = Int(((d.location.x - left) / sw).rounded())
                    if snapsToBars { s = Int((Double(s) / 16).rounded()) * 16 }
                    s = min(56, max(8, s))
                    if s != cut {
                        cut = s
                        forced = nil
                        Haptics.select()
                        if s % 16 == 0 { Haptics.thump() }
                    }
                })
            }
        }
    }

    private func energy(_ p: Pattern, _ s: Int) -> Int {
        var e = 0
        if p.kick[s] { e += 2 }
        if p.clap[s] { e += 2 }
        if p.hat[s] || p.openHat[s] { e += 1 }
        if p.bass.contains(where: { $0.step == s }) { e += 1 }
        if p.chords.contains(where: { $0.step == s }) { e += 1 }
        return min(4, e)
    }

    private var showsScissors: Bool {
        switch round.mode {
        case .markByEar: return false
        default: return true
        }
    }

    private var canScrub: Bool {
        switch round.mode {
        case .align, .direct: return !playing
        default: return false
        }
    }

    private var tag: String {
        if case .markByEar = round.mode { return revealed ? "Downbeats" : "No grid" }
        if playing { return "Playing the join" }
        switch round.mode {
        case .align: return cut % 16 == 0 ? "On the bar line" : "Mid-beat"
        case .direct: return "Bar \(cut / 16 + 1) · \(join.rawValue)"
        default: return join.rawValue
        }
    }

    // MARK: Controls

    private var chooser: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FROM").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { i in
                    ChoiceTile(title: Self.sectionNames[i], color: GameStyle.chords, selected: sectionA == i) {
                        sectionA = i
                        play()
                    }
                }
            }
            Text("INTO").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { i in
                    ChoiceTile(title: Self.sectionNames[i], color: GameStyle.lead, selected: sectionB == i, dim: i == sectionA) {
                        guard i != sectionA else { return }
                        sectionB = i
                        play()
                    }
                }
            }
        }
    }

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .align:
            playButton("Hear the join")
        case .pause:
            VStack(spacing: 10) {
                Button {
                    join = join == .pause ? .hard : .pause
                    heard.insert(join.rawValue)
                    play()
                    Haptics.thump()
                } label: {
                    Label(join == .pause ? "Pause is in" : "CUT OUT one beat", systemImage: "scissors")
                        .font(.display(20)).frame(maxWidth: .infinity, minHeight: 80)
                }
                .buttonStyle(ChunkyButtonStyle(color: join == .pause ? Theme.gold : accent, height: 80))
                ABSwitch(a: "Continuous", b: "With pause", current: nil) { i in
                    join = i == 0 ? .hard : .pause
                    heard.insert(join.rawValue)
                    play()
                }
            }
        case .fill:
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    ChoiceTile(title: Self.fills[i], symbol: ["circle.grid.3x3.fill", "arrow.up.forward", "wind"][i],
                               color: Theme.gold, selected: join == .fill && fillIndex == i) {
                        fillIndex = i
                        join = .fill
                        heard.insert("fill\(i)")
                        play()
                    }
                }
            }
        case .markByEar:
            Button {
                guard playing, let p = clock.now() else { return }
                earMark = p / 16
                Haptics.thump()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "flag.fill").font(.system(size: 24, weight: .black))
                    Text("MARK").font(.display(22))
                }
                .foregroundStyle(playing ? Theme.onBrand : Theme.textTertiary)
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(playing ? accent : Theme.surfaceHigh))
            }
            .buttonStyle(.plain)
            .disabled(!playing)
        case .compare:
            VStack(spacing: 10) {
                Button {
                    forced = (32, .fill, false)
                    heard.insert("ref")
                    play()
                } label: { Label("Hear the reference", systemImage: "ear").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                HStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { i in
                        ChoiceTile(title: "Edit \(i == 0 ? "A" : "B")", symbol: "play.fill", color: accent, selected: choice == i) {
                            choice = i
                            forced = (32, .fill, (i == 0) == lateIsA)
                            heard.insert("edit\(i)")
                            play()
                        }
                    }
                }
            }
        case .intention:
            HStack(spacing: 8) {
                ForEach([CutJoin.echo, .pause, .fill], id: \.self) { j in
                    ChoiceTile(title: j == .echo ? "Gentle fade" : j == .pause ? "Drop-out" : "Short fill",
                               symbol: j == .echo ? "dot.radiowaves.right" : j == .pause ? "pause.fill" : "circle.grid.3x3.fill",
                               color: Theme.gold, selected: join == j) {
                        join = j
                        heard.insert(j.rawValue)
                        play()
                    }
                }
            }
        case .direct:
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    ForEach(CutJoin.allCases, id: \.self) { j in
                        ChoiceTile(title: j.rawValue, color: Theme.gold, selected: join == j) {
                            join = j
                            Haptics.select()
                        }
                    }
                }
                playButton("Preview the cut")
            }
        case .render:
            ABSwitch(a: "Hard cut", b: "Your transition", current: nil) { i in
                if i == 0 { forced = (cut, CutJoin.hard, false) } else { forced = nil }
                heard.insert("r\(i)")
                play()
            }
        case .choose:
            EmptyView()
        }
    }

    private func playButton(_ title: String) -> some View {
        Button { play() } label: { Label(title, systemImage: "play.fill").frame(maxWidth: .infinity) }
            .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 52))
            .disabled(playing)
    }

    // MARK: Sound

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        heard = []
        choice = nil
        earMark = nil
        revealed = false
        forced = nil
        switch round.mode {
        case .align(let start): cut = start; join = .hard
        case .pause: cut = 32; join = .hard
        case .fill: cut = 32; join = .hard
        case .markByEar: cut = 64; join = .hard
        case .compare: cut = 32; join = .fill; fillIndex = 0; lateIsA = Bool.random()
        case .intention: cut = 32; join = .hard
        case .choose: cut = 32; join = .hard
        case .direct: cut = 32; join = .fill
        case .render: break
        }
    }

    private func play() {
        let e = current()
        clock.reset(bpm: round.bpm)
        transport.play(Pattern(), genre: genre, source: .user, bars: 4, bpm: round.bpm,
                       sequence: bars(cut: e.cut, join: e.join, late: e.late), barsPerSection: 1)
        playing = true
        heard.insert("play")
        Haptics.tap()
    }

    /// The echo tail: the last chord before the cut repeats, quieter each time.
    private func echoTail(_ s: Int) {
        let e = current()
        guard e.join == .echo else { return }
        let at = clock.bar * 16 + s % 16
        guard at == e.cut - 4 else { return }
        let src = bars(cut: e.cut, join: .hard)[max(0, (e.cut - 5) / 16)]
        let local = (e.cut - 4) % 16
        guard let last = src.chords.last(where: { $0.step < (local == 0 ? 16 : local) }) else { return }
        let patch = transport.kit(for: genre).chords
        for k in 0..<3 {
            for p in last.pitches {
                engine.playNote(p, seconds: 0.15, patch: patch, velocity: Float(0.7 * pow(0.55, Double(k))),
                                delay: Double(k) * clock.stepSeconds * 1.5)
            }
        }
    }

    // MARK: Flow

    private var primaryTitle: String {
        if playing { return "Listening…" }
        switch round.mode {
        case .align: return "Lock the cut"
        case .pause, .fill: return "Keep this transition"
        case .markByEar: return earMark == nil ? "Play the section" : "Reveal the downbeats"
        case .compare: return "This one matches"
        case .intention(let d): return "Use it for \(d ? "drama" : "a smooth move")"
        case .choose: return "Join these two"
        case .direct: return "Commit the edit"
        case .render: return "Save the transition"
        }
    }

    private var primaryEnabled: Bool {
        if playing { return false }
        switch round.mode {
        case .align: return heard.contains("play")
        case .pause: return heard.count >= 3
        case .fill: return join == .fill && heard.contains("fill\(fillIndex)")
        case .markByEar: return true
        case .compare: return choice != nil && heard.contains("ref")
        case .intention: return join != .hard
        case .choose: return sectionA != sectionB
        case .direct: return heard.contains("play")
        case .render: return heard.contains("r0") && heard.contains("r1")
        }
    }

    private func primary() {
        switch round.mode {
        case .align:
            if cut % 16 == 0 {
                game.pass(game.fails == 0 ? 1 : 0.7, "On the bar line, the second section lands like it was always meant to.")
            } else {
                game.miss("The cut still lands mid-beat, so the groove trips. Drag the scissors onto a bold bar line.")
            }
        case .pause:
            game.pass(1, "A beat of silence makes everyone lean in. Then the next section hits harder.")
        case .fill:
            game.pass(1, "The \(Self.fills[fillIndex].lowercased()) points straight at the next section, so the change feels planned.")
        case .markByEar(let bar):
            if earMark == nil { play(); return }
            revealed = true
            let off = abs((earMark ?? 0) - Double(bar))
            if off <= 0.4 {
                game.pass(max(0.6, 1 - off), "Right on the downbeat of bar \(bar + 1). Your ear found the bar line.")
            } else {
                game.miss("The transition should start on a downbeat. You were \(String(format: "%.1f", off)) bars away. Feel the big “one”.")
                earMark = nil
            }
        case .compare:
            let picked = choice == 0 ? !lateIsA : lateIsA
            if picked {
                game.pass(game.fails == 0 ? 1 : 0.7, "That fill lands right on the next downbeat, just like the reference.")
            } else {
                game.miss("That one lands an eighth late, so the chorus stumbles in. Compare the very first hit after the fill.")
                choice = nil
            }
        case .intention(let dramatic):
            let ok = dramatic ? join == .pause : join != .pause
            if ok {
                game.pass(1, dramatic ? "A sudden drop-out is a shock, so the return hits like a wall." : "A fill or a fade carries you across without a jolt.")
            } else {
                game.miss(dramatic ? "That's smooth, not dramatic. Which one stops everything for a moment?" : "That's a shock, not a smooth move. Try something that carries you across.")
            }
        case .choose:
            transport.stop()
            game.pass(1, "\(Self.sectionNames[sectionA]) into \(Self.sectionNames[sectionB]). Now design the join.")
        case .direct:
            guard join != .hard else {
                game.miss("Add one transition element: a pause, a fill or an echo tail.")
                return
            }
            GoldShelf.save(GoldShelf.cut, [Double(cut), Double(CutJoin.allCases.firstIndex(of: join) ?? 0), Double(sectionA), Double(sectionB)])
            game.pass(1, "Edit committed. Next, hear it against a plain hard cut.")
        case .render:
            transport.stop()
            game.pass(1, "Saved your transition. It's ready for your mini-track.")
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
