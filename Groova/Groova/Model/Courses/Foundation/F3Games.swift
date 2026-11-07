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
                  "A chord is what happens when several notes sound together as one shape. First you'll stack C, E and G as a real chord. Then you'll slide three glowing beams until a chord lock clicks open."),
        K.teach("One note, then three",
                "First a single C. Then C, E and G together. Root, third and fifth: three notes that ring as one chord, a triad.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [60], length: 6), K.ch(8, F.c, 7)])),
        K.build("Stack C major", "C is in. Add E and G above it and hear the chord fill out.", F.c, start: [60]),
        K.game(lockName, lockLine, .chordLock([
            LockRound(title: "One beam versus three", body: "Hear one beam on its own. Then reveal the other two and hear them as one sound.",
                      mode: .reveal(.c)),
            LockRound(title: "Build a shown shape", body: "C is locked at the bottom. Slide the other two beams into the dashed outlines.",
                      mode: .build(.c, locked: [true, false, false], ghost: true)),
            LockRound(title: "Fill the missing voice", body: "C and G are in. Find the middle note by ear until the lock opens.",
                      mode: .build(.c, locked: [true, false, true], ghost: false)),
        ])),
    ])

    static let f31Silver: [LessonStep] = [
        L.silver("Unlock by listening",
                 "The chord's shape isn't shown any more. First repair a chord with a missing note. Then find a beam that's out of place, build A minor blind, and open three locks in a row."),
        K.teach("Move one note, change the colour",
                "Hear G major, then the same chord with one note nudged. The other two stay put, but the whole chord feels different.",
                demo: Pattern(chords: [K.ch(0, F.g, 6), ChordEvent(step: 8, pitches: [55, 58, 62], length: 6)])),
        K.build("Repair F major", "Two of F major's notes are in. Find the one that's missing.", F.f, start: [60, 65]),
        K.game(lockName, lockLine, .chordLock([
            LockRound(title: "Find the shifted voice", body: "One beam is a little off from G major. Hear the target, tap the wrong beam, then slide it home.",
                      mode: .wrongBeam(.g, wrong: 1, by: -1)),
            LockRound(title: "Blind construction", body: "Only the root, A, is locked. Build A minor by ear. Compare with the target whenever you like.",
                      mode: .build(.am, locked: [true, false, false], ghost: false)),
            LockRound(title: "Three locks in a row", body: "C, then F, then G. Each is missing one note. Open all three and hear them as a progression.",
                      mode: .chain([.c, .f, .g], missing: [1, 2, 0])),
        ])),
    ]

    static let f31Gold: [LessonStep] = [
        L.gold("Design a harmonic shape",
               "One chord can take several shapes and stay the same chord. First build a second voicing of C. Then build a chord of your own, reshape it, and keep the version you like."),
        K.teach("Same chord, new shape",
                "C, E, G. Then E, G and C on top. The same three notes, stacked differently. That's a voicing.",
                demo: Pattern(chords: [K.ch(0, F.c, 6), ChordEvent(step: 8, pitches: [64, 67, 72], length: 6)])),
        K.build("Build E, G, high C", "Same C major, new shape: move the C to the top.",
                ChordShape(name: "C", pitches: [64, 67, 72]), start: [64, 67], low: 60, high: 74, exact: true),
        K.game(lockName, "Your chord, your shape.", .chordLock([
            LockRound(title: "Choose a root", body: "Pick C, F or A, and major or minor. Then slide the beams to build it.",
                      mode: .voicing),
            LockRound(title: "Make a second voicing", body: "Move one beam up or down a whole octave. Same notes, different shape.",
                      mode: .revoice),
            LockRound(title: "Save your harmonic fingerprint", body: "Both shapes alternate over a gentle pulse. Keep the one you like.",
                      mode: .alternate),
        ])),
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
                  "Bass gives harmony weight, but it has to share the low end with the kick. First you'll line up a bass with a kick in the piano roll. Then you'll stretch an elastic tether between them and hear the groove change."),
        K.teach("Together, then between",
                "Kick and bass on the same beats sound like one big thump. Move the bass between the kicks and they start talking to each other.",
                demo: Pattern(kick: F.quarters, bass: [NoteEvent(0, 36, 2), NoteEvent(6, 36, 2), NoteEvent(8, 36, 2), NoteEvent(14, 36, 2)])),
        K.bassRule("Bass on the root", "Kicks are on every beat. Put C on step 1 and on step 7, the \"and\" after beat 2.",
                   rows: F.bassRows, target: [NoteEvent(0, 36, 2), NoteEvent(6, 36, 2)], backing: kickChordC),
        K.game(tetherName, tetherLine, .tether([
            TetherRound(title: "Hear the foundation", body: "Kick and bass land together. Watch the tethers stay tight and gold.",
                        mode: .together),
            TetherRound(title: "Move the bass between kicks", body: "Drag the second bass note half a beat earlier, between the kicks. Compare locked and offset.",
                        mode: .slide(from: 8, to: 6)),
            TetherRound(title: "Follow the harmony", body: "C, then F. Drag each bar's bass up or down to its chord's root, the gold outline.",
                        mode: .roots, chords: [.c, .f]),
        ])),
    ])

    static let f34Silver: [LessonStep] = [
        L.silver("Match a groove",
                 "A bassline can fit the chords and still fight the kick. First copy a bass rhythm in the piano roll. Then match a groove, follow roots, and shorten notes to make room."),
        K.teach("Roots and room",
                "The bass follows the chord's root as it changes, and a shorter note leaves space for the next kick.",
                demo: Pattern(kick: F.quarters, bass: [NoteEvent(0, 36, 3), NoteEvent(6, 36, 2), NoteEvent(16 - 4, 36, 2)],
                              chords: [K.ch(0, F.c, 14)])),
        K.bassCopy("Copy the bass rhythm", "Three hits on C: beat 1, the \"and\" of 2, and beat 4.",
                   rows: F.bassRows, target: [NoteEvent(0, 36, 2), NoteEvent(6, 36, 2), NoteEvent(12, 36, 2)], backing: kickChordC),
        K.game(tetherName, tetherLine, .tether([
            TetherRound(title: "Rhythm matching", body: "Hear the target. Drag the three bass pulses to beat 1, the \"and\" of 2, and beat 4.",
                        mode: .rhythm([0, 6, 12])),
            TetherRound(title: "Root switch", body: "Am, then F. Move each bar's bass to the new root.",
                        mode: .roots, chords: [.am, .f]),
            TetherRound(title: "Space the low end", body: "This bass rings over the kicks. Drag its end handle until it matches the tighter target.",
                        mode: .length(6)),
        ])),
    ]

    static let f34Gold: [LessonStep] = [
        L.gold("Play a bass response",
               "Now you play the part that holds the track together. First write a bassline of your own. Then pick a chord loop, perform four bars on bass pads, and compare it with a plain version."),
        K.teach("No single right answer",
                "Some basslines sit with the kick, some dodge it. A good one follows the chords, leaves space and has a little movement.",
                demo: Pattern(kick: F.quarters, bass: [NoteEvent(0, 36, 3), NoteEvent(6, 43, 2), NoteEvent(10, 36, 2), NoteEvent(14, 48, 2)],
                              chords: [K.ch(0, F.c, 14)])),
        K.bassMake("Write a bass response", "At least four notes over the kick. Use the root and slip one note between the beats.",
                   rows: F.bassRows, backing: kickChordC, notes: 4),
        K.game(tetherName, "Your bassline, locked to the kick.", .tether([
            TetherRound(title: "Choose a harmonic loop", body: "Tap a loop to hear it with roots, then keep one.",
                        mode: .chooseLoop([[.c, .am], [.c, .f]])),
            TetherRound(title: "Perform a bassline", body: "One bar count-in, then four bars. Play the pads: root, fifth or high root. Get one note between the beats.",
                        mode: .perform, kick: Pattern(kick: F.quarters, clap: [4, 12])),
            TetherRound(title: "Lock and save", body: "Hear your take, then a version with roots only on the beat. Keep the one you prefer.",
                        mode: .compare, kick: Pattern(kick: F.quarters, clap: [4, 12])),
        ])),
    ]

    // MARK: - F3.5 Topline Meets Harmony → Hook Hotline

    static let hookName = "Hook Hotline"
    static let hookLine = "The band calls. You answer on five glowing pads."

    static let f35 = K.lesson("f3.5", "Topline Meets Harmony", "Boss: a melody over chords", "crown.fill", .theory, 30, [
        K.opening("A hook talks to the chords",
                  "A memorable hook feels like a conversation with the chords under it. First you'll write a short melody over a chord. Then the band calls on a hotline and you answer on five pads."),
        K.teach("Settled or leaning",
                "E, G, E over C feels settled. Change the last note to D and it leans, like it wants to keep going.",
                demo: line([(0, 64, 2), (2, 67, 2), (4, 64, 4), (8, 64, 2), (10, 67, 2), (12, 62, 4)], over: held(F.c))),
        K.leadRule("Change the landing", "E, G, E over C. Move the last note down to D and hear it lean.",
                   rows: rows, target: K.tune([(0, 64, 4), (4, 67, 4), (8, 62, 8)]), backing: held(F.c),
                   start: K.tune([(0, 64, 4), (4, 67, 4), (8, 64, 8)])),
        K.game(hookName, hookLine, .notes(pads, [
            NoteRound(title: "Let the band call", body: "The band plays a three-note hook and the pads light up. Play it back.",
                      mode: .echo([64, 67, 64], show: true, gapBars: 0), backing: bandCAm),
            NoteRound(title: "Answer in time", body: "Same hook, no lights. Answer it on the pads.",
                      mode: .echo([64, 67, 62], show: false, gapBars: 0), backing: bandCAm),
            NoteRound(title: "Hear the landing", body: "Over a held C, try ending on E and on D. Both work, they just feel different.",
                      mode: .ending(lead: [64, 67], options: [64, 62], answer: nil), backing: held(F.c)),
        ])),
    ])

    static let f35Silver: [LessonStep] = [
        L.silver("Make the line move",
                 "Your answers have to follow the chords as they change. First fix a topline's ending over F. Then find hook endings by ear and answer with no lights."),
        K.teach("Same start, new ending",
                "A hook can keep its opening and change only its last note to fit the next chord.",
                demo: line([(0, 64, 2), (2, 67, 2), (4, 64, 4), (8, 64, 2), (10, 67, 2), (12, 69, 4)], over: two(F.c, F.f))),
        K.leadCopy("Fit the F chord", "The first three notes are in. Play the reference and choose the last note over F.",
                   rows: rows, target: K.tune([(0, 64, 2), (2, 67, 2), (4, 64, 4), (8, 69, 8)]), backing: two(F.c, F.f),
                   start: K.tune([(0, 64, 2), (2, 67, 2), (4, 64, 4)])),
        K.game(hookName, hookLine, .notes(pads, [
            NoteRound(title: "Find the hook's last note", body: "The phrase ends over F. Hear both endings and choose the one that fits.",
                      mode: .ending(lead: [64, 67, 64], options: [69, 67], answer: 0), backing: bandCF),
            NoteRound(title: "Follow changing chords", body: "Over C then F. Choose the ending that sits with the new chord.",
                      mode: .ending(lead: [60, 64, 67], options: [69, 62], answer: 0), backing: bandCF),
            NoteRound(title: "Answer without lights", body: "A new three-note call. Play it back with the lights off.",
                      mode: .echo([67, 64, 62], show: false, gapBars: 0), backing: bandCAm),
        ])),
    ]

    static let f35Gold: [LessonStep] = [
        L.gold("Write a hook",
               "Time to write your own hook. First write a call and answer in the piano roll. Then record a hook on the pads, answer it, and hear the whole conversation with the band."),
        K.teach("Repeat to remember",
                "Repeat part of the hook and people will remember it, even if the ending changes.",
                demo: line([(0, 64, 2), (2, 67, 2), (4, 69, 4), (8, 64, 2), (10, 67, 2), (12, 64, 4)], over: two(F.c, F.f))),
        K.leadMake("Write a call and answer", "Six notes or more over C and F. Repeat your opening in the second half.",
                   rows: rows, backing: two(F.c, F.f), notes: 6),
        K.game(hookName, "Your hook, your reply.", .notes(pads, [
            NoteRound(title: "Record the hook", body: "Play any four notes on the pads over the band. That's your hook.",
                      mode: .compose(count: 4, start: nil, end: [], shape: false), backing: bandCF),
            NoteRound(title: "Build the reply", body: "Your hook plays. Reply with four notes that start the same way and end somewhere new.",
                      mode: .answer(keep: 2), backing: bandCF),
            NoteRound(title: "Play the conversation", body: "Hook, reply, hook, reply, with the band underneath.",
                      mode: .duet, backing: bandCF),
        ])),
    ]

    static let levels: [String: LevelPair] = [
        "f3.1": (silver: f31Silver, gold: f31Gold),
        "f3.2": (silver: f32Silver, gold: f32Gold),
        "f3.3": (silver: f33Silver, gold: f33Gold),
        "f3.4": (silver: f34Silver, gold: f34Gold),
        "f3.5": (silver: f35Silver, gold: f35Gold),
    ]
}
