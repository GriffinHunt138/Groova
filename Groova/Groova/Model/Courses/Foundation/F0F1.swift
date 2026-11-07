//
//  F0F1.swift
//  Groova
//
//  Foundation F0, Make Sound Immediately, and F1, Rhythm & Groove.
//

import Foundation

nonisolated enum F0F1 {
    typealias F = FKit

    /// F0 is retired: the course starts at F1. Its lessons stay in F0Games, unused.
    static let units: [Unit] = [f1]

    // Loops used across both units.
    static let pulseHats = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])
    static let wobbly = Pattern(kick: [0, 5, 7, 14], clap: [3, 11], hat: [1, 6, 9, 15])
    static let busyPerc = Pattern(kick: [0, 4, 8, 12], perc: [3, 6, 7, 11, 14])
    static let busier = Pattern(kick: [0, 4, 8, 12], clap: [2, 10], hat: Array(0..<16), perc: [3, 7, 11, 14, 15])
    static let noKick = Pattern(clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14], perc: [3, 10])
    static let pickup = Pattern(clap: [12, 13, 14, 15])
    static let halfTime = Pattern(kick: [0, 10], clap: [8], hat: [0, 2, 4, 6, 8, 10, 12, 14])
    static let melody = K.tune([(0, 64, 2), (2, 67, 2), (4, 69, 4), (8, 67, 2), (10, 64, 2), (12, 62, 4)])
    static let fullLead = K.melody(melody, over: F.beatBass)

    // MARK: - F0 · Make Sound Immediately

    static let f0 = Unit(id: "f0", number: 0, title: "Make Sound Immediately",
                         subtitle: "Pulse, beat, mood and your first loop", lessons: F0Games.lessons,
                         part: .foundations, code: "F")

    // MARK: - F1 · Rhythm & Groove

    static let f1 = Unit(id: "f1", number: 1, title: "Rhythm & Groove",
                         subtitle: "Beats, subdivision, syncopation and feel", lessons: F1Games.lessons,
                         part: .foundations, code: "F")

    // MARK: - Silver and Gold

    /// F0 and F1 tiers now live in F0Games and F1Games.
    static let levels: [String: LevelPair] = [:]
}
