//
//  F2F3.swift
//  Groova
//
//  Foundation F2, Pitch, Notes & Your Ear, and F3, Harmony, Chords & Bass.
//

import Foundation

nonisolated enum F2F3 {
    typealias F = FKit

    static let units: [Unit] = [f2, f3]

    /// Soft drums and a C to Am pad: a bed for melodies.
    static let bed = Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 6, 10, 14],
                             chords: [K.ch(0, F.c, 7), K.ch(8, F.am, 7)])
    static let bedFG = Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 6, 10, 14],
                               chords: [K.ch(0, F.f, 7), K.ch(8, F.g, 7)])
    static let bedNoDrums = Pattern(chords: [K.ch(0, F.c, 7), K.ch(8, F.am, 7)])
    /// Rows with one outside note, F sharp, for hearing what doesn't belong.
    static let outsideRows = [72, 69, 67, 66, 64, 62, 60]
    static let lowKeys = 55, highKeys = 74

    static let call = K.tune([(0, 60, 2), (2, 62, 2), (4, 64, 4)])
    static let echo5 = K.tune([(0, 64, 2), (2, 67, 2), (4, 69, 2), (6, 67, 2), (8, 64, 4)])

    static func held(_ c: ChordShape) -> Pattern { Pattern(chords: [K.ch(0, c, 14)]) }

    // MARK: - F2 · Pitch, Notes & Your Ear

    static let f2 = Unit(id: "f2", number: 2, title: "Pitch, Notes & Your Ear",
                         subtitle: "High and low, the keys, steps, scales and copying by ear",
                         lessons: F2Games.lessons, part: .foundations, code: "F")

    // MARK: - F3 · Harmony, Chords & Bass

    static let f3 = Unit(id: "f3", number: 3, title: "Harmony, Chords & Bass",
                         subtitle: "Triads, major and minor, progressions, bass and toplines",
                         lessons: F3Games.lessons, part: .foundations, code: "F")

    // MARK: - Silver and Gold

    /// F2 and F3 tiers now live in F2Games and F3Games.
    static let levels: [String: LevelPair] = [:]
}
