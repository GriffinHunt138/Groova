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

    // MARK: Academy (Part 2)

    private static func pick(_ ids: String...) -> [Lesson] { Curriculum.lessons(ids, from: units) }
    private static let style = AcademyKit.techHouse

    static let academy: [Unit] = [
        K.unit("tech.a1", 1, "Tech House Foundations", "House groove, techno punch",
               [AcademyKit.whatMakes(style), AcademyKit.anatomy(style)] + pick("tech.u1.l1") + [AcademyKit.foundationsCheck(style)]),
        K.unit("tech.a2", 2, "Drums & Percussion", "Shuffled hats & rims that groove",
               pick("tech.u1.l2", "tech.u1.l3", "tech.u1.l4", "tech.u1.l5", "tech.u1.mastery")),
        K.unit("tech.a3", 3, "Rolling Bass", "Basslines that roll",
               pick("tech.u2.l1", "tech.u2.l2", "tech.u2.l3", "tech.u2.l4", "tech.u2.l5", "tech.u2.mastery")),
        K.unit("tech.a4", 4, "Keys & Transposing", "Move ideas to any key",
               pick("tech.key.l1", "tech.key.l2", "tech.key.l3", "tech.key.l4", "tech.key.mastery")),
        K.unit("tech.a5", 5, "Vocal Hooks", "One word, stuck in your head",
               [AcademyKit.chopIntro(style), AcademyKit.chopRhythm(style), AcademyKit.chopHook(style),
                AcademyKit.vocalMastery(style)].compactMap { $0 }),
        K.unit("tech.a6", 6, "Club Arrangement", "Builds, drops & cuts",
               pick("tech.u4.l1", "tech.u4.l2", "tech.u4.l3", "tech.u4.l4", "tech.u4.l5", "tech.u4.mastery")),
        K.unit("tech.a7", 7, "Mixing & Final Project", "Tight, loud, finished",
               [AcademyKit.mixBalance(style), AcademyKit.mixPump(style), AcademyKit.mixSpace(style), AcademyKit.finalProject(style)]),
    ]

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
            K.intro("Every other 16th",
                    "Tech house hats tick on the 16ths between the 8ths, then get a small swing so they shuffle. It's the bit of house groove that sits on top of a techno-hard kick.",
                    [.hat], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15])),
            K.drumRule("Closed hats on the in-between 16ths", "Every even step: 2, 4, 6 … 16.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15])),
            K.swingMake("Add the tech house shuffle", "Swing delays every second 16th. Just a touch: past 10%.",
                        tracks: [.kick, .clap, .hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: Array(0..<16)),
                        atLeast: 0.1),
        ]),
        K.lesson("tech.u1.l3", "Percussion Layers", "Rims that groove", "triangle.fill", .rhythm, 20, [
            K.intro("Rims that groove",
                    "Tech house is percussion music. Rims, shakers and bongos bounce around the kick and clap and give each track its personality. Place them just off the claps and they talk to each other.",
                    [.perc, .clap], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 9, 13])),
            K.drumCopy("Copy this rim pattern", "Three rims that bounce off the claps.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: basic,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 9, 13])),
            K.drumMake("Layer your own percussion", "At least four rims.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: basic, goal: .atLeast(.perc, 4)),
        ]),
        K.lesson("tech.u1.l4", "Off-beat Rims", "Push the groove", "arrow.right", .rhythm, 20, [
            K.intro("Push the groove",
                    "A rim on the offbeat sits exactly between the kicks. Move one of them a step late and the whole groove leans forward. Small moves, big feel.",
                    [.perc], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [2, 6, 10, 15])),
            K.drumRule("Rims on every offbeat", "Steps 3, 7, 11 and 15.",
                       tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [2, 6, 10, 14])),
            K.drumCopy("Copy this variation", "The last rim moves late.",
                       tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [2, 6, 10, 15])),
        ]),
        K.lesson("tech.u1.l5", "Rolling Drums", "All together", "repeat", .rhythm, 20, [
            K.intro("All together",
                    "A tech house groove stacks four layers: kick and clap for punch, closed hats for speed, open hats on the offbeats for lift, and rims on top for bounce. Each one fills a different gap.",
                    [.kick, .clap, .hat, .openHat, .perc], demo: drums),
            K.quiz("Which layer?", "Bar 2 adds one layer.", [
                K.hear([basic, Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 9, 13])],
                       ["Rims", "Open hats", "Closed hats"], 0, question: "What joined in bar 2?"),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15]),
                        Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], openHat: [2, 6, 10, 14])],
                       ["Rims", "Open hats", "Closed hats"], 1, question: "What joined in bar 2?"),
            ]),
            K.drumCopy("Copy the full rolling groove", "Open hats on offbeats, closed hats between, rims on top.",
                       tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .openHat, .perc],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), target: drums),
            K.drumMake("Make it yours", "Write the hats and rims yourself. At least six closed hats and three rims.",
                       tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .openHat, .perc],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 6)),
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
            K.intro("The offbeat bass",
                    "Tech house bass dodges the kick: kick, bass, kick, bass. Putting the bass on the offbeats, right between the kicks, is the simplest way to make a groove bounce.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], bass: K.notes(36, [2, 6, 10, 14]))),
            K.bassRule("C on every offbeat", "Rows are notes. C is the fifth row. Steps 3, 7, 11 and 15.",
                       rows: rows, target: K.notes(36, [2, 6, 10, 14]), backing: basic),
            K.quiz("On the kick or between?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], bass: K.notes(36, [2, 6, 10, 14]))], ["Between the kicks", "On the kicks"], 0,
                       "Kick, bass, kick, bass: it bounces.", bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], bass: K.notes(36, [0, 4, 8, 12]))], ["Between the kicks", "On the kicks"], 1,
                       "Bass and kick land together and blur.", bars: 2),
            ]),
            K.bassCopy("Copy this bounce", "Offbeat Cs, with one jump up to E♭ at the end.", rows: rows,
                       target: K.notes(36, [2, 6, 10]) + K.notes(39, [14]), backing: basic),
        ]),
        K.lesson("tech.u2.l2", "Rolling 16ths", "Pairs of notes", "repeat", .theory, 25, [
            K.bassRule("Two Cs after beats 1 and 3", "Steps 3–4 and 11–12.",
                       rows: rows, target: K.notes(36, [2, 3, 10, 11]), backing: basic),
            K.bassCopy("Copy this rolling bassline", "Pairs of Cs with a jump up to G.", rows: rows, target: rolling,
                       backing: basic),
        ]),
        K.lesson("tech.u2.l3", "Bass Tone", "Bite and length", "dial.medium.fill", .soundDesign, 25, [
            K.intro("Bite and length",
                    "Tech house bass is rubbery: a quick bite at the start of each note, then gone. Envelope controls the bite. Length controls how long each note lasts. Short notes leave room for the kick.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: rolling)),
            K.lab("Match the rubbery bass", "Envelope is the bite at the start of each note, Length how long it lasts. Bright bite, short notes.", [.bassEnv, .bassDecay], start: [0.1, 0.8],
                  target: [0.75, 0.15], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: rolling)),
            K.lab("Match the warm bass", "Less bite, longer notes.", [.bassEnv, .bassDecay], start: [0.9, 0.1],
                  target: [0.3, 0.55], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: rolling)),
        ]),
        K.lesson("tech.u2.l4", "Groove Variations", "Same line, new ending", "arrow.triangle.2.circlepath", .theory, 25, [
            K.intro("Same line, new ending",
                    "Tech house tracks run one bassline for minutes. To keep it moving, producers change the ending every few bars: same start, a new climb or drop at the end.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], bass: rolling)),
            K.quiz("What changed?", "Two bars. The bassline changes in bar 2.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: rolling),
                        Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14],
                                bass: [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(10, 39), NoteEvent(11, 41),
                                       NoteEvent(14, 43), NoteEvent(15, 46)])],
                       ["The start", "The ending"], 1, "The second half climbs instead of rolling.", question: "Which part changed?"),
            ]),
            K.bassCopy("Copy this variation", "The second half climbs instead.", rows: rows,
                       target: [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(10, 39),
                                NoteEvent(11, 41), NoteEvent(14, 43), NoteEvent(15, 46)],
                       backing: basic),
            K.bassMake("Write your own ending", "Keep the first half rolling on C, then write a new second half. At least seven notes.",
                       rows: rows, backing: basic, notes: 7),
        ]),
        K.lesson("tech.u2.l5", "Write a Rolling Bassline", "Your turn", "pencil", .theory, 25, [
            K.intro("Your turn",
                    "A good tech house bassline does three things: stays out of the kick's way, repeats enough to lock in, and has one move, a jump or a climb, that you remember.",
                    [], demo: full),
            K.quiz("Quick check", "", [
                K.ask("Where should most of the bass notes go?", ["Between the kicks", "On the kicks", "Only on beat 1"], 0),
                K.ask("Your bassline has twelve different notes and never repeats. What's the problem?",
                      ["Nothing to lock onto", "It's too quiet", "Nothing"], 0, "Repetition is the groove. Save the surprise for one moment."),
            ]),
            K.bassMake("Write your own rolling bassline", "At least six notes, mostly between the kicks. Give it one jump.",
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
            K.intro("One idea, clear sections",
                    "Tech house tracks are often called tools: one strong groove, built for DJs. The arrangement is simple. Parts switch on and off in clear sections so the DJ always knows where they are.",
                    [], demo: full),
            K.quiz("Which section?", "", [
                K.hear([full.keeping([.kick, .hat], bass: false, chords: false)], ["Intro", "Drop", "Break"], 0, bars: 2),
                K.hear([full], ["Intro", "Drop", "Break"], 1, bars: 2),
                K.hear([full.keeping([.hat, .perc], bass: false, chords: false)], ["Intro", "Drop", "Break"], 2, "No kick.", bars: 2),
            ]),
            K.arrange("Kick and hats only in the intro", "Columns are sections, rows are parts. In the Intro, switch off the clap, rims and bass.", .rule,
                      lanes: lanes, loop: full,
                      start: K.grid("xxx-", "xxx-", "xxxx", "xxx-", "xxx-"),
                      target: K.grid("xxx-", "-xx-", "xxxx", "-xx-", "-xx-")),
            K.arrange("Copy this tool track", "Listen to each section. The bass only plays in the Drop.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("xxx-", "-xx-", "xxxx", "-xxx", "--x-")),
        ]),
        K.lesson("tech.u4.l2", "Building Tension", "Add one at a time", "arrow.up.right", .arrangement, 35, [
            K.intro("Add one at a time",
                    "Tension comes from waiting. Each section adds one part, so the groove gets fuller and fuller until the drop gives you everything.",
                    [], demo: full),
            K.quiz("What arrived?", "", [
                K.hear([full.keeping([.kick, .hat], bass: false, chords: false), full.keeping([.kick, .clap, .hat], bass: false, chords: false)],
                       ["The clap", "The bass", "The rims"], 0, question: "What joined in bar 2?"),
                K.hear([full.keeping([.kick, .clap, .hat], bass: false, chords: false), full.keeping([.kick, .clap, .hat, .perc], bass: false, chords: false)],
                       ["The clap", "The bass", "The rims"], 2, question: "What joined in bar 2?"),
            ]),
            K.arrange("Copy this build", "Parts arrive section by section. Listen for what joins in the Build and the Drop.", .recreate,
                      lanes: lanes, loop: full, target: K.grid("xxx-", "-xx-", "xxxx", "--x-", "--x-")),
        ]),
        K.lesson("tech.u4.l3", "The Drop", "Bass on the drop", "bolt.fill", .arrangement, 35, [
            K.intro("Bass on the drop",
                    "The simplest trick in tech house: hold the bassline back until the drop. When it finally rolls in under the kick, the floor feels it.",
                    [], demo: full),
            K.quiz("Feel the drop", "", [
                K.hear([full.keeping([.kick, .clap, .hat, .perc], bass: false, chords: false), full], ["The bass", "The clap", "The hats"], 0,
                       question: "What arrives in bar 2?"),
            ]),
            K.arrange("Bass only in the drop", "Switch the bass on in the Drop column only.", .rule, lanes: lanes, loop: full,
                      start: K.grid("xxx-", "-xx-", "xxxx", "-xx-", "----"),
                      target: K.grid("xxx-", "-xx-", "xxxx", "-xx-", "--x-")),
            K.arrange("Copy this drop", "The Build takes the kick away so the Drop hits harder.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("x-x-", "-xx-", "xxxx", "-xx-", "--x-")),
        ]),
        K.lesson("tech.u4.l4", "Fills & Cuts", "The last beat", "scissors", .rhythm, 35, [
            K.intro("The last beat",
                    "A cut is a fill made of silence: everything drops out for the last beat, maybe leaving one clap roll, and the drop crashes back in. The gap makes the next bar hit twice as hard.",
                    [.clap], demo: Pattern(kick: [0, 4, 8], clap: [4, 12, 13, 14, 15], hat: [1, 3, 5, 7, 9, 11], perc: [3, 9])),
            K.quiz("Cut or roll?", "Bar 2 ends with a fill.", [
                K.hear([basic, Pattern(kick: [0, 4, 8], clap: [4], hat: [2, 6, 10])], ["A cut", "A roll"], 0, "Silence for the last beat.",
                       question: "What kind of fill?"),
                K.hear([basic, Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 13, 14, 15], hat: [2, 6, 10, 14])], ["A cut", "A roll"], 1,
                       question: "What kind of fill?"),
            ]),
            K.drumCopy("Copy this cut", "Everything stops for the last beat except the clap roll.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat],
                       start: Pattern(perc: [3, 9]),
                       target: Pattern(kick: [0, 4, 8], clap: [4, 12, 13, 14, 15], hat: [1, 3, 5, 7, 9, 11], perc: [3, 9])),
            K.drumMake("Write your own cut", "Leave the last beat almost empty. At least four claps in the bar.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                       start: Pattern(kick: [0, 4, 8], hat: [1, 3, 5, 7, 9, 11]), goal: .atLeast(.clap, 4)),
        ]),
        K.lesson("tech.u4.l5", "Arrange a Club Track", "Your turn", "pencil", .arrangement, 35, [
            K.intro("Your turn",
                    "You know the moves: a simple intro, a build that adds one part at a time, a drop with the bass, and a break that takes the kick away. Now put them together.",
                    [], demo: full),
            K.quiz("Quick check", "", [
                K.ask("Where does the bass usually wait until?", ["The drop", "The intro", "The break"], 0),
                K.ask("What makes the drop hit harder?", ["A build that holds back", "A longer drop", "More reverb"], 0),
            ]),
            K.arrange("Arrange your own club track", "Every section different from the last.", .create(.variedSections),
                      lanes: lanes, loop: full),
        ]),
        K.mastery("tech.u4.mastery", "Arrangement Mastery", "Recreate a club arrangement", .arrangement, 90, [
            K.arrange("Recreate this club track", "Listen to all four sections.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("xxx-", "--xx", "xxxx", "-xx-", "--x-")),
        ]),
    ])
}
