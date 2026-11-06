//
//  F4F5.swift
//  Groova
//
//  Foundation F4, Sounds & Production Tools, and F5, From Loop to Song. Shared production lessons
//  you can take alongside your genre.
//

import Foundation

nonisolated enum F4F5 {
    typealias F = FKit

    static let units: [Unit] = [f4, f5]

    // MARK: Sounds

    static let phrase = K.tune([(0, 64, 2), (2, 67, 2), (4, 72, 4), (8, 69, 2), (10, 67, 2), (12, 64, 4)])
    /// The phrase alone on the chord synth, for timbre rounds.
    static let line = K.melody(phrase)
    static let lineBeat = K.melody(phrase, over: F.beat)
    static let bassLoop = Pattern(kick: [0, 8], clap: [4, 12], bass: F.bassline)
    static let stabs = Pattern(kick: [0, 8], clap: [4, 12], hat: F.eighths,
                               chords: [K.ch(2, F.c), K.ch(6, F.c), K.ch(10, F.am), K.ch(14, F.am)])

    static let pluck: [SoundParam: Double] = [.chordAttack: 0, .chordDecay: 0.12, .chordRelease: 0.1, .chordCutoff: 0.55]
    static let keys: [SoundParam: Double] = [.chordAttack: 0, .chordDecay: 0.6, .chordRelease: 0.35, .chordCutoff: 0.75]
    static let pad: [SoundParam: Double] = [.chordAttack: 0.75, .chordDecay: 1, .chordRelease: 0.9, .chordCutoff: 0.4]

    // MARK: Song blocks

    static let song = K.melody(phrase, over: F.full)
    static let intro = Pattern(hat: F.eighths, chords: [K.ch(0, F.c, 6), K.ch(8, F.am, 6)])
    static let verse = F.beatBass
    static let chorus = song
    static let outro = Pattern(chords: [K.ch(0, F.c, 14)])
    static let breakdown = Pattern(chords: [K.ch(0, F.c, 6), K.ch(8, F.am, 6)])
    static let silence = Pattern()

    static func blocks() -> [OrderTile] {
        [K.tile("Intro", intro, "Hats & chords"), K.tile("Verse", verse, "Drums & bass"),
         K.tile("Chorus", chorus, "Everything"), K.tile("Outro", outro, "One chord")]
    }

    // MARK: - F4 · Sounds & Production Tools

    static let f4 = Unit(id: "f4", number: 4, title: "Sounds & Production Tools",
                         subtitle: "Timbre, synths, space and making parts fit",
                         lessons: F4Games.lessons, part: .foundations, code: "F")

    // MARK: - F5 · From Loop to Song

    static let f5 = Unit(id: "f5", number: 5, title: "From Loop to Song",
                         subtitle: "Sections, contrast, transitions and your first mini-track",
                         lessons: F5Games.lessons, part: .foundations, code: "F")

    // MARK: - Silver and Gold

    /// F4 and F5 tiers now live in F4Games and F5Games.
    static let levels: [String: LevelPair] = [:]
}
