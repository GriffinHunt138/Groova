//
//  Curriculum.swift
//  Groova
//
//  The learning engine's content. Lessons are data: a list of reusable interactive steps.
//  To add a lesson, add steps here; the player and step views do the rest.
//

import Foundation
import SwiftUI

// MARK: - Skills

nonisolated enum Skill: String, CaseIterable, Codable, Identifiable, Sendable {
    case rhythm, theory, soundDesign, mixing, arrangement

    var id: String { rawValue }

    var name: String {
        switch self {
        case .rhythm: "Rhythm"
        case .theory: "Music Theory"
        case .soundDesign: "Sound Design"
        case .mixing: "Mixing & FX"
        case .arrangement: "Arrangement"
        }
    }

    var symbol: String {
        switch self {
        case .rhythm: "square.grid.4x3.fill"
        case .theory: "pianokeys"
        case .soundDesign: "waveform"
        case .mixing: "slider.vertical.3"
        case .arrangement: "rectangle.split.3x1.fill"
        }
    }

    var color: Color { Color(hex: 0x7B5CFA) }
}

// MARK: - Structure

/// Part 1 is shared by every genre. Part 2 is the genre's own academy.
nonisolated enum CoursePart: Sendable {
    case foundations, academy
}

nonisolated struct Unit: Identifiable, Sendable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    let lessons: [Lesson]
    /// Shown honestly as "in production" with planned lesson titles.
    var plannedLessons: [String] = []
    var part: CoursePart = .academy
    /// Prefix for academy units, like "H" for House: "Unit H3".
    var code: String = ""

    var isComingSoon: Bool { lessons.isEmpty }
    var mastery: Lesson? { lessons.first(where: \.isMastery) }

    /// "UNIT 3" or "UNIT H3".
    var label: String { "UNIT \(code)\(number)" }
    /// "Unit 3" or "Unit H3".
    var shortLabel: String { "Unit \(code)\(number)" }

    func with(part: CoursePart, code: String, number: Int) -> Unit {
        Unit(id: id, number: number, title: title, subtitle: subtitle, lessons: lessons,
             plannedLessons: plannedLessons, part: part, code: code)
    }
}

nonisolated struct Lesson: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let skill: Skill
    let xp: Int
    let steps: [LessonStep]
    var isMastery = false
}

nonisolated enum LessonStep: Sendable {
    case intro(IntroStep)
    case sequencer(SequencerTask)
    case keyboard(KeyboardTask)
    case pianoRoll(PianoRollTask)
    case filter(FilterTask)
    case reverb(ReverbTask)
    case mastery(MasteryTask)
    case chordBuilder(ChordBuilderTask)
    case earChoice(EarChoiceTask)
    case chordLane(ChordLaneTask)
    case soundLab(SoundLabTask)
    case mixer(MixerTask)
    case arrangement(ArrangementTask)
    case tempo(TempoTask)
}

/// How a step is judged.
nonisolated enum TaskMode: Sendable {
    /// A clear instruction with one answer ("kick on every beat"). Needs 100%.
    case rule
    /// Listen and recreate by ear. Needs `threshold` (80% by default).
    case recreate
    /// Open-ended creation. Any musical attempt that meets the goal passes.
    case create(CreativeGoal)
}

nonisolated enum CreativeGoal: Sendable {
    case atLeast(DrumTrack, Int)
    case swingAtLeast(Double)
    case notesAtLeast(Int)
    case chordsAtLeast(Int)
    /// Arrangement: every section plays something and no two neighbours are identical.
    case variedSections
}

nonisolated struct IntroStep: Sendable {
    var title: String
    var body: String
    var pads: [DrumTrack]
    var demo: Pattern? = nil
    /// Overrides the "New sound" badge.
    var badge: String? = nil
    /// Set on the opening card of a Silver or Gold level.
    var level: LessonTier? = nil
}

nonisolated struct SequencerTask: Sendable {
    var prompt: String
    var hint: String
    var mode: TaskMode
    var tracks: [DrumTrack]
    var editable: Set<DrumTrack>
    var start = Pattern()
    var target = Pattern()
    var showBeatGuide = true
    var swingControl = false
    var threshold = 0.8
}

