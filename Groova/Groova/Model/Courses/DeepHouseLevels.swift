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

    static func padsBass(_ chords: [(Int, ChordShape, Int)], _ bass: [NoteEvent]) -> Pattern {
        var p = pads(chords)
        p.bass = bass
        return p
    }
    static let bassLoop = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: D.bassline)
    static let kickHat = D.full.keeping([.kick, .hat], bass: false, chords: false)

    static let all: [String: LevelPair] = [
        "deep.u1.l1": u1l1, "deep.u1.l2": u1l2, "deep.u1.l3": u1l3, "deep.u1.l4": u1l4, "deep.u1.l5": u1l5,
        "deep.u2.l1": u2l1, "deep.u2.l2": u2l2, "deep.u2.l3": u2l3, "deep.u2.l4": u2l4, "deep.u2.l5": u2l5,
        "deep.u3.l1": u3l1, "deep.u3.l2": u3l2, "deep.u3.l3": u3l3, "deep.u3.l4": u3l4, "deep.u3.l5": u3l5,
        "deep.u4.l3": u4l3, "deep.u4.l4": u4l4, "deep.u4.l5": u4l5,
    ]

    // MARK: Unit 1 — Late Night Grooves

    static let u1l1: LevelPair = (
        silver: [
            L.silver("kick length and weight",
                     "A deep kick is low and round, but how long it rings decides how heavy the groove feels. Short sits back, long fills the room."),
            K.quiz("Short or long?", "Same low, soft kick. Only the length changes.", [
                K.sound(kickLoop, [.kickPitch: 0.15, .kickDecay: 0.25, .kickDrive: 0], ["Short and soft", "Long and warm"], 0,
                        "It stops before the next hat. The groove sits back."),
                K.sound(kickLoop, [.kickPitch: 0.15, .kickDecay: 0.75, .kickDrive: 0], ["Short and soft", "Long and warm"], 1,
                        "It rings toward the next kick and fills the room."),
                K.ask("Why do deep house kicks skip the drive knob?", ["Drive adds grit, and deep house wants soft and round",
                                                                         "Drive makes the kick quieter", "Drive slows the tempo"], 0),
            ]),
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
            K.quiz("Does it fit?", "The full track plays with two different kicks.", [
                K.sound(D.full, [.kickPitch: 0.45, .kickDecay: 0.2, .kickDrive: 0.8], ["Too hard for deep house", "Soft and round"], 0,
                        "Bright and gritty. It fights the warm chords."),
                K.sound(D.full, [.kickPitch: 0.2, .kickDecay: 0.5, .kickDrive: 0], ["Too hard for deep house", "Soft and round"], 1),
            ]),
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
            K.quiz("Lean or answer?", "Listen to where the rims sit around the claps.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 11])], ["Leaning in (before)", "Answering (after)"], 0,
                       "Right before each clap.", bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [5, 13])], ["Leaning in (before)", "Answering (after)"], 1,
                       "Right after each clap, like a reply.", bars: 2),
            ]),
            L.copy("Copy the leaning rims", "Each rim sits right before a clap.", tracks: [.kick, .clap, .perc], edit: [.perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 11])),
            K.fix("Fix the answering rims", "Rims should answer: right after each clap, plus one at the very end. Two of them are leaning in before the claps instead.",
                  tracks: [.kick, .clap, .perc], edit: [.perc],
                  broken: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 11, 15]),
                  target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [5, 13, 15]), guide: false),
            L.make("Write your own rims", "At least 3.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: base,
                   goal: .atLeast(.perc, 3)),
        ],
        gold: [
            L.gold("rims instead of claps",
                   "Lots of deep house drops the clap altogether and lets the rims carry the backbeat. Rebuild grooves with no clap at all."),
            K.quiz("Clap or rims?", "Who's playing the backbeat?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: offHats, perc: [4, 7, 10, 12, 15])], ["A clap", "Rims only"], 1,
                       "No clap at all. The rims carry beats 2 and 4.", bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: offHats, perc: [7, 15])], ["A clap", "Rims only"], 0, bars: 2),
            ]),
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
            K.quiz("How much swing?", "Same hats and rims. Only the swing changes.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], perc: [3, 7, 11, 15])],
                       ["None", "Deep house", "Garage"], 0, "Dead straight.", bars: 2, swing: 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], perc: [3, 7, 11, 15])],
                       ["None", "Deep house", "Garage"], 1, "A relaxed lean. That's the sweet spot.", bars: 2, swing: 0.18),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], perc: [3, 7, 11, 15])],
                       ["None", "Deep house", "Garage"], 2, "Heavy skip. That's two-step territory.", bars: 2, swing: 0.36),
            ]),
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
            K.quiz("Quick check", "", [
                K.ask("You swing a groove that only has kicks, claps and offbeat hats. What happens?",
                      ["Nothing you can hear", "It shuffles hard", "It slows down"], 0,
                      "Swing only moves the 16ths between the beats. With nothing there, nothing moves. Write those notes first."),
            ]),
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
            K.quiz("How many open hats?", "Count the long, sizzling ones.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [1, 2, 5, 9, 10, 13], openHat: [6, 14])], ["Two", "Four"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14])], ["Two", "Four"], 1, bars: 2),
            ]),
            L.copy("Copy this hat groove", "Open hats on only two offbeats.", tracks: [.kick, .hat, .openHat],
                   edit: [.hat, .openHat], start: Pattern(kick: [0, 4, 8, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], hat: [1, 2, 5, 9, 10, 13], openHat: [6, 14])),
            K.fix("Move the last open hat", "Open hats on the offbeats, but the last one should move to the very end of the bar, so it breathes into the next one.",
                  tracks: [.kick, .hat, .openHat], edit: [.hat, .openHat],
                  broken: Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 11, 13], openHat: [2, 6, 10, 14]),
                  target: Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 11, 13], openHat: [2, 6, 10, 15]), guide: false),
        ],
        gold: [
            L.gold("hats with the whole kit",
                   "Hats, open hats and rims all fill the same gaps. Rebuild all three so they never step on each other."),
            L.copy("Rebuild the top end", "Closed hats just after each beat, two open hats, three rims.", tracks: kit, edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 10], perc: [7, 14, 15]),
                   threshold: 0.9),
            K.fix("Stop the choke", "Open hats on every offbeat, closed hats around beats 1 and 3. Two closed hats are landing on top of open hats and cutting them short. Clear them.",
                  tracks: kit, edit: Set(kit),
                  broken: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 2, 3, 9, 10, 11], openHat: [2, 6, 10, 14], perc: [7, 15]),
                  target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 9, 11], openHat: [2, 6, 10, 14], perc: [7, 15]),
                  guide: false),
            L.make("Make it yours", "Use both hats. At least 6 closed hats.", tracks: kit, edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 6)),
        ])

    static let u1l5: LevelPair = (
        silver: [
            L.silver("basslines that drift",
                     "Deep basslines hold long notes and drift between F, A♭ and E♭. Long notes on the offbeat make it sound lazy."),
            K.quiz("Lazy or bouncy?", "Same notes. Listen to how long they hold.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: [NoteEvent(3, 41, 3), NoteEvent(7, 44, 2), NoteEvent(11, 39, 3)])],
                       ["Lazy and long", "Short and bouncy"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: [NoteEvent(3, 41), NoteEvent(7, 44), NoteEvent(11, 39)])],
                       ["Lazy and long", "Short and bouncy"], 1, bars: 2),
            ]),
            bass("Copy this drifting line", "F, then up to A♭, then down to E♭.",
                 [NoteEvent(3, 41, 3), NoteEvent(7, 44, 2), NoteEvent(11, 39, 3)]),
            K.fixNotes("Fix the dip", "It should dip down to low C at the end. The last note stayed up on F.", rows: rows,
                       broken: [NoteEvent(2, 41, 2), NoteEvent(6, 41), NoteEvent(10, 44, 2), NoteEvent(14, 41, 2)],
                       target: [NoteEvent(2, 41, 2), NoteEvent(6, 41), NoteEvent(10, 44, 2), NoteEvent(14, 36, 2)], backing: D.drums),
            bassMake("Write your own", "At least 4 notes, some of them long.", notes: 4),
        ],
        gold: [
            L.gold("bass under chords",
                   "Under Fm9 the bass wants F. Under D♭maj7 it can drop to low C or sit on A♭. Follow the chords."),
            K.quiz("Does the bass fit?", "Fm9 then D♭maj7. Listen to the bass under them.", [
                K.hear([padsBass([(0, .fm9, 6), (8, .dbmaj7, 6)], [NoteEvent(3, 41, 3), NoteEvent(11, 37, 3)])],
                       ["Fits", "Clashes"], 0, "F under Fm9, D♭ under D♭maj7: each chord's root.", bars: 2),
                K.hear([padsBass([(0, .fm9, 6), (8, .dbmaj7, 6)], [NoteEvent(3, 40, 3), NoteEvent(11, 37, 3)])],
                       ["Fits", "Clashes"], 1, "That first note is E, a semitone under F. It rubs against the chord.", bars: 2),
            ]),
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
            K.build("Fix this E♭maj7", "This is E♭7: E♭, G, B♭ and D♭. It sounds bluesy. Raise the D♭ a semitone to D for the dreamy major 7th.",
                    .ebmaj7, start: [55, 58, 61, 63], low: 53, high: 67),
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
            K.lane("Make it yours", "Write a loop with at least three chords. Mix warm major 7ths and moody minor 7ths.",
                   .create(.chordsAtLeast(3)), palette: [.cm7, .ebmaj7, .fm7, .dbmaj7], backing: D.drums, length: 4),
        ])

    static let u2l2: LevelPair = (
        silver: [
            L.silver("minor 7ths everywhere",
                     "The same minor 7th shape gives you Fm7, Gm7, B♭m7 and Cm7. Learn the shape and you can play them all."),
            K.build("Build Gm7: G, B♭, D and F", "Same shape as Fm7, one step up.", .gm7, low: 53, high: 67),
            K.build("Build B♭m7: B♭, D♭, F and A♭", "Voiced from F up: F, A♭, B♭, D♭.", .bbm7, low: 53, high: 67),
            K.quiz("Quick check", "", [
                K.ask("Fm7 is F, A♭, C, E♭. Move every note up two semitones. Which chord do you get?", ["Gm7", "Cm7", "B♭m7"], 0,
                      "Same shape, new root. That's why learning one shape gives you every minor 7th."),
                K.round([.bbm7, .dbmaj7], ["Minor 7th", "Major 7th"], 1, question: "Is the second chord a minor 7th or a major 7th?"),
            ]),
            K.lane("Use them in a loop", "Place at least three chords using two or more of these minor 7ths.",
                   .create(.chordsAtLeast(3)), palette: [.fm7, .gm7, .bbm7], backing: D.drums, length: 4),
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
            K.lane("Make it yours", "Write a slow loop with at least three chords. Start on a ninth.",
                   .create(.chordsAtLeast(3)), palette: [.fm9, cm9, .bbm7, .cm7], backing: D.drums, length: 4),
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
            K.lane("Name it, then place it", "Three chords, three colours: rich, then moody, then warm. Pick the right one for each.", .recreate,
                   palette: [.fm9, .cm7, .dbmaj7], backing: D.drums, target: [0: 0, 6: 1, 12: 2], length: 4),
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
            K.lane("Make it yours", "Paint with colour. Use at least three chords and all three colours: rich, moody and warm.",
                   .create(.chordsAtLeast(3)), palette: [.fm9, .cm7, .dbmaj7, .ebmaj7], backing: D.drums, length: 4),
        ])

    static let u2l4: LevelPair = (
        silver: [
            L.silver("chord length",
                     "How long a chord rings is half its feel. Long chords float. Short stabs bounce. Hear both on the same rhythm."),
            K.quiz("Float or bounce?", "Same chord, two rhythms.", [
                K.hear([pads([(0, .fm9, 6), (8, .fm9, 6)])], ["Floating", "Bouncing"], 0, "Two long chords.", bars: 2),
                K.hear([pads([(1, .fm9, 1), (6, .fm9, 1), (9, .fm9, 1), (14, .fm9, 1)])], ["Floating", "Bouncing"], 1,
                       "Four short stabs.", bars: 2),
            ]),
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
            K.lane("Fix the last chord", "Fm9, E♭maj7, then Cm7 twice. The last Cm7 should land on the very last step, pushing into the loop.", .recreate,
                   palette: [.fm9, .ebmaj7, .cm7], backing: D.drums,
                   start: [2: 0, 7: 1, 10: 2, 13: 2], target: [2: 0, 7: 1, 10: 2, 15: 2], length: 3),
            K.lane("Make it yours", "At least 4 chords. Mix long and short.", .create(.chordsAtLeast(4)),
                   palette: [.fm9, .dbmaj7, .ebmaj7, .cm7], backing: D.drums, length: 3),
        ])

    static let u2l5: LevelPair = (
        silver: [
            L.silver("new progressions",
                     "Fm9 to D♭maj7 is the classic. Swap in B♭m7 or Cm7 and the loop goes somewhere else."),
            K.quiz("Where does it go?", "Both start on Fm9.", [
                K.round([.fm9, .dbmaj7], ["D♭maj7", "B♭m7"], 0, "Warm: the classic deep house move.", question: "Which chord comes next?"),
                K.round([.fm9, .bbm7], ["D♭maj7", "B♭m7"], 1, "Moody: the loop stays dark.", question: "Which chord comes next?"),
                K.round([.fm9, .cm7], ["Cm7", "E♭maj7"], 0, question: "Which chord comes next?"),
            ]),
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
            K.lane("Put it in order", "Short chords, placed unevenly. It should go Fm9, B♭m7, D♭maj7, E♭maj7, so the bright ones come last. Two are swapped.", .recreate,
                   palette: [.fm9, .bbm7, .dbmaj7, .ebmaj7], backing: D.drums,
                   start: [0: 0, 6: 2, 8: 1, 14: 3], target: [0: 0, 6: 1, 8: 2, 14: 3], length: 2),
            K.lane("Make it yours", "At least 4 chords.", .create(.chordsAtLeast(4)),
                   palette: [.fm9, .bbm7, .cm7, .dbmaj7, .ebmaj7], backing: D.drums, length: 4),
        ])

    // MARK: Unit 3 — Warm Sounds

    static let u3l1: LevelPair = (
        silver: [
            L.silver("pad envelopes",
                     "Attack is how slowly a chord fades in. Release is how long it hangs after. Together they decide if a pad swells or plucks."),
            K.quiz("Swell or pluck?", "Listen to how each chord starts and ends.", [
                K.sound(D.padLoop, [.chordAttack: 0.8, .chordRelease: 0.2], ["Swell", "Pluck"], 0, "It fades in."),
                K.sound(D.padLoop, [.chordAttack: 0.05, .chordRelease: 0.75], ["Swell", "Pluck"], 1, "Instant start, long hang."),
                K.ask("Which knob makes a pad fade in?", ["Attack", "Release", "Cutoff"], 0),
            ]),
            K.lab("Match the swelling pad", "Slow in, quick out.", [.chordAttack, .chordRelease], start: [0.0, 0.8],
                  target: [0.8, 0.2], loop: D.padLoop),
            K.lab("Match the soft pluck", "Quick in, long hang.", [.chordAttack, .chordRelease], start: [0.9, 0.1],
                  target: [0.05, 0.75], loop: D.padLoop),
        ],
        gold: [
            L.gold("the full pad sound",
                   "Attack, release, length and brightness all shape the pad. Match all four."),
            K.quiz("Back or front?", "The same pad in the full track.", [
                K.sound(D.full, [.chordAttack: 0.6, .chordCutoff: 0.3, .chordRelease: 0.7], ["Sits behind the beat", "Jumps out in front"], 0),
                K.sound(D.full, [.chordAttack: 0.0, .chordCutoff: 0.85, .chordRelease: 0.2], ["Sits behind the beat", "Jumps out in front"], 1),
            ]),
            K.lab("Match this pad", "Slow in, long, and darkish.", [.chordAttack, .chordRelease, .chordDecay, .chordCutoff], start: [0.0, 0.0, 0.1, 0.9],
                  target: [0.6, 0.7, 0.8, 0.35], loop: D.padLoop),
            K.lab("Match this one", "Quick in, short, and brighter.", [.chordAttack, .chordRelease, .chordDecay, .chordCutoff], start: [0.8, 0.8, 0.8, 0.2],
                  target: [0.15, 0.4, 0.35, 0.6], loop: D.full),
            K.lab("Make it yours", "Design a pad for a late-night groove. It should glow, not shout.",
                  [.chordAttack, .chordRelease, .chordDecay, .chordCutoff], start: [0.5, 0.5, 0.5, 0.5], loop: D.full),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("bass length and resonance",
                     "A round bass can still be shaped. Length decides if it hums or bounces. A little resonance adds a soft whistle."),
            K.quiz("Hum or whistle?", "The same bassline with different settings.", [
                K.sound(bassLoop, [.bassCutoff: 0.2, .bassDecay: 0.7, .bassResonance: 0], ["Long hum", "Short bounce"], 0),
                K.sound(bassLoop, [.bassCutoff: 0.2, .bassDecay: 0.15, .bassResonance: 0], ["Long hum", "Short bounce"], 1),
                K.sound(bassLoop, [.bassCutoff: 0.35, .bassResonance: 0.5], ["Smooth", "A soft whistle"], 1,
                        "A little resonance at the cutoff.", question: "What do you hear on top?"),
            ]),
            K.lab("Match the humming bass", "Long notes, dark tone.", [.bassCutoff, .bassDecay], start: [0.8, 0.1],
                  target: [0.2, 0.7], loop: Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: D.bassline)),
            K.lab("Match the whistly bass", "A touch of resonance.", [.bassCutoff, .bassResonance], start: [0.8, 0.0],
                  target: [0.35, 0.45], loop: Pattern(kick: [0, 4, 8, 12], hat: offHats, bass: D.bassline)),
        ],
        gold: [
            L.gold("bass in the full track",
                   "Match four bass controls with the whole track playing."),
            K.quiz("Is the bass sitting right?", "The full track plays. Listen to the low end.", [
                K.faders(D.full, [.bass: 1.0], ["Bass too loud", "Bass too quiet", "Balanced"], 0, "It swallows the kick."),
                K.faders(D.full, [.bass: 0.2], ["Bass too loud", "Bass too quiet", "Balanced"], 1, "The bottom feels empty."),
            ]),
            K.lab("Match this bass", "Dark and long, a hint of resonance.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay], start: [0.8, 0.8, 0.0, 0.1],
                  target: [0.25, 0.2, 0.3, 0.65], loop: D.full),
            K.lab("Match this one", "Brighter and shorter, with some bite.", [.bassCutoff, .bassEnv, .bassResonance, .bassDecay], start: [0.1, 0.0, 0.8, 0.8],
                  target: [0.45, 0.55, 0.15, 0.3], loop: D.full),
            K.lab("Make it yours", "Design a deep bass that hums under the chords and leaves room for the kick.",
                  [.bassCutoff, .bassEnv, .bassResonance, .bassDecay], start: [0.5, 0.5, 0.5, 0.5], loop: D.full),
        ])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("resonant filters",
                     "Resonance boosts the frequencies right at the cutoff. A dark filter with resonance sounds hollow and moody."),
            K.quiz("Hear the filter", "The full track through a filter.", [
                K.filtered(D.full, cutoff: 500, resonance: 0.7, ["Hollow", "Half-open", "Fully open"], 0, "Dark with a resonant peak."),
                K.filtered(D.full, cutoff: 2200, ["Hollow", "Half-open", "Fully open"], 1),
                K.filtered(D.full, cutoff: 16000, ["Hollow", "Half-open", "Fully open"], 2),
            ]),
            K.filterMatch("Match the hollow sound", "Dark, with lots of resonance.", cutoff: 500, resonance: 0.7, D.full),
            K.filterMatch("Match the half-open sound", "Brighter, no resonance.", cutoff: 2200, resonance: 0.0, D.full),
        ],
        gold: [
            L.gold("filters on different parts",
                   "A filter on the whole track changes everything at once. A filter on just the chords or just the bass shapes one part and leaves the rest punchy."),
            K.quiz("Whole track or one part?", "Something is darker. Is it everything, or only the chords?", [
                K.filtered(D.full, cutoff: 600, ["The whole track", "Only the chords"], 0, "The kick and hats went dark too."),
                K.sound(D.full, [.chordCutoff: 0.12], ["The whole track", "Only the chords"], 1, "The hats are still bright."),
            ]),
            K.filterMatch("Match this filter", "About halfway closed, medium resonance.", cutoff: 1100, resonance: 0.5, D.full),
            K.lab("Match the chord brightness", "A little darker than halfway.", [.chordCutoff], start: [0.9], target: [0.4], loop: D.full),
            K.lab("Match the bass brightness", "Very dark.", [.bassCutoff], start: [0.9], target: [0.15], loop: D.full),
        ])

    static let u3l4: LevelPair = (
        silver: [
            L.silver("space for long chords",
                     "Long chords need less reverb than short ones, because they already fill the room. Try space on held pads."),
            K.quiz("Dry or roomy?", "The same pads with different reverb.", [
                K.reverb(D.padLoop, amount: 0.05, ["Dry", "Big room"], 0),
                K.reverb(D.padLoop, amount: 0.6, ["Dry", "Big room"], 1, "The chords hang in the air."),
                K.ask("Which needs more reverb to feel spacious?", ["Short stabs", "Long held pads"], 0,
                      "Long pads already fill the room. Short stabs need reverb to leave a tail."),
            ]),
            K.space("Give the held pads space", "Find a room that does not blur them.",
                    pads([(0, .fm9, 8), (8, .dbmaj7, 8)])),
            K.lab("Match the dark, slow pad", "Darker, and fading in slowly.", [.chordCutoff, .chordAttack], start: [0.9, 0.0], target: [0.3, 0.55],
                  loop: D.padLoop),
        ],
        gold: [
            L.gold("depth front to back",
                   "Dark, quiet, slow sounds sit at the back. Bright, loud, fast ones sit at the front. Push the pad back."),
            K.quiz("Back or front?", "Listen to where the chords sit.", [
                K.sound(D.full, [.chordCutoff: 0.2, .chordAttack: 0.5], ["Pushed back", "Up front"], 0, "Dark and slow: far away."),
                K.sound(D.full, [.chordCutoff: 0.9, .chordAttack: 0.0], ["Pushed back", "Up front"], 1, "Bright and instant: close."),
            ]),
            K.lab("Push the pad back", "Dark, slow in, long release.", [.chordCutoff, .chordAttack, .chordRelease], start: [0.9, 0.0, 0.1],
                  target: [0.25, 0.5, 0.8], loop: D.full),
            K.lab("Bring the bass forward", "Brighter and shorter sounds closer. Pull the bass toward you.",
                  [.bassCutoff, .bassDecay], start: [0.1, 0.8], target: [0.55, 0.3], loop: D.full),
            K.space("Give it a room", "Big enough for the pads, not so big the kick blurs.", D.full),
        ])

    static let u3l5: LevelPair = (
        silver: [
            L.silver("dub stab rhythms",
                     "Dub stabs work because of the gaps. Place each stab so its echo fills the space before the next one."),
            K.quiz("Dry or dubby?", "Short stabs, two settings.", [
                K.reverb(Pattern(kick: [0, 4, 8, 12], hat: offHats, chords: [K.ch(3, .fm9, 1), K.ch(9, .fm9, 1), K.ch(14, .fm9, 1)]),
                         amount: 0.05, ["Dry", "Dubby"], 0),
                K.reverb(Pattern(kick: [0, 4, 8, 12], hat: offHats, chords: [K.ch(3, .fm9, 1), K.ch(9, .fm9, 1), K.ch(14, .fm9, 1)]),
                         amount: 0.7, ["Dry", "Dubby"], 1, "Each stab trails off into the gap."),
            ]),
            K.lane("Copy these dub stabs", "Short stabs with long gaps.", .recreate, palette: [.fm9], backing: D.drums,
                   target: [3: 0, 9: 0, 14: 0], length: 1),
            K.space("Make them echo", "Try a long space and listen to the gaps fill.", Pattern(kick: [0, 4, 8, 12], hat: offHats,
                                               chords: [K.ch(3, .fm9, 1), K.ch(9, .fm9, 1), K.ch(14, .fm9, 1)])),
        ],
        gold: [
            L.gold("dub stab changes",
                   "Change the chord on the stabs and the echo carries one chord into the next."),
            K.quiz("Quick check", "", [
                K.ask("Why leave long gaps between dub stabs?", ["So the echo has room to be heard", "To save CPU", "So the kick is louder"], 0),
            ]),
            K.lane("Copy these stabs", "Fm9 twice, then B♭m7 twice.", .recreate, palette: [.fm9, .bbm7], backing: D.drums,
                   target: [3: 0, 6: 0, 11: 1, 14: 1], length: 1),
            K.lane("Copy this one", "It starts and ends on Fm9.", .recreate, palette: [.fm9, .cm7, .ebmaj7], backing: D.drums,
                   target: [2: 0, 7: 1, 10: 2, 13: 0], length: 1),
            K.lane("Make it yours", "At least 4 stabs.", .create(.chordsAtLeast(4)),
                   palette: [.fm9, .bbm7, .cm7, .ebmaj7], backing: D.drums),
        ])

    // MARK: Unit 5 — Late Night Arrangement


    static let lanes = D.lanes
    static let long = ["Intro", "Groove", "Break", "Drop", "Outro"]
    static func arr(_ prompt: String, _ hint: String, _ mode: TaskMode, sections: [String] = D.sections,
                    start: [[Bool]] = [], target: [[Bool]] = []) -> LessonStep {
        K.arrange(prompt, hint, mode, sections: sections, lanes: lanes, loop: D.full, start: start, target: target)
    }

    static let u4l3: LevelPair = (
        silver: [
            L.silver("gentle edges",
                     "A deep track eases in and eases out. Keep the first and last sections simple, drums and maybe the bass, so the chords feel like an arrival."),
            K.quiz("Gentle edges", "", [
                K.hear([kickHat], ["Intro", "Groove", "Break"], 0, "Just kick and hats: an easy way in.", bars: 2),
                K.ask("Why keep a deep house intro and outro simple?", ["So DJs can mix it with other tracks", "To make it shorter",
                                                                       "Because the chords are too loud"], 0),
            ]),
            arr("Copy this track", "Kick and hats run all the way through.", .recreate, target: K.grid("xxxx", "-x-x", "xxxx", "-xx-", "-xx-")),
            arr("Intro: kick and hats only", "Switch off the clap, bass and chords in the Intro.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("xxxx", "-xxx", "xxxx", "-xxx", "-xxx")),
        ],
        gold: [
            L.gold("longer tracks", "Five sections, slowly adding and removing parts."),
            K.quiz("What arrives?", "Three bars of a slow intro.", [
                K.hear([kickHat, D.full.keeping([.kick, .hat], bass: true, chords: false), D.full], ["The bass", "The chords"], 0,
                       question: "What arrives in bar 2?"),
            ]),
            arr("Recreate this track", "Hats never stop. The kick sits out the Break.", .recreate, sections: long,
                target: K.grid("xx-xx", "-x-x-", "xxxxx", "-x-xx", "-xxx-")),
            arr("Make it yours", "Keep the Intro and Outro simple, so the middle feels full.", .create(.variedSections), sections: long),
        ])

    static let u4l4: LevelPair = (
        silver: [
            L.silver("different breaks",
                     "A break can keep just the chords, just the bass, or just the hats. Each one tells a different story."),
            K.quiz("What carries the break?", "The kick is gone. What's left?", [
                K.hear([D.full.keeping([], bass: true, chords: false)], ["Bass", "Chords", "Hats"], 0, "A dark, tense break.", bars: 2),
                K.hear([D.full.keeping([], bass: false, chords: true)], ["Bass", "Chords", "Hats"], 1, "Open and emotional.", bars: 2),
                K.hear([D.full.keeping([.hat], bass: false, chords: false)], ["Bass", "Chords", "Hats"], 2, "Just the pulse.", bars: 2),
            ]),
            arr("Copy this break", "The bass carries this one.", .recreate,
                target: K.grid("xx-x", "-x-x", "xx-x", "-xx-", "xx-x")),
            arr("Chords only in the Break", "Switch everything else off in the Break.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("xx-x", "xx-x", "xx-x", "xx-x", "xxxx")),
        ],
        gold: [
            L.gold("two breaks", "The second break should strip back further than the first."),
            K.quiz("Quick check", "", [
                K.ask("A track has two breaks. What should the second one do?", ["Strip back further than the first", "Add more parts",
                                                                                 "Repeat the first exactly"], 0,
                      "The deeper the second break, the bigger the return."),
            ]),
            arr("Recreate this track", "Break 2 is chords alone.", .recreate, sections: ["Groove", "Break", "Groove 2", "Break 2"],
                target: K.grid("x-x-", "x-x-", "xxx-", "xxx-", "xxxx")),
            arr("Recreate this one", "The clap only plays in Groove 2. Break 2 is hats alone.", .recreate, sections: ["Groove", "Break", "Groove 2", "Break 2"],
                target: K.grid("x-x-", "--x-", "xxxx", "xxx-", "xxx-")),
            arr("Make it yours", "Write two grooves and two breaks. Make Break 2 emptier than Break 1.", .create(.variedSections),
                sections: ["Groove", "Break", "Groove 2", "Break 2"]),
        ])

    static let u4l5: LevelPair = (
        silver: [
            L.silver("a slow build",
                     "Deep house builds slowly. Bring in one part per section and never drop more than one at a time."),
            K.quiz("One at a time", "", [
                K.hear([kickHat, D.full.keeping([.kick, .hat], bass: true, chords: false)], ["The bass", "The chords", "The clap"], 0,
                       question: "What came in?"),
                K.ask("In a slow deep build, how many parts should change between sections?", ["One, maybe two", "All of them"], 0),
            ]),
            arr("Copy this slow build", "Kick and hats first, then the bass, then clap and chords.", .recreate, target: K.grid("xxxx", "--xx", "xxxx", "-xxx", "--x-")),
            arr("Chords skip the Intro and Outro", "Switch the chords off at both ends.", .rule,
                start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                target: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "-xx-")),
        ],
        gold: [
            L.gold("a full late-night track", "Five sections. Hear it all, then build your own."),
            K.quiz("Slow build or sudden drop?", "", [
                K.hear([kickHat, D.full.keeping([.kick, .hat], bass: true, chords: false), D.full.keeping([.kick, .clap, .hat], bass: true, chords: false)],
                       ["Slow build", "Sudden drop"], 0, "One part at a time."),
                K.hear([kickHat, D.full], ["Slow build", "Sudden drop"], 1, "Everything at once. Exciting, but not very deep."),
            ]),
            arr("Recreate this track", "The bass waits for the Break.", .recreate, sections: long,
                target: K.grid("xx-xx", "-x-x-", "xxxxx", "--xxx", "-xxx-")),
            arr("Make it yours", "Build slowly. Never drop more than one part at a time.", .create(.variedSections), sections: long),
        ])
}
