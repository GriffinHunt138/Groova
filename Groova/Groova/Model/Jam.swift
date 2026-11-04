//
//  Jam.swift
//  Groova
//
//  Sandbox projects. A jam is an 8-bar loop made of five tracks (drums, bass, piano, synth and
//  vocal chops), each with its own sound, knobs and effects, plus a song built from sections
//  that switch parts of the loop on and off.
//

import Foundation
import Observation
import SwiftUI

// MARK: - Parts

nonisolated enum JamPart: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case drums, bass, keys, lead, vox

    var id: String { rawValue }

    var name: String {
        switch self {
        case .drums: "Drums"
        case .bass: "Bass"
        case .keys: "Piano"
        case .lead: "Synth"
        case .vox: "Vocal chops"
        }
    }

    var blurb: String {
        switch self {
        case .drums: "Kick, clap, hats & rim"
        case .bass: "The low end"
        case .keys: "Chords"
        case .lead: "Melodies & riffs"
        case .vox: "Sung syllables"
        }
    }

    var symbol: String {
        switch self {
        case .drums: "circle.grid.2x2.fill"
        case .bass: "waveform.path"
        case .keys: "pianokeys"
        case .lead: "wand.and.stars"
        case .vox: "mic.fill"
        }
    }

    /// Each part's own hue, used only for its icon tile. Grids stay brand purple.
    var color: Color {
        switch self {
        case .drums: Color(hex: 0xFF9F2E)
        case .bass: Color(hex: 0x7B5CFA)
        case .keys: Color(hex: 0x2EC4B6)
        case .lead: Color(hex: 0xFF5E8A)
        case .vox: Color(hex: 0xFFC233)
        }
    }

    var presets: [String] {
        switch self {
        case .drums: JamSound.kits.map(\.name)
        case .bass: JamSound.bassPresets.map(\.name)
        case .keys: JamSound.keyPresets.map(\.name)
        case .lead: JamSound.leadPresets.map(\.name)
        case .vox: JamSound.voxPresets.map(\.name)
        }
    }

    /// The knobs on the Sound tab. Drums show the knobs of the selected drum instead.
    var soundParams: [JamParam] {
        switch self {
        case .drums: []
        case .bass: [.tone, .reso, .punch, .length]
        case .keys: [.tone, .attack, .length, .width]
        case .lead: [.tone, .reso, .attack, .length]
        case .vox: [.pitch, .formant, .breath, .voxLength]
        }
    }
}

/// The rows of the arrangement. Drums split into kick and the rest, so a breakdown can drop the kick.
nonisolated enum JamLane: Int, CaseIterable, Identifiable, Sendable {
    case kick, beat, bass, keys, lead, vox

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .kick: "Kick"
        case .beat: "Beat"
        case .bass: "Bass"
        case .keys: "Piano"
        case .lead: "Synth"
        case .vox: "Vocals"
        }
    }

    var part: JamPart {
        switch self {
        case .kick, .beat: .drums
        case .bass: .bass
        case .keys: .keys
        case .lead: .lead
        case .vox: .vox
        }
    }

    var symbol: String { self == .kick ? "circle.circle.fill" : part.symbol }
}

// MARK: - Knobs

