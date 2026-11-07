//
//  Games45Kit.swift
//  Groova
//
//  Shared pieces for the F4 and F5 games: a sound's fingerprint drawn from its envelope, a shelf
//  that keeps Gold creations for the Live Take, the little band every mixing and arranging game
//  plays, and a few chunky controls.
//

import Foundation
import QuartzCore
import SwiftUI

// MARK: - Gold shelf

/// Gold creations, kept so later games (above all the Live Take) can bring them back.
enum GoldShelf {
    static func save(_ key: String, _ value: [Double]) {
        UserDefaults.standard.set(value, forKey: "groova.gold." + key)
    }

    static func load(_ key: String) -> [Double]? {
        UserDefaults.standard.array(forKey: "groova.gold." + key) as? [Double]
    }

    static func saveName(_ key: String, _ value: String) {
        UserDefaults.standard.set(value, forKey: "groova.gold.name." + key)
    }

    static func name(_ key: String) -> String? {
        UserDefaults.standard.string(forKey: "groova.gold.name." + key)
    }

    /// Keys used across games.
    static let synth = "synth"        // attack, release, filter
    static let hybrid = "hybrid"      // attack voice, tail voice, blend
    static let journey = "journey"    // 16 wet levels, then echo on or off
    static let mix = "mix"            // drums, bass, chords, lead
    static let palette = "palette"    // drums, bass, chords, lead audition index
    static let arc = "arc"            // energy level per bar
    static let song = "song"          // jigsaw card order
    static let cut = "cut"            // join kind
}

// MARK: - The band

/// The little band that F4.4, F4.5 and F5 play: drums, bass, chords and a lead line, in C.
nonisolated extension Stems {
    static let lead = K.tune([(0, 72, 2), (2, 69, 2), (4, 67, 4), (8, 64, 2), (10, 67, 2), (12, 69, 3)])
    static let demo = Stems(drums: FKit.beat, bass: FKit.bassline,
                            chords: [K.ch(0, FKit.c, 7), K.ch(8, FKit.am, 7)], lead: lead)

    /// Drums, bass and chords as one pattern. The lead is played on its own so it gets its own level.
    func backing(drums on: Bool = true, bass b: Bool = true, chords c: Bool = true) -> Pattern {
        var p = on ? drums : Pattern()
        if b { p.bass = bass }
        if c { p.chords = chords }
        return p
    }
}

/// Audition sounds for each role in Mix Traffic Control and Sound Casting.
enum Band {
    static let leadPatch = SynthPatch(saw: 0.5, square: 0.2, sine: 0.4, detuneCents: 6, cutoff: 1800, envAmount: 1500,
                                      filterDecay: 0.2, resonance: 0.15, attack: 0.005, decay: 0.3, sustain: 0.5,
                                      release: 0.15, gain: 0.28)

    struct Audition: Hashable {
        var name: String
        var symbol: String
        var color: Color
        var patch: SynthPatch
        var flavor: Int = 0
    }

    static let drums: [Audition] = [
        Audition(name: "Tight kit", symbol: "circle.grid.2x2.fill", color: GameStyle.kick, patch: .stab, flavor: 3),
        Audition(name: "Warm kit", symbol: "flame.fill", color: Theme.brand, patch: .stab, flavor: 1),
        Audition(name: "Dusty kit", symbol: "wind", color: Theme.brand, patch: .stab, flavor: 4),
    ]
    static let bass: [Audition] = [
        Audition(name: "Sub", symbol: "circle.fill", color: GameStyle.bass, patch: .deepBass),
        Audition(name: "Round", symbol: "capsule.fill", color: Theme.brand, patch: .popBass),
        Audition(name: "Buzz", symbol: "bolt.fill", color: Theme.brand, patch: .technoBass),
    ]
    static let chords: [Audition] = [
        Audition(name: "Pluck", symbol: "guitars.fill", color: GameStyle.chords, patch: .pluck),
        Audition(name: "Pad", symbol: "cloud.fill", color: Theme.brand, patch: .softPad),
        Audition(name: "E-piano", symbol: "pianokeys", color: Theme.brand, patch: .electricPiano),
    ]
    static let lead: [Audition] = [
        Audition(name: "Synth", symbol: "waveform", color: GameStyle.lead, patch: leadPatch),
        Audition(name: "Bell", symbol: "bell.fill", color: Theme.brand, patch: SoundVoice.bell.patch),
        Audition(name: "Brass", symbol: "music.mic", color: Theme.brand, patch: SoundVoice.brass.patch),
    ]

