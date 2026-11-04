//
//  CourseKit.swift
//  Groova
//
//  Short builders for writing lessons, so each genre's course reads like a lesson plan.
//

import Foundation

nonisolated enum K {
    /// Fader position for "as designed".
    static let u = MixerTask.unity

    static let fullHouseLanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]
    static let sections4 = ["Intro", "Build", "Drop", "Break"]

    // MARK: Structure

    static func unit(_ id: String, _ number: Int, _ title: String, _ subtitle: String, _ lessons: [Lesson]) -> Unit {
        Unit(id: id, number: number, title: title, subtitle: subtitle, lessons: lessons)
    }

    static func core(_ id: String, _ number: Int, _ title: String, _ subtitle: String, _ lessons: [Lesson]) -> Unit {
        Unit(id: id, number: number, title: title, subtitle: subtitle, lessons: lessons, part: .foundations)
    }

    static func lesson(_ id: String, _ title: String, _ subtitle: String, _ symbol: String, _ skill: Skill,
                       _ xp: Int, _ steps: [LessonStep]) -> Lesson {
        Lesson(id: id, title: title, subtitle: subtitle, symbol: symbol, skill: skill, xp: xp, steps: steps)
    }

    static func mastery(_ id: String, _ title: String, _ subtitle: String, _ skill: Skill, _ xp: Int,
                        _ steps: [LessonStep]) -> Lesson {
        Lesson(id: id, title: title, subtitle: subtitle, symbol: "crown.fill", skill: skill, xp: xp, steps: steps,
               isMastery: true)
    }

    // MARK: Drums

    static func intro(_ title: String, _ body: String, _ pads: [DrumTrack], demo: Pattern? = nil) -> LessonStep {
        .intro(IntroStep(title: title, body: body, pads: pads, demo: demo))
    }

    static func drumRule(_ prompt: String, _ hint: String, tracks: [DrumTrack], edit: Set<DrumTrack>,
                         start: Pattern = Pattern(), target: Pattern) -> LessonStep {
        .sequencer(SequencerTask(prompt: prompt, hint: hint, mode: .rule, tracks: tracks, editable: edit,
                                 start: start, target: target))
    }

    static func drumCopy(_ prompt: String, _ hint: String, tracks: [DrumTrack], edit: Set<DrumTrack>,
                         start: Pattern = Pattern(), target: Pattern, threshold: Double = 0.8) -> LessonStep {
        .sequencer(SequencerTask(prompt: prompt, hint: hint, mode: .recreate, tracks: tracks, editable: edit,
                                 start: start, target: target, threshold: threshold))
    }

    static func drumMake(_ prompt: String, _ hint: String, tracks: [DrumTrack], edit: Set<DrumTrack>,
                         start: Pattern = Pattern(), goal: CreativeGoal) -> LessonStep {
        .sequencer(SequencerTask(prompt: prompt, hint: hint, mode: .create(goal), tracks: tracks, editable: edit,
                                 start: start))
    }

    static func swingMake(_ prompt: String, _ hint: String, tracks: [DrumTrack], start: Pattern,
                          atLeast: Double) -> LessonStep {
        .sequencer(SequencerTask(prompt: prompt, hint: hint, mode: .create(.swingAtLeast(atLeast)), tracks: tracks,
                                 editable: [], start: start, swingControl: true))
    }

    // MARK: Bass

    static func bassRule(_ prompt: String, _ hint: String, rows: [Int], target: [NoteEvent],
                         backing: Pattern) -> LessonStep {
        .pianoRoll(PianoRollTask(prompt: prompt, hint: hint, mode: .rule, rows: rows, target: target, backing: backing))
    }

    static func bassCopy(_ prompt: String, _ hint: String, rows: [Int], target: [NoteEvent], backing: Pattern,
                         threshold: Double = 0.8) -> LessonStep {
        .pianoRoll(PianoRollTask(prompt: prompt, hint: hint, mode: .recreate, rows: rows, target: target,
                                 backing: backing, threshold: threshold))
    }

    static func bassMake(_ prompt: String, _ hint: String, rows: [Int], backing: Pattern, notes: Int = 4) -> LessonStep {
        .pianoRoll(PianoRollTask(prompt: prompt, hint: hint, mode: .create(.notesAtLeast(notes)), rows: rows,
                                 backing: backing))
    }

    // MARK: Melody (played on the keys)

    static func leadRule(_ prompt: String, _ hint: String, rows: [Int], target: [NoteEvent], backing: Pattern,
                         start: [NoteEvent] = []) -> LessonStep {
        .pianoRoll(PianoRollTask(prompt: prompt, hint: hint, mode: .rule, rows: rows, target: target, backing: backing,
                                 start: start, voice: .lead))
    }

    static func leadCopy(_ prompt: String, _ hint: String, rows: [Int], target: [NoteEvent], backing: Pattern,
                         start: [NoteEvent] = [], threshold: Double = 0.8) -> LessonStep {
        .pianoRoll(PianoRollTask(prompt: prompt, hint: hint, mode: .recreate, rows: rows, target: target,
                                 backing: backing, threshold: threshold, start: start, voice: .lead))
    }

    static func leadMake(_ prompt: String, _ hint: String, rows: [Int], backing: Pattern, notes: Int = 4,
                         start: [NoteEvent] = []) -> LessonStep {
        .pianoRoll(PianoRollTask(prompt: prompt, hint: hint, mode: .create(.notesAtLeast(notes)), rows: rows,
                                 backing: backing, start: start, voice: .lead))
    }

    /// A demo loop with a lead line on top, for intro cards.
    static func withLead(_ base: Pattern, _ notes: [NoteEvent]) -> Pattern {
        var p = base
        p.chords += notes.map { ChordEvent(step: $0.step, pitches: [$0.pitch], length: $0.length) }
        return p
    }

    /// Notes as (step, pitch) or (step, pitch, length).
    static func line(_ n: [(Int, Int)]) -> [NoteEvent] { n.map { NoteEvent($0.0, $0.1) } }
    static func line(_ n: [(Int, Int, Int)]) -> [NoteEvent] { n.map { NoteEvent($0.0, $0.1, $0.2) } }

    /// Play these notes in order on the keyboard.
    static func play(_ prompt: String, _ body: String, _ sequence: [Int], low: Int, high: Int) -> LessonStep {
        .keyboard(KeyboardTask(prompt: prompt, body: body, sequence: sequence, lowNote: low, highNote: high))
    }

    /// A phrase of single notes for ear training. Named by note so levels can transpose it.
    static func phrase(_ pitches: [Int]) -> [ChordShape] {
        pitches.map { ChordShape(name: NoteName.name($0), pitches: [$0]) }
    }

    static func notes(_ pitch: Int, _ steps: [Int], length: Int = 1) -> [NoteEvent] {
        steps.map { NoteEvent($0, pitch, length) }
    }

    // MARK: Chords

    static func ch(_ step: Int, _ chord: ChordShape, _ length: Int = 1) -> ChordEvent {
        ChordEvent(step: step, pitches: chord.pitches, length: length)
    }

    static func build(_ prompt: String, _ body: String, _ chord: ChordShape, start: [Int] = [],
                      low: Int = 55, high: Int = 67, exact: Bool = false) -> LessonStep {
        .chordBuilder(ChordBuilderTask(prompt: prompt, body: body, target: chord, start: start, lowNote: low,
                                       highNote: high, exact: exact))
    }

    static func quiz(_ prompt: String, _ body: String, _ rounds: [EarRound]) -> LessonStep {
        .earChoice(EarChoiceTask(prompt: prompt, body: body, rounds: rounds))
    }

    static func round(_ chords: [ChordShape], _ options: [String], _ answer: Int, _ explain: String = "") -> EarRound {
        EarRound(chords: chords, options: options, answer: answer, explain: explain)
    }

    /// A listening round: loops played in order, `bars` bars each.
    static func hear(_ loops: [Pattern], _ options: [String], _ answer: Int, _ explain: String = "",
                     bars: Int = 1, bpm: Double? = nil, swing: Double? = nil, genre: Genre? = nil) -> EarRound {
        EarRound(chords: [], options: options, answer: answer, explain: explain, loops: loops, bars: bars, bpm: bpm,
                 swing: swing, genre: genre)
    }

    /// Find a tempo: by number, or by ear against a reference.
    static func tempo(_ prompt: String, _ body: String, loop: Pattern, target: Double?, start: Double = 100,
                      byEar: Bool = false, swing: Double? = nil) -> LessonStep {
        .tempo(TempoTask(prompt: prompt, body: body, loop: loop, target: target, start: start, byEar: byEar,
                         swing: swing))
    }

    /// A lane of vocal chops. `target` and `start` map steps to chop indexes.
    static func chops(_ prompt: String, _ hint: String, _ mode: TaskMode, _ chops: [VoxChop], backing: Pattern,
                      start: [Int: Int] = [:], target: [Int: Int] = [:], length: Int = 2,
                      vox: VoxSettings = VoxSettings()) -> LessonStep {
        var t = ChordLaneTask(prompt: prompt, hint: hint, mode: mode, palette: chops.map(\.shape), backing: backing,
                              start: start, target: target, stabLength: length)
        t.chops = chops
        t.vox = vox
        return .chordLane(t)
    }

    static func lane(_ prompt: String, _ hint: String, _ mode: TaskMode, palette: [ChordShape], backing: Pattern,
                     start: [Int: Int] = [:], target: [Int: Int] = [:], length: Int = 1) -> LessonStep {
        .chordLane(ChordLaneTask(prompt: prompt, hint: hint, mode: mode, palette: palette, backing: backing,
                                 start: start, target: target, stabLength: length))
    }

    // MARK: Sound & mix

    static func lab(_ prompt: String, _ body: String, _ params: [SoundParam], start: [Double],
                    target: [Double]? = nil, loop: Pattern) -> LessonStep {
        .soundLab(SoundLabTask(prompt: prompt, body: body, params: params, start: start, target: target, loop: loop))
    }

    static func mix(_ prompt: String, _ body: String, _ channels: [MixChannel], start: [Double],
                    target: [Double]? = nil, loop: Pattern) -> LessonStep {
        .mixer(MixerTask(prompt: prompt, body: body, channels: channels, start: start, target: target, loop: loop))
    }

    static func filterSweep(_ prompt: String, _ body: String, _ backing: Pattern) -> LessonStep {
        .filter(FilterTask(prompt: prompt, body: body, backing: backing))
    }

    static func filterMatch(_ prompt: String, _ body: String, cutoff: Double, resonance: Double,
                            _ backing: Pattern) -> LessonStep {
        .filter(FilterTask(prompt: prompt, body: body, target: (cutoff: cutoff, resonance: resonance), backing: backing))
    }

    static func space(_ prompt: String, _ body: String, _ backing: Pattern) -> LessonStep {
        .reverb(ReverbTask(prompt: prompt, body: body, backing: backing))
    }

    // MARK: Arrangement

    /// Parse lane rows like "xx-x": x = on, anything else = off.
    static func grid(_ rows: String...) -> [[Bool]] {
        rows.map { $0.map { $0 == "x" } }
    }

    static func arrange(_ prompt: String, _ hint: String, _ mode: TaskMode, sections: [String] = sections4,
                        lanes: [Instrument] = fullHouseLanes, loop: Pattern, start: [[Bool]] = [],
                        target: [[Bool]] = []) -> LessonStep {
        .arrangement(ArrangementTask(prompt: prompt, hint: hint, mode: mode, sections: sections, lanes: lanes,
                                     loop: loop, start: start, target: target))
    }

    // MARK: Mastery

    static func groove(_ prompt: String, reference: Pattern, tracks: [DrumTrack], rows: [Int],
                       bars: Int = 4) -> LessonStep {
        .mastery(MasteryTask(prompt: prompt, reference: reference, tracks: tracks, bassRows: rows, bars: bars))
    }
}