nonisolated struct KeyboardTask: Sendable {
    var prompt: String
    var body: String
    /// Notes the learner should play, in order.
    var sequence: [Int]
    var lowNote: Int
    var highNote: Int
}

nonisolated struct PianoRollTask: Sendable {
    var prompt: String
    var hint: String
    var mode: TaskMode
    /// Pitches shown as rows, from high to low.
    var rows: [Int]
    var target: [NoteEvent] = []
    var backing = Pattern()
    var threshold = 0.8
    /// Notes already on the grid when the step opens (e.g. the "call" you answer).
    var start: [NoteEvent] = []
    /// Bass plays on the bass synth. Lead plays on the keys/chord synth, for melodies and riffs.
    var voice: RollVoice = .bass
}

nonisolated enum RollVoice: Sendable, Equatable {
    case bass, lead
}

nonisolated struct FilterTask: Sendable {
    var prompt: String
    var body: String
    /// nil = free exploration (sweep low and high to finish)
    var target: (cutoff: Double, resonance: Double)? = nil
    var backing: Pattern
}

nonisolated struct ReverbTask: Sendable {
    var prompt: String
    var body: String
    var backing: Pattern
}

/// Tap keys to build a chord. Graded on note names, so any octave counts.
nonisolated struct ChordBuilderTask: Sendable {
    var prompt: String
    var body: String
    var target: ChordShape
    var start: [Int] = []
    var lowNote = 55
    var highNote = 67
    /// Grade the exact keys, not just the note names. Used for inversions and voicings.
    var exact = false
}

/// Listen, then pick the right answer. Each round plays one or more chords in order,
/// or, for listening rounds, one or more loops in order.
nonisolated struct EarRound: Sendable {
    var chords: [ChordShape]
    var options: [String]
    var answer: Int
    var explain: String = ""
    /// Loops played one after another, `bars` bars each. Empty for chord rounds.
    var loops: [Pattern] = []
    var bars = 1
    var bpm: Double? = nil
    var swing: Double? = nil
    /// Play the loops with another genre's sounds and tempo.
    var genre: Genre? = nil

    var isListening: Bool { !loops.isEmpty }
}

nonisolated struct EarChoiceTask: Sendable {
    var prompt: String
    var body: String
    var rounds: [EarRound]
}

/// A vocal chop: a sung note that glides from one vowel to another.
nonisolated struct VoxChop: Sendable, Hashable {
    var name: String
    var pitch: Int
    /// Vowels: 0 a, 1 e, 2 i, 3 o, 4 u.
    var from: Int
    var to: Int

    var shape: ChordShape { ChordShape(name: name, pitches: [pitch]) }
}

/// Find the tempo. With a target it's graded; `byEar` hides the number and plays a reference.
nonisolated struct TempoTask: Sendable {
    var prompt: String
    var body: String
    var loop: Pattern
    var target: Double? = nil
    var start: Double = 100
    var byEar = false
    /// How close counts, in BPM.
    var tolerance: Double = 3
    var swing: Double? = nil

    static let range: ClosedRange<Double> = 70...180
}

/// A one-bar lane of chord stabs. Pick a chord from the palette, tap steps to place it.
/// With `chops` it's a lane of vocal chops instead, sung by the vocal synth.
nonisolated struct ChordLaneTask: Sendable {
    var prompt: String
    var hint: String
    var mode: TaskMode
    var palette: [ChordShape]
    var backing: Pattern
    /// Step -> palette index.
    var start: [Int: Int] = [:]
    var target: [Int: Int] = [:]
    var stabLength = 1
    var threshold = 0.8
    var chops: [VoxChop]? = nil
    var vox = VoxSettings()

    func cells(_ map: [Int: Int]) -> [Int?] { (0..<Pattern.steps).map { map[$0] } }

    func chords(_ cells: [Int?]) -> [ChordEvent] {
        cells.enumerated().compactMap { step, idx in
            idx.map { ChordEvent(step: step, pitches: palette[$0].pitches, length: stabLength) }
        }
    }
}

// MARK: Sound Lab

