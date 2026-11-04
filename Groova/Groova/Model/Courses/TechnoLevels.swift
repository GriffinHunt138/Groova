//
//  TechnoLevels.swift
//  Groova
//
//  Hand-written Silver and Gold levels for the Techno course.
//

import Foundation

nonisolated enum TechnoLevels {
    typealias T = TechnoCourse
    static let u = K.u
    static let hats16 = Array(0..<16)
    static let kickLoop = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])
    static let acidLoop = Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: T.acid)
    static let kit: [DrumTrack] = [.kick, .hat, .openHat, .perc]
    static let kick3: [SoundParam] = [.kickPitch, .kickDecay, .kickDrive]
    static let bass4: [SoundParam] = [.bassCutoff, .bassEnv, .bassResonance, .bassDecay]
    static let mix5: [MixChannel] = [.drum(.kick), .drum(.hat), .drum(.openHat), .drum(.perc), .bass]

    static let all: [String: LevelPair] = [
        "techno.u1.l1": u1l1, "techno.u1.l2": u1l2, "techno.u1.l3": u1l3, "techno.u1.l4": u1l4, "techno.u1.l5": u1l5,
        "techno.u2.l1": u2l1, "techno.u2.l2": u2l2, "techno.u2.l3": u2l3, "techno.u2.l4": u2l4, "techno.u2.l5": u2l5,
        "techno.u3.l1": u3l1, "techno.u3.l2": u3l2, "techno.u3.l3": u3l3, "techno.u3.l4": u3l4, "techno.u3.l5": u3l5,
        "techno.u4.l1": u4l1, "techno.u4.l2": u4l2, "techno.u4.l3": u4l3, "techno.u4.l4": u4l4, "techno.u4.l5": u4l5,
        "techno.u5.l1": u5l1, "techno.u5.l2": u5l2, "techno.u5.l3": u5l3, "techno.u5.l4": u5l4, "techno.u5.l5": u5l5,
    ]

    // MARK: Unit 1 — Machine Rhythm

    static let u1l1: LevelPair = (
        silver: [
            L.silver("shape the 16ths",
                     "Sixteen straight hats drive the loop, but producers carve gaps into them. Gaps, open hats and rims give your ear something to follow."),
            L.copy("Copy the hats with gaps", "The closed hats skip the last step of every beat.",
                   tracks: [.kick, .hat], edit: [.hat], start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14])),
            L.copy("Copy the new hook", "Open hats on two offbeats only, and three rims.", tracks: kit,
                   edit: [.openHat, .perc], start: T.pulse,
                   target: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 10], perc: [3, 7, 13])),
            L.make("Write a rim hook", "At least four rims over the driving hats.", tracks: kit, edit: [.perc],
                   start: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 6, 10, 14]), goal: .atLeast(.perc, 4)),
        ],
        gold: [
            L.gold("the full machine",
                   "A techno loop is four parts locked together. Rebuild the whole kit by ear, one layer per listen."),
            L.copy("Rebuild the whole groove", "Kick, 16th hats, offbeat open hats and four rims.", tracks: kit,
                   edit: Set(kit), target: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 6, 10, 14],
                                                   perc: [3, 6, 11, 14]), threshold: 0.9),
            L.copy("Copy the kick ghost", "One extra kick pushes into beat 3. The rims answer it.",
                   tracks: [.kick, .hat, .perc], edit: [.kick, .perc], start: Pattern(hat: hats16),
                   target: Pattern(kick: [0, 4, 7, 8, 12], hat: hats16, perc: [3, 10, 14]), threshold: 0.9),
            L.make("Make it yours", "Build a full loop from silence. At least 5 rims.", tracks: kit, edit: Set(kit),
                   goal: .atLeast(.perc, 5)),
        ])

    static let u1l2: LevelPair = (
        silver: [
            L.silver("pitch shapes the rumble",
                     "Drive and length make a kick rumble. Pitch decides whether that rumble is felt in your chest or heard as a thud."),
            K.lab("Match the sub rumble", "Very low, long and driven.", kick3,
                  start: [0.5, 0.3, 0.3], target: [0.1, 0.85, 0.7], loop: kickLoop),
            K.lab("Match the punchy driven kick", "Higher, medium length, some drive.", kick3,
                  start: [0.1, 0.85, 0.7], target: [0.4, 0.4, 0.5], loop: kickLoop),
        ],
        gold: [
            L.gold("industrial to minimal",
                   "Industrial techno kicks are distorted to the edge. Minimal kicks are clean and short. Match both extremes and the long boom in between."),
            K.lab("Match the industrial kick", "Maximum grit.", kick3,
                  start: [0.5, 0.3, 0.1], target: [0.2, 0.6, 0.95], loop: kickLoop),
            K.lab("Match the minimal kick", "Clean, short and a little higher.", kick3,
                  start: [0.2, 0.6, 0.95], target: [0.35, 0.25, 0.05], loop: kickLoop),
            K.lab("Match the long boom", "Low, very long, some drive.", kick3,
                  start: [0.5, 0.2, 0.2], target: [0.15, 0.95, 0.6], loop: kickLoop),
            K.lab("Make it yours", "Design your own warehouse kick.", kick3, start: [0.5, 0.5, 0.5], loop: kickLoop),
        ])

    static let u1l3: LevelPair = (
        silver: [
            L.silver("rims against the kick",
                     "Off-grid rims hook your ear because they never line up with the kick. Move them and the whole loop changes character."),
            L.copy("Copy these three rims", "None land on a beat.", tracks: [.kick, .hat, .perc], edit: [.perc],
                   start: T.pulse, target: Pattern(kick: [0, 4, 8, 12], hat: hats16, perc: [1, 6, 11])),
            L.copy("Copy the drifting rims", "Four rims, spaced three steps apart.", tracks: [.kick, .hat, .perc],
                   edit: [.perc], start: T.pulse, target: Pattern(kick: [0, 4, 8, 12], hat: hats16, perc: [3, 6, 9, 14])),
            L.make("Write your own rim hook", "At least four rims, none on the beat.", tracks: [.kick, .hat, .perc],
                   edit: [.perc], start: T.pulse, goal: .atLeast(.perc, 4)),
        ],
        gold: [
            L.gold("rims and open hats",
                   "Rims and open hats talk to each other. When one plays, the other waits. Rebuild both, then the whole loop."),
            L.copy("Copy the conversation", "Two open hats, four rims in between.", tracks: kit, edit: [.openHat, .perc],
                   start: T.pulse, target: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 10], perc: [5, 7, 13, 15]),
                   threshold: 0.9),
            L.copy("Rebuild this loop", "Eighth-note hats and four rims.", tracks: [.kick, .hat, .perc],
                   edit: [.kick, .hat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14], perc: [3, 6, 11, 14]),
                   threshold: 0.9),
            L.make("Make it yours", "Write rims and open hats. At least 5 rims.", tracks: kit, edit: [.openHat, .perc],
                   start: T.pulse, goal: .atLeast(.perc, 5)),
        ])

    static let u1l4: LevelPair = (
        silver: [
            L.silver("hats in groups",
                     "Grouping closed hats in pairs or around the beat makes a pattern you can hear repeating, even inside a wall of 16ths."),
            L.copy("Copy the paired hats", "Closed hats in pairs, open hats on the offbeats.", tracks: [.kick, .hat, .openHat],
                   edit: [.hat], start: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 4, 5, 8, 9, 12, 13], openHat: [2, 6, 10, 14])),
            L.copy("Copy the hats around the beat", "Closed hats just before and on each beat.", tracks: [.kick, .hat, .openHat],
                   edit: [.hat], start: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [0, 3, 4, 7, 8, 11, 12, 15], openHat: [2, 6, 10, 14])),
            L.make("Write grouped hats", "At least 10 closed hats.", tracks: [.kick, .hat, .openHat], edit: [.hat],
                   start: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14]), goal: .atLeast(.hat, 10)),
        ],
        gold: [
            L.gold("hats that hypnotise",
                   "Techno swing is subtle, just enough to stop the machine feeling stiff. Open hats can also drift off the offbeat to create tension."),
            K.swingMake("Add subtle swing", "Just past 15%. Techno swing is felt, not heard.", tracks: [.kick, .hat, .openHat],
                        start: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 6, 10, 14]), atLeast: 0.15),
            L.copy("Copy the drifting open hats", "Open hats move off the offbeat in the second half.",
                   tracks: [.kick, .hat, .openHat], edit: [.openHat], start: Pattern(kick: [0, 4, 8, 12], hat: hats16),
                   target: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 5, 10, 13]), threshold: 0.9),
            L.copy("Rebuild all the hats", "Closed hats skip around the open hats.", tracks: [.kick, .hat, .openHat, .perc],
                   edit: [.hat, .openHat], start: Pattern(kick: [0, 4, 8, 12], perc: [3, 11]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 3, 5, 7, 8, 9, 11, 13, 15], openHat: [2, 6, 10, 14],
                                   perc: [3, 11]), threshold: 0.9),
            L.make("Make it yours", "Write closed and open hats. At least 10 closed.", tracks: [.kick, .hat, .openHat],
                   edit: [.hat, .openHat], start: Pattern(kick: [0, 4, 8, 12]), goal: .atLeast(.hat, 10)),
        ])

    static let u1l5: LevelPair = (
        silver: [
            L.silver("loops that hold attention",
                     "A loop that repeats for minutes needs one detail that catches the ear every bar: a missing hat, an extra rim."),
            L.copy("Copy this loop", "One hat is missing at the very end.", tracks: kit, edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<15), openHat: [2, 6, 10, 14], perc: [3, 6, 11])),
            L.make("Write a busier rim part", "At least five rims.", tracks: kit, edit: [.perc],
                   start: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 6, 10, 14]), goal: .atLeast(.perc, 5)),
            L.make("Now write the hats", "At least ten closed hats.", tracks: kit, edit: [.hat, .openHat],
                   start: Pattern(kick: [0, 4, 8, 12], perc: [3, 6, 11]), goal: .atLeast(.hat, 10)),
        ],
        gold: [
            L.gold("a loop from silence",
                   "Now write the whole thing. Start with the kick, add hats for drive, then rims for the hook."),
            L.copy("Rebuild this loop", "A kick pickup, gappy hats, three rims.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 12, 15], hat: [0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14],
                                   openHat: [2, 6, 10, 14], perc: [3, 7, 11]), threshold: 0.9),
            L.make("Write a full loop", "Every part is yours. At least 4 rims.", tracks: kit, edit: Set(kit),
                   goal: .atLeast(.perc, 4)),
            L.make("Make it yours", "A second loop, busier this time. At least 12 closed hats.", tracks: kit,
                   edit: Set(kit), goal: .atLeast(.hat, 12)),
        ])

    // MARK: Unit 2 — Rumble & Acid

    static let u2l1: LevelPair = (
        silver: [
            L.silver("rolling with movement",
                     "A rolling bass keeps the same rhythm but moves pitch every beat. Note length also changes the rumble."),
            L.bass("Copy the climbing roll", "Same 16th pairs, stepping up each half bar.",
                   K.notes(33, [2, 3, 6, 7]) + K.notes(36, [10, 11]) + K.notes(40, [14, 15]), backing: T.pulse),
            L.bass("Copy the long roll", "One long note after every kick.",
                   [NoteEvent(2, 33, 2), NoteEvent(6, 33, 2), NoteEvent(10, 38, 2), NoteEvent(14, 36, 2)], backing: T.pulse),
            L.bassMake("Write your own roll", "At least 8 notes in the gaps between kicks.", backing: T.pulse, notes: 8),
        ],
        gold: [
            L.gold("the rumble line",
                   "Peak-time techno fills every 16th the kick doesn't use. Octave flicks keep it from feeling static."),
            L.bass("Copy the full rumble", "Every 16th except where the kick lands.",
                   K.notes(33, [1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15]), backing: T.pulse, threshold: 0.9),
            L.bass("Copy the octave flicks", "Low A, then a jump up after each one.",
                   L.n([(2, 33), (3, 45), (6, 33), (7, 45), (10, 33), (11, 43), (14, 33), (15, 40)]),
                   backing: T.pulse, threshold: 0.9),
            L.bassMake("Make it yours", "A rumble line with at least 10 notes.", backing: T.pulse, notes: 10),
        ])

    static let u2l2: LevelPair = (
        silver: [
            L.silver("where the peak sits",
                     "Low cutoff with high resonance screams in the low mids. Higher cutoff turns the same peak into a bright whistle. Length makes it bite."),
            K.lab("Match the low scream", "Cutoff low, resonance almost full.", [.bassCutoff, .bassResonance], start: [0.6, 0.3], target: [0.2, 0.9],
                  loop: acidLoop),
            K.lab("Match the bright peak", "Cutoff above halfway, medium resonance.", [.bassCutoff, .bassResonance], start: [0.2, 0.9], target: [0.65, 0.6],
                  loop: acidLoop),
            K.lab("Match the short squelch", "Peak plus short notes.", [.bassCutoff, .bassResonance, .bassDecay],
                  start: [0.6, 0.3, 0.7], target: [0.35, 0.8, 0.2], loop: acidLoop),
        ],
        gold: [
            L.gold("four-knob acid",
                   "Envelope makes every note sweep the peak. With decay too, you control the whole 303 character."),
            K.lab("Match the deep acid", "Dark, with lots of envelope and resonance. Short notes.", bass4, start: [0.5, 0.5, 0.5, 0.5], target: [0.15, 0.85, 0.9, 0.3],
                  loop: acidLoop),
            K.lab("Match the rubbery acid", "Everything near the middle, notes a bit longer.", bass4, start: [0.5, 0.5, 0.5, 0.5], target: [0.45, 0.5, 0.6, 0.65],
                  loop: acidLoop),
            K.lab("Make it yours", "Design your own acid sound.", bass4, start: [0.5, 0.5, 0.5, 0.5], loop: acidLoop),
        ])

    static let u2l3: LevelPair = (
        silver: [
            L.silver("accents and length",
                     "Acid lines get their shape from octave jumps and from which notes are held. A held high note sounds like an accent."),
            L.bass("Copy this acid line", "Octave jumps in new places.",
                   L.n([(0, 33), (2, 45), (3, 33), (5, 33), (6, 43), (8, 33), (10, 45), (11, 40), (13, 33), (14, 45)]),
                   backing: T.pulse),
            L.bass("Copy the held accents", "Three notes hold for two steps.",
                   [NoteEvent(0, 33, 2), NoteEvent(3, 45), NoteEvent(4, 33), NoteEvent(6, 40, 2), NoteEvent(9, 43),
                    NoteEvent(10, 33), NoteEvent(12, 45, 2), NoteEvent(15, 36)], backing: T.pulse),
            L.bassMake("Write your own acid line", "At least 10 notes.", backing: T.pulse, notes: 10),
        ],
        gold: [
            L.gold("long acid lines",
                   "Classic acid lines are busy: twelve notes or more, with octave jumps that feel random but repeat every bar."),
            L.bass("Copy the twelve-note line", "Low A with jumps to the top row. Count the high notes.", L.n([(0, 33), (1, 33), (2, 45), (4, 33), (5, 40), (6, 33),
                                                         (8, 43), (9, 33), (10, 45), (12, 33), (13, 38), (14, 45)]),
                   backing: T.pulse, threshold: 0.9),
            K.lab("Match its squelch", "Low cutoff, high resonance and envelope.", [.bassCutoff, .bassResonance, .bassEnv], start: [0.6, 0.2, 0.2],
                  target: [0.25, 0.85, 0.85], loop: acidLoop),
            L.bassMake("Make it yours", "A busy acid line, at least 12 notes.", backing: T.pulse, notes: 12),
        ])

    static let u2l4: LevelPair = (
        silver: [
            L.silver("stages of a filter ride",
                     "A filter ride has stages: closed right down, halfway, and almost open. Learn to hear each one."),
            K.filterMatch("Match: halfway up the build", "Cutoff in the middle, some resonance.", cutoff: 1500, resonance: 0.4, T.full),
            K.filterMatch("Match: closed right down", "Very dark, strong peak.", cutoff: 300, resonance: 0.8, T.full),
            K.filterMatch("Match: almost open", "Bright with a peak.", cutoff: 5000, resonance: 0.6, T.full),
        ],
        gold: [
            L.gold("small filter moves",
                   "In a long build the filter moves slowly. Hear the difference between neighbouring settings."),
            K.filterMatch("Match this setting", "Dark, only a little resonance.", cutoff: 800, resonance: 0.2, T.full),
            K.filterMatch("Match this setting", "Resonance is doing most of the work.", cutoff: 2500, resonance: 0.85, T.full),
            K.filterMatch("Match this setting", "Very dark, medium peak.", cutoff: 400, resonance: 0.5, T.full),
        ])

    static let u2l5: LevelPair = (
        silver: [
            L.silver("new acid sounds",
                     "The same three knobs make very different acid. Describe the sound before you touch anything."),
            K.lab("Match the screaming acid", "Very dark, resonance almost full, medium envelope.", [.bassCutoff, .bassResonance, .bassEnv], start: [0.5, 0.3, 0.3],
                  target: [0.15, 0.9, 0.5], loop: acidLoop),
            K.lab("Match the bright, sweeping acid", "Brighter, with the envelope almost full.", [.bassCutoff, .bassResonance, .bassEnv],
                  start: [0.15, 0.9, 0.5], target: [0.55, 0.6, 0.9], loop: acidLoop),
        ],
        gold: [
            L.gold("full control",
                   "Four knobs at once. Set the cutoff first, then resonance, then envelope and length."),
            K.lab("Match this acid", "Dark and short, envelope and resonance high.", bass4, start: [0.5, 0.5, 0.5, 0.5], target: [0.2, 0.9, 0.85, 0.2], loop: acidLoop),
            K.lab("Match this acid", "Brighter and longer, nothing extreme.", bass4, start: [0.5, 0.5, 0.5, 0.5], target: [0.4, 0.6, 0.7, 0.7], loop: acidLoop),
            K.lab("Make it yours", "Your own acid patch.", bass4, start: [0.5, 0.5, 0.5, 0.5], loop: acidLoop),
        ])

    // MARK: Unit 3 — Hypnotic Loops

    static let u3l1: LevelPair = (
        silver: [
            L.silver("groupings of three",
                     "A pattern every three steps drifts against the four-step kick and lines up again every three beats. Start it in a new place and it sounds new."),
            L.copy("Copy this three-step rim", "Every third step, starting on step 2.", tracks: [.kick, .hat, .perc],
                   edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], perc: [1, 4, 7, 10, 13])),
            L.copy("Copy the three-step open hat", "Starting on step 3 this time.", tracks: [.kick, .openHat, .perc],
                   edit: [.openHat], start: Pattern(kick: [0, 4, 8, 12], perc: [3, 11]),
                   target: Pattern(kick: [0, 4, 8, 12], openHat: [2, 5, 8, 11, 14], perc: [3, 11])),
            L.make("Write your own polyrhythm", "At least 5 rims.", tracks: [.kick, .hat, .perc], edit: [.perc],
                   start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]), goal: .atLeast(.perc, 5)),
        ],
        gold: [
            L.gold("polyrhythm in layers",
                   "Stack a three-step pattern and a five-step pattern over the kick and the loop seems to change every bar."),
            L.copy("Copy the two layers", "Open hats every three steps, rims every five.", tracks: [.kick, .openHat, .perc],
                   edit: [.openHat, .perc], start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], openHat: [0, 3, 6, 9, 12, 15], perc: [2, 7, 12]), threshold: 0.9),
            L.copy("Rebuild the full loop", "Offbeat hats, open hats every three steps, rims every five.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], openHat: [1, 4, 7, 10, 13], perc: [3, 8, 13]),
                   threshold: 0.9),
            L.make("Make it yours", "Layer your own polyrhythms.", tracks: kit, edit: [.openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]), goal: .atLeast(.perc, 5)),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("richer dub chords",
                     "Dub techno often adds a 9th to the minor 7th for an even more open, foggy sound. And the stab rhythm matters as much as the chord."),
            K.build("Build Am9", "A, C, E, G and B.", .am9, low: 55, high: 72),
            K.lane("Copy the late dub stabs", "Every stab arrives a step late.", .recreate, palette: [.am7],
                   backing: T.dubBacking, target: [1: 0, 6: 0, 9: 0, 14: 0], length: 2),
            K.lane("Copy the two-chord dub", "Am7, then Dm7 for one stab.", .recreate, palette: [.am7, .dm7],
                   backing: T.dubBacking, target: [2: 0, 6: 0, 10: 1, 14: 0], length: 2),
        ],
        gold: [
            L.gold("dub progressions",
                   "Even dub techno moves sometimes. Three minor chords, placed off the beat, keep the fog shifting."),
            K.build("Build Dm9", "D, F, A, C and E.", .dm9, low: 55, high: 72),
            K.build("Build Em9", "E, G, B, D and F♯.", .em9, low: 55, high: 72),
            K.lane("Copy the three-chord dub", "Two Am7 stabs, then Dm7, then Em7.", .recreate, palette: [.am7, .dm7, .em7], backing: T.dubBacking,
                   target: [2: 0, 5: 0, 9: 1, 13: 2], length: 2),
            K.lane("Make it yours", "At least five dub stabs.", .create(.chordsAtLeast(5)), palette: [.am7, .dm7, .em7],
                   backing: T.dubBacking, length: 2),
        ])

    static let dubLoop = Pattern(kick: [0, 8], chords: [K.ch(3, .am7, 2), K.ch(10, .am7, 2)])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("the dub chord sound",
                     "Space isn't just reverb. A dark chord with a long tail already sounds far away before any effect."),
            K.lab("Match the dub chord tail", "Dark with a long release.", [.chordCutoff, .chordRelease],
                  start: [0.8, 0.1], target: [0.3, 0.85], loop: dubLoop),
            K.lane("Copy these echoing stabs", "Stabs answer each other across the bar.", .recreate, palette: [.am7],
                   backing: Pattern(kick: [0, 8]), target: [3: 0, 6: 0, 11: 0, 14: 0], length: 2),
            K.lane("Write your own dub stabs", "At least five stabs.", .create(.chordsAtLeast(5)), palette: [.am7, .dm7],
                   backing: T.dubBacking, length: 2),
        ],
        gold: [
            L.gold("foggy chords",
                   "Shape the chord, then push it back with the filter. That's the whole dub techno sound."),
            K.lab("Match the foggy chord", "Dark and short, with a long release.", [.chordCutoff, .chordDecay, .chordRelease], start: [0.7, 0.7, 0.2],
                  target: [0.25, 0.3, 0.9], loop: dubLoop),
            K.filterMatch("Match the dub filter", "Dark with a soft peak.", cutoff: 800, resonance: 0.5, dubLoop),
            K.lane("Make it yours", "At least six stabs.", .create(.chordsAtLeast(6)), palette: [.am7, .dm7, .em7],
                   backing: T.dubBacking, length: 2),
        ])

    static let u3l4: LevelPair = (
        silver: [
            L.silver("every hit matters",
                     "Minimal techno has so few sounds that moving one hit changes everything. Hear exactly where each one lands."),
            L.copy("Copy this minimal groove", "Three hats and two rims. Nothing on the beat.", tracks: [.kick, .hat, .perc], edit: [.hat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12]), target: Pattern(kick: [0, 4, 8, 12], hat: [3, 10, 14], perc: [6, 13])),
            L.copy("Copy this one", "Open hats join in.", tracks: kit, edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [2, 10], openHat: [6, 14], perc: [5, 11])),
            L.make("Make it minimal", "At least three rims, nothing busy.", tracks: [.kick, .hat, .perc],
                   edit: [.hat, .perc], start: Pattern(kick: [0, 4, 8, 12]), goal: .atLeast(.perc, 3)),
        ],
        gold: [
            L.gold("minimal with groove",
                   "Minimal loops groove through tiny details: one moved kick, a touch of swing."),
            L.copy("Rebuild this minimal loop", "Even the kick has a surprise.", tracks: [.kick, .hat, .perc],
                   edit: [.kick, .hat, .perc],
                   target: Pattern(kick: [0, 4, 8, 11, 12], hat: [2, 7, 10, 15], perc: [5, 13]), threshold: 0.9),
            K.swingMake("Swing the minimal loop", "Past 15%.", tracks: [.kick, .hat, .perc],
                        start: Pattern(kick: [0, 4, 8, 12], hat: [2, 7, 10, 15], perc: [5, 13]), atLeast: 0.15),
            L.make("Make it yours", "A minimal loop from silence. At least 3 rims.", tracks: [.kick, .hat, .perc],
                   edit: [.kick, .hat, .perc], goal: .atLeast(.perc, 3)),
        ])

    static let u3l5: LevelPair = (
        silver: [
            L.silver("hearing small changes",
                     "Techno keeps you hooked by changing one thing every few bars. Training your ear to spot the change is a big part of making it."),
            L.copy("Spot the rim change", "Same groove, one more rim.", tracks: kit, edit: [.perc], start: T.groove,
                   target: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 6, 10, 14], perc: [3, 6, 11, 13])),
            L.copy("Spot the open-hat change", "One open hat has moved.", tracks: kit, edit: [.openHat], start: T.groove,
                   target: Pattern(kick: [0, 4, 8, 12], hat: hats16, openHat: [2, 6, 10, 13], perc: [3, 6, 11])),
        ],
        gold: [
            L.gold("two changes at once",
                   "Now two parts change at once. Check each part on its own."),
            L.copy("Spot both changes", "Hats and rims both changed.", tracks: kit, edit: [.hat, .perc], start: T.groove,
                   target: Pattern(kick: [0, 4, 8, 12], hat: [0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14],
                                   openHat: [2, 6, 10, 14], perc: [3, 6, 9, 11]), threshold: 0.9),
            L.copy("Spot the drop-out", "The kick and hats both leave space at the end.", tracks: kit, edit: [.kick, .hat],
                   start: T.groove, target: Pattern(kick: [0, 4, 8], hat: Array(0..<12), openHat: [2, 6, 10, 14],
                                                    perc: [3, 6, 11]), threshold: 0.9),
            L.make("Make it yours", "Write a variation of the groove. At least 4 rims.", tracks: kit, edit: Set(kit),
                   start: T.groove, goal: .atLeast(.perc, 4)),
        ])

    // MARK: Unit 4 — Warehouse Mix

    static let mx = T.mixLoop

    static let u4l1: LevelPair = (
        silver: [
            L.silver("everything under the kick",
                     "In techno the kick sets the level for everything. Each part should sit just under it, at its own height."),
            K.mix("Match: rims forward", "Kick on top, rims louder than the hats.", [.drum(.kick), .drum(.hat), .drum(.perc), .bass],
                  start: [u, u, u, u], target: [0.85, 0.4, 0.6, 0.5], loop: mx),
            K.mix("Match: open hats forward", "Kick on top, open hats just above the bass.", [.drum(.kick), .drum(.openHat), .bass],
                  start: [u, u, u], target: [0.9, 0.55, 0.45], loop: mx),
        ],
        gold: [
            L.gold("five-part balance",
                   "All five parts at once. Set the kick, then add each part until it just sits."),
            K.mix("Match this mix", "Kick first. Rims slightly above the open hats.", mix5, start: [u, u, u, u, u], target: [0.85, 0.4, 0.55, 0.6, 0.5], loop: mx),
            K.mix("Match this mix", "The bass is bigger this time.", mix5, start: [u, u, u, u, u],
                  target: [0.8, 0.6, 0.35, 0.45, 0.7], loop: mx),
            K.mix("Make it yours", "Your own warehouse balance.", mix5, start: [0.2, 0.2, 0.2, 0.2, 0.2], loop: mx),
        ])

    static let u4l2: LevelPair = (
        silver: [
            L.silver("pump depth",
                     "Hard pump makes the rumble breathe. Gentle pump just cleans up the low end. Hear both."),
            K.mix("Match: maximum pump", "Pump almost all the way up.", [.drum(.kick), .bass, .sidechain], start: [u, u, 0],
                  target: [0.8, 0.7, 0.9], loop: mx),
            K.mix("Match: gentle pump", "Light pump, bass in the middle.", [.bass, .sidechain], start: [u, 0.8], target: [0.55, 0.3], loop: mx),
        ],
        gold: [
            L.gold("pump in the full mix",
                   "Pump changes how loud the bass feels, so balance the rest around it."),
            K.mix("Match this mix", "Big kick, heavy pump, hats tucked in.", [.drum(.kick), .drum(.hat), .bass, .sidechain], start: [u, u, u, 0],
                  target: [0.85, 0.45, 0.75, 0.85], loop: mx),
            K.mix("Match this mix", "Lighter pump. Open hats and bass level.", [.drum(.kick), .drum(.openHat), .bass, .sidechain], start: [u, u, u, 0],
                  target: [0.8, 0.6, 0.6, 0.4], loop: mx),
            K.mix("Make it yours", "Set kick, bass and pump your way.", [.drum(.kick), .drum(.hat), .bass, .sidechain],
                  start: [0.2, 0.2, 0.2, 0], loop: mx),
        ])

    static let u4l3: LevelPair = (
        silver: [
            L.silver("top-end layers",
                     "Closed hats, open hats and rims all live up top. Give each its own level so they don't blur."),
            K.mix("Match: open hats lead", "Open hats loudest, closed hats quietest.", [.drum(.hat), .drum(.openHat), .drum(.perc)], start: [u, u, u],
                  target: [0.3, 0.85, 0.5], loop: mx),
            K.mix("Match: hats over rims", "Closed hats well above the rims.", [.drum(.hat), .drum(.perc)], start: [u, u], target: [0.75, 0.35], loop: mx),
        ],
        gold: [
            L.gold("top and bottom",
                   "The top end changes how big the kick feels. Balance them all together."),
            K.mix("Match this mix", "Rims just under the kick, open hats lowest.", [.drum(.kick), .drum(.hat), .drum(.openHat), .drum(.perc)], start: [u, u, u, u],
                  target: [0.8, 0.5, 0.4, 0.7], loop: mx),
            K.mix("Match this mix", "Closed hats bright, open hats low.", mix5, start: [u, u, u, u, u], target: [0.85, 0.65, 0.3, 0.45, 0.6], loop: mx),
            K.mix("Make it yours", "Start with the kick, then fit the rest under it.", mix5, start: [0.2, 0.2, 0.2, 0.2, 0.2], loop: mx),
        ])

    static let u4l4: LevelPair = (
        silver: [
            L.silver("deep in the warehouse",
                     "Darker and quieter means further away. Push the top end back and the room gets bigger."),
            K.filterMatch("Match: back of the room", "Dark with a soft peak.", cutoff: 600, resonance: 0.45, mx),
            K.mix("Push the top end back", "Pull all three well down.", [.drum(.hat), .drum(.openHat), .drum(.perc)], start: [u, u, u],
                  target: [0.35, 0.4, 0.3], loop: mx),
            K.filterMatch("Match: just behind the speakers", "Only a little top end gone.", cutoff: 2500, resonance: 0.1, mx),
        ],
        gold: [
            L.gold("depth in a full mix",
                   "Kick and bass up front, rims in the middle, hats at the back. Then filter the whole thing."),
            K.mix("Match this depth", "Kick and bass close, hats and rims far back.", mix5, start: [u, u, u, u, u], target: [0.85, 0.3, 0.5, 0.25, 0.65], loop: mx),
            K.filterMatch("Match: dark and resonant", "Very dark with a strong peak.", cutoff: 450, resonance: 0.7, mx),
            K.mix("Make it yours", "Decide what sits close and what sits far.", mix5, start: [0.2, 0.2, 0.2, 0.2, 0.2], loop: mx),
        ])

    static let u4l5: LevelPair = (
        silver: [
            L.silver("new mixes by ear",
                     "Listen part by part and fix the biggest difference first."),
            K.mix("Match this mix", "Kick, then bass, then open hats, then rims.", [.drum(.kick), .drum(.openHat), .drum(.perc), .bass], start: [u, u, u, u],
                  target: [0.8, 0.6, 0.5, 0.7], loop: mx),
            K.mix("Match this mix", "Rims lead the top end. Gentle pump.", [.drum(.hat), .drum(.perc), .bass, .sidechain], start: [u, u, u, 0],
                  target: [0.5, 0.8, 0.6, 0.4], loop: mx),
        ],
        gold: [
            L.gold("full mixes by ear", "Five controls, no hints."),
            K.mix("Match this mix", "", [.drum(.kick), .drum(.hat), .drum(.perc), .bass, .sidechain],
                  start: [u, u, u, u, 0], target: [0.85, 0.35, 0.65, 0.7, 0.8], loop: mx),
            K.mix("Match this mix", "", [.drum(.kick), .drum(.hat), .drum(.openHat), .bass, .sidechain],
                  start: [u, u, u, u, 0], target: [0.75, 0.6, 0.5, 0.55, 0.3], loop: mx),
            K.mix("Make it yours", "", [.drum(.kick), .drum(.hat), .drum(.perc), .bass, .sidechain],
                  start: [0.2, 0.2, 0.2, 0.2, 0], loop: mx),
        ])

    // MARK: Unit 5 — Long Builds

    static let secs = T.sections
    static let lanes = T.lanes

    static func arr(_ prompt: String, _ hint: String, _ mode: TaskMode, sections: [String] = secs,
                    start: [[Bool]] = [], target: [[Bool]] = []) -> LessonStep {
        K.arrange(prompt, hint, mode, sections: sections, lanes: lanes, loop: T.full, start: start, target: target)
    }

    static let allOn = K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx")

    static let u5l1: LevelPair = (
        silver: [
            L.silver("tension by taking away",
                     "Techno builds tension by removing parts, not adding them. A break with only hats and rims makes the slam hit harder."),
            arr("Break: keep only hats and rims", "Switch off the kick, open hats and bass in the Break.", .rule,
                start: allOn, target: K.grid("xx-x", "xxxx", "xx-x", "xxxx", "xx-x")),
            arr("Copy this track", "The Intro is kick and rims. Open hats wait for the Break.", .recreate, target: K.grid("xx-x", "-xxx", "--xx", "x-xx", "-x-x")),
        ],
        gold: [
            L.gold("whole tracks by ear", "Hear it through once, then check one part at a time."),
            arr("Recreate this track", "The bass waits until the Break.", .recreate, target: K.grid("xx-x", "-xxx", "-x-x", "xx-x", "--xx")),
            arr("Recreate this track", "The kick sits out the Groove.", .recreate, target: K.grid("x-xx", "xx-x", "--xx", "-xxx", "-x-x")),
            arr("Make it yours", "Five sections this time.", .create(.variedSections),
                sections: ["Intro", "Groove", "Break", "Slam", "Outro"]),
        ])

    static let u5l2: LevelPair = (
        silver: [
            L.silver("intros for the mix",
                     "Techno intros give the DJ room to blend: kick and percussion first, everything else later."),
            arr("Intro: kick and rims only", "Switch off the hats, open hats and bass in the Intro.", .rule,
                start: allOn, target: K.grid("xxxx", "-xxx", "-xxx", "xxxx", "-xxx")),
            arr("Copy this intro", "Kick and rims open it. Hats arrive in the Groove.", .recreate, target: K.grid("xx-x", "-xxx", "--xx", "x-xx", "--xx")),
        ],
        gold: [
            L.gold("double-length intros",
                   "Many techno tracks take two sections to get going. Each one adds a single part."),
            arr("Recreate this intro", "One new part arrives in each section.", .recreate, sections: ["Intro", "Intro 2", "Groove", "Slam"],
                target: K.grid("xxxx", "-xxx", "--xx", "-x-x", "--xx")),
            arr("Recreate this one", "Hats open the track on their own.", .recreate, sections: ["Intro", "Intro 2", "Groove", "Slam"],
                target: K.grid("x-xx", "xxxx", "--xx", "-xxx", "--xx")),
            arr("Make it yours", "Bring parts in one at a time.", .create(.variedSections), sections: ["Intro", "Intro 2", "Groove", "Slam"]),
        ])

    static let u5l3: LevelPair = (
        silver: [
            L.silver("what rumbles on",
                     "Keep the bass in the break and the tension stays in your chest. Take it out and the room floats."),
            arr("Copy this breakdown", "Hats and rims keep going through the Break.", .recreate, target: K.grid("xx-x", "xxxx", "xx-x", "-xxx", "-x-x")),
            arr("Keep the bass rumbling in the Break", "Switch the bass on in the Break.", .rule,
                start: K.grid("xx-x", "xxxx", "-x-x", "xxxx", "-x-x"),
                target: K.grid("xx-x", "xxxx", "-x-x", "xxxx", "-xxx")),
        ],
        gold: [
            L.gold("break and build",
                   "A break is followed by a build that brings parts back one at a time."),
            arr("Recreate this", "The Build is rims alone.", .recreate, sections: ["Groove", "Break", "Build", "Slam"],
                target: K.grid("x--x", "xx-x", "x--x", "xxxx", "x--x")),
            arr("Recreate this", "The kick returns in the Build. The bass waits for the Slam.", .recreate, sections: ["Groove", "Break", "Build", "Slam"],
                target: K.grid("x-xx", "--xx", "x-xx", "-xxx", "x--x")),
            arr("Make it yours", "Make the Break emptier than the Build.", .create(.variedSections), sections: ["Groove", "Break", "Build", "Slam"]),
        ])

    static let u5l4: LevelPair = (
        silver: [
            L.silver("silence before the slam",
                     "The emptier the break, the bigger the slam. Leave only one part playing."),
            arr("Break: only rims", "Switch everything off in the Break except the rims.", .rule, start: allOn,
                target: K.grid("xx-x", "xx-x", "xx-x", "xxxx", "xx-x")),
            arr("Copy this slam", "The Break is rims only.", .recreate, target: K.grid("-x-x", "xx-x", "x--x", "-xxx", "-x-x")),
        ],
        gold: [
            L.gold("slam and outro",
                   "After the slam, the outro strips back down for the next DJ."),
            arr("Recreate this", "In the Outro only the kick and hats stay.", .recreate, sections: ["Groove", "Break", "Slam", "Outro"],
                target: K.grid("x-xx", "xxxx", "x-x-", "xxx-", "x-x-")),
            arr("Recreate this", "Open hats save themselves for the Slam.", .recreate, sections: ["Groove", "Break", "Slam", "Outro"],
                target: K.grid("x-xx", "xxx-", "--x-", "x-xx", "x-x-")),
            arr("Make it yours", "Strip the Outro back so a DJ can mix out.", .create(.variedSections), sections: ["Groove", "Break", "Slam", "Outro"]),
        ])

    static let u5l5: LevelPair = (
        silver: [
            L.silver("fill shapes",
                     "Techno fills are rolls of rims, kicks or hats. They get faster toward the slam."),
            L.copy("Copy the rim roll", "It starts earlier this time.", tracks: [.kick, .hat, .perc], edit: [.perc],
                   start: Pattern(kick: [0, 4, 8], hat: Array(0..<12)),
                   target: Pattern(kick: [0, 4, 8], hat: Array(0..<12), perc: [10, 12, 13, 14, 15])),
            L.copy("Copy the kick roll", "The kick speeds up through the last beat.", tracks: [.kick, .hat], edit: [.kick],
                   start: Pattern(hat: Array(0..<12)), target: Pattern(kick: [0, 4, 8, 12, 13, 14, 15], hat: Array(0..<12))),
            L.make("Write a rim roll", "At least 5 rims.", tracks: [.kick, .hat, .perc], edit: [.perc],
                   start: Pattern(kick: [0, 4, 8], hat: Array(0..<12)), goal: .atLeast(.perc, 5)),
        ],
        gold: [
            L.gold("full-kit fills", "Every part changes for the fill. Rebuild them one at a time."),
            L.copy("Rebuild this fill", "Eighth-note hats, then a rim roll and one open hat.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 10], hat: [0, 2, 4, 6, 8, 10], openHat: [12], perc: [11, 12, 13, 14, 15]),
                   threshold: 0.9),
            L.copy("Copy the stop", "Everything stops except one rim at the very end.", tracks: [.kick, .hat, .perc],
                   edit: [.kick, .hat, .perc], target: Pattern(kick: [0, 4, 8], hat: Array(0..<12), perc: [15]),
                   threshold: 0.9),
            L.make("Make it yours", "A full-kit fill. At least 6 rims.", tracks: kit, edit: Set(kit),
                   goal: .atLeast(.perc, 6)),
        ])
}
