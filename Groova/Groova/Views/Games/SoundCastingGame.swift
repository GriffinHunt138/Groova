//
//  SoundCastingGame.swift
//  Groova
//
//  F4.5 Sound Casting. You're the casting director for a four-piece band. Each role has a
//  spotlight; each audition is a card. Tap a card into a spotlight and the whole band plays it
//  straight away, notes unchanged. Only the sounds change.
//

import Foundation
import QuartzCore
import SwiftUI

struct SoundCastingGame: View {
    let task: GameTask
    let rounds: [CastRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let roleNames = ["Drums", "Bass", "Chords", "Lead"]
    static let directions = ["Warm", "Edgy", "Minimal"]
    static let directionLineups: [[Int]] = [[1, 1, 2, 2], [0, 2, 0, 0], [2, 0, 1, 1]]
    static let busy = K.tune((0..<16).map { ($0, [76, 79, 84, 79][$0 % 4], 1) })
    static let busyPatch = SynthPatch(saw: 0.9, square: 0.3, sine: 0.1, detuneCents: 12, cutoff: 5000, envAmount: 2000,
                                      filterDecay: 0.1, resonance: 0.3, attack: 0.002, decay: 0.12, sustain: 0.3,
                                      release: 0.08, gain: 0.22)

    @State private var game: GameProgress
    @State private var clock = BeatClock()
    @State private var lineup: [Int?] = [nil, nil, nil, nil]
    @State private var role = 0
    @State private var heard: Set<Int> = []
    @State private var playing = false
    @State private var soloRole: Int?
    @State private var busyOn = false
    @State private var muted: Set<Int> = []
    @State private var phase = 0
    @State private var lineupA: [Int]?
    @State private var lineupB: [Int]?
    @State private var swapRole: Int?
    @State private var hearingRef = false
    @State private var direction: Int?
    @State private var showcaseBar = -1
    @State private var setupIndex = -1
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }
    private var engine: AudioEngine { AudioEngine.shared }

    init(task: GameTask, rounds: [CastRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: CastRound { rounds[min(game.index, rounds.count - 1)] }
    private var filled: [Int] { lineup.map { $0 ?? 0 } }

    private var sounding: [Int] {
        if hearingRef, case .matchRef(let r) = round.mode { return r }
        return filled
    }

    /// Which parts play right now.
    private var active: [Bool] {
        if let soloRole { return (0..<4).map { $0 == soloRole } }
        if case .showcase = round.mode { return (0..<4).map { $0 <= max(0, showcaseBar) } }
        if case .overcrowd = round.mode { return (0..<4).map { !muted.contains($0) } }
        return [true, true, true, true]
    }

    private var counterOn: Bool {
        if case .overcrowd = round.mode { return !muted.contains(4) }
        if case .badFit = round.mode { return busyOn }
        return false
    }

    private var pattern: Pattern {
        Stems.demo.backing(drums: active[0], bass: active[1], chords: active[2])
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: detail)
                    GameStage(height: 340) { stage }
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
            if !running { playing = false }
        }
        .onDisappear {
            transport.stop()
            engine.resetEffects()
        }
    }

    private var detail: String {
        switch round.mode {
        case .lineups: return phase == 0 ? "Lineup A: cast all four roles." : "Lineup B: change at least two roles."
        case .curate: return phase == 0 ? "Cast your band for a \(Self.directions[direction ?? 0].lowercased()) sound." : "Version B: swap exactly one role."
        default: return round.body
        }
    }

    // MARK: Stage

    private var stage: some View {
        VStack(spacing: 14) {
            spotlights
            if showsAuditions {
                auditions
            } else if case .badFit = round.mode {
                versusCards
            } else if case .direction = round.mode {
                directionCards
            } else {
                Spacer()
            }
        }
        .padding(14)
    }

    private var showsAuditions: Bool {
        switch round.mode {
        case .audition, .cast, .lineups, .matchRef, .curate: return true
        default: return false
        }
    }

    private var spotlightCount: Int {
        if case .overcrowd = round.mode { return 5 }
        return 4
    }