    static func pool(_ role: CastRole) -> [Audition] {
        switch role {
        case .drums: drums
        case .bass: bass
        case .chords: chords
        case .lead: lead
        }
    }

    /// A kit built from a lineup: drum flavor, bass and chord patches.
    static func kit(_ genre: Genre, lineup: [Int]) -> DrumKit {
        var k = SoundFlavor.kit(Transport.shared.kit(for: genre), drums[lineup[0] % 3].flavor)
        k.bass = bass[lineup[1] % 3].patch
        k.chords = chords[lineup[2] % 3].patch
        return k
    }
}

/// Plays a lead line in step with the transport, so the lead can have its own level and sound.
/// Call from onChange of the transport step.
func playLead(_ notes: [NoteEvent], step: Int, patch: SynthPatch, level: Double, stepSeconds: Double) {
    guard level > 0.02, step >= 0 else { return }
    for n in notes where n.step == step % 16 {
        AudioEngine.shared.playNote(n.pitch, seconds: Double(n.length) * stepSeconds * 0.95, patch: patch,
                                    velocity: Float(min(1.4, level)))
    }
}

/// Plays a line of notes on a patch now. Pitch 0 is a rest.
func sing(_ patch: SynthPatch, _ notes: [Int], gap: Double = 0.42, length: Double = 0.34, velocity: Float = 1) {
    for (i, n) in notes.enumerated() where n > 0 {
        AudioEngine.shared.playNote(n, seconds: length, patch: patch, velocity: velocity, delay: Double(i) * gap)
    }
}

// MARK: - Envelope fingerprint

/// How loud a note is over time, drawn as a filled silhouette.
struct EnvelopeShape: Shape {
    var attack: Double
    var decay: Double
    var sustain: Double
    var release: Double
    /// When the note is let go, in seconds.
    var hold: Double = 0.45
    /// Seconds across the shape.
    var window: Double = 2.2

    init(patch: SynthPatch, hold: Double = 0.45, window: Double = 2.2) {
        attack = Double(patch.attack)
        decay = Double(patch.decay)
        sustain = Double(patch.sustain)
        release = Double(patch.release)
        self.hold = hold
        self.window = window
    }

