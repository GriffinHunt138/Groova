//
//  ProductionLevels.swift
//  Groova
//
//  Hand-written Silver and Gold levels for each genre's production unit (melody, voice leading,
//  riffs, transposing, bass and chords talking). Each level names one new idea on its opening
//  card and mixes listening, quick checks, fix-its, copying by ear and writing your own.
//

import Foundation

nonisolated enum ProductionLevels {
    typealias H = HouseCourse
    typealias D = DeepHouseCourse
    typealias T = TechnoCourse
    typealias TH = TechHouseCourse
    typealias G = GarageCourse

    static let all: [String: LevelPair] = [
        "house.mel.l2": mel2, "house.mel.l3": mel3, "house.mel.l4": mel4, "house.mel.l5": mel5,
        "deep.vl.l1": vl1, "deep.vl.l2": vl2, "deep.vl.l3": vl3, "deep.vl.l4": vl4,
        "techno.riff.l1": riff1, "techno.riff.l2": riff2, "techno.riff.l3": riff3, "techno.riff.l4": riff4,
        "tech.key.l1": key1, "tech.key.l2": key2, "tech.key.l3": key3, "tech.key.l4": key4,
        "ukg.talk.l1": talk1, "ukg.talk.l2": talk2, "ukg.talk.l3": talk3, "ukg.talk.l4": talk4,
    ]

    // MARK: - House: Melody & Hooks

    static let mel = H.melodyRows
    static let bed = H.melodyBed
    static let hookBed = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14],
                                 bass: [NoteEvent(0, 33, 6), NoteEvent(8, 38, 6)],
                                 chords: [K.ch(0, .am7, 4), K.ch(8, .dm7, 4)])

    static func leadFix(_ prompt: String, _ hint: String, rows: [Int], broken: [NoteEvent], target: [NoteEvent],
                        backing: Pattern) -> LessonStep {
        K.fixNotes(prompt, hint, rows: rows, broken: broken, target: target, backing: backing, voice: .lead)
    }

    static let mel2: LevelPair = (
        silver: [
            L.silver("motifs that move",
                     "A motif doesn't have to repeat on the same notes. Keep its rhythm and shape, start it on a new note, and the ear still hears the same idea. That's called a sequence."),
            K.quiz("Same motif?", "Listen to the second half. Is it the first half again?", [
                K.round(K.phrase([60, 62, 64, 60, 62, 64]), ["Exact repeat", "Same shape, moved up", "Something new"], 0),
                K.round(K.phrase([60, 62, 64, 62, 64, 67]), ["Exact repeat", "Same shape, moved up", "Something new"], 1,
                        "C, D, E, then D, E, G: the same climb, one note higher."),
                K.round(K.phrase([60, 62, 64, 69, 57, 60]), ["Exact repeat", "Same shape, moved up", "Something new"], 2),
                K.round(K.phrase([64, 62, 60, 67, 64, 62]), ["Exact repeat", "Same shape, moved up", "Something new"], 1),
            ]),
            leadFix("Fix the repeat", "The motif on steps 1, 3 and 5 should repeat exactly on steps 9, 11 and 13. One note in the repeat is wrong.",
                    rows: mel, broken: K.line([(0, 60), (2, 62), (4, 64), (8, 60), (10, 64), (12, 64)]),
                    target: K.line([(0, 60), (2, 62), (4, 64), (8, 60), (10, 62), (12, 64)]), backing: bed),
            K.leadCopy("Copy this sequence", "The motif plays from C. Then the same shape starts one note higher, on D.",
                       rows: mel, target: K.line([(0, 60), (2, 62), (4, 64), (8, 62), (10, 64), (12, 67)]), backing: bed,
                       threshold: 0.85),
            K.leadMake("Write a sequence", "Write a three-note motif, then play the same shape starting on a different note. At least 6 notes.",
                       rows: mel, backing: bed, notes: 6),
        ],
        gold: [
            L.gold("one motif, four times",
                   "Most house hooks are one motif played four times in a bar. Change only the rhythm and the same two notes become a brand new hook."),
            K.quiz("Count the motif", "", [
                K.hear([K.withLead(bed, K.line([(0, 69), (1, 67), (8, 69), (9, 67)]))], ["Twice", "Four times"], 0, bars: 2,
                       question: "How many times does the motif play in each bar?"),
                K.hear([K.withLead(bed, K.line([(0, 69), (1, 67), (4, 69), (5, 67), (8, 69), (9, 67), (12, 69), (13, 67)]))],
                       ["Twice", "Four times"], 1, bars: 2, question: "How many times does the motif play in each bar?"),
                K.hear([K.withLead(bed, K.line([(0, 60), (2, 62), (4, 64), (8, 60), (9, 62), (11, 64)]))],
                       ["Same rhythm", "New rhythm"], 1, "Same three notes, but the second time they come quicker.", bars: 2,
                       question: "Do both halves use the same rhythm?"),
            ]),
            K.leadCopy("Copy the four-hit motif", "Two notes, high A then G, starting on every beat.",
                       rows: mel, target: K.line([(0, 69), (1, 67), (4, 69), (5, 67), (8, 69), (9, 67), (12, 69), (13, 67)]),
                       backing: bed, threshold: 0.9),
            leadFix("Fix the rhythm", "The motif is short, short, long: two quick notes, then one held for three steps. The held notes have been clipped short.",
                    rows: mel,
                    broken: K.line([(0, 64), (1, 62), (2, 60), (8, 64), (9, 62), (10, 60)]),
                    target: [NoteEvent(0, 64), NoteEvent(1, 62), NoteEvent(2, 60, 3), NoteEvent(8, 64), NoteEvent(9, 62),
                             NoteEvent(10, 60, 3)],
                    backing: bed),
            K.leadMake("Make it yours", "Pick a two or three-note motif and play it four times in the bar. At least 8 notes.",
                       rows: mel, backing: bed, notes: 8),
        ])

    static let mel3: LevelPair = (
        silver: [
            L.silver("twist the rhythm",
                     "You can twist a motif without changing a single note. Move a note later, hold one longer, or add a quick extra hit. The ear notices, and the hook stays fresh."),
            K.quiz("What changed?", "The motif plays, then plays again with a twist.", [
                K.hear([K.withLead(bed, [NoteEvent(0, 64), NoteEvent(2, 62), NoteEvent(4, 60, 2), NoteEvent(8, 64), NoteEvent(10, 62),
                                         NoteEvent(12, 57, 4)])],
                       ["A note changed", "The rhythm changed"], 0, "The last note drops to the low A.", bars: 2),
                K.hear([K.withLead(bed, [NoteEvent(0, 64), NoteEvent(2, 62), NoteEvent(4, 60, 2), NoteEvent(8, 64), NoteEvent(9, 62),
                                         NoteEvent(11, 60, 4)])],
                       ["A note changed", "The rhythm changed"], 1, "Same notes, but they arrive sooner and the last one holds.", bars: 2),
            ]),
            leadFix("Land it home", "The second time, the motif should end on home: the low A on step 13. It ends on D, so it hangs.",
                    rows: mel,
                    broken: [NoteEvent(0, 64), NoteEvent(2, 62), NoteEvent(4, 60, 2), NoteEvent(8, 64), NoteEvent(10, 62), NoteEvent(12, 62, 4)],
                    target: [NoteEvent(0, 64), NoteEvent(2, 62), NoteEvent(4, 60, 2), NoteEvent(8, 64), NoteEvent(10, 62), NoteEvent(12, 57, 4)],
                    backing: bed),
            K.leadCopy("Copy the rhythm twist", "Same notes both times. The second time, the last note comes in early and holds.",
                       rows: mel,
                       target: [NoteEvent(0, 64), NoteEvent(2, 62), NoteEvent(4, 60, 2), NoteEvent(8, 64), NoteEvent(10, 62),
                                NoteEvent(11, 60, 5)],
                       backing: bed, threshold: 0.85),
            K.leadMake("Twist it with rhythm", "Play a motif, then repeat it with the same notes in a new rhythm. At least 6 notes.",
                       rows: mel, backing: bed, notes: 6),
        ],
        gold: [
            L.gold("the A A B A shape",
                   "Lots of hooks play a motif three times and twist it once. The twist usually comes third, so the fourth time feels like coming home."),
            K.quiz("Where's the twist?", "The motif plays four times. Which one is different?", [
                K.hear([K.withLead(bed, K.line([(0, 64), (1, 62), (2, 60), (4, 64), (5, 62), (6, 60), (8, 67), (9, 64), (10, 62),
                                                (12, 64), (13, 62), (14, 60)]))],
                       ["The third time", "The last time"], 0, bars: 2),
                K.hear([K.withLead(bed, K.line([(0, 64), (1, 62), (2, 60), (4, 64), (5, 62), (6, 60), (8, 64), (9, 62), (10, 60),
                                                (12, 67), (13, 64), (14, 69)]))],
                       ["The third time", "The last time"], 1, bars: 2),
            ]),
            K.leadCopy("Copy the A A B A hook", "E, D, C on every beat, but the third time it starts higher, on G.",
                       rows: mel,
                       target: K.line([(0, 64), (1, 62), (2, 60), (4, 64), (5, 62), (6, 60), (8, 67), (9, 64), (10, 62),
                                       (12, 64), (13, 62), (14, 60)]),
                       backing: bed, threshold: 0.9),
            leadFix("Bring it home", "The last repeat should land on home: the low A on step 15. It stops on C.",
                    rows: mel,
                    broken: K.line([(0, 64), (1, 62), (2, 60), (4, 64), (5, 62), (6, 60), (8, 67), (9, 64), (10, 62),
                                    (12, 64), (13, 62), (14, 60)]),
                    target: K.line([(0, 64), (1, 62), (2, 60), (4, 64), (5, 62), (6, 60), (8, 67), (9, 64), (10, 62),
                                    (12, 64), (13, 62), (14, 57)]),
                    backing: bed),
            K.leadMake("Make it yours", "Write an A A B A hook: the same motif three times, with a twist the third time. At least 10 notes.",
                       rows: mel, backing: bed, notes: 10),
        ])

    static let mel4: LevelPair = (
        silver: [
            L.silver("one question, many answers",
                     "A question can have more than one good answer. What every answer shares is the landing: it comes home to A."),
            K.quiz("Question or answer?", "Does this phrase stop away from home, or land on A?", [
                K.round(K.phrase([60, 62, 67]), ["Question", "Answer"], 0, "It stops on G, waiting."),
                K.round(K.phrase([64, 62, 57]), ["Question", "Answer"], 1, "Home on the low A."),
                K.round(K.phrase([69, 67, 64, 62]), ["Question", "Answer"], 0),
                K.round(K.phrase([62, 60, 57]), ["Question", "Answer"], 1),
            ]),
            K.leadRule("Answer this question",
                       "The question climbs A, C, E and stops on E. Answer by stepping down: D on step 9, C on step 11, then the low A on step 13, held for four.",
                       rows: mel,
                       target: [NoteEvent(0, 57), NoteEvent(2, 60), NoteEvent(4, 64, 2), NoteEvent(8, 62), NoteEvent(10, 60),
                                NoteEvent(12, 57, 4)],
                       backing: bed, start: [NoteEvent(0, 57), NoteEvent(2, 60), NoteEvent(4, 64, 2)]),
            leadFix("The answer doesn't land", "The answer should come home to the low A on step 12. It stops on D, so it sounds like a second question.",
                    rows: mel,
                    broken: [NoteEvent(0, 67), NoteEvent(2, 64), NoteEvent(3, 62, 3), NoteEvent(8, 67), NoteEvent(10, 64),
                             NoteEvent(11, 62, 5)],
                    target: [NoteEvent(0, 67), NoteEvent(2, 64), NoteEvent(3, 62, 3), NoteEvent(8, 67), NoteEvent(10, 64),
                             NoteEvent(11, 57, 5)],
                    backing: bed),
            K.leadMake("Ask and answer", "Write a question that stops away from A, then an answer that lands on A. At least 6 notes.",
                       rows: mel, backing: bed, notes: 6),
        ],
        gold: [
            L.gold("answers that echo",
                   "The tightest answers copy the question's rhythm with new notes. The ear hears the echo and the change at the same time."),
            K.quiz("Echo or new rhythm?", "Listen to the rhythm of the answer.", [
                K.hear([K.withLead(bed, [NoteEvent(0, 60), NoteEvent(1, 62), NoteEvent(3, 67, 3), NoteEvent(8, 64), NoteEvent(9, 62),
                                         NoteEvent(11, 57, 3)])],
                       ["Same rhythm", "New rhythm"], 0, bars: 2),
                K.hear([K.withLead(bed, [NoteEvent(0, 60), NoteEvent(1, 62), NoteEvent(3, 67, 3), NoteEvent(8, 64), NoteEvent(10, 62),
                                         NoteEvent(12, 57, 4)])],
                       ["Same rhythm", "New rhythm"], 1, bars: 2),
            ]),
            K.leadCopy("Copy the echo", "The answer copies the question's rhythm exactly, with notes that fall home.",
                       rows: mel,
                       target: [NoteEvent(0, 60), NoteEvent(1, 62), NoteEvent(3, 67, 3), NoteEvent(8, 64), NoteEvent(9, 62),
                                NoteEvent(11, 57, 3)],
                       backing: bed, threshold: 0.9),
            K.leadRule("Echo the rhythm",
                       "Answer with the same rhythm as the question, on steps 9, 11, 12 and 15. Use E, D, then C held for two, and finish on the low A.",
                       rows: mel,
                       target: [NoteEvent(0, 69), NoteEvent(2, 67), NoteEvent(3, 64, 2), NoteEvent(6, 62),
                                NoteEvent(8, 64), NoteEvent(10, 62), NoteEvent(11, 60, 2), NoteEvent(14, 57)],
                       backing: bed, start: [NoteEvent(0, 69), NoteEvent(2, 67), NoteEvent(3, 64, 2), NoteEvent(6, 62)]),
            K.leadMake("Make it yours", "A question, then an answer that echoes its rhythm and lands on A. At least 8 notes.",
                       rows: mel, backing: bed, notes: 8),
        ])

    static let mel5: LevelPair = (
        silver: [
            L.silver("notes that cross the beat",
                     "Start a note just before a kick and hold it across, and the hook tugs against the beat. That tug is called syncopation. It's why piano house riffs bounce."),
            K.quiz("On the kick or between?", "", [
                K.hear([K.withLead(bed, K.line([(0, 64), (4, 67), (8, 64), (12, 62)]))], ["On the kicks", "Between the kicks"], 0, bars: 2),
                K.hear([K.withLead(bed, K.line([(2, 64), (6, 67), (10, 64), (14, 62)]))], ["On the kicks", "Between the kicks"], 1,
                       "Off the kick, every note pops out.", bars: 2),
                K.hear([K.withLead(bed, [NoteEvent(3, 64, 3), NoteEvent(11, 67, 3)])], ["Short and off the beat", "Held across the kick"], 1,
                       "Each note starts just before a kick and rings through it.", bars: 2),
            ]),
            leadFix("Get off the kick", "Two notes sit right on kicks, on steps 5 and 13. Move each one a step later.",
                    rows: mel,
                    broken: [NoteEvent(1, 64), NoteEvent(3, 67), NoteEvent(4, 69, 2), NoteEvent(10, 67), NoteEvent(12, 64)],
                    target: [NoteEvent(1, 64), NoteEvent(3, 67), NoteEvent(5, 69, 2), NoteEvent(10, 67), NoteEvent(13, 64)],
                    backing: bed),
            K.leadCopy("Copy the syncopated hook", "The long notes start just before a kick and ring across it. Short notes fill in after.",
                       rows: mel,
                       target: [NoteEvent(3, 64, 3), NoteEvent(7, 67), NoteEvent(11, 69, 3), NoteEvent(15, 67)],
                       backing: bed, threshold: 0.85),
            K.leadMake("Write a bouncy hook", "At least 6 notes. Hold at least one note across a kick.", rows: mel, backing: bed, notes: 6),
        ],
        gold: [
            L.gold("a hook that sits in the track",
                   "With chords and bass playing, a hook has more to dodge than the kick. Keep the motif, find the gaps, and choose notes that fit each chord."),
            K.quiz("Which hook pops?", "Same notes, two rhythms, over the full track.", [
                K.hear([K.withLead(hookBed, K.line([(0, 69), (4, 67), (8, 64), (12, 60)])),
                        K.withLead(hookBed, K.line([(1, 69), (3, 67), (6, 64), (14, 60)]))],
                       ["The first", "The second"], 1, "Off the kick and away from the chord hits, the notes stand out.",
                       question: "Which hook pops out more?"),
            ]),
            K.leadCopy("Copy this piano house hook", "High A, G, then a long E, between the kicks. It repeats, but the last note drops to C over Dm7.",
                       rows: mel,
                       target: [NoteEvent(1, 69), NoteEvent(3, 67), NoteEvent(6, 64, 2), NoteEvent(9, 69), NoteEvent(11, 67),
                                NoteEvent(14, 60, 2)],
                       backing: hookBed, threshold: 0.9),
            leadFix("Fix the swallowed note", "One note lands right on the kick on step 9 and gets lost. Move it a step later.",
                    rows: mel,
                    broken: [NoteEvent(2, 64), NoteEvent(3, 67), NoteEvent(6, 69), NoteEvent(8, 64), NoteEvent(11, 67), NoteEvent(14, 62, 2)],
                    target: [NoteEvent(2, 64), NoteEvent(3, 67), NoteEvent(6, 69), NoteEvent(9, 64), NoteEvent(11, 67), NoteEvent(14, 62, 2)],
                    backing: hookBed),
            K.leadMake("Make it yours", "A full hook over the chords: a motif, a twist, and most notes between the kicks. At least 8 notes.",
                       rows: mel, backing: hookBed, notes: 8),
        ])

    // MARK: - Deep House: Voice Leading

    static let glide = D.glideBed
    /// Fm7 stacked from A♭: A♭, C, E♭, F.
    static let fm7OnAb = ChordShape(name: "Fm7", pitches: [56, 60, 63, 65])
    /// Cm7 in root position, low: C, E♭, G, B♭.
    static let cm7Root = ChordShape(name: "Cm7", pitches: [48, 51, 55, 58])
    /// D♭maj7 with F on top: A♭, C, D♭, F.
    static let dbmaj7TopF = ChordShape(name: "D♭maj7", pitches: [56, 60, 61, 65])
    /// B♭m7 in root position: B♭, D♭, F, A♭.
    static let bbm7Root = ChordShape(name: "B♭m7", pitches: [58, 61, 65, 68])
    /// Cm7 with G on top: B♭, C, E♭, G.
    static let cm7TopG = ChordShape(name: "Cm7", pitches: [58, 60, 63, 67])
    /// E♭maj7 with B♭ on top: D, E♭, G, B♭.
    static let ebmaj7TopBb = ChordShape(name: "E♭maj7", pitches: [62, 63, 67, 70])

    static let vl1: LevelPair = (
        silver: [
            L.silver("every way to stack a chord",
                     "A four-note chord can be stacked four ways: the root on the bottom, or any of its other notes. Each one is the same chord, with a different note on top."),
            K.build("Build Fm7 with A♭ on the bottom", "Fm7 is F, A♭, C and E♭. Start from A♭, then C and E♭, with F on top.",
                    fm7OnAb, low: 53, high: 72, exact: true),
            K.build("Restack Cm7 from its root", "This Cm7 has G on the bottom. Restack it from C: C, E♭, G, then B♭.",
                    cm7Root, start: [55, 58, 60, 63], low: 48, high: 67, exact: true),
            K.quiz("Higher or lower?", "Same chord twice, stacked differently. Did the second stack move up or down?", [
                K.round([.fm7, D.fm7OnC], ["Higher", "Lower"], 0),
                K.round([D.fm7OnC, .fm7], ["Higher", "Lower"], 1),
                K.round([.cm7, cm7Root], ["Higher", "Lower"], 1, "Root position Cm7 sits right down low."),
                K.round([cm7Root, D.cm7OnEb], ["Higher", "Lower"], 0),
            ]),
            K.lane("Hear the inversions", "Only Fm7, stacked two ways. The high stack sounds brighter and lighter.", .recreate,
                   palette: [.fm7, D.fm7OnC], backing: glide, target: [0: 0, 4: 1, 8: 0, 12: 1], length: 4),
        ],
        gold: [
            L.gold("pick the inversion that fits",
                   "Producers choose inversions for where they sit. Low stacks feel heavy, high stacks feel airy. Next to another chord, the right inversion is what makes them glide."),
            K.quiz("Same chord or a new one?", "Listen past the height. Is the colour the same?", [
                K.round([cm7Root, .cm7], ["Same chord", "New chord"], 0),
                K.round([.bbm7, D.bbm7TopF], ["Same chord", "New chord"], 0),
                K.round([.bbm7, .dbmaj7], ["Same chord", "New chord"], 1, "They share three notes, but D♭maj7 is brighter."),
                K.round([.ebmaj7, .gm7], ["Same chord", "New chord"], 1),
            ]),
            K.build("Build D♭maj7 with F on top", "D♭maj7 is D♭, F, A♭ and C. Stack A♭, C, D♭, then F on top.",
                    dbmaj7TopF, low: 53, high: 72, exact: true),
            K.build("Restack B♭m7 from its root", "This B♭m7 has F on the bottom. Restack it from B♭: B♭, D♭, F, then A♭.",
                    bbm7Root, start: [53, 56, 58, 61], low: 53, high: 72, exact: true),
            K.lane("Make it yours", "Mix low and high stacks. Notice which pairs glide and which jump. At least 4 chords.",
                   .create(.chordsAtLeast(4)), palette: [.fm7, D.fm7OnC, .dbmaj7, D.dbmaj7Wide], backing: glide, length: 4),
        ])

    static let vl2: LevelPair = (
        silver: [
            L.silver("find the shared notes",
                     "Before you move to the next chord, look for the notes the two chords share. Hold those still and move only the rest."),
            K.quiz("Count the shared notes", "", [
                K.ask("Fm7 is F, A♭, C, E♭. B♭m7 is B♭, D♭, F, A♭. How many notes do they share?", ["One", "Two", "Three"], 1,
                      "F and A♭. Keep them still and move the other two."),
                K.ask("Cm7 is C, E♭, G, B♭. E♭maj7 is E♭, G, B♭, D. How many do they share?", ["One", "Two", "Three"], 2,
                      "E♭, G and B♭. Only C has to move, up a step to D."),
            ]),
            K.build("Glide from Cm7 to E♭maj7", "Cm7 is here: G, B♭, C, E♭. Move just one note: C up to D.",
                    .ebmaj7, start: [55, 58, 60, 63], low: 53, high: 67, exact: true),
            K.build("Glide from Fm7 to B♭m7", "Fm7 is here. Keep F and A♭ still. Move C down to B♭, and E♭ down to D♭.",
                    .bbm7, start: [53, 56, 60, 63], low: 53, high: 67, exact: true),
            K.lane("Glide back and forth", "Every pair here shares notes. Write a loop and listen for how little moves. At least 4 chords.",
                   .create(.chordsAtLeast(4)), palette: [.fm7, .bbm7, .cm7, .ebmaj7], backing: glide, length: 4),
        ],
        gold: [
            L.gold("voice lead a whole loop",
                   "Move from chord to chord by the smallest steps and a whole loop glides. Each chord hands its notes on to the next."),
            K.quiz("Smooth or jumpy?", "", [
                K.round([.gm7, .ebmaj7], ["Smooth", "Jumpy"], 0, "Only F moves, down a step to E♭."),
                K.round([.ebmaj7, D.fm7OnC], ["Smooth", "Jumpy"], 1),
                K.round([.fm7, .bbm7], ["Smooth", "Jumpy"], 0),
                K.round([.cm7, cm7Root], ["Smooth", "Jumpy"], 1, "Same chord, but every note drops a long way."),
            ]),
            K.build("Step from B♭m7 to Cm7", "No shared notes this time, so every note moves up one small step: F to G, A♭ to B♭, B♭ to C, D♭ to E♭.",
                    .cm7, start: [53, 56, 58, 61], low: 53, high: 67, exact: true),
            K.lane("Copy the voice-led loop", "Fm7, B♭m7, E♭maj7, then Cm7. Every change is a small move.", .recreate,
                   palette: [.fm7, .bbm7, .cm7, .ebmaj7], backing: glide, target: [0: 0, 4: 1, 8: 3, 12: 2], length: 4),
            K.lane("Make it yours", "Write a loop where every change is a small move. At least 4 chords.", .create(.chordsAtLeast(4)),
                   palette: [.fm7, .bbm7, .cm7, .ebmaj7], backing: glide, length: 4),
        ])

    static let vl3: LevelPair = (
        silver: [
            L.silver("the top line is a melody",
                     "Join up the top notes and you get a melody hidden inside the chords. Steps sound smooth. A leap on top grabs attention."),
            K.quiz("Where does the top note go?", "", [
                K.round([.bbm7, .cm7], ["Up", "Down", "Stays"], 0, "D♭ up to E♭."),
                K.round([.gm7, .ebmaj7], ["Up", "Down", "Stays"], 1, "F down to E♭."),
                K.round([.fm7, .ebmaj7], ["Up", "Down", "Stays"], 2, "E♭ on top both times."),
                K.round([D.bbm7TopF, .fm7], ["Up", "Down", "Stays"], 1),
            ]),
            K.build("Voice Cm7 with G on top", "Cm7 is C, E♭, G and B♭. Stack B♭, C, E♭, then G on top.",
                    cm7TopG, low: 55, high: 69, exact: true),
            K.build("Put A♭ on top", "This Fm7 has E♭ on top. Restack it so A♭ sings on top: C, E♭, F, then A♭.",
                    D.fm7OnC, start: [53, 56, 60, 63], low: 53, high: 72, exact: true),
            K.lane("Follow the top line", "The top note holds on E♭ for two chords, then steps down to D♭ for two.", .recreate,
                   palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glide, target: [0: 3, 4: 0, 8: 1, 12: 2], length: 4),
        ],
        gold: [
            L.gold("chords that carry a tune",
                   "Pick voicings so the top notes trace a tune: hold, step down, step up, come home. It makes a simple loop sing without a lead."),
            K.quiz("Trace the top line", "Three chords. Follow only the highest note.", [
                K.round([.cm7, .bbm7, .cm7], ["Down, then back up", "Up, then down", "Stays the same"], 0),
                K.round([.bbm7, .cm7, .bbm7], ["Down, then back up", "Up, then down", "Stays the same"], 1),
                K.round([.fm7, .ebmaj7, .cm7], ["Down, then back up", "Up, then down", "Stays the same"], 2, "E♭ on top all the way."),
                K.round([.dbmaj7, .gm7, .fm7], ["Down, then back up", "Up, then down", "Stays the same"], 1),
            ]),
            K.build("Voice E♭maj7 with B♭ on top", "E♭maj7 is E♭, G, B♭ and D. Stack D, E♭, G, then B♭ on top.",
                    ebmaj7TopBb, low: 60, high: 72, exact: true),
            K.lane("Copy the top-line loop", "The top line goes E♭, D♭, E♭, then up to F.", .recreate,
                   palette: [.cm7, .bbm7, .fm7, .gm7], backing: glide, target: [0: 0, 4: 1, 8: 2, 12: 3], length: 4),
            K.lane("Make it yours", "Write a loop and sing its top line back. Aim for steps, with one leap. At least 4 chords.",
                   .create(.chordsAtLeast(4)), palette: [.fm7, .dbmaj7, .bbm7, .cm7, .gm7], backing: glide, length: 4),
        ])

    static let vl4: LevelPair = (
        silver: [
            L.silver("same four, new order",
                     "Swap the order and the loop tells a different story. Ending on Cm7 leaves it hanging, wanting to go round again. Ending on Fm7 brings it home."),
            K.quiz("Home or hanging?", "", [
                K.round([.dbmaj7, .bbm7, .cm7, .fm7], ["Comes home", "Hangs"], 0, "It ends on Fm7, the home chord."),
                K.round([.fm7, .dbmaj7, .bbm7, .cm7], ["Comes home", "Hangs"], 1, "Cm7 pulls back towards Fm7."),
                K.round([.bbm7, .cm7, .dbmaj7, .fm7], ["Comes home", "Hangs"], 0),
            ]),
            K.lane("Fix the order", "Two chords have swapped. The loop should go Fm7, D♭maj7, B♭m7, then Cm7.", .recreate,
                   palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glide, start: [0: 0, 4: 1, 8: 3, 12: 2],
                   target: [0: 0, 4: 1, 8: 2, 12: 3], length: 4),
            K.lane("Copy the new order", "It starts on D♭maj7 and comes home to Fm7 at the end.", .recreate,
                   palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glide, target: [0: 1, 4: 2, 8: 3, 12: 0], length: 4),
            K.lane("Write your own order", "Decide: should your loop come home, or hang? At least 4 chords.", .create(.chordsAtLeast(4)),
                   palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glide, length: 4),
        ],
        gold: [
            L.gold("glide with rhythm",
                   "Deep house chords don't just hold. They stab and push. Keep the voicings close and you can play any rhythm without breaking the glide."),
            K.quiz("Held or stabbed?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], chords: [K.ch(0, .fm7, 8), K.ch(8, .dbmaj7, 8)])],
                       ["Held", "Stabbed"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14],
                                chords: [K.ch(0, .fm7, 2), K.ch(3, .fm7, 2), K.ch(8, .dbmaj7, 2), K.ch(11, .dbmaj7, 2)])],
                       ["Held", "Stabbed"], 1, bars: 2),
            ]),
            K.lane("Copy the rhythm loop", "Fm7 twice, D♭maj7 once, B♭m7 twice, then Cm7 at the very end.", .recreate,
                   palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glide,
                   target: [0: 0, 3: 0, 6: 1, 8: 2, 11: 2, 14: 3], length: 2),
            K.lane("Fix the stab", "B♭m7 should stab twice, on steps 9 and 12. One of its stabs has turned into Cm7.", .recreate,
                   palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glide,
                   start: [0: 0, 3: 0, 6: 1, 8: 2, 11: 3, 14: 3], target: [0: 0, 3: 0, 6: 1, 8: 2, 11: 2, 14: 3], length: 2),
            K.lane("Make it yours", "A gliding loop with rhythm. At least 6 stabs.", .create(.chordsAtLeast(6)),
                   palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glide, length: 2),
        ])

    // MARK: - Techno: Riffs & Arps

    static let riffRows = T.riffRows
    static let arpRows = T.arpRows
    static let riffBed = T.riffBed
    static let riffBass = T.riffBass
    static let arpUp = (0..<16).map { NoteEvent($0, [57, 60, 64, 69][$0 % 4]) }
    static let arpUpDown = (0..<16).map { NoteEvent($0, [57, 60, 64, 69, 64, 60][$0 % 6]) }

    static let riff1: LevelPair = (
        silver: [
            L.silver("length is rhythm too",
                     "With one note, you can only change when it plays and how long it rings. Short notes tick, long notes drone. Mix them and a single note grooves."),
            K.quiz("Short or long?", "", [
                K.hear([K.withLead(riffBed, K.notes(57, [1, 3, 6, 9, 12]))], ["Short notes", "Long notes"], 0, bars: 2),
                K.hear([K.withLead(riffBed, K.notes(57, [1, 6, 9, 14], length: 3))], ["Short notes", "Long notes"], 1, bars: 2),
            ]),
            leadFix("Fix the riff", "Notes should land on steps 2, 4, 7, 10 and 13. One has slipped onto the kick on step 9.",
                    rows: riffRows, broken: K.notes(57, [1, 3, 6, 8, 12]), target: K.notes(57, [1, 3, 6, 9, 12]), backing: riffBed),
            K.leadCopy("Copy the drone riff", "Two long notes and three quick ones, all on A.",
                       rows: riffRows,
                       target: [NoteEvent(1, 57, 3), NoteEvent(6, 57), NoteEvent(7, 57), NoteEvent(9, 57, 3), NoteEvent(14, 57)],
                       backing: riffBed, threshold: 0.85),
            K.leadMake("Write a one-note riff", "Only use A. Mix short and long notes. At least 5 notes.", rows: riffRows, backing: riffBed, notes: 5),
        ],
        gold: [
            L.gold("one note, two octaves",
                   "Add the same note an octave up and a one-note riff gets a jumping shape without ever leaving its key. Techno bounces between octaves all the time."),
            K.quiz("Did it jump?", "", [
                K.hear([K.withLead(riffBed, K.line([(1, 57), (3, 69), (6, 57), (9, 57), (11, 69), (14, 57)]))],
                       ["It jumps an octave", "Same note all the way"], 0, bars: 2),
                K.hear([K.withLead(riffBed, K.notes(57, [1, 3, 6, 9, 11, 14]))], ["It jumps an octave", "Same note all the way"], 1, bars: 2),
            ]),
            K.leadCopy("Copy the octave riff", "Low A and high A take turns.",
                       rows: riffRows, target: K.line([(1, 57), (3, 69), (6, 57), (7, 69), (10, 57), (12, 57), (14, 69)]),
                       backing: riffBed, threshold: 0.9),
            leadFix("Fix the octave", "The note on step 8 should be the high A. It's stuck down low.",
                    rows: riffRows,
                    broken: [NoteEvent(1, 57), NoteEvent(3, 69), NoteEvent(5, 57), NoteEvent(7, 57), NoteEvent(9, 57), NoteEvent(11, 69),
                             NoteEvent(14, 57, 2)],
                    target: [NoteEvent(1, 57), NoteEvent(3, 69), NoteEvent(5, 57), NoteEvent(7, 69), NoteEvent(9, 57), NoteEvent(11, 69),
                             NoteEvent(14, 57, 2)],
                    backing: riffBed),
            K.leadMake("Make it yours", "Only low A and high A. Let the rhythm be the hook. At least 7 notes.",
                       rows: riffRows, backing: riffBed, notes: 7),
        ])

    static let riff2: LevelPair = (
        silver: [
            L.silver("arp patterns",
                     "An arp can climb, fall, go up and down, or skip around. The same three notes feel completely different in each pattern."),
            K.quiz("Which way does it go?", "", [
                K.round(K.phrase([57, 60, 64, 69]), ["Up", "Down", "Both ways"], 0),
                K.round(K.phrase([69, 64, 60, 57]), ["Up", "Down", "Both ways"], 1),
                K.round(K.phrase([57, 60, 64, 69, 64, 60]), ["Up", "Down", "Both ways"], 2),
                K.round(K.phrase([69, 64, 60, 64, 69]), ["Up", "Down", "Both ways"], 2),
            ]),
            K.leadRule("Arpeggiate downwards", "High A, E, C, then low A on steps 1 to 4. Repeat it four times.",
                       rows: arpRows, target: (0..<16).map { NoteEvent($0, [69, 64, 60, 57][$0 % 4]) }, backing: riffBed),
            leadFix("Fix the arp", "This should climb A, C, E, high A on every beat. On the third beat, C and E have swapped.",
                    rows: arpRows,
                    broken: arpUp.map { n in n.step == 9 ? NoteEvent(9, 64) : n.step == 10 ? NoteEvent(10, 60) : n },
                    target: arpUp, backing: riffBed),
            K.leadCopy("Copy the 8th-note arp", "Up the chord, one note every other step.",
                       rows: arpRows, target: K.line([(0, 57), (2, 60), (4, 64), (6, 69), (8, 57), (10, 60), (12, 64), (14, 69)]),
                       backing: riffBed, threshold: 0.85),
        ],
        gold: [
            L.gold("arps with gaps",
                   "Drop a few notes out of a 16th arp and it starts to groove. The gaps make the rhythm, and the notes that stay make the shape."),
            K.quiz("Full or gappy?", "", [
                K.hear([K.withLead(riffBed, arpUp)], ["Every 16th", "With gaps"], 0, bars: 2),
                K.hear([K.withLead(riffBed, arpUp.filter { $0.step % 4 != 3 })], ["Every 16th", "With gaps"], 1, bars: 2),
            ]),
            K.leadCopy("Copy the gappy arp", "A, C, E, then a gap where the high A was. Every beat.",
                       rows: arpRows, target: arpUp.filter { $0.step % 4 != 3 }, backing: riffBed, threshold: 0.9),
            leadFix("Fill the holes", "This up-and-down arp (A, C, E, high A, E, C) is missing two notes. Listen and fill them in.",
                    rows: arpRows, broken: arpUpDown.filter { $0.step != 5 && $0.step != 11 }, target: arpUpDown, backing: riffBed),
            K.leadMake("Make it yours", "Write an arp from A, C, E and high A, then leave some gaps. At least 10 notes.",
                       rows: arpRows, backing: riffBed, notes: 10),
        ])

    static let riff3: LevelPair = (
        silver: [
            L.silver("tension and release",
                     "A♯ wants to fall back to A. Lean on it and come back, and the riff breathes: tense, then relaxed. Leave it hanging on A♯ and the tension never lets go."),
            K.quiz("Does it come back?", "Listen to the last note.", [
                K.round(K.phrase([57, 58, 57]), ["Resolves to A", "Hangs on A♯"], 0),
                K.round(K.phrase([57, 57, 58]), ["Resolves to A", "Hangs on A♯"], 1),
                K.round(K.phrase([58, 57, 57, 58]), ["Resolves to A", "Hangs on A♯"], 1),
                K.round(K.phrase([60, 58, 57]), ["Resolves to A", "Hangs on A♯"], 0),
            ]),
            leadFix("Release the tension", "Each A♯ should fall straight back to A on the next step. The second one never comes back.",
                    rows: riffRows,
                    broken: K.line([(0, 57), (2, 58), (3, 57), (8, 57), (10, 58), (11, 58)]),
                    target: K.line([(0, 57), (2, 58), (3, 57), (8, 57), (10, 58), (11, 57)]), backing: riffBed),
            K.leadCopy("Copy the dark riff", "A♯ shows up twice and resolves both times. C adds a little lift at the end.",
                       rows: riffRows, target: K.line([(0, 57), (1, 58), (2, 57), (6, 57), (8, 57), (9, 58), (10, 57), (14, 60)]),
                       backing: riffBed, threshold: 0.85),
            K.leadMake("Write tension and release", "Use A♯ at least twice, and let each one fall back to A. At least 6 notes.",
                       rows: riffRows, backing: riffBed, notes: 6),
        ],
        gold: [
            L.gold("dark riffs over a rolling bass",
                   "With the bass rolling underneath, A♯ rubs against the bass as well. That's techno's signature tension. Keep it short so it bites instead of muddying."),
            K.quiz("Bite or smear?", "", [
                K.ask("Why does A♯ sound so tense next to A?", ["They're only a half step apart", "A♯ is louder", "It's out of tune"], 0,
                      "A half step is the smallest gap on the keyboard. The two notes rub."),
                K.hear([K.withLead(riffBass, [NoteEvent(1, 57), NoteEvent(5, 58), NoteEvent(9, 57), NoteEvent(13, 58)])],
                       ["Short bite", "Long smear"], 0, bars: 2),
                K.hear([K.withLead(riffBass, [NoteEvent(1, 57), NoteEvent(5, 58, 4), NoteEvent(9, 57), NoteEvent(13, 58, 3)])],
                       ["Short bite", "Long smear"], 1, "Held A♯s run into the bass and blur.", bars: 2),
            ]),
            K.leadCopy("Copy the riff over the bass", "A, a quick A♯, then A again. The last note lifts to E.",
                       rows: riffRows, target: K.line([(1, 57), (2, 58), (5, 57), (9, 57), (10, 58), (13, 57), (14, 64)]),
                       backing: riffBass, threshold: 0.9),
            leadFix("Too much tension", "The A♯ on step 6 is held for four steps and smears into the bass. Shorten it to one step.",
                    rows: riffRows,
                    broken: [NoteEvent(1, 57), NoteEvent(2, 58), NoteEvent(5, 58, 4), NoteEvent(10, 57), NoteEvent(13, 58), NoteEvent(14, 57)],
                    target: [NoteEvent(1, 57), NoteEvent(2, 58), NoteEvent(5, 58), NoteEvent(10, 57), NoteEvent(13, 58), NoteEvent(14, 57)],
                    backing: riffBass),
            K.leadMake("Make it yours", "A dark riff over the bass, with at least two short A♯s that fall back to A. At least 6 notes.",
                       rows: riffRows, backing: riffBass, notes: 6),
        ])

    static let riff4: LevelPair = (
        silver: [
            L.silver("lead and bass take turns",
                     "When the lead only plays where the bass rests, the two lock together like one machine. Change which gaps you use and the groove changes."),
            K.quiz("How many gaps?", "", [
                K.hear([K.withLead(riffBass, K.notes(69, [1, 5, 9, 13]))], ["Every gap", "Every other gap"], 0, bars: 2),
                K.hear([K.withLead(riffBass, K.notes(69, [1, 9]))], ["Every gap", "Every other gap"], 1, bars: 2),
            ]),
            K.leadCopy("Copy the gap riff", "One note per gap: high A, G, high A, then down to E.",
                       rows: riffRows, target: K.line([(1, 69), (5, 67), (9, 69), (13, 64)]), backing: riffBass, threshold: 0.85),
            leadFix("Clear the clash", "One note fights the bass on step 11. Move it back to step 10, inside the gap.",
                    rows: riffRows, broken: K.line([(1, 60), (5, 64), (10, 67), (13, 60)]),
                    target: K.line([(1, 60), (5, 64), (9, 67), (13, 60)]), backing: riffBass),
            K.leadMake("Write a riff for the gaps", "Use at least three different gaps. At least 4 notes.", rows: riffRows, backing: riffBass, notes: 4),
        ],
        gold: [
            L.gold("everything in the gaps",
                   "Put the whole unit together: a one-note pulse, an arp shape and the dark A♯, all squeezed into the bass's gaps. Short notes keep it tight."),
            K.quiz("Quick check", "", [
                K.ask("The bass rolls on steps 3-4, 7-8, 11-12 and 15-16. Which steps are free for the lead?",
                      ["2, 6, 10 and 14", "3, 7, 11 and 15", "4, 8, 12 and 16"], 0, "Right after each kick, the bass is silent."),
            ]),
            K.leadCopy("Copy the interlocking riff", "Low A on each kick, then a note in the gap after it: C, E, A♯, C.",
                       rows: riffRows, target: K.line([(0, 57), (1, 60), (4, 57), (5, 64), (8, 57), (9, 58), (12, 57), (13, 60)]),
                       backing: riffBass, threshold: 0.9),
            leadFix("Fix the smear", "Every note should be one step long so it stays in its gap. Two notes are held into the bass.",
                    rows: riffRows,
                    broken: [NoteEvent(1, 69, 3), NoteEvent(5, 64), NoteEvent(9, 69, 3), NoteEvent(13, 58)],
                    target: K.line([(1, 69), (5, 64), (9, 69), (13, 58)]), backing: riffBass),
            K.leadMake("Make it yours", "A full riff in the gaps, with A♯ at least once. At least 6 notes.", rows: riffRows, backing: riffBass, notes: 6),
        ])

    // MARK: - Tech House: Keys & Transposing

    static let keyRows = TH.keyRows
    static let keyBed = TH.keyBed
    static let lineInC = TH.lineInC
    static let lineInD = [NoteEvent(1, 38), NoteEvent(3, 38), NoteEvent(6, 45), NoteEvent(9, 41), NoteEvent(11, 38), NoteEvent(14, 45)]
    static func up(_ notes: [NoteEvent], _ n: Int) -> [NoteEvent] { notes.map { NoteEvent($0.step, $0.pitch + n, $0.length) } }
    static let offHats = [1, 3, 5, 7, 9, 11, 13, 15]
    static let cfBed = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: offHats, chords: [K.ch(2, .cm7, 6), K.ch(10, .fm7, 6)])
    static let stepRiff = K.line([(0, 36), (2, 39), (4, 43), (8, 38), (10, 41), (12, 45)])

    static let key1: LevelPair = (
        silver: [
            L.silver("transpose down too",
                     "Transposing works in both directions. Down makes a line darker and heavier, up makes it brighter. Every note moves the same amount, or the shape breaks."),
            K.quiz("Up or down?", "The same line twice. Did the second one move up or down?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: lineInC), Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: up(lineInC, 2))],
                       ["Moved up", "Moved down"], 0, question: "Did the second line move up or down?"),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: lineInD), Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: up(lineInD, -2))],
                       ["Moved up", "Moved down"], 1, question: "Did the second line move up or down?"),
            ]),
            .pianoRoll(PianoRollTask(
                prompt: "Move this line down to C",
                hint: "This line is in D. Move every note down one whole step: D becomes C, F becomes D♯, A becomes G. Keep the rhythm.",
                mode: .rule, rows: keyRows, target: up(lineInD, -2), backing: keyBed, start: lineInD)),
            K.fixNotes("Find the note that didn't move", "Someone moved the C line up to D but forgot one note. Every note should be one whole step higher.",
                       rows: keyRows, broken: up(lineInC, 2).map { $0.step == 7 ? NoteEvent(7, 39) : $0 }, target: up(lineInC, 2),
                       backing: keyBed),
            K.bassMake("Write a line in D", "Use D, F, G, A and the high C. At least 5 notes.", rows: keyRows, backing: keyBed, notes: 5),
        ],
        gold: [
            L.gold("lift the energy",
                   "Late in a track, producers often move the whole groove up a step for a final lift. The same line suddenly feels more urgent."),
            K.quiz("Quick check", "", [
                K.ask("You move a line up a whole step. How far does each note move?", ["Two keys on the piano", "One key", "It depends on the note"], 0,
                      "A whole step is two half steps. Every note moves the same, so the shape survives."),
                K.ask("C moved up a whole step becomes...", ["D", "C♯", "E"], 0),
                K.ask("G moved up a whole step becomes...", ["A", "G♯", "B♭"], 0),
            ]),
            K.bassCopy("Copy the line in C", "Low, low, a jump up to G, then back down.", rows: keyRows,
                       target: K.line([(0, 36), (3, 36), (6, 43), (8, 41), (10, 36), (13, 39)]), backing: keyBed, threshold: 0.9),
            .pianoRoll(PianoRollTask(
                prompt: "Now lift it to D",
                hint: "Move every note up a whole step. C becomes D, D♯ becomes F, F becomes G, G becomes A.",
                mode: .rule, rows: keyRows, target: up(K.line([(0, 36), (3, 36), (6, 43), (8, 41), (10, 36), (13, 39)]), 2),
                backing: keyBed, start: K.line([(0, 36), (3, 36), (6, 43), (8, 41), (10, 36), (13, 39)]))),
            K.bassMake("Make it yours", "Write a groove in D using D, F, G, A and high C. At least 6 notes.", rows: keyRows, backing: keyBed, notes: 6),
        ])

    static let key2: LevelPair = (
        silver: [
            L.silver("how far did it move?",
                     "A key change can be a small step or a big jump. Small moves feel like a gentle lift. Big moves feel like a whole new section."),
            K.quiz("Step or leap?", "A riff, then the same riff in a new key.", [
                K.round(K.phrase([36, 39, 43, 38, 41, 45]), ["Up a step", "Up a lot", "Down a step", "Down a lot"], 0),
                K.round(K.phrase([38, 41, 45, 36, 39, 43]), ["Up a step", "Up a lot", "Down a step", "Down a lot"], 2),
                K.round(K.phrase([36, 39, 43, 43, 46, 50]), ["Up a step", "Up a lot", "Down a step", "Down a lot"], 1),
                K.round(K.phrase([48, 51, 55, 41, 44, 48]), ["Up a step", "Up a lot", "Down a step", "Down a lot"], 3),
            ]),
            K.bassCopy("Copy the stepping riff", "C, D♯, G, then the same shape a whole step higher: D, F, A.", rows: keyRows,
                       target: stepRiff, backing: keyBed, threshold: 0.85),
            K.fixNotes("One note missed the move", "The second half should be the first half moved up a whole step. One note is still in the old key.",
                       rows: keyRows, broken: stepRiff.map { $0.step == 10 ? NoteEvent(10, 39) : $0 }, target: stepRiff, backing: keyBed),
            K.bassMake("Make it yours", "Write a three-note riff in C, then play it again a whole step higher. At least 6 notes.",
                       rows: keyRows, backing: keyBed, notes: 6),
        ],
        gold: [
            L.gold("key changes in a track",
                   "In a real track the chords move key too. Listen for the whole groove lifting or sinking, not just one line."),
            K.quiz("Did the groove move?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], chords: [K.ch(0, .cm7, 8)]), Pattern(kick: [0, 4, 8, 12], chords: [K.ch(0, .dm7, 8)])],
                       ["Moved up", "Moved down"], 0, question: "Did the second chord move up or down?"),
                K.hear([Pattern(kick: [0, 4, 8, 12], chords: [K.ch(0, .am7, 8)]), Pattern(kick: [0, 4, 8, 12], chords: [K.ch(0, .gm7, 8)])],
                       ["Moved up", "Moved down"], 1, question: "Did the second chord move up or down?"),
                K.hear([Pattern(kick: [0, 4, 8, 12], chords: [K.ch(0, .fm7, 8)]), Pattern(kick: [0, 4, 8, 12], chords: [K.ch(0, .gm7, 8)])],
                       ["Moved up", "Moved down"], 0, question: "Did the second chord move up or down?"),
            ]),
            K.lane("Hear the chord move", "One chord, then the same kind of chord a whole step higher.", .recreate,
                   palette: [.cm7, .dm7], backing: keyBed, target: [0: 0, 8: 1], length: 6),
            K.bassCopy("Copy the line that lifts", "The C line, then the same line a step higher in the second half.", rows: keyRows,
                       target: K.line([(0, 36), (2, 36), (3, 39), (8, 38), (10, 38), (11, 41)]), backing: keyBed, threshold: 0.9),
            K.bassMake("Make it yours", "A riff that changes key halfway: same shape, a step higher. At least 6 notes.",
                       rows: keyRows, backing: keyBed, notes: 6),
        ])

    static let key3: LevelPair = (
        silver: [
            L.silver("chords in any key",
                     "A chord keeps its colour when it moves. Count how far the first chord moved and every other chord follows by the same amount."),
            K.quiz("Quick check", "", [
                K.ask("Am7 up three half steps is Cm7. What is Em7 up three half steps?", ["Gm7", "Fm7", "G major"], 0,
                      "E up three half steps is G, and it stays a minor 7th."),
                K.round([.am7, .cm7], ["Same kind of chord", "A different kind"], 0, "Both minor 7ths, in different keys.",
                        question: "Is the second chord the same kind?"),
                K.round([.am7, .cmaj7], ["Same kind of chord", "A different kind"], 1, "Cmaj7 is a major 7th: brighter.",
                        question: "Is the second chord the same kind?"),
            ]),
            K.lane("Move it down to G minor", "Move every chord down a whole step: Am7 becomes Gm7, Dm7 becomes Cm7.", .rule,
                   palette: [.am7, .dm7, .gm7, .cm7], backing: keyBed, start: [2: 0, 6: 0, 10: 1, 14: 1], target: [2: 2, 6: 2, 10: 3, 14: 3]),
            K.lane("Fix the left-behind chord", "This loop was moved to C minor, but one Dm7 got left behind. Swap it for Fm7.", .recreate,
                   palette: [.am7, .dm7, .cm7, .fm7], backing: keyBed, start: [0: 2, 3: 2, 8: 3, 11: 1], target: [0: 2, 3: 2, 8: 3, 11: 3]),
            K.lane("Write in G minor", "A loop with Gm7 and Cm7. At least 4 stabs.", .create(.chordsAtLeast(4)), palette: [.gm7, .cm7], backing: keyBed),
        ],
        gold: [
            L.gold("move a loop for a vocal",
                   "A singer can't always hit your key. So you move the loop. Work out the first chord, then every chord moves the same distance."),
            K.quiz("Plan the move", "", [
                K.ask("Your loop is Am7 to Dm7. The vocal needs it a whole step lower. What do you play?", ["Gm7 to Cm7", "Bm7 to Em7", "Cm7 to Fm7"], 0),
                K.ask("And the bass under Am7 moves from A to...", ["G", "B", "C"], 0),
            ]),
            K.lane("Hear it moved", "The A minor loop, moved down a step. Listen for the new first chord.", .recreate,
                   palette: [.am7, .dm7, .gm7, .cm7], backing: keyBed, target: [0: 2, 4: 2, 8: 3, 12: 3], length: 2),
            K.lane("Fix the loop", "Moved up to C minor: Cm7, Cm7, Fm7, Fm7. The last two stabs were never moved.", .recreate,
                   palette: [.am7, .dm7, .cm7, .fm7], backing: keyBed, start: [1: 2, 5: 2, 9: 1, 13: 1], target: [1: 2, 5: 2, 9: 3, 13: 3]),
            K.lane("Make it yours", "Write a loop in one key in the first half, then the same loop in a new key in the second. At least 4 stabs.",
                   .create(.chordsAtLeast(4)), palette: [.am7, .dm7, .gm7, .cm7, .fm7], backing: keyBed),
        ])

    static let key4: LevelPair = (
        silver: [
            L.silver("move the whole line",
                     "Roots are only the start. A full bassline moves too: every note shifts by the same amount as the chords."),
            K.quiz("Quick check", "", [
                K.ask("The chords moved from Am7 and Dm7 up to Cm7 and Fm7. That's three half steps. Where does a bass A go?", ["C", "B", "D"], 0),
                K.ask("And a bass D?", ["F", "E", "G"], 0),
            ]),
            K.fixNotes("Fix the bass", "The chords are Cm7, then Fm7. Under Fm7 the bass should be F. It's still on D from the old key.",
                       rows: keyRows, broken: [NoteEvent(2, 36, 4), NoteEvent(10, 38, 4)], target: [NoteEvent(2, 36, 4), NoteEvent(10, 41, 4)],
                       backing: cfBed),
            K.bassCopy("Copy this line in C minor", "C, an octave flick, C again, then F twice and a G.", rows: keyRows,
                       target: K.line([(2, 36), (3, 48), (6, 36), (10, 41), (11, 41), (14, 43)]), backing: cfBed, threshold: 0.85),
            K.bassMake("Write a line in C minor", "Use C, D♯, F, G and A♯ under the chords. At least 6 notes.", rows: keyRows, backing: cfBed, notes: 6),
        ],
        gold: [
            L.gold("transpose the whole groove",
                   "Chords first, then the bass, then check it all together. That's how you move a full idea into the key a vocal needs."),
            K.lane("First, move the chords", "Am7 becomes Cm7. Dm7 becomes Fm7.", .rule, palette: [.am7, .dm7, .cm7, .fm7], backing: keyBed,
                   start: [2: 0, 10: 1], target: [2: 2, 10: 3], length: 6),
            .pianoRoll(PianoRollTask(
                prompt: "Now move the bass",
                hint: "This line is still in A minor. Move every note up three half steps: A to high C, D to F, G to A♯.",
                mode: .rule, rows: keyRows,
                target: K.line([(2, 48), (6, 48), (10, 41), (11, 41), (14, 46)]), backing: cfBed,
                start: K.line([(2, 45), (6, 45), (10, 38), (11, 38), (14, 43)]))),
            K.fixNotes("Check it together", "One note still rubs against Fm7. It should be F, three rows above D.",
                       rows: keyRows, broken: K.line([(2, 36), (6, 43), (10, 38), (11, 41), (14, 46)]),
                       target: K.line([(2, 36), (6, 43), (10, 41), (11, 41), (14, 46)]), backing: cfBed),
            K.bassMake("Make it yours", "A full line in C minor under Cm7 and Fm7. At least 7 notes.", rows: keyRows, backing: cfBed, notes: 7),
        ])

    // MARK: - UK Garage: Bass & Chords Talking

    static let gRows = G.rows
    static let talkDrums = G.talkDrums
    static let gapBass = G.gapBass
    static let busyBass = K.line([(0, 40), (2, 40), (5, 43), (8, 45), (10, 45), (13, 43)])
    static func with(bass: [NoteEvent] = [], chords: [ChordEvent] = [], hats: [Int] = [2, 6, 10, 14]) -> Pattern {
        Pattern(kick: [0, 10], clap: [4, 12], hat: hats, bass: bass, chords: chords)
    }
    static let skip = [2, 3, 6, 7, 10, 11, 14, 15]
    static let twoStabs = [K.ch(0, .em9, 2), K.ch(8, .am9, 2)]
    static let fourStabs = [K.ch(1, .em9), K.ch(5, .em9), K.ch(9, .am9), K.ch(13, .am9)]

    static let talk1: LevelPair = (
        silver: [
            L.silver("smaller gaps",
                     "The busier the bass, the smaller its gaps. Find where it rests before you place a stab."),
            K.quiz("Find the gap", "", [
                K.ask("The bass plays on steps 1, 3, 6, 9, 11 and 14. Which step is free for a stab?", ["Step 4", "Step 6", "Step 9"], 0),
                K.hear([with(bass: busyBass, chords: [K.ch(3, .em9), K.ch(11, .am9)])], ["In the gaps", "On the bass"], 0, bars: 2),
                K.hear([with(bass: busyBass, chords: [K.ch(2, .em9), K.ch(10, .am9)])], ["In the gaps", "On the bass"], 1, bars: 2),
            ]),
            K.lane("Fix the stab", "One stab sits right on a bass note, on step 11. Move it one step later.", .recreate,
                   palette: [.em9, .am9], backing: with(bass: busyBass), start: [3: 0, 6: 0, 10: 1, 14: 1], target: [3: 0, 6: 0, 11: 1, 14: 1]),
            K.lane("Copy the gap stabs", "Four stabs, all in the gaps. Em9 first, then Am9.", .recreate,
                   palette: [.em9, .am9], backing: with(bass: busyBass), target: [1: 0, 4: 0, 9: 1, 12: 1]),
            K.lane("Write stabs for this bass", "Every stab in a gap. At least 4.", .create(.chordsAtLeast(4)), palette: [.em9, .am9],
                   backing: with(bass: busyBass)),
        ],
        gold: [
            L.gold("gaps with swing",
                   "Add skippy hats and the gaps get busier still. Short stabs on the swung 16ths fit between the bass and the kick."),
            K.quiz("Clean or crowded?", "", [
                K.hear([with(bass: gapBass, chords: [K.ch(5, .em9), K.ch(13, .am9)], hats: skip)], ["Clean", "Crowded"], 0, bars: 2, swing: 0.3),
                K.hear([with(bass: gapBass, chords: [K.ch(0, .em9, 3), K.ch(8, .am9, 3)], hats: skip)], ["Clean", "Crowded"], 1,
                       "The stabs land on the bass and ring over it.", bars: 2, swing: 0.3),
            ]),
            K.lane("Copy the swung gap stabs", "Six stabs: a single, then a pair, in each half.", .recreate,
                   palette: [.em9, .am9], backing: with(bass: gapBass, hats: skip), target: [2: 0, 5: 0, 6: 0, 12: 1, 13: 1, 14: 1]),
            K.lane("Fix the clash", "The first Am9 stab lands on the bass, on step 12. Move it a step later.", .recreate,
                   palette: [.em9, .am9], backing: with(bass: gapBass, hats: skip),
                   start: [2: 0, 5: 0, 6: 0, 11: 1, 13: 1, 14: 1], target: [2: 0, 5: 0, 6: 0, 12: 1, 13: 1, 14: 1]),
            K.lane("Make it yours", "At least 5 stabs, none on the bass.", .create(.chordsAtLeast(5)), palette: [.em9, .am9, .cmaj9],
                   backing: with(bass: gapBass, hats: skip)),
        ])

    static let talk2: LevelPair = (
        silver: [
            L.silver("answers that move",
                     "A reply doesn't have to repeat the root. Step up, jump an octave, or walk down. Just wait until the chord has spoken."),
            K.quiz("Answering or talking over?", "", [
                K.hear([with(bass: [NoteEvent(2, 40, 2), NoteEvent(10, 45, 2)], chords: twoStabs)], ["Answering", "Talking over"], 0, bars: 2),
                K.hear([with(bass: [NoteEvent(0, 40, 2), NoteEvent(8, 45, 2)], chords: twoStabs)], ["Answering", "Talking over"], 1,
                       "The bass lands on the chord, so neither part is heard clearly.", bars: 2),
            ]),
            K.fixNotes("Wait your turn", "The second reply starts on top of the Am9 stab on step 9. Move that note two steps later.",
                       rows: gRows, broken: K.line([(2, 40), (3, 47), (8, 45), (11, 43)]), target: K.line([(2, 40), (3, 47), (10, 45), (11, 43)]),
                       backing: with(chords: twoStabs)),
            K.bassCopy("Copy the walking replies", "After Em9, high B walks down. After Am9, E walks down to low B.", rows: gRows,
                       target: K.line([(2, 47), (3, 45), (5, 43), (10, 40), (11, 38), (13, 35)]), backing: with(chords: twoStabs), threshold: 0.85),
            K.bassMake("Write your own replies", "Reply to each chord with two or three notes. At least 5 notes.", rows: gRows,
                       backing: with(chords: twoStabs), notes: 5),
        ],
        gold: [
            L.gold("a longer conversation",
                   "With four stabs, the bass gets four chances to reply. Keep each reply short so it's done before the next stab."),
            K.quiz("Quick check", "", [
                K.ask("The chords stab on steps 2, 6, 10 and 14. Where should each reply start?", ["Just after each stab", "On the same steps", "Only on step 1"], 0),
            ]),
            K.bassCopy("Copy the four replies", "A two-note reply after the first stab, then single notes after the rest.", rows: gRows,
                       target: K.line([(2, 40), (3, 43), (6, 40), (10, 45), (11, 47), (14, 45)]), backing: with(chords: fourStabs, hats: skip),
                       threshold: 0.9),
            K.fixNotes("Fix the early reply", "The second reply lands on the stab on step 6. Move it a step later.", rows: gRows,
                       broken: K.line([(2, 40), (5, 43), (10, 45), (14, 45)]), target: K.line([(2, 40), (6, 43), (10, 45), (14, 45)]),
                       backing: with(chords: fourStabs, hats: skip)),
            K.bassMake("Make it yours", "Reply to all four stabs. At least 6 notes.", rows: gRows, backing: with(chords: fourStabs, hats: skip), notes: 6),
        ])

    static let talk3: LevelPair = (
        silver: [
            L.silver("pick your moments",
                     "Shared hits only work because they're rare. Most of the bar should still take turns, with one or two hits together as the punch."),
            K.quiz("Quick check", "", [
                K.ask("Why not hit together on every note?", ["Then nothing stands out", "It breaks a rule", "The kick gets quieter"], 0,
                      "An accent only works if the rest is different."),
                K.hear([with(bass: [NoteEvent(0, 40, 2), NoteEvent(10, 45, 2)], chords: [K.ch(0, .em9), K.ch(10, .am9)])], ["One", "Two"], 1,
                       bars: 2, question: "How many hits land together?"),
                K.hear([with(bass: [NoteEvent(0, 40, 2), NoteEvent(10, 45, 2)], chords: [K.ch(0, .em9), K.ch(13, .am9)])], ["One", "Two"], 0,
                       bars: 2, question: "How many hits land together?"),
            ]),
            K.lane("Hit, then answer", "Each chord hits with a bass note, then answers in a gap. Em9 first, then Am9.", .recreate,
                   palette: [.em9, .am9], backing: with(bass: K.line([(0, 40), (3, 40), (10, 45), (13, 45)])),
                   target: [0: 0, 5: 0, 10: 1, 15: 1]),
            K.lane("One shared hit too many", "The stab on step 4 lands with the bass. Move it to step 6, into the gap.", .recreate,
                   palette: [.em9, .am9], backing: with(bass: K.line([(0, 40), (3, 40), (10, 45), (13, 45)])),
                   start: [0: 0, 3: 0, 10: 1, 15: 1], target: [0: 0, 5: 0, 10: 1, 15: 1]),
            K.lane("Write it yourself", "Hit with the bass once or twice, then fill the gaps. At least 4 stabs.", .create(.chordsAtLeast(4)),
                   palette: [.em9, .am9], backing: with(bass: K.line([(0, 40), (3, 40), (10, 45), (13, 45)]))),
        ],
        gold: [
            L.gold("accents with the whole band",
                   "The biggest accents land the kick, bass and chords all at once. Garage saves them for the downbeat and the second kick."),
            K.quiz("Where's the big hit?", "", [
                K.hear([with(bass: [NoteEvent(0, 40, 2), NoteEvent(6, 43)], chords: [K.ch(0, .em9, 2), K.ch(13, .am9)])],
                       ["Start of the bar", "The second kick"], 0, bars: 2),
                K.hear([with(bass: [NoteEvent(3, 40), NoteEvent(10, 45, 2)], chords: [K.ch(5, .em9), K.ch(10, .am9, 2)])],
                       ["Start of the bar", "The second kick"], 1, bars: 2),
            ]),
            K.fixNotes("Land the accent", "The bass should land with the Am9 stab and the second kick on step 11. It's a step late.", rows: gRows,
                       broken: [NoteEvent(0, 40, 2), NoteEvent(3, 47), NoteEvent(7, 40), NoteEvent(11, 45, 2), NoteEvent(13, 43)],
                       target: [NoteEvent(0, 40, 2), NoteEvent(3, 47), NoteEvent(7, 40), NoteEvent(10, 45, 2), NoteEvent(13, 43)],
                       backing: with(chords: [K.ch(0, .em9, 2), K.ch(5, .em9), K.ch(10, .am9, 2), K.ch(14, .am9)], hats: skip)),
            K.bassCopy("Copy the accented line", "Two big hits with the chords. Everything else replies in the gaps.", rows: gRows,
                       target: [NoteEvent(0, 40, 2), NoteEvent(2, 47), NoteEvent(7, 43), NoteEvent(10, 45, 2), NoteEvent(15, 38)],
                       backing: with(chords: [K.ch(0, .em9, 2), K.ch(5, .em9), K.ch(10, .am9, 2), K.ch(14, .am9)], hats: skip), threshold: 0.9),
            K.bassMake("Make it yours", "Hit with the stabs on steps 1 and 11, and answer the others. At least 5 notes.", rows: gRows,
                       backing: with(chords: [K.ch(0, .em9, 2), K.ch(5, .em9), K.ch(10, .am9, 2), K.ch(14, .am9)], hats: skip), notes: 5),
        ])

    static let talk4: LevelPair = (
        silver: [
            L.silver("listen to the other part first",
                     "Before you write, listen to what the other part leaves empty. Every gap is an invitation, and one shared hit is the punctuation."),
            K.bassCopy("Copy the bass side", "Replies after the first two stabs, then one shared hit with Am9 on step 10.", rows: gRows,
                       target: [NoteEvent(2, 40), NoteEvent(3, 40), NoteEvent(7, 43), NoteEvent(9, 45, 2), NoteEvent(15, 38)],
                       backing: with(chords: fourStabs), threshold: 0.85),
            K.lane("Copy the chord side", "Three stabs in the bass's gaps, and one that hits with it on step 9.", .recreate,
                   palette: [.em9, .am9], backing: with(bass: gapBass), target: [5: 0, 6: 0, 8: 1, 13: 1]),
            K.fixNotes("Stop talking over", "Three notes talk over the stabs. Move each one a step later so it answers. Keep the one on step 10 as the shared hit.",
                       rows: gRows, broken: K.line([(1, 40), (5, 40), (9, 45), (13, 45)]), target: K.line([(2, 40), (6, 40), (9, 45), (14, 45)]),
                       backing: with(chords: fourStabs)),
            K.lane("Write the chords", "Leave the bass room, then hit together once. At least 4 stabs.", .create(.chordsAtLeast(4)),
                   palette: [.em9, .am9, .cmaj9], backing: with(bass: gapBass)),
        ],
        gold: [
            L.gold("a full garage conversation",
                   "Skippy drums, bass and chords, all talking. Use every move: leave gaps, answer, and save one big hit together."),
            K.quiz("Name the move", "", [
                K.hear([with(bass: [NoteEvent(2, 40, 2), NoteEvent(10, 45, 2)], chords: twoStabs, hats: skip)],
                       ["Taking turns", "Hitting together"], 0, bars: 2),
                K.hear([with(bass: [NoteEvent(0, 40, 2), NoteEvent(8, 45, 2)], chords: twoStabs, hats: skip)],
                       ["Taking turns", "Hitting together"], 1, bars: 2),
            ]),
            K.bassCopy("Copy the full riff", "Answers after Em9, a shared hit with Am9 on step 11, then a reply to Cmaj9.", rows: gRows,
                       target: [NoteEvent(3, 40), NoteEvent(4, 47), NoteEvent(8, 43), NoteEvent(10, 45, 2), NoteEvent(15, 43)],
                       backing: with(chords: [K.ch(1, .em9), K.ch(6, .em9), K.ch(10, .am9), K.ch(14, .cmaj9)], hats: skip), threshold: 0.9),
            K.lane("Write the chords", "Stabs around this bass, with one shared hit. At least 5.", .create(.chordsAtLeast(5)),
                   palette: [.em9, .am9, .cmaj9], backing: with(bass: gapBass, hats: skip)),
            K.bassMake("Write the bass", "Answer these stabs and hit with one of them. At least 6 notes.", rows: gRows,
                       backing: with(chords: [K.ch(1, .em9), K.ch(6, .em9), K.ch(10, .am9), K.ch(14, .cmaj9)], hats: skip), notes: 6),
        ])
}
