//
//  CoreCourse.swift
//  Groova
//
//  Part 1, Core Foundations: eight units every producer needs, shared by every genre.
//  Progress here counts once, whichever genre you're learning. Some lessons were first written
//  for House and keep their ids, so progress and hand-written levels carry over.
//
//  1 Welcome to Production   2 Rhythm Basics      3 Groove & Feel     4 Notes & Melody
//  5 Chords & Harmony        6 Sound Design       7 Mixing Basics     8 Arrangement & Finishing
//

import Foundation

nonisolated enum CoreCourse {
    static let units: [Unit] = [unit1, unit2, unit3, unit4, unit5, unit6, unit7, unit8]

    /// Lessons first written for House, reused here.
    private static func house(_ ids: String...) -> [Lesson] {
        Curriculum.lessons(ids, from: Curriculum.houseUnits)
    }

    // MARK: Shared loops

    static let rows = Curriculum.bassRows
    static let beat = Curriculum.fourFloor
    static let drums = HouseCourse.drums
    static let full = HouseCourse.full
    static let kickHats = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])
    static let bassOnly = Pattern(bass: HouseCourse.bassline)
    static let chordsOnly = Pattern(chords: [K.ch(0, .am7, 6), K.ch(8, .fmaj7, 6)])
    static let drumsBass = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], bass: HouseCourse.bassline)
    static let evens = [0, 2, 4, 6, 8, 10, 12, 14]
    static let sixteenths = Array(0..<16)
    static let fill = Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 14, 15], hat: [2, 6, 10, 14])
    static let melodyRows = HouseCourse.melodyRows
    static let melodyBed = HouseCourse.melodyBed
    static let lanes = K.fullHouseLanes

    // MARK: - Unit 1: Welcome to Production

    static let unit1 = K.core("core.u1", 1, "Welcome to Production", "What producers do, listening & tempo", [
        K.lesson("core.u1.l1", "What Is Production", "Layers make a track", "music.note.house.fill", .arrangement, 20, [
            K.intro("Hi, I'm Woofer",
                    "Production is making a track from nothing. You write the parts, shape the sounds, arrange them into a song and mix them so they sit together. Every track you love is a few simple layers stacked up. Hear one.",
                    [], demo: full),
            K.quiz("What's playing?",
                   "Drums keep time, the bass holds down the low end, and chords add colour. Name the layer you hear.", [
                K.hear([drums], ["Drums", "Bass", "Chords"], 0, "Kick, clap and hats. The drums keep time."),
                K.hear([bassOnly], ["Drums", "Bass", "Chords"], 1, "Low notes that bounce. That's the bass."),
                K.hear([chordsOnly], ["Drums", "Bass", "Chords"], 2, "Several notes at once, held long. Chords."),
                K.hear([drumsBass], ["Drums and bass", "Drums and chords", "Just drums"], 0,
                       "Drums with a bassline bouncing between the kicks."),
            ]),
            K.drumMake("Make your first beat",
                       "There's no wrong answer here. Tap the kick and clap anywhere, press play, and change it until you like it.",
                       tracks: [.kick, .clap], edit: [.kick, .clap], goal: .atLeast(.kick, 3)),
        ]),
        K.lesson("core.u1.l2", "Learning to Listen", "Hear what changes", "ear.fill", .arrangement, 20, [
            K.intro("Listen like a producer",
                    "Most people hear a song as one sound. Producers hear the layers, and notice the exact moment one comes in or drops out. That's called active listening, and it's how you learn from every track you hear.",
                    [], demo: full),
            K.quiz("What came in?", "Two bars. Something new joins on the second one. What was it?", [
                K.hear([kickHats, drums], ["Clap", "Bass", "Chords"], 0, "The clap arrived on beats 2 and 4."),
                K.hear([drums, drumsBass], ["Hats", "Bass", "Clap"], 1, "The bass came in under the drums."),
                K.hear([drumsBass, full], ["Chords", "Kick", "Hats"], 0, "Chord stabs joined on top."),
                K.hear([full, full.keeping([.clap, .hat], bass: true, chords: true)], ["Kick", "Bass", "Chords"], 0,
                       "The kick dropped out. That's a classic breakdown move."),
            ]),
            K.arrange("Recreate what you hear",
                      "Three sections. Listen to each one and switch on the parts that are playing.", .recreate,
                      sections: ["First", "Second", "Third"], lanes: [.drum(.kick), .drum(.hat), .bass], loop: full,
                      target: K.grid("-xx", "xxx", "--x")),
        ]),
        K.lesson("core.u1.l3", "Tempo & BPM", "How fast the beat goes", "metronome.fill", .rhythm, 20, [
            K.intro("Beats per minute",
                    "Tempo is how fast the beat goes, counted in beats per minute, or BPM. House sits around 120 to 128, techno runs 130 and up, hip-hop is closer to 90. The same loop at a different tempo has a completely different energy.",
                    [], demo: drums),
            K.tempo("Set the tempo to 124 BPM",
                    "Classic house speed. Drag the slider, use the buttons, or tap along to the beat.",
                    loop: drums, target: 124, start: 100),
            K.quiz("Slow, medium or fast?", "Listen to the kick and feel the speed.", [
                K.hear([drums], ["About 90", "About 124", "About 140"], 0, "Around 90 BPM: laid back, hip-hop speed.", bpm: 92),
                K.hear([drums], ["About 90", "About 124", "About 140"], 1, "Around 124 BPM: house speed.", bpm: 124),
                K.hear([drums], ["About 90", "About 124", "About 140"], 2, "Around 140 BPM: fast and urgent.", bpm: 140),
            ]),
            K.tempo("Match the tempo by ear",
                    "Play the reference, then tap along or drag until your loop locks in with it.",
                    loop: drums, target: 132, start: 110, byEar: true),
        ]),
        K.lesson("core.u1.l4", "What Is a Loop", "Bars that repeat", "repeat", .rhythm, 20, [
            K.intro("Bars and loops",
                    "A bar is one count of four beats. On the grid, one bar is 16 steps. A loop is a few bars that repeat, and almost every dance track starts life as one. Watch the playhead reach step 16 and jump back to the start.",
                    [], demo: drums),
            K.drumRule("Make a one-bar loop", "Kick on steps 1 and 9, clap on steps 5 and 13.",
                       tracks: [.kick, .clap], edit: [.kick, .clap], target: Pattern(kick: [0, 8], clap: [4, 12])),
            K.quiz("How long is the loop?", "Count the bars until the pattern starts again. Listen for the clap roll.", [
                K.hear([drums, drums, drums, drums], ["1 bar", "2 bars", "4 bars"], 0, "The same bar every time: a one-bar loop."),
                K.hear([drums, fill, drums, fill], ["1 bar", "2 bars", "4 bars"], 1, "The roll comes every second bar: a two-bar loop."),
                K.hear([drums, drums, drums, fill, drums, drums, drums, fill], ["1 bar", "2 bars", "4 bars"], 2,
                       "Three plain bars, then the roll: a four-bar loop."),
            ]),
        ]),
        K.lesson("core.u1.l5", "Meet Your Studio", "The tools you'll use", "slider.horizontal.3", .soundDesign, 20, [
            K.intro("Your studio",
                    "Groova has the tools of a real studio. A grid for drums, a piano roll for bass and melody, keys for chords, and knobs to shape every sound. Let's try each one for a minute.",
                    []),
            K.drumMake("The drum grid", "Rows are drums, columns are steps. Add at least four hats anywhere and press play.",
                       tracks: [.kick, .hat], edit: [.hat], start: beat, goal: .atLeast(.hat, 4)),
            K.bassMake("The piano roll", "Each row is a note, with low notes at the bottom. Place three notes and hear your bassline.",
                       rows: rows, backing: drums, notes: 3),
            K.play("The keys", "Play A, C and E, one after another. Together those three notes make the chord A minor.",
                   [57, 60, 64], low: 55, high: 67),
            K.lab("The knobs", "Turn Cutoff. Low sounds dark and muffled, high sounds bright and buzzy. Envelope makes each note snap open.",
                  [.bassCutoff, .bassEnv], start: [0.25, 0.2], loop: HouseCourse.bassLoop),
        ]),
        K.mastery("core.u1.mastery", "Your First Production", "Beat, bass and a short arrangement", .arrangement, 60, [
            K.drumMake("Write the beat", "Kick, clap and hats. Make a groove you'd nod your head to.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], goal: .atLeast(.kick, 4)),
            K.bassMake("Add a bassline", "Put the notes between the kicks so they don't fight.",
                       rows: rows, backing: drums, notes: 4),
            K.arrange("Arrange it into a track",
                      "Four short sections. Bring parts in and out so every section is different from the one before. That's a finished idea, not just a loop.",
                      .create(.variedSections), loop: full, start: K.grid("x---", "----", "x---", "----", "----")),
        ]),
    ])

    // MARK: - Unit 2: Rhythm Basics

    static let unit2 = K.core("core.u2", 2, "Rhythm Basics", "Beats, bars & the drum kit", [
        K.lesson("core.u2.l1", "Counting Beats", "1, 2, 3, 4", "number", .rhythm, 20, [
            K.intro("Count to four",
                    "Dance music counts in fours. Four beats make a bar, and each beat is four steps on the grid. Beat 1 is step 1, beat 2 is step 5, beat 3 is step 9 and beat 4 is step 13. The bright columns mark the beats.",
                    [.kick], demo: beat),
            K.quiz("Which beat has the clap?", "Count along with the kick: 1, 2, 3, 4.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4])], ["Beat 2", "Beat 3", "Beat 4"], 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [8])], ["Beat 2", "Beat 3", "Beat 4"], 1),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [12])], ["Beat 2", "Beat 3", "Beat 4"], 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12])], ["Beats 1 and 3", "Beats 2 and 4", "Every beat"], 1,
                       "Beats 2 and 4: the backbeat. Almost every dance track puts its clap there."),
            ]),
            K.drumRule("Put a clap on beat 3", "Beat 3 is step 9, the third bright column.",
                       tracks: [.kick, .clap], edit: [.clap], start: beat, target: Pattern(kick: [0, 4, 8, 12], clap: [8])),
        ]),
        K.lesson("core.u2.l2", "Meet the Drum Kit", "Five sounds, five jobs", "square.grid.3x3.fill", .rhythm, 20, [
            K.intro("The drum kit",
                    "Kick: the low thump that drives everything. Clap: the snap on 2 and 4. Hi-hat: the tick that keeps time. Open hat: a longer hiss that lifts the groove. Rim: a woody click for extra bounce. Tap each one.",
                    [.kick, .clap, .hat, .openHat, .perc]),
            K.quiz("Name that drum", "One drum plays on its own. Which is it?", [
                K.hear([Pattern(kick: [0, 4, 8, 12])], ["Kick", "Clap", "Hi-hat"], 0),
                K.hear([Pattern(hat: evens)], ["Kick", "Rim", "Hi-hat"], 2),
                K.hear([Pattern(clap: [4, 12])], ["Open hat", "Clap", "Kick"], 1),
                K.hear([Pattern(openHat: [2, 6, 10, 14])], ["Open hat", "Hi-hat", "Rim"], 0),
                K.hear([Pattern(perc: [3, 7, 10, 13])], ["Clap", "Rim", "Kick"], 1),
            ]),
            K.drumCopy("Rebuild this groove", "Clap on 2 and 4, plus a rim that lands just before each clap.",
                       tracks: [.kick, .clap, .perc], edit: [.clap, .perc], start: beat,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 11])),
        ]),
    ] + house("house.u1.l1", "house.u1.l2", "house.u1.l3") + [
        K.mastery("core.u2.mastery", "Recreate the Rhythm", "Copy two grooves by ear", .rhythm, 60, [
            K.drumCopy("Kick and hats by ear", "The clap is already there. Listen for an extra kick near the end.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .hat], start: Pattern(clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12, 14], clap: [4, 12], hat: [2, 6, 10, 14])),
            K.drumCopy("The whole kit", "Four drums. Get the kick first, then layer the rest one listen at a time.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat],
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14])),
        ]),
    ])

    // MARK: - Unit 3: Groove & Feel

    static let unit3 = K.core("core.u3", 3, "Groove & Feel", "Subdivision, offbeats, syncopation & swing", [
        K.lesson("core.u3.l1", "Eighths & Sixteenths", "Splitting the beat", "square.split.2x2.fill", .rhythm, 25, [
            K.intro("Split the beat",
                    "Each beat can be split. Two hits per beat are eighth notes: steady and driving. Four per beat are sixteenths: fast and busy. Hats usually do the splitting while the kick holds the beat.",
                    [.hat], demo: Pattern(kick: [0, 4, 8, 12], hat: sixteenths)),
            K.drumRule("Hats on every eighth", "Every other step: 1, 3, 5, 7 and so on, up to 15.",
                       tracks: [.kick, .hat], edit: [.hat], start: beat, target: Pattern(kick: [0, 4, 8, 12], hat: evens)),
            K.quiz("Quarters, eighths or sixteenths?", "Count how many hats land in each beat.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [0, 4, 8, 12])], ["Quarters", "Eighths", "Sixteenths"], 0,
                       "One hat per beat: quarter notes."),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: evens)], ["Quarters", "Eighths", "Sixteenths"], 1,
                       "Two per beat: eighths."),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: sixteenths)], ["Quarters", "Eighths", "Sixteenths"], 2,
                       "Four per beat: sixteenths. Techno lives here."),
            ]),
        ]),
        K.lesson("core.u3.l2", "On & Off the Beat", "Downbeats and offbeats", "arrow.left.and.right", .rhythm, 25, [
            K.intro("The \"and\"",
                    "Downbeats are the beats themselves: 1, 2, 3, 4. Offbeats fall halfway between, on the \"and\". A sound on the offbeat pulls against the kick, and that pull is what makes you move.",
                    [.kick, .openHat], demo: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14])),
            K.quiz("On the beat or off it?", "Listen to the second sound against the kick.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [0, 4, 8, 12])], ["On the beat", "Off the beat"], 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14])], ["On the beat", "Off the beat"], 1),
                K.hear([Pattern(kick: [0, 4, 8, 12], perc: [2, 6, 10, 14])], ["On the beat", "Off the beat"], 1),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [0, 4, 8, 12])], ["On the beat", "Off the beat"], 0),
            ]),
            K.drumRule("Open hats on the offbeats", "Halfway between the beats: steps 3, 7, 11 and 15.",
                       tracks: [.kick, .openHat], edit: [.openHat], start: beat,
                       target: Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14])),
        ]),
        K.lesson("core.u3.l3", "Syncopation", "Hits you don't expect", "bolt.horizontal.fill", .rhythm, 25, [
            K.intro("Surprise the listener",
                    "Syncopation means putting a hit where the ear doesn't expect it, just before or after a beat. A little syncopation makes a groove feel alive instead of mechanical. Hear the kick skip.",
                    [.kick], demo: Pattern(kick: [0, 6, 10], clap: [4, 12], hat: evens)),
            K.quiz("Straight or syncopated?", "Is the kick landing on the beats, or dodging them?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12])], ["Straight", "Syncopated"], 0),
                K.hear([Pattern(kick: [0, 6, 10], clap: [4, 12])], ["Straight", "Syncopated"], 1),
                K.hear([Pattern(kick: [0, 3, 8, 11], clap: [4, 12])], ["Straight", "Syncopated"], 1),
                K.hear([Pattern(kick: [0, 8], clap: [4, 12])], ["Straight", "Syncopated"], 0),
            ]),
            K.drumCopy("Copy the skipping kick", "Three kicks. Only the first is on a beat.",
                       tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: evens),
                       target: Pattern(kick: [0, 6, 10], clap: [4, 12], hat: evens)),
        ]),
        K.lesson("core.u3.l4", "Swing & Shuffle", "Groove that leans", "metronome", .rhythm, 25, [
            K.intro("Swing",
                    "Swing delays every other sixteenth a little, so the beat lilts instead of marching. It's the difference between a drum machine and a drummer. UK garage swings hard, house a little, techno barely at all.",
                    [.hat], demo: Pattern(kick: [0, 4, 8, 12], hat: sixteenths)),
            K.quiz("Straight or swung?", "Listen to the hats. Do they march or bounce?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: sixteenths)], ["Straight", "Swung"], 0, swing: 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: sixteenths)], ["Straight", "Swung"], 1, swing: 0.32),
                K.hear([Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15])], ["Straight", "Swung"], 1, swing: 0.28),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: evens)], ["Straight", "Swung"], 0, swing: 0),
            ]),
            K.swingMake("Add swing", "Drag the swing control until the hats bounce.",
                        tracks: [.kick, .clap, .hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: sixteenths),
                        atLeast: 0.1),
        ]),
    ] + house("house.u5.l5") + [
        K.mastery("core.u3.mastery", "Groove Check", "Syncopation, offbeats & swing", .rhythm, 60, [
            K.drumCopy("Rebuild a syncopated groove", "The kick skips and the open hats sit on offbeats.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .openHat], start: Pattern(clap: [4, 12], hat: evens),
                       target: Pattern(kick: [0, 6, 8, 14], clap: [4, 12], hat: evens, openHat: [2, 10])),
            K.drumCopy("Hats and rims", "Eighth-note hats with one extra at the end, and rims before the claps.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.hat, .perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: evens + [15], perc: [3, 11])),
            K.swingMake("Give it swing", "Make the groove lean. Aim for a clear bounce.",
                        tracks: [.kick, .clap, .hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: sixteenths),
                        atLeast: 0.14),
        ]),
    ])

    // MARK: - Unit 4: Notes & Melody

    static let unit4 = K.core("core.u4", 4, "Notes & Melody", "Keys, scales & playing by ear", [
        K.lesson("core.u4.l1", "Meet the Keys", "Notes on a keyboard", "pianokeys", .theory, 25, [
            K.play("Play C, D and E",
                   "A keyboard repeats the same 12 notes over and over. The white keys are named A to G. C sits just left of each pair of black keys. Play C, then the next two white keys.",
                   [60, 62, 64], low: 55, high: 67),
            K.quiz("Higher or lower?", "Two notes. Is the second one higher or lower than the first?", [
                K.round(K.phrase([60, 64]), ["Higher", "Lower"], 0),
                K.round(K.phrase([67, 62]), ["Higher", "Lower"], 1),
                K.round(K.phrase([57, 69]), ["Higher", "Lower"], 0),
                K.round(K.phrase([64, 59]), ["Higher", "Lower"], 1),
            ]),
            K.play("Play a little tune", "E, D, C, D, E, E, E. You might know this one.",
                   [64, 62, 60, 62, 64, 64, 64], low: 55, high: 67),
        ]),
        K.lesson("core.u4.l2", "Octaves & Semitones", "How notes are spaced", "arrow.up.and.down", .theory, 25, [
            K.play("Play C, then the next C up",
                   "Twelve keys later, a note comes back higher. That's an octave: same name, same feel, just higher. Play C, then the C above it.",
                   [60, 72], low: 55, high: 74),
            K.play("Play every key from C to E",
                   "The smallest step in music is a semitone: from one key to the very next, black or white. Two semitones make a tone.",
                   [60, 61, 62, 63, 64], low: 55, high: 67),
            K.quiz("Octave or a new note?", "Is the second note the same note an octave away, or a different note?", [
                K.round(K.phrase([57, 69]), ["Octave", "Different note"], 0),
                K.round(K.phrase([60, 67]), ["Octave", "Different note"], 1),
                K.round(K.phrase([62, 74]), ["Octave", "Different note"], 0),
                K.round(K.phrase([64, 65]), ["Octave", "Different note"], 1, "Just one semitone apart."),
            ]),
        ]),
        K.lesson("core.u4.l3", "Major & Minor", "Bright and dark", "sun.max.fill", .theory, 25, [
            K.play("Play the C major scale",
                   "A scale is the set of notes a melody uses. C major is every white key from C up to C. It sounds bright and happy.",
                   [60, 62, 64, 65, 67, 69, 71, 72], low: 60, high: 72),
            K.play("Play the A minor scale",
                   "The same white keys, starting from A. Now it sounds darker. Most dance music lives in minor keys.",
                   [57, 59, 60, 62, 64, 65, 67, 69], low: 57, high: 69),
            K.quiz("Major or minor?", "Bright or dark? Trust your gut.", [
                K.round(K.phrase([60, 64, 67, 72]), ["Major (bright)", "Minor (dark)"], 0),
                K.round(K.phrase([57, 60, 64, 69]), ["Major (bright)", "Minor (dark)"], 1),
                K.round(K.phrase([62, 66, 69]), ["Major (bright)", "Minor (dark)"], 0),
                K.round(K.phrase([62, 65, 69]), ["Major (bright)", "Minor (dark)"], 1),
            ]),
        ]),
    ] + house("house.mel.l1") + [
        K.lesson("core.u4.l5", "Steps & Leaps", "Intervals", "chart.line.uptrend.xyaxis", .theory, 25, [
            K.quiz("Step or leap?",
                   "The gap between two notes is an interval. Small gaps sound smooth, like singing. Big leaps sound bold and dramatic.", [
                K.round(K.phrase([60, 62]), ["Step", "Leap"], 0),
                K.round(K.phrase([60, 67]), ["Step", "Leap"], 1),
                K.round(K.phrase([64, 62]), ["Step", "Leap"], 0),
                K.round(K.phrase([57, 69]), ["Step", "Leap"], 1),
            ]),
            K.leadCopy("Copy this melody", "It steps up three notes, then leaps back down.",
                       rows: melodyRows, target: K.line([(0, 60), (2, 62), (4, 64), (8, 57)]), backing: melodyBed),
            K.leadMake("Write steps and a leap", "Use mostly small steps, then one big leap for drama. At least five notes.",
                       rows: melodyRows, backing: melodyBed, notes: 5),
        ]),
        K.mastery("core.u4.mastery", "Play It by Ear", "Melodies from listening alone", .theory, 70, [
            K.quiz("Which way does it go?", "Up, down, or up then down?", [
                K.round(K.phrase([57, 60, 62, 64]), ["Up", "Down", "Up then down"], 0),
                K.round(K.phrase([69, 67, 64, 60]), ["Up", "Down", "Up then down"], 1),
                K.round(K.phrase([60, 64, 67, 64]), ["Up", "Down", "Up then down"], 2),
            ]),
            K.leadCopy("Copy the melody", "Four notes, mostly steps.",
                       rows: melodyRows, target: K.line([(0, 64), (3, 62), (6, 60), (8, 57)]), backing: melodyBed),
            K.leadCopy("Copy the hook", "It repeats a short idea, then changes the ending.",
                       rows: melodyRows, target: K.line([(0, 69), (2, 67), (4, 64), (8, 69), (10, 67), (12, 62)]),
                       backing: melodyBed, threshold: 0.75),
        ]),
    ])

    // MARK: - Unit 5: Chords & Harmony

    static let unit5 = K.core("core.u5", 5, "Chords & Harmony", "Building chords & progressions",
        house("house.u2.l1", "house.u2.l2", "house.u2.l4") + [
        K.lesson("core.u5.l4", "Chords & Emotion", "What chords make you feel", "heart.fill", .theory, 30, [
            K.intro("Chords have moods",
                    "Major chords feel bright and open. Minor chords feel moody. Add a seventh and the chord turns smooth and jazzy. Producers pick chords for the feeling first and the theory second.",
                    [], demo: HouseCourse.padLoop),
            K.quiz("Bright or moody?", "One chord. How does it feel?", [
                K.round([.c], ["Bright", "Moody"], 0, "C major: bright."),
                K.round([.am], ["Bright", "Moody"], 1, "A minor: moody."),
                K.round([.em], ["Bright", "Moody"], 1),
                K.round([ChordShape(name: "F", pitches: [53, 57, 60])], ["Bright", "Moody"], 0),
            ]),
            K.quiz("Plain or jazzy?", "Three notes, or a richer chord with a seventh?", [
                K.round([.am], ["Plain triad", "Jazzy seventh"], 0),
                K.round([.am7], ["Plain triad", "Jazzy seventh"], 1),
                K.round([.fmaj7], ["Plain triad", "Jazzy seventh"], 1),
                K.round([.c], ["Plain triad", "Jazzy seventh"], 0),
            ]),
            K.build("Build a bright chord", "C major: C, E and G.", .c),
        ]),
    ] + house("house.u2.l5", "house.u2.mastery"))

    // MARK: - Unit 6: Sound Design Basics

    static let unit6 = K.core("core.u6", 6, "Sound Design Basics", "Synths, waveforms, filters & envelopes", [
        K.lesson("core.u6.l1", "Inside a Synth", "Oscillator, filter, envelope", "waveform", .soundDesign, 30, [
            K.intro("How a synth works",
                    "A synth starts with an oscillator: a raw, buzzing tone. A filter cuts away brightness, like a hand over a speaker. An envelope shapes the sound over time, so it can pluck, swell or punch. Every bass and pad you'll make goes through those three.",
                    [], demo: HouseCourse.bassLoop),
            K.lab("Close and open the filter", "Low cutoff: dark and muffled. High cutoff: bright and buzzy. Sweep it both ways.",
                  [.bassCutoff], start: [0.2], loop: HouseCourse.bassLoop),
            K.lab("Match this bass", "Cutoff first. Then Envelope, which makes each note open up and snap shut. That movement is modulation.",
                  [.bassCutoff, .bassEnv], start: [0.2, 0.1], target: [0.55, 0.65], loop: HouseCourse.bassLoop),
        ]),
        K.lesson("core.u6.l2", "Waveforms", "Sine, saw & square", "waveform.path", .soundDesign, 30, [
            K.intro("The raw tone",
                    "Oscillators make simple shapes. A sine is pure and round, perfect for sub bass. A saw is bright and buzzy, the classic synth sound. A square is hollow and woody. Each one gives the filter something different to work with.",
                    [], demo: HouseCourse.bassLoop),
            K.lab("Find the saw", "Start on a sine. The saw sits in the middle of the Wave knob: bright and buzzy.",
                  [.bassWave], start: [0], target: [0.5], loop: HouseCourse.bassLoop),
            K.lab("Find a dark square", "Hollow and woody, with the filter closed down a little.",
                  [.bassWave, .bassCutoff], start: [0.5, 0.7], target: [0.95, 0.35], loop: HouseCourse.bassLoop),
        ]),
    ] + house("house.u3.l4", "house.u3.l5", "house.u3.l1", "house.u3.mastery"))

    // MARK: - Unit 7: Mixing Basics

    static let unit7 = K.core("core.u7", 7, "Mixing Basics", "Balance, frequency, pump & effects", [
        K.lesson("core.u7.l1", "Volume & Balance", "Every part at the right level", "slider.vertical.3", .mixing, 30, [
            K.intro("Mixing starts with faders",
                    "Mixing makes every part sit together. The first and most important tool is volume. Start with the kick, then bring everything else in around it. If you can't hear a part, it's too low. If it's all you hear, it's too loud.",
                    [], demo: full),
            K.mix("The hats are too loud", "Bring the hats down until they sit behind the kick and clap.",
                  [.drum(.kick), .drum(.clap), .drum(.hat)], start: [K.u, K.u, 1.0], target: [K.u, K.u, 0.4], loop: drums),
            K.mix("Balance the bass", "The bass should be felt under the kick, not fight it. Match the reference.",
                  [.drum(.kick), .bass], start: [K.u, 0.15], target: [K.u, 0.6], loop: HouseCourse.bassLoop),
        ]),
        K.lesson("core.u7.l2", "Lows, Mids & Highs", "Where each sound lives", "chart.bar.fill", .mixing, 30, [
            K.intro("The frequency spectrum",
                    "Every sound has a home. Kick and bass live in the lows, chords and claps in the mids, hats sparkle in the highs. When two sounds share a home they fight, and the mix turns to mud.",
                    [], demo: full),
            K.quiz("Where does it live?", "One part plays on its own. Low, middle or high?", [
                K.hear([Pattern(kick: [0, 4, 8, 12])], ["Lows", "Mids", "Highs"], 0, "The kick's thump is all low end."),
                K.hear([Pattern(hat: sixteenths)], ["Lows", "Mids", "Highs"], 2, "Hats are pure sizzle up high."),
                K.hear([Pattern(chords: HouseCourse.stabs)], ["Lows", "Mids", "Highs"], 1, "Chords fill the middle."),
                K.hear([bassOnly], ["Lows", "Mids", "Highs"], 0),
            ]),
            K.filterMatch("Keep only the lows",
                          "A low-pass filter removes everything above the cutoff. Pull it down until only the kick and bass are left.",
                          cutoff: 350, resonance: 0.2, full),
        ]),
        K.lesson("core.u7.l3", "Sidechain Pump", "Make room for the kick", "waveform.path.ecg", .mixing, 30, [
            K.intro("The pump",
                    "Sidechain turns other sounds down every time the kick hits, then lets them swell back up. It clears space for the kick and gives dance music its breathing, pumping feel.",
                    [], demo: full),
            K.mix("Add some pump", "Turn up Pump until the pad ducks under every kick.",
                  [.chords, .sidechain], start: [K.u, 0], target: [K.u, 0.7], loop: HouseCourse.padLoop),
            K.mix("Match the mix", "Bass, chords and pump. Set the pump last.",
                  [.drum(.kick), .bass, .chords, .sidechain], start: [K.u, K.u, K.u, 0],
                  target: [K.u, 0.5, 0.75, 0.45], loop: full),
        ]),
    ] + house("house.u1.l5") + [
        K.lesson("core.u7.l5", "Drive & Warmth", "Saturation", "flame.fill", .mixing, 30, [
            K.intro("Drive",
                    "Drive pushes a sound so hard it starts to crunch. A little adds warmth and helps a kick cut through phone speakers. A lot sounds aggressive, which is exactly what techno wants.",
                    [.kick]),
            K.lab("Warm up the kick", "Add drive until the kick has a little grit.",
                  [.kickDrive], start: [0], target: [0.4], loop: HouseCourse.kickLoop),
            K.lab("Match this kick", "Lots of drive and a longer tail. Rumble.",
                  [.kickDrive, .kickDecay], start: [0.1, 0.3], target: [0.85, 0.65], loop: HouseCourse.kickLoop),
        ]),
        K.mastery("core.u7.mastery", "Mix Check", "Balance a full loop", .mixing, 70, [
            K.mix("Fix this mix", "Everything's off. Kick first, then claps, hats, bass and chords around it.",
                  [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords], start: [K.u, 0.3, 0.95, 0.2, 0.95],
                  target: [K.u, K.u, 0.45, 0.6, 0.5], loop: full),
            K.mix("Add the pump", "Make the bass and chords breathe with the kick.",
                  [.bass, .chords, .sidechain], start: [K.u, K.u, 0], target: [K.u, 0.6, 0.55], loop: full),
            K.filterMatch("Match the filter", "Somewhere in the middle, with a little ring.", cutoff: 1200, resonance: 0.5, full),
        ]),
    ])

    // MARK: - Unit 8: Arrangement & Finishing

    static let unit8 = K.core("core.u8", 8, "Arrangement & Finishing", "From loop to finished track", house("house.u5.l1") + [
        K.lesson("core.u8.l2", "Phrases of Eight", "Why changes come in eights", "8.circle.fill", .arrangement, 35, [
            K.intro("Count in eights",
                    "Dance tracks change every 8 or 16 bars. DJs count on it, and listeners feel it even if they've never counted. When something new arrives at the start of a phrase it feels right. Anywhere else it feels like a mistake.",
                    [], demo: full),
            K.quiz("When does the change come?", "Count the bars from 1. When does the bass arrive?", [
                K.hear([drums, drums, drumsBass, drumsBass], ["Bar 3", "Bar 5", "Bar 7"], 0),
                K.hear([drums, drums, drums, drums, drumsBass, drumsBass, drumsBass, drumsBass], ["Bar 3", "Bar 5", "Bar 7"], 1,
                       "Bar 5: the start of the second four-bar phrase."),
                K.hear([drums, drums, drums, drums, drums, drums, drumsBass, drumsBass], ["Bar 3", "Bar 5", "Bar 7"], 2),
            ]),
            K.arrange("Recreate the phrase",
                      "Each section is a phrase. Listen to what each one adds.", .recreate, loop: full,
                      target: K.grid("xxxx", "-xxx", "xxxx", "--xx", "---x")),
        ]),
        K.lesson("core.u8.l3", "From Loop to Track", "8 bars to a whole song", "rectangle.expand.vertical", .arrangement, 35, [
            K.intro("Your loop is a track waiting to happen",
                    "Most unfinished tracks die as an 8-bar loop. The fix: copy your full loop across the whole track, then take things away. Strip the start for an intro, pull the kick for a breakdown, bring it all back for the drop. Subtracting is faster than adding.",
                    [], demo: full),
            K.arrange("Start full, then subtract",
                      "Everything is on. In the Intro, switch off everything except kick and hats. In the Break, switch off the kick.",
                      .rule, loop: full, start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                      target: K.grid("xxx-", "-xxx", "xxxx", "-xxx", "-xxx")),
            K.arrange("Subtract your own way", "Start full and switch parts off until every section is different from the one before.",
                      .create(.variedSections), loop: full, start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx")),
        ]),
        K.lesson("core.u8.l4", "The Energy Curve", "Build, peak, release", "chart.xyaxis.line", .arrangement, 35, [
            K.intro("Energy",
                    "A track is a journey of energy. It builds, peaks at the drop, dips in the breakdown, then peaks again. More parts and busier drums mean more energy. Plan the curve before you arrange.",
                    [], demo: full),
            K.quiz("Which has more energy?", "Two bars. Which one hits harder?", [
                K.hear([kickHats, full], ["First", "Second"], 1, "More parts, more energy."),
                K.hear([full, chordsOnly], ["First", "Second"], 0, "Dropping the drums takes the energy right down."),
                K.hear([drumsBass, drums], ["First", "Second"], 0),
            ]),
            K.arrange("Shape the curve",
                      "Low energy, building, peak, then a dip. Listen and recreate it.", .recreate, loop: full,
                      target: K.grid("-xx-", "--x-", "xxx-", "-xx-", "x-xx")),
        ]),
        K.lesson("core.u8.l5", "Transitions", "Getting from A to B", "arrow.triangle.turn.up.right.diamond.fill", .arrangement, 35, [
            K.intro("Transitions",
                    "The moment between two sections is where tracks feel pro or amateur. A fill on the last beat, a filter sweep, or dropping the kick for a bar tells the listener something is about to change.",
                    [.clap], demo: fill),
            K.drumRule("Add a clap roll", "Keep the claps on 5 and 13, and add claps on steps 14, 15 and 16 to roll into the next bar.",
                       tracks: [.kick, .clap, .hat], edit: [.clap], start: drums,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 13, 14, 15], hat: [2, 6, 10, 14])),
            K.filterSweep("Sweep into the drop", "Start dark and open the filter all the way. That rising brightness is the sound of a build.", full),
        ]),
        K.mastery("core.u8.mastery", "Finish a Mini Track", "Make it, arrange it, mix it", .arrangement, 100, [
            K.drumMake("Write the drums", "A groove you'd play out. Use every drum you like.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat], goal: .atLeast(.kick, 4)),
            K.bassMake("Write the bass", "Between the kicks, at least five notes.", rows: rows, backing: drums, notes: 5),
            K.lane("Add chords", "Place at least three stabs. Offbeats bounce, long chords float.", .create(.chordsAtLeast(3)),
                   palette: [.am7, .dm7], backing: drumsBass),
            K.arrange("Arrange the track", "Intro, build, drop and break, each one different from the last.",
                      .create(.variedSections), loop: full),
            K.mix("Mix it", "Set every fader where it sounds right to you. There's no wrong answer, just listen.",
                  [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords], start: [K.u, K.u, K.u, K.u, K.u], loop: full),
        ]),
    ])
}
