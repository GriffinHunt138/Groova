//
//  HouseLevels.swift
//  Groova
//
//  Hand-written Silver and Gold levels for House Units 1–2.
//  Bronze teaches the idea. Silver applies it to new material and teaches the next detail.
//  Gold takes it into a full groove, by ear, and ends with your own version.
//

import Foundation

/// Builders for level content.
nonisolated enum L {
    static func silver(_ title: String, _ body: String) -> LessonStep {
        .intro(IntroStep(title: title.prefix(1).uppercased() + title.dropFirst(), body: body, pads: [],
                         badge: "Silver level", level: .silver))
    }

    static func gold(_ title: String, _ body: String) -> LessonStep {
        .intro(IntroStep(title: title.prefix(1).uppercased() + title.dropFirst(), body: body, pads: [],
                         badge: "Gold level", level: .gold))
    }

    static func copy(_ prompt: String, _ hint: String, tracks: [DrumTrack], edit: Set<DrumTrack>,
                     start: Pattern = Pattern(), target: Pattern, threshold: Double = 0.85) -> LessonStep {
        .sequencer(SequencerTask(prompt: prompt, hint: hint, mode: .recreate, tracks: tracks, editable: edit,
                                 start: start, target: target, showBeatGuide: false, threshold: threshold))
    }

    static func make(_ prompt: String, _ hint: String, tracks: [DrumTrack], edit: Set<DrumTrack>,
                     start: Pattern = Pattern(), goal: CreativeGoal) -> LessonStep {
        .sequencer(SequencerTask(prompt: prompt, hint: hint, mode: .create(goal), tracks: tracks, editable: edit,
                                 start: start, showBeatGuide: false))
    }

    static func bass(_ prompt: String, _ hint: String, _ target: [NoteEvent], backing: Pattern,
                     rows: [Int] = Curriculum.bassRows, threshold: Double = 0.85) -> LessonStep {
        K.bassCopy(prompt, hint, rows: rows, target: target, backing: backing, threshold: threshold)
    }

    static func bassMake(_ prompt: String, _ hint: String, backing: Pattern, notes: Int,
                         rows: [Int] = Curriculum.bassRows) -> LessonStep {
        K.bassMake(prompt, hint, rows: rows, backing: backing, notes: notes)
    }

    /// Notes as (step, pitch) or (step, pitch, length).
    static func n(_ list: [(Int, Int)]) -> [NoteEvent] { list.map { NoteEvent($0.0, $0.1) } }

    /// Four on the floor, claps, offbeat hats and the given chord stabs.
    static func bed(_ chords: [(Int, ChordShape)], length: Int = 1, bass: [NoteEvent] = []) -> Pattern {
        Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], bass: bass,
                chords: chords.map { K.ch($0.0, $0.1, length) })
    }
}