/// One knob in the Sound Lab. Knob values run 0...1 and map onto real synth settings.
nonisolated enum SoundParam: String, Sendable, CaseIterable {
    case kickPitch, kickDecay, kickDrive
    case bassCutoff, bassEnv, bassResonance, bassDecay, bassWave
    case chordCutoff, chordDecay, chordAttack, chordRelease

    var label: String {
        switch self {
        case .kickPitch: "Pitch"
        case .kickDecay, .bassDecay, .chordDecay: "Length"
        case .kickDrive: "Drive"
        case .bassCutoff, .chordCutoff: "Cutoff"
        case .bassEnv: "Envelope"
        case .bassResonance: "Resonance"
        case .chordAttack: "Attack"
        case .chordRelease: "Release"
        case .bassWave: "Wave"
        }
    }

    func valueText(_ v: Double) -> String {
        switch self {
        case .kickPitch: "\(Int(90 + v * 250)) Hz"
        case .kickDecay: "\(Int((0.1 + v * 0.7) * 1000)) ms"
        case .kickDrive: "\(Int(v * 100))%"
        case .bassCutoff: Self.hz(80 * pow(2, v * 5))
        case .chordCutoff: Self.hz(150 * pow(2, v * 5))
        case .bassEnv, .bassResonance: "\(Int(v * 100))%"
        case .bassDecay: "\(Int((0.05 + v * 0.6) * 1000)) ms"
        case .chordDecay: "\(Int((0.06 + v * 0.9) * 1000)) ms"
        case .chordAttack: "\(Int((0.002 + v * v * 0.8) * 1000)) ms"
        case .chordRelease: "\(Int((0.03 + v * 1.2) * 1000)) ms"
        case .bassWave: v < 0.2 ? "Sine" : v < 0.4 ? "Round" : v < 0.6 ? "Saw" : v < 0.8 ? "Hollow" : "Square"
        }
    }

    private static func hz(_ f: Double) -> String {
        f >= 1000 ? String(format: "%.1f kHz", f / 1000) : "\(Int(f)) Hz"
    }

    func apply(_ v: Double, to kit: inout DrumKit) {
        let x = Float(max(0, min(1, v)))
        switch self {
        case .kickPitch:
            kit.kickStartHz = 90 + x * 250
            kit.kickEndHz = 38 + x * 26
        case .kickDecay: kit.kickDecay = 0.1 + x * 0.7
        case .kickDrive: kit.kickDrive = 1 + x * 4
        case .bassCutoff: kit.bass.cutoff = 80 * exp2f(x * 5)
        case .bassEnv: kit.bass.envAmount = x * 4000
        case .bassResonance: kit.bass.resonance = x * 0.9
        case .bassDecay: kit.bass.decay = 0.05 + x * 0.6
        case .chordCutoff: kit.chords.cutoff = 150 * exp2f(x * 5)
        case .chordDecay:
            kit.chords.decay = 0.06 + x * 0.9
            kit.chords.sustain = x * 0.5
        case .chordAttack: kit.chords.attack = 0.002 + x * x * 0.8
        case .chordRelease: kit.chords.release = 0.03 + x * 1.2
        case .bassWave:
            // Sine at 0, saw in the middle, square at 1.
            let saw = min(1, x * 2), square = max(0, x * 2 - 1)
            kit.bass.sine = 0.15 + 0.85 * (1 - saw)
            kit.bass.saw = 0.75 * saw * (1 - square)
            kit.bass.square = 0.6 * square
        }
    }
}

/// Turn knobs on a looping sound. With a target it's a by-ear match; without, free exploration.
nonisolated struct SoundLabTask: Sendable {
    var prompt: String
    var body: String
    var params: [SoundParam]
    var start: [Double]
    var target: [Double]? = nil
    var loop: Pattern
    var threshold = 0.8

    func kit(base: DrumKit, values: [Double]) -> DrumKit {
        var k = base
        for (p, v) in zip(params, values) { p.apply(v, to: &k) }
        return k
    }
}

// MARK: Mixer

