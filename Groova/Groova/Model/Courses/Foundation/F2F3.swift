//
//  F2F3.swift
//  Groova
//
//  Foundation F2, Pitch, Notes & Your Ear, and F3, Harmony, Chords & Bass.
//

import Foundation

nonisolated enum F2F3 {
    typealias F = FKit

    static let units: [Unit] = [f2, f3]

    /// Soft drums and a C to Am pad: a bed for melodies.
    static let bed = Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 6, 10, 14],
                             chords: [K.ch(0, F.c, 7), K.ch(8, F.am, 7)])
    static let bedFG = Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 6, 10, 14],
                               chords: [K.ch(0, F.f, 7), K.ch(8, F.g, 7)])
    static let bedNoDrums = Pattern(chords: [K.ch(0, F.c, 7), K.ch(8, F.am, 7)])
    /// Rows with one outside note, F sharp, for hearing what doesn't belong.
    static let outsideRows = [72, 69, 67, 66, 64, 62, 60]
    static let lowKeys = 55, highKeys = 74

    static let call = K.tune([(0, 60, 2), (2, 62, 2), (4, 64, 4)])
    static let echo5 = K.tune([(0, 64, 2), (2, 67, 2), (4, 69, 2), (6, 67, 2), (8, 64, 4)])

    static func held(_ c: ChordShape) -> Pattern { Pattern(chords: [K.ch(0, c, 14)]) }

    // MARK: - F2 · Pitch, Notes & Your Ear

    static let f2 = Unit(id: "f2", number: 2, title: "Pitch, Notes & Your Ear",
                         subtitle: "High and low, the keys, steps, scales and copying by ear",
                         lessons: F2Games.lessons, part: .foundations, code: "F")

    // MARK: - F3 · Harmony, Chords & Bass

    static let f3 = Unit(id: "f3", number: 3, title: "Harmony, Chords & Bass",
                         subtitle: "Triads, major and minor, progressions, bass and toplines",
                         lessons: [f31, f32, f33, f34, f35], part: .foundations, code: "F")

    static let f31 = K.lesson("f3.1", "Stack the Sound", "Build a triad", "square.stack.3d.up.fill", .theory, 15, [
        K.intro("Three notes, one chord",
                "Play every other white key, three times, and you've built a triad. The bottom note is the root and names the chord. The middle is the third. The top is the fifth.",
                [], demo: Pattern(chords: [K.ch(0, F.c, 6), K.ch(8, F.f, 6)])),
        K.build("Finish C major", "C is there. Skip a key and add E, skip another and add G.", F.c, start: [60]),
        K.build("Build F major", "Root F, then skip a key twice: F, A, C.", F.f),
        K.build("Build G major", "Same skip-skip shape from G.", F.g),
        K.quiz("Quick check", "", [
            K.ask("How many notes in a triad?", ["Two", "Three", "Four"], 1, "Three: root, third and fifth."),
            K.ask("Which note gives the chord its name?", ["The root", "The third", "The fifth"], 0, "The root, the bottom note."),
            K.round([ChordShape(name: "C5", pitches: [60, 67]), F.c], ["The first", "The second"], 1,
                    "The second has all three notes. The first is missing its third, so it sounds hollow.",
                    question: "Which one is a full triad?"),
        ]),
    ])

    static let f32 = K.lesson("f3.2", "Major and Minor", "One note changes the mood", "circle.lefthalf.filled", .theory, 15, [
        K.intro("The third decides",
                "Move the middle note of a triad down by one key, black keys included, and major becomes minor. Bright becomes moody. One note, a whole new feeling.",
                [], demo: Pattern(chords: [K.ch(0, F.c, 6), K.ch(8, F.cm, 6)])),
        K.build("Build C major", "Add E between C and G.", F.c, start: [60, 67]),
        K.build("Now C minor", "Same outside notes. Lower the middle one key, to the black key E flat.", F.cm, start: [60, 67]),
        K.quiz("Major or minor?", "Bright or moody?", [
            K.round([F.c], ["Major", "Minor"], 0),
            K.round([F.cm], ["Major", "Minor"], 1),
            K.round([F.f], ["Major", "Minor"], 0),
            K.round([F.fm], ["Major", "Minor"], 1),
            K.round([F.gm], ["Major", "Minor"], 1),
            K.round([F.g], ["Major", "Minor"], 0),
        ]),
    ])

    static let f33 = K.lesson("f3.3", "Chords Want to Move", "Home, away and back", "arrow.triangle.2.circlepath", .theory, 15, [
        K.intro("Home and away",
                "In a key, one chord feels like home. Here that's C. Other chords travel away and build tension, and G pulls hardest back home. Progressions are little trips away and back.",
                [], demo: F.chordBar(F.g, root: 43)),
        K.order("Rebuild the loop", "Play the reference, then tap the chords into the order you hear.", .recreate,
                tiles: [K.tile("C", F.chordBar(F.c, root: 36), "Home"), K.tile("F", F.chordBar(F.f, root: 41)),
                        K.tile("G", F.chordBar(F.g, root: 43), "Pulls home"), K.tile("Am", F.chordBar(F.am, root: 45))],
                answer: [0, 3, 1, 2]),
        K.quiz("Home or away?", "Does the last chord feel finished?", [
            K.round([F.f, F.g, F.c], ["Home", "Still away"], 0, "G pulls to C. Home."),
            K.round([F.c, F.am, F.g], ["Home", "Still away"], 1, "Ending on G leaves you leaning forward."),
            K.round([F.dm, F.g, F.c], ["Home", "Still away"], 0, "Dm, G, C: the classic way home."),
        ]),
        K.order("Your own trip", "Start at home on C. Choose three more chords and end wherever feels good to you.",
                .create(.chordsAtLeast(4)),
                tiles: [K.tile("C", F.chordBar(F.c, root: 36)), K.tile("Dm", F.chordBar(F.dm, root: 38)),
                        K.tile("Em", F.chordBar(F.em, root: 40)), K.tile("F", F.chordBar(F.f, root: 41)),
                        K.tile("G", F.chordBar(F.g, root: 43)), K.tile("Am", F.chordBar(F.am, root: 45))],
                slots: 4, start: [0], locked: [0]),
    ])

    static let f34 = K.lesson("f3.4", "Bass Gives It Weight", "Roots under chords", "waveform.path", .theory, 15, [
        K.intro("Bass plays the root",
                "Under every chord, the bass usually plays its root, the note the chord is named after, down low. It locks the harmony to the floor. Hear how much fuller the chords sound with it.",
                [], demo: Pattern(kick: [0, 8], clap: [4, 12], bass: [NoteEvent(0, 36, 7), NoteEvent(8, 45, 7)],
                                  chords: [K.ch(0, F.c, 7), K.ch(8, F.am, 7)])),
        K.bassRule("Roots under C and Am", "C for the first half, A for the second. Hold each one long.",
                   rows: F.bassRows, target: [NoteEvent(0, 36, 8), NoteEvent(8, 45, 8)], backing: bed),
        K.bassRule("Roots under F and G", "F, then G.",
                   rows: F.bassRows, target: [NoteEvent(0, 41, 8), NoteEvent(8, 43, 8)], backing: bedFG),
        K.quiz("Does the bass fit?", "Chords with a bass note. Is it the root?", [
            K.round([ChordShape(name: "C over C", pitches: [36, 60, 64, 67])], ["Fits", "Clashes"], 0, "C under C. Solid."),
            K.round([ChordShape(name: "C over B", pitches: [35, 60, 64, 67])], ["Fits", "Clashes"], 1, "B under C rubs hard."),
            K.round([ChordShape(name: "F over F", pitches: [41, 57, 60, 65])], ["Fits", "Clashes"], 0, "F under F."),
        ]),
    ])

    static let f35 = K.lesson("f3.5", "Topline Meets Harmony", "Boss: a melody over chords", "crown.fill", .theory, 30, [
        K.intro("Boss: melody meets chords",
                "A topline is the main melody on top. Notes from the chord underneath sound settled. Notes outside it add tension. Land on chord notes when you want to feel at rest.",
                [], demo: K.melody(K.tune([(0, 67, 4), (4, 64, 4), (8, 69, 4), (12, 72, 4)]), over: bed)),
        K.leadRule("Land on chord notes", "Over C, play G then E. Over Am, play A then C.",
                   rows: F.leadRows, target: K.tune([(0, 67, 4), (4, 64, 4), (8, 69, 4), (12, 72, 4)]), backing: bed),
        K.quiz("Settled or tense?", "A chord with one melody note on top.", [
            K.round([ChordShape(name: "C + E", pitches: [48, 60, 64, 67, 76])], ["Settled", "Tense"], 0, "E is in C major."),
            K.round([ChordShape(name: "C + F", pitches: [48, 60, 64, 67, 77])], ["Settled", "Tense"], 1, "F rubs against E. Tense."),
            K.round([ChordShape(name: "Am + A", pitches: [45, 57, 60, 64, 69])], ["Settled", "Tense"], 0, "A is the root of Am."),
            K.round([ChordShape(name: "Am + B", pitches: [45, 57, 60, 64, 71])], ["Settled", "Tense"], 1, "B adds a soft ache."),
        ]),
        K.leadMake("Write a topline", "At least four notes over the two chords. Try landing on a chord note at the start of each half.",
                   rows: F.leadRows, backing: bed, notes: 4),
    ])

    // MARK: - Silver and Gold

    static let levels: [String: LevelPair] = [
        "f3.1": (silver: [
            L.silver("Build by shape",
                     "The skip-a-key shape works from any white key. Some come out major, some minor. Build three new ones."),
            K.build("Build D minor", "D, F, A.", F.dm),
            K.build("Build A minor", "A, C, E.", F.am),
            K.build("Build E minor", "E, G, B.", F.em),
            K.quiz("Full or hollow?", "Is the chord complete?", [
                K.round([ChordShape(name: "G5", pitches: [55, 62])], ["Full triad", "Missing a note"], 1),
                K.round([F.am], ["Full triad", "Missing a note"], 0),
                K.round([ChordShape(name: "F5", pitches: [53, 60])], ["Full triad", "Missing a note"], 1),
            ]),
        ], gold: [
            L.gold("Two triads talking",
                   "A two-chord loop is the smallest progression there is, and plenty of hits use just that. Build two new triads, then write your own pair."),
            K.build("Build A major", "Same shape from A, but the middle note is the black key C sharp.", F.a),
            K.build("Build E major", "E, G sharp, B.", F.e),
            K.lane("Your two-chord loop", "Pick any two chords and place them. Swap them around until the pair feels right.",
                   .create(.chordsAtLeast(2)), palette: [F.c, F.dm, F.em, F.f, F.g, F.am], backing: F.beat, length: 6),
        ]),
        "f3.2": (silver: [
            L.silver("Flip it",
                     "Every chord has a major and a minor version. Hear the flip, then build it."),
            K.quiz("Which way did it flip?", "Two chords, same root.", [
                K.round([F.d, F.dm], ["Major to minor", "Minor to major"], 0),
                K.round([F.am, F.a], ["Major to minor", "Minor to major"], 1),
                K.round([F.gm, F.g], ["Major to minor", "Minor to major"], 1),
                K.round([F.e, F.em], ["Major to minor", "Minor to major"], 0),
            ]),
            K.build("Build D major", "Start from D minor and raise its middle note one key.", F.d, start: [57, 62]),
            K.build("Build F minor", "F major with the middle note lowered.", F.fm),
        ], gold: [
            L.gold("Darken the loop",
                   "Swap a major chord for its minor twin and a happy loop turns bittersweet. It's one of the easiest mood changes in music."),
            K.quiz("Bright, dark or both?", "Two chords play.", [
                K.round([F.c, F.g], ["Both bright", "Both dark", "One of each"], 0),
                K.round([F.cm, F.gm], ["Both bright", "Both dark", "One of each"], 1),
                K.round([F.c, F.fm], ["Both bright", "Both dark", "One of each"], 2, "F minor in a C major song. A famous bittersweet move."),
            ]),
            K.lane("Make it bittersweet", "Bright chords are loaded. Use at least one minor twin and four stabs in total.",
                   .create(.chordsAtLeast(4)), palette: [F.c, F.cm, F.f, F.fm, F.g, F.gm], backing: F.beat,
                   start: [0: 0, 4: 2, 8: 4, 12: 0], length: 3),
        ]),
        "f3.3": (silver: [
            L.silver("Hear the pull",
                     "You know G wants to go home. Now find it in fuller progressions, and fix one that stops short."),
            K.order("Rebuild a new loop", "Four chords. Listen for where home lands.", .recreate,
                    tiles: [K.tile("C", F.chordBar(F.c, root: 36)), K.tile("F", F.chordBar(F.f, root: 41)),
                            K.tile("G", F.chordBar(F.g, root: 43)), K.tile("Am", F.chordBar(F.am, root: 45))],
                    answer: [3, 1, 0, 2]),
            K.order("Finish it", "This progression stops short. Choose the chord that brings it home.", .rule,
                    tiles: [K.tile("C", F.chordBar(F.c, root: 36)), K.tile("F", F.chordBar(F.f, root: 41)),
                            K.tile("G", F.chordBar(F.g, root: 43)), K.tile("Am", F.chordBar(F.am, root: 45)),
                            K.tile("Em", F.chordBar(F.em, root: 40))],
                    answer: [0, 1, 2, 0], start: [0, 1, 2], locked: [0, 1, 2]),
            K.quiz("Which ending lands?", "", [
                K.round([F.am, F.f, F.g, F.c], ["Lands home", "Hangs"], 0),
                K.round([F.am, F.f, F.c, F.g], ["Lands home", "Hangs"], 1),
            ]),
        ], gold: [
            L.gold("Two endings",
                   "Songwriters often write the same progression twice with different endings: one that hangs, to keep you listening, and one that lands, to finish."),
            K.order("Ending 1: keep them hanging", "Same first three chords. Pick an ending that doesn't feel finished.",
                    .create(.chordsAtLeast(4)),
                    tiles: [K.tile("C", F.chordBar(F.c, root: 36)), K.tile("Am", F.chordBar(F.am, root: 45)),
                            K.tile("F", F.chordBar(F.f, root: 41)), K.tile("G", F.chordBar(F.g, root: 43)),
                            K.tile("Em", F.chordBar(F.em, root: 40)), K.tile("Dm", F.chordBar(F.dm, root: 38))],
                    slots: 4, start: [0, 1, 2], locked: [0, 1, 2]),
            K.order("Ending 2: land it", "Now an eight-chord version that finishes on home.",
                    .create(.chordsAtLeast(8)),
                    tiles: [K.tile("C", F.chordBar(F.c, root: 36)), K.tile("Am", F.chordBar(F.am, root: 45)),
                            K.tile("F", F.chordBar(F.f, root: 41)), K.tile("G", F.chordBar(F.g, root: 43)),
                            K.tile("Em", F.chordBar(F.em, root: 40)), K.tile("Dm", F.chordBar(F.dm, root: 38))],
                    slots: 8, start: [0, 1, 2, 3], locked: [0, 1, 2, 3]),
        ]),
        "f3.4": (silver: [
            L.silver("Roots by ear",
                     "No lit notes. Listen to each chord and find its lowest, most solid note."),
            K.bassCopy("Find the roots", "Two chords, half a bar each.", rows: F.bassRows,
                       target: [NoteEvent(0, 41, 8), NoteEvent(8, 36, 8)],
                       backing: Pattern(kick: [0, 8], clap: [4, 12], chords: [K.ch(0, F.f, 7), K.ch(8, F.c, 7)])),
            K.bassCopy("Roots with rhythm", "Same idea, but the bass bounces on each root.", rows: F.bassRows,
                       target: [NoteEvent(0, 36, 3), NoteEvent(3, 36), NoteEvent(6, 36, 2), NoteEvent(8, 45, 3),
                                NoteEvent(11, 45), NoteEvent(14, 45, 2)], backing: bed),
        ], gold: [
            L.gold("Connect the roots",
                   "A passing note walks the bass from one root to the next. It's a small touch that makes a bassline move instead of sitting still."),
            K.bassCopy("Hear the walk", "C, then a note that walks up into F.", rows: F.bassRows,
                       target: [NoteEvent(0, 36, 6), NoteEvent(6, 40, 2), NoteEvent(8, 41, 8)],
                       backing: Pattern(kick: [0, 8], clap: [4, 12], chords: [K.ch(0, F.c, 7), K.ch(8, F.f, 7)])),
            K.bassMake("Your bassline", "Roots on the chord changes, plus at least one passing note. Five notes or more.",
                       rows: F.bassRows, backing: bedFG, notes: 5),
        ]),
        "f3.5": (silver: [
            L.silver("Topline by ear",
                     "Copy a topline, then fix one that clashes with the chords."),
            K.leadCopy("Copy the topline", "It sits on chord notes.", rows: F.leadRows,
                       target: K.tune([(0, 64, 2), (2, 67, 2), (4, 64, 4), (8, 72, 2), (10, 69, 2), (12, 64, 4)]), backing: bed),
            K.fixNotes("Fix the clash", "One note fights the F chord. Move it to a chord note.", rows: F.leadRows,
                       broken: K.tune([(0, 69, 4), (4, 71, 4), (8, 67, 4), (12, 71, 4)]),
                       target: K.tune([(0, 69, 4), (4, 72, 4), (8, 67, 4), (12, 71, 4)]), backing: bedFG, voice: .lead),
        ], gold: [
            L.gold("Rest and tension",
                   "Great toplines lean into tension, then resolve. Land on chord notes at the start of each chord and use other notes to travel."),
            K.quiz("Settled or tense?", "", [
                K.round([ChordShape(name: "F + A", pitches: [41, 57, 60, 65, 69])], ["Settled", "Tense"], 0),
                K.round([ChordShape(name: "F + B", pitches: [41, 57, 60, 65, 71])], ["Settled", "Tense"], 1),
                K.round([ChordShape(name: "G + D", pitches: [43, 55, 59, 62, 74])], ["Settled", "Tense"], 0),
                K.round([ChordShape(name: "G + C", pitches: [43, 55, 59, 62, 72])], ["Settled", "Tense"], 1),
            ]),
            K.leadMake("Write a full topline", "At least eight notes over F and G. Land on a chord note on each change.",
                       rows: F.leadRows, backing: bedFG, notes: 8),
        ]),
    ]
}
