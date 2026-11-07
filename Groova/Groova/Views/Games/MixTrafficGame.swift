//
//  MixTrafficGame.swift
//  Groova
//
//  F4.4 Mix Traffic Control. Four lanes of sound flow down into one listening point. Each lane's
//  traffic gets bigger and brighter as you push it forward. Push a lane up to bring it closer,
//  pull it back to give the others room, and watch the melody focus light at the bottom.
//

import Foundation
import QuartzCore
import SwiftUI

struct MixTrafficGame: View {
    let task: GameTask
    let rounds: [TrafficRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let names = ["Drums", "Bass", "Chords", "Melody"]
    static let symbols = ["circle.grid.2x2.fill", "waveform.path", "pianokeys", "music.note"]
    static let colors: [Color] = [GameStyle.kick, GameStyle.bass, GameStyle.chords, GameStyle.lead]
    /// Lane order for the naming round, so the lanes aren't in the usual order.
    static let shuffled = [2, 0, 3, 1]

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var levels: [Double] = [0.75, 0.75, 0.75, 0.75]
    @State private var start: [Double] = [0.75, 0.75, 0.75, 0.75]
    @State private var solo: Int?
    @State private var soloed: Set<Int> = []
    @State private var naming: Int?
    @State private var labels: [Int: Int] = [:]
    @State private var playing = false
    @State private var phase = 0
    @State private var mixA: [Double]?
    @State private var mixB: [Double]?
    @State private var focus: Int?
    @State private var hearingOriginal = false
    @State private var blindSwap = false
    @State private var blindPick: Int?
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }
    private var engine: AudioEngine { AudioEngine.shared }

    init(task: GameTask, rounds: [TrafficRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: TrafficRound { rounds[min(game.index, rounds.count - 1)] }

    /// Which stem each lane on screen plays.
    private var order: [Int] {
        if case .solo = round.mode { return Self.shuffled }
        return [0, 1, 2, 3]
    }

    private var hidesNames: Bool {
        if case .solo = round.mode { return true }
        return false
    }

    private var hidesFaders: Bool {
        if case .blind = round.mode { return true }
        return false
    }

    /// The levels you hear right now.
    private var heard: [Double] {
        if hearingOriginal { return start }
        if case .blind = round.mode, let blindPick {
            let a = mixA ?? levels, b = mixB ?? levels
            return (blindPick == 0) != blindSwap ? a : b
        }
        return levels
    }

    private var pocket: ClosedRange<Double>? {
        if case .level(_, let from) = round.mode { return from < 0.5 ? 0.78...0.98 : 0.42...0.62 }
        return nil
    }

    /// How easy the melody is to follow, 0...1.
    private var clarity: Double {
        let l = heard
        let others = (l[0] + l[1] + l[2]) / 3
        return min(1, max(0, 0.5 + (l[3] - others) * 1.4))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: detail)
                    if case .focus = round.mode { focusPicker }
                    GameStage(height: 360) { stage }
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
            let lead = solo == nil || order[solo!] == 3 ? heard[3] : 0
            playLead(Stems.lead, step: s, patch: Band.leadPatch, level: lead * 1.25, stepSeconds: clock.stepSeconds)
        }
        .onChange(of: levels) { _, _ in applyMix() }
        .onChange(of: solo) { _, _ in applyMix() }
        .onChange(of: hearingOriginal) { _, _ in applyMix() }
        .onChange(of: blindPick) { _, _ in applyMix() }
        .onDisappear {
            transport.stop()
            engine.resetEffects()
        }
    }