nonisolated enum MixChannel: Hashable, Sendable {
    case drum(DrumTrack)
    case bass
    case chords
    case sidechain

    var label: String {
        switch self {
        case .drum(let t): t.name
        case .bass: "Bass"
        case .chords: "Chords"
        case .sidechain: "Pump"
        }
    }
}

/// Faders (0...1, 0.67 = as designed) and an optional sidechain knob.
nonisolated struct MixerTask: Sendable {
    var prompt: String
    var body: String
    var channels: [MixChannel]
    var start: [Double]
    var target: [Double]? = nil
    var loop: Pattern
    var threshold = 0.8

    static let unity = 2.0 / 3.0
    static func level(_ fader: Double) -> Double { fader * 1.5 }
}

// MARK: Arrangement

/// Switch instruments on and off across sections, then hear them play through in order.
nonisolated struct ArrangementTask: Sendable {
    var prompt: String
    var hint: String
    var mode: TaskMode
    var sections: [String]
    var lanes: [Instrument]
    /// The full loop. Each section plays the lanes switched on.
    var loop: Pattern
    /// lanes x sections
    var start: [[Bool]] = []
    var target: [[Bool]] = []
    var barsPerSection = 2
    var threshold = 0.8

    func grid(_ g: [[Bool]]) -> [[Bool]] {
        (0..<lanes.count).map { l in
            (0..<sections.count).map { s in l < g.count && s < g[l].count ? g[l][s] : false }
        }
    }

    func patterns(_ g: [[Bool]]) -> [Pattern] {
        let g = grid(g)
        return (0..<sections.count).map { s in
            var drums = Set<DrumTrack>()
            var bass = false, chords = false
            for (l, lane) in lanes.enumerated() where g[l][s] {
                switch lane {
                case .drum(let t): drums.insert(t)
                case .bass: bass = true
                case .chords: chords = true
                }
            }
            return loop.keeping(drums, bass: bass, chords: chords)
        }
    }
}

nonisolated struct MasteryTask: Sendable {
    var prompt: String
    var reference: Pattern
    var tracks: [DrumTrack]
    var bassRows: [Int]
    var bars: Int
}

// MARK: - Content