    static func level(_ t: Double, attack: Double, decay: Double, sustain: Double, release: Double, hold: Double) -> Double {
        func held(_ t: Double) -> Double {
            let a = max(0.002, attack)
            if t < a { return t / a }
            return sustain + (1 - sustain) * exp(-(t - a) / max(0.01, decay / 3))
        }
        if t <= hold { return held(t) }
        return held(hold) * exp(-(t - hold) / max(0.01, release / 3))
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let n = 90
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        for i in 0...n {
            let t = window * Double(i) / Double(n)
            let v = Self.level(t, attack: attack, decay: decay, sustain: sustain, release: release, hold: hold)
            p.addLine(to: CGPoint(x: rect.minX + rect.width * CGFloat(i) / CGFloat(n),
                                  y: rect.maxY - rect.height * CGFloat(min(1, v))))
        }
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// A sound's fingerprint: its envelope as a glowing silhouette, textured by how bright it is.
/// A playhead sweeps across it after `playedAt`.
struct SoundFingerprint: View {
    let patch: SynthPatch
    var color: Color
    var hold: Double = 0.45
    var playedAt: Double?
    var hidden = false

    private let window = 2.2

    var body: some View {
        TimelineView(.animation(paused: playedAt == nil)) { _ in
            GeometryReader { g in
                let elapsed = playedAt.map { CACurrentMediaTime() - $0 } ?? -1
                let bright = min(1, max(0, log2(Double(patch.cutoff + patch.envAmount * 0.3) / 150) / 6))
                ZStack(alignment: .leading) {
                    EnvelopeShape(patch: patch, hold: hold, window: window)
                        .fill(LinearGradient(colors: [color.opacity(0.95), color.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                    // Brightness: fine hairs inside the silhouette, more of them when the sound is bright.
                    Canvas { ctx, size in
                        let count = Int(10 + bright * 50)
                        for i in 0..<count {
                            let x = size.width * CGFloat(i) / CGFloat(count)
                            let jitter = CGFloat((i * 37) % 11) / 11
                            let top = size.height * (0.1 + 0.5 * jitter * (1 - bright))
                            var line = Path()
                            line.move(to: CGPoint(x: x, y: top))
                            line.addLine(to: CGPoint(x: x, y: size.height))
                            ctx.stroke(line, with: .color(GameStyle.ink.opacity(0.12 + 0.18 * bright)), lineWidth: 1)
                        }
                    }
                    .mask(EnvelopeShape(patch: patch, hold: hold, window: window))
                    if elapsed >= 0, elapsed < window {
                        Capsule().fill(GameStyle.ink).frame(width: 3, height: g.size.height)
                            .offset(x: g.size.width * CGFloat(elapsed / window) - 1.5)
                    }
                }
                .blur(radius: hidden ? 10 : 0)
                .overlay {
                    if hidden {
                        Text("?").font(.display(34)).foregroundStyle(GameStyle.ink.opacity(0.85))
                    }
                }
            }
        }
    }
}

// MARK: - Controls

/// A dark chunky tile for a choice on the stage or under it.
struct ChoiceTile: View {
    let title: String
    var symbol: String? = nil
    var color: Color = GameStyle.lead
    var selected = false
    var dim = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if let symbol {
                    Image(systemName: symbol).font(.system(size: 20, weight: .bold))
                }
                Text(title).font(.label(14, weight: .heavy)).multilineTextAlignment(.center)
            }
            .foregroundStyle(selected ? Theme.onBrand : Theme.text)
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(selected ? color : Theme.surfaceHigh))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(selected ? GameStyle.ink.opacity(0.4) : color.opacity(0.35), lineWidth: 2))
            .opacity(dim ? 0.45 : 1)
            .scaleEffect(selected ? 1.03 : 1)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: selected)
    }
}

/// Two big buttons to flip between versions A and B.
struct ABSwitch: View {
    var a = "A"
    var b = "B"
    let current: Int?
    let onPick: (Int) -> Void
    @Environment(\.accent) private var accent

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { i in
                Button { onPick(i) } label: {
                    Label(i == 0 ? a : b, systemImage: current == i ? "speaker.wave.2.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(color: current == i ? accent : Theme.surfaceHigh,
                                               textColor: current == i ? Theme.onBrand : Theme.text, height: 52))
            }
        }
    }
}

/// A vertical drag strip that sets a 0...1 value with a glowing fill.
struct LevelStrip: View {
    @Binding var value: Double
    var color: Color
    var pocket: ClosedRange<Double>? = nil
    var locked = false
    var onChange: () -> Void = {}

    var body: some View {
        GeometryReader { g in
            let h = g.size.height
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 14).fill(GameStyle.ink.opacity(0.05))
                if let pocket {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Theme.gold.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .frame(height: h * CGFloat(pocket.upperBound - pocket.lowerBound))
                        .offset(y: -h * CGFloat(pocket.lowerBound))
                }
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [color, color.opacity(0.35)], startPoint: .top, endPoint: .bottom))
                    .frame(height: max(10, h * CGFloat(value)))
                    .shadow(color: color.opacity(0.6), radius: 8 * value)
                Capsule().fill(GameStyle.ink).frame(width: 30, height: 6)
                    .offset(y: -max(4, h * CGFloat(value) - 8))
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                guard !locked else { return }
                let nv = min(1, max(0, 1 - Double(v.location.y / h)))
                if abs(nv - value) > 0.004 {
                    value = nv
                    onChange()
                }
            })
            .opacity(locked ? 0.4 : 1)
        }
    }
}

// MARK: - Song material for F5

