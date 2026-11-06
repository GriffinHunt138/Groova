//
//  SoundXRayGame.swift
//  Groova
//
//  F4.1 Sound X-Ray. Every sound shows up as a glowing fingerprint: how it starts, how it holds
//  and how it fades, textured by how bright it is. Tap a fingerprint to hear it, swipe across
//  one to peel it into attack, body and tail, and build a hybrid from two sounds.
//

import Foundation
import QuartzCore
import SwiftUI

struct SoundXRayGame: View {
    let task: GameTask
    let rounds: [XRayRound]
    let genre: Genre
    let onComplete: (Double) -> Void

    static let melody = [60, 64, 67, 72]
    static let briefs = ["Sharp and percussive", "Soft and floating", "Bright and sustained"]

    @State private var game: GameProgress
    @State private var heard: Set<Int> = []
    @State private var playedAt: [Int: Double] = [:]
    @State private var choice: Int?
    @State private var picks: Set<Int> = []
    @State private var zone: Int?
    @State private var zones: Set<Int> = []
    @State private var brief: Int?
    @State private var front: SoundVoice?
    @State private var tail: SoundVoice?
    @State private var blend = 0.5
    @State private var hybridPlays = 0
    @State private var name = ""
    @Environment(\.accent) private var accent

    init(task: GameTask, rounds: [XRayRound], genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.rounds = rounds
        self.genre = genre
        self.onComplete = onComplete
        _game = State(initialValue: GameProgress(total: rounds.count))
    }

