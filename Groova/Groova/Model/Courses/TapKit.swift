//
//  TapKit.swift
//  Groova
//
//  Builders for the tap pad and the tile arranger, plus small helpers the new courses share.
//

import Foundation

extension K {
    // MARK: Tap pad

    /// Tap on these steps of every bar, after one bar to listen. `steps: [0, 4, 8, 12]` is the pulse.
    nonisolated static func tapAlong(_ prompt: String, _ body: String, loop: Pattern, bars: Int = 5, steps: [Int] = [0, 4, 8, 12],
                         guideBars: Int = 1000, bpm: Double? = nil, swing: Double? = nil, label: String = "Tap",
                         unit: String = "beats", sound: DrumTrack? = .perc, tolerance: Double = 1.2,
                         threshold: Double = 0.75) -> LessonStep {
        let targets = (1..<max(2, bars)).flatMap { b in steps.map { b * Pattern.steps + $0 } }
        return .tap(TapTask(prompt: prompt, body: body, loops: [loop], barsEach: bars, targets: targets,
                            guideBars: guideBars, tolerance: tolerance, threshold: threshold, bpm: bpm, swing: swing,
                            sound: sound, padLabel: label, unit: unit))
    }

    /// Tap once each time the music changes section. Loops play in order, `barsEach` bars each.
    nonisolated static func tapChanges(_ prompt: String, _ body: String, loops: [Pattern], barsEach: Int = 2,
                           bpm: Double? = nil, swing: Double? = nil, label: String = "Change!",
                           threshold: Double = 0.66) -> LessonStep {
        let targets = (1..<max(2, loops.count)).map { $0 * barsEach * Pattern.steps }
        return .tap(TapTask(prompt: prompt, body: body, loops: loops, barsEach: barsEach, targets: targets,
                            guideBars: 0, tolerance: 4, threshold: threshold, bpm: bpm, swing: swing, sound: nil,
                            padLabel: label, unit: "changes"))
    }

    /// Tap at chosen moments: steps counted from the very start, across several loops.
    nonisolated static func tapMoments(_ prompt: String, _ body: String, loops: [Pattern], barsEach: Int, at targets: [Int],
                           guideBars: Int = 0, bpm: Double? = nil, swing: Double? = nil, label: String = "Tap",
                           unit: String = "taps", sound: DrumTrack? = .perc, tolerance: Double = 1.5,
                           threshold: Double = 0.7) -> LessonStep {
        .tap(TapTask(prompt: prompt, body: body, loops: loops, barsEach: barsEach, targets: targets,
                     guideBars: guideBars, tolerance: tolerance, threshold: threshold, bpm: bpm, swing: swing,
                     sound: sound, padLabel: label, unit: unit))
    }

    // MARK: Tile arranger

    nonisolated static func tile(_ name: String, _ loop: Pattern, _ tag: String = "") -> OrderTile {
        OrderTile(name: name, loop: loop, tag: tag)
    }

    nonisolated static func order(_ prompt: String, _ hint: String, _ mode: TaskMode, tiles: [OrderTile], answer: [Int] = [],
                      slots: Int? = nil, start: [Int?] = [], locked: Set<Int> = [], barsEach: Int = 1,
                      bed: Pattern? = nil, names: [String] = [], bpm: Double? = nil, swing: Double? = nil,
                      threshold: Double = 0.99) -> LessonStep {
        .order(OrderTask(prompt: prompt, hint: hint, mode: mode, tiles: tiles, slots: slots ?? max(1, answer.count),
                         answer: answer, start: start, locked: locked, barsEach: barsEach, bpm: bpm, swing: swing,
                         bed: bed, threshold: threshold, slotNames: names))
    }

    // MARK: Shared helpers

    /// A chord held for a whole bar, as a one-bar pattern.
    nonisolated static func bar(_ chord: ChordShape, bass: Int? = nil, length: Int = 14) -> Pattern {
        Pattern(bass: bass.map { [NoteEvent(0, $0, length)] } ?? [], chords: [K.ch(0, chord, length)])
    }

    /// Two chords, half a bar each.
    nonisolated static func halves(_ a: ChordShape, _ b: ChordShape, length: Int = 7) -> Pattern {
        Pattern(chords: [K.ch(0, a, length), K.ch(8, b, length)])
    }

    /// Single notes as a lead line on the chord synth, for demos and listening rounds.
    nonisolated static func melody(_ notes: [NoteEvent], over base: Pattern = Pattern()) -> Pattern {
        K.withLead(base, notes)
    }

    /// Lead notes as (step, pitch, length).
    nonisolated static func tune(_ n: [(Int, Int, Int)]) -> [NoteEvent] { n.map { NoteEvent($0.0, $0.1, $0.2) } }

    /// A drum pattern with some parts removed: for "what dropped out?" and arrangement tiles.
    nonisolated static func only(_ p: Pattern, _ drums: Set<DrumTrack>, bass: Bool = false, chords: Bool = false) -> Pattern {
        p.keeping(drums, bass: bass, chords: chords)
    }

    /// All five lanes switched on, for arrangement steps.
    nonisolated static let allDrums: Set<DrumTrack> = [.kick, .clap, .hat, .openHat, .perc]
}
