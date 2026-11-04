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
    static func bed(_ chords: [(Int, ChordShape)], length: Int = 1) -> Pattern {
        Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14],
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
                         "Four on the floor is the base, but producers add pickups: an extra kick just before a beat that pushes the groove forward. These grooves keep all four kicks and add pickups in new places. There's no beat guide from here on."),
                L.copy("Hear the pickup, then copy it", "Four on the floor, plus one kick on the very last step.",
                       tracks: [.kick, .hat], edit: [.kick], start: offHats,
                       target: Pattern(kick: [0, 4, 8, 12, 15], hat: [2, 6, 10, 14])),
                L.copy("Two pickups this time", "One kick pushes into beat 3, another into the next bar.",
                       tracks: [.kick, .hat], edit: [.kick], start: offHats,
                       target: Pattern(kick: [0, 4, 7, 8, 12, 14], hat: [2, 6, 10, 14])),
                L.make("Write a kick with your own pickups", "Keep all four beats and add at least two pickups.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       goal: .atLeast(.kick, 6)),
            ],
            gold: [
                L.gold("what the kick leaves out",
                       "Taking kicks away is as powerful as adding them. Half-time kicks feel slower without changing tempo, rolling kicks feel urgent, and every track drops the kick somewhere. Hear each one, then rebuild a full groove."),
                L.copy("Half-time: copy this kick", "Only two kicks. It feels half as fast, but the tempo hasn't changed.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [8], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 10], clap: [8], hat: [2, 6, 10, 14]), threshold: 0.9),
                L.copy("Rolling kick: copy it", "Four on the floor with an extra kick just before beats 2 and 4.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 3, 4, 8, 11, 12], clap: [4, 12], hat: [2, 6, 10, 14]), threshold: 0.9),
                L.copy("Rebuild the whole groove", "Get the kick first, then the clap, then the hats.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                       target: Pattern(kick: [0, 4, 8, 12, 14], clap: [4, 12], hat: [2, 6, 10, 14]), threshold: 0.9),
                L.make("Make it yours", "Write a peak-time kick with pickups and gaps. Use at least 7 kicks.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: [2, 6, 10, 14]),
                       goal: .atLeast(.kick, 7)),
            ])

    static let u1l2: Pair = (
            silver: [
                L.silver("ghost claps",
                         "Claps on 2 and 4 are the backbone. Ghost claps are extra hits around them that make the groove talk back. Every groove here keeps 2 and 4 and hides a ghost somewhere new."),
                L.copy("Find the ghost clap", "2 and 4 are there. One extra clap lands just before beat 4.",
                       tracks: [.kick, .clap], edit: [.clap], start: Curriculum.fourFloor,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 11, 12])),
                L.copy("Two ghosts", "One answers beat 2, the other leads into the next bar.",
                       tracks: [.kick, .clap, .hat], edit: [.clap], start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 7, 12, 15], hat: [2, 6, 10, 14])),
                L.make("Write a clap part with ghosts", "Keep 2 and 4 and add at least two ghost claps.",
                       tracks: [.kick, .clap, .hat], edit: [.clap], start: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14]),
                       goal: .atLeast(.clap, 4)),
            ],
            gold: [
                L.gold("move the backbeat",
                       "Where the clap lands sets the whole feel. On 2 and 4 it's house. On beat 3 alone it's half-time. Swung ghost claps push toward garage. Hear each one, then build a full groove from nothing."),
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
                         "Offbeat open hats give house its lift. Closed hats on the 16ths in between add speed. These grooves fill in more of the gaps."),
                L.copy("Copy the closed hats", "Open hats stay on the offbeats. Closed hats tick on every step in between the beats and the offbeats.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                       openHat: [2, 6, 10, 14])),
                L.copy("Hats everywhere but the open hat", "Closed hats on every 16th, except where the open hat plays.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat, .openHat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15],
                                       openHat: [2, 6, 10, 14])),
                L.make("Write a fast hat part", "Use at least 8 closed hats and leave room for the open hats.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14]),
                       goal: .atLeast(.hat, 8)),
            ],
            gold: [
                L.gold("hats that groove",
                       "Hats carry the swing and the energy. Shuffled 16ths feel human, sparse hats feel deep, and percussion fills the holes. Rebuild full kits, hats and all."),
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
                L.make("Make it yours", "Write closed hats, open hats and rims. Use at least 6 closed hats.",
                       tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .openHat, .perc],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 6)),
            ])

    static let u1l4: Pair = (
            silver: [
                L.silver("octaves and note length",
                         "The same note an octave higher sounds brighter but still fits. Length matters too: short notes bounce, long notes groove. These basslines use both."),
                L.bass("Copy the octave bounce", "Low A and high A take turns on the offbeats.",
                       L.n([(2, 33), (6, 45), (10, 33), (14, 45)]), backing: drums),
                L.bass("Short and long notes", "Some notes hold for two steps. Drag a note's edge to make it longer.",
                       [NoteEvent(2, 33, 2), NoteEvent(6, 36), NoteEvent(7, 38), NoteEvent(10, 33, 2), NoteEvent(14, 40, 2)],
                       backing: drums),
                L.bassMake("Write a bassline with an octave jump", "Use at least 6 notes, including both the low A and the high A.",
                           backing: drums, notes: 6),
            ],
            gold: [
                L.gold("16th-note bass",
                       "Rolling 16th basslines drive peak-time house. Notes just before or after the offbeat create a gallop, and passing notes walk between them."),
                L.bass("Copy the rolling bass", "Pairs of notes around each offbeat. The pitch climbs in the second half.",
                       L.n([(2, 33), (3, 33), (6, 33), (7, 36), (10, 38), (11, 38), (14, 40), (15, 43)]),
                       backing: drums, threshold: 0.9),
                L.bass("Passing notes", "Every offbeat is low A. The note straight after each one walks up the scale.",
                       L.n([(2, 33), (3, 36), (6, 33), (7, 38), (10, 33), (11, 40), (14, 33), (15, 43)]),
                       backing: drums, threshold: 0.9),
                L.bassMake("Make it yours", "Write a rolling bassline with at least 8 notes.", backing: drums, notes: 8),
            ])

    static let u1l5: Pair = (
            silver: [
                L.silver("resonance",
                         "Cutoff decides how much top end gets through. Resonance adds a peak right at the cutoff, which you hear as a whistle or squelch. Now you match both."),
                K.filterMatch("Match the dull sound", "Just a little top end removed, almost no resonance.",
                              cutoff: 2800, resonance: 0.1, Curriculum.fxLoop),
                K.filterMatch("Match the squelch", "Cutoff low, resonance high. Listen for the whistle.",
                              cutoff: 450, resonance: 0.8, Curriculum.fxLoop),
                K.filterMatch("Match the telephone", "Thin and boxy. Cutoff in the middle with a little resonance.",
                              cutoff: 1200, resonance: 0.45, Curriculum.fxLoop),
            ],
            gold: [
                L.gold("filter one sound",
                       "Producers filter single parts as much as the whole mix. Shape a chord's brightness and length, then match tough filter settings where the difference is small."),
                K.lab("Match the dark chord", "Turn down its brightness and let it ring.",
                      [.chordCutoff, .chordDecay], start: [0.7, 0.3], target: [0.2, 0.7], loop: Curriculum.fxLoop),
                K.lab("Match the bright pluck", "Bright, instant and short.",
                      [.chordCutoff, .chordDecay, .chordAttack], start: [0.3, 0.6, 0.5], target: [0.8, 0.15, 0.0],
                      loop: Curriculum.fxLoop),
                K.filterMatch("Match a subtle filter", "A small difference. Compare Reference and Yours carefully.",
                              cutoff: 5000, resonance: 0.3, Curriculum.fxLoop),
                K.filterMatch("Match the deep, resonant filter", "Very dark with a strong peak.",
                              cutoff: 300, resonance: 0.65, Curriculum.fxLoop),
            ])

        // MARK: Unit 2

    static let u2l1: Pair = (
            silver: [
                L.silver("more chords",
                         "Every major and minor chord has the same recipe: a root, a third and a fifth. Build new ones, hear the difference, and use two in a groove."),
                K.build("Build C major", "C, E and G. Compare it with A minor: two notes are shared.", .c),
                K.build("Build E minor", "E, G and B.", .em),
                K.quiz("Happy or moody?", "New chords this time.", [
                    K.round([.dm], moody, 1, "D minor."),
                    K.round([f], moody, 0, "F major."),
                    K.round([g], moody, 0, "G major."),
                    K.round([.em], moody, 1, "E minor."),
                ]),
                K.lane("A minor on beat 1, C on beat 3", "Pick each chord, then place it.", .rule,
                       palette: [.am, .c], backing: drums, target: [0: 0, 8: 1], length: 4),
            ],
            gold: [
                L.gold("three-chord moves",
                       "Major and minor chords take turns in almost every song. Build them with no help, name them by ear, and recreate a three-chord groove."),
                K.build("Build D minor", "D, F and A. No starting notes.", .dm),
                K.build("Build G major", "G, B and D.", g),
                K.quiz("Major or minor?", "Five chords, one after another.", [
                    K.round([.c], moody, 0), K.round([.em], moody, 1), K.round([f], moody, 0),
                    K.round([.am], moody, 1), K.round([g], moody, 0),
                ]),
                K.lane("Recreate this three-chord groove", "Am, then C, then G. Listen for where each one starts.", .recreate,
                       palette: [.am, .c, g], backing: drums, target: [0: 0, 6: 1, 10: 2], length: 4),
            ])

    static let u2l2: Pair = (
            silver: [
                L.silver("7ths on new roots",
                         "The minor 7th recipe works from any root: root, minor third, fifth and minor seventh. Build it from scratch on new notes."),
                K.build("Build Em7", "E, G, B and D.", .em7),
                K.quiz("Plain or 7th?", "New chords this time.", [
                    K.round([.dm7], ["Plain (3 notes)", "7th (4 notes)"], 1, "Dm7."),
                    K.round([.em], ["Plain (3 notes)", "7th (4 notes)"], 0, "Plain E minor."),
                    K.round([.dm], ["Plain (3 notes)", "7th (4 notes)"], 0, "Plain D minor."),
                    K.round([.am7], ["Plain (3 notes)", "7th (4 notes)"], 1, "Am7."),
                ]),
                K.build("Build Gm7", "G, B♭, D and F. The black key is the minor third.", .gm7),
            ],
            gold: [
                L.gold("major 7ths",
                       "There are two kinds of 7th. Minor 7ths sound moody. Major 7ths sound warm and dreamy. Deep house lives on both, so learn to build and hear each."),
                K.build("Build Fmaj7", "F, A, C and E.", .fmaj7),
                K.build("Build Cmaj7", "C, E, G and B.", .cmaj7),
                K.quiz("Major 7th or minor 7th?", "Warm or moody?", [
                    K.round([.fmaj7], ["Major 7th (warm)", "Minor 7th (moody)"], 0),
                    K.round([.am7], ["Major 7th (warm)", "Minor 7th (moody)"], 1),
                    K.round([.cmaj7], ["Major 7th (warm)", "Minor 7th (moody)"], 0),
                    K.round([.dm7], ["Major 7th (warm)", "Minor 7th (moody)"], 1),
                    K.round([.em7], ["Major 7th (warm)", "Minor 7th (moody)"], 1),
                ]),
                K.lane("Hear the moody-to-warm swap", "Two stabs of one chord, then two of the other.", .recreate,
                       palette: [.am7, .fmaj7], backing: drums, target: [2: 0, 6: 0, 10: 1, 14: 1]),
            ])

    static let u2l3: Pair = (
            silver: [
                L.silver("stab rhythm",
                         "Where you place stabs is a rhythm part of its own. Stabs on the 16ths around the offbeat feel funky. Stabs that hold for longer feel lush."),
                K.lane("Copy the funky stabs", "Pairs of stabs around the offbeats.", .recreate,
                       palette: [.am7], backing: drums, target: [2: 0, 3: 0, 7: 0, 10: 0, 11: 0, 15: 0]),
                K.lane("Copy the longer stabs", "Each stab holds for two steps. The last one comes a step early.", .recreate,
                       palette: [.am7], backing: drums, target: [2: 0, 6: 0, 10: 0, 13: 0], length: 2),
                K.lane("Write stabs with at least six hits", "Mix single stabs and pairs.", .create(.chordsAtLeast(6)),
                       palette: [.am7], backing: drums),
            ],
            gold: [
                L.gold("stab riffs",
                       "Real stab riffs swap chords on the offbeats. Hear which chord lands where, then write your own riff."),
                K.lane("Copy the two-chord riff", "Mostly Am7, with Em7 in the middle of the bar.", .recreate,
                       palette: [.am7, .em7], backing: drums, target: [2: 0, 6: 0, 9: 1, 10: 1, 14: 0]),
                K.lane("Copy the pushed riff", "Am7 then Dm7. The last stab comes a step before the bar loops.", .recreate,
                       palette: [.am7, .dm7], backing: drums, target: [1: 0, 3: 0, 6: 0, 10: 1, 15: 1]),
                K.lane("Make it yours", "Write a stab riff with at least six stabs and at least two chords.",
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
                ]),
                K.lane("Recreate this progression", "Three chords. It ends back home on Am7.", .recreate,
                       palette: [.am7, .dm7, .em7], backing: drums, target: [2: 0, 6: 2, 10: 1, 14: 0]),
            ],
            gold: [
                L.gold("four-chord loops",
                       "The four-chord loop is the backbone of piano house. Learn to hear the whole Am7, Fmaj7, Dm7, Em7 family and where each one sits."),
                K.lane("Recreate the four-chord loop", "Every chord plays once.", .recreate,
                       palette: [.am7, .dm7, .em7, .fmaj7], backing: drums, target: [2: 0, 6: 3, 10: 1, 14: 2]),
                K.quiz("How does it end?", "Four chords play. Listen to where they finish.", [
                    K.round([.am7, .fmaj7, .dm7, .em7], ["Ends on Em7", "Ends on Am7"], 0),
                    K.round([.am7, .dm7, .em7, .am7], ["Ends on Em7", "Ends on Am7"], 1),
                    K.round([.fmaj7, .em7, .dm7, .am7], ["Ends on Em7", "Ends on Am7"], 1),
                ]),
                K.lane("Recreate the syncopated riff", "Same four chords, but two stabs land early.", .recreate,
                       palette: [.am7, .dm7, .em7, .fmaj7], backing: drums, target: [0: 0, 3: 0, 6: 3, 10: 1, 13: 2]),
                K.lane("Make it yours", "Write a loop with at least four stabs and at least three different chords.",
                       .create(.chordsAtLeast(4)), palette: [.am7, .dm7, .em7, .fmaj7], backing: drums),
            ])

    static let u2l5: Pair = (
            silver: [
                L.silver("roots and fifths",
                         "The root anchors the chord. The fifth (E for A, A for D) is the next safest note. Mixing the two makes a bassline move without clashing."),
                L.bass("Roots under new chords", "Am7 then Em7. Hold each root under its chord.",
                       [NoteEvent(2, 33, 4), NoteEvent(10, 40, 4)],
                       backing: L.bed([(2, .am7), (6, .am7), (10, .em7), (14, .em7)])),
                L.bass("Roots and fifths", "A, then its fifth E. Then D, then its fifth A.",
                       L.n([(2, 33), (6, 40), (10, 38), (14, 45)]),
                       backing: L.bed([(2, .am7), (6, .am7), (10, .dm7), (14, .dm7)])),
                L.bassMake("Write a bassline from roots and fifths", "Use at least 5 notes. Stick to A and E under Am7, D and A under Dm7.",
                           backing: L.bed([(2, .am7), (6, .am7), (10, .dm7), (14, .dm7)]), notes: 5),
            ],
            gold: [
                L.gold("four chords, one bassline",
                       "Under a four-chord loop the bass has to follow every change. Find each root by ear, then add movement between them."),
                L.bass("Roots under four chords", "Am7, Cmaj7, Dm7, Em7. Each root holds until the next chord.",
                       [NoteEvent(2, 33, 3), NoteEvent(6, 36, 3), NoteEvent(10, 38, 3), NoteEvent(14, 40, 2)],
                       backing: L.bed([(2, .am7), (6, .cmaj7), (10, .dm7), (14, .em7)]), threshold: 0.9),
                L.bass("Add movement", "The same roots, each followed by a quick note that leads into the next chord.",
                       L.n([(2, 33), (3, 45), (6, 36), (7, 36), (10, 38), (11, 38), (14, 40), (15, 43)]),
                       backing: L.bed([(2, .am7), (6, .cmaj7), (10, .dm7), (14, .em7)]), threshold: 0.9),
                L.bassMake("Make it yours", "Write a bassline that follows all four chords, with at least 8 notes.",
                           backing: L.bed([(2, .am7), (6, .cmaj7), (10, .dm7), (14, .em7)]), notes: 8),
            ])
}
