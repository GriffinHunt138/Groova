//
//  TetherGame.swift
//  Groova
//
//  F3.4 Kick-Bass Tether. Kick pucks sit on the floor of a one-bar track; bass blobs float above
//  them, tied to the nearest kick by an elastic tether. Drag a bass blob sideways and the tether
//  stretches as it moves off the kick; drag it up or down to change its note. Every move is heard.
//

import Foundation
import QuartzCore
import SwiftUI

struct TetherGame: View {
    let task: GameTask
    let rounds: [TetherRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, done }
    private struct Hit: Equatable { var step: Int; var pitch: Int; var length: Int; var bar = 0 }

    /// Bass rows, low to high: C2 up to A2.
    static let bassRows = [36, 38, 40, 41, 43, 45, 47, 48]

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var phase: Phase = .ready
    @State private var hits: [Hit] = []
    @State private var dragging: Int?
    @State private var grab: (step: Int, pitch: Int)?
    @State private var hearingRef = false
    @State private var loop: [Triad] = [.c, .am]
    @State private var take: [Hit] = []
    @State private var flash: Set<Int> = []
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, rounds: [TetherRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: TetherRound { rounds[min(game.index, rounds.count - 1)] }
    private var chords: [Triad] {
        switch round.mode {
        case .perform, .compare, .chooseLoop: return loop
        default: return round.chords
        }
    }
    private var bars: Int { round.mode == .roots ? chords.count : 1 }
    private func bassRoot(_ t: Triad) -> Int { 36 + ((t.root % 12) + 12) % 12 }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    if case .chooseLoop(let loops) = round.mode, phase != .done { loopPicker(loops) }
                    GameStage(height: round.mode == .perform ? 260 : 320) { stage }
                    if round.mode == .perform, phase == .playing { bassPads }
                    if phase != .ready { extras }
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
        .onChange(of: transport.step) { _, s in
            guard phase == .playing else { return }
            clock.follow(s)
            pulse(s)
        }
        .onChange(of: transport.isRunning) { _, running in
            if !running, phase == .playing, round.mode == .perform { judgePerformance() }
        }
        .onDisappear { transport.stop() }
    }

    private var primaryTitle: String {
        switch phase {
        case .ready:
            switch round.mode {
            case .chooseLoop: return "Keep this loop"
            case .perform: return "Record four bars"
            case .compare: return "Compare the takes"
            default: return "Start the low end"
            }
        case .done: return "Locked"
        case .playing:
            switch round.mode {
            case .together: return "I feel them together"
            case .perform: return "Recording…"
            default: return "Check"
            }
        }
    }