nonisolated enum JamParam: String, Codable, CaseIterable, Identifiable, Sendable {
    // Synths
    case tone, reso, punch, length, attack, width
    // Vocal chops
    case pitch, formant, breath, voxLength
    // Effects, on every track
    case reverb, delay, pump, pan
    // Drums, per drum
    case kickTune, kickLength, kickPunch, kickClick, kickLevel
    case clapTone, clapLength, clapLevel
    case hatTone, hatLength, hatLevel
    case openLength, openLevel
    case rimTune, rimLength, rimLevel

    var id: String { rawValue }

    var label: String {
        switch self {
        case .tone, .clapTone, .hatTone: "Tone"
        case .reso: "Reso"
        case .punch, .kickPunch: "Punch"
        case .length, .voxLength, .kickLength, .clapLength, .hatLength, .openLength, .rimLength: "Length"
        case .attack: "Attack"
        case .width: "Width"
        case .pitch: "Pitch"
        case .formant: "Formant"
        case .breath: "Breath"
        case .reverb: "Reverb"
        case .delay: "Delay"
        case .pump: "Pump"
        case .pan: "Pan"
        case .kickTune, .rimTune: "Tune"
        case .kickClick: "Click"
        case .kickLevel, .clapLevel, .hatLevel, .openLevel, .rimLevel: "Level"
        }
    }

    /// One line under the knobs explaining what it does.
    var help: String {
        switch self {
        case .tone, .clapTone, .hatTone: "Tone opens the filter: higher is brighter."
        case .reso: "Reso adds a whistle at the filter's edge."
        case .punch: "Punch makes each note start brighter, then close."
        case .length, .voxLength, .kickLength, .clapLength, .hatLength, .openLength, .rimLength:
            "Length sets how long each hit rings."
        case .attack: "Attack fades each note in. Turn it up for swells."
        case .width: "Width detunes the voices for a wider sound."
        case .pitch: "Pitch moves every chop up or down."
        case .formant: "Formant changes the voice's size without changing the note."
        case .breath: "Breath adds air to the voice."
        case .reverb: "Reverb puts the sound in a room."
        case .delay: "Delay repeats it in time, bouncing left and right."
        case .pump: "Pump ducks it every time the kick hits."
        case .pan: "Pan moves it left or right."
        case .kickTune, .rimTune: "Tune moves the drum's pitch."
        case .kickPunch: "Punch drives the kick harder."
        case .kickClick: "Click adds a sharp attack at the start."
        case .kickLevel, .clapLevel, .hatLevel, .openLevel, .rimLevel: "Level sets how loud this drum is."
        }
    }

    static let effects: [JamParam] = [.reverb, .delay, .pump, .pan]

    static func drum(_ t: DrumTrack) -> [JamParam] {
        switch t {
        case .kick: [.kickTune, .kickLength, .kickPunch, .kickClick, .kickLevel]
        case .clap: [.clapTone, .clapLength, .clapLevel]
        case .hat: [.hatTone, .hatLength, .hatLevel]
        case .openHat: [.openLength, .openLevel]
        case .perc: [.rimTune, .rimLength, .rimLevel]
        }
    }

    func initial(for part: JamPart) -> Double {
        switch self {
        case .reverb: part == .keys ? 0.2 : (part == .lead ? 0.25 : (part == .vox ? 0.3 : 0))
        case .delay: part == .lead ? 0.15 : (part == .vox ? 0.2 : 0)
        case .pump: 0
        default: 0.5
        }
    }
}

// MARK: - Data

/// One bar of one track. Every track uses only the field that fits it.
nonisolated struct JamBar: Codable, Hashable, Sendable {
    var drums = Pattern()
    var notes: [NoteEvent] = []
    var chords = [Int?](repeating: nil, count: Pattern.steps)
    var chops = [[Bool]](repeating: [Bool](repeating: false, count: Pattern.steps), count: JamSound.padCount)

    func isEmpty(_ part: JamPart) -> Bool {
        switch part {
        case .drums: drums == Pattern()
        case .bass, .lead: notes.isEmpty
        case .keys: chords.allSatisfy { $0 == nil }
        case .vox: chops.allSatisfy { !$0.contains(true) }
        }
    }

    func hasHit(_ part: JamPart, at s: Int) -> Bool {
        switch part {
        case .drums: DrumTrack.allCases.contains { drums[$0][s] }
        case .bass, .lead: notes.contains { $0.step == s }
        case .keys: chords[s] != nil
        case .vox: chops.contains { $0[s] }
        }
    }
}

nonisolated struct JamTrack: Codable, Hashable, Sendable, Identifiable {
    var part: JamPart
    var preset: Int
    var knobs: [String: Double] = [:]
    var volume = MixerTask.unity
    var muted = false
    /// 1, 2, 4 or 8 bars, repeated to fill the loop.
    var clips: [JamBar] = [JamBar()]

    var id: JamPart { part }
    var bars: Int { clips.count }

    func value(_ p: JamParam) -> Double { knobs[p.rawValue] ?? p.initial(for: part) }
    mutating func set(_ p: JamParam, _ v: Double) { knobs[p.rawValue] = min(1, max(0, v)) }

    /// Change the length. Longer repeats what's there; shorter keeps the first bars.
    mutating func setBars(_ n: Int) {
        guard n > 0, n != clips.count else { return }
        if n > clips.count {
            let base = clips
            clips = (0..<n).map { base[$0 % base.count] }
        } else {
            clips = Array(clips.prefix(n))
        }
    }

    /// The bar of this track that plays during bar `loopBar` of the loop.
    func bar(at loopBar: Int) -> Int { ((loopBar % bars) + bars) % bars }

    var isEmpty: Bool { clips.allSatisfy { $0.isEmpty(part) } }

    /// One flag per step of the 8-bar loop: does anything play there?
    var activity: [Bool] {
        (0..<(Jam.loopBars * Pattern.steps)).map { p in
            clips[bar(at: p / Pattern.steps)].hasHit(part, at: p % Pattern.steps)
        }
    }
}

