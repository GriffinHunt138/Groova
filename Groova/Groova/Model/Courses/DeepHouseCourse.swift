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
            K.intro("Behind the beat",
                    "Deep house sounds relaxed because the notes between the beats arrive a fraction late. That's swing. Just a little makes a groove feel human and lazy. Too much and it turns into garage.",
                    [.hat, .perc], demo: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [7, 15])),
            K.swingMake("Add a little swing", "Swing delays every second 16th. Deep house keeps it subtle: past 12%.",
                        tracks: [.kick, .hat, .perc], start: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [7, 15]),
                        atLeast: 0.12),
            K.drumCopy("Copy these lazy hats", "Swung 16ths with a few gaps.",
                       tracks: [.kick, .hat], edit: [.hat], start: Pattern(kick: [0, 4, 8, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15])),
            K.quiz("How much swing?", "Deep house keeps it subtle.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [7, 15])], ["Straight", "A lazy lean", "Heavy garage skip"], 0,
                       bars: 2, swing: 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [7, 15])], ["Straight", "A lazy lean", "Heavy garage skip"], 1,
                       "That's deep house.", bars: 2, swing: 0.15),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [7, 15])], ["Straight", "A lazy lean", "Heavy garage skip"], 2,
                       bars: 2, swing: 0.36),
            ]),
        ]),
        K.lesson("deep.u1.l4", "Shuffling Hats", "Open and closed", "sparkles", .rhythm, 20, [
            K.intro("Open and closed",
                    "Closed hats tick. Open hats ring out and take up more room. Deep house puts open hats on the offbeats for lift and tucks closed hats in around them, so the top end shuffles without getting busy.",
                    [.hat, .openHat], demo: Pattern(kick: [0, 4, 8, 12], hat: [1, 5, 9, 13, 15], openHat: [2, 6, 10, 14])),
            K.drumCopy("Copy this hat groove", "Open hats on the offbeats, closed hats tucked around them.",
                       tracks: [.kick, .hat, .openHat], edit: [.hat, .openHat], start: Pattern(kick: [0, 4, 8, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [1, 5, 9, 13, 15], openHat: [2, 6, 10, 14])),
            K.drumMake("Write your own hats", "At least six closed hats.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat, .openHat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 6)),
            K.quiz("Open or closed?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14])], ["Open hats", "Closed hats"], 0, "They ring out.", bars: 2,
                       question: "Which hat is on the offbeat?"),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])], ["Open hats", "Closed hats"], 1, "Short ticks.", bars: 2,
                       question: "Which hat is on the offbeat?"),
            ]),
        ]),
        K.lesson("deep.u1.l5", "Deep Groove", "A warm bassline", "waveform", .theory, 20, [
            K.intro("A warm bassline",
                    "Deep house bass is long and round. It holds notes over the offbeats and drifts between a few notes of F minor instead of bouncing. The piano roll's rows are notes, and you can stretch a note by dragging its edge.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)),
            K.bassRule("Long F on the offbeats", "Rows are notes. F is the fourth row. Steps 4 and 12, two steps long (drag a note to stretch it).",
                       rows: rows, target: [NoteEvent(3, 41, 2), NoteEvent(11, 41, 2)], backing: drums),
            K.bassCopy("Copy this deep bassline", "It starts on F and drifts down.", rows: rows, target: bassline,
                       backing: drums),
            K.quiz("Long or short?", "Which bass is deep house?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)], ["Deep: long and drifting", "Bouncy: short and busy"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: K.notes(41, [2, 3, 6, 7, 10, 11, 14, 15]))],
                       ["Deep: long and drifting", "Bouncy: short and busy"], 1, bars: 2),
            ]),
            K.bassMake("Write your own deep bassline", "At least four notes. Make some of them long, and leave the beats to the kick.",
                       rows: rows, backing: drums, notes: 4),
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
            K.intro("Warm and open",
                    "Deep house chords are jazzy: they stack more notes than a plain chord. A major 7th takes a major chord and adds the note just below the octave. It sounds warm, hopeful and a little dreamy.",
                    [], demo: Pattern(kick: [0, 8], chords: [K.ch(0, .cmaj7, 8), K.ch(8, .dbmaj7, 8)])),
            K.build("Build Cmaj7: C, E, G and B", "A chord is notes played together. A major 7th is a major chord plus the note just below the octave.", .cmaj7),
            K.quiz("Major 7th or minor 7th?", "Major 7ths sound warm. Minor 7ths sound moodier.", [
                K.round([.cmaj7], ["Major 7th", "Minor 7th"], 0),
                K.round([.fm7], ["Major 7th", "Minor 7th"], 1),
                K.round([.dbmaj7], ["Major 7th", "Minor 7th"], 0),
            ]),
            K.lane("Play the warm chords", "Cmaj7 on beat 1, D♭maj7 on beat 3.", .rule, palette: [.cmaj7, .dbmaj7], backing: drums,
                   target: [0: 0, 8: 1], length: 6),
        ]),
        K.lesson("deep.u2.l2", "Minor 9ths", "The deep house chord", "music.quarternote.3", .theory, 25, [
            K.intro("The deep house chord",
                    "The minor 9th is the sound of deep house. Start with a minor 7th, then add one more note on top: the 9th. It softens the darkness of the minor chord and makes it feel rich and open.",
                    [], demo: Pattern(kick: [0, 8], chords: [K.ch(0, .fm7, 8), K.ch(8, .fm9, 8)])),
            K.build("Build Fm7: F, A♭, C and E♭", "A minor 7th is a minor chord plus the note a whole step below the octave. Here it's built on F: F, A♭, C and E♭. The black keys come in now.", .fm7, low: 53, high: 67),
            K.build("Add G to make Fm9", "A ninth adds the note one step above the octave, G. That extra note is the soft, rich deep house colour.", .fm9, start: [53, 56, 60, 63], low: 53, high: 67),
            K.quiz("Seventh or ninth?", "The 9th sounds wider and softer.", [
                K.round([.fm7], ["Minor 7th", "Minor 9th"], 0),
                K.round([.fm9], ["Minor 7th", "Minor 9th"], 1),
                K.ask("Fm7 is F, A♭, C, E♭. Which note turns it into Fm9?", ["G", "B♭", "D♭"], 0, "One step above the octave of F."),
            ]),
            K.lane("Hold the Fm9", "Place Fm9 on beats 1 and 3 and let it ring.", .rule, palette: [.fm9], backing: drums,
                   target: [0: 0, 8: 0], length: 6),
        ]),
        K.lesson("deep.u2.l3", "Chord Colours", "Ear training", "paintpalette.fill", .theory, 25, [
            K.intro("Chord colours",
                    "Producers talk about chords as colours. Major 7ths are warm. Minor 7ths are moody. Minor 9ths are rich and open. Learning to hear the colour is how you pick chords by feel instead of by theory.",
                    [], demo: Pattern(kick: [0, 8], chords: [K.ch(0, .dbmaj7, 5), K.ch(5, .cm7, 5), K.ch(10, .fm9, 6)])),
            K.quiz("Which colour is it?", "Listen for warm (major 7th), moody (minor 7th) or rich (minor 9th).", [
                K.round([.fm9], ["Major 7th", "Minor 7th", "Minor 9th"], 2),
                K.round([.ebmaj7], ["Major 7th", "Minor 7th", "Minor 9th"], 0),
                K.round([.gm7], ["Major 7th", "Minor 7th", "Minor 9th"], 1),
            ]),
            K.lane("Pick the colour", "Two chords: rich first, then warm. Choose the right one for each.", .recreate,
                   palette: [.fm9, .cm7, .dbmaj7], backing: drums, target: [0: 0, 8: 2], length: 6),
        ]),
        K.lesson("deep.u2.l4", "Long Chords", "Let them breathe", "timer", .rhythm, 25, [
            K.intro("Let them breathe",
                    "In deep house, how long a chord rings matters as much as which chord it is. Long chords float over the groove. Chords that start a little late, off the beat, feel lazy and soulful.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], chords: [K.ch(2, .fm9, 6), K.ch(10, .fm9, 6)])),
            K.lane("Hold Fm9 on beats 1 and 3", "Steps 1 and 9. Each chord rings for six steps.", .rule,
                   palette: [.fm9], backing: drums, target: [0: 0, 8: 0], length: 6),
            K.lane("Copy this chord rhythm", "Long chords, placed late.", .recreate, palette: [.fm9], backing: drums,
                   target: [2: 0, 10: 0, 13: 0], length: 3),
            K.quiz("Float or bounce?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], chords: [K.ch(0, .fm9, 6), K.ch(8, .fm9, 6)])],
                       ["Floating", "Bouncing"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], chords: [K.ch(2, .fm9), K.ch(6, .fm9), K.ch(10, .fm9), K.ch(14, .fm9)])],
                       ["Floating", "Bouncing"], 1, bars: 2),
            ]),
            K.lane("Write your own chord rhythm", "At least three Fm9 chords. Try starting some of them late.", .create(.chordsAtLeast(3)),
                   palette: [.fm9], backing: drums, length: 4),
        ]),
        K.lesson("deep.u2.l5", "Deep Progression", "Fm9 to D♭maj7", "arrow.left.arrow.right", .theory, 25, [
            K.intro("Fm9 to D♭maj7",
                    "The classic deep house move goes from a rich minor 9th to a warm major 7th and back. Dark, then hopeful, then dark again. Loop it for eight minutes and it never gets old.",
                    [], demo: full),
            K.lane("Switch to D♭maj7 in the second half", "Change the chord on step 9.", .rule,
                   palette: [.fm9, .dbmaj7], backing: drums, start: [0: 0, 8: 0], target: [0: 0, 8: 1], length: 6),
            K.lane("Copy this progression", "Three chords this time.", .recreate, palette: [.fm9, .dbmaj7, .ebmaj7],
                   backing: drums, target: [0: 0, 6: 1, 12: 2], length: 4),
            K.quiz("Which way did it go?", "Both start on Fm9.", [
                K.round([.fm9, .dbmaj7], ["D♭maj7 (warm)", "E♭maj7 (bright)"], 0, question: "Which chord comes second?"),
                K.round([.fm9, .ebmaj7], ["D♭maj7 (warm)", "E♭maj7 (bright)"], 1, question: "Which chord comes second?"),
            ]),
            K.lane("Write your own progression", "At least three chords. Start on Fm9.", .create(.chordsAtLeast(3)),
                   palette: [.fm9, .dbmaj7, .ebmaj7], backing: drums, length: 4),
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
            K.intro("Slow in, slow out",
                    "A pad is a chord that fades in and lingers, like a glow behind the beat. Attack sets how slowly it arrives. Release sets how long it hangs after the chord ends.",
                    [], demo: padLoop),
            K.lab("Explore the pad", "Attack fades the chord in. Release lets it linger.",
                  [.chordAttack, .chordRelease], start: [0.1, 0.27], loop: padLoop),
            K.lab("Match the warm pad", "Slow and soft.", [.chordAttack, .chordRelease], start: [0.0, 0.1],
                  target: [0.75, 0.8], loop: padLoop),
            K.quiz("Pad or pluck?", "", [
                K.sound(padLoop, [.chordAttack: 0.75, .chordRelease: 0.8], ["Pad", "Pluck"], 0),
                K.sound(padLoop, [.chordAttack: 0, .chordRelease: 0.1], ["Pad", "Pluck"], 1),
            ]),
        ]),
        K.lesson("deep.u3.l2", "Round Bass", "Sine-like and soft", "waveform", .soundDesign, 30, [
            K.intro("Round, not sharp",
                    "Deep house bass is felt more than heard. Close the filter and turn the envelope down and it turns into a soft, round hum. Open it up and add envelope and it gets a little bite.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)),
            K.lab("Match the round bass", "Dark and smooth, no bite.", [.bassCutoff, .bassEnv], start: [0.7, 0.7],
                  target: [0.2, 0.05], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)),
            K.lab("Match the plucky bass", "A little brighter, short bite at the start.", [.bassCutoff, .bassEnv],
                  start: [0.1, 0.0], target: [0.45, 0.5], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)),
            K.quiz("Round or bitey?", "", [
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline), [.bassCutoff: 0.2, .bassEnv: 0.05],
                        ["Round", "Bitey"], 0),
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline), [.bassCutoff: 0.45, .bassEnv: 0.6],
                        ["Round", "Bitey"], 1),
                K.ask("Which suits a late-night deep house track?", ["Round", "Bitey"], 0, "Deep bass sits under the chords, not on top of them."),
            ]),
        ]),
        K.lesson("deep.u3.l3", "Dark Filter", "Muffled warmth", "dial.medium.fill", .soundDesign, 30, [
            K.intro("Muffled warmth",
                    "A low-pass filter cuts the highs and leaves the lows. Deep house runs a lot of its sounds slightly filtered, which is why it sounds warm and far away instead of bright and in your face.",
                    [], demo: full),
            K.filterSweep("Sweep the filter", "A low-pass filter cuts the highs. Close it right down, then open it all the way.", full),
            K.filterMatch("Match the dark sound", "Low cutoff, a touch of resonance.", cutoff: 700, resonance: 0.3, full),
            K.quiz("Open or closed?", "", [
                K.filtered(full, cutoff: 600, ["Closed: warm and muffled", "Open: bright and clear"], 0),
                K.filtered(full, cutoff: 15000, ["Closed: warm and muffled", "Open: bright and clear"], 1),
            ]),
        ]),
        K.lesson("deep.u3.l4", "Big Room Reverb", "Space for chords", "building.columns.fill", .soundDesign, 30, [
            K.intro("Space for chords",
                    "Reverb puts a sound in a room. Deep house loves big, soft spaces on its chords, so they feel like they're coming from somewhere far away. Keep the kick and bass dry so the groove stays tight.",
                    [], demo: padLoop),
            K.space("Give the chords a room", "Deep house loves big, soft spaces. Find one you like.", padLoop),
            K.lab("Match the pad brightness", "Darker chords sit further back.", [.chordCutoff], start: [0.8],
                  target: [0.3], loop: padLoop),
            K.quiz("Dry or roomy?", "", [
                K.reverb(padLoop, amount: 0.05, ["Dry", "Big room"], 0),
                K.reverb(padLoop, amount: 0.65, ["Dry", "Big room"], 1),
                K.ask("Which part should stay dry so the groove stays tight?", ["The kick and bass", "The pads"], 0,
                      "Reverb on low sounds turns them into mud."),
            ]),
        ]),
        K.lesson("deep.u3.l5", "Dubby Space", "Stabs that echo", "water.waves", .soundDesign, 30, [
            K.intro("Stabs that echo",
                    "Dub techno and dub house use short chord stabs with lots of space after them, then fill that space with echo and reverb. The gaps are the point: they're where the echo lives.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], chords: [K.ch(3, .fm9, 1), K.ch(10, .fm9, 1)])),
            K.space("Make the stabs dubby", "Short stabs with a long space after them.",
                    Pattern(kick: [0, 4, 8, 12], chords: [K.ch(3, .fm9, 1), K.ch(10, .fm9, 1)])),
            K.lane("Write your own stabs", "At least three. Leave space for the echo.", .create(.chordsAtLeast(3)),
                   palette: [.fm9, .dbmaj7], backing: drums),
            K.quiz("Quick check", "", [
                K.ask("Where does the echo of a dub stab live?", ["In the gap after it", "On top of the next stab", "Under the kick"], 0),
            ]),
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
            K.intro("Start and end gently",
                    "Deep house tracks ease in and ease out. The intro and outro are mostly drums, so a DJ can blend them with the next record, and the chords feel like an arrival when they come in.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.arrange("Drums only in the outro", "Columns are sections, rows are parts. In the Outro, switch off the bass and chords.", .rule,
                      sections: sections, lanes: lanes, loop: full,
                      start: K.grid("xxxx", "-xxx", "xxxx", "-xxx", "xxxx"),
                      target: K.grid("xxxx", "-xxx", "xxxx", "-xx-", "xxx-")),
            K.quiz("Intro or groove?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])], ["Intro", "Groove"], 0, "Drums only, easy to mix.", bars: 2),
                K.hear([full], ["Intro", "Groove"], 1, bars: 2),
            ]),
            K.arrange("Copy this track", "The chords wait until the Groove. Kick and hats play throughout.", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("xxxx", "-x--", "xxxx", "-xx-", "-xx-")),
        ]),
        K.lesson("deep.u4.l4", "The Deep Break", "Chords alone", "pause.circle.fill", .arrangement, 35, [
            K.intro("Chords alone",
                    "The deep house break pulls the drums away and leaves something to float: usually the chords, sometimes just the bass. It's the moment the track gets emotional before the groove returns.",
                    [], demo: Pattern(chords: padChords)),
            K.arrange("Copy this break", "Only one part keeps playing in the break.", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("xx-x", "-x-x", "xx-x", "-x--", "xxxx")),
            K.quiz("What stayed?", "Bar 2 is the break.", [
                K.hear([full, Pattern(chords: padChords)], ["The chords", "The bass", "The hats"], 0, question: "What's left in bar 2?"),
                K.hear([full, Pattern(bass: bassline)], ["The chords", "The bass", "The hats"], 1, question: "What's left in bar 2?"),
            ]),
            K.arrange("Chords alone in the Break", "Switch everything except the chords off in the Break.", .rule,
                      sections: sections, lanes: lanes, loop: full,
                      start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"), target: K.grid("xx-x", "xx-x", "xx-x", "xx-x", "xxxx")),
        ]),
        K.lesson("deep.u4.l5", "Late Night Arrangement", "Your track", "moon.stars.fill", .arrangement, 35, [
            K.intro("A slow build",
                    "Deep tracks don't jump from quiet to loud. They add one part per section and take one away, so the energy rises and falls like a tide. Long sections, small changes.",
                    [], demo: full),
            K.quiz("Quick check", "", [
                K.ask("How do deep tracks build energy?", ["One part per section", "Everything at once", "By getting faster"], 0),
            ]),
            K.arrange("Copy this slow build", "One part arrives in each section, then the Outro takes two away.", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("xxxx", "--x-", "xxxx", "-xxx", "--x-")),
            K.arrange("Arrange your own deep track", "Every section different from the last. Change one or two parts at a time.", .create(.variedSections),
                      sections: sections, lanes: lanes, loop: full),
        ]),
        K.mastery("deep.u4.mastery", "Arrangement Mastery", "Recreate a deep house arrangement", .arrangement, 90, [
            K.arrange("Recreate this deep house track", "Listen to all four sections.", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("-x-x", "-x--", "xxxx", "-x-x", "xxx-")),
        ]),
    ])
}
