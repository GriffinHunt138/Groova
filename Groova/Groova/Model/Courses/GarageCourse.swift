//
//  GarageCourse.swift
//  Groova
//
//  UK Garage: two-step drums, bouncy bass, swung ninth chords, bass-and-chord interplay and arrangement.
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

    // MARK: Academy (Part 2)

    private static func pick(_ ids: String...) -> [Lesson] { Curriculum.lessons(ids, from: units) }
    private static let style = AcademyKit.garage

    static let academy: [Unit] = [
        K.unit("ukg.a1", 1, "UK Garage Foundations", "London, two-step & swing",
               [AcademyKit.whatMakes(style), AcademyKit.anatomy(style)] + pick("ukg.u1.l1") + [AcademyKit.foundationsCheck(style)]),
        K.unit("ukg.a2", 2, "Drums & Shuffle", "Skippy hats, ghosts & late kicks",
               pick("ukg.u1.l2", "ukg.u1.l3", "ukg.u1.l4", "ukg.u1.l5", "ukg.u1.mastery")),
        K.unit("ukg.a3", 3, "Bouncy Bass", "Sub, skip & octaves",
               pick("ukg.u2.l1", "ukg.u2.l2", "ukg.u2.l3", "ukg.u2.l4", "ukg.u2.l5", "ukg.u2.mastery")),
        K.unit("ukg.a4", 4, "Garage Chords", "Ninths & swung stabs",
               pick("ukg.u3.l1", "ukg.u3.l2", "ukg.u3.l3", "ukg.u3.l4", "ukg.u3.l5", "ukg.u3.mastery")),
        K.unit("ukg.a5", 5, "Bass & Chords Talking", "Parts that answer each other",
               pick("ukg.talk.l1", "ukg.talk.l2", "ukg.talk.l3", "ukg.talk.l4", "ukg.talk.mastery")),
        K.unit("ukg.a6", 6, "Vocals & Chops", "Sliced, pitched and swung",
               [AcademyKit.chopIntro(style), AcademyKit.chopRhythm(style), AcademyKit.chopHook(style),
                AcademyKit.vocalMastery(style)].compactMap { $0 }),
        K.unit("ukg.a7", 7, "Arrangement", "Speed garage, verses & the drop",
               pick("ukg.u4.l3", "ukg.u4.l4", "ukg.u4.l5") + [AcademyKit.loopToTrack(style)] + pick("ukg.u4.mastery")),
        K.unit("ukg.a8", 8, "Mixing & Final Project", "Punch, bounce, finished",
               [AcademyKit.mixBalance(style), AcademyKit.mixPump(style), AcademyKit.mixSpace(style), AcademyKit.finalProject(style)]),
    ]

    static let units: [Unit] = [unit1, unit2, unit3, talkUnit, unit4]

    // MARK: Unit 1 — The Two-Step

    static let unit1 = K.unit("ukg.u1", 1, "The Two-Step", "Swing, skip and shuffle", [
        K.lesson("ukg.u1.l1", "Two-Step Shuffle", "Swing and broken kicks", "figure.dance", .rhythm, 25, [
            K.intro("The two-step",
                    "UK garage came out of London in the 90s: house tempo, but the kick breaks out of the steady four. One kick on the downbeat, one pushed late, claps on 2 and 4, and heavy swing on the hats so everything skips.",
                    [.kick, .clap, .hat], demo: skippy),
            K.swingMake("Add swing until it shuffles",
                        "Swing delays every second 16th. Watch the cells shift, and push past 25%.",
                        tracks: [.clap, .hat], start: Pattern(clap: [4, 12], hat: Array(0..<16)), atLeast: 0.25),
            K.drumRule("Two-step kick: hit step 1 and step 11",
                       "Garage skips the steady four. One kick on the downbeat, then a late push on step 11.",
                       tracks: [.kick, .clap, .hat], edit: [.kick],
                       start: Pattern(clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15]),
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.drumCopy("Recreate this garage groove", "Three kicks around the claps, plus two rims near the end. Listen for the late kicks.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .hat, .perc], start: Pattern(clap: [4, 12]),
                       target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 6, 10, 11, 14], perc: [9, 15])),
            K.quiz("Two-step or four?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])], ["Four on the floor", "Two-step"], 0, bars: 2),
                K.hear([twoStep], ["Four on the floor", "Two-step"], 1, "Downbeat, then a late kick.", bars: 2),
            ]),
        ]),
        K.lesson("ukg.u1.l2", "Skippy Hats", "Pairs of 16ths", "sparkles", .rhythm, 25, [
            K.intro("Pairs of 16ths",
                    "Garage hats come in pairs: one on the offbeat and one straight after it. With swing on, the second hat of each pair lands late, and that's the skip.",
                    [.hat], demo: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.drumRule("Hats in pairs after every beat", "Steps 3–4, 7–8, 11–12 and 15–16.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 10], clap: [4, 12]),
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.drumCopy("Copy these skippy hats", "Some pairs, some singles.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 10], clap: [4, 12]),
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14])),
            K.quiz("Straight or skippy?", "Same hats, different swing.", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])], ["Straight", "Skippy"], 0, bars: 2, swing: 0),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])], ["Straight", "Skippy"], 1, bars: 2, swing: 0.32),
            ]),
            K.drumMake("Write your own skippy hats", "At least six hats, mostly in pairs.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 10], clap: [4, 12]), goal: .atLeast(.hat, 6)),
        ]),
        K.lesson("ukg.u1.l3", "Rim Ghost Notes", "Quiet extra hits", "triangle.fill", .rhythm, 25, [
            K.intro("Quiet extra hits",
                    "A ghost note is a soft extra hit that fills a gap. In garage, rims ghost around the claps and kicks, so the groove feels busy without getting loud.",
                    [.perc], demo: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [5, 13])),
            K.drumRule("Ghost rims after the claps", "A ghost note is a quiet extra hit that fills a gap. Put rims on steps 6 and 14, just after each clap.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: twoStep,
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [5, 13])),
            K.drumCopy("Copy this rim pattern", "Three rims, all in the gaps.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: twoStep,
                       target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 9, 15])),
            K.quiz("Spot the ghost", "", [
                K.hear([twoStep], ["No ghosts", "Ghost rims"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 9, 15])], ["No ghosts", "Ghost rims"], 1, bars: 2),
            ]),
        ]),
        K.lesson("ukg.u1.l4", "Late Kicks", "Push and pull", "arrow.uturn.right", .rhythm, 25, [
            K.intro("Push and pull",
                    "Garage kicks rarely sit on the beat after the first one. A kick just before a clap pushes into it. A kick just after pulls back. Moving one kick by a single step changes the whole bounce.",
                    [.kick], demo: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 10, 14])),
            K.drumCopy("Copy these kicks", "One on the downbeat, two late ones.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 10, 14])),
            K.drumCopy("Copy another variation", "The second kick moves.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 7, 11], clap: [4, 12], hat: [2, 6, 10, 14])),
            K.quiz("Push or pull?", "Listen to the extra kick around the clap.", [
                K.hear([Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 10, 14])], ["Pushes into the clap", "Pulls back after it"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 5, 10], clap: [4, 12], hat: [2, 6, 10, 14])], ["Pushes into the clap", "Pulls back after it"], 1, bars: 2),
            ]),
        ]),
        K.lesson("ukg.u1.l5", "Your Own Two-Step", "Write the kicks", "pencil", .rhythm, 25, [
            K.intro("Write the kicks",
                    "The two-step kick is a rhythm you can play with. Keep a kick on the downbeat so the bar has an anchor, then place one or two more off the beat to push and pull against the claps.",
                    [.kick], demo: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.quiz("Quick check", "", [
                K.ask("Which kick should you keep in a two-step?", ["The one on the downbeat", "The one on beat 2", "None of them"], 0,
                      "It anchors the bar. The others can move."),
                K.ask("You put a kick on every beat. What have you made?", ["Four on the floor, not a two-step", "A two-step", "Garage"], 0),
            ]),
            K.drumCopy("Copy this two-step", "Downbeat, one before the second clap, one late.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15]),
                       target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.drumMake("Write your own two-step kicks", "At least two kicks. Keep the downbeat and avoid the steady four.",
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
            K.intro("Round and warm",
                    "Garage bass is a sub: deep, round and felt in your chest. Close the cutoff for warmth. Length decides if it bounces with short notes or rolls with long ones.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], bass: bassline)),
            K.lab("Explore the garage bass", "Cutoff for brightness, length for how long each note holds.",
                  [.bassCutoff, .bassDecay], start: [0.48, 0.42], loop: Pattern(kick: [0, 10], clap: [4, 12], bass: bassline)),
            K.lab("Match the deep sub", "Dark and long.",
                  [.bassCutoff, .bassDecay], start: [0.7, 0.1], target: [0.15, 0.75],
                  loop: Pattern(kick: [0, 10], clap: [4, 12], bass: bassline)),
            K.quiz("Sub or bright?", "", [
                K.sound(Pattern(kick: [0, 10], clap: [4, 12], bass: bassline), [.bassCutoff: 0.12, .bassDecay: 0.7], ["Deep sub", "Bright bass"], 0),
                K.sound(Pattern(kick: [0, 10], clap: [4, 12], bass: bassline), [.bassCutoff: 0.7, .bassDecay: 0.3], ["Deep sub", "Bright bass"], 1),
            ]),
        ]),
        K.lesson("ukg.u2.l2", "Skipping Bass", "Off the kick", "figure.run", .theory, 30, [
            K.intro("Off the kick",
                    "Garage bass skips around the broken kick. It lands with the first kick, then answers in the gaps, so bass and kick play a conversation instead of hitting together.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                      bass: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(7, 43), NoteEvent(11, 38)])),
            K.bassRule("Bass on step 1 and step 8", "Rows are notes. E is the fourth row down.",
                       rows: rows, target: [NoteEvent(0, 40), NoteEvent(7, 40)], backing: twoStep),
            K.bassCopy("Copy this skipping bass", "It answers the kicks.",
                       rows: rows, target: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(7, 43), NoteEvent(11, 38)],
                       backing: twoStep),
            K.bassMake("Write your own skipping bass", "At least four notes. Start with the first kick, then fill the gaps.",
                       rows: rows, backing: twoStep, notes: 4),
        ]),
        K.lesson("ukg.u2.l3", "Long and Short", "Note lengths", "ruler", .theory, 30, [
            K.intro("Note lengths",
                    "In garage, how long each bass note holds is half the groove. Long notes roll and carry the weight. Short notes bounce and leave gaps for the kick. Mixing them is where the swing comes from.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], bass: bassline)),
            K.quiz("Long or short?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 40, 3), NoteEvent(6, 43, 3), NoteEvent(10, 38, 4)])],
                       ["Long and rolling", "Short and bouncy"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(6, 43), NoteEvent(10, 38), NoteEvent(14, 35)])],
                       ["Long and rolling", "Short and bouncy"], 1, bars: 2),
            ]),
            K.bassCopy("Copy this bassline", "Two long notes and three short ones. Drag notes to make them longer.",
                       rows: rows, target: bassline, backing: twoStep),
            K.bassMake("Write your own", "At least four notes. Make at least one long and one short.", rows: rows, backing: twoStep, notes: 4),
        ]),
        K.lesson("ukg.u2.l4", "Octave Jumps", "Low B, high B", "arrow.up.arrow.down", .theory, 30, [
            K.intro("Low B, high B",
                    "An octave is the same note, twelve semitones higher. Garage bass loves bouncing between the two: low for weight, high for bounce. It adds energy without changing the harmony.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(8, 35), NoteEvent(11, 47)])),
            K.bassRule("Jump between the two Bs", "An octave is the same note, higher up. Low B (bottom row) on steps 1 and 9, high B (top row) on steps 4 and 12.",
                       rows: rows, target: [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(8, 35), NoteEvent(11, 47)],
                       backing: twoStep),
            K.bassCopy("Copy this octave line", "Jumps up and down, then an E to finish.",
                       rows: rows,
                       target: [NoteEvent(0, 35), NoteEvent(2, 47), NoteEvent(6, 35), NoteEvent(7, 47), NoteEvent(10, 40, 2)],
                       backing: twoStep),
            K.quiz("Did it jump?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(8, 35), NoteEvent(11, 47)])],
                       ["Jumps an octave", "Stays low"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 35), NoteEvent(3, 35), NoteEvent(8, 35), NoteEvent(11, 35)])],
                       ["Jumps an octave", "Stays low"], 1, bars: 2),
            ]),
        ]),
        K.lesson("ukg.u2.l5", "Write a Garage Bassline", "Your turn", "pencil", .theory, 30, [
            K.intro("Your turn",
                    "A garage bassline does three things: lands with the first kick, skips around the gaps, and mixes long and short notes. Throw in one octave jump for bounce.",
                    [], demo: full),
            K.quiz("Quick check", "", [
                K.ask("Where does a garage bassline usually start?", ["With the first kick", "On beat 2", "On the last step"], 0),
                K.ask("What gives garage bass its bounce?", ["Mixing long and short notes", "Every note the same length", "Lots of reverb"], 0),
            ]),
            K.bassMake("Write your own bassline", "At least five notes. Mix long and short, and jump an octave once.", rows: rows,
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
            K.intro("Five-note chords",
                    "Garage chords are lush. Start with a minor 7th and add one more note on top, the 9th, and you get the soft, rich organ and piano chords all over classic garage.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], chords: [K.ch(0, .em9, 6), K.ch(8, .am9, 6)])),
            K.build("Build Am9: A, C, E, G and B", "A chord is notes played together, named after its root, the note it's built on. Am7 (A, C, E, G) is already there. A ninth adds B, one step above the octave. That's the garage sound.",
                    .am9, start: [57, 60, 64, 67], low: 55, high: 71),
            K.build("Build Em9: E, G, B, D and F♯", "Same recipe, starting on E.", .em9, low: 55, high: 71),
            K.quiz("Seventh or ninth?", "", [
                K.round([.am7], ["7th", "9th"], 0), K.round([.am9], ["7th", "9th"], 1), K.round([.em9], ["7th", "9th"], 1),
            ]),
        ]),
        K.lesson("ukg.u3.l2", "Swung Stabs", "Chords that skip", "bolt.horizontal.fill", .rhythm, 30, [
            K.intro("Chords that skip",
                    "In garage the chords are part of the rhythm. Short stabs land off the beat, just after the claps, and the swing makes them skip like the hats.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], chords: [K.ch(3, .em9), K.ch(5, .em9), K.ch(11, .em9), K.ch(13, .em9)])),
            K.lane("Stab Em9 after every clap", "A stab is a short, punchy chord hit. Put one on steps 6 and 14, just after each clap.", .rule, palette: [.em9], backing: twoStep,
                   target: [5: 0, 13: 0]),
            K.lane("Copy this swung stab rhythm", "Four stabs, all off the beat.", .recreate, palette: [.em9],
                   backing: twoStep, target: [3: 0, 5: 0, 11: 0, 13: 0]),
            K.quiz("On the beat or off?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], chords: [K.ch(4, .em9), K.ch(12, .em9)])], ["With the claps", "Just after the claps"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], chords: [K.ch(5, .em9), K.ch(13, .em9)])], ["With the claps", "Just after the claps"], 1,
                       "Off the beat, so they skip.", bars: 2),
            ]),
            K.lane("Write your own stabs", "At least four stabs, mostly off the beat.", .create(.chordsAtLeast(4)), palette: [.em9],
                   backing: twoStep),
        ]),
        K.lesson("ukg.u3.l3", "Two-Chord Loop", "Em9 to Am9", "arrow.left.arrow.right", .theory, 30, [
            K.intro("Em9 to Am9",
                    "Two lush chords, swapping back and forth, is enough for a whole garage track. Em9 is home, Am9 is the lift. Keep the stab rhythm the same and only change the chord.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], chords: [K.ch(3, .em9), K.ch(5, .em9), K.ch(11, .am9), K.ch(13, .am9)])),
            K.lane("Switch to Am9 for the second half", "Change the stabs on steps 12 and 14 to Am9.", .rule,
                   palette: [.em9, .am9], backing: twoStep,
                   start: [3: 0, 5: 0, 11: 0, 13: 0], target: [3: 0, 5: 0, 11: 1, 13: 1]),
            K.quiz("Which half is Am9?", "", [
                K.round([.em9, .am9], ["First", "Second"], 1, question: "Which chord is the lift?"),
                K.round([.am9, .em9], ["First", "Second"], 0, question: "Which chord is the lift?"),
            ]),
            K.lane("Copy this two-chord loop", "Em9 three times, then Am9 at the end.", .recreate, palette: [.em9, .am9], backing: twoStep,
                   target: [3: 0, 5: 0, 11: 0, 13: 1]),
        ]),
        K.lesson("ukg.u3.l4", "Hear the Change", "Ear training", "ear.fill", .theory, 30, [
            K.intro("Hear the change",
                    "From Em9 the chords can go up to bright Cmaj9, across to Am9, or down to dark Dm9. Learning to hear which way it went lets you copy any garage tune you love.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], chords: [K.ch(0, .em9, 6), K.ch(8, .cmaj9, 6)])),
            K.quiz("Which chord comes second?", "Both start on Em9. Cmaj9 sounds brighter, Dm9 darker.", [
                K.round([.em9, .am9], ["Am9", "Cmaj9"], 0),
                K.round([.em9, .cmaj9], ["Am9", "Cmaj9"], 1, "Cmaj9 sounds brighter."),
                K.round([.em9, .dm9], ["Dm9", "Am9"], 0),
            ]),
            K.lane("Recreate what you hear", "Em9, then one of the others. Listen for bright or dark.", .recreate,
                   palette: [.em9, .am9, .cmaj9, .dm9], backing: twoStep, target: [3: 0, 5: 0, 11: 2, 13: 2]),
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

    // MARK: Unit 5 — Speed Garage & the Drop

    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]

    static let unit4 = K.unit("ukg.u4", 5, "Speed Garage & the Drop", "Four-four swing, intros & drops", [
        K.lesson("ukg.u4.l3", "Speed Garage", "Four on the floor, garage swing", "hare.fill", .rhythm, 35, [
            K.intro("Four-four, garage swing",
                    "Speed garage took the swing, the bass and the attitude of garage and put the kick back on every beat. It's harder and more driving, made for big rooms, with a bass that jumps the octave.",
                    [.kick], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15],
                                           bass: [NoteEvent(2, 35), NoteEvent(6, 35), NoteEvent(7, 47), NoteEvent(10, 35), NoteEvent(14, 40)])),
            K.drumRule("Speed garage kick: every beat", "Steps 1, 5, 9 and 13. Same swing, harder drive.",
                       tracks: [.kick, .clap, .hat], edit: [.kick],
                       start: Pattern(clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.bassCopy("Copy the speed garage bass", "Offbeat bass, with a jump up the octave.",
                       rows: rows, target: [NoteEvent(2, 35), NoteEvent(6, 35), NoteEvent(7, 47), NoteEvent(10, 35),
                                            NoteEvent(14, 40)],
                       backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])),
            K.quiz("Garage or speed garage?", "", [
                K.hear([skippy], ["Two-step garage", "Speed garage"], 0, bars: 2, swing: 0.3),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])], ["Two-step garage", "Speed garage"], 1,
                       "Kick on every beat, garage swing on top.", bars: 2, swing: 0.3),
            ]),
        ]),
        K.lesson("ukg.u4.l4", "Arrange the Two-Step", "Intro to drop", "rectangle.split.3x1.fill", .arrangement, 35, [
            K.intro("Intro to drop",
                    "Garage tracks often open with just the hats and chords, so the vocal or the hook can breathe. The kick, clap and bass wait for the drop, then land together.",
                    [], demo: Pattern(hat: [2, 3, 6, 7, 10, 11, 14, 15], chords: [K.ch(3, .em9, 2), K.ch(11, .am9, 2)])),
            K.quiz("Which section?", "", [
                K.hear([full.keeping([.hat], bass: false, chords: true)], ["Intro", "Drop"], 0, bars: 2),
                K.hear([full], ["Intro", "Drop"], 1, bars: 2),
            ]),
            K.arrange("Hats and chords only in the intro", "Columns are sections, rows are parts. In the Intro, switch off the kick, clap and bass.", .rule,
                      lanes: lanes, loop: full,
                      start: K.grid("xxx-", "xxx-", "xxxx", "xxx-", "xxxx"),
                      target: K.grid("-xx-", "-xx-", "xxxx", "-xx-", "xxxx")),
        ]),
        K.lesson("ukg.u4.l5", "The Drop", "Bass drop", "bolt.fill", .arrangement, 35, [
            K.intro("Bass drop",
                    "The garage drop is the moment the sub comes in. Hold the bass back through the intro and build, and when it finally lands under the two-step the whole room moves.",
                    [], demo: full),
            K.quiz("Feel the drop", "", [
                K.hear([full.keeping([.kick, .clap, .hat], bass: false, chords: true), full], ["The bass", "The chords", "The hats"], 0,
                       question: "What arrives in bar 2?"),
            ]),
            K.arrange("Copy this garage arrangement", "The bass waits for the drop.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("-xx-", "-xx-", "xxxx", "--x-", "xx-x")),
            K.arrange("Arrange your own", "Every section different from the last. Save the bass for the drop.", .create(.variedSections),
                      lanes: lanes, loop: full),
        ]),
        K.mastery("ukg.u4.mastery", "Arrangement Mastery", "Recreate a garage arrangement", .arrangement, 90, [
            K.arrange("Recreate this garage track", "Four sections, five parts.", .recreate, lanes: lanes, loop: full,
                      target: K.grid("--x-", "-xx-", "xxxx", "-xx-", "xxxx")),
        ]),
    ])
}
