//
//  F0F1.swift
//  Groova
//
//  Foundation F0, Make Sound Immediately, and F1, Rhythm & Groove.
//

import Foundation

nonisolated enum F0F1 {
    typealias F = FKit

    static let units: [Unit] = [f0, f1]

    // Loops used across both units.
    static let pulseHats = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])
    static let wobbly = Pattern(kick: [0, 5, 7, 14], clap: [3, 11], hat: [1, 6, 9, 15])
    static let busyPerc = Pattern(kick: [0, 4, 8, 12], perc: [3, 6, 7, 11, 14])
    static let busier = Pattern(kick: [0, 4, 8, 12], clap: [2, 10], hat: Array(0..<16), perc: [3, 7, 11, 14, 15])
    static let noKick = Pattern(clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14], perc: [3, 10])
    static let pickup = Pattern(clap: [12, 13, 14, 15])
    static let halfTime = Pattern(kick: [0, 10], clap: [8], hat: [0, 2, 4, 6, 8, 10, 12, 14])
    static let melody = K.tune([(0, 64, 2), (2, 67, 2), (4, 69, 4), (8, 67, 2), (10, 64, 2), (12, 62, 4)])
    static let fullLead = K.melody(melody, over: F.beatBass)

    // MARK: - F0 · Make Sound Immediately

    static let f0 = Unit(id: "f0", number: 0, title: "Make Sound Immediately",
                         subtitle: "Pulse, beat, mood and your first loop", lessons: F0Games.lessons,
                         part: .foundations, code: "F")

    // MARK: - F1 · Rhythm & Groove

    static let f1 = Unit(id: "f1", number: 1, title: "Rhythm & Groove",
                         subtitle: "Beats, subdivision, syncopation and feel", lessons: [f11, f12, f13, f14, f15],
                         part: .foundations, code: "F")

    static let f11 = K.lesson("f1.1", "Find the Beat", "Beat one and the bar", "scope", .rhythm, 15, [
        K.intro("Count to four",
                "Most music counts in fours. One, two, three, four, and around again. Each count of four is a bar, and beat one is where it starts. Beat one usually gets the strongest kick.",
                [], demo: F.full),
        K.tapAlong("Tap all four beats", "The lights show each beat. Lock onto the kick.", loop: F.full, bars: 3),
        K.tapAlong("Now only beat one", "Count in your head and tap only on ONE. That's the downbeat.",
                   loop: F.full, bars: 5, steps: [0], label: "One!", unit: "downbeats"),
        K.quiz("Quick check", "", [
            K.ask("How many beats in a bar of most songs?", ["Two", "Four", "Eight"], 1,
                  "Four. You count 1 2 3 4, then start again."),
            K.ask("On the grid, one bar has 16 steps. Which step is beat 3?", ["Step 3", "Step 9", "Step 12"], 1,
                  "Every beat is four steps: 1, 5, 9, 13. So beat 3 is step 9."),
            K.ask("Beat one is also called…", ["The downbeat", "The offbeat", "The backbeat"], 0,
                  "The downbeat. The backbeat is 2 and 4, where the snare usually goes."),
        ]),
    ])

    static let f12 = K.lesson("f1.2", "Divide Time", "Quarters, eighths and sixteenths", "divide", .rhythm, 15, [
        K.intro("Split the beat",
                "A beat can be split in half (eighth notes) or in quarters (sixteenth notes). Hats usually do the splitting. More splits feel busier and faster, even at the same tempo.",
                [.hat], demo: Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)),
        K.drumRule("Quarter notes", "One hat per beat: steps 1, 5, 9 and 13.",
                   tracks: [.kick, .hat], edit: [.hat], start: Pattern(kick: [0, 8], hat: [0]),
                   target: Pattern(kick: [0, 8], hat: F.quarters)),
        K.drumRule("Eighth notes", "Two hats per beat. Fill in the gaps between the quarters.",
                   tracks: [.kick, .hat], edit: [.hat], start: Pattern(kick: [0, 8], hat: F.quarters),
                   target: Pattern(kick: [0, 8], hat: F.eighths)),
        K.tapAlong("Tap the eighths", "Two taps per beat. Hit the pad on every hat.",
                   loop: Pattern(kick: [0, 8], clap: [4, 12], hat: F.eighths), bars: 3, steps: F.eighths,
                   bpm: 96, unit: "eighths"),
        K.quiz("Count the hats", "How finely are the hats splitting the beat?", [
            K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.quarters)], ["Quarters", "Eighths", "Sixteenths"], 0,
                   "One hat per beat. Calm and steady.", bars: 2),
            K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)], ["Quarters", "Eighths", "Sixteenths"], 2,
                   "Four hats per beat. Busy and driving.", bars: 2),
            K.hear([F.beat], ["Quarters", "Eighths", "Sixteenths"], 1, "Two hats per beat. The most common split.", bars: 2),
        ]),
    ])

    static let f13 = K.lesson("f1.3", "Kick, Snare, Hat", "Three jobs in every kit", "circle.grid.2x2.fill", .rhythm, 15, [
        K.intro("Every drum has a job",
                "The kick is the low weight you feel in your chest. The snare is the crack that marks 2 and 4. The hats are the ticking that keeps the motion going. Learn the jobs and you can build any beat.",
                [.kick, .clap, .hat], demo: F.beat),
        K.quiz("Name the drum", "One drum at a time. Which is it?", [
            K.hear([Pattern(kick: [0, 4, 8, 12])], ["Kick", "Snare", "Hat"], 0, "Low and round. The kick."),
            K.hear([Pattern(clap: [4, 12])], ["Kick", "Snare", "Hat"], 1, "A crack on 2 and 4. The snare."),
            K.hear([Pattern(hat: F.eighths)], ["Kick", "Snare", "Hat"], 2, "Short, bright ticks. Hats."),
        ]),
        K.order("Match each drum to its job", "Tap a drum to hear it and drop it in the next slot.", .rule,
                tiles: [K.tile("Hat", Pattern(hat: F.eighths)), K.tile("Kick", Pattern(kick: [0, 8])),
                        K.tile("Snare", Pattern(clap: [4, 12]))],
                answer: [1, 2, 0], names: ["Low weight", "Crack on 2 & 4", "Ticking"]),
        K.drumRule("Put them together", "Kick on 1 and 3, snare on 2 and 4, hats on every odd step.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], target: F.beat),
    ])

    static let f14 = K.lesson("f1.4", "Move Off the Beat", "Offbeats and syncopation", "arrow.right.to.line", .rhythm, 15, [
        K.intro("Between the beats",
                "Hits on the beat feel solid. Hits between the beats feel like they're pushing forward. Putting sounds in unexpected places is called syncopation, and it's what makes a groove move.",
                [.hat], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: F.offbeats)),
        K.drumRule("Slide the hats off the beat",
                   "Move each hat one step to the right of the kick, onto steps 3, 7, 11 and 15. Hear it start to bounce.",
                   tracks: [.kick, .hat], edit: [.hat], start: Pattern(kick: F.quarters, hat: F.quarters),
                   target: Pattern(kick: F.quarters, hat: F.offbeats)),
        K.tapAlong("Tap the 'and'", "Count 1 and 2 and. Tap only on the 'and', between the kicks.",
                   loop: Pattern(kick: F.quarters, hat: F.offbeats), bars: 4, steps: F.offbeats, label: "And",
                   unit: "offbeats"),
        K.quiz("On or off?", "Listen to the hats. Are they on the beat or between?", [
            K.hear([Pattern(kick: F.quarters, hat: F.quarters)], ["On the beat", "Off the beat"], 0,
                   "Hats with the kicks. Solid, but stiff.", bars: 2),
            K.hear([Pattern(kick: F.quarters, hat: F.offbeats)], ["On the beat", "Off the beat"], 1,
                   "Hats between the kicks. That bounce is everywhere in dance music.", bars: 2),
        ]),
        K.drumRule("Push the kick", "Add a kick on step 8, just before beat 3. It pulls you into the next half.",
                   tracks: [.kick, .clap, .hat], edit: [.kick], start: F.beat,
                   target: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.eighths)),
    ])

    static let f15 = K.lesson("f1.5", "Give It a Feel", "Boss: swing and ghost notes", "crown.fill", .rhythm, 30, [
        K.intro("Boss: give it a feel",
                "Two producers can program the same notes and get different grooves. The difference is feel. Swing delays every second sixteenth so the beat lopes. Ghost notes are quiet extra hits, here on the rim, that fill the gaps.",
                [.perc], demo: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.eighths, perc: [3, 11, 14])),
        K.quiz("Straight or swung?", "Same notes. Does it march or lope?", [
            K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)], ["Straight", "Swung"], 0,
                   "Every hat evenly spaced. Straight.", bars: 2, swing: 0),
            K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)], ["Straight", "Swung"], 1,
                   "Every second hat arrives late. That limp is swing.", bars: 2, swing: 0.3),
        ]),
        K.drumCopy("Copy the groove with ghost notes",
                   "The rim hits are the ghost notes. Find them between the kicks and snares.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .perc], start: Pattern(clap: [4, 12], hat: F.eighths),
                   target: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.eighths, perc: [3, 11, 14])),
        K.swingMake("Now swing it", "Drag swing up until the hats lope. Somewhere past a quarter of the way feels great.",
                    tracks: [.kick, .clap, .hat, .perc],
                    start: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.sixteenths, perc: [3, 11, 14]), atLeast: 0.15),
    ])

    // MARK: - Silver and Gold

    static let levels: [String: LevelPair] = [
        "f1.1": (silver: [
            L.silver("No glow",
                     "Without lights you find beat one by ear. Listen for the strongest kick and the moment the pattern starts over."),
            K.tapAlong("Tap the downbeat", "Only beat one, no lights. The pattern resets on it.",
                       loop: F.groove, bars: 5, steps: [0], guideBars: 0, label: "One!", unit: "downbeats"),
            K.tapAlong("All four, fuller track", "Kick, bass and chords together. Tap every beat.",
                       loop: F.full, bars: 4, guideBars: 0),
            K.quiz("How long is the loop?", "Count bars until it repeats. Listen for the snare roll.", [
                K.hear([F.beat, F.beat, F.beat, F.beat], ["1 bar", "2 bars", "4 bars"], 0, "The same bar every time."),
                K.hear([F.beat, F.fill, F.beat, F.fill], ["1 bar", "2 bars", "4 bars"], 1, "The roll comes every second bar."),
                K.hear([F.beat, F.beat, F.beat, F.fill, F.beat, F.beat, F.beat, F.fill], ["1 bar", "2 bars", "4 bars"], 2,
                       "Three plain bars and a roll. A four-bar loop."),
            ]),
        ], gold: [
            L.gold("Keep counting in the dark",
                   "Real songs often start with a pickup, a few notes before beat one. And sometimes everything stops for a bar. A producer keeps counting through both."),
            K.tapMoments("After the pickup", "A snare pickup leads in. Tap beat one of every bar, even the silent one.",
                         loops: [pickup, F.beat, F.beat, Pattern(), F.beat], barsEach: 1, at: [16, 32, 48, 64],
                         label: "One!", unit: "downbeats", tolerance: 1.5, threshold: 0.75),
            K.tapMoments("Through the gap", "Four beats per bar through all of it, including two silent beats.",
                         loops: [F.beat, Pattern(kick: [0, 4], clap: [4], hat: [0, 2, 4, 6]), F.beat], barsEach: 1,
                         at: Array(stride(from: 0, to: 48, by: 4)), label: "Pulse", unit: "beats", threshold: 0.75),
        ]),
        "f1.2": (silver: [
            L.silver("Rhythms by ear",
                     "Hats rarely play a plain grid. Producers drop one here and double one there. Count in eighths and listen for the gaps."),
            L.copy("Copy the hat pattern", "Mostly eighths, with two extra hats that double up.",
                   tracks: [.kick, .clap, .hat], edit: [.hat], start: F.beatNoHats,
                   target: Pattern(kick: [0, 8], clap: [4, 12], hat: [0, 2, 4, 5, 6, 8, 10, 12, 13, 14])),
            L.copy("Copy the gaps", "This one leaves holes. Which eighths are missing?",
                   tracks: [.kick, .clap, .hat], edit: [.hat], start: F.beatNoHats,
                   target: Pattern(kick: [0, 8], clap: [4, 12], hat: [0, 2, 6, 8, 10, 14])),
            K.tapAlong("Eighths without lights", "Two taps per beat. Lights for one bar only.",
                       loop: F.beat, bars: 3, steps: F.eighths, guideBars: 1, bpm: 96, unit: "eighths"),
        ], gold: [
            L.gold("Busier or calmer",
                   "Subdivision is an energy dial. The same beat can feel calm with quarters or urgent with sixteenths. Producers ride that dial through a track."),
            K.quiz("Which has more energy?", "Same tempo both times.", [
                K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.quarters), Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)],
                       ["The first", "The second"], 1, "Sixteenths feel urgent, though the tempo didn't change."),
                K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.eighths, openHat: [2, 6, 10, 14]), Pattern(kick: [0, 8], clap: [4, 12], hat: F.quarters)],
                       ["The first", "The second"], 0, "Eighths plus open hats beat plain quarters."),
            ]),
            L.make("Make it busier", "Start from the basic beat. Add hats until it drives. At least ten.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.hat, .openHat], start: F.beat, goal: .atLeast(.hat, 10)),
            K.tapAlong("Eighths, no lights", "Hold the eighths for four bars at 100 BPM.",
                       loop: Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths), bars: 5, steps: F.eighths, guideBars: 0,
                       bpm: 100, unit: "eighths"),
        ]),
        "f1.3": (silver: [
            L.silver("Groove doctor",
                     "When a beat feels wrong, the fastest fix is to check each drum's job. Is the kick heavy where it should be? Is the snare on 2 and 4? Are the hats steady?"),
            K.fix("Fix this groove", "One snare is in the wrong place and a hat is missing. Find both.",
                  tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                  broken: Pattern(kick: [0, 8], clap: [6, 12], hat: [0, 2, 4, 6, 10, 12, 14]), target: F.beat, guide: false),
            K.quiz("What's missing?", "The full beat, then the same beat with one drum gone.", [
                K.hear([F.beat, Pattern(kick: [0, 8], hat: F.eighths)], ["Kick", "Snare", "Hats"], 1, "No crack on 2 and 4."),
                K.hear([F.beat, F.beatNoHats], ["Kick", "Snare", "Hats"], 2, "The ticking stopped."),
                K.hear([F.beat, Pattern(clap: [4, 12], hat: F.eighths)], ["Kick", "Snare", "Hats"], 0, "The weight disappeared."),
            ]),
            L.copy("Copy this groove", "The kick moves a lot here. The snare and hats keep their jobs.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                   target: Pattern(kick: [0, 3, 8, 11], clap: [4, 12], hat: F.eighths)),
        ], gold: [
            L.gold("One kit, two moods",
                   "The same three drums can sound driving or laid back. It's all in where you put them. Make both."),
            L.make("Groove 1: driving", "Push it forward. Kicks on every beat or more, busy hats.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat], goal: .atLeast(.kick, 4)),
            L.make("Groove 2: laid back", "Fewer kicks, maybe the snare only on beat 3, space between hits. Use at least four hats.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat], goal: .atLeast(.hat, 4)),
            K.quiz("Name the mood", "Which word fits each groove?", [
                K.hear([halfTime], ["Driving", "Laid back"], 1, "One snare per bar halves the feel.", bars: 2),
                K.hear([Pattern(kick: F.quarters, clap: [4, 12], hat: F.sixteenths)], ["Driving", "Laid back"], 0,
                       "Four kicks and sixteenth hats push hard.", bars: 2),
            ]),
        ]),
        "f1.4": (silver: [
            L.silver("Syncopation by ear",
                     "Syncopated rhythms trip you up the first time and hook you the second. Count steps in fours and listen for which hits land between the beats."),
            L.copy("Copy the syncopated kick", "Four kicks. Only the first is on a beat.",
                   tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: F.eighths),
                   target: Pattern(kick: [0, 3, 6, 10], clap: [4, 12], hat: F.eighths)),
            K.tapAlong("Tap the rhythm", "Tap with the kick: 1, then three hits between beats.",
                       loop: Pattern(kick: [0, 3, 6, 10], clap: [4, 12], hat: F.eighths), bars: 4, steps: [0, 3, 6, 10],
                       guideBars: 1, bpm: 96, label: "Kick", unit: "kicks", sound: .kick),
            K.quiz("Which is syncopated?", "One has hits between the beats.", [
                K.hear([Pattern(kick: F.quarters, clap: [4, 12]), Pattern(kick: [0, 3, 6, 10], clap: [4, 12])],
                       ["The first", "The second"], 1, "The second kick pattern dodges the beats."),
                K.hear([Pattern(kick: [0, 8], clap: [4, 11, 14]), Pattern(kick: [0, 8], clap: [4, 12])],
                       ["The first", "The second"], 0, "The snares in the first land just off the beat."),
            ]),
        ], gold: [
            L.gold("Counter-rhythm",
                   "A counter-rhythm fills the gaps another part leaves, like two people finishing each other's sentences. You'll write a rim part that interlocks with a beat."),
            L.make("Write a counter-rhythm",
                   "Add a rim part that lands between the kicks and snares, never on top of them. At least three hits.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: F.beat, goal: .atLeast(.perc, 3)),
            K.tapAlong("Offbeats, no lights", "Tap only on the 'and' for four bars.",
                       loop: F.beat, bars: 5, steps: F.offbeats, guideBars: 0, label: "And", unit: "offbeats"),
            L.copy("Copy this interlocking groove", "Kick and rim never land together. Find the rim.",
                   tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 6, 8], clap: [4, 12]),
                   target: Pattern(kick: [0, 6, 8], clap: [4, 12], perc: [3, 10, 14])),
        ]),
        "f1.5": (silver: [
            L.silver("Feel by ear",
                     "Now copy feel from a reference: where the ghost notes sit and how much swing there is."),
            L.copy("Copy this groove", "Rim ghost notes plus an accent kick. Listen for the quiet hits.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .perc], start: Pattern(clap: [4, 12], hat: F.eighths),
                   target: Pattern(kick: [0, 10], clap: [4, 12], hat: F.eighths, perc: [2, 7, 13, 15])),
            K.quiz("How much swing?", "None, a little, or a lot?", [
                K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)], ["None", "A little", "A lot"], 2, "Heavy swing.", bars: 2, swing: 0.35),
                K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)], ["None", "A little", "A lot"], 0, "Dead straight.", bars: 2, swing: 0),
                K.hear([Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)], ["None", "A little", "A lot"], 1, "Just a touch.", bars: 2, swing: 0.12),
            ]),
            K.swingMake("Swing the new groove", "Go further this time, to about a third of the way.",
                        tracks: [.kick, .clap, .hat, .perc],
                        start: Pattern(kick: [0, 10], clap: [4, 12], hat: F.sixteenths, perc: [2, 7, 13, 15]), atLeast: 0.3),
        ], gold: [
            L.gold("Two feels, same notes",
                   "Pros reuse one pattern and change only the feel: tight for an intro, loose and swung for the main part. Build two feels from one set of notes."),
            K.swingMake("Feel A: just a touch", "Barely there. Enough to soften the hats.",
                        tracks: [.kick, .clap, .hat], start: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.sixteenths), atLeast: 0.08),
            L.make("Feel B: ghost notes", "Same kick and snare. Add rim ghost notes to make it lope. At least four.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.perc, .hat],
                   start: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.eighths), goal: .atLeast(.perc, 4)),
            K.swingMake("Then swing feel B hard", "Push swing well past a third.",
                        tracks: [.kick, .clap, .hat, .perc],
                        start: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.sixteenths, perc: [3, 6, 11, 14]), atLeast: 0.35),
        ]),
    ]
}