nonisolated enum HouseLevels {
    typealias Pair = (silver: [LessonStep], gold: [LessonStep])

    static let f = ChordShape(name: "F", pitches: [57, 60, 65])
    static let g = ChordShape(name: "G", pitches: [55, 59, 62])

    static let drums = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])
    static let offHats = Pattern(hat: [2, 6, 10, 14])
    static let moody = ["Happy (major)", "Moody (minor)"]

    static let all: [String: Pair] = [
        "house.u1.l1": u1l1,
        "house.u1.l2": u1l2,
        "house.u1.l3": u1l3,
        "house.u1.l4": u1l4,
        "house.u1.l5": u1l5,
        "house.u2.l1": u2l1,
        "house.u2.l2": u2l2,
        "house.u2.l3": u2l3,
        "house.u2.l4": u2l4,
        "house.u2.l5": u2l5,
    ]
        // MARK: Unit 1

    static let u1l1: Pair = (
            silver: [
                L.silver("push the kick",
                         "Four on the floor is the base, but producers add pickups: an extra kick just before a beat that leans into it and pushes the groove forward. Learn to hear where a pickup lands, fix one that's in the wrong place, then write your own. There's no beat guide from here on."),
                K.quiz("Where's the pickup?", "Four kicks on the beat plus one extra. Where does the extra one land?", [
                    K.hear([Pattern(kick: [0, 4, 8, 12, 15], hat: [2, 6, 10, 14])],
                           ["Before beat 2", "Before beat 3", "Before the next bar"], 2,
                           "Right at the end, so it pushes into the next bar.", bars: 2),
                    K.hear([Pattern(kick: [0, 4, 7, 8, 12], hat: [2, 6, 10, 14])],
                           ["Before beat 2", "Before beat 3", "Before the next bar"], 1,
                           "It leans into beat 3, the middle of the bar.", bars: 2),
                    K.hear([Pattern(kick: [0, 3, 4, 8, 12], hat: [2, 6, 10, 14])],
                           ["Before beat 2", "Before beat 3", "Before the next bar"], 0, bars: 2),
                    K.ask("Why does a pickup push the groove forward?",
                          ["It lands just before a beat and leads into it", "It replaces the kick on the beat",
                           "It's louder than the other kicks"], 0,
                          "A pickup always leads into the beat after it. That's what makes it pull you forward."),
                ]),
                L.copy("Hear the pickup, then copy it", "Four on the floor, plus one kick on the very last step.",
                       tracks: [.kick, .hat], edit: [.kick], start: offHats,
                       target: Pattern(kick: [0, 4, 8, 12, 15], hat: [2, 6, 10, 14])),
                K.fix("Fix the late pickup", "The extra kick should lead into beat 3. Here it lands just after it, so it drags instead of pushing. Move it.",
                      tracks: [.kick, .hat], edit: [.kick], broken: Pattern(kick: [0, 4, 8, 9, 12], hat: [2, 6, 10, 14]),
                      target: Pattern(kick: [0, 4, 7, 8, 12], hat: [2, 6, 10, 14]), guide: false),
                L.make("Write a kick with your own pickups", "Keep all four beats and add at least two pickups, each just before a beat.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       goal: .atLeast(.kick, 6)),
            ],
            gold: [
                L.gold("what the kick leaves out",
                       "Taking kicks away is as powerful as adding them. Half-time kicks feel slower without changing tempo, rolling kicks feel urgent, and every track drops the kick somewhere. Name each feel by ear, copy and fix them, then write a peak-time kick."),
                K.quiz("Name that kick", "Same tempo every time. Only the kick changes.", [
                    K.hear([Pattern(kick: [0, 10], clap: [8], hat: [2, 6, 10, 14])],
                           ["Four on the floor", "Half-time", "Rolling"], 1, "Two kicks and one clap per bar. It feels half as fast.",
                           bars: 2),
                    K.hear([Pattern(kick: [0, 3, 4, 8, 11, 12], clap: [4, 12], hat: [2, 6, 10, 14])],
                           ["Four on the floor", "Half-time", "Rolling"], 2, "Extra kicks tumble into beats 2 and 4.", bars: 2),
                    K.hear([drums], ["Four on the floor", "Half-time", "Rolling"], 0, bars: 2),
                    K.hear([drums, Pattern(clap: [4, 12], hat: [2, 6, 10, 14])],
                           ["The kick drops out", "The clap drops out", "Nothing changes"], 0,
                           "Dropping the kick for a bar is the oldest trick for building tension.",
                           question: "What happens in bar 2?"),
                ]),
                L.copy("Half-time: copy this kick", "Only two kicks. It feels half as fast, but the tempo hasn't changed.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [8], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 10], clap: [8], hat: [2, 6, 10, 14]), threshold: 0.9),
                K.fix("Fix the rolling kick", "The extra kicks should tumble into beats 2 and 4, landing just before them. Two of them landed just after instead.",
                      tracks: [.kick, .clap, .hat], edit: [.kick],
                      broken: Pattern(kick: [0, 4, 5, 8, 12, 13], clap: [4, 12], hat: [2, 6, 10, 14]),
                      target: Pattern(kick: [0, 3, 4, 8, 11, 12], clap: [4, 12], hat: [2, 6, 10, 14]), guide: false),
                L.copy("Rebuild the whole groove", "Get the kick first, then the clap, then the hats. Listen for the pickup.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                       target: Pattern(kick: [0, 4, 8, 12, 14], clap: [4, 12], hat: [2, 6, 10, 14]), threshold: 0.9),
                L.make("Make it yours", "Write a peak-time kick with pickups and one gap where a kick drops out. Use at least 7 kicks.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       goal: .atLeast(.kick, 7)),
            ])

    static let u1l2: Pair = (
            silver: [
                L.silver("ghost claps",
                         "Claps on 2 and 4 are the backbone. Ghost claps are extra hits around them that make the groove talk back. Spot them by ear, copy one, repair a broken backbeat, then write your own."),
                K.quiz("Spot the ghost", "Listen to the claps.", [
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12])], ["Just 2 and 4", "2 and 4 plus a ghost"], 0,
                           "Plain backbeat.", bars: 2, question: "Is there a ghost clap?"),
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 11, 12])], ["Just 2 and 4", "2 and 4 plus a ghost"], 1,
                           "A quick extra clap just before beat 4.", bars: 2, question: "Is there a ghost clap?"),
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 7, 12])], ["Just after beat 2", "Just before beat 4"], 0,
                           "It answers beat 2, like an echo.", bars: 2, question: "Where's the ghost?"),
                    K.ask("Which clap must never move in house?",
                          ["The ones on beats 2 and 4", "The ghost claps", "None of them"], 0,
                          "Ghosts can go anywhere. The backbeat on 2 and 4 stays put."),
                ]),
                L.copy("Find the ghost clap", "2 and 4 are there. One extra clap lands just before beat 4.",
                       tracks: [.kick, .clap], edit: [.clap], start: Curriculum.fourFloor,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 11, 12])),
                K.fix("Repair the backbeat", "Someone moved the beat 4 clap onto beat 3. Put the backbeat back on 2 and 4, and keep both ghosts.",
                      tracks: [.kick, .clap, .hat], edit: [.clap],
                      broken: Pattern(kick: [0, 4, 8, 12], clap: [4, 7, 8, 15], hat: [2, 6, 10, 14]),
                      target: Pattern(kick: [0, 4, 8, 12], clap: [4, 7, 12, 15], hat: [2, 6, 10, 14]), guide: false),
                L.make("Write a clap part with ghosts", "Keep 2 and 4 and add at least two ghost claps.",
                       tracks: [.kick, .clap, .hat], edit: [.clap], start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]),
                       goal: .atLeast(.clap, 4)),
            ],
            gold: [
                L.gold("move the backbeat",
                       "Where the clap lands sets the whole feel. On 2 and 4 it's house. On beat 3 alone it's half-time. Swung ghost claps push toward garage. Name each feel, play them, then build a full groove from nothing."),
                K.quiz("Which feel is it?", "Only the clap and the swing change.", [
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])],
                           ["House", "Half-time", "Shuffled"], 0, "Claps on 2 and 4.", bars: 2),
                    K.hear([Pattern(kick: [0, 10], clap: [8], hat: [2, 6, 10, 14])],
                           ["House", "Half-time", "Shuffled"], 1, "One clap per bar, on beat 3.", bars: 2),
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 7, 12, 15], hat: [2, 6, 10, 14])],
                           ["House", "Half-time", "Shuffled"], 2, "The ghosts swing late, so the groove skips.", bars: 2,
                           swing: 0.35),
                ]),
                L.copy("Half-time backbeat", "One clap per bar, on beat 3. The kick plays beat 1 and once more just after the clap.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap], start: offHats,
                       target: Pattern(kick: [0, 10], clap: [8], hat: [2, 6, 10, 14]), threshold: 0.9),
                K.swingMake("Swing the ghost claps", "Turn up swing until the ghost claps on the in-between steps start to shuffle.",
                            tracks: [.kick, .clap, .hat],
                            start: Pattern(kick: [0, 4, 8, 12], clap: [4, 7, 12, 15], hat: [2, 6, 10, 14]), atLeast: 0.25),
                L.copy("Rebuild the whole groove", "Kick on every beat, claps on 2 and 4 with one ghost, hats on the offbeats plus one at the end.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 15], hat: [2, 6, 10, 14, 15]), threshold: 0.9),
                L.make("Make it yours", "Start from silence. Write kick, clap and hats, keep a backbeat, and use at least 3 claps.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], goal: .atLeast(.clap, 3)),
            ])

    static let u1l3: Pair = (
            silver: [
                L.silver("16th hats",
                         "Offbeat open hats give house its lift. Closed hats on the 16ths in between add speed. Hear the difference between open and closed, and between 8ths and 16ths. Then fill the gaps without stepping on the open hat."),
                K.quiz("Open, closed, fast or slow?", "Listen to the hats.", [
                    K.hear([Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14])], ["Open hat", "Closed hat"], 0,
                           "Long and sizzling: open.", bars: 2, question: "Which hat is on the offbeat?"),
                    K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])], ["Open hat", "Closed hat"], 1,
                           "Short tick: closed.", bars: 2, question: "Which hat is on the offbeat?"),
                    K.hear([Pattern(kick: [0, 4, 8, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14])], ["Two", "Four"], 0,
                           "8th notes: two per beat.", bars: 2, question: "How many hats per beat?"),
                    K.hear([Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16))], ["Two", "Four"], 1,
                           "16th notes: four per beat. Much faster.", bars: 2, question: "How many hats per beat?"),
                ]),
                L.copy("Copy the closed hats", "Open hats stay on the offbeats. Closed hats tick on every step in between the beats and the offbeats.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                       openHat: [2, 6, 10, 14])),
                K.fix("Stop the hats choking", "A closed hat cuts an open hat short when they hit together. The closed hats are on every step here. Clear them only where the open hat plays.",
                      tracks: [.kick, .clap, .hat, .openHat], edit: [.hat],
                      broken: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14]),
                      target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15],
                                      openHat: [2, 6, 10, 14]), guide: false),
                L.make("Write a fast hat part", "Use at least 8 closed hats and leave room for the open hats.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14]),
                       goal: .atLeast(.hat, 8)),
            ],
            gold: [
                L.gold("hats that groove",
                       "Hats carry the swing and the energy. Shuffled 16ths feel human, sparse hats feel deep, and percussion fills the holes. Tell the styles apart by ear, then build full kits, hats and all."),
                K.quiz("Which hat style?", "Kick and clap stay the same. Only the hats change.", [
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [7, 15], openHat: [2, 10])],
                           ["Deep and sparse", "Straight 16ths", "Shuffled 16ths"], 0, "Lots of space between hits.", bars: 2),
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15], openHat: [2, 6, 10, 14])],
                           ["Deep and sparse", "Straight 16ths", "Shuffled 16ths"], 1, "Even, machine-tight ticks.", bars: 2),
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15], openHat: [2, 6, 10, 14])],
                           ["Deep and sparse", "Straight 16ths", "Shuffled 16ths"], 2, "Every other tick lands late, so it skips.",
                           bars: 2, swing: 0.35),
                ]),
                K.swingMake("Shuffle the 16th hats", "Swing delays every other 16th. Turn it up until the hats skip.",
                            tracks: [.kick, .clap, .hat, .openHat],
                            start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15],
                                           openHat: [2, 6, 10, 14]), atLeast: 0.25),
                L.copy("Sparse deep house hats", "Fewer hats, more space: two open hats and two closed ticks.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat, .openHat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [7, 15], openHat: [2, 10]), threshold: 0.9),
                L.copy("Rebuild the full kit with a rim", "Classic kick and clap, closed hats just after each offbeat, open hats on the offbeat. The new Rim row plays after beats 3 and 4.",
                       tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc],
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [3, 7, 11, 15], openHat: [2, 6, 10, 14],
                                       perc: [9, 13]), threshold: 0.9),
                L.make("Make it yours", "Write closed hats, open hats and rims. Use at least 6 closed hats, and keep them off the open hats.",
                       tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .openHat, .perc],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 6)),
            ])

    static let u1l4: Pair = (
            silver: [
                L.silver("octaves and note length",
                         "The same note an octave higher sounds brighter but still fits. Length matters too: short notes bounce, long notes groove. Hear both, copy a line that uses length, then fix a bounce that jumps to the wrong octave."),
                K.quiz("High, low, short or long?", "Listen to the bass under the drums.", [
                    K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: L.n([(2, 33), (6, 33), (10, 33), (14, 33)]))],
                           ["Stays on one note", "Jumps up an octave"], 0, "Low A every time.", bars: 2,
                           question: "What does the bass do?"),
                    K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: L.n([(2, 33), (6, 45), (10, 33), (14, 45)]))],
                           ["Stays on one note", "Jumps up an octave"], 1, "Same note name, an octave apart. It still fits.", bars: 2,
                           question: "What does the bass do?"),
                    K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14],
                                    bass: [NoteEvent(2, 33, 2), NoteEvent(6, 33, 2), NoteEvent(10, 33, 2), NoteEvent(14, 33, 2)])],
                           ["Short and bouncy", "Long and smooth"], 1, "Each note holds for two steps.", bars: 2,
                           question: "How long are the notes?"),
                ]),
                L.bass("Short and long notes", "Some notes hold for two steps. Drag a note's edge to make it longer.",
                       [NoteEvent(2, 33, 2), NoteEvent(6, 36), NoteEvent(7, 38), NoteEvent(10, 33, 2), NoteEvent(14, 40, 2)],
                       backing: drums),
                K.fixNotes("Fix the octave bounce", "Low A and high A should take turns on the offbeats. Two notes are in the wrong octave.",
                           rows: Curriculum.bassRows, broken: L.n([(2, 33), (6, 33), (10, 45), (14, 45)]),
                           target: L.n([(2, 33), (6, 45), (10, 33), (14, 45)]), backing: drums),
                L.bassMake("Write a bassline with an octave jump", "Use at least 6 notes, including both the low A and the high A. Make at least one of them long.",
                           backing: drums, notes: 6),
            ],
            gold: [
                L.gold("16th-note bass",
                       "Rolling 16th basslines drive peak-time house. Notes just before or after the offbeat create a gallop, and passing notes walk between them. Tell the styles apart, copy a roller, then repair a walk that goes the wrong way."),
                K.quiz("Which bassline?", "Same drums, three basslines.", [
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], bass: L.n([(2, 33), (6, 33), (10, 33), (14, 33)]))],
                           ["Offbeat", "Rolling 16ths", "Walking"], 0, "One note per offbeat.", bars: 2),
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14],
                                    bass: L.n([(2, 33), (3, 33), (6, 33), (7, 33), (10, 33), (11, 33), (14, 33), (15, 33)]))],
                           ["Offbeat", "Rolling 16ths", "Walking"], 1, "Pairs of quick notes on one pitch.", bars: 2),
                    K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14],
                                    bass: L.n([(2, 33), (3, 36), (6, 33), (7, 38), (10, 33), (11, 40), (14, 33), (15, 43)]))],
                           ["Offbeat", "Rolling 16ths", "Walking"], 2, "The second note of each pair climbs.", bars: 2),
                ]),
                L.bass("Copy the rolling bass", "Pairs of notes around each offbeat. The pitch climbs in the second half.",
                       L.n([(2, 33), (3, 33), (6, 33), (7, 36), (10, 38), (11, 38), (14, 40), (15, 43)]),
                       backing: drums, threshold: 0.9),
                K.fixNotes("Fix the walk", "Every offbeat is low A, and the note after each one should climb: C, D, E, then G. Two of the climbing notes are swapped.",
                           rows: Curriculum.bassRows,
                           broken: L.n([(2, 33), (3, 36), (6, 33), (7, 43), (10, 33), (11, 40), (14, 33), (15, 38)]),
                           target: L.n([(2, 33), (3, 36), (6, 33), (7, 38), (10, 33), (11, 40), (14, 33), (15, 43)]),
                           backing: drums),
                L.bassMake("Make it yours", "Write a rolling bassline with at least 8 notes. Give it a gallop or a walk.", backing: drums, notes: 8),
            ])

    static let u1l5: Pair = (
            silver: [
                L.silver("resonance",
                         "Cutoff decides how much top end gets through. Resonance adds a peak right at the cutoff, which you hear as a whistle or squelch. Learn to hear both, then match them."),
                K.quiz("Hear the filter", "The same loop through a filter.", [
                    K.filtered(Curriculum.fxLoop, cutoff: 400, ["Closed: dark and muffled", "Open: bright and clear"], 0,
                               "Only the lows get through.", question: "Is the filter open or closed?"),
                    K.filtered(Curriculum.fxLoop, cutoff: 12000, ["Closed: dark and muffled", "Open: bright and clear"], 1,
                               question: "Is the filter open or closed?"),
                    K.filtered(Curriculum.fxLoop, cutoff: 700, resonance: 0.8, ["Smooth", "A whistling peak"], 1,
                               "That ringing tone at the cutoff is resonance.", question: "Can you hear resonance?"),
                    K.filtered(Curriculum.fxLoop, cutoff: 700, resonance: 0, ["Smooth", "A whistling peak"], 0,
                               question: "Can you hear resonance?"),
                ]),
                K.filterMatch("Match the squelch", "Cutoff low, resonance high. Listen for the whistle.",
                              cutoff: 450, resonance: 0.8, Curriculum.fxLoop),
                K.filterMatch("Match the telephone", "Thin and boxy. Cutoff in the middle with a little resonance.",
                              cutoff: 1200, resonance: 0.45, Curriculum.fxLoop),
            ],
            gold: [
                L.gold("filter one sound",
                       "Producers filter single parts as much as the whole mix. A chord can be a short bright pluck or a dark ringing pad just by moving its filter and length. Hear the difference, shape two chords, match a subtle filter, then ride it like a build."),
                K.quiz("Pluck or pad?", "Same chords, different sound settings.", [
                    K.sound(Curriculum.fxLoop, [.chordCutoff: 0.85, .chordDecay: 0.1, .chordAttack: 0],
                            ["Bright pluck", "Dark pad"], 0, "Bright, instant and short.", question: "What is it?"),
                    K.sound(Curriculum.fxLoop, [.chordCutoff: 0.2, .chordDecay: 0.8, .chordAttack: 0.5],
                            ["Bright pluck", "Dark pad"], 1, "Filtered down, slow to start, long to fade.", question: "What is it?"),
                ]),
                K.lab("Match the dark chord", "Turn down its brightness and let it ring.",
                      [.chordCutoff, .chordDecay], start: [0.7, 0.3], target: [0.2, 0.7], loop: Curriculum.fxLoop),
                K.lab("Match the bright pluck", "Bright, instant and short.",
                      [.chordCutoff, .chordDecay, .chordAttack], start: [0.3, 0.6, 0.5], target: [0.8, 0.15, 0.0],
                      loop: Curriculum.fxLoop),
                K.filterMatch("Match a subtle filter", "A small difference. Compare Reference and Yours carefully.",
                              cutoff: 5000, resonance: 0.3, Curriculum.fxLoop),
                K.filterSweep("Make it yours: ride the filter", "Start dark and slowly open the filter over a few bars, like a build into a drop. Add resonance near the top for extra bite.",
                              Curriculum.fxLoop),
            ])

        // MARK: Unit 2

    static let u2l1: Pair = (
            silver: [
                L.silver("more chords",
                         "Every major and minor chord has the same recipe: a root, a third and a fifth. The third decides the mood. Build new chords, hear the difference, and use two in a groove."),
                K.build("Build C major", "C, E and G. Compare it with A minor: two notes are shared.", .c),
                K.build("Build E minor", "E, G and B.", .em),
                K.quiz("Happy or moody?", "New chords this time.", [
                    K.ask("A minor is A, C, E. C major is C, E, G. How many notes do they share?", ["One", "Two", "Three"], 1,
                          "C and E. Only one note changes, which is why they sit so well together."),
                    K.round([.dm], moody, 1, "D minor."),
                    K.round([f], moody, 0, "F major."),
                    K.round([g], moody, 0, "G major."),
                    K.ask("Which note decides if a chord is major or minor?", ["The root", "The third", "The fifth"], 1,
                          "Four semitones above the root is major. Three is minor."),
                ]),
                K.lane("A minor on beat 1, C on beat 3", "Pick each chord, then place it.", .rule,
                       palette: [.am, .c], backing: drums, target: [0: 0, 8: 1], length: 4),
            ],
            gold: [
                L.gold("three-chord moves",
                       "Major and minor chords take turns in almost every song. Build them with no help, repair one with the wrong third, name them by ear, recreate a three-chord groove and write your own."),
                K.build("Build D minor", "D, F and A. No starting notes.", .dm),
                K.build("Fix this G major", "Someone built G minor: G, B♭, D. Raise the third a semitone to make it major.", g,
                        start: [55, 58, 62]),
                K.quiz("Major or minor?", "Five chords, one after another.", [
                    K.round([.c], moody, 0), K.round([.em], moody, 1), K.round([f], moody, 0),
                    K.round([.am], moody, 1), K.round([g], moody, 0),
                ]),
                K.lane("Recreate this three-chord groove", "Am, then C, then G. Listen for where each one starts.", .recreate,
                       palette: [.am, .c, g], backing: drums, target: [0: 0, 6: 1, 10: 2], length: 4),
                K.lane("Make it yours", "Write a groove with at least three chords. Mix major and minor, and end on Am to feel finished.",
                       .create(.chordsAtLeast(3)), palette: [.am, .c, .dm, g], backing: drums, length: 4),
            ])

    static let u2l2: Pair = (
            silver: [
                L.silver("7ths on new roots",
                         "The minor 7th recipe works from any root: root, minor third, fifth and minor seventh. Build it on a root with a black key, hear plain against 7th, repair a broken one, then use 7ths in a groove."),
                K.build("Build Gm7", "G, B♭, D and F. The black key is the minor third.", .gm7),
                K.quiz("Plain or 7th?", "New chords this time.", [
                    K.round([.dm7], ["Plain (3 notes)", "7th (4 notes)"], 1, "Dm7."),
                    K.round([.em], ["Plain (3 notes)", "7th (4 notes)"], 0, "Plain E minor."),
                    K.round([.em7], ["Plain (3 notes)", "7th (4 notes)"], 1, "Em7."),
                    K.ask("What does adding the 7th do to a minor chord?",
                          ["Makes it softer and jazzier", "Makes it major", "Makes it louder"], 0,
                          "It fills the gap above the fifth, so the chord sounds smoother."),
                ]),
                K.build("Fix this Dm7", "D, F, A and C. One note is a semitone too high.", .dm7, start: [57, 61, 62, 65]),
                K.lane("Use 7ths in a groove", "Place at least four stabs using two or more of these 7ths.",
                       .create(.chordsAtLeast(4)), palette: [.am7, .dm7, .em7], backing: drums),
            ],
            gold: [
                L.gold("major 7ths",
                       "There are two kinds of 7th. Minor 7ths sound moody. Major 7ths sound warm and dreamy. A semitone in the wrong place turns dreamy into bluesy. Build, repair and hear each, then write a deep house loop with both."),
                K.build("Build Fmaj7", "F, A, C and E.", .fmaj7),
                K.build("Fix this Cmaj7", "This is C7: C, E, G and B♭. It sounds bluesy. Move the 7th up a semitone to B to make it dreamy.",
                        .cmaj7, start: [55, 58, 60, 64]),
                K.quiz("Major 7th or minor 7th?", "Warm or moody?", [
                    K.round([.fmaj7], ["Major 7th (warm)", "Minor 7th (moody)"], 0),
                    K.round([.am7], ["Major 7th (warm)", "Minor 7th (moody)"], 1),
                    K.round([.cmaj7], ["Major 7th (warm)", "Minor 7th (moody)"], 0),
                    K.round([.dm7], ["Major 7th (warm)", "Minor 7th (moody)"], 1),
                    K.ask("Am7 is A, C, E, G. Cmaj7 is C, E, G, B. What do they share?",
                          ["C, E and G", "A, C and E", "Nothing"], 0,
                          "Three notes. Only one changes, so swapping between them sounds smooth."),
                ]),
                K.lane("Hear the moody-to-warm swap", "Two stabs of one chord, then two of the other.", .recreate,
                       palette: [.am7, .fmaj7], backing: drums, target: [2: 0, 6: 0, 10: 1, 14: 1]),
                K.lane("Make it yours", "Write a deep house loop with at least four stabs. Use at least one warm major 7th and one moody minor 7th.",
                       .create(.chordsAtLeast(4)), palette: [.am7, .dm7, .fmaj7, .cmaj7], backing: drums, length: 2),
            ])

    static let u2l3: Pair = (
            silver: [
                L.silver("stab rhythm",
                         "Where you place stabs is a rhythm part of its own. Stabs on the 16ths around the offbeat feel funky. Stabs that hold for longer feel lush. Hear the difference, copy a funky part, then fix a lush one."),
                K.quiz("Funky or lush?", "Same chord, same drums. Only the stab rhythm changes.", [
                    K.hear([L.bed([(2, .am7), (3, .am7), (7, .am7), (10, .am7), (11, .am7), (15, .am7)])],
                           ["Funky", "Lush"], 0, "Short stabs in quick pairs.", bars: 2),
                    K.hear([L.bed([(2, .am7), (10, .am7)], length: 4)], ["Funky", "Lush"], 1, "Long chords with space.", bars: 2),
                    K.hear([L.bed([(0, .am7), (4, .am7), (8, .am7), (12, .am7)])],
                           ["With the kick", "Between the kicks"], 0, "Stabs on the beat fight the kick for space.", bars: 2,
                           question: "Where do the stabs land?"),
                    K.hear([L.bed([(2, .am7), (6, .am7), (10, .am7), (14, .am7)])],
                           ["With the kick", "Between the kicks"], 1, "Offbeat stabs bounce against the kick.", bars: 2,
                           question: "Where do the stabs land?"),
                ]),
                K.lane("Copy the funky stabs", "Pairs of stabs around the offbeats.", .recreate,
                       palette: [.am7], backing: drums, target: [2: 0, 3: 0, 7: 0, 10: 0, 11: 0, 15: 0]),
                K.lane("Fix the lush stabs", "Each stab holds for two steps. The last one should come a step early, to push into the next bar.", .recreate,
                       palette: [.am7], backing: drums, start: [2: 0, 6: 0, 10: 0, 14: 0], target: [2: 0, 6: 0, 10: 0, 13: 0],
                       length: 2),
                K.lane("Write stabs with at least six hits", "Mix single stabs and pairs.", .create(.chordsAtLeast(6)),
                       palette: [.am7], backing: drums),
            ],
            gold: [
                L.gold("stab riffs",
                       "Real stab riffs swap chords on the offbeats. Hear which chord sneaks in, copy a two-chord riff, fix a riff that's lost its push, then write your own."),
                K.quiz("Which chord sneaks in?", "Mostly Am7, then something else.", [
                    K.round([.am7, .am7, .em7, .am7], ["Dm7", "Em7"], 1, "Em7: brighter, a little higher.",
                            question: "Which chord is the odd one out?"),
                    K.round([.am7, .am7, .dm7, .dm7], ["Dm7", "Em7"], 0, "Dm7: softer and lower.",
                            question: "Which chord comes in?"),
                    K.round([.am7, .em7, .am7, .am7], ["Second", "Third"], 0, question: "Which stab is different?"),
                ]),
                K.lane("Copy the two-chord riff", "Mostly Am7, with Em7 in the middle of the bar.", .recreate,
                       palette: [.am7, .em7], backing: drums, target: [2: 0, 6: 0, 9: 1, 10: 1, 14: 0]),
                K.lane("Fix the pushed riff", "Am7 then Dm7. The last stab should land on the very last step, pushing into the loop. Right now it sits on the offbeat.", .recreate,
                       palette: [.am7, .dm7], backing: drums, start: [1: 0, 3: 0, 6: 0, 10: 1, 14: 1],
                       target: [1: 0, 3: 0, 6: 0, 10: 1, 15: 1]),
                K.lane("Make it yours", "Write a stab riff with at least six stabs and at least two chords. Push one stab early.",
                       .create(.chordsAtLeast(6)), palette: [.am7, .dm7, .em7], backing: drums),
            ])

    static let u2l4: Pair = (
            silver: [
                L.silver("three-chord progressions",
                         "Most house loops use three or four chords. The order changes the mood: ending on Em7 feels unfinished, ending on Am7 feels like home."),
                K.lane("Am7, Dm7, then Em7", "Change step 7 to Dm7, and steps 11 and 15 to Em7.", .rule,
                       palette: [.am7, .dm7, .em7], backing: drums,
                       start: [2: 0, 6: 0, 10: 0, 14: 0], target: [2: 0, 6: 1, 10: 2, 14: 2]),
                K.quiz("Which chord comes third?", "Three chords play. Name the last one.", [
                    K.round([.am7, .dm7, .em7], ["Em7", "Fmaj7"], 0),
                    K.round([.am7, .fmaj7, .dm7], ["Em7", "Dm7"], 1),
                    K.round([.am7, .em7, .fmaj7], ["Fmaj7", "Dm7"], 0),
                    K.ask("Why does a loop ending on Em7 feel unfinished?",
                          ["It wants to go back home to Am7", "It's quieter", "It has fewer notes"], 0,
                          "Am7 is home. Em7 leans back toward it, so the loop keeps pulling you round."),
                ]),
                K.lane("Recreate this progression", "Three chords. It ends back home on Am7.", .recreate,
                       palette: [.am7, .dm7, .em7], backing: drums, target: [2: 0, 6: 2, 10: 1, 14: 0]),
            ],
            gold: [
                L.gold("four-chord loops",
                       "The four-chord loop is the backbone of piano house. Learn the Am7, Fmaj7, Dm7, Em7 family: put it in order, hear where it ends, copy a syncopated version and write your own."),
                K.lane("Put the loop in order", "Two chords are swapped. It should go Am7, Fmaj7, Dm7, then Em7.", .recreate,
                       palette: [.am7, .dm7, .em7, .fmaj7], backing: drums,
                       start: [2: 0, 6: 1, 10: 3, 14: 2], target: [2: 0, 6: 3, 10: 1, 14: 2]),
                K.quiz("How does it end?", "Four chords play. Listen to where they finish.", [
                    K.round([.am7, .fmaj7, .dm7, .em7], ["Ends on Em7", "Ends on Am7"], 0),
                    K.round([.am7, .dm7, .em7, .am7], ["Ends on Em7", "Ends on Am7"], 1),
                    K.round([.fmaj7, .em7, .dm7, .am7], ["Ends on Em7", "Ends on Am7"], 1),
                ]),
                K.lane("Recreate the syncopated riff", "Same four chords, but two stabs land early.", .recreate,
                       palette: [.am7, .dm7, .em7, .fmaj7], backing: drums, target: [0: 0, 3: 0, 6: 3, 10: 1, 13: 2]),
                K.lane("Make it yours", "Write a loop with at least four stabs and at least three different chords. Decide: end at home, or leave it hanging?",
                       .create(.chordsAtLeast(4)), palette: [.am7, .dm7, .em7, .fmaj7], backing: drums),
            ])

    static let u2l5: Pair = (
            silver: [
                L.silver("roots and fifths",
                         "The root anchors the chord. The fifth (E for A, A for D) is the next safest note. Mixing the two makes a bassline move without clashing. Hear a clash, then copy and fix basslines built from roots and fifths."),
                K.quiz("Does the bass fit?", "Am7 stabs over drums. Listen to the bass under them.", [
                    K.hear([L.bed([(2, .am7), (6, .am7), (10, .am7), (14, .am7)], bass: L.n([(2, 33), (6, 33), (10, 40), (14, 33)]))],
                           ["Fits", "Clashes"], 0, "A and its fifth E. Both are in the chord.", bars: 2),
                    K.hear([L.bed([(2, .am7), (6, .am7), (10, .am7), (14, .am7)], bass: L.n([(2, 38), (6, 38), (10, 38), (14, 38)]))],
                           ["Fits", "Clashes"], 1, "D isn't in Am7, so it rubs against the chord.", bars: 2),
                    K.ask("What's the fifth of D?", ["A", "E", "F"], 0, "Count five letters from D: D, E, F, G, A."),
                ]),
                L.bass("Roots under new chords", "Am7 then Em7. Hold each root under its chord.",
                       [NoteEvent(2, 33, 4), NoteEvent(10, 40, 4)],
                       backing: L.bed([(2, .am7), (6, .am7), (10, .em7), (14, .em7)])),
                K.fixNotes("Fix the fifth", "A, then its fifth E. Then D, then its fifth A. One note under Dm7 is a C. Find it.",
                           rows: Curriculum.bassRows, broken: L.n([(2, 33), (6, 40), (10, 36), (14, 45)]),
                           target: L.n([(2, 33), (6, 40), (10, 38), (14, 45)]),
                           backing: L.bed([(2, .am7), (6, .am7), (10, .dm7), (14, .dm7)])),
                L.bassMake("Write a bassline from roots and fifths", "Use at least 5 notes. Stick to A and E under Am7, D and A under Dm7.",
                           backing: L.bed([(2, .am7), (6, .am7), (10, .dm7), (14, .dm7)]), notes: 5),
            ],
            gold: [
                L.gold("four chords, one bassline",
                       "Under a four-chord loop the bass has to follow every change. Hear whether a bass follows, fix two roots that don't, add movement between them, then write your own."),
                K.quiz("Does it follow?", "Four chords: Am7, Cmaj7, Dm7, Em7.", [
                    K.hear([L.bed([(2, .am7), (6, .cmaj7), (10, .dm7), (14, .em7)], bass: L.n([(2, 33), (6, 36), (10, 38), (14, 40)]))],
                           ["Follows the chords", "Stays on A"], 0, "A, C, D, E: a new root for each chord.", bars: 2),
                    K.hear([L.bed([(2, .am7), (6, .cmaj7), (10, .dm7), (14, .em7)], bass: L.n([(2, 33), (6, 33), (10, 33), (14, 33)]))],
                           ["Follows the chords", "Stays on A"], 1, "Low A under everything. It works for a bar, then it drags.", bars: 2),
                ]),
                K.fixNotes("Fix the roots", "Each root holds until the next chord. Two of them don't match their chord. Listen to each change.",
                           rows: Curriculum.bassRows,
                           broken: [NoteEvent(2, 33, 3), NoteEvent(6, 33, 3), NoteEvent(10, 38, 3), NoteEvent(14, 38, 2)],
                           target: [NoteEvent(2, 33, 3), NoteEvent(6, 36, 3), NoteEvent(10, 38, 3), NoteEvent(14, 40, 2)],
                           backing: L.bed([(2, .am7), (6, .cmaj7), (10, .dm7), (14, .em7)])),
                L.bass("Add movement", "The same roots, each followed by a quick note that leads into the next chord.",
                       L.n([(2, 33), (3, 45), (6, 36), (7, 36), (10, 38), (11, 38), (14, 40), (15, 43)]),
                       backing: L.bed([(2, .am7), (6, .cmaj7), (10, .dm7), (14, .em7)]), threshold: 0.9),
                L.bassMake("Make it yours", "Write a bassline that follows all four chords, with at least 8 notes.",
                           backing: L.bed([(2, .am7), (6, .cmaj7), (10, .dm7), (14, .em7)]), notes: 8),
            ])
}
