//
//  TechHouseLevels.swift
//  Groova
//
//  Hand-written Silver and Gold levels for the Tech House course.
//

import Foundation

nonisolated enum TechHouseLevels {
    typealias T = TechHouseCourse
    static let u = K.u
    static let rows = T.rows
    static let kit: [DrumTrack] = [.kick, .clap, .hat, .openHat, .perc]
    static let shuffle = [1, 3, 5, 7, 9, 11, 13, 15]
    static let beat = Pattern(kick: [0, 4, 8, 12], clap: [4, 12])
    static let bassBed = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])

    static func bass(_ prompt: String, _ hint: String, _ notes: [NoteEvent], backing: Pattern = T.basic,
                     threshold: Double = 0.85) -> LessonStep {
        L.bass(prompt, hint, notes, backing: backing, rows: rows, threshold: threshold)
    }

    static func bassMake(_ prompt: String, _ hint: String, backing: Pattern = T.drums, notes: Int) -> LessonStep {
        L.bassMake(prompt, hint, backing: backing, notes: notes, rows: rows)
    }

    static let all: [String: LevelPair] = [
        "tech.u1.l1": u1l1, "tech.u1.l2": u1l2, "tech.u1.l3": u1l3, "tech.u1.l4": u1l4, "tech.u1.l5": u1l5,
        "tech.u2.l1": u2l1, "tech.u2.l2": u2l2, "tech.u2.l3": u2l3, "tech.u2.l4": u2l4, "tech.u2.l5": u2l5,
        "tech.u3.l1": u3l1, "tech.u3.l2": u3l2, "tech.u3.l3": u3l3, "tech.u3.l4": u3l4, "tech.u3.l5": u3l5,
        "tech.u4.l1": u4l1, "tech.u4.l2": u4l2, "tech.u4.l3": u4l3, "tech.u4.l4": u4l4, "tech.u4.l5": u4l5,
    ]

    // MARK: Unit 1 — The Rolling Groove

    static let u1l1: LevelPair = (
        silver: [
            L.silver("punch and placement",
                     "Tech house kicks are tight and punchy. Shape the punch, then try claps in new places: a clap on the offbeat or a double clap changes the whole swagger."),
            K.lab("Match the tight, punchy kick", "Short, slightly higher, some drive.", [.kickPitch, .kickDecay, .kickDrive],
                  start: [0.1, 0.8, 0.0], target: [0.35, 0.15, 0.5], loop: T.basic),
            L.copy("Copy the double clap", "A second clap sneaks in at the end of the bar.", tracks: [.kick, .clap],
                   edit: [.kick, .clap], target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 15])),
            L.copy("Copy this one", "The clap moves late in the second half.", tracks: [.kick, .clap, .hat],
                   edit: [.clap], start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 13], hat: [2, 6, 10, 14])),
        ],
        gold: [
            L.gold("the backbone under pressure",
                   "In a full tech house groove the kick and clap fight the percussion for space. Set the kick, then rebuild the whole backbone."),
            K.lab("Match the kick in the full groove", "Short, fairly low, lots of drive.", [.kickPitch, .kickDecay, .kickDrive], start: [0.8, 0.8, 0.0],
                  target: [0.3, 0.25, 0.65], loop: T.full),
            L.copy("Rebuild this groove", "An extra clap after beat 4. Rims lead into each clap.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 14], hat: [2, 6, 10, 14], perc: [3, 11]),
                   threshold: 0.9),
            L.make("Make it yours", "A groove from silence. At least 2 claps.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], goal: .atLeast(.clap, 2)),
        ])

    static let u1l2: LevelPair = (
        silver: [
            L.silver("shuffle in pockets",
                     "Swing only moves the in-between 16ths. Leave a few out and the shuffle falls into pockets instead of a steady roll."),
            L.copy("Copy these hats", "In-between 16ths, with two gaps.", tracks: [.kick, .clap, .hat], edit: [.hat],
                   start: beat, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 7, 9, 11, 15])),
            K.swingMake("Shuffle it more", "Past 18%.", tracks: [.kick, .clap, .hat],
                        start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 7, 9, 11, 15]), atLeast: 0.18),
        ],
        gold: [
            L.gold("closed and open shuffle",
                   "Pro tech house layers a steady shuffle with open hats on the offbeat. Rebuild both, then swing them together."),
            L.copy("Rebuild the hats", "Shuffle hats with one gap, open hats on the offbeats.", tracks: [.kick, .clap, .hat, .openHat], edit: [.hat, .openHat], start: beat,
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 9, 11, 13, 15], openHat: [2, 6, 10, 14]),
                   threshold: 0.9),
            K.swingMake("Swing the lot", "Past 22%.", tracks: [.kick, .clap, .hat, .openHat],
                        start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle, openHat: [2, 6, 10, 14]),
                        atLeast: 0.22),
            L.make("Make it yours", "At least 6 closed hats.", tracks: [.kick, .clap, .hat, .openHat],
                   edit: [.hat, .openHat], start: beat, goal: .atLeast(.hat, 6)),
        ])

    static let u1l3: LevelPair = (
        silver: [
            L.silver("percussion that answers",
                     "Good percussion answers the clap. Rims after the clap feel like a reply, rims before it feel like a question."),
            L.copy("Copy the reply rims", "Rims just after each clap.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc],
                   start: T.basic, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [5, 7, 13])),
            L.copy("Copy the question rims", "Rims leading into each clap.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc],
                   start: T.basic, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [1, 3, 11])),
            L.make("Write your own", "At least 5 rims.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: T.basic,
                   goal: .atLeast(.perc, 5)),
        ],
        gold: [
            L.gold("two percussion layers",
                   "Tech house stacks two kinds of percussion that never land together. Use rims and open hats as the two layers."),
            L.copy("Rebuild both layers", "Two open hats. Rims in pairs, never with them.", tracks: kit, edit: [.openHat, .perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle, openHat: [2, 10], perc: [3, 6, 13, 14]),
                   threshold: 0.9),
            L.copy("Rebuild this one", "Closed hats after each beat, open hats on the offbeats, three rims.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14], perc: [3, 7, 11]),
                   threshold: 0.9),
            L.make("Make it yours", "Rims and open hats. At least 4 rims.", tracks: kit, edit: [.openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle), goal: .atLeast(.perc, 4)),
        ])

    static let u1l4: LevelPair = (
        silver: [
            L.silver("offbeat variations",
                     "Rims on every offbeat are a base. Drop one or push one late and you get a groove with a hook."),
            L.copy("Copy this variation", "One offbeat rim is missing and one moves early.", tracks: [.kick, .clap, .perc],
                   edit: [.perc], start: beat, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [2, 5, 14])),
            L.copy("Copy the doubled rims", "Every offbeat rim gets a partner.", tracks: [.kick, .clap, .perc], edit: [.perc],
                   start: beat, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [2, 3, 6, 10, 11, 14])),
        ],
        gold: [
            L.gold("offbeats across the kit",
                   "Rims and open hats both love the offbeat. Rebuild grooves where they take turns."),
            L.copy("Rebuild the offbeats", "Open hats on two offbeats, rims on the other two plus one at the end.", tracks: kit, edit: [.openHat, .perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle, openHat: [2, 10], perc: [6, 14, 15]),
                   threshold: 0.9),
            L.copy("Copy the offbeat swap", "Open hats take the first half, rims the second.", tracks: kit,
                   edit: [.openHat, .perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle, openHat: [2, 6], perc: [10, 13, 14]),
                   threshold: 0.9),
            L.make("Make it yours", "At least 4 offbeat rims.", tracks: kit, edit: [.perc, .openHat],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.perc, 4)),
        ])

    static let u1l5: LevelPair = (
        silver: [
            L.silver("rolling grooves by ear",
                     "Now build full grooves with nothing written down."),
            L.copy("Copy this rolling groove", "Shuffle hats with two gaps. Rims right after each clap.", tracks: kit, edit: [.hat, .openHat, .perc], start: beat,
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 7, 9, 11, 15], openHat: [2, 6, 10, 14],
                                   perc: [5, 13])),
            L.copy("Copy this one", "The rims move to the end of the bar.", tracks: kit, edit: [.hat, .openHat, .perc],
                   start: beat, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle, openHat: [2, 10],
                                                perc: [11, 13, 14])),
        ],
        gold: [
            L.gold("the whole groove from silence", "Every drum, rebuilt by ear."),
            L.copy("Rebuild this groove", "A ghost clap at the end. Rims in the first half only.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 15], hat: [1, 3, 5, 9, 11, 13], openHat: [2, 6, 10, 14],
                                   perc: [3, 7]), threshold: 0.9),
            L.copy("Rebuild this one", "A kick pickup before beat 4. Open hats on two offbeats only.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 11, 12], clap: [4, 12], hat: shuffle, openHat: [6, 14], perc: [2, 9, 10]),
                   threshold: 0.9),
            L.make("Make it yours", "A full rolling groove. At least 4 kicks.", tracks: kit, edit: Set(kit),
                   goal: .atLeast(.kick, 4)),
        ])

    // MARK: Unit 2 — Rolling Bass

    static let u2l1: LevelPair = (
        silver: [
            L.silver("offbeats on new notes",
                     "The offbeat bass doesn't have to stay on C. Move one note and the groove starts to move too."),
            bass("Copy this offbeat line", "C, C, E♭, C.", [NoteEvent(2, 36), NoteEvent(6, 36), NoteEvent(10, 39), NoteEvent(14, 36)]),
            bass("Copy this one", "It dips to low B♭ at the end.",
                 [NoteEvent(2, 36), NoteEvent(6, 43), NoteEvent(10, 36), NoteEvent(14, 34)]),
            bassMake("Write your own", "At least 4 notes on the offbeats.", backing: T.basic, notes: 4),
        ],
        gold: [
            L.gold("offbeats with pickups",
                   "Add a short note just before an offbeat and the bass gets a kick of its own."),
            bass("Copy this line", "Pickups lead into the C on step 7. Then it climbs.", [NoteEvent(2, 36), NoteEvent(5, 36), NoteEvent(6, 36), NoteEvent(10, 39),
                                        NoteEvent(13, 41), NoteEvent(14, 43)], threshold: 0.9),
            bass("Copy this one", "Low B♭ leads into C. An octave jump in the middle.", [NoteEvent(1, 34), NoteEvent(2, 36), NoteEvent(6, 46), NoteEvent(9, 36),
                                       NoteEvent(10, 36), NoteEvent(14, 39)], backing: T.drums, threshold: 0.9),
            bassMake("Make it yours", "At least 6 notes.", backing: T.basic, notes: 6),
        ])

    static let u2l2: LevelPair = (
        silver: [
            L.silver("pairs in new places",
                     "Rolling bass is built from pairs. Move where the pairs land and the roll changes direction."),
            bass("Copy these pairs", "Pairs before each clap.", K.notes(36, [2, 3, 10, 11]) + K.notes(39, [6, 7]),
                 backing: bassBed),
            bass("Copy this roll", "Pairs climbing up through E♭ and F.",
                 [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(6, 39), NoteEvent(7, 39), NoteEvent(10, 41),
                  NoteEvent(11, 41), NoteEvent(14, 36)], backing: bassBed),
        ],
        gold: [
            L.gold("full rolling lines",
                   "The best tech house basslines never repeat a pair the same way twice."),
            bass("Copy this rolling line", "Pairs of C, broken up by G, E♭ and low B♭.", [NoteEvent(1, 36), NoteEvent(2, 36), NoteEvent(3, 43), NoteEvent(6, 36),
                                                NoteEvent(7, 36), NoteEvent(10, 39), NoteEvent(11, 36), NoteEvent(14, 34),
                                                NoteEvent(15, 36)], backing: T.drums, threshold: 0.9),
            bass("Copy this one", "C on every offbeat, each followed by a different note.", [NoteEvent(2, 36), NoteEvent(3, 46), NoteEvent(6, 36), NoteEvent(7, 43),
                                       NoteEvent(10, 36), NoteEvent(11, 41), NoteEvent(14, 39), NoteEvent(15, 36)],
                 backing: T.drums, threshold: 0.9),
            bassMake("Make it yours", "At least 8 notes.", notes: 8),
        ])

    static let u2l3: LevelPair = (
        silver: [
            L.silver("bite and resonance",
                     "Envelope gives the bass its bite. Resonance turns the bite into a squelch. Tech house lives right between them."),
            K.lab("Match the squelchy bass", "Bite plus resonance.", [.bassEnv, .bassResonance], start: [0.1, 0.0],
                  target: [0.6, 0.65], loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: T.rolling)),
            K.lab("Match the dark, short bass", "Both well down.", [.bassCutoff, .bassDecay], start: [0.9, 0.8], target: [0.2, 0.2],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: T.rolling)),
        ],
        gold: [
            L.gold("the full bass tone", "Four controls, with the whole groove playing."),
            K.lab("Match this bass", "Short and biting, with some resonance.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay], start: [0.9, 0.0, 0.0, 0.9],
                  target: [0.35, 0.7, 0.4, 0.2], loop: T.full),
            K.lab("Match this one", "Brighter, less bite, longer notes.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay], start: [0.1, 0.9, 0.9, 0.1],
                  target: [0.55, 0.3, 0.15, 0.45], loop: T.full),
        ])

    static let u2l4: LevelPair = (
        silver: [
            L.silver("one line, two endings",
                     "Keep the first half of the bassline and change the second half. It's the easiest way to make a loop feel longer."),
            bass("Copy this ending", "The second half drops down.",
                 [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(10, 39), NoteEvent(11, 36),
                  NoteEvent(14, 34), NoteEvent(15, 34)]),
            bass("Copy this one", "The second half bounces on G.",
                 [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(10, 43), NoteEvent(12, 43),
                  NoteEvent(14, 46)]),
        ],
        gold: [
            L.gold("variations in the groove", "Copy two variations with the full groove, then write a third."),
            bass("Copy this variation", "Same start, then it climbs through F and E♭ to G.", [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(9, 36),
                                             NoteEvent(10, 41), NoteEvent(13, 39), NoteEvent(14, 41), NoteEvent(15, 43)],
                 backing: T.drums, threshold: 0.9),
            bass("Copy this one", "Same start, then it drops to low B♭.", [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(10, 34),
                                       NoteEvent(11, 34), NoteEvent(14, 36), NoteEvent(15, 39)],
                 backing: T.drums, threshold: 0.9),
            bassMake("Make it yours", "Start like the rolling line, end your own way. At least 7 notes.", notes: 7),
        ])

    static let u2l5: LevelPair = (
        silver: [
            L.silver("basslines that fit the drums",
                     "A rolling bassline should leave room for the kick. Write lines that sit between the kicks, then check them by ear."),
            bassMake("Write your own", "At least 5 notes, none on the kicks.", backing: T.basic, notes: 5),
            bass("Copy this one", "Every note avoids the kick.",
                 [NoteEvent(1, 36), NoteEvent(3, 36), NoteEvent(6, 39), NoteEvent(9, 36), NoteEvent(11, 43), NoteEvent(14, 36)],
                 backing: T.drums),
        ],
        gold: [
            L.gold("bass and percussion together",
                   "The bass and the rims share the gaps. Write the bass so it locks with the percussion."),
            bass("Copy this locked line", "Mostly C, filling the gaps between kicks and rims.", [NoteEvent(2, 36), NoteEvent(5, 36), NoteEvent(7, 43), NoteEvent(10, 36),
                                               NoteEvent(11, 39), NoteEvent(14, 36), NoteEvent(15, 34)],
                 backing: T.drums, threshold: 0.9),
            L.copy("Rebuild the rims around it", "Rims straight after every kick.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle, bass: T.rolling),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: shuffle, perc: [1, 5, 9, 13], bass: T.rolling)),
            bassMake("Make it yours", "At least 9 notes.", notes: 9),
        ])

    // MARK: Unit 3 — Pump & Punch

    static let mixC: [MixChannel] = [.drum(.kick), .drum(.clap), .drum(.hat), .drum(.perc), .bass]

    static let u3l1: LevelPair = (
        silver: [
            L.silver("drums against the bass",
                     "In tech house the kick and bass share the low end. One of them always has to be a little quieter."),
            K.mix("Match: kick on top", "Kick clearly on top.", [.drum(.kick), .drum(.clap), .bass], start: [u, u, u], target: [0.85, 0.6, 0.55],
                  loop: T.full),
            K.mix("Match: bass on top", "Bass clearly on top, rims low.", [.drum(.kick), .drum(.perc), .bass], start: [u, u, u], target: [0.6, 0.5, 0.85],
                  loop: T.full),
        ],
        gold: [
            L.gold("five-part balance", "Kick first, bass second, then the rest around them."),
            K.mix("Match this mix", "Kick, then bass, clap, rims and hats.", mixC, start: [u, u, u, u, u], target: [0.8, 0.65, 0.4, 0.5, 0.7], loop: T.full),
            K.mix("Match this one", "Bass leads. Rims level with the kick.", mixC, start: [u, u, u, u, u], target: [0.7, 0.5, 0.55, 0.7, 0.8], loop: T.full),
            K.mix("Make it yours", "Kick and bass first, then everything else.", mixC, start: [0.2, 0.2, 0.2, 0.2, 0.2], loop: T.full),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("how deep to pump",
                     "A little pump makes the bass breathe. A lot makes the whole track bounce. Hear both ends."),
            K.mix("Match: barely there", "Pump well down.", [.sidechain], start: [0.9], target: [0.25], loop: T.full),
            K.mix("Match: heavy pump", "Pump almost full, bass fairly loud.", [.bass, .sidechain], start: [u, 0.0], target: [0.7, 0.9], loop: T.full),
        ],
        gold: [
            L.gold("pump and level", "The deeper the pump, the louder the bass has to be."),
            K.mix("Match this mix", "Bass just above the kick, medium pump.", [.drum(.kick), .bass, .sidechain], start: [u, u, 0], target: [0.75, 0.8, 0.5],
                  loop: T.full),
            K.mix("Match this one", "Heavy pump, big kick, rims tucked in.", [.drum(.kick), .drum(.perc), .bass, .sidechain], start: [u, u, u, 0],
                  target: [0.85, 0.4, 0.65, 0.8], loop: T.full),
        ])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("drive and filters",
                     "Drive adds crunch to the kick. A resonant filter on the whole groove is a classic tech house DJ trick."),
            K.lab("Match the crunchy kick", "Lots of drive, low pitch.", [.kickDrive, .kickPitch, .kickDecay],
                  start: [0.0, 0.8, 0.8], target: [0.85, 0.2, 0.3], loop: T.basic),
            K.filterMatch("Match the resonant filter", "Dark with a sharp peak.", cutoff: 600, resonance: 0.8, T.full),
        ],
        gold: [
            L.gold("crunch in the mix", "Drive and filter both change how loud things feel. Match them together."),
            K.lab("Match this kick", "Medium drive, low pitch, medium length.", [.kickDrive, .kickPitch, .kickDecay], start: [0.9, 0.9, 0.0], target: [0.5, 0.3, 0.4],
                  loop: T.full),
            K.filterMatch("Match this filter", "Cutoff around the middle, a little resonance.", cutoff: 1500, resonance: 0.3, T.full),
            K.mix("Rebalance after the crunch", "Bass slightly above the kick.", [.drum(.kick), .bass], start: [u, u], target: [0.7, 0.8], loop: T.full),
        ])

    static let u3l4: LevelPair = (
        silver: [
            L.silver("percussion front and back",
                     "Loud percussion sits in your face. Quiet percussion with space sits at the back. Push it back."),
            K.mix("Match the percussion", "Open hats loudest, rims quietest.", [.drum(.perc), .drum(.openHat), .drum(.hat)], start: [u, u, u],
                  target: [0.35, 0.6, 0.5], loop: T.full),
            K.space("Give it space", "A small room keeps the groove tight.", T.drums),
        ],
        gold: [
            L.gold("the whole top end", "Hats, open hats, rims and clap all balanced at once."),
            K.mix("Match the top end", "Clap on top, open hats lowest.", [.drum(.clap), .drum(.hat), .drum(.openHat), .drum(.perc)], start: [u, u, u, u],
                  target: [0.7, 0.45, 0.35, 0.55], loop: T.full),
            K.mix("Match this one", "Closed hats on top, rims lowest.", [.drum(.clap), .drum(.hat), .drum(.openHat), .drum(.perc)], start: [u, u, u, u],
                  target: [0.55, 0.65, 0.5, 0.3], loop: T.full),
            K.space("Give it a room", "Pick a space that suits a club.", T.full),
        ])

    static let u3l5: LevelPair = (
        silver: [
            L.silver("mixing by ear",
                     "Listen for what's loudest first, then work down."),
            K.mix("Match this club mix", "Bass just above the kick, light pump.", [.drum(.kick), .drum(.perc), .bass, .sidechain], start: [u, u, u, 0],
                  target: [0.75, 0.6, 0.8, 0.4], loop: T.full),
        ],
        gold: [
            L.gold("six controls", "Five faders and the pump."),
            K.mix("Match this mix", "Kick and bass first, then the pump, then the top end.", mixC + [.sidechain], start: [u, u, u, u, u, 0],
                  target: [0.8, 0.6, 0.45, 0.5, 0.75, 0.6], loop: T.full),
            K.mix("Make it yours", "Start with kick and pump, then build around them.", mixC + [.sidechain], start: [0.2, 0.2, 0.2, 0.2, 0.2, 0], loop: T.full),
        ])

    // MARK: Unit 4 — Club Arrangement

    static let lanes = T.lanes
    static let allOn = K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx")
    static let club = ["Intro", "Build", "Drop", "Break", "Drop 2"]
    static func arr(_ prompt: String, _ hint: String, _ mode: TaskMode, sections: [String] = K.sections4,
                    start: [[Bool]] = [], target: [[Bool]] = []) -> LessonStep {
        K.arrange(prompt, hint, mode, sections: sections, lanes: lanes, loop: T.full, start: start, target: target)
    }

    static let u4l1: LevelPair = (
        silver: [
            L.silver("tool track structure",
                     "Tool tracks are made for DJs: long drum intros, one big idea, and simple edges."),
            arr("Copy this track", "Kick and hats play throughout. Rims join at the Drop.", .recreate, target: K.grid("xxxx", "-xx-", "xxxx", "--xx", "--x-")),
            arr("Rims only after the Intro", "Switch off the rims in the Intro.", .rule, start: allOn,
                target: K.grid("xxxx", "xxxx", "xxxx", "-xxx", "xxxx")),
        ],
        gold: [
            L.gold("five-section tool tracks", "Add a second drop and keep it DJ-friendly."),
            arr("Recreate this track", "Both drops have everything. The hats never stop.", .recreate, sections: club,
                target: K.grid("xxx-x", "--x-x", "xxxxx", "-xx-x", "--x-x")),
            arr("Make it yours", "Keep the Intro simple for DJs.", .create(.variedSections), sections: club),
        ])

    static let u4l2: LevelPair = (
        silver: [
            L.silver("builds by subtraction",
                     "You can also build by taking the kick away and letting the percussion carry the tension."),
            arr("Copy this build", "No kick in the Build. The bass waits for the Drop.", .recreate, target: K.grid("x-x-", "-xx-", "xxxx", "xxx-", "--x-")),
            arr("No kick in the Build", "Switch off the kick in the Build.", .rule, start: allOn,
                target: K.grid("x-xx", "xxxx", "xxxx", "xxxx", "xxxx")),
        ],
        gold: [
            L.gold("long builds", "Five sections, adding and removing one part at a time."),
            arr("Recreate this track", "The kick sits out the Build and the Break.", .recreate, sections: club,
                target: K.grid("x-x-x", "-xx-x", "xxxxx", "-xxxx", "--x-x")),
            arr("Recreate this one", "The kick skips the Build but stays for the Break.", .recreate, sections: club,
                target: K.grid("x-xxx", "--x-x", "xxxxx", "-x-xx", "--x-x")),
        ])

    static let u4l3: LevelPair = (
        silver: [
            L.silver("the drop hits harder",
                     "The drop hits harder if the section before it strips back. Take the bass and the kick out of the Build."),
            arr("Bass and kick out of the Build", "Switch both off in the Build column only.", .rule, start: allOn,
                target: K.grid("x-xx", "xxxx", "xxxx", "xxxx", "x-xx")),
            arr("Copy this track", "No kick in the Build. Bass only in the Drop.", .recreate, target: K.grid("x-xx", "-xx-", "xxxx", "xxxx", "--x-")),
        ],
        gold: [
            L.gold("two drops", "The second drop should hit even harder than the first."),
            arr("Recreate this track", "The Break is rims alone.", .recreate, sections: club,
                target: K.grid("x-x-x", "-xx-x", "xxx-x", "-xxxx", "--x-x")),
            arr("Recreate this one", "The hats skip the Build. The clap stays for the Break.", .recreate, sections: club,
                target: K.grid("xxx-x", "--xxx", "x-xxx", "-xx-x", "--x-x")),
        ])

    static let u4l4: LevelPair = (
        silver: [
            L.silver("different cuts",
                     "A cut is a tiny gap before the next section. Drop the kick, the hats or everything for the last beat."),
            L.copy("Copy this cut", "The kick and hats stop for the last beat.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .hat], start: Pattern(clap: [4, 12], perc: [3, 9, 13]),
                   target: Pattern(kick: [0, 4, 8], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11], perc: [3, 9, 13])),
            L.copy("Copy this one", "A rim roll fills the last beat.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.perc], start: Pattern(kick: [0, 4, 8], clap: [4], hat: [1, 3, 5, 7, 9, 11]),
                   target: Pattern(kick: [0, 4, 8], clap: [4], hat: [1, 3, 5, 7, 9, 11], perc: [3, 12, 13, 14, 15])),
        ],
        gold: [
            L.gold("fills from scratch", "Rebuild the whole bar, cut and fill included."),
            L.copy("Rebuild this fill", "The kick and hats stop early. Claps and rims trade in the last beat.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8], clap: [4, 12, 14], hat: [1, 3, 5, 7, 9], openHat: [2, 6], perc: [11, 13, 15]),
                   threshold: 0.9),
            L.copy("Rebuild this one", "A clap roll at the end, with a late kick before it.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 10], clap: [4, 13, 14, 15], hat: shuffle, openHat: [2, 6, 10], perc: [3, 9]),
                   threshold: 0.9),
            L.make("Make it yours", "Write your own fill. At least 3 claps.", tracks: kit, edit: Set(kit),
                   start: Pattern(kick: [0, 4, 8], hat: [1, 3, 5, 7, 9, 11]), goal: .atLeast(.clap, 3)),
        ])

    static let u4l5: LevelPair = (
        silver: [
            L.silver("club tracks by ear",
                     "Hear the whole thing once, then check part by part."),
            arr("Recreate this track", "The kick leaves for the Break. The bass only plays the Drop.", .recreate, target: K.grid("xxx-", "-xx-", "xxxx", "-x-x", "--x-")),
            arr("Recreate this one", "No kick in the Build, and the bass arrives early.", .recreate, target: K.grid("x-xx", "--x-", "xxxx", "xx-x", "-xx-")),
        ],
        gold: [
            L.gold("a full club track", "Five sections. Hear it, rebuild it, then make your own."),
            arr("Recreate this track", "The kick skips the Build and the Break.", .recreate, sections: club,
                target: K.grid("x-x-x", "--xxx", "xxxxx", "x-x-x", "--x-x")),
            arr("Make it yours", "Make Drop 2 hit harder than the first.", .create(.variedSections), sections: club),
        ])
}