    private var round: XRayRound { rounds[min(game.index, rounds.count - 1)] }
    private var engine: AudioEngine { AudioEngine.shared }
    private static let colors: [Color] = [GameStyle.lead, GameStyle.chords, GameStyle.snare, GameStyle.kick, Color(hex: 0x5CE0B8)]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(task: task, round: game.index, total: rounds.count, title: round.title, detail: round.body)
                    GameStage(height: 300) { stage }
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
        .onDisappear { Transport.shared.stop() }
    }

    // MARK: Stage

    @ViewBuilder private var stage: some View {
        switch round.mode {
        case .identities(let voices): identities(voices)
        case .peel(let v): peel(v)
        case .match(let mystery, let options): mysteryStage(mystery: [mystery], options: options)
        case .layers(let a, let b, let options): mysteryStage(mystery: [a, b], options: options)
        case .brief: briefStage
        case .hybrid: hybridStage
        case .reveal: revealStage
        }
    }

    /// The locked melody on top, one fingerprint per instrument below.
    private func identities(_ voices: [SoundVoice]) -> some View {
        VStack(spacing: 14) {
            HStack {
                StageTag(text: "MIDI locked", color: accent)
                Spacer()
                HStack(spacing: 6) {
                    ForEach(Array(Self.melody.enumerated()), id: \.offset) { i, n in
                        RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.75))
                            .frame(width: 30, height: 12)
                            .offset(y: CGFloat(-(n - 60)) * 1.4)
                    }
                }
                .frame(height: 34)
            }
            HStack(spacing: 10) {
                ForEach(Array(voices.enumerated()), id: \.offset) { i, v in
                    fingerprintCard(v, index: i, label: v.name, hidden: false) {
                        sing(v.patch, Self.melody)
                        mark(i)
                    }
                }
            }
        }
        .padding(16)
    }

    private func fingerprintCard(_ v: SoundVoice, index i: Int, label: String, hidden: Bool, selected: Bool = false,
                                 action: @escaping () -> Void) -> some View {
        let color = Self.colors[i % Self.colors.count]
        return Button(action: action) {
            VStack(spacing: 8) {
                Fingerprint(patch: v.patch, color: color, playedAt: playedAt[i], hidden: hidden)
                    .frame(height: 110)
                    .padding(.horizontal, 6)
                HStack(spacing: 5) {
                    if !hidden { Image(systemName: v.symbol).font(.system(size: 12, weight: .bold)) }
                    Text(label).font(.label(13, weight: .heavy))
                }
                .foregroundStyle(heard.contains(i) || selected ? Color.white : GameStyle.nightDim)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 18).fill(selected ? color.opacity(0.25) : GameStyle.nightRaised))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(selected ? color : .clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    /// One long note, split into attack, body and tail. Drag across it to hear each slice.
    private func peel(_ v: SoundVoice) -> some View {
        let edges: [CGFloat] = [0, 0.14, 0.5, 1]
        let names = ["ATTACK", "BODY", "TAIL"]
        return GeometryReader { g in
            let w = g.size.width - 32, h = g.size.height - 90
            ZStack(alignment: .topLeading) {
                Fingerprint(patch: v.patch, color: GameStyle.lead, hold: 0.9, playedAt: playedAt[9])
                    .frame(width: w, height: h)
                    .position(x: 16 + w / 2, y: 50 + h / 2)
                ForEach(0..<3, id: \.self) { z in
                    let x0 = 16 + w * edges[z], x1 = 16 + w * edges[z + 1]
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(zone == z ? 0.16 : 0.0))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(zones.contains(z) ? Theme.gold.opacity(0.7) : Color.white.opacity(0.15),
                                          style: StrokeStyle(lineWidth: 2, dash: zones.contains(z) ? [] : [5, 5])))
                        .frame(width: x1 - x0 - 4, height: h + 20)
                        .position(x: (x0 + x1) / 2, y: 50 + h / 2)
                    Text(names[z]).font(.label(11, weight: .black)).tracking(1)
                        .foregroundStyle(zones.contains(z) ? Theme.gold : GameStyle.nightDim)
                        .position(x: (x0 + x1) / 2, y: 50 + h + 26)
                }
                // Magnifier that follows the finger.
                if let zone {
                    Image(systemName: "magnifyingglass").font(.system(size: 22, weight: .black)).foregroundStyle(.white)
                        .position(x: 16 + w * (edges[zone] + edges[zone + 1]) / 2, y: 24)
                }
                StageTag(text: zones.count == 3 ? "Peeled" : "Swipe across the note").padding(14)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { d in
                    let f = (d.location.x - 16) / max(1, w)
                    let z = f < edges[1] ? 0 : f < edges[2] ? 1 : 2
                    if z != zone {
                        zone = z
                        slice(v, z)
                    }
                }
                .onEnded { _ in withAnimation { zone = nil } })
        }
    }

    /// A hidden fingerprint on top, the choices below.
    private func mysteryStage(mystery: [SoundVoice], options: [SoundVoice]) -> some View {
        VStack(spacing: 12) {
            Button {
                for v in mystery { sing(v.patch, [60, 67], gap: 0.7, length: 0.5) }
                playedAt[99] = CACurrentMediaTime()
                heard.insert(99)
            } label: {
                HStack(spacing: 12) {
                    Fingerprint(patch: mystery[0].patch, color: .white, playedAt: playedAt[99], hidden: game.feedback?.kind != .success)
                        .frame(width: 120, height: 70)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MYSTERY SOUND").font(.label(12, weight: .black)).tracking(1).foregroundStyle(accent)
                        Text(heard.contains(99) ? "Tap to hear again" : "Tap to hear it").font(.label(15, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "play.circle.fill").font(.system(size: 34)).foregroundStyle(accent)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 18).fill(GameStyle.nightRaised))
            }
            .buttonStyle(.plain)
            HStack(spacing: 10) {
                ForEach(Array(options.enumerated()), id: \.offset) { i, v in
                    let on = mystery.count > 1 ? picks.contains(i) : choice == i
                    fingerprintCard(v, index: i, label: v.name, hidden: false, selected: on) {
                        sing(v.patch, [60, 67], gap: 0.7, length: 0.5)
                        mark(i)
                        withAnimation(.spring(response: 0.3)) {
                            if mystery.count > 1 {
                                if picks.contains(i) { picks.remove(i) } else if picks.count < 2 { picks.insert(i) }
                            } else {
                                choice = i
                            }
                        }
                    }
                }
            }
        }
        .padding(14)
    }

    private var briefStage: some View {
        VStack(spacing: 12) {
            StageTag(text: "Choose a brief", color: accent)
            ForEach(Array(Self.briefs.enumerated()), id: \.offset) { i, b in
                ChoiceTile(title: b, symbol: ["bolt.fill", "cloud.fill", "sun.max.fill"][i],
                           color: Self.colors[i], selected: brief == i) {
                    brief = i
                    Haptics.select()
                    let demo: [SoundVoice] = [.click, .pad, .organ]
                    sing(demo[i].patch, [64, 67, 72], gap: 0.35)
                }
            }
        }
        .padding(16)
    }

    private var hybridVoices: [SoundVoice] {
        if case .hybrid(let v) = round.mode { return v }
        return [.click, .pluck, .pad, .bell, .organ]
    }

    private var hybridPatch: SynthPatch {
        let f = (front ?? hybridVoices[0]).patch, t = (tail ?? hybridVoices[min(2, hybridVoices.count - 1)]).patch
        var p = t
        p.attack = f.attack
        p.decay = t.decay * Float(0.4 + blend * 0.6)
        p.sustain = t.sustain * Float(blend)
        p.cutoff = f.cutoff * Float(1 - blend) + t.cutoff * Float(blend)
        return p
    }

    /// Front sound on the left, tail sound on the right, the hybrid's fingerprint in the middle.
    private var hybridStage: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                voiceColumn("FRONT", selected: front) { front = $0 }
                Button(action: playHybrid) {
                    VStack(spacing: 6) {
                        ZStack {
                            if let f = front { Fingerprint(patch: f.patch, color: GameStyle.snare, playedAt: playedAt[50]).opacity(1 - blend * 0.7) }
                            if let t = tail { Fingerprint(patch: t.patch, color: GameStyle.chords, playedAt: playedAt[50]).opacity(0.3 + blend * 0.7) }
                            if front == nil || tail == nil {
                                Text("Pick a front\nand a tail").font(.label(13, weight: .heavy)).multilineTextAlignment(.center)
                                    .foregroundStyle(GameStyle.nightDim)
                            }
                        }
                        .frame(height: 130)
                        Text("TAP TO PLAY").font(.label(11, weight: .black)).tracking(1).foregroundStyle(accent)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 18).fill(GameStyle.nightRaised))
                }
                .buttonStyle(.plain)
                .disabled(front == nil || tail == nil)
                voiceColumn("TAIL", selected: tail) { tail = $0 }
            }
            VStack(spacing: 4) {
                HStack {
                    Text("FRONT").font(.label(11, weight: .black)).foregroundStyle(GameStyle.snare)
                    Spacer()
                    Text("BLEND").font(.label(11, weight: .black)).foregroundStyle(GameStyle.nightDim)
                    Spacer()
                    Text("TAIL").font(.label(11, weight: .black)).foregroundStyle(GameStyle.chords)
                }
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(LinearGradient(colors: [GameStyle.snare, GameStyle.chords], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 12).opacity(0.6)
                        Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 6)
                            .offset(x: (g.size.width - 30) * blend)
                    }
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { d in blend = min(1, max(0, Double((d.location.x - 15) / max(1, g.size.width - 30)))) }
                        .onEnded { _ in playHybrid() })
                }
                .frame(height: 34)
            }
        }
        .padding(14)
    }

    private func voiceColumn(_ label: String, selected: SoundVoice?, set: @escaping (SoundVoice) -> Void) -> some View {
        VStack(spacing: 6) {
            Text(label).font(.label(11, weight: .black)).tracking(1).foregroundStyle(GameStyle.nightDim)
            ForEach(Array(hybridVoices.enumerated()), id: \.offset) { i, v in
                Button {
                    set(v)
                    sing(v.patch, [60], length: 0.5)
                    Haptics.select()
                } label: {
                    Image(systemName: v.symbol).font(.system(size: 15, weight: .bold))
                        .foregroundStyle(selected == v ? Theme.onBrand : .white)
                        .frame(width: 44, height: 34)
                        .background(RoundedRectangle(cornerRadius: 10).fill(selected == v ? Self.colors[i % 5] : Color.white.opacity(0.08)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var revealStage: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                if let f = front {
                    fingerprintCard(f, index: 0, label: f.name, hidden: false) { sing(f.patch, Self.melody); mark(0) }
                }
                Button {
                    for (i, n) in Self.melody.enumerated() { hybridNote(n, delay: Double(i) * 0.42) }
                    mark(2)
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            if let f = front { Fingerprint(patch: f.patch, color: GameStyle.snare, playedAt: playedAt[2]).opacity(1 - blend * 0.7) }
                            if let t = tail { Fingerprint(patch: t.patch, color: GameStyle.chords, playedAt: playedAt[2]).opacity(0.3 + blend * 0.7) }
                        }
                        .frame(height: 110).padding(.horizontal, 6)
                        Text(name.isEmpty ? "Yours" : name).font(.label(13, weight: .heavy)).foregroundStyle(Theme.gold)
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Theme.gold.opacity(0.15)))
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Theme.gold, lineWidth: 2))
                }
                .buttonStyle(.plain)
                if let t = tail {
                    fingerprintCard(t, index: 1, label: t.name, hidden: false) { sing(t.patch, Self.melody); mark(1) }
                }
            }
            TextField("Name your sound", text: $name)
                .font(.label(16, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 14).frame(height: 46)
                .background(RoundedRectangle(cornerRadius: 14).fill(GameStyle.nightRaised))
        }
        .padding(14)
    }

    @ViewBuilder private var below: some View {
        if case .reveal = round.mode, front == nil {
            Text("Build a hybrid first, then come back to reveal it.").font(.label(14, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: Sound

    private func mark(_ i: Int) {
        heard.insert(i)
        playedAt[i] = CACurrentMediaTime()
        Haptics.tap()
    }

    private func slice(_ v: SoundVoice, _ z: Int) {
        var p = v.patch
        Haptics.select()
        zones.insert(z)
        playedAt[9] = CACurrentMediaTime() - [0, 0.2, 0.9][z]
        switch z {
        case 0:
            p.release = 0.02
            engine.playNote(60, seconds: 0.07, patch: p)
        case 1:
            p.attack = max(p.attack, 0.12)
            engine.playNote(60, seconds: 0.45, patch: p, velocity: 0.8)
        default:
            p.attack = max(p.attack, 0.3)
            p.release = p.release * 1.5 + 0.2
            engine.playNote(60, seconds: 0.15, patch: p, velocity: 0.4)
        }
    }

    private func hybridNote(_ pitch: Int, delay: Double = 0) {
        guard let f = front, let t = tail else { return }
        var a = f.patch
        a.sustain = 0
        a.decay = min(a.decay, 0.15)
        a.release = 0.05
        var b = t.patch
        b.attack = max(b.attack, 0.06)
        engine.playNote(pitch, seconds: 0.6, patch: a, velocity: Float(1.1 - blend * 0.6), delay: delay)
        engine.playNote(pitch, seconds: 0.6, patch: b, velocity: Float(0.4 + blend * 0.8), delay: delay)
    }

    private func playHybrid() {
        guard front != nil, tail != nil else { return }
        hybridNote(60)
        hybridPlays += 1
        playedAt[50] = CACurrentMediaTime()
        Haptics.tap()
    }

    // MARK: Flow

    private var primaryTitle: String {
        switch round.mode {
        case .identities: return "I hear the difference"
        case .peel: return "Peeled"
        case .match, .layers: return "Check"
        case .brief: return "Use this brief"
        case .hybrid: return "Keep this hybrid"
        case .reveal: return "Save sound card"
        }
    }

    private var primaryEnabled: Bool {
        switch round.mode {
        case .identities(let v): return heard.count >= v.count
        case .peel: return zones.count == 3
        case .match: return choice != nil && heard.contains(99)
        case .layers: return picks.count == 2 && heard.contains(99)
        case .brief: return brief != nil
        case .hybrid: return front != nil && tail != nil && hybridPlays >= 2
        case .reveal: return front != nil && heard.contains(2)
        }
    }

    private func primary() {
        switch round.mode {
        case .identities:
            game.pass(1, "Same four notes every time. Only the fingerprint changed. That character is timbre.")
        case .peel:
            game.pass(1, "Attack is the first instant, body is what holds, tail is how it fades. Every sound has all three.")
        case .match(let mystery, let options):
            if let c = choice, options[c] == mystery {
                game.pass(game.fails == 0 ? 1 : 0.7, "It was the \(mystery.name.lowercased()). Its fingerprint matched the shape you heard.")
            } else {
                game.miss("Listen to how it starts. Is it a sudden hit or a slow arrival? Then how long it hangs on.")
                choice = nil
            }
        case .layers(let a, let b, let options):
            let names = Set(picks.map { options[$0] })
            if names == Set([a, b]) {
                game.pass(game.fails == 0 ? 1 : 0.7, "A \(a.name.lowercased()) up front and a \(b.name.lowercased()) underneath. Two sounds, one fingerprint.")
            } else {
                game.miss("One part is the quick hit at the start. The other is what keeps ringing. Find both.")
                picks = []
            }
        case .brief:
            game.pass(1, "Brief locked: \(Self.briefs[brief ?? 0].lowercased()). Build a sound that fits it.")
        case .hybrid:
            if front == tail {
                game.miss("Pick two different sounds, one for the front and one for the tail.")
                return
            }
            let b = Self.briefs[brief ?? 0].lowercased()
            game.pass(1, "A \(front?.name.lowercased() ?? "") front with a \(tail?.name.lowercased() ?? "") tail. Does it feel \(b)? That's your call.")
        case .reveal:
            let fi = SoundVoice.all.firstIndex(of: front ?? .click) ?? 0
            let ti = SoundVoice.all.firstIndex(of: tail ?? .pad) ?? 0
            GoldShelf.save(GoldShelf.hybrid, [Double(fi), Double(ti), blend])
            GoldShelf.saveName(GoldShelf.hybrid, name.isEmpty ? "My hybrid" : name)
            game.pass(1, "Saved \(name.isEmpty ? "your hybrid" : "“\(name)”"). You can bring it back in your mini-track.")
        }
    }

    private func retry() {
        withAnimation { game.feedback = nil }
    }

    private func next() {
        if game.advance() {
            onComplete(game.average)
            return
        }
        heard = []
        playedAt = [:]
        choice = nil
        picks = []
        zones = []
        hybridPlays = 0
    }
}