    private var spotlights: some View {
        TimelineView(.animation(paused: !playing)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            HStack(spacing: 8) {
                ForEach(0..<spotlightCount, id: \.self) { r in
                    let isCounter = r == 4
                    let on = isCounter ? counterOn : active[r] && (lineup[r] != nil || !needsCast)
                    let a: Band.Audition? = isCounter ? nil : lineup[r].map { Band.pool(CastRole(rawValue: r)!)[$0] }
                    let color = isCounter ? Theme.miss : (a?.color ?? GameStyle.nightDim)
                    let pulse = playing && on ? 0.5 + 0.5 * sin(t * 6 + Double(r)) : 0
                    Button { tapSpotlight(r) } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                // The beam of light from above.
                                Path { p in
                                    p.move(to: CGPoint(x: 22, y: 0))
                                    p.addLine(to: CGPoint(x: 34, y: 0))
                                    p.addLine(to: CGPoint(x: 56, y: 70))
                                    p.addLine(to: CGPoint(x: 0, y: 70))
                                    p.closeSubpath()
                                }
                                .fill(LinearGradient(colors: [color.opacity(on ? 0.5 : 0.06), .clear], startPoint: .top, endPoint: .bottom))
                                .frame(width: 56, height: 70)
                                Image(systemName: isCounter ? "music.note.list" : (a?.symbol ?? "questionmark"))
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundStyle(on ? GameStyle.nightText : GameStyle.nightDim)
                                    .scaleEffect(1 + 0.12 * pulse)
                                    .offset(y: 14)
                            }
                            Text(isCounter ? "Extra lead" : Self.roleNames[r]).font(.label(10, weight: .black))
                                .foregroundStyle(role == r && showsAuditions ? accent : GameStyle.nightDim)
                            Text(isCounter ? (counterOn ? "On" : "Muted") : (a?.name ?? "Empty"))
                                .font(.label(10, weight: .heavy)).foregroundStyle(on ? GameStyle.nightText : GameStyle.nightDim)
                                .lineLimit(1).minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 16).fill(GameStyle.nightRaised.opacity(role == r && showsAuditions ? 1 : 0.6)))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(role == r && showsAuditions ? accent : .clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var needsCast: Bool {
        switch round.mode {
        case .badFit, .overcrowd, .showcase, .direction: return false
        default: return true
        }
    }

    private var auditions: some View {
        let pool = Band.pool(CastRole(rawValue: role)!)
        return VStack(alignment: .leading, spacing: 8) {
            Text("AUDITIONS · \(Self.roleNames[role].uppercased())").font(.label(11, weight: .black)).tracking(1)
                .foregroundStyle(GameStyle.nightDim)
            HStack(spacing: 10) {
                ForEach(Array(pool.enumerated()), id: \.offset) { i, a in
                    let chosen = lineup[role] == i
                    Button { audition(i) } label: {
                        VStack(spacing: 8) {
                            Image(systemName: a.symbol).font(.system(size: 24, weight: .black))
                            Text(a.name).font(.label(13, weight: .heavy))
                            if case .audition = round.mode {
                                Image(systemName: heard.contains(i) ? "checkmark.circle.fill" : "play.circle")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundStyle(chosen ? Theme.onBrand : GameStyle.nightText)
                        .frame(maxWidth: .infinity, minHeight: 110)
                        .background(RoundedRectangle(cornerRadius: 18).fill(chosen ? a.color : a.color.opacity(0.18)))
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(a.color.opacity(0.6), lineWidth: 2))
                        .scaleEffect(chosen ? 1.04 : 1)
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.3), value: chosen)
                }
            }
        }
    }

    private var versusCards: some View {
        HStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { i in
                let on = playing && busyOn == (i == 0)
                Button {
                    busyOn = i == 0
                    heard.insert(i)
                    if !playing { startBand() }
                    Haptics.select()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: i == 0 ? "sparkles" : "music.note").font(.system(size: 26, weight: .black))
                        Text(i == 0 ? "Busy and bright" : "Simple").font(.label(14, weight: .heavy))
                        Text(i == 0 ? "An extra part racing on top" : "Just the band").font(.label(11, weight: .semibold))
                            .foregroundStyle(GameStyle.nightDim)
                    }
                    .foregroundStyle(GameStyle.nightText)
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .background(RoundedRectangle(cornerRadius: 18).fill(on ? accent.opacity(0.35) : GameStyle.nightRaised))
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(on ? accent : .clear, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var directionCards: some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                ChoiceTile(title: Self.directions[i], symbol: ["flame.fill", "bolt.fill", "circle.dotted"][i],
                           color: [GameStyle.bass, GameStyle.kick, GameStyle.chords][i], selected: direction == i) {
                    direction = i
                    lineup = Self.directionLineups[i].map { Optional($0) }
                    if playing { engine.update(kit: Band.kit(genre, lineup: sounding)) } else { startBand() }
                    Haptics.select()
                }
            }
        }
    }

    // MARK: Below

    @ViewBuilder private var below: some View {
        switch round.mode {
        case .matchRef:
            Button {
                hearingRef.toggle()
                if playing { engine.update(kit: Band.kit(genre, lineup: sounding)) } else { startBand() }
            } label: {
                Label(hearingRef ? "Back to mine" : "Hear the reference", systemImage: hearingRef ? "arrow.uturn.left" : "ear")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(color: hearingRef ? Theme.gold : Theme.surfaceHigh, textColor: Theme.text, height: 52))
        case .overcrowd:
            Text("Tap a spotlight to mute or unmute that part.").font(.label(13, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
        case .lineups, .curate:
            if phase == 1, let a = lineupA {
                ABSwitch(a: "Hear A", b: "Hear B", current: nil) { i in
                    let l = i == 0 ? a : filled
                    if !playing { startBand() }
                    engine.update(kit: Band.kit(genre, lineup: l))
                    leadOverride = Band.lead[l[3]].patch
                }
            }
        default:
            if playing {
                Button { transport.stop(); playing = false } label: {
                    Label("Stop the band", systemImage: "stop.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: Theme.surfaceHigh, textColor: Theme.text, height: 48))
            }
        }
    }

    @State private var leadOverride: SynthPatch?

    // MARK: Sound

    private func setup() {
        guard setupIndex != game.index else { return }
        setupIndex = game.index
        heard = []
        soloRole = nil
        busyOn = false
        muted = []
        phase = 0
        hearingRef = false
        showcaseBar = -1
        leadOverride = nil
        role = 0
        switch round.mode {
        case .audition(let r):
            role = r.rawValue
            soloRole = r.rawValue
            lineup = [0, 0, 0, 0]
            lineup[role] = nil
        case .cast, .lineups, .matchRef:
            lineup = [nil, nil, nil, nil]
        case .curate:
            lineup = direction.map { Self.directionLineups[$0].map { Optional($0) } } ?? [nil, nil, nil, nil]
        case .badFit, .overcrowd:
            lineup = [0, 1, 0, 0]
        case .direction, .showcase:
            if lineup.contains(where: { $0 == nil }) { lineup = [0, 1, 0, 0] }
        }
    }

    private func startBand() {
        clock.reset(bpm: 104)
        transport.play(pattern, genre: genre, source: .user, bpm: 104, kit: Band.kit(genre, lineup: sounding))
        playing = true
    }

    private func audition(_ i: Int) {
        Haptics.select()
        if case .curate = round.mode, phase == 1, let a = lineupA {
            // Version B: only one role may change.
            if let s = swapRole, s != role, lineup[s] != Optional(a[s]) {
                lineup[s] = a[s]
            }
            swapRole = lineup[role] == i && a[role] == i ? nil : role
        }
        lineup[role] = i
        heard.insert(i)
        leadOverride = nil
        if playing {
            engine.update(kit: Band.kit(genre, lineup: sounding))
            transport.liveUpdate(pattern)
        } else {
            startBand()
        }
        // Move to the next empty role when casting.
        if case .audition = round.mode { return }
        if let nextRole = (0..<4).first(where: { lineup[$0] == nil }) {
            withAnimation(.spring(response: 0.3)) { role = nextRole }
        }
    }

    private func tapSpotlight(_ r: Int) {
        Haptics.select()
        switch round.mode {
        case .overcrowd:
            if muted.contains(r) { muted.remove(r) } else { muted.insert(r) }
            if playing { transport.liveUpdate(pattern) } else { startBand() }
        case .audition:
            break
        default:
            if showsAuditions, r < 4 { withAnimation(.spring(response: 0.3)) { role = r } }
        }
    }

    private func onStep(_ s: Int) {
        let step = s % 16
        if case .showcase = round.mode {
            if step == 0 {
                if clock.bar >= 4 {
                    transport.stop()
                    playing = false
                    showcaseBar = 3
                    return
                }
            }
            if step == 15 {
                showcaseBar = min(3, clock.bar + 1)
                transport.liveUpdate(pattern)
            }
        }
        if active[3] {
            let patch = leadOverride ?? Band.lead[sounding[3] % 3].patch
            playLead(Stems.lead, step: step, patch: patch, level: 1, stepSeconds: clock.stepSeconds)
        }
        if counterOn {
            playLead(Self.busy, step: step, patch: Self.busyPatch, level: 0.9, stepSeconds: clock.stepSeconds)
        }
    }

    // MARK: Flow

    private var primaryTitle: String {
        switch round.mode {
        case .audition: return "I've heard them all"
        case .cast: return "Lock the lineup"
        case .badFit: return "The simple one is clearer"
        case .overcrowd: return "Check the band"
        case .lineups: return phase == 0 ? "Save lineup A" : "Save lineup B"
        case .matchRef: return "Check"
        case .direction: return "Go \(Self.directions[direction ?? 0].lowercased())"
        case .curate: return phase == 0 ? "Save version A" : "Save version B"
        case .showcase:
            if playing { return "Showcase…" }
            return showcaseBar >= 3 ? "Save my palette" : "Run the showcase"
        }
    }

    private var primaryEnabled: Bool {
        switch round.mode {
        case .audition: return heard.count >= 3
        case .cast, .lineups, .matchRef, .curate: return !lineup.contains { $0 == nil } && !hearingRef
        case .badFit: return heard.count >= 2
        case .overcrowd: return playing
        case .direction: return direction != nil
        case .showcase: return !playing
        }
    }

    private func primary() {
        switch round.mode {
        case .audition(let r):
            game.pass(1, "Three \(Self.roleNames[r.rawValue].lowercased()) sounds, the same notes. Each one gives the band a different personality.")
        case .cast:
            game.pass(1, "That's your band. Swap any card and the same song changes character.")
        case .badFit:
            busyOn = false
            game.pass(1, "The busy part fights the melody for the same space. Simpler parts and softer sounds let the tune through.")
        case .overcrowd:
            if muted == [4] {
                game.pass(game.fails == 0 ? 1 : 0.7, "The extra lead was crowding the melody. Four clear roles beat five crowded ones.")
            } else if muted.isEmpty {
                game.miss("Five parts are fighting. Mute the one that's in the melody's way.")
            } else {
                game.miss("That part was holding up the band. Unmute it and find the one that's crowding the melody.")
            }
        case .lineups:
            if phase == 0 {
                lineupA = filled
                withAnimation { phase = 1 }
                Haptics.success()
            } else {
                let diff = (0..<4).filter { filled[$0] != lineupA?[$0] }.count
                guard diff >= 2 else {
                    game.miss("Lineup B is too close to A. Change at least two roles.")
                    return
                }
                lineupB = filled
                game.pass(1, "Same notes, two bands. Use the A and B buttons to hear how different they feel.")
            }
        case .matchRef(let ref):
            let right = (0..<4).filter { filled[$0] == ref[$0] }.count
            if right >= 3 {
                game.pass(Double(right) / 4, right == 4 ? "A perfect match for the reference." : "Three of four roles match. Very close.")
            } else {
                game.miss("\(right) of 4 match. Flip to the reference and listen to one role at a time.", score: Double(right) / 4)
            }
        case .direction:
            game.pass(1, "\(Self.directions[direction ?? 0]) it is. There's no wrong direction, just yours.")
        case .curate:
            if phase == 0 {
                lineupA = filled
                swapRole = nil
                withAnimation { phase = 1 }
                Haptics.success()
            } else {
                let diff = (0..<4).filter { filled[$0] != lineupA?[$0] }.count
                guard diff == 1 else {
                    game.miss(diff == 0 ? "Swap one role to make version B." : "Version B should change just one role.")
                    return
                }
                lineupB = filled
                game.pass(1, "Version B saved. One swap, a new colour. Keep whichever you like for the showcase.")
            }
        case .showcase:
            if showcaseBar < 3 {
                showcaseBar = 0
                lineup = (lineupB ?? lineupA ?? filled).map { Optional($0) }
                clock.reset(bpm: 104)
                transport.play(pattern, genre: genre, source: .user, bpm: 104, kit: Band.kit(genre, lineup: filled))
                playing = true
                return
            }
            GoldShelf.save(GoldShelf.palette, filled.map(Double.init))
            game.pass(1, "Your band is saved. It'll play your mini-track at the end of the course.")
        }
    }

    private func retry() {
        withAnimation { game.feedback = nil }
    }

    private func next() {
        if game.advance() {
            transport.stop()
            onComplete(game.average)
            return
        }
        transport.stop()
        playing = false
        setup()
    }
}