nonisolated struct JamSection: Codable, Hashable, Sendable, Identifiable {
    var id = UUID()
    var name: String
    var bars: Int
    /// One flag per `JamLane`.
    var lanes: [Bool]

    static let names = ["Intro", "Build", "Drop", "Break", "Verse", "Chorus", "Bridge", "Outro"]
    static let lengths = [2, 4, 8]

    func plays(_ lane: JamLane) -> Bool { lane.rawValue < lanes.count && lanes[lane.rawValue] }
}

nonisolated struct Jam: Codable, Hashable, Sendable, Identifiable {
    static let loopBars = 8
    static let maxSections = 12

    var id = UUID()
    var name = "Untitled jam"
    var genre: Genre
    var bpm: Double
    var swing: Double
    var tracks: [JamTrack]
    var sections: [JamSection]
    var updated = Date.now

    subscript(part: JamPart) -> JamTrack {
        get { tracks.first { $0.part == part } ?? JamTrack(part: part, preset: 0) }
        set {
            if let i = tracks.firstIndex(where: { $0.part == part }) { tracks[i] = newValue } else { tracks.append(newValue) }
        }
    }

    var songBars: Int { sections.reduce(0) { $0 + $1.bars } }
    var songSeconds: Double { Double(songBars * 16) * 60 / bpm / 4 }

    // MARK: Starting points

    static func empty(_ g: Genre) -> Jam {
        Jam(genre: g, bpm: g.bpm, swing: g.swing,
            tracks: JamPart.allCases.map { JamTrack(part: $0, preset: JamSound.defaultPreset($0, g)) },
            sections: defaultSections)
    }

    /// The genre's groove, a two-chord progression and a couple of chops, ready to play.
    static func starter(_ g: Genre) -> Jam {
        var jam = empty(g)
        jam.name = "\(g.name) jam"
        let demo = g.demoPattern
        var drums = JamBar()
        drums.drums = demo.keeping(Set(DrumTrack.allCases), bass: false, chords: false)
        jam[.drums].clips = [drums]
        var bass = JamBar()
        bass.notes = demo.bass
        jam[.bass].clips = [bass]
        let palette = Studio.palette(g)
        var steps = demo.chords.map(\.step).filter { $0 < Pattern.steps }
        if steps.isEmpty { steps = [2, 10] }
        var one = JamBar(), two = JamBar()
        for s in steps {
            one.chords[s] = 0
            two.chords[s] = min(1, palette.count - 1)
        }
        jam[.keys].clips = [one, two]
        var vox = JamBar()
        vox.chops[1][6] = true
        vox.chops[3][14] = true
        jam[.vox].clips = [vox]
        return jam
    }

    /// Brings an old Studio loop into the Sandbox.
    static func from(_ s: Sketch) -> Jam {
        var jam = empty(s.genre)
        jam.id = s.id
        jam.name = s.name
        jam.bpm = s.bpm
        jam.swing = s.swing
        jam.updated = s.updated
        var drums = JamBar()
        drums.drums = s.pattern.keeping(Set(DrumTrack.allCases), bass: false, chords: false)
        jam[.drums].clips = [drums]
        var bass = JamBar()
        bass.notes = s.pattern.bass
        jam[.bass].clips = [bass]
        var keys = JamBar()
        for (i, c) in s.chordCells.enumerated() where i < Pattern.steps { keys.chords[i] = c }
        jam[.keys].clips = [keys]
        return jam
    }

    static var defaultSections: [JamSection] {
        let all = [Bool](repeating: true, count: JamLane.allCases.count)
        return [
            JamSection(name: "Intro", bars: 4, lanes: [true, true, false, false, false, false]),
            JamSection(name: "Build", bars: 4, lanes: [false, true, true, true, false, true]),
            JamSection(name: "Drop", bars: 8, lanes: all),
            JamSection(name: "Break", bars: 4, lanes: [false, false, false, true, true, true]),
            JamSection(name: "Drop", bars: 8, lanes: all),
            JamSection(name: "Outro", bars: 4, lanes: [true, true, false, false, false, false]),
        ]
    }

    var isUntouched: Bool {
        var a = self, b = Jam.starter(genre)
        b.id = a.id; b.updated = a.updated; b.name = a.name
        a.updated = b.updated
        return a == b || tracks.allSatisfy(\.isEmpty)
    }

    // MARK: Playback

    /// What the engine plays: the loop, or the song when `arranged`.
    func song(arranged: Bool) -> JamSong {
        let n = Jam.loopBars * Pattern.steps
        var lanes = JamLane.allCases.map { _ in JamLaneData(steps: [[JamEvent]](repeating: [], count: n)) }
        for track in tracks {
            let mix = JamSound.mix(track)
            for lane in JamLane.allCases where lane.part == track.part {
                lanes[lane.rawValue].level = mix.level
                lanes[lane.rawValue].pan = mix.pan
                lanes[lane.rawValue].reverb = mix.reverb
                lanes[lane.rawValue].delay = mix.delay
                lanes[lane.rawValue].duck = mix.duck
            }
            switch track.part {
            case .drums:
                let kit = JamSound.kit(track, genre)
                lanes[JamLane.kick.rawValue].kit = kit
                lanes[JamLane.beat.rawValue].kit = kit
                let levels = Dictionary(uniqueKeysWithValues: DrumTrack.allCases.map { ($0, JamSound.drumLevel(track, $0)) })
                for p in 0..<n {
                    let bar = track.clips[track.bar(at: p / Pattern.steps)], s = p % Pattern.steps
                    for t in DrumTrack.allCases where bar.drums[t][s] {
                        let accent: Float = t == .hat ? (s % 4 == 2 ? 1 : 0.72) : 1
                        let lane: JamLane = t == .kick ? .kick : .beat
                        lanes[lane.rawValue].steps[p].append(.drum(t, accent * (levels[t] ?? 1)))
                    }
                }
            case .bass, .lead:
                let lane: JamLane = track.part == .bass ? .bass : .lead
                lanes[lane.rawValue].patch = JamSound.patch(track)
                for p in 0..<n {
                    let bar = track.clips[track.bar(at: p / Pattern.steps)], s = p % Pattern.steps
                    for note in bar.notes where note.step == s {
                        lanes[lane.rawValue].steps[p].append(.note(note.pitch, Float(note.length), 1))
                    }
                }
            case .keys:
                lanes[JamLane.keys.rawValue].patch = JamSound.patch(track)
                let palette = Studio.palette(genre)
                let hold = JamSound.holdSteps(track)
                let cells = track.clips.flatMap(\.chords)
                let hits = cells.indices.filter { cells[$0] != nil }
                for p in 0..<n {
                    let i = p % cells.count
                    guard let idx = cells[i], idx < palette.count else { continue }
                    // Hold until the next chord, or the Length knob, whichever comes first.
                    let next = hits.first { $0 > i } ?? ((hits.first ?? i) + cells.count)
                    let gate = Float(min(hold, max(1, next - i)))
                    for pitch in palette[idx].pitches {
                        lanes[JamLane.keys.rawValue].steps[p].append(.note(pitch, gate, 1))
                    }
                }
            case .vox:
                lanes[JamLane.vox.rawValue].vox = JamSound.vox(track)
                let pads = JamSound.pads(genre)
                let shift = JamSound.pitchShift(track)
                let len = Float(JamSound.chopSteps(track))
                for p in 0..<n {
                    let bar = track.clips[track.bar(at: p / Pattern.steps)], s = p % Pattern.steps
                    for (r, pad) in pads.enumerated() where r < bar.chops.count && bar.chops[r][s] {
                        lanes[JamLane.vox.rawValue].steps[p].append(.vox(pad.pitch + shift, len, pad.from, pad.to))
                    }
                }
            }
        }
        let sections = arranged ? self.sections.map { JamSectionData(bars: $0.bars, lanes: $0.lanes) } : []
        return JamSong(lanes: lanes, loopSteps: n, sections: sections)
    }
}

