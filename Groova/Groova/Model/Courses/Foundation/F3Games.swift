//
//  F3Games.swift
//  Groova
//
//  F3, Harmony, Chords & Bass, in the Teach → Studio → Game flow:
//
//  F3.1 Stack the Sound        → Chord Lock         F3.2 Major and Minor     → Chord Impostor
//  F3.3 Chords Want to Move    → Resolution Run     F3.4 Bass Gives It Weight → Kick-Bass Tether
//  F3.5 Topline Meets Harmony  → Hook Hotline
//

import Foundation

nonisolated enum F3Games {
    typealias F = FKit

    static let playName = "Play Along"
    static let earName = "Quick Ear"
    static let lessons: [Lesson] = [f31, f32, f33, f34, f35]

    // MARK: Material

    static func held(_ c: ChordShape) -> Pattern { Pattern(chords: [K.ch(0, c, 14)]) }
    static func two(_ a: ChordShape, _ b: ChordShape) -> Pattern { Pattern(chords: [K.ch(0, a, 7), K.ch(8, b, 7)]) }
    static func four(_ a: ChordShape, _ b: ChordShape, _ c: ChordShape, _ d: ChordShape) -> Pattern {
        Pattern(chords: [K.ch(0, a, 3), K.ch(4, b, 3), K.ch(8, c, 3), K.ch(12, d, 3)])
    }
    static func line(_ n: [(Int, Int, Int)], over base: Pattern) -> Pattern { K.melody(K.tune(n), over: base) }

    static let rows = F.leadRows
    static let pads = NoteSurface.pads([60, 62, 64, 67, 69])
    static let bandCAm = Pattern(kick: [0, 8], hat: F.offbeats, chords: [K.ch(0, F.c, 7), K.ch(8, F.am, 7)])
    static let bandCF = Pattern(kick: [0, 8], hat: F.offbeats, chords: [K.ch(0, F.c, 7), K.ch(8, F.f, 7)])
    static let kickChordC = Pattern(kick: F.quarters, chords: [K.ch(0, F.c, 14)])

    // MARK: - F3.1 Stack the Sound → Chord Lock

    static let lockName = "Chord Lock"
    static let lockLine = "Three beams, one lock. Slide them until the harmony clicks."

    static let f31 = K.lesson("f3.1", "Stack the Sound", "Build a triad", "square.stack.3d.up.fill", .theory, 15, [
        K.opening("Notes that sound as one",
                  "A chord is what happens when several notes sound together as one shape. First you'll stack C, E and G as a real chord. Then you'll hear chords and count their notes."),
        K.teach("One note, then three",
                "First a single C. Then C, E and G together. Root, third and fifth: three notes that ring as one chord, a triad.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [60], length: 6), K.ch(8, F.c, 7)])),
        K.build("Stack C major", "C is in. Add E and G above it and hear the chord fill out.", F.c, start: [60]),
        K.game(earName, "One, two or three notes?", .quickEar(.noteCount("f3.1"))),
    ])

    static let f31Silver: [LessonStep] = [
        L.silver("Unlock by listening",
                 "The chord's shape isn't shown any more. First repair a chord with a missing note. Then you'll count chord notes, twelve in a row."),
        K.teach("Move one note, change the colour",
                "Hear G major, then the same chord with one note nudged. The other two stay put, but the whole chord feels different.",
                demo: Pattern(chords: [K.ch(0, F.g, 6), ChordEvent(step: 8, pitches: [55, 58, 62], length: 6)])),
        K.build("Repair F major", "Two of F major's notes are in. Find the one that's missing.", F.f, start: [60, 65]),
        K.game(earName, "Twelve chords.", .quickEar(.noteCount("f3.1s", count: 12))),
    ]

    static let f31Gold: [LessonStep] = [
        L.gold("Design a harmonic shape",
               "One chord can take several shapes and stay the same chord. First build a second voicing of C. Then you'll count chord notes, fifteen in a row."),
        K.teach("Same chord, new shape",
                "C, E, G. Then E, G and C on top. The same three notes, stacked differently. That's a voicing.",
                demo: Pattern(chords: [K.ch(0, F.c, 6), ChordEvent(step: 8, pitches: [64, 67, 72], length: 6)])),
        K.build("Build E, G, high C", "Same C major, new shape: move the C to the top.",
                ChordShape(name: "C", pitches: [64, 67, 72]), start: [64, 67], low: 60, high: 74, exact: true),
        K.game(earName, "Fifteen chords.", .quickEar(.noteCount("f3.1g", count: 15))),
    ]

    // MARK: - F3.2 Major and Minor → Chord Impostor

    static let impostorName = "Chord Impostor"
    static let impostorLine = "A shell game for your ears. Catch the odd third."

    static let f32 = K.lesson("f3.2", "Major and Minor", "One note changes the mood", "circle.lefthalf.filled", .theory, 15, [
        K.opening("One note, a new colour",
                  "Changing one note can turn a major chord into a minor one. First you'll move that note in a real chord. Then you'll hear chords and call major or minor."),
        K.teach("The third decides",
                "C major, then C minor. C and G stay. Only the middle note drops one step, from E to E flat.",
                demo: Pattern(chords: [K.ch(0, F.c, 6), K.ch(8, F.cm, 6)])),
        K.build("Drop the third", "C and G are in. Put E flat, the black key, in the middle to make C minor.", F.cm, start: [60, 67]),
        K.game(earName, "Happy or sad? Major or minor.", .quickEar(.majorMinor("f3.2"))),
    ])

    static let f32Silver: [LessonStep] = [
        L.silver("Hear beyond one root",
                 "Now the chords don't all start on the same note. First build D minor. Then you'll call major or minor when the notes are played one at a time."),
        K.teach("Any root works",
                "D major, then D minor. Same trick on a new root: only the middle note moves.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [62, 66, 69], length: 6), ChordEvent(step: 8, pitches: [62, 65, 69], length: 6)])),
        K.build("Build D minor", "D and A are locked in. Choose the middle note that makes it minor.",
                ChordShape(name: "Dm", pitches: [62, 65, 69]), start: [62, 69], low: 60, high: 72),
        K.game(earName, "The notes come one at a time now.", .quickEar(.majorMinor("f3.2s", count: 12, arpeggio: true))),
    ]

    static let f32Gold: [LessonStep] = [
        L.gold("Make your own fake-out",
               "Use the one-note switch to surprise someone. First plant a minor twist in a chord lane. Then you'll call major or minor, fifteen in a row."),
        K.teach("A flavour, not a rule",
                "C, F, G, C. Then C, F minor, G, C. Borrowing that one minor chord is a classic twist. It's a choice, not a mistake.",
                demo: Pattern(chords: [K.ch(0, F.c, 3), K.ch(4, F.f, 3), K.ch(8, F.fm, 3), K.ch(12, F.c, 3)])),
        K.lane("Plant a twist", "Four chords are in. Swap one for its minor twin and hear the turn.",
               .create(.chordsAtLeast(4)), palette: [F.c, F.cm, F.f, F.fm, F.g, F.gm], backing: F.beat,
               start: [0: 0, 4: 2, 8: 4, 12: 0], length: 3),
        K.game(earName, "Fifteen in a row.", .quickEar(.majorMinor("f3.2g", count: 15, arpeggio: true))),
    ]

    // MARK: - F3.3 Chords Want to Move → Resolution Run

    static let runName = "Resolution Run"
    static let runLine = "The gate opens for the chord that brings the music home."

    static let f33 = K.lesson("f3.3", "Chords Want to Move", "Home, away and back", "arrow.triangle.2.circlepath", .theory, 15, [
        K.opening("Questions and answers",
                  "Some chord changes feel like a question and others like the answer. First you'll build a four-chord route in a chord lane. Then you'll hear chord routes and call whether they landed home."),
        K.teach("G pulls to C",
                "Hear G7, then C. That stretch and release is the strongest pull in a key: away, then home.",
                demo: Pattern(bass: [NoteEvent(0, 43, 6), NoteEvent(8, 36, 6)], chords: [K.ch(0, F.g7, 6), K.ch(8, F.c, 6)])),
        K.lane("Build C, F, G7, C", "One chord per beat: C, then F, then G7, then back to C.", .rule,
               palette: [F.c, F.f, F.g7], backing: F.beatNoHats, target: [0: 0, 4: 1, 8: 2, 12: 0], length: 3),
        K.game(earName, "Did the chords come home?", .quickEar(.homeAway("f3.3"))),
    ])

    static let f33Silver: [LessonStep] = [
        L.silver("Predict and repair motion",
                 "This time the destination isn't shown. First fill a missing chord in a chord lane. Then you'll call home or away, twelve in a row."),
        K.teach("Context decides",
                "Two routes. One ends on G and hangs there. The other comes back to C and rests. Same chords, different endings.",
                demo: four(F.c, F.am, F.f, F.g)),
        K.lane("Fill the gap", "C, Am, ?, G. Play the reference and choose the third chord.", .recreate,
               palette: [F.c, F.am, F.f, F.g, F.dm], backing: F.beatNoHats,
               start: [0: 0, 4: 1, 12: 3], target: [0: 0, 4: 1, 8: 2, 12: 3], length: 3),
        K.game(earName, "Twelve routes.", .quickEar(.homeAway("f3.3s", count: 12))),
    ]

    static let f33Gold: [LessonStep] = [
        L.gold("Build a tiny harmonic story",
               "Build a short story with anticipation and arrival. First write a four-chord route. Then you'll call home or away, fifteen in a row."),
        K.teach("A small palette is enough",
                "C, Am, F, G and Dm are enough for hundreds of songs. The order is what makes the story.",
                demo: four(F.am, F.f, F.c, F.g)),
        K.lane("Write a four-chord story", "Four chords from the palette. End wherever you like.", .create(.chordsAtLeast(4)),
               palette: [F.c, F.am, F.f, F.g, F.dm], backing: F.beatNoHats, length: 3),
        K.game(earName, "Fifteen routes.", .quickEar(.homeAway("f3.3g", count: 15))),
    ]

    // MARK: - F3.4 Bass Gives It Weight → Kick-Bass Tether

    static let tetherName = "Kick-Bass Tether"
    static let tetherLine = "Kick and bass on one elastic line. Feel them pull."

    static let f34 = K.lesson("f3.4", "Bass Gives It Weight", "Roots under chords", "waveform.path", .theory, 15, [
        K.opening("The low end is shared",
                  "Bass gives harmony weight, but it has to share the low end with the kick. First you'll line up a bass with a kick in the piano roll. Then you'll play the bass roots along with the drums."),
        K.teach("Together, then between",
                "Kick and bass on the same beats sound like one big thump. Move the bass between the kicks and they start talking to each other.",
                demo: Pattern(kick: F.quarters, bass: [NoteEvent(0, 36, 2), NoteEvent(6, 36, 2), NoteEvent(8, 36, 2), NoteEvent(14, 36, 2)])),
        K.bassRule("Bass on the root", "Kicks are on every beat. Put C on step 1 and on step 7, the \"and\" after beat 2.",
                   rows: F.bassRows, target: [NoteEvent(0, 36, 2), NoteEvent(6, 36, 2)], backing: kickChordC),
        K.game(playName, "Play the roots: C, F, G, C.", .playAlong(PlayAlongConfig(groove: Pattern(kick: F.quarters, hat: F.offbeats), bars: 8, bpm: 84, keys: [36, 41, 43], melody: [NoteEvent(0, 36), NoteEvent(8, 36), NoteEvent(16, 41), NoteEvent(24, 41), NoteEvent(32, 43), NoteEvent(40, 43), NoteEvent(48, 36), NoteEvent(56, 36)]))),
    ])

    static let f34Silver: [LessonStep] = [
        L.silver("Match a groove",
                 "A bassline can fit the chords and still fight the kick. First copy a bass rhythm in the piano roll. Then you'll play a four-chord bassline, the last bars by feel."),
        K.teach("Roots and room",
                "The bass follows the chord's root as it changes, and a shorter note leaves space for the next kick.",
                demo: Pattern(kick: F.quarters, bass: [NoteEvent(0, 36, 3), NoteEvent(6, 36, 2), NoteEvent(16 - 4, 36, 2)],
                              chords: [K.ch(0, F.c, 14)])),
        K.bassCopy("Copy the bass rhythm", "Three hits on C: beat 1, the \"and\" of 2, and beat 4.",
                   rows: F.bassRows, target: [NoteEvent(0, 36, 2), NoteEvent(6, 36, 2), NoteEvent(12, 36, 2)], backing: kickChordC),
        K.game(playName, "C, G, A, F. Later by feel.", .playAlong(PlayAlongConfig(groove: Pattern(kick: F.quarters, hat: F.offbeats), bars: 8, bpm: 88, ghostFrom: 5, keys: [36, 41, 43, 45], melody: [NoteEvent(0, 36), NoteEvent(8, 36), NoteEvent(16, 43), NoteEvent(24, 43), NoteEvent(32, 45), NoteEvent(40, 45), NoteEvent(48, 41), NoteEvent(56, 41)]))),
    ]

    static let f34Gold: [LessonStep] = [
        L.gold("Play a bass response",
               "Now you play the part that holds the track together. First write a bassline of your own. Then you'll play a bassline with pickups, the last bars by feel."),
        K.teach("No single right answer",
                "Some basslines sit with the kick, some dodge it. A good one follows the chords, leaves space and has a little movement.",
                demo: Pattern(kick: F.quarters, bass: [NoteEvent(0, 36, 3), NoteEvent(6, 43, 2), NoteEvent(10, 36, 2), NoteEvent(14, 48, 2)],
                              chords: [K.ch(0, F.c, 14)])),
        K.bassMake("Write a bass response", "At least four notes over the kick. Use the root and slip one note between the beats.",
                   rows: F.bassRows, backing: kickChordC, notes: 4),
        K.game(playName, "A pushier bassline with pickups.", .playAlong(PlayAlongConfig(groove: Pattern(kick: F.quarters, hat: F.offbeats), bars: 8, bpm: 90, ghostFrom: 5, keys: [36, 41, 43, 45], melody: [NoteEvent(0, 36), NoteEvent(3, 36), NoteEvent(8, 36), NoteEvent(16, 43), NoteEvent(19, 43), NoteEvent(24, 43), NoteEvent(32, 45), NoteEvent(35, 45), NoteEvent(40, 45), NoteEvent(48, 41), NoteEvent(51, 41), NoteEvent(56, 41)]))),
    ]

    // MARK: - F3.5 Topline Meets Harmony → Hook Hotline

    static let hookName = "Hook Hotline"
    static let hookLine = "The band calls. You answer on five glowing pads."

    static let f35 = K.lesson("f3.5", "Topline Meets Harmony", "Boss: a melody over chords", "crown.fill", .theory, 30, [
        K.opening("A hook talks to the chords",
                  "A memorable hook feels like a conversation with the chords under it. First you'll write a short melody over a chord. Then you'll play a hook over the chords as the notes fall."),
        K.teach("Settled or leaning",
                "E, G, E over C feels settled. Change the last note to D and it leans, like it wants to keep going.",
                demo: line([(0, 64, 2), (2, 67, 2), (4, 64, 4), (8, 64, 2), (10, 67, 2), (12, 62, 4)], over: held(F.c))),
        K.leadRule("Change the landing", "E, G, E over C. Move the last note down to D and hear it lean.",
                   rows: rows, target: K.tune([(0, 64, 4), (4, 67, 4), (8, 62, 8)]), backing: held(F.c),
                   start: K.tune([(0, 64, 4), (4, 67, 4), (8, 64, 8)])),
        K.game(playName, "Play the hook over the chords.", .playAlong(PlayAlongConfig(groove: bandCAm, bars: 8, bpm: 84, keys: [60, 62, 64, 67, 69], melody: [NoteEvent(0, 64), NoteEvent(2, 64), NoteEvent(4, 67), NoteEvent(8, 69), NoteEvent(12, 67), NoteEvent(16, 64), NoteEvent(20, 62), NoteEvent(24, 60)]))),
    ])

    static let f35Silver: [LessonStep] = [
        L.silver("Make the line move",
                 "Your answers have to follow the chords as they change. First fix a topline's ending over F. Then you'll play the hook and keep it going from memory."),
        K.teach("Same start, new ending",
                "A hook can keep its opening and change only its last note to fit the next chord.",
                demo: line([(0, 64, 2), (2, 67, 2), (4, 64, 4), (8, 64, 2), (10, 67, 2), (12, 69, 4)], over: two(F.c, F.f))),
        K.leadCopy("Fit the F chord", "The first three notes are in. Play the reference and choose the last note over F.",
                   rows: rows, target: K.tune([(0, 64, 2), (2, 67, 2), (4, 64, 4), (8, 69, 8)]), backing: two(F.c, F.f),
                   start: K.tune([(0, 64, 2), (2, 67, 2), (4, 64, 4)])),
        K.game(playName, "Same hook. Later from memory.", .playAlong(PlayAlongConfig(groove: bandCAm, bars: 8, bpm: 88, ghostFrom: 5, keys: [60, 62, 64, 67, 69], melody: [NoteEvent(0, 64), NoteEvent(2, 64), NoteEvent(4, 67), NoteEvent(8, 69), NoteEvent(12, 67), NoteEvent(16, 64), NoteEvent(20, 62), NoteEvent(24, 60)]))),
    ]

    static let f35Gold: [LessonStep] = [
        L.gold("Write a hook",
               "Time to write your own hook. First write a call and answer in the piano roll. Then you'll play a busier hook, the last bars from memory."),
        K.teach("Repeat to remember",
                "Repeat part of the hook and people will remember it, even if the ending changes.",
                demo: line([(0, 64, 2), (2, 67, 2), (4, 69, 4), (8, 64, 2), (10, 67, 2), (12, 64, 4)], over: two(F.c, F.f))),
        K.leadMake("Write a call and answer", "Six notes or more over C and F. Repeat your opening in the second half.",
                   rows: rows, backing: two(F.c, F.f), notes: 6),
        K.game(playName, "A busier hook, then from memory.", .playAlong(PlayAlongConfig(groove: bandCAm, bars: 8, bpm: 88, ghostFrom: 5, keys: [60, 62, 64, 67, 69], melody: [NoteEvent(0, 64), NoteEvent(2, 67), NoteEvent(4, 69), NoteEvent(6, 67), NoteEvent(8, 64), NoteEvent(10, 62), NoteEvent(12, 60), NoteEvent(16, 62), NoteEvent(18, 64), NoteEvent(20, 67), NoteEvent(24, 64), NoteEvent(28, 60)]))),
    ]

    static let levels: [String: LevelPair] = [
        "f3.1": (silver: f31Silver, gold: f31Gold),
        "f3.2": (silver: f32Silver, gold: f32Gold),
        "f3.3": (silver: f33Silver, gold: f33Gold),
        "f3.4": (silver: f34Silver, gold: f34Gold),
        "f3.5": (silver: f35Silver, gold: f35Gold),
    ]
}
