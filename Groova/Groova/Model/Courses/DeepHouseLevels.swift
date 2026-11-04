//
//  DeepHouseLevels.swift
//  Groova
//
//  Hand-written Silver and Gold levels for the Deep House course.
//

import Foundation

nonisolated enum DeepHouseLevels {
    typealias D = DeepHouseCourse
    static let u = K.u
    static let rows = D.rows
    static let kit: [DrumTrack] = [.kick, .clap, .hat, .openHat, .perc]
    static let offHats = [2, 6, 10, 14]
    static let base = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])
    static let cm9 = ChordShape(name: "Cm9", pitches: [55, 58, 60, 62, 63])
    static let kickLoop = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])

    static func bass(_ prompt: String, _ hint: String, _ notes: [NoteEvent], backing: Pattern = D.drums,
                     threshold: Double = 0.85) -> LessonStep {
        L.bass(prompt, hint, notes, backing: backing, rows: rows, threshold: threshold)
    }

    static func bassMake(_ prompt: String, _ hint: String, backing: Pattern = D.drums, notes: Int) -> LessonStep {
        L.bassMake(prompt, hint, backing: backing, notes: notes, rows: rows)
    }

    static func pads(_ chords: [(Int, ChordShape, Int)]) -> Pattern {
        Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [7, 15],
                chords: chords.map { K.ch($0.0, $0.1, $0.2) })
    }

    static let all: [String: LevelPair] = [
        "deep.u1.l1": u1l1, "deep.u1.l2": u1l2, "deep.u1.l3": u1l3, "deep.u1.l4": u1l4, "deep.u1.l5": u1l5,
        "deep.u2.l1": u2l1, "deep.u2.l2": u2l2, "deep.u2.l3": u2l3, "deep.u2.l4": u2l4, "deep.u2.l5": u2l5,
        "deep.u3.l1": u3l1, "deep.u3.l2": u3l2, "deep.u3.l3": u3l3, "deep.u3.l4": u3l4, "deep.u3.l5": u3l5,
        "deep.u4.l1": u4l1, "deep.u4.l2": u4l2, "deep.u4.l3": u4l3, "deep.u4.l4": u4l4, "deep.u4.l5": u4l5,
    ]

    // MARK: Unit 1 — Late Night Grooves

    static let u1l1: LevelPair = (
        silver: [
            L.silver("kick length and weight",
                     "A deep kick is low and round, but how long it rings decides how heavy the groove feels. Short sits back, long fills the room."),
            K.lab("Match the short, soft kick", "Low pitch, short tail, no drive.", [.kickPitch, .kickDecay, .kickDrive],
                  start: [0.6, 0.8, 0.5], target: [0.15, 0.25, 0.0], loop: kickLoop),
            K.lab("Match the long, warm kick", "Still low, but it rings out.", [.kickPitch, .kickDecay],
                  start: [0.7, 0.1], target: [0.1, 0.7], loop: base),
            L.copy("Copy this kick with a pickup", "Four on the floor plus one soft extra kick.", tracks: [.kick, .hat],
                   edit: [.kick], start: Pattern(hat: offHats), target: Pattern(kick: [0, 4, 8, 11, 12], hat: offHats)),
        ],
        gold: [
            L.gold("the kick in the whole groove",
                   "The kick sound only makes sense next to everything else. Shape it under the full loop, then build a groove around it."),
            K.lab("Match this kick in the full loop", "Listen under the bass and chords.", [.kickPitch, .kickDecay, .kickDrive],
                  start: [0.8, 0.1, 0.6], target: [0.2, 0.5, 0.1], loop: D.full),
            L.copy("Rebuild this groove", "Two rims: one just before the first clap, one at the very end.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [3, 15]),
                   threshold: 0.9),
            L.make("Make it yours", "A soft groove from silence. At least 4 kicks.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], goal: .atLeast(.kick, 4)),
        ])

    static let u1l2: LevelPair = (
        silver: [
            L.silver("rims that talk",
                     "Rims are the conversation in a deep groove. A rim just before the clap leans in. One just after answers back."),
            L.copy("Copy the leaning rims", "Each rim sits right before a clap.", tracks: [.kick, .clap, .perc], edit: [.perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 11])),
            L.copy("Copy the answering rims", "Rims right after the claps, plus one at the end.", tracks: [.kick, .clap, .perc],
                   edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [5, 13, 15])),
            L.make("Write your own rims", "At least 3.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: base,
                   goal: .atLeast(.perc, 3)),
        ],
        gold: [
            L.gold("rims instead of claps",
                   "Lots of deep house drops the clap altogether and lets the rims carry the backbeat. Rebuild grooves with no clap at all."),
            L.copy("Copy this clapless groove", "Rims do all the work.", tracks: [.kick, .hat, .perc], edit: [.perc],
                   start: kickLoop, target: Pattern(kick: [0, 4, 8, 12], hat: offHats, perc: [4, 7, 10, 12, 15]),
                   threshold: 0.9),
            L.copy("Rebuild rims and hats", "Offbeat hats plus one extra. Rims carry beats 2 and 4.", tracks: [.kick, .hat, .perc], edit: [.hat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 13, 14], perc: [3, 4, 9, 12]), threshold: 0.9),
            L.make("Make it yours", "No clap. At least 5 rims.", tracks: [.kick, .hat, .perc], edit: [.hat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12]), goal: .atLeast(.perc, 5)),
        ])

    static let u1l3: LevelPair = (
        silver: [
            L.silver("how much swing",
                     "Deep house swing is a feel, not an effect. A little sounds relaxed. Too much sounds like garage. Find the sweet spot."),
            K.swingMake("Swing the rims too", "Rims and hats on 16ths. Past 18%.", tracks: [.kick, .hat, .perc],
                        start: Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], perc: [3, 7, 11, 15]),
                        atLeast: 0.18),
            L.copy("Copy these lazy hats", "Only the in-between 16ths, with a gap.", tracks: [.kick, .hat], edit: [.hat],
                   start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 13, 15])),
        ],
        gold: [
            L.gold("swing and space",
                   "Swing only shows up on the notes between the beats. Write those notes, then set the swing so they lean back."),
            L.copy("Rebuild this swung groove", "Hats in pairs around each offbeat, plus three rims.", tracks: [.kick, .clap, .hat, .perc], edit: [.hat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 2, 5, 6, 9, 10, 13, 14], perc: [3, 11, 15]),
                   threshold: 0.9),
            K.swingMake("Lean it back", "Past 22%, but keep it deep.", tracks: [.kick, .clap, .hat, .perc],
                        start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 2, 5, 6, 9, 10, 13, 14], perc: [3, 11, 15]),
                        atLeast: 0.22),
            L.make("Make it yours", "At least 8 hats.", tracks: [.kick, .clap, .hat, .perc], edit: [.hat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 8)),
        ])

    static let u1l4: LevelPair = (
        silver: [
            L.silver("open hats that breathe",
                     "An open hat rings, so it takes up more room than a closed one. Move it and the whole groove breathes differently."),
            L.copy("Copy this hat groove", "Open hats on only two offbeats.", tracks: [.kick, .hat, .openHat],
                   edit: [.hat, .openHat], start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [1, 2, 5, 9, 10, 13], openHat: [6, 14])),
            L.copy("Copy the late open hat", "The last open hat moves to the very end.", tracks: [.kick, .hat, .openHat],
                   edit: [.hat, .openHat], start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 11, 13], openHat: [2, 6, 10, 15])),
        ],
        gold: [
            L.gold("hats with the whole kit",
                   "Hats, open hats and rims all fill the same gaps. Rebuild all three so they never step on each other."),
            L.copy("Rebuild the top end", "Closed hats just after each beat, two open hats, three rims.", tracks: kit, edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 10], perc: [7, 14, 15]),
                   threshold: 0.9),
            L.copy("Rebuild the whole kit", "Open hats on every offbeat. Closed hats around beats 1 and 3.", tracks: kit, edit: Set(kit),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 9, 11], openHat: [2, 6, 10, 14], perc: [7, 15]),
                   threshold: 0.9),
            L.make("Make it yours", "Use both hats. At least 6 closed hats.", tracks: kit, edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 6)),
        ])

    static let u1l5: LevelPair = (
        silver: [
            L.silver("basslines that drift",
                     "Deep basslines hold long notes and drift between F, A♭ and E♭. Long notes on the offbeat make it sound lazy."),
            bass("Copy this drifting line", "F, then up to A♭, then down to E♭.",
                 [NoteEvent(3, 41, 3), NoteEvent(7, 44, 2), NoteEvent(11, 39, 3)]),
            bass("Copy this one", "It dips down to low C at the end.",
                 [NoteEvent(2, 41, 2), NoteEvent(6, 41), NoteEvent(10, 44, 2), NoteEvent(14, 36, 2)]),
            bassMake("Write your own", "At least 4 notes, some of them long.", notes: 4),
        ],
        gold: [
            L.gold("bass under chords",
                   "Under Fm9 the bass wants F. Under D♭maj7 it can drop to low C or sit on A♭. Follow the chords."),
            bass("Copy this bassline", "F under Fm9, low C under D♭maj7, then back up to F.", [NoteEvent(3, 41, 2), NoteEvent(6, 48), NoteEvent(7, 44), NoteEvent(11, 36, 2),
                                            NoteEvent(14, 39), NoteEvent(15, 41)],
                 backing: pads([(0, .fm9, 6), (8, .dbmaj7, 6)]), threshold: 0.9),
            bass("Copy this one", "It climbs from F to B♭, then drops to low C.", [NoteEvent(0, 41), NoteEvent(3, 44, 2), NoteEvent(7, 46), NoteEvent(8, 36, 3),
                                       NoteEvent(12, 39), NoteEvent(14, 41, 2)],
                 backing: pads([(0, .fm9, 6), (8, .dbmaj7, 6)]), threshold: 0.9),
            bassMake("Make it yours", "At least 6 notes under the chords.",
                     backing: pads([(0, .fm9, 6), (8, .dbmaj7, 6)]), notes: 6),
        ])

    // MARK: Unit 2 — Jazzy Chords

    static let u2l1: LevelPair = (
        silver: [
            L.silver("major 7ths on new roots",
                     "A major 7th is a major chord plus the note a half step under the octave. The shape works from any root."),
            K.build("Build E♭maj7: E♭, G, B♭ and D", "Any octave and any order works.", .ebmaj7, low: 53, high: 67),
            K.build("Build D♭maj7: D♭, F, A♭ and C", "Same shape, new root. Any order works.", .dbmaj7,
                    low: 53, high: 67),
            K.quiz("Major 7th or minor 7th?", "Warm or moody?", [
                K.round([.ebmaj7], ["Major 7th", "Minor 7th"], 0), K.round([.gm7], ["Major 7th", "Minor 7th"], 1),
                K.round([.bbm7], ["Major 7th", "Minor 7th"], 1), K.round([.cmaj7], ["Major 7th", "Minor 7th"], 0),
            ]),
        ],
        gold: [
            L.gold("sevenths in context",
                   "Real tracks move between major and minor 7ths. Hear which is which as they change, then play them yourself."),
            K.quiz("Is the second chord major or minor?", "Major 7ths sound warm. Minor 7ths sound moody.", [
                K.round([.fm7, .dbmaj7], ["Major 7th", "Minor 7th"], 0), K.round([.ebmaj7, .cm7], ["Major 7th", "Minor 7th"], 1),
                K.round([.dbmaj7, .bbm7], ["Major 7th", "Minor 7th"], 1), K.round([.gm7, .ebmaj7], ["Major 7th", "Minor 7th"], 0),
            ]),
            K.build("Build Cm7: C, E♭, G and B♭", "Voiced from G up: G, B♭, C, E♭.", .cm7, low: 53, high: 67),
            K.lane("Copy this loop", "A minor 7th, then a major 7th.", .recreate, palette: [.cm7, .ebmaj7], backing: D.drums,
                   target: [0: 0, 8: 1], length: 6),
        ])

    static let u2l2: LevelPair = (
        silver: [
            L.silver("minor 7ths everywhere",
                     "The same minor 7th shape gives you Fm7, Gm7, B♭m7 and Cm7. Learn the shape and you can play them all."),
            K.build("Build Gm7: G, B♭, D and F", "Same shape as Fm7, one step up.", .gm7, low: 53, high: 67),
            K.build("Build B♭m7: B♭, D♭, F and A♭", "Voiced from F up: F, A♭, B♭, D♭.", .bbm7, low: 53, high: 67),
        ],
        gold: [
            L.gold("ninths by ear",
                   "A ninth adds one note on top, and it is the note that makes deep house sound deep. Build it, then hear it."),
            K.build("Build Cm9: C, E♭, G, B♭ and D", "Cm7 plus D on top. Any order works.", cm9, low: 53, high: 67),
            K.quiz("Seventh or ninth?", "The ninth sounds richer and more open.", [
                K.round([.fm9], ["Minor 7th", "Minor 9th"], 1), K.round([.fm7], ["Minor 7th", "Minor 9th"], 0),
                K.round([cm9], ["Minor 7th", "Minor 9th"], 1), K.round([.gm7], ["Minor 7th", "Minor 9th"], 0),
            ]),
            K.lane("Copy this loop", "Ninth, then two sevenths.", .recreate, palette: [.fm9, .bbm7, .cm7], backing: D.drums,
                   target: [0: 0, 6: 1, 10: 2], length: 4),
        ])

    static let u2l3: LevelPair = (
        silver: [
            L.silver("chord colours in pairs",
                     "Now the colours change. Listen to the second chord in each pair."),
            K.quiz("What colour is the second chord?", "Warm is a major 7th, moody a minor 7th, rich and open a minor 9th.", [
                K.round([.fm9, .dbmaj7], ["Major 7th", "Minor 7th", "Minor 9th"], 0),
                K.round([.dbmaj7, .fm9], ["Major 7th", "Minor 7th", "Minor 9th"], 2),
                K.round([.ebmaj7, .cm7], ["Major 7th", "Minor 7th", "Minor 9th"], 1),
                K.round([.bbm7, .am9], ["Major 7th", "Minor 7th", "Minor 9th"], 2),
            ]),
        ],
        gold: [
            L.gold("colours in a progression",
                   "Follow three chords and name the one that changes the mood."),
            K.quiz("Which chord is the major 7th?", "Listen for the warmest one.", [
                K.round([.fm9, .dbmaj7, .bbm7], ["First", "Second", "Third"], 1),
                K.round([.ebmaj7, .cm7, .fm9], ["First", "Second", "Third"], 0),
                K.round([.gm7, .cm7, .dbmaj7], ["First", "Second", "Third"], 2),
            ]),
            K.lane("Recreate what you heard", "Fm9, D♭maj7, B♭m7.", .recreate, palette: [.fm9, .dbmaj7, .bbm7],
                   backing: D.drums, target: [0: 0, 6: 1, 12: 2], length: 4),
        ])

    static let u2l4: LevelPair = (
        silver: [
            L.silver("chord length",
                     "How long a chord rings is half its feel. Long chords float. Short stabs bounce. Hear both on the same rhythm."),
            K.lane("Hold Fm9 from steps 3 and 11", "Late starts, but each chord still rings for six steps.", .rule,
                   palette: [.fm9], backing: D.drums, target: [2: 0, 10: 0], length: 6),
            K.lane("Copy these late chords", "Each one lands just after the beat.", .recreate, palette: [.fm9],
                   backing: D.drums, target: [1: 0, 6: 0, 9: 0, 14: 0], length: 2),
        ],
        gold: [
            L.gold("rhythm and changes together",
                   "Pro tracks change chord and rhythm at the same time. Copy both."),
            K.lane("Copy this loop", "Two Fm9 in the first half, three D♭maj7 in the second.", .recreate, palette: [.fm9, .dbmaj7], backing: D.drums,
                   target: [0: 0, 3: 0, 8: 1, 11: 1, 14: 1], length: 2),
            K.lane("Copy this one", "Fm9, E♭maj7, then Cm7 twice.", .recreate, palette: [.fm9, .ebmaj7, .cm7], backing: D.drums,
                   target: [2: 0, 7: 1, 10: 2, 15: 2], length: 3),
            K.lane("Make it yours", "At least 4 chords. Mix long and short.", .create(.chordsAtLeast(4)),
                   palette: [.fm9, .dbmaj7, .ebmaj7, .cm7], backing: D.drums, length: 3),
        ])

    static let u2l5: LevelPair = (
        silver: [
            L.silver("new progressions",
                     "Fm9 to D♭maj7 is the classic. Swap in B♭m7 or Cm7 and the loop goes somewhere else."),
            K.lane("Switch to B♭m7 for the second half", "Change the chords on steps 9 and 13.", .rule,
                   palette: [.fm9, .bbm7], backing: D.drums, start: [0: 0, 4: 0, 8: 0, 12: 0],
                   target: [0: 0, 4: 0, 8: 1, 12: 1], length: 4),
            K.lane("Copy this progression", "Fm9, Cm7, then D♭maj7 holding to the end.", .recreate, palette: [.fm9, .cm7, .dbmaj7], backing: D.drums,
                   target: [0: 0, 4: 1, 8: 2], length: 4),
        ],
        gold: [
            L.gold("four-chord progressions",
                   "Deep house loves four slow chords. Hear them, rebuild them, then write your own."),
            K.lane("Copy this progression", "One chord per beat. The middle two are major 7ths.", .recreate, palette: [.fm9, .dbmaj7, .ebmaj7, .cm7], backing: D.drums,
                   target: [0: 0, 4: 1, 8: 2, 12: 3], length: 4),
            K.lane("Copy this one", "Short chords, placed unevenly. The bright ones come last.", .recreate, palette: [.fm9, .bbm7, .dbmaj7, .ebmaj7], backing: D.drums,
                   target: [0: 0, 6: 1, 8: 2, 14: 3], length: 2),
            K.lane("Make it yours", "At least 4 chords.", .create(.chordsAtLeast(4)),
                   palette: [.fm9, .bbm7, .cm7, .dbmaj7, .ebmaj7], backing: D.drums, length: 4),
        ])

    // MARK: Unit 3 — Warm Sounds

    static let u3l1: LevelPair = (
        silver: [
            L.silver("pad envelopes",
                     "Attack is how slowly a chord fades in. Release is how long it hangs after. Together they decide if a pad swells or plucks."),
            K.lab("Match the swelling pad", "Slow in, quick out.", [.chordAttack, .chordRelease], start: [0.0, 0.8],
                  target: [0.8, 0.2], loop: D.padLoop),
            K.lab("Match the soft pluck", "Quick in, long hang.", [.chordAttack, .chordRelease], start: [0.9, 0.1],
                  target: [0.05, 0.75], loop: D.padLoop),
        ],
        gold: [
            L.gold("the full pad sound",
                   "Attack, release, length and brightness all shape the pad. Match all four."),
            K.lab("Match this pad", "Slow in, long, and darkish.", [.chordAttack, .chordRelease, .chordDecay, .chordCutoff], start: [0.0, 0.0, 0.1, 0.9],
                  target: [0.6, 0.7, 0.8, 0.35], loop: D.padLoop),
            K.lab("Match this one", "Quick in, short, and brighter.", [.chordAttack, .chordRelease, .chordDecay, .chordCutoff], start: [0.8, 0.8, 0.8, 0.2],
                  target: [0.15, 0.4, 0.35, 0.6], loop: D.full),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("bass length and resonance",
                     "A round bass can still be shaped. Length decides if it hums or bounces. A little resonance adds a soft whistle."),
            K.lab("Match the humming bass", "Long notes, dark tone.", [.bassCutoff, .bassDecay], start: [0.8, 0.1],
                  target: [0.2, 0.7], loop: Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: D.bassline)),
            K.lab("Match the whistly bass", "A touch of resonance.", [.bassCutoff, .bassResonance], start: [0.8, 0.0],
                  target: [0.35, 0.45], loop: Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: D.bassline)),
        ],
        gold: [
            L.gold("bass in the mix",
                   "Match four bass controls with the whole track playing."),
            K.lab("Match this bass", "Dark and long, a hint of resonance.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay], start: [0.8, 0.8, 0.0, 0.1],
                  target: [0.25, 0.2, 0.3, 0.65], loop: D.full),
            K.lab("Match this one", "Brighter and shorter, with some bite.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay], start: [0.1, 0.0, 0.8, 0.8],
                  target: [0.45, 0.55, 0.15, 0.3], loop: D.full),
        ])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("resonant filters",
                     "Resonance boosts the frequencies right at the cutoff. A dark filter with resonance sounds hollow and moody."),
            K.filterMatch("Match the hollow sound", "Dark, with lots of resonance.", cutoff: 500, resonance: 0.7, D.full),
            K.filterMatch("Match the half-open sound", "Brighter, no resonance.", cutoff: 2200, resonance: 0.0, D.full),
        ],
        gold: [
            L.gold("filters on different parts",
                   "A filter on the whole mix is a DJ move. A filter on just the chords or just the bass is a production move."),
            K.filterMatch("Match this filter", "About halfway closed, medium resonance.", cutoff: 1100, resonance: 0.5, D.full),
            K.lab("Match the chord brightness", "A little darker than halfway.", [.chordCutoff], start: [0.9], target: [0.4], loop: D.full),
            K.lab("Match the bass brightness", "Very dark.", [.bassCutoff], start: [0.9], target: [0.15], loop: D.full),
        ])

    static let u3l4: LevelPair = (
        silver: [
            L.silver("space for long chords",
                     "Long chords need less reverb than short ones, because they already fill the room. Try space on held pads."),
            K.space("Give the held pads space", "Find a room that does not blur them.",
                    pads([(0, .fm9, 8), (8, .dbmaj7, 8)])),
            K.lab("Match the dark, slow pad", "Darker, and fading in slowly.", [.chordCutoff, .chordAttack], start: [0.9, 0.0], target: [0.3, 0.55],
                  loop: D.padLoop),
        ],
        gold: [
            L.gold("depth front to back",
                   "Dark, quiet, slow sounds sit at the back. Bright, loud, fast ones sit at the front. Push the pad back."),
            K.lab("Push the pad back", "Dark, slow in, long release.", [.chordCutoff, .chordAttack, .chordRelease], start: [0.9, 0.0, 0.1],
                  target: [0.25, 0.5, 0.8], loop: D.full),
            K.mix("Match the depth", "Chords back, bass and kick forward.", [.drum(.kick), .bass, .chords],
                  start: [u, u, u], target: [0.8, 0.75, 0.45], loop: D.full),
            K.space("Give it a room", "Big enough for the pads, not so big the kick blurs.", D.full),
        ])

    static let u3l5: LevelPair = (
        silver: [
            L.silver("dub stab rhythms",
                     "Dub stabs work because of the gaps. Place each stab so its echo fills the space before the next one."),
            K.lane("Copy these dub stabs", "Short stabs with long gaps.", .recreate, palette: [.fm9], backing: D.drums,
                   target: [3: 0, 9: 0, 14: 0], length: 1),
            K.space("Make them echo", "Try a long space and listen to the gaps fill.", Pattern(kick: [0, 4, 8, 12], hat: offHats,
                                               chords: [K.ch(3, .fm9, 1), K.ch(9, .fm9, 1), K.ch(14, .fm9, 1)])),
        ],
        gold: [
            L.gold("dub stab changes",
                   "Change the chord on the stabs and the echo carries one chord into the next."),
            K.lane("Copy these stabs", "Fm9 twice, then B♭m7 twice.", .recreate, palette: [.fm9, .bbm7], backing: D.drums,
                   target: [3: 0, 6: 0, 11: 1, 14: 1], length: 1),
            K.lane("Copy this one", "It starts and ends on Fm9.", .recreate, palette: [.fm9, .cm7, .ebmaj7], backing: D.drums,
                   target: [2: 0, 7: 1, 10: 2, 13: 0], length: 1),
            K.lane("Make it yours", "At least 4 stabs.", .create(.chordsAtLeast(4)),
                   palette: [.fm9, .bbm7, .cm7, .ebmaj7], backing: D.drums),
        ])

    // MARK: Unit 4 — Deep Mix & Arrangement

    static let mixC: [MixChannel] = [.drum(.kick), .drum(.hat), .drum(.perc), .bass, .chords]

    static let u4l1: LevelPair = (
        silver: [
            L.silver("which part leads",
                     "In deep house the chords usually lead and the drums sit back. Hear two balances of the same loop."),
            K.mix("Match: chords lead", "Chords well above the drums. Hats lowest.", [.drum(.kick), .drum(.hat), .chords], start: [u, u, u],
                  target: [0.55, 0.35, 0.85], loop: D.full),
            K.mix("Match: bass leads", "Bass on top, chords tucked under the kick.", [.drum(.kick), .bass, .chords], start: [u, u, u], target: [0.6, 0.85, 0.5],
                  loop: D.full),
        ],
        gold: [
            L.gold("five-part balance", "Kick first, then bass, then chords, then the small parts."),
            K.mix("Match this mix", "Chords lead, bass next. Hats and rims low.", mixC, start: [u, u, u, u, u], target: [0.65, 0.4, 0.35, 0.7, 0.8], loop: D.full),
            K.mix("Match this one", "Bass leads. Hats and chords close together.", mixC, start: [u, u, u, u, u], target: [0.7, 0.55, 0.5, 0.8, 0.55], loop: D.full),
            K.mix("Make it yours", "Decide what leads: the bass or the chords.", mixC, start: [0.2, 0.2, 0.2, 0.2, 0.2], loop: D.full),
        ])

    static let u4l2: LevelPair = (
        silver: [
            L.silver("pump on the chords",
                     "In deep house the pump is felt most on held chords. Too much and the pads wobble. Just enough and they breathe."),
            K.mix("Match: barely breathing", "Pump almost off.", [.sidechain], start: [0.9], target: [0.15],
                  loop: pads([(0, .fm9, 8), (8, .dbmaj7, 8)])),
            K.mix("Match chords and pump", "Chords loud, light pump.", [.chords, .sidechain], start: [u, 0], target: [0.85, 0.4],
                  loop: pads([(0, .fm9, 8), (8, .dbmaj7, 8)])),
        ],
        gold: [
            L.gold("pump and balance", "Set the pump, then rebalance around it."),
            K.mix("Match this mix", "Chords lead, light pump.", [.drum(.kick), .bass, .chords, .sidechain], start: [u, u, u, 0],
                  target: [0.7, 0.65, 0.8, 0.25], loop: D.full),
            K.mix("Match this one", "Bass leads, hats low, medium pump.", [.drum(.kick), .drum(.hat), .bass, .chords, .sidechain], start: [u, u, u, u, 0],
                  target: [0.6, 0.35, 0.8, 0.7, 0.4], loop: D.full),
        ])

    static let lanes = D.lanes
    static let long = ["Intro", "Groove", "Break", "Drop", "Outro"]
    static func arr(_ prompt: String, _ hint: String, _ mode: TaskMode, sections: [String] = D.sections,
                    start: [[Bool]] = [], target: [[Bool]] = []) -> LessonStep {
        K.arrange(prompt, hint, mode, sections: sections, lanes: lanes, loop: D.full, start: start, target: target)
    }

    static let u4l3: LevelPair = (
        silver: [
            L.silver("DJ-friendly edges",
                     "DJs mix the start and end of your track into other records. Keep those edges simple: drums and maybe the bass."),
            arr("Copy this track", "Kick and hats run all the way through.", .recreate, target: K.grid("xxxx", "-x-x", "xxxx", "-xx-", "-xx-")),
            arr("Intro: kick and hats only", "Switch off the clap, bass and chords in the Intro.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("xxxx", "-xxx", "xxxx", "-xxx", "-xxx")),
        ],
        gold: [
            L.gold("longer tracks", "Five sections, slowly adding and removing parts."),
            arr("Recreate this track", "Hats never stop. The kick sits out the Break.", .recreate, sections: long,
                target: K.grid("xx-xx", "-x-x-", "xxxxx", "-x-xx", "-xxx-")),
            arr("Make it yours", "Keep the Intro and Outro simple for DJs.", .create(.variedSections), sections: long),
        ])

    static let u4l4: LevelPair = (
        silver: [
            L.silver("different breaks",
                     "A break can keep just the chords, just the bass, or just the hats. Each one tells a different story."),
            arr("Copy this break", "The bass carries this one.", .recreate,
                target: K.grid("xx-x", "-x-x", "xx-x", "-xx-", "xx-x")),
            arr("Chords only in the Break", "Switch everything else off in the Break.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("xx-x", "xx-x", "xx-x", "xx-x", "xxxx")),
        ],
        gold: [
            L.gold("two breaks", "The second break should strip back further than the first."),
            arr("Recreate this track", "Break 2 is chords alone.", .recreate, sections: ["Groove", "Break", "Groove 2", "Break 2"],
                target: K.grid("x-x-", "x-x-", "xxx-", "xxx-", "xxxx")),
            arr("Recreate this one", "The clap only plays in Groove 2. Break 2 is hats alone.", .recreate, sections: ["Groove", "Break", "Groove 2", "Break 2"],
                target: K.grid("x-x-", "--x-", "xxxx", "xxx-", "xxx-")),
        ])

    static let u4l5: LevelPair = (
        silver: [
            L.silver("a slow build",
                     "Deep house builds slowly. Bring in one part per section and never drop more than one at a time."),
            arr("Copy this slow build", "Kick and hats first, then the bass, then clap and chords.", .recreate, target: K.grid("xxxx", "--xx", "xxxx", "-xxx", "--x-")),
            arr("Chords skip the Intro and Outro", "Switch the chords off at both ends.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "-xx-")),
        ],
        gold: [
            L.gold("a full late-night track", "Five sections. Hear it all, then build your own."),
            arr("Recreate this track", "The bass waits for the Break.", .recreate, sections: long,
                target: K.grid("xx-xx", "-x-x-", "xxxxx", "--xxx", "-xxx-")),
            arr("Make it yours", "Build slowly. Never drop more than one part at a time.", .create(.variedSections), sections: long),
        ])
}
