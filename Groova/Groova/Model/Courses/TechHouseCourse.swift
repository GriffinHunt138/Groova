//
//  TechHouseCourse.swift
//  Groova
//
//  Tech House: rolling percussion, rolling bass, keys & transposing and club arrangement.
//

import Foundation

nonisolated enum TechHouseCourse {
    /// C minor pentatonic, B♭2 down to B♭1.
    static let rows = [46, 43, 41, 39, 36, 34]

    static let drums = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                               openHat: [2, 6, 10, 14], perc: [3, 9, 13])
    static let basic = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])
    static let rolling = [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(10, 36),
                          NoteEvent(11, 36), NoteEvent(14, 39), NoteEvent(15, 36)]
    static let full = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                              openHat: [2, 6, 10, 14], perc: [3, 9, 13], bass: rolling)
    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .drum(.perc), .bass]

    static let units: [Unit] = [unit1, unit2, keyUnit, unit4]

    // MARK: Unit 1 — The Rolling Groove

    static let unit1 = K.unit("tech.u1", 1, "The Rolling Groove", "Punchy drums & percussion", [
        K.lesson("tech.u1.l1", "Punchy Kick & Clap", "The backbone", "circle.circle.fill", .rhythm, 20, [
            K.intro("Meet the tech house kit", "Punchy kick, snappy clap, lots of percussion. Tap them.",
                    [.kick, .clap, .perc], demo: drums),
            K.drumRule("Kick on every beat, clap on 2 and 4", "Kicks: steps 1, 5, 9, 13. Claps: steps 5 and 13.",
                       tracks: [.kick, .clap], edit: [.kick, .clap], target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12])),
            K.lab("Match the punchy kick", "Tight with a little drive.", [.kickDecay, .kickDrive], start: [0.7, 0.0],
                  target: [0.2, 0.4], loop: basic),
        ]),
        K.lesson("tech.u1.l2", "Shuffled Hats", "Every other 16th", "sparkles", .rhythm, 20, [
            K.drumRule("Closed hats on the in-between 16ths", "Every even step: 2, 4, 6 … 16.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15])),
            K.swingMake("Add the tech house shuffle", "Swing delays every second 16th. Just a touch: past 10%.",
                        tracks: [.kick, .clap, .hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: Array(0..<16)),
                        atLeast: 0.1),
        ]),
        K.lesson("tech.u1.l3", "Percussion Layers", "Rims that groove", "triangle.fill", .rhythm, 20, [
            K.drumCopy("Copy this rim pattern", "Three rims that bounce off the claps.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: basic,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 9, 13])),
            K.drumMake("Layer your own percussion", "At least four rims.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: basic, goal: .atLeast(.perc, 4)),
        ]),
        K.lesson("tech.u1.l4", "Off-beat Rims", "Push the groove", "arrow.right", .rhythm, 20, [
            K.drumRule("Rims on every offbeat", "Steps 3, 7, 11 and 15.",
                       tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [2, 6, 10, 14])),
            K.drumCopy("Copy this variation", "The last rim moves late.",
                       tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [2, 6, 10, 15])),
        ]),
        K.lesson("tech.u1.l5", "Rolling Drums", "All together", "repeat", .rhythm, 20, [
            K.drumCopy("Copy the full rolling groove", "Open hats on offbeats, closed hats between, rims on top.",
                       tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .openHat, .perc],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), target: drums),
        ]),
        K.mastery("tech.u1.mastery", "Groove Mastery", "Recreate a tech house groove", .rhythm, 60, [
            K.groove("Recreate this tech house groove",
                     reference: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                        perc: [3, 9, 13], bass: K.notes(36, [2, 6, 10, 14])),
                     tracks: [.kick, .clap, .hat, .perc], rows: rows),
        ]),
    ])

    // MARK: Unit 2 — Rolling Bass

    static let unit2 = K.unit("tech.u2", 2, "Rolling Bass", "Basslines that roll", [
        K.lesson("tech.u2.l1", "Bass Between Kicks", "The offbeat C", "waveform", .theory, 25, [
            K.bassRule("C on every offbeat", "Rows are notes. C is the fifth row. Steps 3, 7, 11 and 15.",
                       rows: rows, target: K.notes(36, [2, 6, 10, 14]), backing: basic),
        ]),
        K.lesson("tech.u2.l2", "Rolling 16ths", "Pairs of notes", "repeat", .theory, 25, [
            K.bassRule("Two Cs after beats 1 and 3", "Steps 3–4 and 11–12.",
                       rows: rows, target: K.notes(36, [2, 3, 10, 11]), backing: basic),
            K.bassCopy("Copy this rolling bassline", "Pairs of Cs with a jump up to G.", rows: rows, target: rolling,
                       backing: basic),
        ]),
        K.lesson("tech.u2.l3", "Bass Tone", "Bite and length", "dial.medium.fill", .soundDesign, 25, [
            K.lab("Match the rubbery bass", "Envelope is the bite at the start of each note, Length how long it lasts. Bright bite, short notes.", [.bassEnv, .bassDecay], start: [0.1, 0.8],
                  target: [0.75, 0.15], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: rolling)),
            K.lab("Match the warm bass", "Less bite, longer notes.", [.bassEnv, .bassDecay], start: [0.9, 0.1],
                  target: [0.3, 0.55], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: rolling)),
        ]),
        K.lesson("tech.u2.l4", "Groove Variations", "Same line, new ending", "arrow.triangle.2.circlepath", .theory, 25, [
            K.bassCopy("Copy this variation", "The second half climbs instead.", rows: rows,
                       target: [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(10, 39),
                                NoteEvent(11, 41), NoteEvent(14, 43), NoteEvent(15, 46)],
                       backing: basic),
        ]),
        K.lesson("tech.u2.l5", "Write a Rolling Bassline", "Your turn", "pencil", .theory, 25, [
            K.bassMake("Write your own rolling bassline", "At least six notes, mostly between the kicks.",
                       rows: rows, backing: drums, notes: 6),
        ]),
        K.mastery("tech.u2.mastery", "Bass Mastery", "Recreate a rolling groove", .theory, 70, [
            K.groove("Recreate this rolling groove",
                     reference: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 13],
                                        bass: rolling),
                     tracks: [.kick, .clap, .perc], rows: rows),
        ]),
    ])

    // MARK: Unit 4 — Club Arrangement

    static let unit4 = K.unit("tech.u4", 4, "Club Arrangement", "Builds, drops & cuts", [
        K.lesson("tech.u4.l1", "Tool Track Sections", "One idea, clear sections", "rectangle.split.3x1.fill", .arrangement, 35, [
            K.arrange("Kick and hats only in the intro", "Columns are sections, rows are parts. In the Intro, switch off the clap, rims and bass.", .rule,
                      lanes: lanes, loop: full,
                      start: K.grid("xxx-", "xxx-", "xxxx", "xxx-", "xxx-"),
                      target: K.grid("xxx-", "-xx-", "xxxx", "-xx-", "-xx-")),
        ]),
        K.lesson("tech.u4.l2", "Building Tension", "Add one at a time", "arrow.up.right", .arrangement, 35, [
            K.arrange("Copy this build", "One new part arrives in each section.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("xxx-", "-xx-", "xxxx", "--x-", "--x-")),
        ]),
        K.lesson("tech.u4.l3", "The Drop", "Bass on the drop", "bolt.fill", .arrangement, 35, [
            K.arrange("Bass only in the drop", "Switch the bass on in the Drop column only.", .rule, lanes: lanes, loop: full,
                      start: K.grid("xxx-", "-xx-", "xxxx", "-xx-", "----"),
                      target: K.grid("xxx-", "-xx-", "xxxx", "-xx-", "--x-")),
        ]),
        K.lesson("tech.u4.l4", "Fills & Cuts", "The last beat", "scissors", .rhythm, 35, [
            K.drumCopy("Copy this cut", "Everything stops for the last beat except the clap roll.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat],
                       start: Pattern(perc: [3, 9]),
                       target: Pattern(kick: [0, 4, 8], clap: [4, 12, 13, 14, 15], hat: [1, 3, 5, 7, 9, 11], perc: [3, 9])),
        ]),
        K.lesson("tech.u4.l5", "Arrange a Club Track", "Your turn", "pencil", .arrangement, 35, [
            K.arrange("Arrange your own club track", "Every section different from the last.", .create(.variedSections),
                      lanes: lanes, loop: full),
        ]),
        K.mastery("tech.u4.mastery", "Arrangement Mastery", "Recreate a club arrangement", .arrangement, 90, [
            K.arrange("Recreate this club track", "Listen to all four sections.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("xxx-", "--xx", "xxxx", "-xx-", "--x-")),
        ]),
    ])
}
