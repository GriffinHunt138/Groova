//
//  GarageLevels.swift
//  Groova
//
//  Hand-written Silver and Gold levels for the UK Garage course.
//

import Foundation

nonisolated enum GarageLevels {
    typealias G = GarageCourse
    static let u = K.u
    static let rows = G.rows
    static let skipHats = [2, 3, 6, 7, 10, 11, 14, 15]
    static let kit: [DrumTrack] = [.kick, .clap, .hat, .perc]
    static let bassLoop = Pattern(kick: [0, 10], clap: [4, 12], bass: G.bassline)
    static let speed = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])

    static func bass(_ prompt: String, _ hint: String, _ notes: [NoteEvent], backing: Pattern = G.twoStep,
                     threshold: Double = 0.85) -> LessonStep {
        L.bass(prompt, hint, notes, backing: backing, rows: rows, threshold: threshold)
    }

    static func bassMake(_ prompt: String, _ hint: String, backing: Pattern = G.skippy, notes: Int) -> LessonStep {
        L.bassMake(prompt, hint, backing: backing, notes: notes, rows: rows)
    }

    static let all: [String: LevelPair] = [
        "ukg.u1.l1": u1l1, "ukg.u1.l2": u1l2, "ukg.u1.l3": u1l3, "ukg.u1.l4": u1l4, "ukg.u1.l5": u1l5,
        "ukg.u2.l1": u2l1, "ukg.u2.l2": u2l2, "ukg.u2.l3": u2l3, "ukg.u2.l4": u2l4, "ukg.u2.l5": u2l5,
        "ukg.u3.l1": u3l1, "ukg.u3.l2": u3l2, "ukg.u3.l3": u3l3, "ukg.u3.l4": u3l4, "ukg.u3.l5": u3l5,
        "ukg.u4.l3": u4l3, "ukg.u4.l4": u4l4, "ukg.u4.l5": u4l5,
    ]

    // MARK: Unit 1 — The Two-Step

    static let u1l1: LevelPair = (
        silver: [
            L.silver("kick placement",
                     "Two-step means the kick skips beats 2 and 4. Where the second kick lands changes the whole bounce. Hear new placements."),
            L.copy("Copy this two-step", "The second kick lands a step earlier than before.", tracks: [.kick, .clap, .hat],
                   edit: [.kick], start: Pattern(clap: [4, 12], hat: skipHats),
                   target: Pattern(kick: [0, 9], clap: [4, 12], hat: skipHats)),
            L.copy("Copy the three-kick two-step", "A pickup kick leads into the second clap.", tracks: [.kick, .clap, .hat],
                   edit: [.kick], start: Pattern(clap: [4, 12], hat: skipHats),
                   target: Pattern(kick: [0, 10, 11], clap: [4, 12], hat: skipHats)),
            K.swingMake("Heavier shuffle", "Push swing past 30%.", tracks: [.kick, .clap, .hat],
                        start: Pattern(kick: [0, 10], clap: [4, 12], hat: Array(0..<16)), atLeast: 0.3),
        ],
        gold: [
            L.gold("the full two-step",
                   "Kick, clap, skippy hats and rims all push and pull against each other. Rebuild full grooves from nothing."),
            L.copy("Rebuild this groove", "Three kicks. Two rims fill the gaps near the end.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14], perc: [9, 15]),
                   threshold: 0.9),
            L.copy("Rebuild this one", "The kick plays three times and the rims answer.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: skipHats, perc: [7, 13]), threshold: 0.9),
            L.make("Make it yours", "A full two-step groove from silence. At least 3 kicks.", tracks: kit,
                   edit: Set(kit), goal: .atLeast(.kick, 3)),
        ])

    static let u1l2: LevelPair = (
        silver: [
            L.silver("hats that skip",
                     "Garage hats work in pairs: the second hit of each pair is the one swing pushes late. Change which pairs play and the skip changes."),
            L.copy("Copy these hats", "Pairs before each beat this time.", tracks: [.kick, .clap, .hat], edit: [.hat],
                   start: Pattern(kick: [0, 10], clap: [4, 12]),
                   target: Pattern(kick: [0, 10], clap: [4, 12], hat: [1, 2, 5, 6, 9, 10, 13, 14])),
            L.copy("Copy the open-hat skip", "Closed hat pairs plus two open hats.", tracks: [.kick, .clap, .hat, .openHat],
                   edit: [.hat, .openHat], start: Pattern(kick: [0, 10], clap: [4, 12]),
                   target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 10, 11], openHat: [6, 14])),
            L.make("Write skippy hats", "At least 8 hats.", tracks: [.kick, .clap, .hat], edit: [.hat],
                   start: Pattern(kick: [0, 10], clap: [4, 12]), goal: .atLeast(.hat, 8)),
        ],
        gold: [
            L.gold("hats and swing together",
                   "The same hats sound totally different at 15% and 35% swing. Set the swing, then rebuild hats under it."),
            K.swingMake("Find the 2-step swing", "Past 35% for that rolling skip.", tracks: [.kick, .clap, .hat],
                        start: Pattern(kick: [0, 10], clap: [4, 12], hat: [1, 2, 5, 6, 9, 10, 13, 14]), atLeast: 0.35),
            L.copy("Rebuild all the hats", "Closed pairs, two open hats and one rim.", tracks: [.kick, .clap, .hat, .openHat, .perc],
                   edit: [.hat, .openHat, .perc], start: Pattern(kick: [0, 10], clap: [4, 12]),
                   target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 7, 10, 11, 15], openHat: [6, 14], perc: [9]),
                   threshold: 0.9),
            L.make("Make it yours", "Hats and open hats. At least 8 closed hats.", tracks: [.kick, .clap, .hat, .openHat],
                   edit: [.hat, .openHat], start: Pattern(kick: [0, 10], clap: [4, 12]), goal: .atLeast(.hat, 8)),
        ])

    static let u1l3: LevelPair = (
        silver: [
            L.silver("ghosts in new places",
                     "Ghost rims fill the gaps that the kick and clap leave. Move them and the groove talks differently."),
            L.copy("Copy these ghost rims", "Just before each clap.", tracks: kit, edit: [.perc], start: G.twoStep,
                   target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 11])),
            L.copy("Copy the busier rims", "Four rims around the second kick.", tracks: kit, edit: [.perc], start: G.twoStep,
                   target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [5, 7, 9, 15])),
            L.make("Write ghost rims", "At least 4.", tracks: kit, edit: [.perc], start: G.twoStep, goal: .atLeast(.perc, 4)),
        ],
        gold: [
            L.gold("ghost claps too",
                   "Garage producers ghost the clap as well as the rim. Rebuild both, then the whole kit."),
            L.copy("Copy rims and ghost claps", "Each clap has a ghost clap three steps later. Three rims fill the gaps.", tracks: kit, edit: [.clap, .perc],
                   start: Pattern(kick: [0, 10], hat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 10], clap: [4, 7, 12, 15], hat: [2, 6, 10, 14], perc: [3, 9, 13]),
                   threshold: 0.9),
            L.copy("Rebuild the full kit", "One ghost clap at the end, two rims around the middle.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 10], clap: [4, 12, 15], hat: skipHats, perc: [5, 9]), threshold: 0.9),
            L.make("Make it yours", "Write rims and claps. At least 4 rims.", tracks: kit, edit: [.clap, .perc],
                   start: Pattern(kick: [0, 10], hat: skipHats), goal: .atLeast(.perc, 4)),
        ])

    static let u1l4: LevelPair = (
        silver: [
            L.silver("push and pull",
                     "Kicks before the clap push the groove forward. Kicks just after it pull it back. Hear which is which."),
            L.copy("Copy the pushing kicks", "Kicks just before each clap.", tracks: [.kick, .clap, .hat], edit: [.kick],
                   start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 3, 11], clap: [4, 12], hat: [2, 6, 10, 14])),
            L.copy("Copy the pulling kicks", "Kicks just after each clap.", tracks: [.kick, .clap, .hat], edit: [.kick],
                   start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 5, 13], clap: [4, 12], hat: [2, 6, 10, 14])),
        ],
        gold: [
            L.gold("push and pull across the kit",
                   "Rims can push and pull just like kicks. Rebuild kicks and rims that lean against the claps."),
            L.copy("Copy these four kicks", "One on the downbeat, then three that push.", tracks: [.kick, .clap, .hat], edit: [.kick],
                   start: Pattern(clap: [4, 12], hat: skipHats),
                   target: Pattern(kick: [0, 3, 7, 10], clap: [4, 12], hat: skipHats), threshold: 0.9),
            L.copy("Copy kicks and rims", "Kicks pull after the claps. Rims push into them.", tracks: kit, edit: [.kick, .perc],
                   start: Pattern(clap: [4, 12], hat: skipHats),
                   target: Pattern(kick: [0, 5, 10, 13], clap: [4, 12], hat: skipHats, perc: [3, 11, 15]), threshold: 0.9),
            L.make("Make it yours", "Write your own push-and-pull kicks. At least 3.", tracks: [.kick, .clap, .hat],
                   edit: [.kick], start: Pattern(clap: [4, 12], hat: skipHats), goal: .atLeast(.kick, 3)),
        ])

    static let u1l5: LevelPair = (
        silver: [
            L.silver("kicks with rims",
                     "Your own two-step works best when the kick and rims answer each other."),
            L.copy("Copy this answer", "Kick, then rim, then kick.", tracks: kit, edit: [.kick, .perc],
                   start: Pattern(clap: [4, 12], hat: skipHats),
                   target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: skipHats, perc: [3, 9, 15])),
            L.make("Write your own two-step", "At least 3 kicks and 3 rims.", tracks: kit, edit: [.kick, .perc],
                   start: Pattern(clap: [4, 12], hat: skipHats), goal: .atLeast(.perc, 3)),
        ],
        gold: [
            L.gold("a groove from nothing", "Every part is yours now."),
            L.copy("Rebuild this groove first", "Three kicks, gappy hats and two rims.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 7, 10, 14, 15], perc: [9, 13]),
                   threshold: 0.9),
            L.make("Make it yours", "A full two-step from silence. At least 6 hats.", tracks: kit, edit: Set(kit),
                   goal: .atLeast(.hat, 6)),
        ])

    // MARK: Unit 2 — Bouncy Bass

    static let u2l1: LevelPair = (
        silver: [
            L.silver("envelope and length",
                     "Garage bass changes character from round sub to bright pluck. Envelope adds a 'wow' at the start of each note."),
            K.lab("Match the warm, rounded bass", "Dark, little bite, notes held.", [.bassCutoff, .bassEnv, .bassDecay], start: [0.6, 0.6, 0.2],
                  target: [0.25, 0.15, 0.6], loop: bassLoop),
            K.lab("Match the plucky garage bass", "Brighter with lots of bite. Short notes.", [.bassCutoff, .bassEnv, .bassDecay], start: [0.25, 0.15, 0.6],
                  target: [0.5, 0.7, 0.2], loop: bassLoop),
        ],
        gold: [
            L.gold("bass from every era",
                   "90s garage bass is warm and bouncy. Speed garage bass is a wobbling, resonant reese. Match both with all four knobs."),
            K.lab("Match the 90s bass", "Darkish, a little bite, almost no resonance.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay], start: [0.5, 0.5, 0.5, 0.5],
                  target: [0.3, 0.35, 0.15, 0.55], loop: bassLoop),
            K.lab("Match the speed garage bass", "Lots of bite and resonance, shortish notes.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay],
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.45, 0.75, 0.7, 0.35], loop: bassLoop),
            K.lab("Make it yours", "Design a bass you'd want under a vocal.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay],
                  start: [0.5, 0.5, 0.5, 0.5], loop: bassLoop),
        ])

    static let u2l2: LevelPair = (
        silver: [
            L.silver("bass answers the kick",
                     "Garage bass skips around the kick. When the kick plays, the bass waits."),
            bass("Copy this skipping bass", "E, G, E, D. Every note dodges the kick.", [NoteEvent(1, 40), NoteEvent(5, 43), NoteEvent(8, 40), NoteEvent(13, 38)]),
            bass("Copy the busier skip", "It climbs to A, then walks down to low B at the end.", [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(6, 45), NoteEvent(9, 43),
                                              NoteEvent(13, 38), NoteEvent(15, 35)]),
            bassMake("Write a skipping bassline", "At least 5 notes, none with the kick.", backing: G.twoStep, notes: 5),
        ],
        gold: [
            L.gold("bass with the hats",
                   "With skippy hats and swing, the bass has to sit in even smaller gaps."),
            bass("Copy this line", "Up from E to A, then down to low B.", [NoteEvent(0, 40), NoteEvent(2, 40), NoteEvent(5, 43), NoteEvent(7, 45),
                                        NoteEvent(11, 38), NoteEvent(13, 40), NoteEvent(15, 35)], backing: G.skippy,
                 threshold: 0.9),
            bass("Copy this line", "An octave jump first, then it settles on E.", [NoteEvent(1, 35), NoteEvent(3, 47), NoteEvent(6, 40), NoteEvent(9, 43),
                                        NoteEvent(11, 40), NoteEvent(14, 38)], backing: G.skippy, threshold: 0.9),
            bassMake("Make it yours", "At least 7 notes.", notes: 7),
        ])

    static let u2l3: LevelPair = (
        silver: [
            L.silver("length makes the bounce",
                     "The same notes held for different lengths feel completely different. Long notes groove, short notes bounce."),
            bass("Copy this bassline", "Three long notes.", [NoteEvent(0, 40, 3), NoteEvent(6, 43), NoteEvent(7, 45),
                                                             NoteEvent(10, 38, 3), NoteEvent(15, 35)]),
            bass("Copy this one", "All short.", [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(6, 43), NoteEvent(8, 40),
                                                 NoteEvent(10, 38), NoteEvent(14, 35)]),
        ],
        gold: [
            L.gold("long and short together",
                   "The best garage lines mix long notes and quick skips in one bar."),
            bass("Copy this bassline", "Mix of long and short. Four notes hold for two steps.", [NoteEvent(0, 40, 2), NoteEvent(3, 40), NoteEvent(4, 43), NoteEvent(6, 45, 2),
                                            NoteEvent(10, 38, 2), NoteEvent(13, 35), NoteEvent(14, 38, 2)], threshold: 0.9),
            bass("Copy this one", "Low B holds for three steps. It ends on a long G.", [NoteEvent(0, 35, 3), NoteEvent(3, 47), NoteEvent(7, 45, 2), NoteEvent(11, 40),
                                       NoteEvent(12, 43, 3)], threshold: 0.9),
            bassMake("Make it yours", "Mix long and short. At least 6 notes.", notes: 6),
        ])

    static let u2l4: LevelPair = (
        silver: [
            L.silver("jumps on new notes",
                     "Big jumps work from any note, not just B. Start on E and leap up and the line moves somewhere new."),
            bass("Jump from E up to B", "E on steps 1 and 9, then jump up to B on steps 4 and 12.",
                 [NoteEvent(0, 40), NoteEvent(3, 47), NoteEvent(8, 40), NoteEvent(11, 47)]),
            bass("Copy this octave line", "Octave jumps on B, then it steps down to A and a long G.", [NoteEvent(0, 35), NoteEvent(1, 47), NoteEvent(6, 35), NoteEvent(9, 47),
                                               NoteEvent(10, 45), NoteEvent(14, 43, 2)]),
        ],
        gold: [
            L.gold("octaves and walks",
                   "Combine octave jumps with notes that walk down the scale and the bass sings."),
            bass("Copy this line", "An octave jump, then a walk down. Then again, ending on D.", [NoteEvent(0, 35), NoteEvent(2, 47), NoteEvent(3, 45), NoteEvent(6, 43),
                                        NoteEvent(7, 40), NoteEvent(10, 35), NoteEvent(11, 47), NoteEvent(14, 38)],
                 threshold: 0.9),
            bass("Copy this one", "Octave jumps, then a walk down from A to D.", [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(5, 35), NoteEvent(7, 45),
                                       NoteEvent(9, 43), NoteEvent(12, 40, 2), NoteEvent(15, 38)], threshold: 0.9),
            bassMake("Make it yours", "Use at least one octave jump. At least 7 notes.", notes: 7),
        ])

    static let u2l5: LevelPair = (
        silver: [
            L.silver("writing over chords",
                     "With chords playing, the bass should start on each chord's root, then bounce."),
            bassMake("Write a bassline under Em9", "At least 6 notes. Start on E.",
                     backing: Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, chords: [K.ch(3, .em9, 2), K.ch(11, .em9, 2)]),
                     notes: 6),
            bass("Copy this bassline first", "E, up to high B, a long E, then A and G.", [NoteEvent(0, 40), NoteEvent(3, 47), NoteEvent(6, 40, 2), NoteEvent(11, 45),
                                                  NoteEvent(14, 43)], backing: G.skippy),
        ],
        gold: [
            L.gold("a full garage bassline", "Write against chords and full drums."),
            bass("Copy this bassline first", "It starts on E and jumps up to B. A holds in the second half.", [NoteEvent(0, 40, 2), NoteEvent(3, 40), NoteEvent(5, 47), NoteEvent(7, 45),
                                                  NoteEvent(11, 45, 2), NoteEvent(14, 43), NoteEvent(15, 40)],
                 backing: G.full.keeping([.kick, .clap, .hat, .perc], bass: false, chords: true), threshold: 0.9),
            bassMake("Make it yours", "At least 8 notes, under Em9 then Am9.",
                     backing: G.full.keeping([.kick, .clap, .hat, .perc], bass: false, chords: true), notes: 8),
        ])

    // MARK: Unit 3 — Garage Chords

    static let u3l1: LevelPair = (
        silver: [
            L.silver("more ninths",
                     "The ninth recipe works on any root. Build the other two chords garage uses most."),
            K.build("Build Dm9", "D, F, A, C and E.", .dm9, low: 55, high: 71),
            K.build("Build Cmaj9", "C, E, G, B and D. A major ninth: brighter.", .cmaj9, low: 55, high: 71),
            K.quiz("7th or 9th?", "A 9th adds one more note on top. Listen for the richer sound.", [
                K.round([.am7], ["7th", "9th (richer)"], 0), K.round([.em9], ["7th", "9th (richer)"], 1),
                K.round([.dm9], ["7th", "9th (richer)"], 1), K.round([.em7], ["7th", "9th (richer)"], 0),
            ]),
        ],
        gold: [
            L.gold("minor or major ninth",
                   "Minor ninths sound smooth and dark. Major ninths sound bright and hopeful. Garage switches between them."),
            K.build("Build Fm9", "F, A♭, C, E♭ and G.", .fm9, low: 53, high: 71),
            K.quiz("Minor 9th or major 9th?", "Major 9ths sound bright. Minor 9ths sound smooth and moody.", [
                K.round([.cmaj9], ["Minor 9th", "Major 9th"], 1), K.round([.am9], ["Minor 9th", "Major 9th"], 0),
                K.round([.em9], ["Minor 9th", "Major 9th"], 0), K.round([.cmaj9], ["Minor 9th", "Major 9th"], 1),
                K.round([.dm9], ["Minor 9th", "Major 9th"], 0),
            ]),
            K.lane("Copy these ninths", "Em9 in the first half, Cmaj9 in the second.", .recreate, palette: [.em9, .cmaj9], backing: G.twoStep,
                   target: [3: 0, 5: 0, 11: 1, 13: 1]),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("stabs with the swing",
                     "Stabs on the second 16th of a pair get pushed late by swing, so they skip like the hats."),
            K.lane("Copy the skipping stabs", "Five stabs: a pair in each half, plus one at the end.", .recreate, palette: [.em9], backing: G.twoStep,
                   target: [1: 0, 3: 0, 9: 0, 11: 0, 15: 0]),
            K.lane("Copy the held stabs", "Each holds for two steps.", .recreate, palette: [.em9], backing: G.twoStep,
                   target: [3: 0, 7: 0, 13: 0], length: 2),
            K.lane("Write swung stabs", "At least 5.", .create(.chordsAtLeast(5)), palette: [.em9], backing: G.twoStep),
        ],
        gold: [
            L.gold("stab riffs",
                   "Garage stab riffs mix chords and rhythms. Hear both at once."),
            K.lane("Copy this riff", "Em9 and Am9 take turns.", .recreate, palette: [.em9, .am9], backing: G.skippy,
                   target: [1: 0, 3: 0, 6: 1, 9: 0, 11: 1, 15: 1]),
            K.lane("Copy this riff", "It starts and ends on Em9. Cmaj9 is the bright one.", .recreate, palette: [.em9, .am9, .cmaj9], backing: G.skippy,
                   target: [0: 0, 5: 1, 7: 1, 11: 2, 13: 0]),
            K.lane("Make it yours", "At least 6 stabs.", .create(.chordsAtLeast(6)), palette: [.em9, .am9, .cmaj9],
                   backing: G.skippy),
        ])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("new two-chord loops",
                     "Em9 to Am9 is the classic, but Em9 to Cmaj9 lifts the mood and Em9 to Dm9 drops it."),
            K.lane("Switch to Cmaj9 for the second half", "Change steps 12 and 14 to Cmaj9.", .rule,
                   palette: [.em9, .cmaj9], backing: G.twoStep, start: [3: 0, 5: 0, 11: 0, 13: 0],
                   target: [3: 0, 5: 0, 11: 1, 13: 1]),
            K.lane("Copy this loop", "Em9 and Dm9 swap back and forth.", .recreate, palette: [.em9, .dm9], backing: G.twoStep,
                   target: [3: 0, 5: 1, 11: 0, 13: 1]),
        ],
        gold: [
            L.gold("three and four-chord loops", "Garage loops often use four ninths."),
            K.lane("Copy this loop", "Two Em9, one Am9, then two Cmaj9.", .recreate, palette: [.em9, .am9, .cmaj9], backing: G.twoStep,
                   target: [3: 0, 5: 0, 9: 1, 11: 2, 13: 2]),
            K.lane("Copy this four-chord loop", "One chord per beat, all four different.", .recreate, palette: [.em9, .am9, .cmaj9, .dm9], backing: G.skippy,
                   target: [1: 0, 5: 1, 9: 2, 13: 3]),
            K.lane("Make it yours", "At least 3 different chords.", .create(.chordsAtLeast(5)),
                   palette: [.em9, .am9, .cmaj9, .dm9], backing: G.skippy),
        ])

    static let u3l4: LevelPair = (
        silver: [
            L.silver("hearing ninths move",
                     "Train your ear to follow a ninth chord as it changes. Listen to the top note."),
            K.quiz("Which chord comes second?", "Starting on Am9 this time.", [
                K.round([.am9, .em9], ["Em9", "Dm9"], 0), K.round([.am9, .dm9], ["Em9", "Dm9"], 1),
                K.round([.am9, .cmaj9], ["Cmaj9", "Em9"], 0),
            ]),
            K.quiz("Brighter or darker?", "Does the second chord lift or drop?", [
                K.round([.em9, .cmaj9], ["Brighter", "Darker"], 0), K.round([.cmaj9, .em9], ["Brighter", "Darker"], 1),
                K.round([.am9, .dm9], ["Brighter", "Darker"], 1),
            ]),
        ],
        gold: [
            L.gold("three-chord ear training", "Now follow three chords in a row."),
            K.quiz("Which chord comes third?", "Follow the top note as it moves.", [
                K.round([.em9, .am9, .cmaj9], ["Cmaj9", "Dm9"], 0), K.round([.em9, .cmaj9, .dm9], ["Am9", "Dm9"], 1),
                K.round([.am9, .em9, .am9], ["Am9", "Cmaj9"], 0), K.round([.cmaj9, .dm9, .em9], ["Em9", "Am9"], 0),
            ]),
            K.lane("Recreate what you heard", "Em9, Am9, Cmaj9.", .recreate, palette: [.em9, .am9, .cmaj9],
                   backing: G.twoStep, target: [3: 0, 7: 1, 11: 2]),
        ])

    static let chordsBacking = Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                       chords: [K.ch(3, .em9, 2), K.ch(11, .am9, 2)])

    static let u3l5: LevelPair = (
        silver: [
            L.silver("roots that bounce",
                     "Start each chord on its root, then add a skip or an octave."),
            bass("Roots with a bounce", "E under Em9, A under Am9, each with a second note.",
                 [NoteEvent(3, 40, 2), NoteEvent(6, 40), NoteEvent(11, 45, 2), NoteEvent(14, 45)], backing: chordsBacking),
            bass("Roots under Cmaj9", "E under Em9, then G under Cmaj9. G is part of that chord.", [NoteEvent(3, 40, 4), NoteEvent(11, 43, 4)],
                 backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                  chords: [K.ch(3, .em9, 2), K.ch(11, .cmaj9, 2)])),
        ],
        gold: [
            L.gold("bass and chords together", "Follow three chords with a moving bassline."),
            bass("Copy this bassline", "E under Em9, A under Am9, then G and D under Cmaj9.", [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(5, 47), NoteEvent(8, 45),
                                            NoteEvent(11, 45), NoteEvent(13, 43), NoteEvent(15, 38)],
                 backing: Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats,
                                  chords: [K.ch(3, .em9, 2), K.ch(8, .am9, 2), K.ch(13, .cmaj9, 2)]), threshold: 0.9),
            bassMake("Make it yours", "At least 7 notes under the chords.",
                     backing: Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats,
                                      chords: [K.ch(3, .em9, 2), K.ch(8, .am9, 2), K.ch(13, .cmaj9, 2)]), notes: 7),
        ])

    // MARK: Unit 5 — Speed Garage & the Drop


    static let u4l3: LevelPair = (
        silver: [
            L.silver("speed garage bounce",
                     "Speed garage puts the four-on-the-floor kick under garage swing, with a bass that bounces on the offbeats."),
            bass("Copy this speed garage bass", "Low B on the offbeats, with octave flicks up.", [NoteEvent(2, 35), NoteEvent(3, 47), NoteEvent(6, 35), NoteEvent(10, 35),
                                                     NoteEvent(11, 47), NoteEvent(14, 40)], backing: speed),
            L.copy("Copy the speed garage drums", "Four kicks, two claps and a rim.", tracks: kit, edit: [.hat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14], perc: [7, 15])),
        ],
        gold: [
            L.gold("the speed garage sound", "Rebuild the drums, then the bass, then shape the bass tone."),
            L.copy("Rebuild the drums", "Four kicks, claps on 2 and 4, skippy hats and two rims.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: skipHats, perc: [7, 13]), threshold: 0.9),
            bass("Copy this bass", "Offbeat low Bs with octave jumps. A and G answer them.", [NoteEvent(2, 35), NoteEvent(3, 47), NoteEvent(6, 35), NoteEvent(7, 45),
                                        NoteEvent(10, 35), NoteEvent(11, 47), NoteEvent(14, 40), NoteEvent(15, 43)],
                 backing: speed, threshold: 0.9),
            K.lab("Match the speed garage bass tone", "Resonant and wobbly.", [.bassCutoff, .bassEnv, .bassResonance],
                  start: [0.6, 0.2, 0.1], target: [0.35, 0.7, 0.75],
                  loop: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], bass: [NoteEvent(2, 35), NoteEvent(6, 35),
                                                                            NoteEvent(7, 47), NoteEvent(10, 35)])),
            bassMake("Make it yours", "At least 8 notes.", backing: speed, notes: 8),
        ])

    static let lanes = G.lanes
    static func arr(_ prompt: String, _ hint: String, _ mode: TaskMode, sections: [String] = K.sections4,
                    start: [[Bool]] = [], target: [[Bool]] = []) -> LessonStep {
        K.arrange(prompt, hint, mode, sections: sections, lanes: lanes, loop: G.full, start: start, target: target)
    }

    static let u4l4: LevelPair = (
        silver: [
            L.silver("garage intros",
                     "Garage intros often start with chords and hats, so the vocal has room to come in."),
            arr("Copy this intro", "Hats and chords open it. The clap waits for the Drop.", .recreate, target: K.grid("-xx-", "--x-", "xxxx", "-xx-", "xx-x")),
            arr("Intro: chords only", "Switch off everything in the Intro except the chords.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("-xxx", "-xxx", "-xxx", "-xxx", "xxxx")),
        ],
        gold: [
            L.gold("whole garage tracks", "Hear the whole thing, then check part by part."),
            arr("Recreate this track", "The bass waits for the Drop and stays for the Break.", .recreate, target: K.grid("-xx-", "-xxx", "xxx-", "--xx", "xx-x")),
            arr("Recreate this one", "The kick only arrives at the Drop.", .recreate, target: K.grid("--xx", "-x-x", "xxxx", "-x-x", "x-xx")),
            arr("Make it yours", "Start small and keep the bass for the Drop.", .create(.variedSections)),
        ])

    static let u4l5: LevelPair = (
        silver: [
            L.silver("the bass drop",
                     "In garage the drop is all about the bass arriving. Keep it out until then."),
            arr("Copy this track", "Kick and bass both wait for the Drop.", .recreate, target: K.grid("--x-", "-xx-", "xxxx", "--x-", "x-xx")),
            arr("Save the bass for the Drop", "Switch off the bass everywhere except the Drop.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("xxxx", "xxxx", "xxxx", "--x-", "xxxx")),
        ],
        gold: [
            L.gold("two drops", "The second drop should feel bigger than the first."),
            arr("Recreate this track", "The Break is chords alone.", .recreate, sections: ["Intro", "Drop", "Break", "Drop 2"],
                target: K.grid("-x-x", "-x-x", "xx-x", "-x-x", "x-xx")),
            arr("Recreate this one", "In the Break the clap stays with the hats and chords.", .recreate, sections: ["Intro", "Drop", "Break", "Drop 2"],
                target: K.grid("-x-x", "-xxx", "xxxx", "-x-x", "xxxx")),
            arr("Make it yours", "Make Drop 2 bigger than the first.", .create(.variedSections), sections: ["Intro", "Drop", "Break", "Drop 2"]),
        ])
}
