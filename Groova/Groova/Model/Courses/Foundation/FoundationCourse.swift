//
//  FoundationCourse.swift
//  Groova
//
//  Part 1, Foundation: Music From Zero. Shared by every genre, and progress counts once.
//
//  F0 Make Sound Immediately   F1 Rhythm & Groove      F2 Pitch, Notes & Your Ear
//  F3 Harmony, Chords & Bass   F4 Sounds & Production  F5 From Loop to Song
//
//  F0–F3 are the beginner path. F4–F5 are shared production lessons you can take alongside
//  your genre. Each lesson has Bronze (the lesson), Silver (on your own) and Gold (a creative
//  challenge). Silver and Gold live in the matching *Levels dictionaries.
//

import Foundation

nonisolated enum FoundationCourse {
    static let units: [Unit] = F0F1.units + F2F3.units + F4F5.units

    static let levels: [String: LevelPair] = {
        var r: [String: LevelPair] = [:]
        for d in [F0Games.levels, F0F1.levels, F2F3.levels, F4F5.levels] { r.merge(d) { a, _ in a } }
        return r
    }()
}

/// Sounds the Foundation lessons share. Genre-neutral, in C major and A minor, so they sit in any kit.
nonisolated enum FKit {
    // MARK: Drums

    /// Kick on every beat: the pulse.
    static let pulse = Pattern(kick: [0, 4, 8, 12])
    /// The basic backbeat: kick on 1 and 3, snare on 2 and 4, eighth-note hats.
    static let beat = Pattern(kick: [0, 8], clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14])
    static let beatNoHats = Pattern(kick: [0, 8], clap: [4, 12])
    static let eighths = [0, 2, 4, 6, 8, 10, 12, 14]
    static let sixteenths = Array(0..<16)
    static let quarters = [0, 4, 8, 12]
    static let offbeats = [2, 6, 10, 14]
    /// A busier beat with a pickup kick.
    static let groove = Pattern(kick: [0, 7, 8, 10], clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14])
    static let fill = Pattern(kick: [0, 8], clap: [4, 12, 13, 14, 15], hat: [0, 2, 4, 6, 8, 10])

    // MARK: Pitch

    /// Bass rows in C, high to low: C3 A2 G2 F2 E2 C2.
    static let bassRows = [48, 45, 43, 41, 40, 36]
    /// Melody rows, C major pentatonic plus F and B, high to low: C5 down to C4.
    static let leadRows = [72, 71, 69, 67, 65, 64, 62, 60]
    /// Five friendly notes: C major pentatonic, high to low.
    static let penta = [69, 67, 64, 62, 60]

    // MARK: Chords

    static let c = ChordShape.c
    static let am = ChordShape.am
    static let f = ChordShape.f
    static let g = ChordShape.g
    static let em = ChordShape.em
    static let dm = ChordShape.dm
    static let cm = ChordShape(name: "Cm", pitches: [60, 63, 67])
    static let fm = ChordShape(name: "Fm", pitches: [56, 60, 65])
    static let a = ChordShape(name: "A", pitches: [57, 61, 64])
    static let e = ChordShape(name: "E", pitches: [56, 59, 64])
    static let d = ChordShape(name: "D", pitches: [57, 62, 66])
    static let gm = ChordShape(name: "Gm", pitches: [55, 58, 62])
    static let g7 = ChordShape(name: "G7", pitches: [55, 59, 62, 65])
    static let csus = ChordShape(name: "Csus4", pitches: [60, 65, 67])

    /// Two chords, half a bar each.
    static func pair(_ a: ChordShape, _ b: ChordShape) -> Pattern { K.halves(a, b) }

    /// Beat plus a chord held for the bar, with its root in the bass.
    static func chordBar(_ ch: ChordShape, root: Int, drums: Bool = true) -> Pattern {
        var p = drums ? beat : Pattern()
        p.chords = [K.ch(0, ch, 14)]
        p.bass = [NoteEvent(0, root, 6), NoteEvent(8, root, 6)]
        return p
    }

    /// The four-chord loop every pop fan knows by feel: C G Am F, one chord per bar.
    static let popLoop: [Pattern] = [chordBar(c, root: 36), chordBar(g, root: 43), chordBar(am, root: 45),
                                     chordBar(f, root: 41)]

    /// Drums with a bassline in C.
    static let bassline = [NoteEvent(0, 36, 2), NoteEvent(3, 36), NoteEvent(6, 43, 2), NoteEvent(10, 45, 2),
                           NoteEvent(14, 43, 2)]
    static let beatBass = Pattern(kick: [0, 8], clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14], bass: bassline)
    static let full: Pattern = {
        var p = beatBass
        p.chords = [K.ch(0, c, 6), K.ch(8, am, 6)]
        return p
    }()

    /// Every lane, for arrangement steps.
    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]
}
