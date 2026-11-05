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
            K.quiz("Where's the second kick?", "Same clap and hats. Only the kick moves.", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats)], ["Two kicks", "Three kicks"], 0, bars: 2,
                       question: "How many kicks in each bar?"),
                K.hear([Pattern(kick: [0, 10, 11], clap: [4, 12], hat: skipHats)], ["Two kicks", "Three kicks"], 1,
                       "The extra kick is a pickup: it rolls straight into the second clap.", bars: 2,
                       question: "How many kicks in each bar?"),
                K.ask("Why does two-step leave beats 2 and 4 without a kick?", ["So the clap and the gaps can swing", "To save CPU", "Because the kick is too loud"], 0,
                      "Taking the kick off beats 2 and 4 is what breaks the steady thump into a bounce."),
            ]),
            L.copy("Copy this two-step", "The second kick lands a step earlier than before.", tracks: [.kick, .clap, .hat],
                   edit: [.kick], start: Pattern(clap: [4, 12], hat: skipHats),
                   target: Pattern(kick: [0, 9], clap: [4, 12], hat: skipHats)),
            K.fix("Fix the pickup kick", "The third kick should be a pickup on step 12, right before the second clap. It has slipped after the clap.",
                  tracks: [.kick, .clap, .hat], edit: [.kick],
                  broken: Pattern(kick: [0, 10, 14], clap: [4, 12], hat: skipHats),
                  target: Pattern(kick: [0, 10, 11], clap: [4, 12], hat: skipHats), guide: false),
            K.swingMake("Heavier shuffle", "Push swing past 30%.", tracks: [.kick, .clap, .hat],
                        start: Pattern(kick: [0, 10], clap: [4, 12], hat: Array(0..<16)), atLeast: 0.3),
        ],
        gold: [
            L.gold("the full two-step",
                   "Kick, clap, skippy hats and rims all push and pull against each other. Rebuild full grooves from nothing."),
            K.quiz("Read the groove", "", [
                K.hear([Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14], perc: [9, 15])], ["Yes", "No"], 0,
                       "Two rims sit in the gaps near the end of the bar.", bars: 2, question: "Can you hear rims as well as hats?"),
                K.hear([Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14])], ["Yes", "No"], 1, bars: 2,
                       question: "Can you hear rims as well as hats?"),
            ]),
            L.copy("Rebuild this groove", "Three kicks. Two rims fill the gaps near the end.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14], perc: [9, 15]),
                   threshold: 0.9),
            K.fix("Make the hats skip", "Every hat should have a partner on the very next step, so they come in pairs. Right now they play alone.",
                  tracks: kit, edit: [.hat],
                  broken: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [7, 13]),
                  target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: skipHats, perc: [7, 13]), guide: false),
            L.make("Make it yours", "A full two-step groove from silence. At least 3 kicks.", tracks: kit,
                   edit: Set(kit), goal: .atLeast(.kick, 3)),
        ])

    static let u1l2: LevelPair = (
        silver: [
            L.silver("hats that skip",
                     "Garage hats work in pairs: the second hit of each pair is the one swing pushes late. Change which pairs play and the skip changes."),
            K.quiz("Pairs or singles?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14])], ["Single hats", "Hats in pairs"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats)], ["Single hats", "Hats in pairs"], 1,
                       "The second hit of each pair is the skip.", bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 10, 11], openHat: [6, 14])], ["No open hats", "Open hats too"], 1,
                       "The open hats ring longer, like a 'tss'.", bars: 2),
            ]),
            L.copy("Copy these hats", "Pairs before each beat this time.", tracks: [.kick, .clap, .hat], edit: [.hat],
                   start: Pattern(kick: [0, 10], clap: [4, 12]),
                   target: Pattern(kick: [0, 10], clap: [4, 12], hat: [1, 2, 5, 6, 9, 10, 13, 14])),
            K.fix("Fix the open hats", "Open hats belong on the offbeats, steps 7 and 15. Both have slipped one step early.",
                  tracks: [.kick, .clap, .hat, .openHat], edit: [.openHat],
                  broken: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 10, 11], openHat: [5, 13]),
                  target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 10, 11], openHat: [6, 14]), guide: false),
            L.make("Write skippy hats", "At least 8 hats.", tracks: [.kick, .clap, .hat], edit: [.hat],
                   start: Pattern(kick: [0, 10], clap: [4, 12]), goal: .atLeast(.hat, 8)),
        ],
        gold: [
            L.gold("hats and swing together",
                   "The same hats sound totally different at 15% and 35% swing. Set the swing, then rebuild hats under it."),
            K.quiz("How much swing?", "The same hats each time.", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [1, 2, 5, 6, 9, 10, 13, 14])], ["Straight", "A little", "Full garage swing"], 0,
                       bars: 2, swing: 0),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [1, 2, 5, 6, 9, 10, 13, 14])], ["Straight", "A little", "Full garage swing"], 2,
                       bars: 2, swing: 0.4),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [1, 2, 5, 6, 9, 10, 13, 14])], ["Straight", "A little", "Full garage swing"], 1,
                       bars: 2, swing: 0.18),
                K.ask("Which hit in each pair does swing push late?", ["The first", "The second"], 1,
                      "Swing delays the in-between 16ths. That late second hit is the skip."),
            ]),
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
            K.quiz("Where are the ghosts?", "Listen to the quiet rims around each clap.", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 11])], ["Just before the claps", "Just after the claps"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [5, 13])], ["Just before the claps", "Just after the claps"], 1, bars: 2),
            ]),
            L.copy("Copy these ghost rims", "Just before each clap.", tracks: kit, edit: [.perc], start: G.twoStep,
                   target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 11])),
            K.fix("Fix the busy rims", "Four rims should circle the second kick: steps 6, 8, 10 and 16. One is hiding on top of the kick on step 11.",
                  tracks: kit, edit: [.perc],
                  broken: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [5, 7, 10, 15]),
                  target: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], perc: [5, 7, 9, 15]), guide: false),
            L.make("Write ghost rims", "At least 4.", tracks: kit, edit: [.perc], start: G.twoStep, goal: .atLeast(.perc, 4)),
        ],
        gold: [
            L.gold("ghost claps too",
                   "Garage producers ghost the clap as well as the rim. Rebuild both, then the whole kit."),
            K.quiz("Ghost claps?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14])], ["Main claps only", "Ghost claps too"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 7, 12, 15], hat: [2, 6, 10, 14])], ["Main claps only", "Ghost claps too"], 1,
                       "Each clap gets an echo three steps later.", bars: 2),
            ]),
            L.copy("Copy rims and ghost claps", "Each clap has a ghost clap three steps later. Three rims fill the gaps.", tracks: kit, edit: [.clap, .perc],
                   start: Pattern(kick: [0, 10], hat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 10], clap: [4, 7, 12, 15], hat: [2, 6, 10, 14], perc: [3, 9, 13]),
                   threshold: 0.9),
            K.fix("Too many ghosts", "Ghosts work because they're rare. Keep the claps on steps 5 and 13 plus one ghost on step 16. Clear the rest.",
                  tracks: kit, edit: [.clap],
                  broken: Pattern(kick: [0, 10], clap: [4, 6, 7, 12, 14, 15], hat: skipHats, perc: [5, 9]),
                  target: Pattern(kick: [0, 10], clap: [4, 12, 15], hat: skipHats, perc: [5, 9]), guide: false),
            L.make("Make it yours", "Write rims and claps. At least 4 rims.", tracks: kit, edit: [.clap, .perc],
                   start: Pattern(kick: [0, 10], hat: skipHats), goal: .atLeast(.perc, 4)),
        ])

    static let u1l4: LevelPair = (
        silver: [
            L.silver("push and pull",
                     "Kicks before the clap push the groove forward. Kicks just after it pull it back. Hear which is which."),
            K.quiz("Push or pull?", "Skippy hats this time. Follow the extra kicks.", [
                K.hear([Pattern(kick: [0, 3, 11], clap: [4, 12], hat: skipHats)], ["Push (before the clap)", "Pull (after the clap)"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 5, 13], clap: [4, 12], hat: skipHats)], ["Push (before the clap)", "Pull (after the clap)"], 1, bars: 2),
                K.ask("A kick right before the clap makes the groove feel...", ["Like it's leaning forward", "Like it's dragging back"], 0,
                      "Kicks after the clap do the opposite: they hold the groove back and make it feel lazy."),
            ]),
            L.copy("Copy the pushing kicks", "Kicks just before each clap.", tracks: [.kick, .clap, .hat], edit: [.kick],
                   start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 3, 11], clap: [4, 12], hat: [2, 6, 10, 14])),
            K.fix("Turn push into pull", "Move each extra kick from just before its clap to just after it: steps 6 and 14. Hear the groove lean back.",
                  tracks: [.kick, .clap, .hat], edit: [.kick],
                  broken: Pattern(kick: [0, 3, 11], clap: [4, 12], hat: [2, 6, 10, 14]),
                  target: Pattern(kick: [0, 5, 13], clap: [4, 12], hat: [2, 6, 10, 14]), guide: false),
            L.make("Mix push and pull", "One kick that pushes into a clap and one that pulls after the other. At least 3 kicks.",
                   tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: skipHats),
                   goal: .atLeast(.kick, 3)),
        ],
        gold: [
            L.gold("push and pull across the kit",
                   "Rims can push and pull just like kicks. Rebuild kicks and rims that lean against the claps."),
            K.quiz("Rims push too", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, perc: [3, 11])], ["Rims push", "Rims pull"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, perc: [6, 14])], ["Rims push", "Rims pull"], 1, bars: 2),
            ]),
            L.copy("Copy these four kicks", "One on the downbeat, then three that push.", tracks: [.kick, .clap, .hat], edit: [.kick],
                   start: Pattern(clap: [4, 12], hat: skipHats),
                   target: Pattern(kick: [0, 3, 7, 10], clap: [4, 12], hat: skipHats), threshold: 0.9),
            K.fix("Fix the rims", "Kicks pull after the claps and rims push into them: steps 4, 12 and 16. The first rim is pulling on step 7 instead.",
                  tracks: kit, edit: [.perc],
                  broken: Pattern(kick: [0, 5, 10, 13], clap: [4, 12], hat: skipHats, perc: [6, 11, 15]),
                  target: Pattern(kick: [0, 5, 10, 13], clap: [4, 12], hat: skipHats, perc: [3, 11, 15]), guide: false),
            L.make("Make it yours", "Write your own push-and-pull kicks. At least 3.", tracks: [.kick, .clap, .hat],
                   edit: [.kick], start: Pattern(clap: [4, 12], hat: skipHats), goal: .atLeast(.kick, 3)),
        ])

    static let u1l5: LevelPair = (
        silver: [
            L.silver("kicks with rims",
                     "Your own two-step works best when the kick and rims answer each other."),
            K.quiz("Stacked or answering?", "", [
                K.hear([Pattern(kick: [0, 7, 10], clap: [4, 12], hat: skipHats, perc: [0, 7, 10])], ["Rims on the kicks", "Rims in the gaps"], 0,
                       "Stacked on the kick, the rims just disappear.", bars: 2),
                K.hear([Pattern(kick: [0, 7, 10], clap: [4, 12], hat: skipHats, perc: [3, 9, 15])], ["Rims on the kicks", "Rims in the gaps"], 1,
                       "Kick, rim, kick: a little conversation.", bars: 2),
            ]),
            L.copy("Copy this answer", "Kick, then rim, then kick.", tracks: kit, edit: [.kick, .perc],
                   start: Pattern(clap: [4, 12], hat: skipHats),
                   target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: skipHats, perc: [3, 9, 15])),
            K.fix("Unstack the rims", "These rims sit right on the kicks. Move them into the gaps: steps 4, 10 and 16.",
                  tracks: kit, edit: [.perc],
                  broken: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: skipHats, perc: [0, 7, 10]),
                  target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: skipHats, perc: [3, 9, 15]), guide: false),
            L.make("Write your own two-step", "At least 3 kicks and 3 rims, answering each other.", tracks: kit, edit: [.kick, .perc],
                   start: Pattern(clap: [4, 12], hat: skipHats), goal: .atLeast(.perc, 3)),
        ],
        gold: [
            L.gold("a groove from nothing", "Every part is yours now."),
            K.quiz("Garage or house?", "Listen to the kick and the swing.", [
                K.hear([Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 7, 10, 14, 15], perc: [9, 13])], ["UK garage", "House"], 0, bars: 2, swing: 0.35),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])], ["UK garage", "House"], 1,
                       "A kick on every beat and straight hats: that's house.", bars: 2, swing: 0),
            ]),
            L.copy("Rebuild this groove first", "Three kicks, gappy hats and two rims.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 7, 10, 14, 15], perc: [9, 13]),
                   threshold: 0.9),
            K.fix("Rescue the two-step", "Someone put a kick on every beat. Take it back to a two-step: kicks on steps 1, 4 and 11 only.",
                  tracks: kit, edit: [.kick],
                  broken: Pattern(kick: [0, 3, 4, 8, 10, 12], clap: [4, 12], hat: [2, 6, 7, 10, 14, 15], perc: [9, 13]),
                  target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: [2, 6, 7, 10, 14, 15], perc: [9, 13]), guide: false),
            L.make("Make it yours", "A full two-step from silence. At least 6 hats.", tracks: kit, edit: Set(kit),
                   goal: .atLeast(.hat, 6)),
        ])

    // MARK: Unit 2 — Bouncy Bass

    static let u2l1: LevelPair = (
        silver: [
            L.silver("envelope and length",
                     "Garage bass changes character from round sub to bright pluck. Envelope adds a 'wow' at the start of each note."),
            K.quiz("Round or plucky?", "", [
                K.sound(bassLoop, [.bassCutoff: 0.25, .bassEnv: 0.15, .bassDecay: 0.6], ["Round sub", "Bright pluck"], 0),
                K.sound(bassLoop, [.bassCutoff: 0.5, .bassEnv: 0.7, .bassDecay: 0.2], ["Round sub", "Bright pluck"], 1,
                        "The envelope adds a quick 'wow' at the start, and short notes make it bounce."),
                K.ask("What does the envelope knob add?", ["A 'wow' at the start of each note", "More volume", "Longer notes"], 0,
                      "It opens the filter for a moment as each note starts, then lets it close."),
            ]),
            K.lab("Match the warm, rounded bass", "Dark, little bite, notes held.", [.bassCutoff, .bassEnv, .bassDecay], start: [0.6, 0.6, 0.2],
                  target: [0.25, 0.15, 0.6], loop: bassLoop),
            K.lab("Match the plucky garage bass", "Brighter with lots of bite. Short notes.", [.bassCutoff, .bassEnv, .bassDecay], start: [0.25, 0.15, 0.6],
                  target: [0.5, 0.7, 0.2], loop: bassLoop),
            K.lab("Make it yours", "Somewhere between the two: some bite, but notes long enough to groove.", [.bassCutoff, .bassEnv, .bassDecay],
                  start: [0.4, 0.4, 0.4], loop: bassLoop),
        ],
        gold: [
            L.gold("bass from every era",
                   "90s garage bass is warm and bouncy. Speed garage bass is a wobbling, resonant reese. Match both with all four knobs."),
            K.quiz("Which era?", "", [
                K.sound(bassLoop, [.bassCutoff: 0.3, .bassEnv: 0.35, .bassResonance: 0.15, .bassDecay: 0.55], ["90s two-step", "Speed garage"], 0,
                        "Warm and rounded, made to sit under a vocal."),
                K.sound(bassLoop, [.bassCutoff: 0.45, .bassEnv: 0.75, .bassResonance: 0.7, .bassDecay: 0.35], ["90s two-step", "Speed garage"], 1,
                        "Resonance makes it whistle and wobble."),
                K.faders(G.full, [.bass: 1.0, .drum(.kick): 0.5], ["Bass too loud", "Balanced"], 0,
                         "The sub is swallowing the kick. A great tone still needs the right level.", question: "How's the balance?"),
            ]),
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
            K.quiz("With the kick or around it?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 40, 2), NoteEvent(10, 38, 2)])], ["Bass on the kick", "Bass dodges the kick"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(1, 40), NoteEvent(5, 43), NoteEvent(8, 40), NoteEvent(13, 38)])],
                       ["Bass on the kick", "Bass dodges the kick"], 1, "Each note fills a gap the kick leaves. That's the skip.", bars: 2),
            ]),
            bass("Copy this skipping bass", "E, G, E, D. Every note dodges the kick.", [NoteEvent(1, 40), NoteEvent(5, 43), NoteEvent(8, 40), NoteEvent(13, 38)]),
            K.fixNotes("Fix the busier skip", "The G should land just before the second kick, on step 10. Right now it crashes into the kick on step 11.", rows: rows,
                       broken: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(6, 45), NoteEvent(10, 43), NoteEvent(13, 38), NoteEvent(15, 35)],
                       target: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(6, 45), NoteEvent(9, 43), NoteEvent(13, 38), NoteEvent(15, 35)],
                       backing: G.twoStep),
            bassMake("Write a skipping bassline", "At least 5 notes, none with the kick.", backing: G.twoStep, notes: 5),
        ],
        gold: [
            L.gold("bass with the hats",
                   "With skippy hats and swing, the bass has to sit in even smaller gaps."),
            K.quiz("Quick check", "", [
                K.ask("Why does garage bass dodge the kick?", ["So the low end stays clear and the line bounces", "Because the kick is too quiet", "So it can be louder"], 0,
                      "Two low sounds at once turn to mud. Taking turns keeps both punchy."),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, perc: [9],
                                bass: [NoteEvent(0, 40), NoteEvent(2, 40), NoteEvent(5, 43), NoteEvent(7, 45), NoteEvent(11, 38), NoteEvent(13, 40), NoteEvent(15, 35)])],
                       ["It climbs", "It falls"], 0, "Up from E to A, then a drop to low B at the end.", bars: 2,
                       question: "Where does the line go in the first half?"),
            ]),
            bass("Copy this line", "Up from E to A, then down to low B.", [NoteEvent(0, 40), NoteEvent(2, 40), NoteEvent(5, 43), NoteEvent(7, 45),
                                        NoteEvent(11, 38), NoteEvent(13, 40), NoteEvent(15, 35)], backing: G.skippy,
                 threshold: 0.9),
            K.fixNotes("Fix the opening jump", "The line should open with an octave jump: low B, then high B on step 4. The second note is stuck down low.", rows: rows,
                       broken: [NoteEvent(1, 35), NoteEvent(3, 35), NoteEvent(6, 40), NoteEvent(9, 43), NoteEvent(11, 40), NoteEvent(14, 38)],
                       target: [NoteEvent(1, 35), NoteEvent(3, 47), NoteEvent(6, 40), NoteEvent(9, 43), NoteEvent(11, 40), NoteEvent(14, 38)],
                       backing: G.skippy),
            bassMake("Make it yours", "At least 7 notes.", notes: 7),
        ])

    static let u2l3: LevelPair = (
        silver: [
            L.silver("length makes the bounce",
                     "The same notes held for different lengths feel completely different. Long notes groove, short notes bounce."),
            K.quiz("Which one bounces?", "The same notes twice. Only the lengths change.", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, bass: [NoteEvent(0, 40, 3), NoteEvent(6, 43, 3), NoteEvent(10, 38, 3)]),
                        Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, bass: [NoteEvent(0, 40), NoteEvent(6, 43), NoteEvent(10, 38)])],
                       ["The first", "The second"], 1, "Short notes leave gaps, and gaps are where the bounce lives.",
                       question: "Which version bounces more?"),
            ]),
            bass("Copy this bassline", "Three long notes.", [NoteEvent(0, 40, 3), NoteEvent(6, 43), NoteEvent(7, 45),
                                                             NoteEvent(10, 38, 3), NoteEvent(15, 35)]),
            K.fixNotes("Make it bounce", "Same notes, but every one is held too long. Shorten them all to one step.", rows: rows,
                       broken: [NoteEvent(0, 40, 3), NoteEvent(3, 40, 3), NoteEvent(6, 43, 2), NoteEvent(8, 40, 2), NoteEvent(10, 38, 3), NoteEvent(14, 35, 2)],
                       target: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(6, 43), NoteEvent(8, 40), NoteEvent(10, 38), NoteEvent(14, 35)],
                       backing: G.twoStep),
            bassMake("Write a long-and-short line", "At least 5 notes. Hold one or two, keep the rest short.", backing: G.twoStep, notes: 5),
        ],
        gold: [
            L.gold("long and short together",
                   "The best garage lines mix long notes and quick skips in one bar."),
            K.quiz("Where's the long note?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, bass: [NoteEvent(0, 40, 4), NoteEvent(6, 43), NoteEvent(9, 40), NoteEvent(13, 38)])],
                       ["At the start", "At the end"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, bass: [NoteEvent(0, 40), NoteEvent(3, 43), NoteEvent(6, 40), NoteEvent(12, 38, 4)])],
                       ["At the start", "At the end"], 1, bars: 2),
            ]),
            bass("Copy this bassline", "Mix of long and short. Four notes hold for two steps.", [NoteEvent(0, 40, 2), NoteEvent(3, 40), NoteEvent(4, 43), NoteEvent(6, 45, 2),
                                            NoteEvent(10, 38, 2), NoteEvent(13, 35), NoteEvent(14, 38, 2)], threshold: 0.9),
            K.fixNotes("Fix the held notes", "The low B at the start and the G at the end should both hold for three steps. Right now they're clipped short.", rows: rows,
                       broken: [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(7, 45, 2), NoteEvent(11, 40), NoteEvent(12, 43)],
                       target: [NoteEvent(0, 35, 3), NoteEvent(3, 47), NoteEvent(7, 45, 2), NoteEvent(11, 40), NoteEvent(12, 43, 3)],
                       backing: G.twoStep),
            bassMake("Make it yours", "Mix long and short. At least 6 notes.", notes: 6),
        ])

    static let u2l4: LevelPair = (
        silver: [
            L.silver("jumps on new notes",
                     "Big jumps work from any note, not just B. Start on E and leap up and the line moves somewhere new."),
            K.quiz("How big is the jump?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 40), NoteEvent(3, 47), NoteEvent(8, 40), NoteEvent(11, 47)])],
                       ["A big leap", "A small step"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 40), NoteEvent(3, 38), NoteEvent(8, 40), NoteEvent(11, 38)])],
                       ["A big leap", "A small step"], 1, "E down to D is the next note in the scale.", bars: 2),
                K.ask("Low B to high B is an octave. What stays the same?", ["The note name", "The pitch"], 0,
                      "Same note, twice as high. That's why octave jumps never clash."),
            ]),
            bass("Jump from E up to B", "E on steps 1 and 9, then jump up to B on steps 4 and 12.",
                 [NoteEvent(0, 40), NoteEvent(3, 47), NoteEvent(8, 40), NoteEvent(11, 47)]),
            K.fixNotes("Fix the octave flick", "Each low B flicks up to high B. The second high B, on step 10, has slipped down to A.", rows: rows,
                       broken: [NoteEvent(0, 35), NoteEvent(1, 47), NoteEvent(6, 35), NoteEvent(9, 45), NoteEvent(10, 45), NoteEvent(14, 43, 2)],
                       target: [NoteEvent(0, 35), NoteEvent(1, 47), NoteEvent(6, 35), NoteEvent(9, 47), NoteEvent(10, 45), NoteEvent(14, 43, 2)],
                       backing: G.twoStep),
            bassMake("Write a jumping line", "Start on E. Leap up to high B at least twice. At least 4 notes.", backing: G.twoStep, notes: 4),
        ],
        gold: [
            L.gold("octaves and walks",
                   "Combine octave jumps with notes that walk down the scale and the bass sings."),
            K.quiz("Jump or walk?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(0, 35), NoteEvent(2, 47), NoteEvent(8, 35), NoteEvent(10, 47)])],
                       ["Octave jumps", "Walking down"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(1, 47), NoteEvent(5, 45), NoteEvent(8, 43), NoteEvent(12, 40, 2)])],
                       ["Octave jumps", "Walking down"], 1, bars: 2),
                K.ask("Walking down from A, which note comes next?", ["G", "F"], 0,
                      "The rows are B, A, G, E, D, B. Walk down them and you stay in key."),
            ]),
            bass("Copy this line", "An octave jump, then a walk down. Then again, ending on D.", [NoteEvent(0, 35), NoteEvent(2, 47), NoteEvent(3, 45), NoteEvent(6, 43),
                                        NoteEvent(7, 40), NoteEvent(10, 35), NoteEvent(11, 47), NoteEvent(14, 38)],
                 threshold: 0.9),
            K.fixNotes("Fix the walk", "After the jumps, the line should walk down: A, G, then a long E. Right now it climbs up instead.", rows: rows,
                       broken: [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(5, 35), NoteEvent(7, 40), NoteEvent(9, 43), NoteEvent(12, 45, 2), NoteEvent(15, 38)],
                       target: [NoteEvent(0, 35), NoteEvent(3, 47), NoteEvent(5, 35), NoteEvent(7, 45), NoteEvent(9, 43), NoteEvent(12, 40, 2), NoteEvent(15, 38)],
                       backing: G.twoStep),
            bassMake("Make it yours", "Use at least one octave jump. At least 7 notes.", notes: 7),
        ])

    static let u2l5: LevelPair = (
        silver: [
            L.silver("writing over chords",
                     "With chords playing, the bass should start on each chord's root, then bounce."),
            K.quiz("Locked in or clashing?", "Listen to the bass against the chord.", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(3, 40, 2), NoteEvent(11, 40, 2)], chords: [K.ch(3, .em9, 2), K.ch(11, .em9, 2)])],
                       ["Locked in", "Clashing"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], bass: [NoteEvent(3, 41, 2), NoteEvent(11, 41, 2)], chords: [K.ch(3, .em9, 2), K.ch(11, .em9, 2)])],
                       ["Locked in", "Clashing"], 1, "F rubs against the E and F♯ in Em9.", bars: 2),
                K.ask("Under Em9, which note should the bass start on?", ["E", "A", "D"], 0,
                      "The root locks the bass to the chord. After that, bounce wherever you like."),
            ]),
            bass("Copy this bassline first", "E, up to high B, a long E, then A and G.", [NoteEvent(0, 40), NoteEvent(3, 47), NoteEvent(6, 40, 2), NoteEvent(11, 45),
                                                  NoteEvent(14, 43)], backing: G.skippy),
            K.fixNotes("Fix the second root", "Each chord should start on its root: E under Em9, A under Am9 on step 12. Under Am9 the bass is playing D.", rows: rows,
                       broken: [NoteEvent(3, 40, 2), NoteEvent(6, 40), NoteEvent(11, 38, 2), NoteEvent(14, 43)],
                       target: [NoteEvent(3, 40, 2), NoteEvent(6, 40), NoteEvent(11, 45, 2), NoteEvent(14, 43)],
                       backing: chordsBacking),
            bassMake("Write your own under Em9", "At least 6 notes. Start on E, then bounce.",
                     backing: Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, chords: [K.ch(3, .em9, 2), K.ch(11, .em9, 2)]),
                     notes: 6),
        ],
        gold: [
            L.gold("a full garage bassline", "Write against chords and full drums."),
            K.quiz("Follow the chords", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, bass: [NoteEvent(3, 40, 2), NoteEvent(6, 40), NoteEvent(11, 45, 2), NoteEvent(14, 45)],
                                chords: [K.ch(3, .em9, 2), K.ch(11, .am9, 2)])],
                       ["Follows the chords", "Stays on one note"], 0, "E under Em9, then A when Am9 arrives.", bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, bass: [NoteEvent(3, 40, 2), NoteEvent(6, 40), NoteEvent(11, 40, 2), NoteEvent(14, 40)],
                                chords: [K.ch(3, .em9, 2), K.ch(11, .am9, 2)])],
                       ["Follows the chords", "Stays on one note"], 1, "E fits Am9, but the line never moves with the change.", bars: 2),
            ]),
            bass("Copy this bassline first", "It starts on E and jumps up to B. A holds in the second half.", [NoteEvent(0, 40, 2), NoteEvent(3, 40), NoteEvent(5, 47), NoteEvent(7, 45),
                                                  NoteEvent(11, 45, 2), NoteEvent(14, 43), NoteEvent(15, 40)],
                 backing: G.full.keeping([.kick, .clap, .hat, .perc], bass: false, chords: true), threshold: 0.9),
            K.fixNotes("Move with the change", "When Am9 arrives on step 12, the bass should move to its root, A. It's still sitting on E.", rows: rows,
                       broken: [NoteEvent(1, 40), NoteEvent(3, 40), NoteEvent(6, 43), NoteEvent(9, 40), NoteEvent(11, 40, 2), NoteEvent(14, 43), NoteEvent(15, 40)],
                       target: [NoteEvent(1, 40), NoteEvent(3, 40), NoteEvent(6, 43), NoteEvent(9, 40), NoteEvent(11, 45, 2), NoteEvent(14, 43), NoteEvent(15, 40)],
                       backing: G.full.keeping([.kick, .clap, .hat, .perc], bass: false, chords: true)),
            bassMake("Make it yours", "At least 8 notes, under Em9 then Am9.",
                     backing: G.full.keeping([.kick, .clap, .hat, .perc], bass: false, chords: true), notes: 8),
        ])

    // MARK: Unit 3 — Garage Chords

    static let u3l1: LevelPair = (
        silver: [
            L.silver("more ninths",
                     "The ninth recipe works on any root. Build the other two chords garage uses most."),
            K.build("Build Dm9", "D, F, A, C and E.", .dm9, low: 55, high: 71),
            K.build("Turn Cmaj7 into Cmaj9", "Cmaj7 is already here: C, E, G and B. Add the ninth, D, to make it Cmaj9.", .cmaj9,
                    start: [55, 59, 60, 64], low: 55, high: 71),
            K.quiz("7th or 9th?", "A 9th adds one more note on top. Listen for the richer sound.", [
                K.round([.am7], ["7th", "9th (richer)"], 0), K.round([.em9], ["7th", "9th (richer)"], 1),
                K.round([.dm9], ["7th", "9th (richer)"], 1), K.round([.em7], ["7th", "9th (richer)"], 0),
            ]),
            K.lane("Play your new ninths", "Stab them over the two-step. At least 4 stabs, using both chords.", .create(.chordsAtLeast(4)),
                   palette: [.dm9, .cmaj9], backing: G.twoStep),
        ],
        gold: [
            L.gold("minor or major ninth",
                   "Minor ninths sound smooth and dark. Major ninths sound bright and hopeful. Garage switches between them."),
            K.build("Turn Cm9 into Cmaj9", "This is Cm9: smooth and dark. Raise the third (E♭) and the seventh (B♭) by one key each to make it bright.", .cmaj9,
                    start: [55, 58, 60, 62, 63], low: 55, high: 71),
            K.quiz("Minor 9th or major 9th?", "Major 9ths sound bright. Minor 9ths sound smooth and moody.", [
                K.round([.cmaj9], ["Minor 9th", "Major 9th"], 1), K.round([.am9], ["Minor 9th", "Major 9th"], 0),
                K.round([.em9], ["Minor 9th", "Major 9th"], 0), K.round([.cmaj9], ["Minor 9th", "Major 9th"], 1),
                K.round([.dm9], ["Minor 9th", "Major 9th"], 0),
            ]),
            K.lane("Copy these ninths", "Em9 in the first half, Cmaj9 in the second.", .recreate, palette: [.em9, .cmaj9], backing: G.twoStep,
                   target: [3: 0, 5: 0, 11: 1, 13: 1]),
            K.lane("Make it yours", "Mix minor and major ninths. At least 5 stabs.", .create(.chordsAtLeast(5)),
                   palette: [.em9, .am9, .dm9, .cmaj9], backing: G.skippy),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("stabs with the swing",
                     "Stabs on the second 16th of a pair get pushed late by swing, so they skip like the hats."),
            K.quiz("Do the stabs skip?", "The same stabs, with and without swing.", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], chords: [K.ch(1, .em9), K.ch(3, .em9), K.ch(9, .em9), K.ch(11, .em9)])],
                       ["Straight", "Swung"], 0, bars: 2, swing: 0),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], chords: [K.ch(1, .em9), K.ch(3, .em9), K.ch(9, .em9), K.ch(11, .em9)])],
                       ["Straight", "Swung"], 1, "Stabs on in-between 16ths get pushed late, so they skip with the hats.", bars: 2, swing: 0.35),
            ]),
            K.lane("Copy the skipping stabs", "Five stabs: a pair in each half, plus one at the end.", .recreate, palette: [.em9], backing: G.twoStep,
                   target: [1: 0, 3: 0, 9: 0, 11: 0, 15: 0]),
            K.lane("Fix the held stab", "Held stabs sit on swung 16ths: steps 4, 8 and 14. The middle one has landed on a straight 8th.", .recreate,
                   palette: [.em9], backing: G.twoStep, start: [3: 0, 6: 0, 13: 0], target: [3: 0, 7: 0, 13: 0], length: 2),
            K.lane("Write swung stabs", "At least 5.", .create(.chordsAtLeast(5)), palette: [.em9], backing: G.twoStep),
        ],
        gold: [
            L.gold("stab riffs",
                   "Garage stab riffs mix chords and rhythms. Hear both at once."),
            K.quiz("One chord or two?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, chords: [K.ch(1, .em9), K.ch(3, .em9), K.ch(9, .em9), K.ch(11, .em9)])],
                       ["One chord", "Two chords"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats, chords: [K.ch(1, .em9), K.ch(3, .em9), K.ch(9, .am9), K.ch(11, .am9)])],
                       ["One chord", "Two chords"], 1, "Em9, then Am9 answers.", bars: 2),
            ]),
            K.lane("Copy this riff", "Em9 and Am9 take turns.", .recreate, palette: [.em9, .am9], backing: G.skippy,
                   target: [1: 0, 3: 0, 6: 1, 9: 0, 11: 1, 15: 1]),
            K.lane("Fix the riff", "It needs its bright moment: the stab on step 12 should be Cmaj9.", .recreate,
                   palette: [.em9, .am9, .cmaj9], backing: G.skippy,
                   start: [0: 0, 5: 1, 7: 1, 11: 0, 13: 0], target: [0: 0, 5: 1, 7: 1, 11: 2, 13: 0]),
            K.lane("Make it yours", "At least 6 stabs.", .create(.chordsAtLeast(6)), palette: [.em9, .am9, .cmaj9],
                   backing: G.skippy),
        ])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("new two-chord loops",
                     "Em9 to Am9 is the classic, but Em9 to Cmaj9 lifts the mood and Em9 to Dm9 drops it."),
            K.quiz("Lift or drop?", "Each loop starts on Em9.", [
                K.round([.em9, .cmaj9], ["Lifts", "Drops"], 0, "Cmaj9 is major: the mood brightens.", question: "Does the second chord lift or drop?"),
                K.round([.em9, .dm9], ["Lifts", "Drops"], 1, "Dm9 sits lower and darker.", question: "Does the second chord lift or drop?"),
                K.round([.em9, .am9], ["Lifts", "Drops"], 1, "Classic garage: moody, but moving.", question: "Does the second chord lift or drop?"),
            ]),
            K.lane("Switch to Cmaj9 for the second half", "Change steps 12 and 14 to Cmaj9.", .rule,
                   palette: [.em9, .cmaj9], backing: G.twoStep, start: [3: 0, 5: 0, 11: 0, 13: 0],
                   target: [3: 0, 5: 0, 11: 1, 13: 1]),
            K.lane("Copy this loop", "Em9 and Dm9 swap back and forth.", .recreate, palette: [.em9, .dm9], backing: G.twoStep,
                   target: [3: 0, 5: 1, 11: 0, 13: 1]),
            K.lane("Write your own two-chord loop", "Start on Em9, then pick the chord that sets the mood you want. At least 4 stabs.",
                   .create(.chordsAtLeast(4)), palette: [.em9, .am9, .cmaj9, .dm9], backing: G.twoStep),
        ],
        gold: [
            L.gold("three and four-chord loops", "Garage loops often use four ninths."),
            K.quiz("Count the chords", "", [
                K.round([.em9, .am9, .em9, .am9], ["Two", "Four"], 0, question: "How many different chords?"),
                K.round([.em9, .am9, .cmaj9, .dm9], ["Two", "Four"], 1, question: "How many different chords?"),
            ]),
            K.lane("Fix the loop", "Cmaj9 should take over on step 12, not step 14. Change the stab on step 12.", .recreate,
                   palette: [.em9, .am9, .cmaj9], backing: G.twoStep,
                   start: [3: 0, 5: 0, 9: 1, 11: 1, 13: 2], target: [3: 0, 5: 0, 9: 1, 11: 2, 13: 2]),
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
            K.lane("Fix it by ear", "This loop should end on the bright chord. Listen and fix the last stab.", .recreate,
                   palette: [.em9, .am9, .cmaj9], backing: G.twoStep, start: [3: 0, 7: 1, 11: 0], target: [3: 0, 7: 1, 11: 2]),
            K.lane("Recreate what you hear", "Two chords. It starts on Am9. Is the second darker?", .recreate,
                   palette: [.am9, .dm9, .em9], backing: G.twoStep, target: [3: 0, 11: 1]),
        ],
        gold: [
            L.gold("three-chord ear training", "Now follow three chords in a row."),
            K.quiz("Which chord comes third?", "Follow the top note as it moves.", [
                K.round([.em9, .am9, .cmaj9], ["Cmaj9", "Dm9"], 0), K.round([.em9, .cmaj9, .dm9], ["Am9", "Dm9"], 1),
                K.round([.am9, .em9, .am9], ["Am9", "Cmaj9"], 0), K.round([.cmaj9, .dm9, .em9], ["Em9", "Am9"], 0),
            ]),
            K.lane("Recreate what you heard", "Em9, Am9, Cmaj9.", .recreate, palette: [.em9, .am9, .cmaj9],
                   backing: G.twoStep, target: [3: 0, 7: 1, 11: 2]),
            K.lane("Two chords swapped", "Two of these four chords have swapped places. Listen for which should be brighter.", .recreate,
                   palette: [.em9, .am9, .cmaj9, .dm9], backing: G.skippy,
                   start: [1: 0, 5: 1, 9: 3, 13: 2], target: [1: 0, 5: 1, 9: 2, 13: 3]),
            K.lane("Make it yours", "Write a four-chord loop. Play it back and name every chord in your head.", .create(.chordsAtLeast(4)),
                   palette: [.em9, .am9, .cmaj9, .dm9], backing: G.skippy),
        ])

    static let chordsBacking = Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                       chords: [K.ch(3, .em9, 2), K.ch(11, .am9, 2)])

    static let u3l5: LevelPair = (
        silver: [
            L.silver("roots that bounce",
                     "Start each chord on its root, then add a skip or an octave."),
            K.quiz("Quick check", "", [
                K.ask("Under Cmaj9 the bass plays G. Why does that work?", ["G is one of Cmaj9's notes", "G is the root of Cmaj9"], 0,
                      "C isn't in our bass rows, but G is part of the chord, so it still fits."),
                K.hear([chordsBacking.keeping([.kick, .clap, .hat], bass: false, chords: true)], ["Em9 then Am9", "Em9 then Cmaj9"], 0, bars: 2,
                       question: "Which chords are these?"),
            ]),
            bass("Roots with a bounce", "E under Em9, A under Am9, each with a second note.",
                 [NoteEvent(3, 40, 2), NoteEvent(6, 40), NoteEvent(11, 45, 2), NoteEvent(14, 45)], backing: chordsBacking),
            K.fixNotes("Roots under Cmaj9", "E under Em9, then the bass should move to G under Cmaj9. It's stuck on E.", rows: rows,
                       broken: [NoteEvent(3, 40, 4), NoteEvent(11, 40, 4)], target: [NoteEvent(3, 40, 4), NoteEvent(11, 43, 4)],
                       backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                        chords: [K.ch(3, .em9, 2), K.ch(11, .cmaj9, 2)])),
            bassMake("Write roots that bounce", "E under Em9, A under Am9, then add a skip after each. At least 4 notes.",
                     backing: chordsBacking, notes: 4),
        ],
        gold: [
            L.gold("bass and chords together", "Follow three chords with a moving bassline."),
            K.quiz("Which notes fit?", "", [
                K.ask("Am9 is A, C, E, G and B. Which bass notes fit under it?", ["A or E", "D or F"], 0,
                      "Any note inside the chord fits. The root, A, fits best."),
            ]),
            bass("Copy this bassline", "E under Em9, A under Am9, then G and D under Cmaj9.", [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(5, 47), NoteEvent(8, 45),
                                            NoteEvent(11, 45), NoteEvent(13, 43), NoteEvent(15, 38)],
                 backing: Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats,
                                  chords: [K.ch(3, .em9, 2), K.ch(8, .am9, 2), K.ch(13, .cmaj9, 2)]), threshold: 0.9),
            K.fixNotes("Land on the root", "When Am9 arrives on step 9, the bass should land on A. It's playing D.", rows: rows,
                       broken: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(5, 47), NoteEvent(8, 38), NoteEvent(11, 45), NoteEvent(13, 43), NoteEvent(15, 38)],
                       target: [NoteEvent(0, 40), NoteEvent(3, 40), NoteEvent(5, 47), NoteEvent(8, 45), NoteEvent(11, 45), NoteEvent(13, 43), NoteEvent(15, 38)],
                       backing: Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats,
                                        chords: [K.ch(3, .em9, 2), K.ch(8, .am9, 2), K.ch(13, .cmaj9, 2)])),
            bassMake("Make it yours", "At least 7 notes under the chords.",
                     backing: Pattern(kick: [0, 10], clap: [4, 12], hat: skipHats,
                                      chords: [K.ch(3, .em9, 2), K.ch(8, .am9, 2), K.ch(13, .cmaj9, 2)]), notes: 7),
        ])

    // MARK: Unit 5 — Speed Garage & the Drop


    static let u4l3: LevelPair = (
        silver: [
            L.silver("speed garage bounce",
                     "Speed garage puts the four-on-the-floor kick under garage swing, with a bass that bounces on the offbeats."),
            K.quiz("Still swinging?", "Four kicks on the floor. Listen to the hats.", [
                K.hear([speed], ["Straight", "Swung"], 0, bars: 2, swing: 0),
                K.hear([speed], ["Straight", "Swung"], 1, "Speed garage keeps garage swing even with a steady kick.", bars: 2, swing: 0.3),
            ]),
            bass("Copy this speed garage bass", "Low B on the offbeats, with octave flicks up.", [NoteEvent(2, 35), NoteEvent(3, 47), NoteEvent(6, 35), NoteEvent(10, 35),
                                                     NoteEvent(11, 47), NoteEvent(14, 40)], backing: speed),
            L.copy("Copy the speed garage drums", "Four kicks, two claps and a rim.", tracks: kit, edit: [.hat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 3, 6, 10, 11, 14], perc: [7, 15])),
            K.fixNotes("Get off the kicks", "Speed garage bass bounces between the kicks. Two notes land on top of kicks. Move each one to the offbeat after it.", rows: rows,
                       broken: [NoteEvent(2, 35), NoteEvent(3, 47), NoteEvent(4, 35), NoteEvent(10, 35), NoteEvent(11, 47), NoteEvent(12, 40)],
                       target: [NoteEvent(2, 35), NoteEvent(3, 47), NoteEvent(6, 35), NoteEvent(10, 35), NoteEvent(11, 47), NoteEvent(14, 40)],
                       backing: speed),
        ],
        gold: [
            L.gold("the speed garage sound", "Rebuild the drums, then the bass, then shape the bass tone."),
            K.quiz("Clean or wobbly?", "", [
                K.sound(Pattern(kick: [0, 4, 8, 12], clap: [4, 12], bass: [NoteEvent(2, 35), NoteEvent(6, 35), NoteEvent(7, 47), NoteEvent(10, 35)]),
                        [.bassCutoff: 0.35, .bassEnv: 0.7, .bassResonance: 0.75], ["Clean", "Wobbly and resonant"], 1),
                K.sound(Pattern(kick: [0, 4, 8, 12], clap: [4, 12], bass: [NoteEvent(2, 35), NoteEvent(6, 35), NoteEvent(7, 47), NoteEvent(10, 35)]),
                        [.bassCutoff: 0.6, .bassEnv: 0.2, .bassResonance: 0.1], ["Clean", "Wobbly and resonant"], 0),
                K.ask("What does speed garage keep from two-step?", ["The swing and skippy hats", "The broken kick", "The slow tempo"], 0,
                      "It swaps the broken kick for four on the floor, and keeps the shuffle."),
            ]),
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
            K.quiz("Quick check", "", [
                K.ask("Why do garage intros often hold back the kick and bass?", ["To leave room for the vocal and save the punch for the drop",
                      "Because DJs don't like kicks", "So the track is shorter"], 0,
                      "Starting light gives DJs something to mix with and makes the drop land harder."),
            ]),
            arr("Fix this intro", "The kick and clap have crept into the Intro. Take them out so hats and chords open the track.", .recreate,
                start: K.grid("xxx-", "x-x-", "xxxx", "-xx-", "xx-x"), target: K.grid("-xx-", "--x-", "xxxx", "-xx-", "xx-x")),
            arr("Intro: chords only", "Switch off everything in the Intro except the chords.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("-xxx", "-xxx", "-xxx", "-xxx", "xxxx")),
        ],
        gold: [
            L.gold("whole garage tracks", "Hear the whole thing, then check part by part."),
            K.quiz("Which section?", "", [
                K.hear([G.full.keeping([.hat], bass: false, chords: true)], ["Intro or Break", "Drop"], 0, bars: 2),
                K.hear([G.full], ["Intro or Break", "Drop"], 1, "Everything is in: kick, bass, chords and the full kit.", bars: 2),
            ]),
            arr("Recreate this track", "The bass waits for the Drop and stays for the Break.", .recreate, target: K.grid("-xx-", "-xxx", "xxx-", "--xx", "xx-x")),
            arr("Fix the Break", "The Break has gone silent apart from hats. Bring the chords back so it still has something to carry it.", .recreate,
                start: K.grid("--x-", "-xx-", "xxxx", "--x-", "xx--"), target: K.grid("--x-", "-xx-", "xxxx", "--x-", "xx-x")),
            arr("Make it yours", "Start small and keep the bass for the Drop.", .create(.variedSections)),
        ])

    static let u4l5: LevelPair = (
        silver: [
            L.silver("the bass drop",
                     "In garage the drop is all about the bass arriving. Keep it out until then."),
            K.quiz("Feel the arrival", "", [
                K.filtered(G.full, cutoff: 400, ["Before the drop", "The drop"], 0, "Filtered down, the bass and kick are just a rumble."),
                K.hear([G.full.keeping([.kick, .clap, .hat, .perc], bass: false, chords: true), G.full], ["The first", "The second"], 1,
                       "The bass arriving is the drop.", question: "Which one is the drop?"),
            ]),
            arr("Copy this track", "Kick and bass both wait for the Drop.", .recreate, target: K.grid("--x-", "-xx-", "xxxx", "--x-", "x-xx")),
            arr("Save the bass for the Drop", "Switch off the bass everywhere except the Drop.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("xxxx", "xxxx", "xxxx", "--x-", "xxxx")),
            arr("Write your own drop", "Keep the bass out until the Drop, then bring everything in.", .create(.variedSections)),
        ],
        gold: [
            L.gold("two drops", "The second drop should feel bigger than the first."),
            K.quiz("Which drop hits harder?", "", [
                K.hear([G.full.keeping([.kick, .clap, .hat], bass: true, chords: false), G.full], ["The first", "The second"], 1,
                       "Chords and rims on top make the second one fuller.", question: "Which drop hits harder?"),
            ]),
            arr("Recreate this track", "The Break is chords alone.", .recreate, sections: ["Intro", "Drop", "Break", "Drop 2"],
                target: K.grid("-x-x", "-x-x", "xx-x", "-x-x", "x-xx")),
            arr("Fix Drop 2", "The bass is playing through the Break and missing from Drop 2. Swap it so Drop 2 lands with full force.", .recreate,
                sections: ["Intro", "Drop", "Break", "Drop 2"],
                start: K.grid("-x-x", "-xxx", "xxxx", "-xx-", "xxxx"), target: K.grid("-x-x", "-xxx", "xxxx", "-x-x", "xxxx")),
            arr("Make it yours", "Make Drop 2 bigger than the first.", .create(.variedSections), sections: ["Intro", "Drop", "Break", "Drop 2"]),
        ])
}