/// Sections that sit together, all in C at the same tempo, so any order joins on a bar line.
nonisolated enum SongKit {
    typealias F = FKit

    static let chordBed = [K.ch(0, F.c, 7), K.ch(8, F.am, 7)]
    static let chordBedB = [K.ch(0, F.f, 7), K.ch(8, F.g, 7)]
    static let lead = Stems.lead
    static let leadB = K.tune([(0, 69, 2), (2, 67, 2), (4, 64, 4), (8, 65, 2), (10, 67, 2), (12, 72, 3)])

    static let intro = Pattern(hat: F.eighths, chords: chordBed)
    static let main = K.melody(lead, over: Pattern(kick: [0, 8], clap: [4, 12], hat: F.eighths, bass: F.bassline, chords: chordBed))
    static let mainB = K.melody(leadB, over: Pattern(kick: [0, 8], clap: [4, 12], hat: F.eighths,
                                                     bass: [NoteEvent(0, 41, 2), NoteEvent(6, 41, 2), NoteEvent(8, 43, 2), NoteEvent(14, 43, 2)],
                                                     chords: chordBedB))
    static let verse = Pattern(kick: [0, 8], clap: [4, 12], hat: F.eighths, bass: F.bassline, chords: chordBed)
    static let breakdown = K.melody(lead, over: Pattern(chords: chordBed))
    static let variation = K.melody(leadB, over: Pattern(kick: [0, 7, 8, 10], clap: [4, 12], hat: F.sixteenths, perc: [3, 11],
                                                         bass: F.bassline, chords: chordBedB))
    static let outro = Pattern(kick: [0], chords: [K.ch(0, F.c, 15)])
    static let fill = Pattern(kick: [0, 8], clap: [4, 10, 12, 13, 14, 15], hat: [0, 2, 4, 6, 8])
    static let silence = Pattern()

    static func section(_ name: String, _ p: Pattern, bars: Int = 2) -> SongSection {
        SongSection(name: name, pattern: p, bars: bars, layers: layers(p))
    }

    /// Which of drums, bass, chords and lead a pattern uses.
    static func layers(_ p: Pattern) -> [Bool] {
        let drums = p.kick.contains(true) || p.clap.contains(true) || p.hat.contains(true)
        let lead = p.chords.contains { $0.pitches.count == 1 }
        let chords = p.chords.contains { $0.pitches.count > 1 }
        return [drums, !p.bass.isEmpty, chords, lead]
    }

    /// One pattern per bar.
    static func bars(_ song: [SongSection]) -> [Pattern] {
        song.flatMap { s in Array(repeating: s.pattern, count: max(1, s.bars)) }
    }

    /// Bars where each section after the first starts.
    static func boundaries(_ song: [SongSection]) -> [Int] {
        var r: [Int] = []
        var at = 0
        for (i, s) in song.enumerated() {
            if i > 0 { r.append(at) }
            at += s.bars
        }
        return r
    }

    /// Energy levels 0...4 for Energy Surfer: more layers, busier drums and a higher lead as it climbs.
    static func energy(_ level: Int) -> Pattern {
        switch level {
        case ..<1: return Pattern(chords: chordBed)
        case 1: return Pattern(hat: F.eighths, chords: chordBed)
        case 2: return Pattern(kick: [0, 8], hat: F.eighths, bass: F.bassline, chords: chordBed)
        case 3: return main
        default:
            return K.melody(lead.map { NoteEvent($0.step, $0.pitch + 12, $0.length) },
                            over: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: F.sixteenths, openHat: [6, 14], perc: [3, 11],
                                          bass: F.bassline, chords: chordBed))
        }
    }

    /// Joins two sections at a step: everything before the cut from `a`, everything after from `b`.
    static func splice(_ a: Pattern, _ b: Pattern, at cut: Int) -> Pattern {
        var p = Pattern()
        for t in DrumTrack.allCases {
            var lane = [Bool](repeating: false, count: 16)
            for s in 0..<16 { lane[s] = s < cut ? a[t][s] : b[t][s] }
            p[t] = lane
        }
        p.bass = a.bass.filter { $0.step < cut }.map { NoteEvent($0.step, $0.pitch, min($0.length, cut - $0.step)) }
            + b.bass.filter { $0.step >= cut }
        p.chords = a.chords.filter { $0.step < cut }.map { ChordEvent(step: $0.step, pitches: $0.pitches, length: min($0.length, cut - $0.step)) }
            + b.chords.filter { $0.step >= cut }
        return p
    }
}