nonisolated enum Curriculum {
    /// Part 1, Core Foundations, then the genre's academy.
    static func units(for genre: Genre) -> [Unit] { byGenre[genre] ?? CoreCourse.units }

    static func academy(for genre: Genre) -> [Unit] {
        switch genre {
        case .house: HouseCourse.academy
        case .techno: TechnoCourse.academy
        case .ukGarage: GarageCourse.academy
        case .deepHouse: DeepHouseCourse.academy
        case .techHouse: TechHouseCourse.academy
        }
    }

    private static let byGenre: [Genre: [Unit]] = {
        var out: [Genre: [Unit]] = [:]
        for g in Genre.allCases {
            out[g] = CoreCourse.units + academy(for: g).enumerated().map { i, u in
                u.with(part: .academy, code: g.academyCode, number: i + 1)
            }
        }
        return out
    }()

    /// Progress for Core Foundations lessons is shared by every genre.
    static let coreKey = "core"
    static let coreIDs: Set<String> = Set(CoreCourse.units.flatMap { $0.lessons.map(\.id) })
    static func isCore(_ lessonID: String) -> Bool { coreIDs.contains(lessonID) }

    /// Every lesson that exists, by id, so units can be put together from lessons written elsewhere.
    static func lessons(_ ids: [String], from pool: [Unit]) -> [Lesson] {
        let all = pool.flatMap(\.lessons)
        return ids.compactMap { id in all.first { $0.id == id } }
    }

    static func allLessons(for genre: Genre) -> [Lesson] {
        units(for: genre).flatMap(\.lessons)
    }

    private static func previewUnit(_ g: Genre, title: String, planned: [String]) -> Unit {
        Unit(id: "\(g.rawValue).u1", number: 1, title: title, subtitle: "In the studio", lessons: [],
             plannedLessons: planned)
    }

    // A minor pentatonic bass rows (A1 ... A2), high to low
    static let bassRows = [45, 43, 40, 38, 36, 33]

    // MARK: House

    static let houseUnits: [Unit] = [
        Unit(id: "house.u1", number: 1, title: "Understanding the Groove",
             subtitle: "Kick, clap, hats & bass", lessons: [
                houseL1, houseL2, houseL3, houseL4, houseL5, houseMastery
             ]),
        Unit(id: "house.u2", number: 2, title: "Chords & Stabs",
             subtitle: "Chords, 7ths, stabs & progressions", lessons: [
                houseU2L1, houseU2L2, houseU2L3, houseU2L4, houseU2L5, houseU2Mastery
             ]),
    ] + HouseCourse.units

    static let fourFloor = Pattern(kick: [0, 4, 8, 12])

    static let houseL1 = Lesson(
        id: "house.u1.l1", title: "Four on the Floor", subtitle: "The heartbeat of house",
        symbol: "circle.circle.fill", skill: .rhythm, xp: 20, steps: [
            .intro(IntroStep(title: "Meet the kick",
                             body: "Every house track is built on this sound. Tap it.",
                             pads: [.kick])),
            .sequencer(SequencerTask(
                prompt: "Put a kick on every beat",
                hint: "A bar has 4 beats. They're the bright columns: 1, 5, 9 and 13.",
                mode: .rule, tracks: [.kick], editable: [.kick],
                target: fourFloor)),
            .sequencer(SequencerTask(
                prompt: "Listen, then copy this kick pattern",
                hint: "It's four on the floor, plus one extra kick pushing into the next bar.",
                mode: .recreate, tracks: [.kick], editable: [.kick],
                target: Pattern(kick: [0, 4, 8, 12, 14]))),
        ])

    static let houseL2 = Lesson(
        id: "house.u1.l2", title: "Clap Back", subtitle: "Beats two and four",
        symbol: "hands.clap.fill", skill: .rhythm, xp: 20, steps: [
            .intro(IntroStep(title: "Meet the clap",
                             body: "The clap answers the kick. Tap both and feel the call and response.",
                             pads: [.kick, .clap])),
            .sequencer(SequencerTask(
                prompt: "Add a clap on beats 2 and 4",
                hint: "Beat 2 is step 5, beat 4 is step 13 — on top of those kicks.",
                mode: .rule, tracks: [.kick, .clap], editable: [.clap],
                start: fourFloor, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]))),
            .sequencer(SequencerTask(
                prompt: "Copy this groove by ear",
                hint: "Claps on 2 and 4 again, plus a quick extra clap just before the bar loops.",
                mode: .recreate, tracks: [.kick, .clap], editable: [.clap],
                start: fourFloor, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 15]))),
        ])

    static let houseL3 = Lesson(
        id: "house.u1.l3", title: "Offbeat Hats", subtitle: "The \"and\" between beats",
        symbol: "sparkles", skill: .rhythm, xp: 25, steps: [
            .intro(IntroStep(title: "Meet the hi-hats",
                             body: "Closed hats tick. Open hats breathe. Tap both.",
                             pads: [.hat, .openHat],
                             demo: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14]))),
            .sequencer(SequencerTask(
                prompt: "Put open hats on every offbeat",
                hint: "Offbeats sit exactly between the kicks: steps 3, 7, 11 and 15.",
                mode: .rule, tracks: [.kick, .clap, .openHat], editable: [.openHat],
                start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14]))),
            .sequencer(SequencerTask(
                prompt: "Sprinkle closed hats to add movement",
                hint: "There's no wrong answer. Try the gaps between other sounds — drag across the row to paint.",
                mode: .create(.atLeast(.hat, 3)), tracks: [.kick, .clap, .hat, .openHat], editable: [.hat],
                start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14]))),
            .sequencer(SequencerTask(
                prompt: "Recreate the full groove",
                hint: "The kick and clap are classic. Listen closely to where the closed hats land.",
                mode: .recreate, tracks: [.kick, .clap, .hat, .openHat], editable: [.kick, .clap, .hat, .openHat],
                target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [3, 7, 11, 15], openHat: [2, 6, 10, 14]))),
        ])

    static let houseL4 = Lesson(
        id: "house.u1.l4", title: "Bounce the Bass", subtitle: "Syncopation with the piano roll",
        symbol: "pianokeys", skill: .theory, xp: 25, steps: [
            .keyboard(KeyboardTask(
                prompt: "Play A, then C, then E",
                body: "These three notes are the heart of A minor — the moody home key of this groove.",
                sequence: [45, 48, 52], lowNote: 45, highNote: 57)),
            .pianoRoll(PianoRollTask(
                prompt: "Put an A on every offbeat",
                hint: "Bass on the offbeat dodges the kick and makes the groove bounce. Bottom row, steps 3, 7, 11, 15.",
                mode: .rule, rows: bassRows,
                target: [2, 6, 10, 14].map { NoteEvent($0, 33) },
                backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14]))),
            .pianoRoll(PianoRollTask(
                prompt: "Make it bounce — copy this bassline",
                hint: "It starts on the offbeat A, then climbs. Drag a note sideways to make it longer.",
                mode: .recreate, rows: bassRows,
                target: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(7, 36), NoteEvent(10, 33),
                         NoteEvent(13, 40), NoteEvent(14, 38, 2)],
                backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14]))),
            .pianoRoll(PianoRollTask(
                prompt: "Write your own bassline",
                hint: "Any notes in this scale sound good together. Notes between the kicks bounce the most.",
                mode: .create(.notesAtLeast(4)), rows: bassRows,
                backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [3, 7, 11, 15], openHat: [2, 6, 10, 14]))),
        ])

    static let fxLoop = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [3, 7, 11, 15], openHat: [2, 6, 10, 14],
                                bass: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(7, 36), NoteEvent(10, 33),
                                       NoteEvent(13, 40), NoteEvent(14, 38, 2)],
                                chords: [ChordEvent(step: 3, pitches: [57, 60, 64, 67], length: 1),
                                         ChordEvent(step: 10, pitches: [57, 60, 64, 67], length: 2)])

    static let houseL5 = Lesson(
        id: "house.u1.l5", title: "Filter & Space", subtitle: "Shape sound with effects",
        symbol: "dial.medium.fill", skill: .soundDesign, xp: 25, steps: [
            .filter(FilterTask(
                prompt: "Sweep the filter",
                body: "A low-pass filter removes high frequencies. Close it right down, then open it all the way.",
                backing: fxLoop)),
            .filter(FilterTask(
                prompt: "Match the muffled sound",
                body: "Switch between Reference and Yours. Turn the knobs until they sound the same.",
                target: (cutoff: 650, resonance: 0.55),
                backing: fxLoop)),
            .reverb(ReverbTask(
                prompt: "Give the groove some space",
                body: "Reverb puts your sound in a room. Try a few spaces and find a mix you like.",
                backing: Pattern(kick: [0, 8], clap: [4, 12], openHat: [6, 14],
                                 chords: [ChordEvent(step: 10, pitches: [57, 60, 64, 67], length: 1)]))),
        ])

    static let houseMasteryReference = Pattern(
        kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14, 15],
        bass: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(9, 36), NoteEvent(10, 33), NoteEvent(14, 40, 2)])

    static let houseMastery = Lesson(
        id: "house.u1.mastery", title: "House Rhythm Mastery", subtitle: "Recreate a groove by ear",
        symbol: "crown.fill", skill: .rhythm, xp: 60, steps: [
            .mastery(MasteryTask(
                prompt: "Recreate this house groove",
                reference: houseMasteryReference,
                tracks: [.kick, .clap, .hat], bassRows: bassRows, bars: 4)),
        ], isMastery: true)

    // MARK: House Unit 2: Chords & Stabs

    /// Drums for the chord lessons: four on the floor, claps, offbeat hats.
    static let chordBacking = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])

    static let houseU2L1 = Lesson(
        id: "house.u2.l1", title: "Your First Chord", subtitle: "Three notes, one sound",
        symbol: "pianokeys.inverse", skill: .theory, xp: 25, steps: [
            .chordBuilder(ChordBuilderTask(
                prompt: "Build A minor",
                body: "A chord is three or more notes played together. A minor is built on A, its root, plus C and E. Tap A, C and E.",
                target: .am)),
            .earChoice(EarChoiceTask(
                prompt: "Happy or moody?",
                body: "Major chords sound bright. Minor chords sound dark. Listen and choose.",
                rounds: [
                    EarRound(chords: [.c], options: ["Happy (major)", "Moody (minor)"], answer: 0,
                             explain: "C major: bright and open."),
                    EarRound(chords: [.am], options: ["Happy (major)", "Moody (minor)"], answer: 1,
                             explain: "A minor: the moody chord you just built."),
                    EarRound(chords: [.em], options: ["Happy (major)", "Moody (minor)"], answer: 1,
                             explain: "E minor: another dark one."),
                ])),
            .chordLane(ChordLaneTask(
                prompt: "Play A minor on beats 1 and 3",
                hint: "Beats 1 and 3 are steps 1 and 9, right on top of the kick.",
                mode: .rule, palette: [.am], backing: chordBacking,
                target: [0: 0, 8: 0], stabLength: 4)),
        ])

    static let houseU2L2 = Lesson(
        id: "house.u2.l2", title: "Minor 7ths", subtitle: "The sound of house chords",
        symbol: "music.quarternote.3", skill: .theory, xp: 25, steps: [
            .chordBuilder(ChordBuilderTask(
                prompt: "Add a G to make Am7",
                body: "A, C and E are already there. One more note, G, turns it into a minor 7th: softer and jazzier.",
                target: .am7, start: [57, 60, 64])),
            .earChoice(EarChoiceTask(
                prompt: "Plain chord or 7th?",
                body: "A 7th adds a fourth note that makes the chord sound richer and less final.",
                rounds: [
                    EarRound(chords: [.am7], options: ["Plain (3 notes)", "7th (4 notes)"], answer: 1,
                             explain: "Am7: hear that extra shimmer on top?"),
                    EarRound(chords: [.am], options: ["Plain (3 notes)", "7th (4 notes)"], answer: 0,
                             explain: "Plain A minor: simpler and more final."),
                    EarRound(chords: [.em7], options: ["Plain (3 notes)", "7th (4 notes)"], answer: 1,
                             explain: "Em7: a 7th built on E."),
                ])),
            .chordBuilder(ChordBuilderTask(
                prompt: "Build Dm7: D, F, A and C",
                body: "Same recipe, starting on D. The notes can be in any order on the keyboard.",
                target: .dm7)),
        ])

    static let houseU2L3 = Lesson(
        id: "house.u2.l3", title: "The Stab", subtitle: "Short chords, big groove",
        symbol: "bolt.horizontal.fill", skill: .rhythm, xp: 25, steps: [
            .chordLane(ChordLaneTask(
                prompt: "Stab Am7 on every offbeat",
                hint: "A stab is a short, punchy chord hit. Offbeats sit between the kicks: steps 3, 7, 11 and 15.",
                mode: .rule, palette: [.am7], backing: chordBacking,
                target: [2: 0, 6: 0, 10: 0, 14: 0])),
            .chordLane(ChordLaneTask(
                prompt: "Copy this stab rhythm",
                hint: "One stab lands just after beat 1, then they skip around the claps. Five stabs in all.",
                mode: .recreate, palette: [.am7], backing: chordBacking,
                target: [1: 0, 3: 0, 6: 0, 10: 0, 13: 0])),
            .chordLane(ChordLaneTask(
                prompt: "Write your own stab rhythm",
                hint: "Place at least four stabs. Stabs between the kicks push the groove forward.",
                mode: .create(.chordsAtLeast(4)), palette: [.am7], backing: chordBacking)),
        ])

    static let houseU2L4 = Lesson(
        id: "house.u2.l4", title: "Moving Chords", subtitle: "Your first progression",
        symbol: "arrow.left.arrow.right", skill: .theory, xp: 30, steps: [
            .chordLane(ChordLaneTask(
                prompt: "Switch to Dm7 for the second half",
                hint: "Pick Dm7, then tap the stabs on steps 11 and 15 to change them.",
                mode: .rule, palette: [.am7, .dm7], backing: chordBacking,
                start: [2: 0, 6: 0, 10: 0, 14: 0],
                target: [2: 0, 6: 0, 10: 1, 14: 1])),
            .earChoice(EarChoiceTask(
                prompt: "Which chord comes second?",
                body: "Both start on Am7. Fmaj7 is new: a warm major 7th. Listen to where the second chord goes.",
                rounds: [
                    EarRound(chords: [.am7, .dm7], options: ["Dm7", "Em7"], answer: 0,
                             explain: "Am7 to Dm7: a classic house move."),
                    EarRound(chords: [.am7, .em7], options: ["Dm7", "Em7"], answer: 1,
                             explain: "Em7 sits higher and leans back toward Am7."),
                    EarRound(chords: [.am7, .fmaj7], options: ["Fmaj7", "Dm7"], answer: 0,
                             explain: "Fmaj7: warmer and brighter than Dm7."),
                ])),
            .chordLane(ChordLaneTask(
                prompt: "Recreate this progression",
                hint: "Two stabs of Am7, then it moves. Use Both to hear which chords don't match.",
                mode: .recreate, palette: [.am7, .dm7, .fmaj7], backing: chordBacking,
                target: [2: 0, 6: 0, 10: 2, 14: 1])),
        ])

    /// Am7 for the first half of the bar, Dm7 for the second, held so you can hear them.
    static let rootChords = [ChordEvent(step: 2, pitches: ChordShape.am7.pitches, length: 6),
                             ChordEvent(step: 10, pitches: ChordShape.dm7.pitches, length: 6)]

    static let houseU2L5 = Lesson(
        id: "house.u2.l5", title: "Follow the Roots", subtitle: "Bass that fits the chords",
        symbol: "point.topleft.down.to.point.bottomright.curvepath.fill", skill: .theory, xp: 25, steps: [
            .intro(IntroStep(
                title: "Meet the root",
                body: "Every chord is built up from one note, its root, and it's named after it. Am7 is built on A, Dm7 on D. House basslines usually play the root under each chord, so bass and chords fit together. Play this loop: Am7 then Dm7, with their roots in the bass.",
                pads: [],
                demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14],
                              bass: [NoteEvent(2, 33, 4), NoteEvent(10, 38, 4)], chords: rootChords),
                badge: "New idea")),
            .pianoRoll(PianoRollTask(
                prompt: "Play the root under each chord",
                hint: "The strip above the grid shows which chord is playing. Under Am7, put an A (bottom row) on step 3. Under Dm7, put a D (fourth row) on step 11. Stretch each note to four steps.",
                mode: .rule, rows: bassRows,
                target: [NoteEvent(2, 33, 4), NoteEvent(10, 38, 4)],
                backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], chords: rootChords))),
            .pianoRoll(PianoRollTask(
                prompt: "Copy this bassline under the chords",
                hint: "It bounces on the roots, A then D, with a quick jump up to the high A.",
                mode: .recreate, rows: bassRows,
                target: [NoteEvent(2, 33), NoteEvent(6, 45), NoteEvent(7, 33), NoteEvent(10, 38),
                         NoteEvent(14, 38, 2)],
                backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14],
                                 chords: [ChordEvent(step: 2, pitches: ChordShape.am7.pitches, length: 1),
                                          ChordEvent(step: 6, pitches: ChordShape.am7.pitches, length: 1),
                                          ChordEvent(step: 10, pitches: ChordShape.dm7.pitches, length: 1),
                                          ChordEvent(step: 14, pitches: ChordShape.dm7.pitches, length: 1)]))),
        ])

    static let houseU2Mastery = Lesson(
        id: "house.u2.mastery", title: "Piano House Mastery", subtitle: "Recreate the chords by ear",
        symbol: "crown.fill", skill: .theory, xp: 60, steps: [
            .chordLane(ChordLaneTask(
                prompt: "Recreate this piano house riff",
                hint: "Four chords this time. The rhythm starts on the offbeats, and the last stab comes early.",
                mode: .recreate, palette: [.am7, .dm7, .em7, .fmaj7],
                backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14, 15],
                                 bass: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(10, 38),
                                        NoteEvent(13, 40, 2)]),
                target: [2: 0, 6: 0, 10: 1, 13: 2, 15: 3])),
        ], isMastery: true)
}
