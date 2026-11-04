//
//  DeepHouseCourse.swift
//  Groova
//
//  Deep House: soft grooves, jazzy chords, warm sounds, voice leading and late-night arrangement.
//

import Foundation

nonisolated enum DeepHouseCourse {
    /// F minor pentatonic, C3 down to C2.
    static let rows = [48, 46, 44, 41, 39, 36]

    static let drums = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [7, 15])
    static let bassline = [NoteEvent(3, 41, 2), NoteEvent(7, 44), NoteEvent(11, 39, 2), NoteEvent(14, 36)]
    static let padChords = [K.ch(0, .fm9, 6), K.ch(8, .dbmaj7, 6)]
    static let full = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [7, 15],
                              bass: bassline, chords: padChords)
    static let padLoop = Pattern(kick: [0, 8], hat: [2, 6, 10, 14], chords: padChords)
    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]
    static let sections = ["Intro", "Groove", "Break", "Outro"]

    // MARK: Academy (Part 2)

    private static func pick(_ ids: String...) -> [Lesson] { Curriculum.lessons(ids, from: units) }
    private static let style = AcademyKit.deep

    static let academy: [Unit] = [
        K.unit("deep.a1", 1, "Deep House Foundations", "Soul, jazz & the late-night feel",
               [AcademyKit.whatMakes(style), AcademyKit.anatomy(style)] + pick("deep.u1.l3") + [AcademyKit.foundationsCheck(style)]),
        K.unit("deep.a2", 2, "Drums & Groove", "Soft kicks, rims & shuffling hats",
               pick("deep.u1.l1", "deep.u1.l2", "deep.u1.l4", "deep.u1.mastery")),
        K.unit("deep.a3", 3, "Bass & Low End", "Round, warm and dark",
               pick("deep.u1.l5", "deep.u3.l2", "deep.u3.l3") + [lowEndMastery]),
        K.unit("deep.a4", 4, "Jazzy Chords", "Sevenths, ninths & colour",
               pick("deep.u2.l1", "deep.u2.l2", "deep.u2.l3", "deep.u2.l4", "deep.u2.l5", "deep.u2.mastery")),
        K.unit("deep.a5", 5, "Voice Leading", "Chords that glide",
               pick("deep.vl.l1", "deep.vl.l2", "deep.vl.l3", "deep.vl.l4", "deep.vl.mastery")),
        K.unit("deep.a6", 6, "Vocals & Atmosphere", "Breathy chops, pads & space",
               [AcademyKit.chopIntro(style), AcademyKit.chopHook(style)].compactMap { $0 }
                   + pick("deep.u3.l1", "deep.u3.l4", "deep.u3.l5", "deep.u3.mastery")),
        K.unit("deep.a7", 7, "Arrangement", "Intros, breaks & outros",
               pick("deep.u4.l3", "deep.u4.l4", "deep.u4.l5") + [AcademyKit.loopToTrack(style)] + pick("deep.u4.mastery")),
        K.unit("deep.a8", 8, "Mixing & Final Project", "Warm, wide, finished",
               [AcademyKit.mixBalance(style), AcademyKit.mixPump(style), AcademyKit.mixSpace(style), AcademyKit.finalProject(style)]),
    ]

    static let lowEndMastery = K.mastery("deep.a3.mastery", "Low End Mastery", "Recreate a deep groove and bassline", .theory, 70, [
        K.groove("Recreate this deep house groove", reference: full.keeping([.kick, .clap, .hat, .perc], bass: true, chords: false),
                 tracks: [.kick, .clap, .hat, .perc], rows: rows),
    ])

    static let units: [Unit] = [unit1, unit2, unit3, voiceUnit, unit4]

    // MARK: Unit 1 — Late Night Grooves

    static let unit1 = K.unit("deep.u1", 1, "Late Night Grooves", "Soft kicks, rims & lazy swing", [
        K.lesson("deep.u1.l1", "Soft Kick", "Round, not punchy", "moon.fill", .soundDesign, 20, [
            K.intro("Meet the deep kick", "Softer and rounder than a house kick. Tap it.", [.kick, .perc]),
            K.drumRule("Four on the floor, softly", "Kicks on steps 1, 5, 9 and 13.",
                       tracks: [.kick, .hat], edit: [.kick], start: Pattern(hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.lab("Match the soft kick", "Low pitch, no drive.", [.kickPitch, .kickDrive], start: [0.6, 0.7],
                  target: [0.12, 0.0], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
        ]),
        K.lesson("deep.u1.l2", "Rimshots", "The deep house snare", "triangle.fill", .rhythm, 20, [
            K.intro("Meet the rimshot",
                    "A rimshot is a stick hitting the edge of a drum: short, woody and clicky. Deep house uses it instead of a loud snare. Tap it.",
                    [.perc], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [7, 15])),
            K.drumRule("Rims on steps 8 and 16", "Just before beats 3 and 1. They nudge the groove forward.",
                       tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [7, 15])),
            K.drumCopy("Copy this rim pattern", "Four rims, all between the beats.",
                       tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 7, 10, 15])),
        ]),
        K.lesson("deep.u1.l3", "Lazy Swing", "Behind the beat", "tortoise.fill", .rhythm, 20, [
            K.swingMake("Add a little swing", "Swing delays every second 16th. Deep house keeps it subtle: past 12%.",
                        tracks: [.kick, .hat, .perc], start: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [7, 15]),
                        atLeast: 0.12),
            K.drumCopy("Copy these lazy hats", "Swung 16ths with a few gaps.",
                       tracks: [.kick, .hat], edit: [.hat], start: Pattern(kick: [0, 4, 8, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15])),
        ]),
        K.lesson("deep.u1.l4", "Shuffling Hats", "Open and closed", "sparkles", .rhythm, 20, [
            K.drumCopy("Copy this hat groove", "Open hats on the offbeats, closed hats tucked around them.",
                       tracks: [.kick, .hat, .openHat], edit: [.hat, .openHat], start: Pattern(kick: [0, 4, 8, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [1, 5, 9, 13, 15], openHat: [2, 6, 10, 14])),
            K.drumMake("Write your own hats", "At least six closed hats.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat, .openHat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 6)),
        ]),
        K.lesson("deep.u1.l5", "Deep Groove", "A warm bassline", "waveform", .theory, 20, [
            K.bassRule("Long F on the offbeats", "Rows are notes. F is the fourth row. Steps 4 and 12, two steps long (drag a note to stretch it).",
                       rows: rows, target: [NoteEvent(3, 41, 2), NoteEvent(11, 41, 2)], backing: drums),
            K.bassCopy("Copy this deep bassline", "It starts on F and drifts down.", rows: rows, target: bassline,
                       backing: drums),
        ]),
        K.mastery("deep.u1.mastery", "Groove Mastery", "Recreate a deep groove", .rhythm, 60, [
            K.groove("Recreate this deep house groove",
                     reference: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 7, 15], bass: bassline),
                     tracks: [.kick, .clap, .perc], rows: rows),
        ]),
    ])

    // MARK: Unit 2 — Jazzy Chords

    static let unit2 = K.unit("deep.u2", 2, "Jazzy Chords", "Sevenths, ninths & colour", [
        K.lesson("deep.u2.l1", "Major 7ths", "Warm and open", "pianokeys", .theory, 25, [
            K.build("Build Cmaj7: C, E, G and B", "A chord is notes played together. A major 7th is a major chord plus the note just below the octave.", .cmaj7),
            K.quiz("Major 7th or minor 7th?", "Major 7ths sound warm. Minor 7ths sound moodier.", [
                K.round([.cmaj7], ["Major 7th", "Minor 7th"], 0),
                K.round([.fm7], ["Major 7th", "Minor 7th"], 1),
                K.round([.dbmaj7], ["Major 7th", "Minor 7th"], 0),
            ]),
        ]),
        K.lesson("deep.u2.l2", "Minor 9ths", "The deep house chord", "music.quarternote.3", .theory, 25, [
            K.build("Build Fm7: F, A♭, C and E♭", "A minor 7th is a minor chord plus the note a whole step below the octave. Here it's built on F: F, A♭, C and E♭. The black keys come in now.", .fm7, low: 53, high: 67),
            K.build("Add G to make Fm9", "A ninth adds the note one step above the octave, G. That extra note is the soft, rich deep house colour.", .fm9, start: [53, 56, 60, 63], low: 53, high: 67),
        ]),
        K.lesson("deep.u2.l3", "Chord Colours", "Ear training", "paintpalette.fill", .theory, 25, [
            K.quiz("Which colour is it?", "Listen for warm (major 7th), moody (minor 7th) or rich (minor 9th).", [
                K.round([.fm9], ["Major 7th", "Minor 7th", "Minor 9th"], 2),
                K.round([.ebmaj7], ["Major 7th", "Minor 7th", "Minor 9th"], 0),
                K.round([.gm7], ["Major 7th", "Minor 7th", "Minor 9th"], 1),
            ]),
        ]),
        K.lesson("deep.u2.l4", "Long Chords", "Let them breathe", "timer", .rhythm, 25, [
            K.lane("Hold Fm9 on beats 1 and 3", "Steps 1 and 9. Each chord rings for six steps.", .rule,
                   palette: [.fm9], backing: drums, target: [0: 0, 8: 0], length: 6),
            K.lane("Copy this chord rhythm", "Long chords, placed late.", .recreate, palette: [.fm9], backing: drums,
                   target: [2: 0, 10: 0, 13: 0], length: 3),
        ]),
        K.lesson("deep.u2.l5", "Deep Progression", "Fm9 to D♭maj7", "arrow.left.arrow.right", .theory, 25, [
            K.lane("Switch to D♭maj7 in the second half", "Change the chord on step 9.", .rule,
                   palette: [.fm9, .dbmaj7], backing: drums, start: [0: 0, 8: 0], target: [0: 0, 8: 1], length: 6),
            K.lane("Copy this progression", "Three chords this time.", .recreate, palette: [.fm9, .dbmaj7, .ebmaj7],
                   backing: drums, target: [0: 0, 6: 1, 12: 2], length: 4),
        ]),
        K.mastery("deep.u2.mastery", "Chord Mastery", "Recreate a deep progression", .theory, 70, [
            K.lane("Recreate this late-night progression", "Four chords. Listen for the bright one.", .recreate,
                   palette: [.fm9, .dbmaj7, .bbm7, .cm7], backing: drums,
                   target: [0: 0, 4: 2, 8: 1, 12: 3], length: 4),
        ]),
    ])

    // MARK: Unit 3 — Warm Sounds

    static let unit3 = K.unit("deep.u3", 3, "Warm Sounds", "Pads, round bass & space", [
        K.lesson("deep.u3.l1", "Warm Pad", "Slow in, slow out", "cloud.fill", .soundDesign, 30, [
            K.lab("Explore the pad", "Attack fades the chord in. Release lets it linger.",
                  [.chordAttack, .chordRelease], start: [0.1, 0.27], loop: padLoop),
            K.lab("Match the warm pad", "Slow and soft.", [.chordAttack, .chordRelease], start: [0.0, 0.1],
                  target: [0.75, 0.8], loop: padLoop),
        ]),
        K.lesson("deep.u3.l2", "Round Bass", "Sine-like and soft", "waveform", .soundDesign, 30, [
            K.lab("Match the round bass", "Dark and smooth, no bite.", [.bassCutoff, .bassEnv], start: [0.7, 0.7],
                  target: [0.2, 0.05], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)),
            K.lab("Match the plucky bass", "A little brighter, short bite at the start.", [.bassCutoff, .bassEnv],
                  start: [0.1, 0.0], target: [0.45, 0.5], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)),
        ]),
        K.lesson("deep.u3.l3", "Dark Filter", "Muffled warmth", "dial.medium.fill", .soundDesign, 30, [
            K.filterSweep("Sweep the filter", "A low-pass filter cuts the highs. Close it right down, then open it all the way.", full),
            K.filterMatch("Match the dark sound", "Low cutoff, a touch of resonance.", cutoff: 700, resonance: 0.3, full),
        ]),
        K.lesson("deep.u3.l4", "Big Room Reverb", "Space for chords", "building.columns.fill", .soundDesign, 30, [
            K.space("Give the chords a room", "Deep house loves big, soft spaces. Find one you like.", padLoop),
            K.lab("Match the pad brightness", "Darker chords sit further back.", [.chordCutoff], start: [0.8],
                  target: [0.3], loop: padLoop),
        ]),
        K.lesson("deep.u3.l5", "Dubby Space", "Stabs that echo", "water.waves", .soundDesign, 30, [
            K.space("Make the stabs dubby", "Short stabs with a long space after them.",
                    Pattern(kick: [0, 4, 8, 12], chords: [K.ch(3, .fm9, 1), K.ch(10, .fm9, 1)])),
            K.lane("Write your own stabs", "At least three. Leave space for the echo.", .create(.chordsAtLeast(3)),
                   palette: [.fm9, .dbmaj7], backing: drums),
        ]),
        K.mastery("deep.u3.mastery", "Sound Mastery", "Match three warm sounds", .soundDesign, 80, [
            K.lab("Match this kick", "Soft and deep.", [.kickPitch, .kickDecay], start: [0.7, 0.1], target: [0.15, 0.45],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.lab("Match this bass", "Listen for the bite.", [.bassCutoff, .bassEnv, .bassDecay], start: [0.7, 0.0, 0.1],
                  target: [0.3, 0.35, 0.6], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)),
            K.lab("Match this pad", "How it fades in, how it fades out, how bright it is.",
                  [.chordAttack, .chordRelease, .chordCutoff], start: [0.0, 0.0, 0.9], target: [0.55, 0.7, 0.3],
                  loop: padLoop),
        ]),
    ])

    // MARK: Unit 5 — Late Night Arrangement

    static let unit4 = K.unit("deep.u4", 5, "Late Night Arrangement", "Intros, breaks & outros", [
        K.lesson("deep.u4.l3", "Intro & Outro", "Start and end gently", "arrow.left.and.right", .arrangement, 35, [
            K.arrange("Drums only in the outro", "Columns are sections, rows are parts. In the Outro, switch off the bass and chords.", .rule,
                      sections: sections, lanes: lanes, loop: full,
                      start: K.grid("xxxx", "-xxx", "xxxx", "-xxx", "xxxx"),
                      target: K.grid("xxxx", "-xxx", "xxxx", "-xx-", "xxx-")),
        ]),
        K.lesson("deep.u4.l4", "The Deep Break", "Chords alone", "pause.circle.fill", .arrangement, 35, [
            K.arrange("Copy this break", "Only one part keeps playing in the break.", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("xx-x", "-x-x", "xx-x", "-x--", "xxxx")),
        ]),
        K.lesson("deep.u4.l5", "Late Night Arrangement", "Your track", "moon.stars.fill", .arrangement, 35, [
            K.arrange("Arrange your own deep track", "Every section different from the last.", .create(.variedSections),
                      sections: sections, lanes: lanes, loop: full),
        ]),
        K.mastery("deep.u4.mastery", "Arrangement Mastery", "Recreate a deep house arrangement", .arrangement, 90, [
            K.arrange("Recreate this deep house track", "Listen to all four sections.", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("-x-x", "-x--", "xxxx", "-x-x", "xxx-")),
        ]),
    ])
}
