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

    // MARK: Academy (Part 2)

    private static func pick(_ ids: String...) -> [Lesson] { Curriculum.lessons(ids, from: units) }
    private static let style = AcademyKit.techno

    static let academy: [Unit] = [
        K.unit("techno.a1", 1, "Techno Foundations", "Detroit, Berlin & the machine",
               [AcademyKit.whatMakes(style), AcademyKit.anatomy(style)] + pick("techno.u1.l1") + [AcademyKit.foundationsCheck(style)]),
        K.unit("techno.a2", 2, "Drums & Rhythm", "Rumble, rims & hypnotic hats",
               pick("techno.u1.l2", "techno.u1.l3", "techno.u1.l4", "techno.u1.l5", "techno.u1.mastery")),
        K.unit("techno.a3", 3, "Bass & Acid", "Rolling bass and squelch",
               pick("techno.u2.l1", "techno.u2.l2", "techno.u2.l3", "techno.u2.l4", "techno.u2.l5", "techno.u2.mastery")),
        K.unit("techno.a4", 4, "Hypnotic Loops", "Polyrhythm, dub chords & space",
               pick("techno.u3.l1", "techno.u3.l2", "techno.u3.l3", "techno.u3.l4", "techno.u3.l5", "techno.u3.mastery")),
        K.unit("techno.a5", 5, "Riffs & Arps", "Hypnotic lead lines",
               pick("techno.riff.l1", "techno.riff.l2", "techno.riff.l3", "techno.riff.l4", "techno.riff.mastery")),
        K.unit("techno.a6", 6, "Long Builds", "Tension, release & the slam",
               pick("techno.u5.l1", "techno.u5.l2", "techno.u5.l3", "techno.u5.l4", "techno.u5.l5", "techno.u5.mastery")),
        K.unit("techno.a7", 7, "Mixing & Final Project", "Heavy, driving, finished",
               [AcademyKit.mixBalance(style), AcademyKit.mixPump(style), AcademyKit.mixSpace(style), AcademyKit.finalProject(style)]),
    ]

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
            K.intro("The rumble",
                    "A techno kick is longer and dirtier than a house kick. Drive adds distortion so it cuts through a warehouse sound system. Length lets the low end roll on until it almost meets the next kick: that's the rumble.",
                    [.kick], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.lab("Explore the techno kick", "Drive adds distortion. Length lets the kick rumble into the next one.",
                  [.kickDrive, .kickDecay], start: [0.55, 0.57], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.lab("Match the warehouse kick", "Heavily driven and long.",
                  [.kickDrive, .kickDecay], start: [0.1, 0.2], target: [0.9, 0.75],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.lab("Match the clean, tight kick", "Barely any drive, short and dry.",
                  [.kickDrive, .kickDecay], start: [0.8, 0.8], target: [0.1, 0.2],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
            K.quiz("Dirty or clean?", "", [
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]), [.kickDrive: 0.9, .kickDecay: 0.75], ["Warehouse", "Clean and tight"], 0),
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]), [.kickDrive: 0.05, .kickDecay: 0.2], ["Warehouse", "Clean and tight"], 1),
            ]),
        ]),
        K.lesson("techno.u1.l3", "Off-grid Rims", "Hits that hook", "triangle.fill", .rhythm, 25, [
            K.intro("Hits that hook",
                    "Techno has no clap on 2 and 4 most of the time. The hook comes from rims and percussion placed off the beat, so they pull against the steady kick and your ear locks onto them.",
                    [.perc], demo: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [3, 6, 11])),
            K.drumRule("Rim on the last 16th of every beat", "Steps 4, 8, 12 and 16.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: pulse,
                       target: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [3, 7, 11, 15])),
            K.drumCopy("Copy this rim pattern", "Four rims, none on the beat.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: pulse,
                       target: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [2, 5, 11, 14])),
            K.quiz("On the beat or off?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [0, 4, 8, 12])], ["On the beat", "Off the beat"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [2, 5, 11, 14])], ["On the beat", "Off the beat"], 1, bars: 2),
            ]),
            K.drumMake("Write your own rim hook", "At least three rims, none on the beat.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: pulse, goal: .atLeast(.perc, 3)),
        ]),
        K.lesson("techno.u1.l4", "Hypnotic Hats", "Open and closed", "sparkles", .rhythm, 25, [
            K.intro("Open and closed",
                    "Closed hats on every 16th are the engine. Open hats on the offbeats give it lift. Take a few closed hats away and the gaps start to swing, even without any swing at all.",
                    [.hat, .openHat], demo: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15], openHat: [2, 6, 10, 14])),
            K.drumRule("Open hats on every offbeat", "Steps 3, 7, 11 and 15.",
                       tracks: [.kick, .hat, .openHat], edit: [.openHat], start: pulse,
                       target: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14])),
            K.drumCopy("Copy these broken hats", "The closed hats skip some steps. Listen for the gaps.",
                       tracks: [.kick, .hat, .openHat], edit: [.hat],
                       start: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15],
                                       openHat: [2, 6, 10, 14])),
            K.quiz("Open or closed?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14])], ["Open", "Closed"], 0, bars: 2, question: "Which hat is on the offbeat?"),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])], ["Open", "Closed"], 1, bars: 2, question: "Which hat is on the offbeat?"),
            ]),
        ]),
        K.lesson("techno.u1.l5", "Your First Techno Loop", "Make it hypnotic", "repeat", .rhythm, 25, [
            K.intro("Make it hypnotic",
                    "A techno loop has to hold a room for minutes at a time. The secret is a few parts locked together, each simple, with one or two hits off the grid for your ear to chase.",
                    [.kick, .hat, .openHat, .perc], demo: groove),
            K.drumMake("Add your own rim pattern", "At least three rims. Off-grid hits hypnotise the most.",
                       tracks: [.kick, .hat, .openHat, .perc], edit: [.perc],
                       start: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14]),
                       goal: .atLeast(.perc, 3)),
            K.drumMake("Now write the hats", "At least eight closed hats. Leave a few gaps.",
                       tracks: [.kick, .hat, .openHat, .perc], edit: [.hat, .openHat],
                       start: Pattern(kick: [0, 4, 8, 12], perc: [3, 6, 11]), goal: .atLeast(.hat, 8)),
            K.quiz("Quick check", "", [
                K.ask("What makes a techno loop hypnotic?", ["Simple parts locked together, with a few hits off the grid", "As many parts as possible",
                                                             "A new pattern every bar"], 0),
            ]),
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
            K.intro("Fill the gaps",
                    "Techno bass rolls: quick 16th notes in the space right after each kick, never on it. Kick, bass, bass, kick, bass, bass. The kick and the bass become one rolling machine.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: rolling)),
            K.bassRule("Two 16ths after every offbeat", "Rows are notes, with low A at the bottom. Steps 3–4, 7–8, 11–12 and 15–16.",
                       rows: rows, target: rolling, backing: pulse),
            K.bassCopy("Copy this rolling bass", "Same rhythm, but the last pair steps up.",
                       rows: rows,
                       target: K.notes(33, [2, 3, 6, 7, 10, 11]) + K.notes(36, [14, 15]), backing: pulse),
            K.quiz("Where's the bass?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: rolling)], ["Between the kicks", "On the kicks"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: K.notes(33, [0, 4, 8, 12]))], ["Between the kicks", "On the kicks"], 1,
                       "It smears into the kick. Muddy.", bars: 2),
            ]),
            K.bassMake("Write your own roll", "At least six notes, all between the kicks.", rows: rows, backing: pulse, notes: 6),
        ]),
        K.lesson("techno.u2.l2", "Resonance Squelch", "Cutoff and resonance", "dial.high.fill", .soundDesign, 30, [
            K.intro("The squelch",
                    "Resonance boosts the sound right at the filter's cutoff, so the filter starts to sing. Turn it up and move the cutoff, and a plain bass turns into the squeal of acid techno.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.lab("Explore the squelch", "Turn resonance up, then move the cutoff around.",
                  [.bassCutoff, .bassResonance], start: [0.23, 0.3], loop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.lab("Match the squelch", "High resonance, cutoff in the middle.",
                  [.bassCutoff, .bassResonance], start: [0.7, 0.1], target: [0.4, 0.85],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.quiz("Squelch or smooth?", "", [
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid), [.bassCutoff: 0.4, .bassResonance: 0.85], ["Squelch", "Smooth"], 0),
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid), [.bassCutoff: 0.4, .bassResonance: 0], ["Squelch", "Smooth"], 1),
            ]),
        ]),
        K.lesson("techno.u2.l3", "Acid Line", "Jumps and accents", "waveform.path", .theory, 30, [
            K.intro("Jumps and accents",
                    "An acid line is busy 16ths on one low note, with jumps up an octave now and then. The jumps are the accents: they're what you remember.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.bassCopy("Copy this acid line", "Low A with jumps to the top. Listen for the high notes.",
                       rows: rows, target: acid, backing: pulse),
            K.bassMake("Write your own acid line", "At least eight notes. Jump to the top row, an octave up, now and then.",
                       rows: rows, backing: pulse, notes: 8),
            K.quiz("Quick check", "", [
                K.ask("In an acid line, what are the jumps up an octave for?", ["They're the accents you remember", "They make it quieter",
                                                                                "They change the key"], 0),
            ]),
        ]),
        K.lesson("techno.u2.l4", "Filter Ride", "Open it slowly", "slider.horizontal.3", .soundDesign, 30, [
            K.intro("Open it slowly",
                    "Techno DJs and producers build tension by riding a filter: start with it closed and dark, then open it over 16 or 32 bars. When it's fully open, the track feels like it's arrived.",
                    [], demo: full),
            K.filterSweep("Ride the filter", "A low-pass filter cuts the highs. Techno lives on this knob. Close it, then open it.", full),
            K.filterMatch("Match the closed-down groove", "Dark and resonant, like the start of a build.",
                          cutoff: 500, resonance: 0.65, full),
            K.quiz("Open or closed?", "", [
                K.filtered(full, cutoff: 400, ["Closed: the start of a build", "Open: it's arrived"], 0),
                K.filtered(full, cutoff: 15000, ["Closed: the start of a build", "Open: it's arrived"], 1),
            ]),
        ]),
        K.lesson("techno.u2.l5", "Acid Jam", "All three knobs", "dial.medium.fill", .soundDesign, 30, [
            K.intro("All three knobs",
                    "Acid is three knobs working together. Cutoff sets how bright. Resonance sets how much it squeals. Envelope opens the filter on every note so each one goes 'wow'.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.lab("Match this acid sound", "Cutoff, resonance, and envelope, which adds a 'wow' to the start of each note.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.7, 0.1, 0.1], target: [0.3, 0.8, 0.8],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.lab("Make it your own", "Turn every knob through its whole range.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.4, 0.5, 0.5],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid)),
            K.quiz("Hear the envelope", "", [
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid), [.bassCutoff: 0.3, .bassResonance: 0.8, .bassEnv: 0.85],
                        ["Every note goes 'wow'", "Steady"], 0),
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: acid), [.bassCutoff: 0.3, .bassResonance: 0.8, .bassEnv: 0],
                        ["Every note goes 'wow'", "Steady"], 1),
            ]),
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
            K.intro("Three against four",
                    "The kick counts in fours. Put a sound every three steps instead and it drifts against the kick, lining up again only every three bars. That slow drift is what makes a loop hypnotic.",
                    [.perc], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], perc: [0, 3, 6, 9, 12, 15])),
            K.drumRule("Rim on every third step", "Steps 1, 4, 7, 10, 13 and 16. It drifts against the kick.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], perc: [0, 3, 6, 9, 12, 15])),
            K.drumCopy("Copy this polyrhythm", "Open hats every third step, starting on step 2.",
                       tracks: [.kick, .openHat, .perc], edit: [.openHat], start: Pattern(kick: [0, 4, 8, 12], perc: [3, 11]),
                       target: Pattern(kick: [0, 4, 8, 12], openHat: [1, 4, 7, 10, 13], perc: [3, 11])),
            K.quiz("Lined up or drifting?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], perc: [2, 6, 10, 14])], ["Lined up", "Drifting"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], perc: [0, 3, 6, 9, 12, 15])], ["Lined up", "Drifting"], 1, bars: 2),
            ]),
            K.drumMake("Write your own polyrhythm", "Put rims every three or five steps. At least four.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]),
                       goal: .atLeast(.perc, 4)),
        ]),
        K.lesson("techno.u3.l2", "Dub Chord", "One chord, endless", "music.quarternote.3", .theory, 30, [
            K.intro("One chord, endless",
                    "Dub techno is built on a single chord, usually a minor 7th, stabbed short and drenched in echo. It barely changes, so tiny moves in rhythm and tone feel huge.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], chords: [K.ch(3, .am7, 2), K.ch(10, .am7, 2)])),
            K.build("Build the dub chord: Am7", "A chord is notes played together. Tap A, C, E and G. Dub techno lives on this one.", .am7),
            K.lane("Stab it on the offbeats", "A stab is a short chord hit. Put one on every offbeat: steps 3, 7, 11 and 15.", .rule, palette: [.am7], backing: dubBacking,
                   target: [2: 0, 6: 0, 10: 0, 14: 0], length: 2),
            K.lane("Copy this dub rhythm", "The stabs drift late in the bar.", .recreate, palette: [.am7],
                   backing: dubBacking, target: [3: 0, 7: 0, 10: 0, 13: 0], length: 2),
            K.quiz("Quick check", "", [
                K.ask("Dub techno uses one chord for minutes. What keeps it interesting?", ["Small changes in rhythm and tone", "Changing chords every bar",
                                                                                            "Getting louder"], 0),
            ]),
        ]),
        K.lesson("techno.u3.l3", "Echo Space", "Huge reverb", "water.waves", .soundDesign, 30, [
            K.intro("Huge space",
                    "Reverb is the room a sound plays in. Dub techno uses enormous ones, so every stab leaves a long tail that fills the gaps between the kicks.",
                    [], demo: Pattern(kick: [0, 8], chords: [K.ch(3, .am7, 2), K.ch(10, .am7, 2)])),
            K.space("Drown the chords in space", "Dub techno uses huge spaces. Try the cathedral.",
                    Pattern(kick: [0, 8], chords: [K.ch(3, .am7, 2), K.ch(10, .am7, 2)])),
            K.lane("Write your own dub stabs", "At least four stabs. Dm7 is a second chord to move to.", .create(.chordsAtLeast(4)),
                   palette: [.am7, .dm7], backing: dubBacking, length: 2),
            K.quiz("Dry or huge?", "", [
                K.reverb(Pattern(kick: [0, 8], chords: [K.ch(3, .am7, 2), K.ch(10, .am7, 2)]), amount: 0.05, ["Dry", "Huge"], 0),
                K.reverb(Pattern(kick: [0, 8], chords: [K.ch(3, .am7, 2), K.ch(10, .am7, 2)]), amount: 0.75, ["Dry", "Huge"], 1),
            ]),
        ]),
        K.lesson("techno.u3.l4", "Minimal Percussion", "Less is more", "minus.circle.fill", .rhythm, 30, [
            K.intro("Less is more",
                    "Minimal techno strips the groove down to three or four parts with lots of space. When there's almost nothing there, every single hit gets your full attention.",
                    [.hat, .perc], demo: Pattern(kick: [0, 4, 8, 12], hat: [2, 7, 10, 15], perc: [5, 13])),
            K.drumCopy("Copy this minimal groove", "Only three parts. Every hit matters.",
                       tracks: [.kick, .hat, .perc], edit: [.hat, .perc], start: Pattern(kick: [0, 4, 8, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], hat: [2, 7, 10, 15], perc: [5, 13])),
            K.drumMake("Make it minimal", "At least two rims, nothing busy.",
                       tracks: [.kick, .hat, .perc], edit: [.hat, .perc], start: Pattern(kick: [0, 4, 8, 12]),
                       goal: .atLeast(.perc, 2)),
            K.quiz("Busy or minimal?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 7, 10, 15], perc: [5, 13])], ["Minimal", "Busy"], 0, bars: 2),
                K.hear([groove], ["Minimal", "Busy"], 1, bars: 2),
            ]),
        ]),
        K.lesson("techno.u3.l5", "Loop Variation", "Change one thing", "arrow.triangle.2.circlepath", .rhythm, 30, [
            K.intro("Change one thing",
                    "A loop that never changes gets boring. A loop that changes everything isn't hypnotic. Techno producers change one small thing every few bars: a hat drops out, a rim moves, an open hat sneaks in.",
                    [], demo: groove),
            K.drumCopy("Spot the change", "The groove from lesson 1, but the closed hats stop early and an extra open hat ends the bar.",
                       tracks: [.kick, .hat, .openHat, .perc], edit: [.hat, .openHat], start: groove,
                       target: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
                                       openHat: [2, 6, 10, 14, 15], perc: [3, 6, 11])),
            K.quiz("What changed?", "Two bars. Listen for the change in bar 2.", [
                K.hear([groove, Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14, 15], perc: [3, 6, 11])],
                       ["Open hats", "Rims", "Kick"], 0, "An extra open hat at the end.", question: "What changed?"),
                K.hear([groove, Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14], perc: [3, 6, 11, 14])],
                       ["Open hats", "Rims", "Kick"], 1, question: "What changed?"),
            ]),
            K.drumMake("Write your own variation", "Start from the groove and change one or two things. Keep at least three rims.",
                       tracks: [.kick, .hat, .openHat, .perc], edit: [.kick, .hat, .openHat, .perc], start: groove, goal: .atLeast(.perc, 3)),
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
            K.intro("Groove, break, slam",
                    "A techno track is long, often seven minutes, built from one loop. The groove runs, then a break pulls the kick away and the tension builds, then everything slams back in.",
                    [], demo: full),
            K.arrange("Take the kick out of the break", "Columns are sections, rows are parts. In the Break column, switch off the kick and bass.", .rule,
                      sections: sections, lanes: lanes, loop: full,
                      start: K.grid("xxxx", "xxxx", "-xxx", "-xxx", "-xxx"),
                      target: K.grid("xx-x", "xxxx", "-xxx", "-xxx", "-x-x")),
            K.arrange("Arrange your own", "Every section needs something, and each one should differ from the last.",
                      .create(.variedSections), sections: sections, lanes: lanes, loop: full),
            K.quiz("Which section?", "", [
                K.hear([full], ["Groove", "Break"], 0, bars: 2),
                K.hear([Pattern(hat: Array(0..<16), openHat: [2, 6, 10, 14], perc: [3, 6, 11])], ["Groove", "Break"], 1, "No kick, no bass.", bars: 2),
            ]),
        ]),
        K.lesson("techno.u5.l2", "The Long Intro", "Patient starts", "arrow.up.right", .arrangement, 35, [
            K.intro("Patient starts",
                    "Techno intros take their time: often just a kick, then rims, then hats, one new part every 16 or 32 bars. It gives DJs room to mix, and makes each new part feel like an event.",
                    [.kick], demo: Pattern(kick: [0, 4, 8, 12])),
            K.arrange("Kick-only intro", "In the Intro, keep only the kick.", .rule, sections: sections, lanes: lanes,
                      loop: full,
                      start: K.grid("xx-x", "xx-x", "xx-x", "xx-x", "xx-x"),
                      target: K.grid("xx-x", "-x-x", "-x-x", "-x-x", "-x-x")),
            K.arrange("Copy this intro", "Parts arrive one by one.", .recreate, sections: sections, lanes: lanes,
                      loop: full, target: K.grid("xx-x", "-xxx", "--xx", "-x-x", "-x-x")),
            K.quiz("What arrives?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12]), Pattern(kick: [0, 4, 8, 12], perc: [3, 6, 11])], ["Rims", "Hats", "Bass"], 0,
                       question: "What arrives in bar 2?"),
            ]),
        ]),
        K.lesson("techno.u5.l3", "The Breakdown", "Hold your breath", "pause.circle.fill", .arrangement, 35, [
            K.intro("Hold your breath",
                    "The breakdown takes the kick away. What keeps playing decides how it feels: a rumbling bass keeps the floor moving, hats alone feel like a held breath.",
                    [], demo: Pattern(hat: Array(0..<16), perc: [3, 6, 11], bass: rolling)),
            K.arrange("Copy this breakdown", "What keeps playing when the kick leaves?", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("xx-x", "xxxx", "-x-x", "xxxx", "-x-x")),
            K.quiz("What keeps playing?", "", [
                K.hear([Pattern(hat: Array(0..<16), perc: [3, 6, 11], bass: rolling)], ["Bass and tops", "Only hats"], 0, bars: 2),
                K.hear([Pattern(hat: Array(0..<16))], ["Bass and tops", "Only hats"], 1, bars: 2),
            ]),
            K.arrange("Keep the bass in the Break", "Switch the bass on in the Break so it keeps rumbling without the kick.", .rule,
                      sections: sections, lanes: lanes, loop: full,
                      start: K.grid("xx-x", "xxxx", "-x-x", "xxxx", "-x-x"), target: K.grid("xx-x", "xxxx", "-x-x", "xxxx", "-xxx")),
        ]),
        K.lesson("techno.u5.l4", "The Slam", "Everything back at once", "bolt.fill", .arrangement, 35, [
            K.intro("Everything back at once",
                    "The slam is the moment the kick and bass come back together after a break. The emptier the break was, the harder the slam hits.",
                    [], demo: full),
            K.arrange("Bring everything back for the slam", "Switch every part on in the Slam column.", .rule,
                      sections: sections, lanes: lanes, loop: full,
                      start: K.grid("xx--", "xxx-", "-x--", "--x-", "-x--"),
                      target: K.grid("xx-x", "xxxx", "-x-x", "--xx", "-x-x")),
            K.quiz("Feel the slam", "", [
                K.hear([Pattern(hat: Array(0..<16), perc: [3, 6, 11]), full], ["Everything slams back", "Nothing changes"], 0, question: "What happens in bar 2?"),
            ]),
            K.arrange("Copy this slam", "The Break is hats and rims only. Everything returns in the Slam.", .recreate,
                      sections: sections, lanes: lanes, loop: full, target: K.grid("xx-x", "xxxx", "-x-x", "-xxx", "-x-x")),
        ]),
        K.lesson("techno.u5.l5", "Fills & Rolls", "Snare-style rolls", "square.stack.3d.up.fill", .rhythm, 35, [
            K.intro("Rolls into the slam",
                    "Techno fills are mostly rolls: rims or kicks getting faster and faster in the last beat before a big moment. The listener feels the slam coming before it lands.",
                    [.kick, .perc], demo: Pattern(kick: [0, 4, 8], hat: Array(0..<12), perc: [12, 13, 14, 15])),
            K.drumRule("Roll the rims into the slam", "Rims on every step of the last beat: 13 to 16.",
                       tracks: [.kick, .hat, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8], hat: Array(0..<12)),
                       target: Pattern(kick: [0, 4, 8], hat: Array(0..<12), perc: [12, 13, 14, 15])),
            K.drumCopy("Copy this roll", "It speeds up through the bar.",
                       tracks: [.kick, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8]),
                       target: Pattern(kick: [0, 4, 8], perc: [4, 8, 10, 12, 13, 14, 15])),
            K.quiz("Where's the roll?", "Four bars.", [
                K.hear([pulse, pulse, pulse, Pattern(kick: [0, 4, 8], hat: Array(0..<12), perc: [12, 13, 14, 15])], ["Bar 2", "Bar 3", "Bar 4"], 2,
                       "At the end of the phrase.", question: "Which bar rolls?"),
            ]),
            K.drumMake("Write your own roll", "Use the last beat. At least four rims.", tracks: [.kick, .hat, .perc], edit: [.perc],
                       start: Pattern(kick: [0, 4, 8], hat: Array(0..<12)), goal: .atLeast(.perc, 4)),
        ]),
        K.mastery("techno.u5.mastery", "Arrangement Mastery", "Recreate a techno arrangement", .arrangement, 100, [
            K.arrange("Recreate this techno track", "Listen to all four sections before you start.", .recreate,
                      sections: sections, lanes: lanes, loop: full,
                      target: K.grid("x--x", "xxxx", "-x-x", "-xxx", "-x-x")),
        ]),
    ])
}