// MARK: - Sounds

nonisolated enum JamSound {
    nonisolated struct Preset: Sendable { let name: String; let patch: SynthPatch; var hold = 4 }
    nonisolated struct Kit: Sendable { let name: String; let kit: DrumKit }
    nonisolated struct VoxPreset: Sendable { let name: String; let settings: VoxSettings }
    nonisolated struct Pad: Sendable { let syllable: String; let pitch: Int; let from: Int; let to: Int }

    static let padCount = 6

    static let kits: [Kit] = [
        Kit(name: "House", kit: .house), Kit(name: "Deep", kit: .deepHouse), Kit(name: "Techno", kit: .techno),
        Kit(name: "Tech", kit: .techHouse), Kit(name: "Garage", kit: .ukGarage),
    ]

    static let bassPresets: [Preset] = [
        Preset(name: "Classic", patch: .houseBass),
        Preset(name: "Round", patch: .deepBass),
        Preset(name: "Rolling", patch: .technoBass),
        Preset(name: "Bouncy", patch: .garageBass),
        Preset(name: "Acid", patch: SynthPatch(saw: 0.9, square: 0, sine: 0.15, cutoff: 240, envAmount: 3400,
                                               filterDecay: 0.14, resonance: 0.78, decay: 0.16, sustain: 0.4, gain: 0.4)),
        Preset(name: "Sub", patch: SynthPatch(saw: 0, square: 0, sine: 1, cutoff: 220, envAmount: 120,
                                              filterDecay: 0.1, resonance: 0, decay: 0.4, sustain: 0.85,
                                              release: 0.06, gain: 0.6)),
    ]

    static let piano = SynthPatch(saw: 0.22, square: 0, sine: 0.75, detuneCents: 3, cutoff: 2000, envAmount: 3200,
                                  filterDecay: 0.3, resonance: 0.05, attack: 0.002, decay: 1.1, sustain: 0.05,
                                  release: 0.45, gain: 0.2)

    static let keyPresets: [Preset] = [
        Preset(name: "Piano", patch: piano, hold: 5),
        Preset(name: "E-Piano", patch: .electricPiano, hold: 3),
        Preset(name: "Organ", patch: .organ, hold: 3),
        Preset(name: "Stab", patch: .stab, hold: 0),
        Preset(name: "Pad", patch: SynthPatch(saw: 0.45, square: 0, sine: 0.5, detuneCents: 14, cutoff: 700,
                                              envAmount: 600, filterDecay: 0.6, resonance: 0.12, attack: 0.3,
                                              decay: 0.8, sustain: 0.6, release: 0.7, gain: 0.11), hold: 7),
    ]

    static let leadPresets: [Preset] = [
        Preset(name: "Pluck", patch: .pluck),
        Preset(name: "Saw", patch: SynthPatch(saw: 0.8, square: 0, sine: 0.2, detuneCents: 12, cutoff: 1300,
                                              envAmount: 1800, filterDecay: 0.18, resonance: 0.2, attack: 0.004,
                                              decay: 0.3, sustain: 0.6, release: 0.12, gain: 0.13)),
        Preset(name: "Square", patch: SynthPatch(saw: 0, square: 0.55, sine: 0.35, detuneCents: 0, cutoff: 1800,
                                                 envAmount: 900, filterDecay: 0.12, resonance: 0.1, attack: 0.003,
                                                 decay: 0.25, sustain: 0.5, release: 0.08, gain: 0.14)),
        Preset(name: "Bell", patch: SynthPatch(saw: 0.05, square: 0.1, sine: 0.9, detuneCents: 7, cutoff: 3200,
                                               envAmount: 3000, filterDecay: 0.08, resonance: 0.15, attack: 0.001,
                                               decay: 0.6, sustain: 0, release: 0.5, gain: 0.2)),
    ]

    static let voxPresets: [VoxPreset] = [
        VoxPreset(name: "Diva", settings: VoxSettings(formant: 1.12, breath: 0.1, vibrato: 0.18)),
        VoxPreset(name: "Soul", settings: VoxSettings(formant: 0.86, breath: 0.08, vibrato: 0.25)),
        VoxPreset(name: "Airy", settings: VoxSettings(formant: 1.05, breath: 0.5, vibrato: 0.1, gain: 0.55)),
        VoxPreset(name: "Robot", settings: VoxSettings(formant: 1, breath: 0, vibrato: 0, robot: true, gain: 0.4)),
    ]

    static func defaultPreset(_ part: JamPart, _ g: Genre) -> Int {
        let order: [Genre] = [.house, .deepHouse, .techno, .techHouse, .ukGarage]
        let i = order.firstIndex(of: g) ?? 0
        switch part {
        case .drums: return i
        case .bass: return [0, 1, 2, 2, 3][i]
        case .keys: return [0, 1, 3, 3, 1][i]
        case .lead, .vox: return 0
        }
    }

    /// The key's root as a pitch class: A minor for house and techno, and so on.
    static func keyRoot(_ g: Genre) -> Int {
        switch g {
        case .house, .techno: 9
        case .ukGarage: 4
        case .deepHouse: 5
        case .techHouse: 0
        }
    }

    /// Minor pentatonic over an octave and a half, high to low. Nothing in it clashes.
    static func leadRows(_ g: Genre) -> [Int] {
        let root = 55 + ((keyRoot(g) - 7 + 12) % 12)
        return [0, 3, 5, 7, 10, 12, 15, 17].map { root + $0 }.reversed()
    }

    /// Six vocal chops, top row first. Each has its own syllable and note, like slices of a sung phrase.
    static func pads(_ g: Genre) -> [Pad] {
        let root = 57 + ((keyRoot(g) - 9 + 12) % 12)
        return [
            Pad(syllable: "Yeah", pitch: root + 12, from: 2, to: 0),
            Pad(syllable: "Hey", pitch: root + 10, from: 1, to: 2),
            Pad(syllable: "Ee", pitch: root + 7, from: 2, to: 2),
            Pad(syllable: "Oh", pitch: root + 5, from: 3, to: 3),
            Pad(syllable: "Oo", pitch: root + 3, from: 4, to: 4),
            Pad(syllable: "Ah", pitch: root, from: 0, to: 0),
        ]
    }

    private static func scaled(_ v: Double, octaves: Double) -> Float { Float(pow(2, (v - 0.5) * octaves)) }

    static func preset(_ t: JamTrack) -> Preset {
        let list = t.part == .bass ? bassPresets : (t.part == .keys ? keyPresets : leadPresets)
        return list[min(max(0, t.preset), list.count - 1)]
    }

    static func patch(_ t: JamTrack) -> SynthPatch {
        var p = preset(t).patch
        let length = scaled(t.value(.length), octaves: 3)
        p.cutoff *= scaled(t.value(.tone), octaves: 4)
        p.envAmount *= scaled(t.value(.punch), octaves: 3)
        p.resonance = min(0.92, max(0, p.resonance + Float(t.value(.reso) - 0.5)))
        p.decay *= length
        p.release *= length
        p.attack = min(1.2, max(0.001, p.attack * scaled(t.value(.attack), octaves: 8)))
        p.detuneCents = min(40, max(0, p.detuneCents + Float(t.value(.width) - 0.5) * 30))
        return p
    }

    static let holds = [1, 2, 3, 4, 6, 8, 12, 16]

    static func holdIndex(_ t: JamTrack) -> Int {
        min(holds.count - 1, max(0, preset(t).hold + Int(((t.value(.length) - 0.5) * 8).rounded())))
    }

    static func holdSteps(_ t: JamTrack) -> Int { holds[holdIndex(t)] }

    static func kit(_ t: JamTrack, _ g: Genre) -> DrumKit {
        var k = kits[min(max(0, t.preset), kits.count - 1)].kit
        let tune = scaled(t.value(.kickTune), octaves: 2)
        k.kickStartHz *= tune
        k.kickEndHz *= tune
        k.kickDecay *= scaled(t.value(.kickLength), octaves: 3)
        k.kickDrive = min(8, max(0.6, k.kickDrive * scaled(t.value(.kickPunch), octaves: 3)))
        k.kickClick = min(1, max(0, k.kickClick + Float(t.value(.kickClick) - 0.5)))
        k.clapTone *= scaled(t.value(.clapTone), octaves: 2)
        k.clapDecay *= scaled(t.value(.clapLength), octaves: 3)
        k.hatTone = min(16_000, k.hatTone * scaled(t.value(.hatTone), octaves: 1.5))
        k.hatDecay *= scaled(t.value(.hatLength), octaves: 3)
        k.openHatDecay *= scaled(t.value(.openLength), octaves: 3)
        k.percHz *= scaled(t.value(.rimTune), octaves: 2)
        k.percDecay *= scaled(t.value(.rimLength), octaves: 3)
        return k
    }

    static func levelParam(_ d: DrumTrack) -> JamParam {
        switch d {
        case .kick: .kickLevel
        case .clap: .clapLevel
        case .hat: .hatLevel
        case .openHat: .openLevel
        case .perc: .rimLevel
        }
    }

    static func drumLevel(_ t: JamTrack, _ d: DrumTrack) -> Float { Float(t.value(levelParam(d)) * 2) }

    static func vox(_ t: JamTrack) -> VoxSettings {
        var s = voxPresets[min(max(0, t.preset), voxPresets.count - 1)].settings
        s.formant *= scaled(t.value(.formant), octaves: 1)
        s.breath = min(0.9, max(0, s.breath + Float(t.value(.breath) - 0.5) * 0.8))
        return s
    }

    static func pitchShift(_ t: JamTrack) -> Int { Int(((t.value(.pitch) - 0.5) * 24).rounded()) }

    static let chopLengths = [1, 2, 3, 4, 6, 8]

    static func chopSteps(_ t: JamTrack) -> Int {
        chopLengths[min(chopLengths.count - 1, max(0, 1 + Int(((t.value(.voxLength) - 0.5) * 6).rounded())))]
    }

    static func mix(_ t: JamTrack) -> (level: Float, pan: Float, reverb: Float, delay: Float, duck: Float) {
        (t.muted ? 0 : Float(MixerTask.level(t.volume)), Float((t.value(.pan) - 0.5) * 2),
         Float(t.value(.reverb)), Float(t.value(.delay) * 0.8), Float(t.value(.pump) * 0.85))
    }

    // MARK: Knob text

    private static func hz(_ f: Float) -> String { f >= 1000 ? String(format: "%.1fk", f / 1000) : "\(Int(f)) Hz" }
    private static func ms(_ s: Float) -> String { s >= 1 ? String(format: "%.1f s", s) : "\(Int(s * 1000)) ms" }
    private static func pct(_ v: Double) -> String { "\(Int((v * 100).rounded()))%" }
    private static func semis(_ n: Int) -> String { n == 0 ? "0 st" : String(format: "%+ld st", n) }

    static func noteValue(_ steps: Int) -> String {
        [1: "1/16", 2: "1/8", 3: "3/16", 4: "1/4", 6: "3/8", 8: "1/2", 12: "3/4", 16: "1 bar"][steps] ?? "\(steps) steps"
    }

    static func text(_ p: JamParam, _ t: JamTrack, _ g: Genre) -> String {
        let v = t.value(p)
        switch p {
        case .tone: return hz(patch(t).cutoff)
        case .reso: return pct(Double(patch(t).resonance))
        case .punch: return pct(v)
        case .length:
            return t.part == .keys ? noteValue(holdSteps(t)) : ms(patch(t).decay)
        case .attack: return ms(patch(t).attack)
        case .width: return "\(Int(patch(t).detuneCents)) ct"
        case .pitch: return semis(pitchShift(t))
        case .formant:
            let f = scaled(v, octaves: 1)
            return abs(f - 1) < 0.02 ? "Natural" : String(format: "%+ld%%", Int(((f - 1) * 100).rounded()))
        case .breath: return pct(Double(vox(t).breath))
        case .voxLength: return noteValue(chopSteps(t))
        case .reverb, .delay, .pump: return pct(v)
        case .pan:
            let pan = (v - 0.5) * 2
            return abs(pan) < 0.05 ? "Centre" : (pan < 0 ? "L \(Int(-pan * 100))" : "R \(Int(pan * 100))")
        case .kickTune, .rimTune: return semis(Int(((v - 0.5) * 24).rounded()))
        case .kickLength: return ms(kit(t, g).kickDecay)
        case .kickPunch, .kickClick: return pct(v)
        case .clapTone: return hz(kit(t, g).clapTone)
        case .clapLength: return ms(kit(t, g).clapDecay)
        case .hatTone: return hz(kit(t, g).hatTone)
        case .hatLength: return ms(kit(t, g).hatDecay)
        case .openLength: return ms(kit(t, g).openHatDecay)
        case .rimLength: return ms(kit(t, g).percDecay)
        case .kickLevel, .clapLevel, .hatLevel, .openLevel, .rimLevel:
            let gain = v * 2
            guard gain > 0.001 else { return "Off" }
            let db = 20 * log10(gain)
            return abs(db) < 0.5 ? "0 dB" : String(format: "%+.0f dB", db)
        }
    }

    // MARK: Auditioning

    /// A short sample of a track's sound, for when you change a preset or turn a knob.
    static func audition(_ t: JamTrack, _ g: Genre, drum: DrumTrack = .kick) {
        let engine = AudioEngine.shared
        switch t.part {
        case .drums:
            engine.trigger(drum, kit: kit(t, g), velocity: drumLevel(t, drum))
        case .bass:
            engine.playNote(Studio.bassRows(g).last ?? 33, seconds: 0.4, patch: patch(t))
        case .keys:
            let chord = Studio.palette(g).first ?? .am7
            let seconds = Double(holdSteps(t)) * 60 / g.bpm / 4
            engine.playChord(chord.pitches, seconds: max(0.15, seconds), patch: patch(t))
        case .lead:
            let rows = leadRows(g)
            engine.playNote(rows[rows.count - 1], seconds: 0.18, patch: patch(t))
            engine.playNote(rows[rows.count - 2], seconds: 0.18, patch: patch(t), delay: 0.16)
            engine.playNote(rows[rows.count - 4], seconds: 0.3, patch: patch(t), delay: 0.32)
        case .vox:
            let pad = pads(g)[0]
            let seconds = Double(chopSteps(t)) * 60 / g.bpm / 4
            engine.playVox(pad.pitch + pitchShift(t), seconds: max(0.12, seconds), from: pad.from, to: pad.to,
                           settings: vox(t))
        }
    }

    /// Play one chop pad.
    static func audition(pad: Int, _ t: JamTrack, _ g: Genre) {
        let pads = pads(g)
        guard pad < pads.count else { return }
        let p = pads[pad]
        let seconds = Double(chopSteps(t)) * 60 / g.bpm / 4
        AudioEngine.shared.playVox(p.pitch + pitchShift(t), seconds: max(0.12, seconds), from: p.from, to: p.to,
                                   settings: vox(t))
    }
}