    private var detail: String {
        switch round.mode {
        case .priorities: return phase == 0 ? "Mix 1 of 2: make the melody the star." : "Mix 2 of 2: now make the drums drive it."
        case .alternate: return phase == 0 ? "Mix A: feature your \(Self.names[focus ?? 3].lowercased())." : "Mix B: feature a different part."
        default: return round.body
        }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation(paused: !playing)) { ctx in
            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                let laneW = (w - 40) / 4
                let t = ctx.date.timeIntervalSinceReferenceDate
                let ear = CGPoint(x: w / 2, y: h - 34)
                ZStack(alignment: .topLeading) {
                    // Roads that merge into the listening point.
                    ForEach(0..<4, id: \.self) { slot in
                        let stem = order[slot]
                        let x = 20 + laneW * (CGFloat(slot) + 0.5)
                        let lvl = solo == nil || solo == slot ? heard[stem] : 0.05
                        Path { p in
                            p.move(to: CGPoint(x: x, y: 190))
                            p.addQuadCurve(to: ear, control: CGPoint(x: x, y: h - 60))
                        }
                        .stroke(Self.colors[stem].opacity(0.15 + 0.5 * lvl), style: StrokeStyle(lineWidth: 4 + 18 * lvl, lineCap: .round))
                        // Traffic: dots flowing toward you.
                        ForEach(0..<5, id: \.self) { k in
                            let u = (t * 0.45 + Double(k) / 5).truncatingRemainder(dividingBy: 1)
                            let pt = Self.quad(CGPoint(x: x, y: 190), CGPoint(x: x, y: h - 60), ear, CGFloat(u))
                            Circle().fill(Self.colors[stem])
                                .frame(width: 5 + 14 * lvl, height: 5 + 14 * lvl)
                                .opacity(playing ? (0.3 + 0.7 * lvl) * (1 - u * 0.6) : 0)
                                .position(pt)
                        }
                    }
                    // Faders.
                    ForEach(0..<4, id: \.self) { slot in
                        let stem = order[slot]
                        laneControl(slot: slot, stem: stem)
                            .frame(width: laneW - 10, height: 176)
                            .position(x: 20 + laneW * (CGFloat(slot) + 0.5), y: 98)
                    }
                    // The listening point and the melody focus light.
                    ZStack {
                        Circle().fill(Theme.gold.opacity(0.15 + 0.6 * clarity)).frame(width: 54, height: 54)
                            .blur(radius: 8 * clarity)
                        Image(systemName: "ear.fill").font(.system(size: 22, weight: .black)).foregroundStyle(.white)
                    }
                    .position(ear)
                    if !hidesNames {
                        Text(clarity > 0.62 ? "MELODY CLEAR" : clarity > 0.45 ? "MELODY OK" : "MELODY BURIED")
                            .font(.label(10, weight: .black)).tracking(1)
                            .foregroundStyle(clarity > 0.62 ? Theme.gold : GameStyle.nightDim)
                            .position(x: ear.x + 92, y: ear.y)
                    }
                }
            }
        }
    }

    static func quad(_ a: CGPoint, _ c: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        let u = 1 - t
        return CGPoint(x: u * u * a.x + 2 * u * t * c.x + t * t * b.x, y: u * u * a.y + 2 * u * t * c.y + t * t * b.y)
    }

    private func laneControl(slot: Int, stem: Int) -> some View {
        VStack(spacing: 6) {
            Button {
                if hidesNames, let n = naming {
                    withAnimation(.spring(response: 0.3)) {
                        labels = labels.filter { $0.value != n }
                        labels[slot] = n
                        naming = nil
                    }
                    Haptics.thump()
                    return
                }
                solo = solo == slot ? nil : slot
                soloed.insert(slot)
                if !playing { startLoop() }
                Haptics.select()
            } label: {
                HStack(spacing: 4) {
                    if hidesNames {
                        Text(labels[slot].map { Self.names[$0] } ?? "?").font(.label(11, weight: .black))
                    } else {
                        Image(systemName: Self.symbols[stem]).font(.system(size: 11, weight: .black))
                        Text(Self.names[stem]).font(.label(10, weight: .black))
                    }
                }
                .foregroundStyle(solo == slot ? Theme.onBrand : GameStyle.nightText)
                .frame(maxWidth: .infinity, minHeight: 26)
                .background(Capsule().fill(solo == slot ? Self.colors[stem] : GameStyle.ink.opacity(0.1)))
            }
            .buttonStyle(.plain)
            if hidesFaders {
                RoundedRectangle(cornerRadius: 14).fill(GameStyle.ink.opacity(0.05))
                    .overlay(Text("?").font(.display(22)).foregroundStyle(GameStyle.nightDim))
            } else {
                LevelStrip(value: Binding(get: { levels[stem] }, set: { levels[stem] = $0 }),
                           color: hidesNames ? GameStyle.ink.opacity(0.6) : Self.colors[stem],
                           pocket: levelPocket(stem), locked: hearingOriginal) {
                    if !playing { startLoop() }
                }
            }
            Text(hidesNames ? "SOLO" : (solo == slot ? "SOLO" : " ")).font(.label(9, weight: .black))
                .foregroundStyle(GameStyle.nightDim)
        }
    }

    private func levelPocket(_ stem: Int) -> ClosedRange<Double>? {
        if case .level(let lane, _) = round.mode, lane == stem { return pocket }
        return nil
    }

    // MARK: Below

    private var focusPicker: some View {
        HStack(spacing: 10) {
            ForEach([3, 0], id: \.self) { i in
                ChoiceTile(title: "Feature the \(Self.names[i].lowercased())", symbol: Self.symbols[i], color: Self.colors[i],
                           selected: focus == i) {
                    focus = i
                    var l = [0.6, 0.6, 0.55, 0.6]
                    l[i] = 0.95
                    levels = l
                    if !playing { startLoop() }
                    Haptics.select()
                }
            }
        }
    }

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .solo:
            VStack(alignment: .leading, spacing: 8) {
                Text("Solo a lane to hear it alone. Then pick a name and tap the lane's label.")
                    .font(.label(13, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { n in
                        ChoiceTile(title: Self.names[n], symbol: Self.symbols[n], color: Self.colors[n], selected: naming == n,
                                   dim: labels.values.contains(n)) {
                            naming = n
                            Haptics.select()
                        }
                    }
                }
            }
        case .level:
            ABSwitch(a: "Original", b: "Yours", current: playing ? (hearingOriginal ? 0 : 1) : nil) { i in
                hearingOriginal = i == 0
                if !playing { startLoop() }
            }
        case .blind:
            VStack(spacing: 10) {
                ABSwitch(a: "Mix 1", b: "Mix 2", current: playing ? blindPick : nil) { i in
                    blindPick = i
                    if !playing { startLoop() }
                }
                if game.feedback == nil {
                    HStack(spacing: 10) {
                        Button { keepBlind(0) } label: { Text("Keep mix 1").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: accent, height: 50))
                        Button { keepBlind(1) } label: { Text("Keep mix 2").frame(maxWidth: .infinity) }
                            .buttonStyle(ChunkyButtonStyle(color: accent, height: 50))
                    }
                }
            }
        default:
            if !playing {
                Button(action: startLoop) { Label("Play the mix", systemImage: "play.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 50))
            }
        }
    }

    // MARK: Sound

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        solo = nil
        soloed = []
        labels = [:]
        naming = nil
        phase = 0
        hearingOriginal = false
        blindPick = nil
        switch round.mode {
        case .solo: levels = [0.85, 0.85, 0.85, 0.85]
        case .level(let lane, let from):
            levels = [0.72, 0.72, 0.72, 0.72]
            levels[lane] = from
        case .culprit(let lane):
            levels = [0.6, 0.6, 0.6, 0.6]
            levels[lane] = 1
        case .priorities, .alternate: levels = [0.7, 0.7, 0.7, 0.7]
        case .focus: break
        case .blind:
            blindSwap = Bool.random()
            if mixA == nil { mixA = [0.6, 0.6, 0.55, 0.95] }
            if mixB == nil { mixB = [0.95, 0.7, 0.55, 0.6] }
        }
        start = levels
    }

    private func startLoop() {
        clock.reset(bpm: 104)
        transport.play(Stems.demo.backing(), genre: genre, source: .user, bpm: 104)
        playing = true
        applyMix()
    }

    private func applyMix() {
        guard playing else { return }
        var l = heard.map { $0 * 1.3 }
        if let solo {
            let keep = order[solo]
            for i in 0..<4 where i != keep { l[i] = 0 }
        }
        var drums: [DrumTrack: Double] = [:]
        for t in DrumTrack.allCases { drums[t] = l[0] }
        engine.setMix(drums: drums, bass: l[1], chords: l[2])
    }

    // MARK: Flow

    private var primaryTitle: String {
        switch round.mode {
        case .solo: return "Check names"
        case .level, .culprit: return "Check the mix"
        case .priorities: return phase == 0 ? "Lock mix 1" : "Lock mix 2"
        case .focus: return "Mix it"
        case .alternate: return phase == 0 ? "Save mix A" : "Save mix B"
        case .blind: return "Pick one above"
        }
    }

    private var primaryEnabled: Bool {
        switch round.mode {
        case .solo: return labels.count == 4
        case .focus: return focus != nil
        case .blind: return false
        default: return playing && !hearingOriginal
        }
    }

    private func primary() {
        switch round.mode {
        case .solo:
            let right = (0..<4).filter { labels[$0] == order[$0] }.count
            if right == 4 {
                game.pass(game.fails == 0 ? 1 : 0.7, "Drums, bass, chords and melody. You can pick every part out of the jam.")
            } else {
                game.miss("\(right) of 4 are right. Solo each lane and listen: is it low, rhythmic, a held chord, or a tune?",
                          score: Double(right) / 4)
                labels = [:]
            }
        case .level(let lane, _):
            if let p = pocket, p.contains(levels[lane]) {
                game.pass(1, "That's the pocket. Same notes, it just sits in the right place now.")
            } else {
                game.miss(levels[lane] < (pocket?.lowerBound ?? 0) ? "Still too far back. Push it forward." : "Now it's on top of everything. Ease it back.")
            }
        case .culprit(let lane):
            let others = (0..<4).filter { $0 != lane }
            if others.contains(where: { abs(levels[$0] - start[$0]) > 0.08 }) {
                game.miss("You moved a lane that wasn't the problem. Only fix the loud one.")
                levels = start
            } else if levels[lane] > 0.75 {
                game.miss("Something is still shouting. Solo each lane to find it.")
            } else if levels[lane] < 0.4 {
                game.miss("You fixed it, but now it's too quiet. Bring it back a little.")
            } else {
                game.pass(game.fails == 0 ? 1 : 0.7, "The \(Self.names[lane].lowercased()) was the culprit. One move, and the traffic flows again.")
            }
        case .priorities:
            if phase == 0 {
                guard levels[3] >= levels[0] + 0.15, levels[3] >= levels[2] + 0.1 else {
                    game.miss("The melody still isn't the star. Push it up, or pull the drums and chords back.")
                    return
                }
                mixA = levels
                withAnimation { phase = 1 }
                levels = [0.7, 0.7, 0.7, 0.7]
                Haptics.success()
            } else {
                guard levels[0] >= levels[3] + 0.15 else {
                    game.miss("The drums need to lead this time. Push them past the melody.")
                    return
                }
                mixB = levels
                game.pass(1, "Two good mixes from the same parts. Each one tells your ear what matters.")
            }
        case .focus:
            game.pass(1, "Your feature is the \(Self.names[focus ?? 3].lowercased()). Mix around it.")
        case .alternate:
            let star = levels.indices.max { levels[$0] < levels[$1] } ?? 0
            let f = focus ?? 3
            if phase == 0 {
                guard star == f else {
                    game.miss("Your \(Self.names[f].lowercased()) should be the loudest lane in mix A.")
                    return
                }
                mixA = levels
                withAnimation { phase = 1 }
                Haptics.success()
            } else {
                guard star != f else {
                    game.miss("Mix B should feature a different part. Bring another lane forward.")
                    return
                }
                mixB = levels
                game.pass(1, "Two mixes saved. Next, hear them without the faders and pick one.")
            }
        case .blind:
            break
        }
    }

    private func keepBlind(_ i: Int) {
        let chosen = (i == 0) != blindSwap ? mixA : mixB
        let wasA = (i == 0) != blindSwap
        GoldShelf.save(GoldShelf.mix, chosen ?? levels)
        transport.stop()
        playing = false
        game.pass(1, "You picked mix \(wasA ? "A" : "B") with your ears alone. Saved as your mix.")
    }

    private func retry() {
        withAnimation { game.feedback = nil }
    }

    private func next() {
        if game.advance() {
            transport.stop()
            engine.resetEffects()
            onComplete(game.average)
            return
        }
        setup()
        applyMix()
    }
}
