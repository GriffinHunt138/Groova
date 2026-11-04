//
//  GarageCourse.swift
//  Groova
//
//  UK Garage: two-step drums, bouncy bass, swung ninth chords, mixing and arrangement.
//  Playback uses the genre's heavy swing, so every groove here shuffles.
//

import Foundation

nonisolated enum GarageCourse {
    /// E minor pentatonic, B2 down to B1.
    static let rows = [47, 45, 43, 40, 38, 35]

    static let twoStep = Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14])
    static let skippy = Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15], perc: [9])
    static let bassline = [NoteEvent(0, 40, 2), NoteEvent(3, 40), NoteEvent(6, 43), NoteEvent(10, 38, 2),
                           NoteEvent(14, 35)]
    static let full = Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15], perc: [9],
                              bass: bassline, chords: [K.ch(3, .em9, 2), K.ch(11, .am9, 2)])

    static let units: [Unit] = [unit1, unit2, unit3, unit4]

    // MARK: Unit 1 — The Two-Step

    static let unit1 = K.unit("ukg.u1", 1, "The Two-Step", "Swing, skip and shuffle", [
        K.lesson("ukg.u1.l1", "Two-Step Shuffle", "Swing and broken kicks", "figure.dance", .rhythm, 25, [
            K.swingMake("Add swing until it shuffles",
                        "Swing delays every second 16th. Watch the cells shift — push past 25%.",
                        tracks: [.clap, .hat], start: Pattern(clap: [4, 12], hat: Array(0..<16)), atLeast: 0.25),
            K.drumRule("Two-step kick: hit step 1 and step 11",
                       "Garage skips the steady four. One kick on the downbeat, then a late push on step 11.",
                       tracks: [.kick, .clap, .hat], edit: [.kick],
                       start: Pattern(clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15]),
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.drumCopy("Recreate this garage groove", "Three kicks around the claps, plus two rims near the end. Listen for the late kicks.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .hat, .perc], start: Pattern(clap: [4, 12]),
                       target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 6, 10, 11, 14], perc: [9, 15])),
        ]),
        K.lesson("ukg.u1.l2", "Skippy Hats", "Pairs of 16ths", "sparkles", .rhythm, 25, [
            K.drumRule("Hats in pairs after every beat", "Steps 3–4, 7–8, 11–12 and 15–16.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 10], clap: [4, 12]),
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.drumCopy("Copy these skippy hats", "Some pairs, some singles.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 10], clap: [4, 12]),
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14])),
        ]),
        K.lesson("ukg.u1.l3", "Rim Ghost Notes", "Quiet extra hits", "triangle.fill", .rhythm, 25, [
            K.drumRule("Ghost rims after the claps", "A ghost note is a quiet extra hit that fills a gap. Put rims on steps 6 and 14, just after each clap.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: twoStep,
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [5, 13])),
            K.drumCopy("Copy this rim pattern", "Three rims, all in the gaps.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: twoStep,
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 9, 15])),
        ]),
        K.lesson("ukg.u1.l4", "Late Kicks", "Push and pull", "arrow.uturn.right", .rhythm, 25, [
            K.drumCopy("Copy these kicks", "One on the downbeat, two late ones.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 10, 14])),
            K.drumCopy("Copy another variation", "The second kick moves.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 7, 11], clap: [4, 12], hat: [2, 6, 10, 14])),
        ]),
        K.lesson("ukg.u1.l5", "Your Own Two-Step", "Write the kicks", "pencil", .rhythm, 25, [
            K.drumMake("Write your own two-step kicks", "At least two kicks. Avoid the steady four.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .perc],
                       start: Pattern(clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15]), goal: .atLeast(.kick, 2)),
        ]),
        K.mastery("ukg.u1.mastery", "Two-Step Mastery", "Recreate a two-step groove", .rhythm, 60, [
            K.groove("Recreate this two-step groove",
                     reference: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14],
                                        bass: [NoteEvent(0, 40, 2), NoteEvent(6, 43), NoteEvent(10, 38, 2)]),
                     tracks: [.kick, .clap, .hat], rows: rows),
        ]),
    ])

    // MARK: Unit 2 — Bouncy Bass

    static let unit2 = K.unit("ukg.u2", 2, "Bouncy Bass", "Sub, skip & octaves", [
        K.lesson("ukg.u2.l1", "Sub Bass Tone", "Round and warm", "waveform", .soundDesign, 30, [
            K.lab("Explore the garage bass", "Cutoff for brightness, length for how long each note holds.",
                  [.bassCutoff, .bassDecay], start: [0.48, 0.42], loop: Pattern(kick: [0, 10], clap: [4, 12], bass: bassline)),
            K.lab("Match the deep sub", "Dark and long.",
                  [.bassCutoff, .bassDecay], start: [0.7, 0.1], target: [0.15, 0.75],
                  loop: Pattern(kick: [0, 10], clap: [4, 12], bass: bassline)),
        ]),
        K.lesson("ukg.u2.l2", "Skipping Bass", "Off the kick", "figure.run", .theory, 30, [
            K.bassRule("Bass on step 1 and step 8", "Rows are notes. E is the fourth row down.",
                       rows: rows, target: [NoteEvent(0, 40), NoteEvent(7, 40)], backing: twoStep),
            K.bassCopy("Copy this skipping bass", "It answers the kicks.",
                       rows: rows, target: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(7, 43), NoteEvent(11, 38)],
                       backing: twoStep),
        ]),
        K.lesson("ukg.u2.l3", "Long and Short", "Note lengths", "ruler", .theory, 30, [
            K.bassCopy("Copy this bassline", "Two long notes and three short ones. Drag notes to make them longer.",
                       rows: rows, target: bassline, backing: twoStep),
        ]),
        K.lesson("ukg.u2.l4", "Octave Jumps", "Low B, high B", "arrow.up.arrow.down", .theory, 30, [
            K.bassRule("Jump between the two Bs", "An octave is the same note, higher up. Low B (bottom row) on steps 1 and 9, high B (top row) on steps 4 and 12.",
                       rows: rows, target: [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(8, 35), NoteEvent(11, 47)],
                       backing: twoStep),
            K.bassCopy("Copy this octave line", "Jumps up and down, then an E to finish.",
                       rows: rows,
                       target: [NoteEvent(0, 35), NoteEvent(2, 47), NoteEvent(6, 35), NoteEvent(7, 47), NoteEvent(10, 40, 2)],
                       backing: twoStep),
        ]),
        K.lesson("ukg.u2.l5", "Write a Garage Bassline", "Your turn", "pencil", .theory, 30, [
            K.bassMake("Write your own bassline", "At least five notes. Mix long and short.", rows: rows,
                       backing: skippy, notes: 5),
        ]),
        K.mastery("ukg.u2.mastery", "Bass Mastery", "Recreate a garage bassline groove", .theory, 70, [
            K.groove("Recreate this garage groove",
                     reference: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15],
                                        bass: [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(6, 40, 2),
                                               NoteEvent(10, 38), NoteEvent(13, 43)]),
                     tracks: [.kick, .clap, .hat], rows: rows),
        ]),
    ])

    // MARK: Unit 3 — Garage Chords

    static let unit3 = K.unit("ukg.u3", 3, "Garage Chords", "Ninths & swung stabs", [
        K.lesson("ukg.u3.l1", "Ninths", "Five-note chords", "pianokeys", .theory, 30, [
            K.build("Build Am9: A, C, E, G and B", "A chord is notes played together, named after its root, the note it's built on. Am7 (A, C, E, G) is already there. A ninth adds B, one step above the octave. That's the garage sound.",
                    .am9, start: [57, 60, 64, 67], low: 55, high: 71),
            K.build("Build Em9: E, G, B, D and F♯", "Same recipe, starting on E.", .em9, low: 55, high: 71),
        ]),
        K.lesson("ukg.u3.l2", "Swung Stabs", "Chords that skip", "bolt.horizontal.fill", .rhythm, 30, [
            K.lane("Stab Em9 after every clap", "A stab is a short, punchy chord hit. Put one on steps 6 and 14, just after each clap.", .rule, palette: [.em9], backing: twoStep,
                   target: [5: 0, 13: 0]),
            K.lane("Copy this swung stab rhythm", "Four stabs, all off the beat.", .recreate, palette: [.em9],
                   backing: twoStep, target: [3: 0, 5: 0, 11: 0, 13: 0]),
        ]),
        K.lesson("ukg.u3.l3", "Two-Chord Loop", "Em9 to Am9", "arrow.left.arrow.right", .theory, 30, [
            K.lane("Switch to Am9 for the second half", "Change the stabs on steps 12 and 14 to Am9.", .rule,
                   palette: [.em9, .am9], backing: twoStep,
                   start: [3: 0, 5: 0, 11: 0, 13: 0], target: [3: 0, 5: 0, 11: 1, 13: 1]),
        ]),
        K.lesson("ukg.u3.l4", "Hear the Change", "Ear training", "ear.fill", .theory, 30, [
            K.quiz("Which chord comes second?", "Both start on Em9. Cmaj9 sounds brighter, Dm9 darker.", [
                K.round([.em9, .am9], ["Am9", "Cmaj9"], 0),
                K.round([.em9, .cmaj9], ["Am9", "Cmaj9"], 1, "Cmaj9 sounds brighter."),
                K.round([.em9, .dm9], ["Dm9", "Am9"], 0),
            ]),
        ]),
        K.lesson("ukg.u3.l5", "Chords Meet Bass", "Roots under ninths", "point.topleft.down.to.point.bottomright.curvepath.fill",
                 .theory, 30, [
            K.intro("Meet the root",
                    "Every chord is built up from one note, its root, and it's named after it. Em9 is built on E, Am9 on A. The bass plays the root under each chord so the two lock together. Play the loop to hear it.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                      bass: [NoteEvent(3, 40, 4), NoteEvent(11, 45, 4)],
                                      chords: [K.ch(3, .em9, 6), K.ch(11, .am9, 5)])),
            K.bassRule("Play the roots", "The strip above the grid shows each chord. E (fourth row) under Em9 on step 4, A (second row) under Am9 on step 12. Make each note four steps long.",
                       rows: rows, target: [NoteEvent(3, 40, 4), NoteEvent(11, 45, 4)],
                       backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                        chords: [K.ch(3, .em9, 6), K.ch(11, .am9, 5)])),
        ]),
        K.mastery("ukg.u3.mastery", "Chord Mastery", "Recreate a swung chord riff", .theory, 80, [
            K.lane("Recreate this garage chord riff", "Three chords. The last stab comes early.", .recreate,
                   palette: [.em9, .am9, .cmaj9], backing: skippy,
                   target: [0: 0, 3: 0, 6: 1, 11: 2, 13: 1]),
        ]),
    ])

    // MARK: Unit 4 — Mix & Arrange

    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]

    static let unit4 = K.unit("ukg.u4", 4, "Mix & Arrange", "Levels, pump & the drop", [
        K.lesson("ukg.u4.l1", "Garage Levels", "Bass up front", "slider.vertical.3", .mixing, 35, [
            K.mix("Match: bass up front", "In garage the bass and the vocal lead. Here, bass is the star.",
                  [.drum(.kick), .drum(.hat), .bass], start: [K.u, K.u, 0.3], target: [0.6, 0.5, 0.9], loop: full),
        ]),
        K.lesson("ukg.u4.l2", "Pump the Bass", "Sidechain bounce", "waveform.path.ecg", .mixing, 35, [
            K.mix("Match the pump", "Sidechain ducks the bass and chords on each kick. With two kicks a bar, each pump is a big bounce.",
                  [.sidechain], start: [0], target: [0.75], loop: full),
            K.mix("Match chords and pump", "Chords up, gentle pump.",
                  [.chords, .sidechain], start: [0.3, 0.8], target: [0.8, 0.4], loop: full),
        ]),
        K.lesson("ukg.u4.l3", "Speed Garage", "Four on the floor, garage swing", "hare.fill", .rhythm, 35, [
            K.drumRule("Speed garage kick: every beat", "Steps 1, 5, 9 and 13. Same swing, harder drive.",
                       tracks: [.kick, .clap, .hat], edit: [.kick],
                       start: Pattern(clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.bassCopy("Copy the speed garage bass", "Offbeat bass, with a jump up the octave.",
                       rows: rows, target: [NoteEvent(2, 35), NoteEvent(6, 35), NoteEvent(7, 47), NoteEvent(10, 35),
                                            NoteEvent(14, 40)],
                       backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
        ]),
        K.lesson("ukg.u4.l4", "Arrange the Two-Step", "Intro to drop", "rectangle.split.3x1.fill", .arrangement, 35, [
            K.arrange("Hats and chords only in the intro", "Columns are sections, rows are parts. In the Intro, switch off the kick, clap and bass.", .rule,
                      lanes: lanes, loop: full,
                      start: K.grid("xxx-", "xxx-", "xxxx", "xxx-", "xxxx"),
                      target: K.grid("-xx-", "-xx-", "xxxx", "-xx-", "xxxx")),
        ]),
        K.lesson("ukg.u4.l5", "The Drop", "Bass drop", "bolt.fill", .arrangement, 35, [
            K.arrange("Copy this garage arrangement", "The bass waits for the drop.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("-xx-", "-xx-", "xxxx", "--x-", "xx-x")),
            K.arrange("Arrange your own", "Every section different from the last.", .create(.variedSections),
                      lanes: lanes, loop: full),
        ]),
        K.mastery("ukg.u4.mastery", "Arrangement Mastery", "Recreate a garage arrangement", .arrangement, 90, [
            K.arrange("Recreate this garage track", "Four sections, five parts.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("--x-", "-xx-", "xxxx", "-xx-", "xxxx")),
        ]),
    ])
}