// MARK: - Store

/// Saved jams, newest first. Old Studio loops are brought over the first time.
@Observable
final class JamStore {
    private(set) var jams: [Jam] = []
    private let key = "groova.jams.v1"
    private let migratedKey = "groova.jams.migratedSketches"

    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: key), let saved = try? JSONDecoder().decode([Jam].self, from: data) {
            jams = saved.sorted { $0.updated > $1.updated }
        }
        if !defaults.bool(forKey: migratedKey) {
            defaults.set(true, forKey: migratedKey)
            if let data = defaults.data(forKey: "groova.sketches.v1"),
               let sketches = try? JSONDecoder().decode([Sketch].self, from: data), !sketches.isEmpty {
                jams += sketches.map(Jam.from).filter { s in !jams.contains { $0.id == s.id } }
                jams.sort { $0.updated > $1.updated }
                persist()
            }
        }
    }

    func save(_ jam: Jam) {
        var j = jam
        j.updated = .now
        if let i = jams.firstIndex(where: { $0.id == j.id }) { jams.remove(at: i) }
        jams.insert(j, at: 0)
        persist()
    }

    func delete(_ id: UUID) {
        jams.removeAll { $0.id == id }
        persist()
    }

    func contains(_ id: UUID) -> Bool { jams.contains { $0.id == id } }

    private func persist() {
        if let data = try? JSONEncoder().encode(jams) { UserDefaults.standard.set(data, forKey: key) }
    }
}
