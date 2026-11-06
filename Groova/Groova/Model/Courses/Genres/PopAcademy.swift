//
//  PopAcademy.swift
//  Groova
//
//  Pop, Part 2. Five units and a final song project, in C major at 112 BPM.
//
//  P1 Songs Have Shapes   P2 Chords That Support a Song   P3 Write the Hook
//  P4 Layers That Matter  P5 Tell a Musical Story         P6 Song Project Finale
//

import Foundation

nonisolated enum PopAcademy {
    static let units: [Unit] = [p1, p2, p3, p4, p5, p6]

    // MARK: Material

    static let rows = [48, 45, 43, 41, 40, 36]                 // C3 A2 G2 F2 E2 C2
    static let lead = [76, 74, 72, 71, 69, 67, 65, 64, 62, 60] // C major, E5 down to C4
    static let eighths = [0, 2, 4, 6, 8, 10, 12, 14]

    static let c = ChordShape.c, g = ChordShape.g, am = ChordShape.am, f = ChordShape.f
    static let dm = ChordShape.dm, em = ChordShape.em
    static let gOverB = ChordShape(name: "G/B", pitches: [59, 62, 67])
    static let cOverE = ChordShape(name: "C/E", pitches: [64, 67, 72])
    static let fOverA = ChordShape(name: "F/A", pitches: [57, 60, 65])
    static let gSus = ChordShape(name: "Gsus4", pitches: [55, 60, 62])

    static let beat = Pattern(kick: [0, 6, 8], clap: [4, 12], hat: eighths)
    static let soft = Pattern(kick: [0, 8], hat: [0, 4, 8, 12])
    static let big = Pattern(kick: [0, 6, 8, 10], clap: [4, 12], hat: eighths, openHat: [14])
    static let fill = Pattern(kick: [0, 6, 8], clap: [4, 10, 12, 13, 14, 15], hat: [0, 2, 4, 6, 8])

    /// A chord for a whole bar, with its root in the bass.
    static func bar(_ ch: ChordShape, _ root: Int, drums: Pattern = Pattern()) -> Pattern {
        drums.merged(with: Pattern(bass: [NoteEvent(0, root, 6), NoteEvent(8, root, 6)], chords: [K.ch(0, ch, 14)]))
    }

    static func chordTiles(drums: Pattern = beat) -> [OrderTile] {
        [K.tile("C", bar(c, 36, drums: drums), "Home"), K.tile("G", bar(g, 43, drums: drums)),
         K.tile("Am", bar(am, 45, drums: drums)), K.tile("F", bar(f, 41, drums: drums))]
    }

    static let hook = K.tune([(0, 67, 2), (2, 67, 2), (4, 69, 2), (6, 72, 4), (12, 69, 4)])
    static let verseLine = K.tune([(0, 64, 2), (4, 64, 2), (6, 62, 2), (8, 60, 6)])
    static let verseBed = Pattern(kick: [0, 8], hat: [0, 4, 8, 12], bass: [NoteEvent(0, 36, 8), NoteEvent(8, 45, 8)],
                                  chords: [K.ch(0, c, 7), K.ch(8, am, 7)])
    static let chorusBed = big.merged(with: Pattern(bass: [NoteEvent(0, 41, 6), NoteEvent(8, 43, 6)],
                                                    chords: [K.ch(0, f, 3), K.ch(4, f, 3), K.ch(8, g, 3), K.ch(12, g, 3)]))
    static let verse = K.melody(verseLine, over: verseBed)
    static let chorus = K.melody(hook, over: chorusBed)
    static let preChorus = beat.merged(with: Pattern(bass: [NoteEvent(0, 38, 8), NoteEvent(8, 43, 8)],
                                                     chords: [K.ch(0, dm, 7), K.ch(8, gSus, 7)]))
    static let intro = Pattern(chords: [K.ch(0, c, 7), K.ch(8, am, 7)])
    static let bridge = Pattern(kick: [0, 8], clap: [12], bass: [NoteEvent(0, 45, 8), NoteEvent(8, 40, 8)],
                                chords: [K.ch(0, am, 7), K.ch(8, em, 7)])
    static let outro = Pattern(chords: [K.ch(0, c, 14)])
    static let finalChorus = K.melody(hook.map { NoteEvent($0.step, $0.pitch + 12, $0.length) }, over: chorusBed.merged(with: Pattern(perc: [3, 11])))
    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]

    static func sections() -> [OrderTile] {
        [K.tile("Intro", intro, "Chords alone"), K.tile("Verse", verse, "Quiet"), K.tile("Pre", preChorus, "Building"),
         K.tile("Chorus", chorus, "The hook"), K.tile("Bridge", bridge, "Something new"), K.tile("Outro", outro, "Ending")]
    }

    static let piano: [SoundParam: Double] = [.chordAttack: 0, .chordDecay: 0.65, .chordRelease: 0.4, .chordCutoff: 0.75]
    static let padSound: [SoundParam: Double] = [.chordAttack: 0.7, .chordDecay: 1, .chordRelease: 0.9, .chordCutoff: 0.45]
    static let pluck: [SoundParam: Double] = [.chordAttack: 0, .chordDecay: 0.12, .chordRelease: 0.1, .chordCutoff: 0.6]

    // MARK: - P1 · Songs Have Shapes

    static let p1 = K.unit("pop.p1", 1, "Songs Have Shapes", "Verse, chorus and the hook", [p11, p12, p13, p1b])

    static let p11 = K.lesson("pop.p1.1", "Chorus Finder", "Where the song peaks", "flag.fill", .arrangement, 20, [
        K.intro("Verse, then chorus",
                "Pop songs take turns. The verse tells the story and holds back. The chorus is the big moment everyone sings. You can hear the switch even without words.",
                [], demo: chorus),
        K.tapChanges("Tap when the chorus hits", "Verse, chorus, verse, chorus.", loops: [verse, chorus, verse, chorus], barsEach: 2,
                     label: "Chorus!"),
        K.quiz("Verse or chorus?", "Listen to two bars and call it.", [
            K.hear([verse], ["Verse", "Chorus"], 0, "Sparse, low melody, few drums.", bars: 2),
            K.hear([chorus], ["Verse", "Chorus"], 1, "Full drums, punchy chords, the hook up high.", bars: 2),
        ]),
        K.quiz("Quick check", "Two quick ones.", [
            K.ask("Which part usually has the song's title and hook?", ["Verse", "Chorus", "Intro"], 1),
            K.ask("Why does the verse hold back?", ["So the chorus feels bigger", "To save time", "Because of the lyrics"], 0),
        ]),
    ])

    static let p12 = K.lesson("pop.p1.2", "Hook Hunter", "Spot the repeat", "scope", .theory, 20, [
        K.intro("The hook comes back",
                "A hook is a short idea that keeps returning until it's stuck in your head. Pop songs bring it back again and again, sometimes on a new instrument.",
                [], demo: chorus),
        K.tapMoments("Tap when the hook starts", "Verse bars, then the hook. Tap at the start of each hook.",
                     loops: [verse, chorus, verse, chorus], barsEach: 1, at: [16, 48], label: "Hook!", unit: "hooks", sound: nil,
                     tolerance: 2, threshold: 0.99),
        K.quiz("Same hook?", "Is the second clip the same idea?", [
            K.hear([K.melody(hook), K.melody(hook)], ["Same", "Different"], 0),
            K.hear([K.melody(hook), K.melody(verseLine)], ["Same", "Different"], 1),
            K.hear([K.melody(hook), K.melody(hook, over: big)], ["Same hook", "New hook"], 0, "Same notes, now with drums under it."),
        ]),
    ])

    static let p13 = K.lesson("pop.p1.3", "Energy Painter", "Quiet and loud", "chart.xyaxis.line", .arrangement, 20, [
        K.intro("Draw the energy",
                "Picture a song as a line that goes up and down. Low in the verse, higher in the pre-chorus, highest in the chorus. Producers paint that line with layers.",
                [], demo: preChorus),
        K.arrange("Match the energy", "Verse low, pre-chorus higher, chorus highest.", .rule, sections: ["Verse", "Pre", "Chorus"],
                  lanes: lanes, loop: chorus, target: K.grid("xxx", "-xx", "--x", "xxx", "xxx")),
        K.tapChanges("Tap each rise", "Verse, pre-chorus, chorus. Tap the pad the moment the energy steps up.", loops: [verse, preChorus, chorus], barsEach: 2),
        K.quiz("Which has more energy?", "Two clips. Pick the bigger one.", [
            K.hear([verse, preChorus], ["The first", "The second"], 1, "The pre-chorus adds drums and a rising bass.", bars: 2),
            K.hear([chorus, verse], ["The first", "The second"], 0, bars: 2),
            K.hear([preChorus, chorus], ["The first", "The second"], 1, "The chorus is the peak.", bars: 2),
        ]),
    ])

    static let p1b = K.lesson("pop.p1.boss", "Songs Have Shapes Boss", "Boss: map a song", "crown.fill", .arrangement, 40, [
        K.intro("Boss: the shape", "Order the cards to match a reference song.", [], demo: chorus),
        K.order("Match the reference", "Verse, chorus, verse.", .recreate, tiles: sections(), answer: [1, 3, 1], barsEach: 2),
        K.order("A longer one", "Intro, verse, chorus, verse, chorus.", .rule, tiles: sections(), answer: [0, 1, 3, 1, 3], barsEach: 2),
        K.order("With an ending", "Intro, verse, chorus, verse, chorus, outro. Play the reference.", .recreate, tiles: sections(),
                answer: [0, 1, 3, 1, 3, 5], barsEach: 2),
    ])

    // MARK: - P2 · Chords That Support a Song

    static let p2 = K.unit("pop.p2", 2, "Chords That Support a Song", "Progressions, resolution and inversions", [p21, p22, p23, p2b])

    static let p21 = K.lesson("pop.p2.1", "Home, Away, Home", "Tension and resolution", "house.and.flag.fill", .theory, 20, [
        K.intro("Leave and come back",
                "C is home. F and Am wander away. G is the doorstep: it pulls you back to C. Every pop progression is a little trip from home and back.",
                [], demo: bar(g, 43, drums: beat)),
        K.quiz("Home or not?", "Does the last chord feel finished?", [
            K.round([f, g, c], ["Home", "Not yet"], 0),
            K.round([c, f, g], ["Home", "Not yet"], 1),
            K.round([am, f, g, c], ["Home", "Not yet"], 0),
            K.round([c, g, am], ["Home", "Not yet"], 1, "Am instead of C. A deceptive ending."),
        ]),
        K.order("Finish the trip", "End on the chord that feels like home.", .rule, tiles: chordTiles(), answer: [0, 3, 1, 0],
                start: [0, 3, 1], locked: [0, 1, 2]),
    ])

    static let p22 = K.lesson("pop.p2.2", "Progression Puzzle", "The four-chord loop", "puzzlepiece.fill", .theory, 20, [
        K.intro("Four chords",
                "C, G, Am, F. Those four chords in some order sit under a huge number of pop songs. The order changes the mood.",
                [], demo: bar(c, 36, drums: beat)),
        K.order("Build the loop", "C, G, Am, F.", .rule, tiles: chordTiles(), answer: [0, 1, 2, 3]),
        K.order("Copy this order", "Same four chords, new mood. Play the reference.", .recreate, tiles: chordTiles(), answer: [2, 3, 0, 1]),
        K.quiz("Which order is sadder?", "Same four chords, two orders.", [
            K.round([c, g, am, f] + [am, f, c, g], ["The first", "The second"], 1, "Starting on Am sounds more bittersweet."),
        ]),
    ])

    static let p23 = K.lesson("pop.p2.3", "Chord Twist", "Inversions", "arrow.triangle.swap", .theory, 20, [
        K.intro("Same chord, new bottom",
                "Put a different note of the chord at the bottom and you get an inversion. G with B at the bottom (G/B) steps smoothly from C to Am, and the bass walks instead of jumping.",
                [], demo: Pattern(bass: [NoteEvent(0, 36, 4), NoteEvent(4, 35, 4), NoteEvent(8, 33, 8)],
                                  chords: [K.ch(0, c, 4), K.ch(4, gOverB, 4), K.ch(8, am, 8)])),
        K.build("Build G over B", "B D G, with B at the bottom.", gOverB, low: 55, high: 72, exact: true),
        K.quiz("Walk or jump?", "Listen to the lowest note.", [
            K.round([ChordShape(name: "C", pitches: [36, 60, 64, 67]), ChordShape(name: "G/B", pitches: [35, 59, 62, 67]),
                     ChordShape(name: "Am", pitches: [33, 57, 60, 64])], ["Bass walks", "Bass jumps"], 0),
            K.round([ChordShape(name: "C", pitches: [36, 60, 64, 67]), ChordShape(name: "G", pitches: [43, 55, 59, 62]),
                     ChordShape(name: "Am", pitches: [33, 57, 60, 64])], ["Bass walks", "Bass jumps"], 1),
        ]),
        K.bassRule("Walk the bass", "C, B, A: a step at a time.", rows: [48, 47, 45, 43, 41, 36, 35, 33],
                   target: [NoteEvent(0, 36, 4), NoteEvent(4, 35, 4), NoteEvent(8, 33, 8)],
                   backing: Pattern(kick: [0, 8], clap: [4, 12], chords: [K.ch(0, c, 4), K.ch(4, gOverB, 4), K.ch(8, am, 8)])),
    ])

    static let p2b = K.lesson("pop.p2.boss", "Chords Boss", "Boss: verse and chorus chords", "crown.fill", .theory, 40, [
        K.intro("Boss: two progressions",
                "Verse and chorus usually use different progressions. The verse wanders, the chorus lands.", [], demo: chorus),
        K.order("Verse progression", "Am, F, C, G. It hangs at the end.", .rule, tiles: chordTiles(drums: soft), answer: [2, 3, 0, 1]),
        K.order("Chorus progression", "F, G, C, C. It lands home.", .rule, tiles: chordTiles(drums: big), answer: [3, 1, 0, 0]),
    ])

    // MARK: - P3 · Write the Hook

    static let p3 = K.unit("pop.p3", 3, "Write the Hook", "Motifs, surprises and lift", [p31, p32, p33, p3b])

    static let p31 = K.lesson("pop.p3.1", "Motif Machine", "Repeat with a twist", "gearshape.2.fill", .theory, 20, [
        K.intro("Say it, say it again, then twist",
                "The classic hook shape: a short motif, the same motif again, then a version with a new ending. Your brain expects the repeat, and the twist rewards it.",
                [], demo: chorus),
        K.leadRule("Write the motif", "Three notes: G, G, A.", rows: lead, target: K.tune([(0, 67, 2), (2, 67, 2), (4, 69, 4)]), backing: chorusBed),
        K.leadRule("Repeat, then twist", "Same three notes again, then end higher on C.", rows: lead,
                   target: K.tune([(0, 67, 2), (2, 67, 2), (4, 69, 4), (8, 67, 2), (10, 67, 2), (12, 72, 4)]), backing: chorusBed),
        K.quiz("Which has the twist?", "Listen to how each one ends.", [
            K.round(K.phrase([67, 67, 69, 67, 67, 69]), ["Repeat only", "Repeat with a twist"], 0),
            K.round(K.phrase([67, 67, 69, 67, 67, 72]), ["Repeat only", "Repeat with a twist"], 1),
        ]),
    ])

    static let p32 = K.lesson("pop.p3.2", "Hook Doctor", "Rhythm makes it stick", "stethoscope", .theory, 20, [
        K.intro("Pause for effect",
                "Often a hook isn't catchy because of its notes but because of its rhythm. Add a gap, push one note early, and a flat line suddenly grabs you.",
                [], demo: chorus),
        K.fixNotes("Add the pause", "The notes are fine. Move the last two later to leave a gap.", rows: lead,
                   broken: K.tune([(0, 67, 2), (2, 69, 2), (4, 72, 2), (6, 69, 2)]),
                   target: K.tune([(0, 67, 2), (2, 69, 2), (8, 72, 2), (10, 69, 4)]), backing: chorusBed, voice: .lead),
        K.quiz("Which one grabs you?", "Same notes, different rhythm.", [
            K.round(K.phrase([67, 69, 72, 69]), ["Flat", "Catchy"], 0, "Even notes, no gaps."),
            K.hear([K.melody(K.tune([(0, 67, 2), (2, 69, 2), (8, 72, 2), (10, 69, 4)]))], ["Flat", "Catchy"], 1, "The gap makes you lean in."),
        ]),
        K.leadMake("Your hook", "At least five notes, with a pause somewhere.", rows: lead, backing: chorusBed, notes: 5),
    ])

    static let p33 = K.lesson("pop.p3.3", "Melody Lift", "Higher for the chorus", "arrow.up.forward", .theory, 20, [
        K.intro("Go up for the chorus",
                "Choruses often sit higher than verses, with longer notes. It's the musical version of raising your voice.",
                [], demo: chorus),
        K.quiz("Verse or chorus melody?", "Low and chatty, or high and reaching?", [
            K.round(K.phrase([64, 64, 62, 60]), ["Verse", "Chorus"], 0, "Low and conversational."),
            K.round(K.phrase([67, 69, 72, 74]), ["Verse", "Chorus"], 1, "Higher and reaching."),
        ]),
        K.leadRule("Lift the motif", "Move the verse line up so it starts on G.", rows: lead,
                   target: K.tune([(0, 67, 2), (4, 67, 2), (6, 69, 2), (8, 72, 6)]), backing: chorusBed),
    ])

    static let p3b = K.lesson("pop.p3.boss", "Write the Hook Boss", "Boss: a four-bar hook", "crown.fill", .theory, 40, [
        K.intro("Boss: the hook", "Copy a hook, then write your own.", [], demo: chorus),
        K.leadCopy("Copy it", "Repeat, then twist.", rows: lead, target: hook, backing: chorusBed),
        K.leadMake("Your hook", "At least six notes. Repeat an idea and twist it.", rows: lead, backing: chorusBed, notes: 6),
    ])

    // MARK: - P4 · Layers That Matter

    static let p4 = K.unit("pop.p4", 4, "Layers That Matter", "Roles, lifts and transitions", [p41, p42, p43, p4b])

    static let p41 = K.lesson("pop.p4.1", "Instrument Draft", "One job each", "person.3.fill", .soundDesign, 20, [
        K.intro("Every part has a job",
                "Drums keep time. Bass holds the floor. Chords colour it in. The lead tells you what to sing. When two parts try to do the same job, the song gets muddy.",
                [], demo: chorus),
        K.order("Match the roles", "Tap each part and drop it on its job.", .rule,
                tiles: [K.tile("Lead", K.melody(hook)), K.tile("Drums", big), K.tile("Chords", Pattern(chords: chorusBed.chords)),
                        K.tile("Bass", Pattern(bass: chorusBed.bass))],
                answer: [1, 3, 2, 0], names: ["Keeps time", "Holds the floor", "Colours it", "What you sing"]),
        K.quiz("Which sound for the lead?", "Same hook, two sounds.", [
            K.sound(K.melody(hook, over: beat), pluck, ["Cuts through", "Blends in"], 0),
            K.sound(K.melody(hook, over: beat), padSound, ["Cuts through", "Blends in"], 1, "Pads are better for chords underneath."),
        ]),
    ])

    static let p42 = K.lesson("pop.p4.2", "Arrangement Tetris", "Add one, remove one", "square.grid.3x1.below.line.grid.1x2", .arrangement, 20, [
        K.intro("Fuller, not louder",
                "To make a chorus bigger, add a layer the verse didn't have. To keep it clear, take away anything that fights the hook.",
                [], demo: chorus),
        K.arrange("Add a layer for the chorus", "The chorus gets the snare and hats the verse didn't have.", .rule,
                  sections: ["Verse", "Chorus"], lanes: lanes, loop: chorus, target: K.grid("xx", "-x", "-x", "xx", "xx")),
        K.quiz("Which chorus is clearer?", "Can you hear the hook on top?", [
            K.faders(chorus, [.chords: 1, .drum(.hat): 1], ["Cluttered", "Clear"], 0),
            K.faders(chorus, [:], ["Cluttered", "Clear"], 1),
        ]),
    ])

    static let p43 = K.lesson("pop.p4.3", "Transition Lab", "Into the chorus", "arrow.right.circle.fill", .arrangement, 20, [
        K.intro("Launch the chorus",
                "A snare fill, a sudden drop-out, or both, right before the chorus. It's how pop songs say: here it comes.",
                [], demo: fill),
        K.order("Fill before the chorus", "Verse, verse, fill, chorus.", .rule,
                tiles: [K.tile("Verse", verse), K.tile("Fill", fill, "Snare roll"), K.tile("Chorus", chorus)], answer: [0, 0, 1, 2]),
        K.quiz("Does it launch?", "Listen to the moment before the chorus.", [
            K.hear([verse, fill, chorus], ["It launches", "It just changes"], 0),
            K.hear([verse, verse, chorus], ["It launches", "It just changes"], 1),
        ]),
    ])

    static let p4b = K.lesson("pop.p4.boss", "Layers Boss", "Boss: verse versus chorus", "crown.fill", .arrangement, 40, [
        K.intro("Boss: contrast", "A verse and a chorus that sound clearly different.", [], demo: chorus),
        K.arrange("Set the layers", "Verse sparse, chorus full.", .rule, sections: ["Verse", "Chorus", "Verse", "Chorus"], lanes: lanes,
                  loop: chorus, target: K.grid("xxxx", "-x-x", "-x-x", "xxxx", "xxxx")),
        K.mix("Bring out the hook", "The lead (on Chords) is buried. Lift it.", [.drum(.kick), .bass, .chords], start: [0.9, 0.9, 0.35],
              target: [K.u, 0.6, 0.75], loop: chorus),
    ])

    // MARK: - P5 · Tell a Musical Story

    static let p5 = K.unit("pop.p5", 5, "Tell a Musical Story", "Full structure, payoff and polish", [p51, p52, p53, p5b])

    static let p51 = K.lesson("pop.p5.1", "Song Architect", "Intro to outro", "building.2.fill", .arrangement, 20, [
        K.intro("Build the house",
                "Intro, verse, pre-chorus, chorus, then again, then an outro. The pre-chorus is a ramp: it builds tension so the chorus feels like a release.",
                [], demo: preChorus),
        K.order("Build it", "Intro, verse, pre, chorus, outro.", .rule, tiles: sections(), answer: [0, 1, 2, 3, 5], barsEach: 2),
        K.tapChanges("Tap every section", "Intro, verse, pre, chorus. Tap each time a new section starts.", loops: [intro, verse, preChorus, chorus], barsEach: 2),
        K.quiz("Name the section", "What job is this part doing?", [
            K.hear([intro], ["Intro", "Pre-chorus", "Outro"], 0, "Chords alone, easing you in.", bars: 2),
            K.hear([preChorus], ["Intro", "Pre-chorus", "Outro"], 1, "Building towards something.", bars: 2),
            K.hear([bridge], ["Bridge", "Verse"], 0, "New chords you haven't heard yet.", bars: 2),
        ]),
    ])

    static let p52 = K.lesson("pop.p5.2", "Second-Chorus Upgrade", "Make it new again", "plus.circle.fill", .arrangement, 20, [
        K.intro("Same chorus, bigger",
                "The second chorus can't be a copy. Add something: a higher melody, an extra percussion layer, a fuller beat. Small upgrades keep the song moving forward.",
                [], demo: finalChorus),
        K.quiz("Which is the upgraded chorus?", "Two choruses. One has extras.", [
            K.hear([chorus, finalChorus], ["The first", "The second"], 1, "The melody jumped up an octave and percussion joined."),
        ]),
        K.drumRule("Add percussion", "Rims on steps 4 and 12 for the second chorus.", tracks: [.kick, .clap, .hat, .openHat, .perc],
                   edit: [.perc], start: big, target: big.merged(with: Pattern(perc: [3, 11]))),
    ])

    static let p53 = K.lesson("pop.p5.3", "Mix Rescue", "The vocal-style lead on top", "lifepreserver.fill", .mixing, 20, [
        K.intro("The lead wins",
                "In pop, the lead line, usually the vocal, sits on top of everything. If you can't hear the hook clearly, nothing else matters.",
                [], demo: chorus),
        K.mix("Raise the hook", "The lead plays on Chords. Lift it above the bass and drums.", [.drum(.kick), .drum(.clap), .bass, .chords],
              start: [0.9, 0.9, 0.9, 0.3], target: [K.u, K.u, 0.6, 0.8], loop: chorus),
        K.quiz("Is the hook clear?", "Listen for the melody.", [
            K.faders(chorus, [.chords: 0.3], ["Buried", "Clear"], 0),
            K.faders(chorus, [.chords: 0.8, .bass: 0.55], ["Buried", "Clear"], 1),
        ]),
    ])

    static let p5b = K.lesson("pop.p5.boss", "Musical Story Boss", "Boss: the full song", "crown.fill", .arrangement, 40, [
        K.intro("Boss: the full song", "Verse, chorus, return and an ending.", [], demo: finalChorus),
        K.order("Map it", "Intro, verse, chorus, verse, chorus, outro.", .rule, tiles: sections(), answer: [0, 1, 3, 1, 3, 5], barsEach: 2),
        K.arrange("Set the layers", "Six sections, no two neighbours the same.", .create(.variedSections),
                  sections: ["Intro", "Verse", "Chorus", "Verse", "Chorus", "Outro"], lanes: lanes, loop: chorus),
    ])

    // MARK: - P6 · Song Project Finale

    static let p6 = K.unit("pop.p6", 6, "Song Project Finale", "Your first pop song", [p6l])

    static let p6l = K.lesson("pop.p6", "Song Project Finale", "Your pop song", "flag.checkered", .arrangement, 60, [
        K.intro("Your pop song",
                "Chords, a hook, verse and chorus contrast, and a map. Bronze guides you. Silver and Gold make it yours.", [], demo: chorus),
        K.order("The chords", "C, G, Am, F.", .rule, tiles: chordTiles(), answer: [0, 1, 2, 3]),
        K.leadRule("The hook", "Place the notes.", rows: lead, target: hook, backing: chorusBed),
        K.arrange("The contrast", "Verse sparse, chorus full.", .rule, sections: ["Verse", "Chorus"], lanes: lanes, loop: chorus,
                  target: K.grid("xx", "-x", "-x", "xx", "xx")),
        K.order("The map", "Intro, verse, chorus, verse, chorus, outro.", .rule, tiles: sections(), answer: [0, 1, 3, 1, 3, 5], barsEach: 2),
    ])

    // MARK: - Silver and Gold

    static let levels: [String: LevelPair] = [
        "pop.p1.1": (silver: [
            L.silver("Find it in a fuller song",
                     "Now the verse has drums too. The chorus still stands out. Find it."),
            K.tapChanges("Tap each chorus", "Verse, pre, chorus, verse, chorus.", loops: [verse, preChorus, chorus, verse, chorus], barsEach: 2,
                         label: "Change!"),
            K.quiz("Which part?", "Three options now.", [
                K.hear([preChorus], ["Verse", "Pre-chorus", "Chorus"], 1, "Building, but not there yet.", bars: 2),
                K.hear([chorus], ["Verse", "Pre-chorus", "Chorus"], 2, bars: 2),
                K.hear([verse], ["Verse", "Pre-chorus", "Chorus"], 0, bars: 2),
            ]),
        ], gold: [
            L.gold("Make a verse feel like a chorus",
                   "Take a quiet verse loop and change one thing so it feels like a chorus."),
            K.arrange("One change", "The verse is on the left. Make the right section feel like a chorus.", .create(.variedSections),
                      sections: ["Verse", "Chorus"], lanes: lanes, loop: chorus, start: K.grid("x-", "--", "x-", "x-", "x-")),
            L.make("Chorus drums", "Bigger than the verse: more kicks, snare on 2 and 4, open hat.", tracks: [.kick, .clap, .hat, .openHat],
                   edit: [.kick, .clap, .hat, .openHat], start: soft, goal: .atLeast(.kick, 3)),
        ]),
        "pop.p1.2": (silver: [
            L.silver("New instrument, same hook",
                     "Pop producers move the hook to different instruments. Recognise it anyway."),
            K.quiz("Same hook?", "Ignore the sound. Listen to the notes.", [
                K.hear([K.melody(hook)], ["Hook", "Not the hook"], 0, bars: 2, fx: EarFX(sound: pluck)),
                K.hear([K.melody(verseLine)], ["Hook", "Not the hook"], 1, bars: 2, fx: EarFX(sound: padSound)),
                K.hear([K.melody(hook)], ["Hook", "Not the hook"], 0, bars: 2, fx: EarFX(sound: padSound)),
            ]),
            K.tapMoments("Tap every hook", "Three hooks in six bars.", loops: [verse, chorus, chorus, verse, chorus, verse], barsEach: 1,
                         at: [16, 32, 64], label: "Hook!", unit: "hooks", sound: nil, tolerance: 2, threshold: 0.66),
        ], gold: [
            L.gold("Write a motif and move it", "Write a four-note motif, then hear it in a new context."),
            K.leadMake("Your motif", "At least four notes.", rows: lead, backing: verseBed, notes: 4),
            K.leadMake("Same idea, chorus", "Bring your motif back over the chorus. At least four notes.", rows: lead, backing: chorusBed, notes: 4),
        ]),
        "pop.p1.3": (silver: [
            L.silver("Map by ear", "Recreate the energy of a song you haven't heard."),
            K.arrange("Recreate it", "Four sections.", .recreate, sections: ["Intro", "Verse", "Pre", "Chorus"], lanes: lanes, loop: chorus,
                      target: K.grid("-xxx", "--xx", "--xx", "-xxx", "xxxx")),
            K.tapChanges("Tap each step up", "Five sections. Tap each change.", loops: [intro, verse, preChorus, chorus, outro], barsEach: 2),
        ], gold: [
            L.gold("Your energy curve", "Sketch three sections with a clear rise."),
            K.arrange("Your curve", "Three sections, rising.", .create(.variedSections), sections: ["Low", "Mid", "High"], lanes: lanes, loop: chorus),
            K.tapChanges("Feel a curve", "Tap each rise.", loops: [intro, verse, preChorus, chorus, outro], barsEach: 2),
        ]),
        "pop.p1.boss": (silver: [
            L.silver("Four parts", "A more detailed song from audio."),
            K.order("Rebuild it", "Four sections.", .recreate, tiles: sections(), answer: [1, 2, 3, 1], barsEach: 2),
            K.order("And a longer one", "Six sections, with a bridge.", .recreate, tiles: sections(), answer: [1, 3, 1, 3, 4, 3], barsEach: 2),
        ], gold: [
            L.gold("A different shape", "Same clips, a new structure."),
            K.order("Your structure", "Eight blocks.", .create(.variedSections), tiles: sections(), slots: 8, barsEach: 2),
        ]),
        "pop.p2.1": (silver: [
            L.silver("Resolution in context", "Choose the ending that resolves."),
            K.order("Which ending lands?", "Pick the last chord that resolves.", .rule, tiles: chordTiles(), answer: [2, 3, 1, 0],
                    start: [2, 3, 1], locked: [0, 1, 2]),
            K.quiz("Resolved?", "Does it land?", [
                K.round([dm, g, c], ["Resolved", "Unresolved"], 0),
                K.round([dm, g, am], ["Resolved", "Unresolved"], 1),
                K.round([f, c], ["Resolved", "Unresolved"], 0, "F to C is the gentle 'amen' ending."),
            ]),
        ], gold: [
            L.gold("Delay the payoff", "Make the listener wait for home."),
            K.order("Delay it", "Eight bars. Don't land on C until the very end.", .create(.chordsAtLeast(8)),
                    tiles: chordTiles() + [K.tile("Dm", bar(dm, 38, drums: beat)), K.tile("Em", bar(em, 40, drums: beat))], slots: 8),
        ]),
        "pop.p2.2": (silver: [
            L.silver("Reorder by ear", "One chord moved. Fix it."),
            K.order("Match the reference", "Play the reference, then put the chords in its order.", .recreate, tiles: chordTiles(), answer: [0, 2, 3, 1]),
            K.order("And this one", "A new order. Listen for where C lands.", .recreate, tiles: chordTiles(), answer: [3, 0, 1, 2]),
        ], gold: [
            L.gold("Two progressions, one palette", "Same four chords, two different moods."),
            K.order("Happy", "Four chords that feel bright. Try starting on C.", .create(.chordsAtLeast(4)), tiles: chordTiles(), slots: 4),
            K.order("Bittersweet", "Try starting on Am.", .create(.chordsAtLeast(4)), tiles: chordTiles(), slots: 4),
        ]),
        "pop.p2.3": (silver: [
            L.silver("Smooth bass", "Choose inversions that connect."),
            K.build("Build C over E", "E G C, with E at the bottom.", cOverE, low: 60, high: 76, exact: true),
            K.build("Build F over A", "A C F, with A at the bottom.", fOverA, low: 55, high: 69, exact: true),
            L.bass("Walk it", "C, E, F, G: the bass climbs.", [NoteEvent(0, 36, 4), NoteEvent(4, 40, 4), NoteEvent(8, 41, 4), NoteEvent(12, 43, 4)],
                   backing: Pattern(kick: [0, 8], clap: [4, 12], chords: [K.ch(0, c, 4), K.ch(4, cOverE, 4), K.ch(8, f, 4), K.ch(12, g, 4)]),
                   rows: rows),
        ], gold: [
            L.gold("Verse voicing, chorus voicing", "Low and close for the verse. High and open for the chorus."),
            K.lane("Verse chords", "Two chords, plain shapes.", .create(.chordsAtLeast(2)), palette: [c, am, f, g], backing: soft, length: 7),
            K.lane("Chorus chords", "Inversions sit higher.", .create(.chordsAtLeast(3)), palette: [cOverE, fOverA, gOverB, am], backing: big, length: 3),
        ]),
        "pop.p2.boss": (silver: [
            L.silver("Harmonic rhythm", "Change chords faster in the chorus than the verse."),
            K.lane("Chorus: two per bar", "F then G.", .recreate, palette: [c, g, am, f], backing: big, target: [0: 3, 8: 1], length: 7),
            K.lane("Verse: one per bar", "Am, held.", .recreate, palette: [c, g, am, f], backing: soft, target: [0: 2], length: 14),
        ], gold: [
            L.gold("Two beds, one hook", "Two chord beds that support the same hook differently."),
            K.lane("Bed 1", "Simple and soft under the hook.", .create(.chordsAtLeast(2)), palette: [c, g, am, f], backing: K.melody(hook, over: soft), length: 7),
            K.lane("Bed 2", "Busier, with inversions. Same hook on top.", .create(.chordsAtLeast(4)), palette: [cOverE, fOverA, gOverB, am, dm], backing: K.melody(hook, over: big), length: 3),
        ]),
        "pop.p3.1": (silver: [
            L.silver("Repair the motif", "One note in the twist is wrong."),
            K.fixNotes("Fix the twist", "The ending should jump higher.", rows: lead,
                       broken: K.tune([(0, 67, 2), (2, 67, 2), (4, 69, 4), (8, 67, 2), (10, 67, 2), (12, 69, 4)]),
                       target: K.tune([(0, 67, 2), (2, 67, 2), (4, 69, 4), (8, 67, 2), (10, 67, 2), (12, 72, 4)]), backing: chorusBed, voice: .lead),
            K.leadCopy("Copy a new motif", "Down, down, then a new ending.", rows: lead, target: K.tune([(0, 72, 2), (2, 71, 2), (4, 69, 4), (8, 72, 2), (10, 71, 2), (12, 67, 4)]),
                       backing: chorusBed),
        ], gold: [
            L.gold("Your repeat-with-a-twist", "Four bars."),
            K.leadMake("Your motif", "At least eight notes: motif, repeat, twist.", rows: lead, backing: chorusBed, notes: 8),
        ]),
        "pop.p3.2": (silver: [
            L.silver("Contour and repeat", "Match a reference hook."),
            K.leadCopy("Copy it", "It pauses in the middle.", rows: lead, target: K.tune([(0, 64, 2), (2, 67, 2), (8, 69, 2), (10, 67, 6)]),
                       backing: chorusBed),
            K.fixNotes("Push one early", "Move the C one step earlier so it lands before the beat.", rows: lead,
                       broken: K.tune([(0, 67, 2), (4, 69, 2), (8, 72, 4)]),
                       target: K.tune([(0, 67, 2), (4, 69, 2), (7, 72, 5)]), backing: chorusBed, voice: .lead),
        ], gold: [
            L.gold("Repetition plus surprise", "Repeat something so the listener expects it, then break the pattern once."),
            K.leadMake("Your hook", "At least six notes. One surprise.", rows: lead, backing: chorusBed, notes: 6),
            K.leadMake("Same hook, verse bed", "Bring it back quieter. At least four notes.", rows: lead, backing: verseBed, notes: 4),
        ]),
        "pop.p3.3": (silver: [
            L.silver("Shape verse and chorus", "Copy a low verse line, then a high chorus line."),
            K.leadCopy("Verse melody", "Low.", rows: lead, target: verseLine, backing: verseBed),
            K.leadCopy("Chorus melody", "High.", rows: lead, target: hook, backing: chorusBed),
        ], gold: [
            L.gold("Two phrases, one bed", "Contrast over the same chords."),
            K.leadMake("Low phrase", "Stay in the bottom half of the grid.", rows: lead, backing: chorusBed, notes: 4),
            K.leadMake("High phrase", "Now the top half. Hear the lift.", rows: lead, backing: chorusBed, notes: 4),
        ]),
        "pop.p3.boss": (silver: [
            L.silver("Repeat and vary", "Write a hook that repeats an idea and changes it."),
            K.leadCopy("Copy first", "A hook with a twist at the end.", rows: lead,
                       target: K.tune([(0, 72, 2), (2, 72, 2), (4, 74, 4), (8, 72, 2), (10, 72, 2), (12, 76, 4)]), backing: chorusBed),
            K.leadMake("Hook", "At least six notes with a repeat.", rows: lead, backing: chorusBed, notes: 6),
        ], gold: [
            L.gold("Hook and verse motif", "A chorus hook and a calmer verse line that fit together."),
            K.leadMake("Hook", "At least six notes.", rows: lead, backing: chorusBed, notes: 6),
            K.leadMake("Verse motif", "Lower and calmer. At least four notes.", rows: lead, backing: verseBed, notes: 4),
        ]),
        "pop.p4.1": (silver: [
            L.silver("Role collision", "Two parts fighting for the same job."),
            K.quiz("What's colliding?", "Listen for the part that gets in the way.", [
                K.sound(chorus, [.bassWave: 1, .bassCutoff: 1, .bassResonance: 0.8], ["Bass is too bright", "Chords are too dull"], 0,
                        "A buzzy bass competes with the lead."),
                K.sound(chorus, [.chordAttack: 0.9, .chordRelease: 1, .chordCutoff: 0.2], ["Bass is too bright", "Chords are too dull"], 1),
            ]),
            K.lab("Fix the bass", "Smooth the wave and close the filter so it stops fighting the lead.", [.bassWave, .bassCutoff], start: [1, 1], target: [0.2, 0.35], loop: chorus),
        ], gold: [
            L.gold("Your palette", "Four parts, four jobs."),
            K.lab("Bass", "Warm and low. It holds the floor.", [.bassWave, .bassCutoff, .bassDecay], start: [0.5, 0.5, 0.5], loop: chorus),
            K.lab("Chords and lead", "Short and bright so the hook pops.", [.chordAttack, .chordDecay, .chordCutoff], start: [0.5, 0.5, 0.5], loop: chorus),
            K.mix("Balance", "Set the levels so the hook sits on top.", [.drum(.kick), .drum(.clap), .bass, .chords], start: [K.u, K.u, K.u, K.u], loop: chorus),
        ]),
        "pop.p4.2": (silver: [
            L.silver("Remove a competitor", "The chorus gets bigger, but one part drops out to make room."),
            K.arrange("Copy it", "Listen for which part leaves in the chorus.", .recreate, sections: ["Verse", "Chorus"], lanes: lanes, loop: chorus, target: K.grid("xx", "-x", "x-", "xx", "xx")),
            K.quiz("What dropped out?", "Listen to the chorus.", [
                K.faders(chorus, [.drum(.hat): 0], ["Hats", "Bass"], 0),
                K.faders(chorus, [.bass: 0], ["Hats", "Bass"], 1),
            ]),
        ], gold: [
            L.gold("Three-stage lift", "Without just turning everything up."),
            K.arrange("Your lift", "Each section should feel bigger than the last, with no two the same.", .create(.variedSections), sections: ["Verse", "Pre", "Chorus"], lanes: lanes, loop: chorus),
            K.mix("Then balance it", "Fuller, but the hook stays on top.", [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords],
                  start: [K.u, K.u, K.u, K.u, K.u], loop: chorus),
        ]),
        "pop.p4.3": (silver: [
            L.silver("Matching energy", "Name the transition into each chorus."),
            K.quiz("Which transition?", "Fill, drop-out, or nothing.", [
                K.hear([verse, fill, chorus], ["Fill", "Drop-out", "None"], 0),
                K.hear([verse, Pattern(chords: [K.ch(0, gSus, 14)]), chorus], ["Fill", "Drop-out", "None"], 1),
                K.hear([verse, verse, chorus], ["Fill", "Drop-out", "None"], 2),
            ]),
        ], gold: [
            L.gold("Your fill and silence", "Write a fill, then place it and a gap before the chorus."),
            L.make("Your fill", "At least five snares.", tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], start: beat,
                   goal: .atLeast(.clap, 5)),
            K.order("Place it", "Six blocks. Use the fill or the silence to launch a chorus.", .create(.chordsAtLeast(6)),
                    tiles: [K.tile("Verse", verse), K.tile("Fill", fill), K.tile("Silence", Pattern()), K.tile("Chorus", chorus)], slots: 6),
        ]),
        "pop.p4.boss": (silver: [
            L.silver("Two edits", "Make the hook clear against the backing."),
            K.arrange("Thin the verse", "Copy the reference: the verse drops snare and hats.", .recreate, sections: ["Verse", "Chorus"],
                      lanes: lanes, loop: chorus, target: K.grid("xx", "-x", "-x", "xx", "xx")),
            K.mix("Clear the hook", "Bring the hats and bass down and the hook up.", [.drum(.kick), .drum(.hat), .bass, .chords], start: [0.9, 1, 0.9, 0.4], target: [K.u, 0.5, 0.6, 0.8],
                  loop: chorus),
        ], gold: [
            L.gold("Bigger without clutter", "A fuller chorus that still lets the hook through."),
            K.arrange("Verse and chorus", "Make them clearly different.", .create(.variedSections), sections: ["Verse", "Chorus"], lanes: lanes, loop: chorus),
            K.mix("Balance the chorus", "Hook on top, kick and bass solid underneath.", [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords], start: [K.u, K.u, K.u, K.u, K.u],
                  loop: chorus),
        ]),
        "pop.p5.1": (silver: [
            L.silver("Add a pre-chorus and return", "A ramp into the chorus, then back to the verse."),
            K.order("Rebuild it", "Play the reference. Six blocks.", .recreate, tiles: sections(), answer: [1, 2, 3, 1, 2, 3], barsEach: 2),
            K.tapChanges("Feel the ramp", "Tap each new section.", loops: [verse, preChorus, chorus, verse, preChorus, chorus], barsEach: 2),
        ], gold: [
            L.gold("Add a bridge", "Something new before the last chorus."),
            K.order("Your song", "Ten blocks with a bridge.", .create(.variedSections), tiles: sections(), slots: 10, barsEach: 2),
        ]),
        "pop.p5.2": (silver: [
            L.silver("Two upgrades", "Bigger drums and a higher hook for the last chorus."),
            K.drumRule("Bigger drums", "Add kicks on steps 11 and 15.", tracks: [.kick, .clap, .hat, .openHat], edit: [.kick], start: big,
                       target: Pattern(kick: [0, 6, 8, 10, 14], clap: [4, 12], hat: eighths, openHat: [14])),
            K.leadRule("Lift the hook an octave", "Same notes, twelve steps higher.", rows: [84, 81, 79, 76, 74, 72, 69, 67],
                       target: hook.map { NoteEvent($0.step, $0.pitch + 12, $0.length) }, backing: chorusBed),
        ], gold: [
            L.gold("Final chorus payoff", "Use melody, harmony and texture."),
            K.lane("Payoff chords", "Four chords under the big final hook.", .create(.chordsAtLeast(4)), palette: [c, g, am, f, cOverE, gOverB], backing: finalChorus, length: 3),
            K.arrange("The last three sections", "Bridge pulls back, chorus returns, final chorus goes biggest.", .create(.variedSections), sections: ["Bridge", "Chorus", "Final chorus"], lanes: lanes,
                      loop: finalChorus),
        ]),
        "pop.p5.3": (silver: [
            L.silver("Masking", "Reduce a clash with volume and tone."),
            K.mix("Fix it", "The bass is masking the hook. Pull it down.", [.drum(.kick), .bass, .chords], start: [K.u, 1, 0.8], target: [K.u, 0.55, 0.75], loop: chorus),
            K.lab("Darken the bass", "Close the filter so it stops crowding the top.", [.bassCutoff], start: [1], target: [0.3], loop: chorus),
        ], gold: [
            L.gold("Balance a whole arrangement", "Everything starts nearly silent. Build the mix up yourself."),
            K.mix("Your mix", "Kick and hook first, then the rest around them.", [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords], start: [0.1, 0.1, 0.1, 0.1, 0.1], loop: chorus),
            K.quiz("Spot the problem", "What's wrong with each mix?", [
                K.faders(chorus, [.bass: 1, .chords: 0.4], ["Bass too loud", "Hats too loud"], 0),
                K.faders(chorus, [.drum(.hat): 1, .chords: 0.5], ["Bass too loud", "Hats too loud"], 1),
            ]),
        ]),
        "pop.p5.boss": (silver: [
            L.silver("Pre-chorus or bridge", "Use at least one to give the song a new moment."),
            K.order("Your song", "Eight blocks. Include a pre-chorus or a bridge.", .create(.variedSections), tiles: sections(), slots: 8, barsEach: 2),
            K.mix("Polish the chorus", "Hook on top.", [.drum(.kick), .drum(.clap), .bass, .chords], start: [K.u, K.u, K.u, K.u], loop: chorus),
        ], gold: [
            L.gold("Your song arrangement", "Contrasting sections and a final lift."),
            K.order("Your song", "Twelve blocks. Save the final chorus for the end.", .create(.variedSections), tiles: sections() + [K.tile("Final", finalChorus, "Biggest")], slots: 12, barsEach: 2),
        ]),
        "pop.p6": (silver: [
            L.silver("Personalise it", "Verse and chorus contrast, variations and mix polish."),
            K.order("Your chords", "Any four chords you like.", .create(.chordsAtLeast(4)), tiles: chordTiles(), slots: 4),
            K.leadMake("Your hook", "At least six notes over your chorus.", rows: lead, backing: chorusBed, notes: 6),
            K.mix("Polish", "Hook on top, nothing buried.", [.drum(.kick), .drum(.clap), .bass, .chords], start: [K.u, K.u, K.u, K.u], loop: chorus),
        ], gold: [
            L.gold("Your pop song", "Hook, build, contrasting section and a final payoff."),
            K.order("Your chords", "Four chords. Dm is now on the table.", .create(.chordsAtLeast(4)), tiles: chordTiles() + [K.tile("Dm", bar(dm, 38, drums: beat))], slots: 4),
            K.leadMake("Your hook", "At least seven notes. Repeat an idea, then twist it.", rows: lead, backing: chorusBed, notes: 7),
            L.make("Your chorus drums", "At least three kicks. Add rims for extra lift.", tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc],
                   goal: .atLeast(.kick, 3)),
            K.order("Your map", "Fourteen blocks. End with the final chorus and an outro.", .create(.variedSections), tiles: sections() + [K.tile("Final", finalChorus)], slots: 14, barsEach: 2),
        ]),
    ]
}
