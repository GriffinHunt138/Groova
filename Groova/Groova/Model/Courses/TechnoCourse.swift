//
//  TechnoCourse.swift
//  Groova
//
//  Techno: machine rhythm, rumble & acid, hypnotic loops, riffs & arps and long builds.
//

import Foundation

nonisolated enum TechnoCourse {
    static let rows = Curriculum.bassRows

    static let pulse = Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16))
    static let groove = Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14], perc: [3, 6, 11])
    static let rolling = K.notes(33, [2, 3, 6, 7, 10, 11, 14, 15])
    static let acid = [NoteEvent(0, 33), NoteEvent(1, 33), NoteEvent(3, 45), NoteEvent(4, 33), NoteEvent(6, 40),
                       NoteEvent(7, 33), NoteEvent(9, 43), NoteEvent(10, 33), NoteEvent(12, 45), NoteEvent(14, 36)]
    static let full = Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14], perc: [3, 6, 11],
                              bass: rolling, chords: [K.ch(3, .am7, 2), K.ch(11, .am7, 2)])
    static let lanes: [Instrument] = [.drum(.kick), .drum(.hat), .drum(.openHat), .drum(.perc), .bass]
    static let sections = ["Intro", "Groove", "Break", "Slam"]

    static let units: [Unit] = [unit1, unit2, unit3, riffUnit, unit5]

    // MARK: Unit 1 — Machine Rhythm

    static let unit1 = K.unit("techno.u1", 1, "Machine Rhythm", "Drive, rumble, repeat", [
        K.lesson("techno.u1.l1", "The Driving Pulse", "16ths, rims & relentless kicks", "bolt.fill", .rhythm, 25, [
            K.intro("Meet the techno kick", "Harder, longer, distorted. It rumbles instead of bounces. Tap it.",
                    [.kick, .perc], demo: pulse),
            K.drumRule("Fill every step with closed hats",
                       "Drag your finger across the whole hat row. Sixteen ticks = pure drive.",
                       tracks: [.kick, .hat], edit: [.hat], start: Pattern(kick: [0, 4, 8, 12]), target: pulse),
            K.drumCopy("Recreate this hypnotic groove", "No clap here. Open hats sit on the offbeats and the rim plays three off-grid hits.",
                       tracks: [.kick, .hat, .openHat, .perc], edit: [.openHat, .perc], start: pulse, target: groove),
        ]),
        K.lesson("techno.u1.l2", "Rumble Kick", "Drive and length", "speaker.wave.3.fill", .soundDesign, 25, [
            K.lab("Explore the techno kick", "Drive adds distortion. Length lets the kick rumble into the next one.",
                  [.kickDrive, .kickDecay], start: [0.55, 0.57], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.lab("Match the warehouse kick", "Heavily driven and long.",
                  [.kickDrive, .kickDecay], start: [0.1, 0.2], target: [0.9, 0.75],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.lab("Match the clean, tight kick", "Barely any drive, short and dry.",
                  [.kickDrive, .kickDecay], start: [0.8, 0.8], target: [0.1, 0.2],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
        ]),
        K.lesson("techno.u1.l3", "Off-grid Rims", "Hits that hook", "triangle.fill", .rhythm, 25, [
            K.drumRule("Rim on the last 16th of every beat", "Steps 4, 8, 12 and 16.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: pulse,
                       target: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [3, 7, 11, 15])),
            K.drumCopy("Copy this rim pattern", "Four rims, none on the beat.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: pulse,
                       target: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [2, 5, 11, 14])),
        ]),
        K.lesson("techno.u1.l4", "Hypnotic Hats", "Open and closed", "sparkles", .rhythm, 25, [
            K.drumRule("Open hats on every offbeat", "Steps 3, 7, 11 and 15.",
                       tracks: [.kick, .hat, .openHat], edit: [.openHat], start: pulse,
                       target: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14])),
            K.drumCopy("Copy these broken hats", "The closed hats skip some steps. Listen for the gaps.",
                       tracks: [.kick, .hat, .openHat], edit: [.hat],
                       start: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15],
                                       openHat: [2, 6, 10, 14])),
        ]),
        K.lesson("techno.u1.l5", "Your First Techno Loop", "Make it hypnotic", "repeat", .rhythm, 25, [
            K.drumMake("Add your own rim pattern", "At least three rims. Off-grid hits hypnotise the most.",
                       tracks: [.kick, .hat, .openHat, .perc], edit: [.perc],
                       start: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14]),
                       goal: .atLeast(.perc, 3)),
            K.drumMake("Now write the hats", "At least eight closed hats. Leave a few gaps.",
                       tracks: [.kick, .hat, .openHat, .perc], edit: [.hat, .openHat],
                       start: Pattern(kick: [0, 4, 8, 12], perc: [3, 6, 11]), goal: .atLeast(.hat, 8)),
        ]),
        K.mastery("techno.u1.mastery", "Machine Rhythm Mastery", "Recreate a techno groove", .rhythm, 60, [
            K.groove("Recreate this techno groove",
                     reference: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14], perc: [3, 6, 11, 14],
                                        bass: rolling),
                     tracks: [.kick, .openHat, .perc], rows: rows),
        ]),
    ])

    // MARK: Unit 2 — Rumble & Acid

    static let unit2 = K.unit("techno.u2", 2, "Rumble & Acid", "Rolling bass and squelch", [
        K.lesson("techno.u2.l1", "Rolling Bass", "Fill the gaps", "waveform", .theory, 30, [
            K.bassRule("Two 16ths after every offbeat", "Rows are notes, with low A at the bottom. Steps 3–4, 7–8, 11–12 and 15–16.",
                       rows: rows, target: rolling, backing: pulse),
            K.bassCopy("Copy this rolling bass", "Same rhythm, but the last pair steps up.",
                       rows: rows,
                       target: K.notes(33, [2, 3, 6, 7, 10, 11]) + K.notes(36, [14, 15]), backing: pulse),
        ]),
        K.lesson("techno.u2.l2", "Resonance Squelch", "Cutoff and resonance", "dial.high.fill", .soundDesign, 30, [
            K.lab("Explore the squelch", "Turn resonance up, then move the cutoff around.",
                  [.bassCutoff, .bassResonance], start: [0.23, 0.3], loop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.lab("Match the squelch", "High resonance, cutoff in the middle.",
                  [.bassCutoff, .bassResonance], start: [0.7, 0.1], target: [0.4, 0.85],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
        ]),
        K.lesson("techno.u2.l3", "Acid Line", "Jumps and accents", "waveform.path", .theory, 30, [
            K.bassCopy("Copy this acid line", "Low A with jumps to the top. Listen for the high notes.",
                       rows: rows, target: acid, backing: pulse),
            K.bassMake("Write your own acid line", "At least eight notes. Jump to the top row, an octave up, now and then.",
                       rows: rows, backing: pulse, notes: 8),
        ]),
        K.lesson("techno.u2.l4", "Filter Ride", "Open it slowly", "slider.horizontal.3", .soundDesign, 30, [
            K.filterSweep("Ride the filter", "A low-pass filter cuts the highs. Techno lives on this knob. Close it, then open it.", full),
            K.filterMatch("Match the closed-down groove", "Dark and resonant, like the start of a build.",
                          cutoff: 500, resonance: 0.65, full),
        ]),
        K.lesson("techno.u2.l5", "Acid Jam", "All three knobs", "dial.medium.fill", .soundDesign, 30, [
            K.lab("Match this acid sound", "Cutoff, resonance, and envelope, which adds a 'wow' to the start of each note.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.7, 0.1, 0.1], target: [0.3, 0.8, 0.8],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.lab("Make it your own", "Turn every knob through its whole range.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.4, 0.5, 0.5],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
        ]),
        K.mastery("techno.u2.mastery", "Acid Mastery", "Recreate an acid groove", .theory, 70, [
            K.groove("Recreate this acid groove",
                     reference: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14], perc: [3, 11], bass: acid),
                     tracks: [.kick, .openHat, .perc], rows: rows),
        ]),
    ])

    // MARK: Unit 3 — Hypnotic Loops

    static let dubBacking = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], perc: [7, 15])

    static let unit3 = K.unit("techno.u3", 3, "Hypnotic Loops", "Polyrhythm, dub chords & space", [
        K.lesson("techno.u3.l1", "Three Against Four", "Polyrhythm", "circle.grid.3x3.fill", .rhythm, 30, [
            K.drumRule("Rim on every third step", "Steps 1, 4, 7, 10, 13 and 16. It drifts against the kick.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], perc: [0, 3, 6, 9, 12, 15])),
            K.drumCopy("Copy this polyrhythm", "Open hats every third step, starting on step 2.",
                       tracks: [.kick, .openHat, .perc], edit: [.openHat], start: Pattern(kick: [0, 4, 8, 12], perc: [3, 11]),
                       target: Pattern(kick: [0, 4, 8, 12], openHat: [1, 4, 7, 10, 13], perc: [3, 11])),
        ]),
        K.lesson("techno.u3.l2", "Dub Chord", "One chord, endless", "music.quarternote.3", .theory, 30, [
            K.build("Build the dub chord: Am7", "A chord is notes played together. Tap A, C, E and G. Dub techno lives on this one.", .am7),
            K.lane("Stab it on the offbeats", "A stab is a short chord hit. Put one on every offbeat: steps 3, 7, 11 and 15.", .rule, palette: [.am7], backing: dubBacking,
                   target: [2: 0, 6: 0, 10: 0, 14: 0], length: 2),
            K.lane("Copy this dub rhythm", "The stabs drift late in the bar.", .recreate, palette: [.am7],
                   backing: dubBacking, target: [3: 0, 7: 0, 10: 0, 13: 0], length: 2),
        ]),
        K.lesson("techno.u3.l3", "Echo Space", "Huge reverb", "water.waves", .soundDesign, 30, [
            K.space("Drown the chords in space", "Dub techno uses huge spaces. Try the cathedral.",
                    Pattern(kick: [0, 8], chords: [K.ch(3, .am7, 2), K.ch(10, .am7, 2)])),
            K.lane("Write your own dub stabs", "At least four stabs. Dm7 is a second chord to move to.", .create(.chordsAtLeast(4)),
                   palette: [.am7, .dm7], backing: dubBacking, length: 2),
        ]),
        K.lesson("techno.u3.l4", "Minimal Percussion", "Less is more", "minus.circle.fill", .rhythm, 30, [
            K.drumCopy("Copy this minimal groove", "Only three parts. Every hit matters.",
                       tracks: [.kick, .hat, .perc], edit: [.hat, .perc], start: Pattern(kick: [0, 4, 8, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [2, 7, 10, 15], perc: [5, 13])),
            K.drumMake("Make it minimal", "At least two rims, nothing busy.",
                       tracks: [.kick, .hat, .perc], edit: [.hat, .perc], start: Pattern(kick: [0, 4, 8, 12]),
                       goal: .atLeast(.perc, 2)),
        ]),
        K.lesson("techno.u3.l5", "Loop Variation", "Change one thing", "arrow.triangle.2.circlepath", .rhythm, 30, [
            K.drumCopy("Spot the change", "The groove from lesson 1, but the closed hats stop early and an extra open hat ends the bar.",
                       tracks: [.kick, .hat, .openHat, .perc], edit: [.hat, .openHat], start: groove,
                       target: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
                                       openHat: [2, 6, 10, 14, 15], perc: [3, 6, 11])),
        ]),
        K.mastery("techno.u3.mastery", "Hypnotic Mastery", "Recreate a dub stab pattern", .theory, 80, [
            K.lane("Recreate this dub-techno riff", "Two chords. Listen for when it moves to Dm7.", .recreate,
                   palette: [.am7, .dm7], backing: dubBacking,
                   target: [2: 0, 5: 0, 10: 1, 13: 0], length: 2),
        ]),
    ])

    // MARK: Unit 5 — Long Builds

    static let unit5 = K.unit("techno.u5", 5, "Long Builds", "Tension, release & the slam", [
        K.lesson("techno.u5.l1", "Techno Sections", "Groove, break, slam", "rectangle.split.3x1.fill", .arrangement, 35, [
            K.arrange("Take the kick out of the break", "Columns are sections, rows are parts. In the Break column, switch off the kick and bass.", .rule,
                      sections: sections, lanes: lanes, loop: full,
                      start: K.grid("xxxx", "xxxx", "-xxx", "-xxx", "-xxx"),
                      target: K.grid("xx-x", "xxxx", "-xxx", "-xxx", "-x-x")),
            K.arrange("Arrange your own", "Every section needs something, and each one should differ from the last.",
                      .create(.variedSections), sections: sections, lanes: lanes, loop: full),
        ]),
        K.lesson("techno.u5.l2", "The Long Intro", "Patient starts", "arrow.up.right", .arrangement, 35, [
            K.arrange("Kick-only intro", "In the Intro, keep only the kick.", .rule, sections: sections, lanes: lanes,
                      loop: full,
                      start: K.grid("xx-x", "xx-x", "xx-x", "xx-x", "xx-x"),
                      target: K.grid("xx-x", "-x-x", "-x-x", "-x-x", "-x-x")),
            K.arrange("Copy this intro", "Parts arrive one by one.", .recreate, sections: sections, lanes: lanes,
                      loop: full, target: K.grid("xx-x", "-xxx", "--xx", "-x-x", "-x-x")),
        ]),
        K.lesson("techno.u5.l3", "The Breakdown", "Hold your breath", "pause.circle.fill", .arrangement, 35, [
            K.arrange("Copy this breakdown", "What keeps playing when the kick leaves?", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("xx-x", "xxxx", "-x-x", "xxxx", "-x-x")),
        ]),
        K.lesson("techno.u5.l4", "The Slam", "Everything back at once", "bolt.fill", .arrangement, 35, [
            K.arrange("Bring everything back for the slam", "Switch every part on in the Slam column.", .rule,
                      sections: sections, lanes: lanes, loop: full,
                      start: K.grid("xx--", "xxx-", "-x--", "--x-", "-x--"),
                      target: K.grid("xx-x", "xxxx", "-x-x", "--xx", "-x-x")),
        ]),
        K.lesson("techno.u5.l5", "Fills & Rolls", "Snare-style rolls", "square.stack.3d.up.fill", .rhythm, 35, [
            K.drumRule("Roll the rims into the slam", "Rims on every step of the last beat: 13 to 16.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8], hat: Array(0..<12)),
                       target: Pattern(kick: [0, 4, 8], hat: Array(0..<12), perc: [12, 13, 14, 15])),
            K.drumCopy("Copy this roll", "It speeds up through the bar.",
                       tracks: [.kick, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8]),
                       target: Pattern(kick: [0, 4, 8], perc: [4, 8, 10, 12, 13, 14, 15])),
        ]),
        K.mastery("techno.u5.mastery", "Arrangement Mastery", "Recreate a techno arrangement", .arrangement, 100, [
            K.arrange("Recreate this techno track", "Listen to all four sections before you start.", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("x--x", "xxxx", "-x-x", "-xxx", "-x-x")),
        ]),
    ])
}
