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
                         subtitle: "Pulse, beat, mood and your first loop", lessons: [f01, f02, f03, f04],
                         part: .foundations, code: "F")

    static let f01 = K.lesson("f0.1", "Tap the Pulse", "Feel the heartbeat of a track", "hand.tap.fill", .rhythm, 15, [
        K.intro("Every track has a heartbeat",
                "It's called the pulse, and you already feel it. It's what your head nods to without asking. Press play and nod along before you touch anything.",
                [], demo: pulseHats),
        K.tapAlong("Tap four beats",
                   "Listen for one bar. Then hit the pad every time a light glows.",
                   loop: pulseHats, bars: 2),
        K.quiz("Steady or not?", "A pulse is even, like a clock. Which of these has one?", [
            K.hear([F.pulse], ["Steady pulse", "No steady pulse"], 0, "Four even kicks. You could set a clock by it.", bars: 2),
            K.hear([wobbly], ["Steady pulse", "No steady pulse"], 1, "The hits land at random spots, so there's nothing to nod to.", bars: 2),
            K.hear([F.beat], ["Steady pulse", "No steady pulse"], 0, "Kick, snare and hats all line up on an even grid.", bars: 2),
        ]),
        K.tapAlong("Keep it going",
                   "Four bars this time. Stay with the lights and let your thumb fall into the groove.",
                   loop: F.beat, bars: 5, label: "Pulse"),
    ])

    static let f02 = K.lesson("f0.2", "Build a Beat", "Kick, snare and hats", "square.grid.3x3.fill", .rhythm, 15, [
        K.intro("Two drums do most of the work",
                "The kick is the low thump. The snare is the crack. Put the kick on beats 1 and 3 and the snare on 2 and 4, and you've got the beat under thousands of songs.",
                [.kick, .clap], demo: F.beatNoHats),
        K.drumRule("Kicks on 1 and 3", "Steps 1 and 9 are beats 1 and 3. Tap them on the kick row.",
                   tracks: [.kick, .clap], edit: [.kick], target: Pattern(kick: [0, 8])),
        K.drumRule("Snares on 2 and 4", "Beats 2 and 4 are steps 5 and 13. Tap them on the snare row.",
                   tracks: [.kick, .clap], edit: [.clap], start: Pattern(kick: [0, 8]), target: F.beatNoHats),
        K.drumRule("Add the hats", "Hats keep things moving. Put one on every odd step: 1, 3, 5, all the way to 15.",
                   tracks: [.kick, .clap, .hat], edit: [.hat], start: F.beatNoHats, target: F.beat),
        K.quiz("Which one is the classic beat?", "One of these has kick on 1 and 3 and snare on 2 and 4.", [
            K.hear([Pattern(kick: [4, 12], clap: [0, 8], hat: F.eighths), F.beat], ["The first", "The second"], 1,
                   "The first one swaps them. It feels backwards, like it's tripping over itself."),
            K.hear([F.beat, Pattern(kick: [0, 4, 8, 12], hat: F.eighths)], ["The first", "The second"], 0,
                   "The second has no snare, so there's no crack on 2 and 4."),
        ]),
    ])

    static let f03 = K.lesson("f0.3", "Change the Feeling", "Chords set the mood", "theatermasks.fill", .theory, 15, [
        K.intro("Same beat, different feeling",
                "Chords are several notes played together, and they decide how a track feels. Some sound bright and hopeful. Others sound dark and moody. Listen to this loop flip between the two.",
                [], demo: F.beat.merged(with: K.halves(F.c, F.am))),
        K.quiz("Bright or dark?", "Hear each chord and go with your gut.", [
            K.round([F.c], ["Bright", "Dark"], 0, "C major. Open and sunny."),
            K.round([F.am], ["Bright", "Dark"], 1, "A minor. A little sad, a little moody."),
            K.round([F.f], ["Bright", "Dark"], 0, "F major. Warm and bright."),
            K.round([F.em], ["Bright", "Dark"], 1, "E minor. Dark and thoughtful."),
        ]),
        K.quiz("Which loop feels hopeful?", "Two loops, same drums. Only the chords change.", [
            K.hear([F.beat.merged(with: K.halves(F.c, F.g)), F.beat.merged(with: K.halves(F.am, F.em))],
                   ["The first", "The second"], 0, "C and G are major chords. Am and Em are minor, so they sound darker.",
                   bars: 2),
            K.hear([F.beat.merged(with: K.halves(F.dm, F.am)), F.beat.merged(with: K.halves(F.f, F.c))],
                   ["The first", "The second"], 1, "Dm and Am are minor. F and C are major and lift the mood.", bars: 2),
        ]),
        K.lane("Pick your mood",
               "Tap a chord, then tap steps to place it. Try bright chords first, then swap in dark ones and hear the mood flip.",
               .create(.chordsAtLeast(2)), palette: [F.c, F.am, F.f, F.em], backing: F.beat, length: 6),
    ])

    static let f04 = K.lesson("f0.4", "My First Loop", "Boss: drums, bass and melody", "crown.fill", .arrangement, 30, [
        K.intro("Boss: your first loop",
                "Three layers make a loop. Drums keep time, bass gives it weight, and a melody gives you something to hum. Stack them one at a time.",
                [], demo: fullLead),
        K.drumRule("Lay down the beat", "Kick on 1 and 3, snare on 2 and 4. The hats are already there.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap], start: Pattern(hat: F.eighths), target: F.beat),
        K.bassRule("Add the bass", "Follow the lit notes. Each one lands between or with the kicks.",
                   rows: F.bassRows, target: F.bassline, backing: F.beat),
        K.leadRule("Add the melody", "Place the notes to match the outline. It rises, then falls back down.",
                   rows: F.leadRows, target: melody, backing: F.beatBass),
        K.arrange("Hear it build", "Switch on one more layer in each section: drums, then bass, then melody.", .rule,
                  sections: ["Drums", "+ Bass", "+ Melody"], lanes: [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords],
                  loop: fullLead, target: K.grid("xxx", "xxx", "xxx", "-xx", "--x")),
    ])

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
        "f0.1": (silver: [
            L.silver("Lights out",
                     "Bronze gave you lights the whole way. Now they glow for one bar, then it's on you. Count 1 2 3 4 in your head and keep tapping."),
            K.tapAlong("Tap eight beats", "One bar with lights, then two without.", loop: pulseHats, bars: 3, guideBars: 1),
            K.tapAlong("Slow it down", "Same idea at a relaxed 80 BPM. Slower is harder than it sounds. Don't rush.",
                       loop: F.beat, bars: 3, guideBars: 1, bpm: 80),
            K.tapAlong("Speed it up", "128 BPM, dance-floor speed. Stay light on the pad.",
                       loop: F.beat, bars: 3, guideBars: 1, bpm: 128),
        ], gold: [
            L.gold("Don't get pulled",
                   "Real tracks have a dozen sounds fighting for attention. Halfway through, busy percussion joins to pull you off the beat. Stay locked on the pulse."),
            K.tapMoments("Hold the pulse", "No lights. The kick stays steady. Everything else is a distraction.",
                         loops: [F.pulse, busyPerc, busier], barsEach: 2, at: Array(stride(from: 16, to: 96, by: 4)),
                         label: "Pulse", unit: "beats"),
            K.tapAlong("Find it with no kick",
                       "There's no kick at all. The pulse is still there in the snare and hats. Feel it and tap all four beats.",
                       loop: noKick, bars: 4, guideBars: 0),
            K.tapAlong("Backbeat only", "Tap only beats 2 and 4, with the snare. That's the backbeat.",
                       loop: F.beat, bars: 5, steps: [4, 12], guideBars: 0, label: "Snare", unit: "snares"),
        ]),
        "f0.2": (silver: [
            L.silver("Build it by ear",
                     "No step numbers this time. Listen, count where each drum lands, and build it yourself."),
            L.copy("Copy this beat", "The kick plays three times. One of them sneaks in just before beat 3.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap], start: Pattern(hat: F.eighths), target: F.groove),
            K.fix("One drum is out of place", "Play the reference, then yours. Something lands a step late.",
                  tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                  broken: Pattern(kick: [0, 9], clap: [4, 12], hat: F.eighths), target: F.beat, guide: false),
            L.copy("Copy a half-time beat",
                   "The snare only hits once, on beat 3. It makes the same tempo feel twice as slow and heavy.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap], start: Pattern(hat: F.eighths), target: halfTime),
        ], gold: [
            L.gold("Your beat",
                   "Every producer starts from the same kick and snare, then adds the details that make it theirs. First train your ear for those details."),
            K.quiz("What changed?", "Basic beat first, then a version with one change.", [
                K.hear([F.beat, F.groove], ["Extra kicks", "Extra snares", "The hats"], 0, "Two extra kicks, before and after beat 3."),
                K.hear([F.beat, F.fill], ["Extra kicks", "Extra snares", "The hats"], 1, "A snare roll at the end of the bar. That's a fill."),
                K.hear([F.beat, Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)], ["Extra kicks", "Extra snares", "The hats"], 2,
                       "The hats doubled up to sixteenths."),
            ]),
            L.make("Make your main beat",
                   "Start from the basic beat. Add kicks, change the hats, make it yours. Keep a snare on 2 and 4 so it still hits.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat], start: F.beat,
                   goal: .atLeast(.kick, 3)),
            L.make("Now its fill bar",
                   "Every few bars, a beat changes to announce what's next. Add snares near the end of the bar to build your fill version.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat], start: F.beat,
                   goal: .atLeast(.clap, 4)),
        ]),
        "f0.3": (silver: [
            L.silver("Harmony or drums?",
                     "Producers hear a track as layers. When something changes, you should know which layer moved. Chords are harmony. Drums are rhythm."),
            K.quiz("What changed?", "The first loop plays, then a second with one change. Or no change at all.", [
                K.hear([F.beat.merged(with: K.bar(F.c)), F.beat.merged(with: K.bar(F.am))], ["The chords", "The drums", "Nothing"], 0,
                       "Same beat. The chord went from C to Am, bright to dark."),
                K.hear([F.beat.merged(with: K.bar(F.c)), F.groove.merged(with: K.bar(F.c))], ["The chords", "The drums", "Nothing"], 1,
                       "Same chord. The kick pattern got busier."),
                K.hear([F.beat.merged(with: K.bar(F.f)), F.beat.merged(with: K.bar(F.f))], ["The chords", "The drums", "Nothing"], 2,
                       "Identical. Good producers can tell when nothing changed too."),
                K.hear([F.beat.merged(with: K.bar(F.g)), F.beat.merged(with: K.bar(F.em))], ["The chords", "The drums", "Nothing"], 0,
                       "G to Em. The chord darkened while the beat stayed put."),
            ]),
            K.quiz("Bright or dark?", "New chords. Trust your gut.", [
                K.round([F.d], ["Bright", "Dark"], 0, "D major."),
                K.round([F.gm], ["Bright", "Dark"], 1, "G minor."),
                K.round([F.e], ["Bright", "Dark"], 0, "E major."),
                K.round([F.dm], ["Bright", "Dark"], 1, "D minor."),
                K.round([F.a], ["Bright", "Dark"], 0, "A major."),
            ]),
            K.lane("Copy this two-chord loop",
                   "One chord starts the bar, another starts halfway. Is each one bright or dark?", .recreate,
                   palette: [F.c, F.am, F.f, F.g], backing: F.beat, target: [0: 2, 8: 1], length: 6),
        ], gold: [
            L.gold("Change one chord",
                   "Swap a single chord and the whole loop tells a different story. Hear it, then make the swap yourself."),
            K.quiz("Does it feel finished?", "Three chords play. Does the last one feel like home?", [
                K.round([F.f, F.g, F.c], ["Finished", "Unfinished"], 0, "G pulls straight home to C."),
                K.round([F.f, F.g, F.am], ["Finished", "Unfinished"], 1, "Am where you expected C. A twist, not an ending."),
                K.round([F.c, F.f, F.g], ["Finished", "Unfinished"], 1, "Ending on G leaves you hanging. It wants to go home."),
            ]),
            K.order("Pick the last chord",
                    "The first three chords are set. Try every option in the last slot and keep the one that feels the way you want.",
                    .create(.chordsAtLeast(4)),
                    tiles: [K.tile("C", F.chordBar(F.c, root: 36)), K.tile("G", F.chordBar(F.g, root: 43)),
                            K.tile("Am", F.chordBar(F.am, root: 45)), K.tile("F", F.chordBar(F.f, root: 41)),
                            K.tile("Em", F.chordBar(F.em, root: 40), "Dark"), K.tile("Dm", F.chordBar(F.dm, root: 38), "Dark")],
                    slots: 4, start: [0, 1, 2], locked: [0, 1, 2]),
            K.lane("Write the dark version",
                   "Rewrite the loop to feel tense or moody. Lean on Am, Em and Dm, and use at least four stabs.",
                   .create(.chordsAtLeast(4)), palette: [F.c, F.am, F.em, F.dm, F.f], backing: F.beat, length: 3),
        ]),
        "f0.4": (silver: [
            L.silver("Swap a part",
                     "Your loop works. Now replace parts of it with your own ideas, one layer at a time."),
            K.quiz("Which layer changed?", "The loop plays twice. One layer is different the second time.", [
                K.hear([fullLead, K.melody(melody, over: F.beat.merged(with: Pattern(bass: [NoteEvent(0, 36, 8), NoteEvent(8, 41, 8)])))],
                       ["Drums", "Bass", "Melody"], 1, "The bass became two long notes."),
                K.hear([fullLead, K.melody(melody, over: F.groove.merged(with: Pattern(bass: F.bassline)))],
                       ["Drums", "Bass", "Melody"], 0, "Extra kicks around beat 3."),
                K.hear([fullLead, K.melody(K.tune([(0, 72, 2), (2, 69, 2), (4, 67, 4), (8, 64, 4), (12, 60, 4)]), over: F.beatBass)],
                       ["Drums", "Bass", "Melody"], 2, "The melody starts high and walks down instead."),
            ]),
            K.bassMake("Write your own bassline", "Keep the beat. Place at least four bass notes, mostly between the kicks.",
                       rows: F.bassRows, backing: F.beat, notes: 4),
            K.leadMake("Write a new melody", "Over the beat and bass. Use at least five notes. Repeating a note is allowed.",
                       rows: F.leadRows, backing: F.beatBass, notes: 5),
        ], gold: [
            L.gold("Version B",
                   "Most tracks have an A part and a B part. Same key, same tempo, but B changes enough to keep you listening. Build version B, then arrange both."),
            L.make("Beat for version B", "Change the drums for B. More kicks, different hats, an open hat, your call.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat], start: F.beat,
                   goal: .atLeast(.kick, 4)),
            K.leadMake("Melody for version B", "Keep the first notes and write a new second half. At least six notes in total.",
                       rows: F.leadRows, backing: F.beatBass, notes: 6, start: Array(melody.prefix(3))),
            K.arrange("Arrange A and B", "Four sections. Each must play something, and no two neighbours can match.",
                      .create(.variedSections), sections: ["A", "B", "A", "B"], lanes: F.lanes, loop: F.full),
        ]),
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