    private var primaryEnabled: Bool {
        if phase == .ready { return true }
        return phase == .playing && round.mode != .perform && !hearingRef
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: phase != .playing)) { _ in
            GeometryReader { geo in
                scene(size: geo.size, pos: clock.now())
            }
        }
    }

    private func scene(size: CGSize, pos: Double?) -> some View {
        let w = size.width, h = size.height
        let left: CGFloat = 18, right = w - 18
        let barW = (right - left) / CGFloat(bars)
        let floorY = h - 40
        let topY: CGFloat = 56
        let xOf: (Int, Int) -> CGFloat = { bar, s in left + barW * CGFloat(bar) + barW * (CGFloat(s) + 0.5) / 16 }
        let yOf: (Int) -> CGFloat = { p in
            let i = Self.bassRows.firstIndex(of: p) ?? Self.bassRows.enumerated().min { abs($0.element - p) < abs($1.element - p) }!.offset
            return floorY - 40 - (floorY - 40 - topY) * CGFloat(i) / CGFloat(Self.bassRows.count - 1)
        }
        let kicks = (0..<16).filter { round.kick.kick[$0] }
        let p = pos ?? -1
        let curBar = p >= 0 ? Int(p / 16) % bars : -1
        let cur = p >= 0 ? p.truncatingRemainder(dividingBy: 16) : -1
        return ZStack(alignment: .topLeading) {
            // Bars and chord names.
            ForEach(0..<bars, id: \.self) { b in
                RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(curBar == b ? 0.05 : 0.02))
                    .frame(width: barW - 6, height: floorY - topY + 30)
                    .position(x: left + barW * (CGFloat(b) + 0.5), y: (floorY + topY) / 2)
                Text(chords[min(b, chords.count - 1)].name)
                    .font(.label(12, weight: .black))
                    .foregroundStyle(GameStyle.nightDim)
                    .position(x: left + barW * (CGFloat(b) + 0.5), y: topY - 12)
            }
            // Root anchors for the roots round.
            if round.mode == .roots {
                ForEach(0..<bars, id: \.self) { b in
                    let r = bassRoot(chords[b])
                    Capsule().strokeBorder(Theme.gold.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .frame(width: barW * 0.5, height: 22)
                        .position(x: left + barW * (CGFloat(b) + 0.5), y: yOf(r))
                }
            }
            // Tethers.
            ForEach(Array(hits.enumerated()), id: \.offset) { _, hit in
                let near = kicks.min { abs($0 - hit.step) < abs($1 - hit.step) } ?? hit.step
                let a = CGPoint(x: xOf(hit.bar, hit.step), y: yOf(hit.pitch))
                let k = CGPoint(x: xOf(hit.bar, near), y: floorY)
                let stretch = abs(hit.step - near)
                Path { path in
                    path.move(to: a)
                    path.addQuadCurve(to: k, control: CGPoint(x: (a.x + k.x) / 2 + CGFloat(stretch) * 6, y: (a.y + k.y) / 2 + 20))
                }
                .stroke(stretch == 0 ? Theme.gold.opacity(0.8) : GameStyle.snare.opacity(0.6),
                        style: StrokeStyle(lineWidth: stretch == 0 ? 3 : 2, lineCap: .round, dash: stretch == 0 ? [] : [3, 4]))
            }
            // Kick pucks.
            ForEach(0..<bars, id: \.self) { b in
                ForEach(kicks, id: \.self) { s in
                    let on = curBar == b && cur >= Double(s) && cur < Double(s) + 1.2
                    Circle().fill(GameStyle.kick.opacity(on ? 1 : 0.55))
                        .frame(width: on ? 30 : 24, height: on ? 30 : 24)
                        .shadow(color: on ? GameStyle.kick : .clear, radius: 12)
                        .position(x: xOf(b, s), y: floorY)
                }
            }
            // Bass blobs.
            ForEach(Array(hits.enumerated()), id: \.offset) { i, hit in
                let on = flash.contains(i)
                let len = barW * CGFloat(hit.length) / 16
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(GameStyle.snare.opacity(on ? 1 : 0.75))
                    .frame(width: max(26, len), height: 26)
                    .overlay(Text(noteName(hit.pitch)).font(.label(11, weight: .black)).foregroundStyle(.white))
                    .overlay(alignment: .trailing) {
                        if case .length = round.mode {
                            Capsule().fill(Color.white).frame(width: 6, height: 18).padding(.trailing, 4)
                        }
                    }
                    .shadow(color: on ? GameStyle.snare : .clear, radius: 12)
                    .position(x: xOf(hit.bar, hit.step) - barW / 32 + max(26, len) / 2, y: yOf(hit.pitch))
                    .scaleEffect(dragging == i ? 1.1 : 1)
            }
            // Playhead.
            if cur >= 0 {
                Rectangle().fill(Color.white.opacity(0.12)).frame(width: 2, height: floorY - topY + 20)
                    .position(x: xOf(curBar, 0) - barW / 32 + barW * CGFloat(cur) / 16, y: (floorY + topY) / 2)
            }
            StageTag(text: tag, color: phase == .playing ? accent : GameStyle.nightDim).padding(14)
        }
        .frame(width: w, height: h)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { v in drag(v, left: left, barW: barW, xOf: xOf, yOf: yOf, floorY: floorY, topY: topY) }
            .onEnded { _ in dragging = nil; grab = nil })
    }

    private var tag: String {
        switch phase {
        case .ready: return task.name
        case .done: return "Locked"
        case .playing:
            if hearingRef { return "Reference" }
            switch round.mode {
            case .together: return "Together"
            case .slide: return "Drag a bass note"
            case .roots: return "Follow the chords"
            case .rhythm: return "Place the pulses"
            case .length: return "Drag the end handle"
            case .perform: return clock.bar == 0 ? "Count-in" : "Bar \(clock.bar) of 4"
            default: return "Listen"
            }
        }
    }

    // MARK: Below

    @ViewBuilder private var extras: some View {
        switch round.mode {
        case .slide(let from, let to):
            HStack(spacing: 10) {
                Button { audition([from]) } label: { Label("Locked", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                Button { audition([to]) } label: { Label("Offset", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
            }
        case .rhythm, .length:
            Button(action: toggleRef) {
                Label(hearingRef ? "Back to mine" : "Hear the target", systemImage: hearingRef ? "arrow.uturn.left" : "ear")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: hearingRef ? Theme.gold : Theme.surfaceHigh, textColor: Theme.text, height: 52))
        case .compare:
            if game.feedback == nil {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Button { playTake(take) } label: { Label("Your take", systemImage: "play.fill").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                        Button { playTake(onBeat) } label: { Label("On the beat", systemImage: "play").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
                    }
                    HStack(spacing: 10) {
                        Button { keep(true) } label: { Text("Keep mine").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 50))
                        Button { keep(false) } label: { Text("Keep on-beat").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: accent, textColor: Theme.onBrand, height: 50))
                    }
                }
            }
        default:
            EmptyView()
        }
    }

    private func loopPicker(_ loops: [[Triad]]) -> some View {
        HStack(spacing: 10) {
            ForEach(Array(loops.enumerated()), id: \.offset) { _, l in
                Button {
                    Haptics.select()
                    loop = l
                    transport.play(pattern(for: l.map { Hit(step: 0, pitch: bassRoot($0), length: 6) }, chords: l)[0], genre: genre,
                                   source: .demo, bars: l.count, swing: 0, bpm: round.bpm,
                                   sequence: pattern(for: l.enumerated().map { Hit(step: 0, pitch: bassRoot($0.element), length: 6, bar: $0.offset) }, chords: l),
                                   barsPerSection: 1)
                } label: {
                    Text(l.map(\.name).joined(separator: " → ")).frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: loop == l ? accent : Theme.surfaceHigh,
                                               textColor: loop == l ? Theme.onBrand : Theme.text, height: 52))
            }
        }
    }

    private var bassPads: some View {
        let bar = max(0, clock.bar - 1)
        let r = bassRoot(chords[bar % max(1, chords.count)])
        return HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { k in
                let p = [r, r + 7, r + 12][k]
                let name = ["Root", "Fifth", "High root"][k]
                Button {} label: {
                    VStack(spacing: 2) {
                        Text(noteName(p)).font(.display(22))
                        Text(name).font(.label(11, weight: .bold)).opacity(0.8)
                    }
                    .frame(maxWidth: .infinity).frame(height: 86)
                }
                .buttonStyle(ChunkyButtonStyle(color: GameStyle.snare, textColor: Theme.onBrand, height: 86))
                .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in
                    if !padHeld.contains(p) { padHeld.insert(p); playPad(p) }
                }.onEnded { _ in _ = padHeld.remove(p) })
            }
        }
    }

    @State private var padHeld: Set<Int> = []

    // MARK: Sound

    private func pattern(for hs: [Hit], chords cs: [Triad]) -> [Pattern] {
        (0..<max(1, cs.count)).map { b in
            var p = round.kick
            p.bass = hs.filter { $0.bar == b }.map { NoteEvent($0.step, $0.pitch, $0.length) }
            p.chords = [ChordEvent(step: 0, pitches: cs[b].pitches, length: 15)]
            p.hat = [false, false, true, false, false, false, true, false, false, false, true, false, false, false, true, false]
            return p
        }
    }

    private func play(_ hs: [Hit], bars n: Int? = nil) {
        let seq = pattern(for: hs, chords: Array(chords.prefix(bars)))
        transport.play(seq[0], genre: genre, source: .user, bars: n, swing: 0, bpm: round.bpm,
                       sequence: seq.count > 1 ? seq : [], barsPerSection: 1)
    }

    private func refresh() {
        guard phase == .playing, !hearingRef else { return }
        let seq = pattern(for: hits, chords: Array(chords.prefix(bars)))
        if seq.count > 1 { AudioEngine.shared.update(sequence: seq) } else { transport.liveUpdate(seq[0]) }
    }

    private func pulse(_ s: Int) {
        guard s >= 0 else { return }
        let b = clock.bar % max(1, bars)
        let on = Set(hits.indices.filter { hits[$0].step == s && hits[$0].bar == b })
        guard !on.isEmpty else { return }
        withAnimation(.easeOut(duration: 0.05)) { flash = on }
        withAnimation(.easeOut(duration: 0.3).delay(0.08)) { flash = [] }
    }

    private func audition(_ steps: [Int]) {
        Haptics.tap()
        var hs = [Hit(step: 0, pitch: 36, length: 3)]
        hs += steps.map { Hit(step: $0, pitch: 36, length: 3) }
        clock.reset(bpm: round.bpm)
        transport.play(pattern(for: hs, chords: [chords[0]])[0], genre: genre, source: .demo, bars: 2, swing: 0, bpm: round.bpm)
    }

    private func playPad(_ p: Int) {
        Haptics.thump()
        let kit = transport.kit(for: genre)
        AudioEngine.shared.playNote(p, seconds: 0.25, patch: kit.bass)
        guard phase == .playing, let pos = clock.now(), clock.bar >= 1 else { return }
        let step = Int(pos.rounded()) % 16
        let bar = Int(pos.rounded()) / 16 - 1
        if bar >= 0, bar < 4 { take.append(Hit(step: step, pitch: p, length: 2, bar: bar)) }
    }

    private var onBeat: [Hit] {
        (0..<4).flatMap { b in [0, 8].map { Hit(step: $0, pitch: bassRoot(loop[b % loop.count]), length: 4, bar: b) } }
    }

    private func playTake(_ t: [Hit]) {
        let cs = (0..<4).map { loop[$0 % loop.count] }
        let seq = pattern(for: t, chords: cs)
        transport.play(seq[0], genre: genre, source: .demo, bars: 4, swing: 0, bpm: round.bpm, sequence: seq, barsPerSection: 1)
    }

    // MARK: Touch

    private func drag(_ v: DragGesture.Value, left: CGFloat, barW: CGFloat, xOf: (Int, Int) -> CGFloat, yOf: (Int) -> CGFloat,
                      floorY: CGFloat, topY: CGFloat) {
        guard phase == .playing, !hearingRef else { return }
        if dragging == nil {
            // Grab the closest bass blob.
            let best = hits.indices.min { a, b in
                hypot(xOf(hits[a].bar, hits[a].step) - v.startLocation.x, yOf(hits[a].pitch) - v.startLocation.y)
                    < hypot(xOf(hits[b].bar, hits[b].step) - v.startLocation.x, yOf(hits[b].pitch) - v.startLocation.y)
            }
            guard let best, canMove(best) else { return }
            dragging = best
            grab = (hits[best].step, hits[best].pitch)
        }
        guard let i = dragging, let g = grab else { return }
        var hit = hits[i]
        switch round.mode {
        case .slide, .rhythm:
            let s = max(0, min(15, g.step + Int((v.translation.width / (barW / 16)).rounded())))
            hit.step = s
        case .roots:
            let rowH = (floorY - 40 - topY) / CGFloat(Self.bassRows.count - 1)
            let gi = Self.bassRows.firstIndex(of: g.pitch) ?? 0
            let ni = max(0, min(Self.bassRows.count - 1, gi - Int((v.translation.height / rowH).rounded())))
            hit.pitch = Self.bassRows[ni]
        case .length:
            hit.length = max(1, min(16, Int(((v.location.x - left) / (barW / 16)).rounded()) - hit.step))
        default: return
        }
        if hit != hits[i] {
            hits[i] = hit
            Haptics.select()
            if round.mode == .roots { AudioEngine.shared.playNote(hit.pitch, seconds: 0.3, patch: transport.kit(for: genre).bass) }
            if game.feedback?.kind == .retry { withAnimation { game.feedback = nil } }
            refresh()
        }
    }

    private func canMove(_ i: Int) -> Bool {
        switch round.mode {
        case .slide(let from, _): return hits[i].step != 0 || from == 0
        case .rhythm, .roots, .length: return true
        default: return false
        }
    }

    private func toggleRef() {
        Haptics.select()
        hearingRef.toggle()
        if hearingRef {
            var ref = hits
            switch round.mode {
            case .rhythm(let t): ref = t.map { Hit(step: $0, pitch: 36, length: 2) }
            case .length(let n): ref = [Hit(step: 0, pitch: 36, length: n)]
            default: break
            }
            let seq = pattern(for: ref, chords: [chords[0]])
            transport.play(seq[0], genre: genre, source: .reference, bars: nil, swing: 0, bpm: round.bpm)
        } else {
            play(hits)
        }
    }

    // MARK: Flow

    private func primary() {
        if phase == .ready { start(); return }
        switch round.mode {
        case .together:
            finish("Kick and bass hit together, so the low end feels like one big thump.")
        case .slide(_, let to):
            if hits.contains(where: { $0.step == to }) {
                finish("The bass now answers between the kicks instead of sitting on top of them. Hear the bounce?")
            } else {
                game.miss("Slide the second bass note to step \(to + 1), half a beat after the kick on beat 2.")
            }
        case .roots:
            let wrong = (0..<bars).filter { b in hits.first { $0.bar == b }.map { $0.pitch % 12 != chords[b].root % 12 } ?? true }
            if wrong.isEmpty {
                finish("Each bass note is the chord's root. The bass and chords now agree.")
            } else {
                game.miss("Bar \(wrong.map { "\($0 + 1)" }.joined(separator: " and ")) doesn't match its chord yet. Drag the bass to the gold anchor.")
            }
        case .rhythm(let t):
            let mine = Set(hits.map(\.step))
            if mine == Set(t) {
                finish("Three pulses, right where the target has them.")
            } else {
                let right = mine.intersection(t).count
                game.miss("\(right) of \(t.count) in place. Hear the target and listen for where each bass note lands against the kick.",
                          score: Double(right) / Double(t.count))
            }
        case .length(let n):
            let len = hits.first?.length ?? 16
            if abs(len - n) <= 1 {
                finish("Shorter bass, cleaner kick. Now both low sounds have their own space.")
            } else {
                game.miss(len > n ? "Still too long. The bass is covering the kick. Pull the handle left." : "A bit short now. Let it ring a little longer.")
            }
        default: break
        }
    }

    private func start() {
        clock.reset(bpm: round.bpm)
        hearingRef = false
        switch round.mode {
        case .together:
            hits = [Hit(step: 0, pitch: 36, length: 3), Hit(step: 8, pitch: 36, length: 3)]
        case .slide(let from, _):
            hits = [Hit(step: 0, pitch: 36, length: 3), Hit(step: from, pitch: 36, length: 3)]
        case .roots:
            hits = (0..<bars).map { Hit(step: 0, pitch: 36, length: 8, bar: $0) }
        case .rhythm:
            hits = [Hit(step: 0, pitch: 36, length: 2), Hit(step: 4, pitch: 36, length: 2), Hit(step: 8, pitch: 36, length: 2)]
        case .length:
            hits = [Hit(step: 0, pitch: 36, length: 16)]
        case .chooseLoop:
            withAnimation { phase = .done }
            game.pass(1, "Your loop: \(loop.map(\.name).joined(separator: " → ")). Its roots will guide your bassline.", title: "Loop chosen")
            return
        case .perform:
            take = []
            let cs = (0..<4).map { loop[$0 % loop.count] }
            let seq = [round.kick] + pattern(for: [], chords: cs)
            withAnimation { phase = .playing }
            transport.play(seq[0], genre: genre, source: .reference, bars: 5, swing: 0, bpm: round.bpm,
                           sequence: seq, barsPerSection: 1)
            return
        case .compare:
            if take.isEmpty { take = onBeat }
            withAnimation { phase = .done }
            playTake(take)
            return
        }
        withAnimation { phase = .playing }
        play(hits)
    }

    private func judgePerformance() {
        withAnimation { phase = .done }
        let offbeat = take.filter { $0.step % 4 != 0 }.count
        let rootsHit = (0..<4).filter { b in take.contains { $0.bar == b && $0.pitch % 12 == loop[b % loop.count].root % 12 } }.count
        if take.count < 4 {
            game.miss("Play more notes. Aim for at least one per bar, starting on each chord's root.")
        } else if offbeat == 0 {
            game.miss("Every note landed on a beat. Slip at least one in between the kicks.")
        } else if rootsHit < 3 {
            game.miss("Follow the chords: hit the Root pad in each bar as the chord changes.", score: 0.5)
        } else {
            game.pass(1, "\(take.count) notes, \(offbeat) between the beats, roots in \(rootsHit) of 4 bars. That's a bassline.", title: "Your bassline")
            playTake(take)
        }
    }

    private func keep(_ mine: Bool) {
        Haptics.success()
        playTake(mine ? take : onBeat)
        game.pass(1, mine ? "You kept your own bassline. It moves with the kick instead of just copying it."
                          : "You kept the solid on-beat version. Sometimes simple holds the track together best.", title: "Saved")
    }

    private func finish(_ msg: String) {
        withAnimation { phase = .done }
        game.pass(1, msg)
    }

    private func retry() {
        withAnimation { game.feedback = nil }
        if phase == .done {
            transport.stop()
            phase = .ready
        }
    }

    private func next() {
        transport.stop()
        if game.advance() {
            onComplete(game.average)
        } else {
            phase = .ready
            hits = []
        }
    }
}
