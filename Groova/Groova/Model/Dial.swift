//
//  Dial.swift
//  Groova
//
//  Dial It In, one of the core games: hear a target sound, move one slider until yours
//  matches it, lock it in.
//

import Foundation

nonisolated enum DialKind: Sendable {
    /// Master low-pass filter on a loop: dark to bright.
    case filter
    /// Reverb amount on a loop: dry to washed out.
    case reverb
    /// Bass level in a loop.
    case bassLevel
    /// One drum's level in a loop.
    case drumLevel(DrumTrack)
    /// How slowly a synth note fades in.
    case attack
    /// How long a synth note rings after it stops.
    case release
    /// Tempo of a loop: slow to fast.
    case tempo
}

nonisolated struct DialConfig: Sendable {
    var kind: DialKind
    /// What to match, e.g. "Match the brightness".
    var prompt: String
    /// Words at the two ends of the slider.
    var low: String
    var high: String
    /// The loop for filter, reverb, level and tempo.
    var groove: Pattern = Pattern()
    /// The phrase for attack and release.
    var notes: [Int] = [60, 64, 67, 72]
    /// One target per round, 0...1 along the slider.
    var targets: [Double]
    /// How close counts as a match.
    var tolerance: Double = 0.1
    var lives: Int = 3
    var bpm: Double = 96
}
