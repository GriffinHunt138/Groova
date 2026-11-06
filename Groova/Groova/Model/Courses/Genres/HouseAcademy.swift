//
//  HouseAcademy.swift
//  Groova
//
//  House, Part 2. Five units and a final song project, in A minor at 124 BPM.
//
//  H1 The House Pulse   H2 Groove Meets Bass   H3 Chords, Stabs & Hooks
//  H4 House Sound Lab   H5 Dancefloor Arrangement   H6 Song Project Finale
//

import Foundation

nonisolated enum HouseAcademy {
    static let units: [Unit] = [h1, h2, h3, h4, h5, h6]

    // MARK: Material

    static let rows = Curriculum.bassRows            // A2 G2 E2 D2 C2 A1
    static let lead = [76, 74, 72, 69, 67, 64, 62, 60] // A minor, E5 down to C4

    static let kick4 = Pattern(kick: [0, 4, 8, 12])
    static let beat = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14])
    static let tops = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                              openHat: [2, 6, 10, 14], perc: [3, 11])
    static let shuffle = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14])
    static let hipHopBeat = Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14])
    static let technoBeat = Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), perc: [3, 6, 11])

    static let bass = HouseCourse.bassline
    static let offBass = [2, 6, 10, 14].map { NoteEvent($0, 33) }
    static let motif = [NoteEvent(2, 33), NoteEvent(3, 45), NoteEvent(6, 43)]
    static let bassGroove = beat.merged(with: Pattern(bass: bass))

    static let stabs = [K.ch(2, .am7), K.ch(6, .am7), K.ch(10, .dm7), K.ch(14, .dm7)]
    static let full = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14],
                              bass: bass, chords: stabs)
    static let hook = K.tune([(0, 69, 2), (2, 72, 2), (4, 76, 3), (8, 74, 2), (10, 72, 2), (12, 69, 4)])
    static let song = K.melody(hook, over: full)

    // Arrangement blocks
    static let intro = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])
    static let groove = bassGroove
    static let breakdown = K.melody(hook, over: Pattern(chords: [K.ch(0, .am7, 7), K.ch(8, .dm7, 7)]))
    static let drop = song
    static let outro = Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14])
    static let fill = Pattern(kick: [0, 4, 8, 12], clap: [4, 10, 12, 13, 14, 15], openHat: [2, 6])
    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]

    static func blocks() -> [OrderTile] {
        [K.tile("Intro", intro, "Kick & hats"), K.tile("Groove", groove, "Drums & bass"),
         K.tile("Break", breakdown, "No kick"), K.tile("Drop", drop, "Everything"), K.tile("Outro", outro, "Strip back")]
    }

    static let pluck: [SoundParam: Double] = [.bassDecay: 0.1, .bassEnv: 0.8, .bassCutoff: 0.35]
    static let long: [SoundParam: Double] = [.bassDecay: 0.9, .bassEnv: 0.1, .bassCutoff: 0.35]
    static let bassLoop = Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14], bass: bass)
    static let stabLoop = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], chords: [K.ch(2, .am7, 2), K.ch(10, .dm7, 2)])

    // MARK: - H1 · The House Pulse

    static let h1 = K.unit("house.h1", 1, "The House Pulse", "Four on the floor, offbeat hats and claps", [h11, h12, h13, h1b])

    static let h11 = K.lesson("house.h1.1", "Hear the House Pulse", "What makes it house", "ear.fill", .rhythm, 20, [
        K.intro("One kick, every beat",
                "House was born in Chicago clubs in the 80s, and it's built on one idea: a kick drum on every single beat. Four on the floor. It never stops, so dancers never lose the beat.",
                [.kick], demo: beat),
        K.quiz("House, hip-hop or techno?", "Each clip plays in its own genre. Listen to the kick.", [
            K.hear([beat], ["House", "Hip-Hop", "Techno"], 0, "Four even kicks and an offbeat 'tss'. House.", bars: 2, genre: .house),
            K.hear([hipHopBeat], ["House", "Hip-Hop", "Techno"], 1, "A slower, choppy kick dodging around the snare. Hip-hop.", bars: 2, genre: .hipHop),
            K.hear([technoBeat], ["House", "Hip-Hop", "Techno"], 2, "Four kicks too, but harder, faster and full of machine hats. Techno.", bars: 2, genre: .techno),
        ]),
        K.tapAlong("Tap the kick", "Every beat. This is the pulse a whole dance floor moves to.", loop: beat, bars: 5,
                   label: "Kick", unit: "kicks", sound: .kick),
        K.quiz("Quick check", "", [
            K.ask("Four on the floor means…", ["A kick on every beat", "Four snares a bar", "Four bars per loop"], 0),
            K.ask("House usually sits around…", ["90 BPM", "124 BPM", "170 BPM"], 1),
        ]),
    ])

    static let h12 = K.lesson("house.h1.2", "Four-on-the-Floor Builder", "Kick and clap", "square.grid.4x3.fill", .rhythm, 20, [
        K.intro("Kick and clap",
                "House swaps the snare for a clap, landing on 2 and 4 with the kick underneath. Kick on every beat, clap on every other one. That's the skeleton of every house track.",
                [.kick, .clap], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12])),
        K.drumRule("Four kicks", "Steps 1, 5, 9 and 13.", tracks: [.kick, .clap], edit: [.kick], target: kick4),
        K.drumRule("Claps on 2 and 4", "On the snare row, steps 5 and 13, right on top of those kicks.",
                   tracks: [.kick, .clap], edit: [.clap], start: kick4, target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12])),
        K.quiz("Four on the floor?", "Does the kick hit every beat?", [
            K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12])], ["Yes", "No"], 0, bars: 2),
            K.hear([Pattern(kick: [0, 8], clap: [4, 12])], ["Yes", "No"], 1, "Only beats 1 and 3. That's a backbeat, not house.", bars: 2),
            K.hear([Pattern(kick: [0, 4, 8, 11], clap: [4, 12])], ["Yes", "No"], 1, "The last kick lands early.", bars: 2),
        ]),
        K.tapAlong("Tap the claps", "Just 2 and 4.", loop: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), bars: 5, steps: [4, 12],
                   label: "Clap", unit: "claps", sound: .clap),
    ])

    static let h13 = K.lesson("house.h1.3", "Hat Flip", "The offbeat 'tss'", "sparkles", .rhythm, 20, [
        K.intro("The offbeat",
                "Here's the sound that makes house bounce: an open hat right between the kicks. Boom, tss, boom, tss. It pulls your body up between every step.",
                [.openHat], demo: beat),
        K.drumRule("Open hats between the kicks", "Steps 3, 7, 11 and 15.",
                   tracks: [.kick, .clap, .openHat], edit: [.openHat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: beat),
        K.tapAlong("Tap the 'tss'", "Only the offbeat hats.", loop: beat, bars: 5, steps: [2, 6, 10, 14], label: "Tss",
                   unit: "offbeats", sound: .openHat),
        K.drumRule("Add closed hats", "Short hats on every odd step between: 2, 4, 6 and so on. Now the groove shimmers.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.hat], start: beat,
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], openHat: [2, 6, 10, 14])),
    ])

    static let h1b = K.lesson("house.h1.boss", "House Pulse Boss", "Boss: rebuild a house groove", "crown.fill", .rhythm, 40, [
        K.intro("Boss: the house groove",
                "Kick on every beat, clap on 2 and 4, an open hat between, and a few shakers on top. Rebuild it from the reference.",
                [.kick, .clap, .hat, .openHat, .perc], demo: tops),
        K.drumCopy("Rebuild the groove", "Start with the kick and clap, then the open hats, then the rest.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc], target: tops),
        K.tapAlong("Feel it", "Tap the kick for four bars.", loop: tops, bars: 5, label: "Kick", unit: "kicks", sound: .kick),
    ])

    // MARK: - H2 · Groove Meets Bass

    static let h2 = K.unit("house.h2", 2, "Groove Meets Bass", "Basslines that dance with the kick", [h21, h22, h23, h2b])

    static let h21 = K.lesson("house.h2.1", "Kick/Bass Tetris", "Bass in the gaps", "square.on.square", .rhythm, 20, [
        K.intro("Share the low end",
                "The kick and bass both live down low. If they hit together, they blur into mud. House bass slots into the gaps between kicks, like Tetris pieces.",
                [], demo: beat.merged(with: Pattern(bass: offBass))),
        K.bassRule("Bass between the kicks", "Low A on steps 3, 7, 11 and 15.", rows: rows, target: offBass, backing: beat),
        K.quiz("Clash or groove?", "", [
            K.hear([beat.merged(with: Pattern(bass: [0, 4, 8, 12].map { NoteEvent($0, 33) }))], ["Clash", "Groove"], 0,
                   "Bass on the kicks. Thick and blurry.", bars: 2),
            K.hear([beat.merged(with: Pattern(bass: offBass))], ["Clash", "Groove"], 1, "Bass in the gaps. Bouncy and clear.", bars: 2),
        ]),
        K.bassMake("Fill the gaps your way", "At least four notes, none on a kick.", rows: rows, backing: beat, notes: 4),
    ])

    static let h22 = K.lesson("house.h2.2", "Bass Echo", "Repeating motifs", "repeat", .theory, 20, [
        K.intro("Say it twice",
                "Great house basslines are short ideas repeated. Three notes, again and again, until they're stuck in your head. Repetition is a feature, not a flaw.",
                [], demo: beat.merged(with: Pattern(bass: motif + motif.map { NoteEvent($0.step + 8, $0.pitch) }))),
        K.bassRule("Place the motif", "Three lit notes in the first half of the bar.", rows: rows, target: motif, backing: beat),
        K.bassRule("Now echo it", "Copy the same three notes into the second half.", rows: rows,
                   target: motif + motif.map { NoteEvent($0.step + 8, $0.pitch) }, backing: beat),
        K.bassCopy("Copy a new motif", "Three notes, repeated twice. By ear.", rows: rows,
                   target: [NoteEvent(2, 33), NoteEvent(4, 36), NoteEvent(6, 38), NoteEvent(10, 33), NoteEvent(12, 36), NoteEvent(14, 38)],
                   backing: beat),
    ])

    static let h23 = K.lesson("house.h2.3", "Groove Surgeon", "Note length and timing", "scissors", .rhythm, 20, [
        K.intro("Length matters",
                "A bass note that rings into the next kick muddies it. Shorten it and the kick punches through. Pros fix grooves by trimming, not adding.",
                [], demo: bassGroove),
        K.fixNotes("Trim the long note", "One note rings right through the next kick. Make it short.", rows: rows,
                   broken: [NoteEvent(2, 33, 4), NoteEvent(6, 33), NoteEvent(10, 33), NoteEvent(14, 33)], target: offBass,
                   backing: beat),
        K.fixNotes("Move the late note", "One note lands on a kick instead of after it.", rows: rows,
                   broken: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(8, 36), NoteEvent(14, 40)],
                   target: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(10, 36), NoteEvent(14, 40)], backing: beat),
    ])

    static let h2b = K.lesson("house.h2.boss", "Groove Meets Bass Boss", "Boss: kick and bass", "crown.fill", .rhythm, 40, [
        K.intro("Boss: drums and bass",
                "Put the house groove and a bassline together. Drums first, then the bass in the gaps.", [], demo: bassGroove),
        K.drumRule("The groove", "Kick on every beat, clap on 2 and 4, open hats between.",
                   tracks: [.kick, .clap, .openHat], edit: [.kick, .clap, .openHat], target: beat),
        K.bassRule("The bassline", "Follow the lit notes.", rows: rows, target: bass, backing: beat),
        K.tapAlong("Ride it", "Tap the kick while the groove plays.", loop: bassGroove, bars: 5, label: "Kick", unit: "kicks", sound: .kick),
    ])

    // MARK: - H3 · Chords, Stabs & Hooks

    static let h3 = K.unit("house.h3", 3, "Chords, Stabs & Hooks", "Sevenths, stabs and catchy motifs", [h31, h32, h33, h3b])

    static let h31 = K.lesson("house.h3.1", "Chord Color Lab", "Sevenths", "paintpalette.fill", .theory, 20, [
        K.intro("Add a fourth note",
                "House chords are rarely plain triads. Add one more note on top, the seventh, and a chord turns warm, jazzy and soulful. Am becomes Am7. Listen to the glow.",
                [], demo: Pattern(kick: [0, 4, 8, 12], chords: [K.ch(0, .am, 6), K.ch(8, .am7, 6)])),
        K.quiz("Plain or seventh?", "", [
            K.round([.am], ["Plain triad", "Seventh"], 0),
            K.round([.am7], ["Plain triad", "Seventh"], 1, "That extra G softens it."),
            K.round([.dm7], ["Plain triad", "Seventh"], 1),
            K.round([.em], ["Plain triad", "Seventh"], 0),
        ]),
        K.build("Build Am7", "Start from Am (A C E) and add G on top.", .am7, start: [57, 60, 64]),
        K.build("Build Dm7", "D F A, plus C on top.", .dm7, start: [62, 65]),
    ])

    static let h32 = K.lesson("house.h3.2", "Chord Chopper", "Short, rhythmic stabs", "scissors", .theory, 20, [
        K.intro("Chop the chords",
                "Hold a chord and it's a pad. Chop it short and hit it on the offbeats and it's a stab, the classic house piano and synth move.",
                [], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], chords: stabs)),
        K.lane("Offbeat stabs", "Am7 on steps 3 and 7, Dm7 on 11 and 15.", .rule, palette: [.am7, .dm7], backing: beat,
               target: [2: 0, 6: 0, 10: 1, 14: 1]),
        K.quiz("Pad or stab?", "", [
            K.hear([Pattern(kick: [0, 4, 8, 12], chords: [K.ch(0, .am7, 14)])], ["Pad", "Stabs"], 0, bars: 2),
            K.hear([Pattern(kick: [0, 4, 8, 12], chords: stabs)], ["Pad", "Stabs"], 1, bars: 2),
        ]),
        K.lane("Your stab rhythm", "Use both chords. At least four stabs.", .create(.chordsAtLeast(4)), palette: [.am7, .dm7, .fmaj7],
               backing: bassGroove),
    ])

    static let h33 = K.lesson("house.h3.3", "Hook Builder", "A motif people remember", "music.note", .theory, 20, [
        K.intro("A hook is short",
                "A hook is the bit you hum in the shower. In house it's often just three to six notes from the minor pentatonic, repeated until it's part of you.",
                [], demo: song),
        K.leadRule("Build the hook", "Up to the top, then back down to A.", rows: lead, target: hook, backing: full),
        K.leadMake("Your hook", "Five notes or more. Short and catchy beats long and clever.", rows: lead, backing: full, notes: 5),
    ])

    static let h3b = K.lesson("house.h3.boss", "Chords & Hooks Boss", "Boss: stabs and a hook", "crown.fill", .theory, 40, [
        K.intro("Boss: chords and hook",
                "Add a stab part and a hook to the groove. Two layers that make the loop sound like a record.", [], demo: song),
        K.lane("The stabs", "Am7 on 3 and 7, Dm7 on 11 and 15.", .rule, palette: [.am7, .dm7], backing: bassGroove,
               target: [2: 0, 6: 0, 10: 1, 14: 1]),
        K.leadCopy("The hook", "Copy it by ear.", rows: lead, target: hook, backing: full),
    ])

    // MARK: - H4 · House Sound Lab

    static let h4 = K.unit("house.h4", 4, "House Sound Lab", "Plucks, space and filter rides", [h41, h42, h43, h4b])

    static let h41 = K.lesson("house.h4.1", "Warm Bass & Pluck Lab", "Envelope shapes", "waveform.path.ecg", .soundDesign, 20, [
        K.intro("Long or plucky",
                "The same bassline can drone or bounce. Shorten the length and push the envelope and every note plucks. Lengthen it and the bass hums underneath.",
                [], demo: bassLoop),
        K.lab("Make it pluck", "Turn Length down and Envelope up.", [.bassDecay, .bassEnv], start: [0.9, 0.1], loop: bassLoop),
        K.quiz("Plucky or long?", "", [
            K.sound(bassLoop, pluck, ["Plucky", "Long"], 0),
            K.sound(bassLoop, long, ["Plucky", "Long"], 1),
        ]),
    ])

    static let h42 = K.lesson("house.h4.2", "Space Dial", "Reverb on stabs", "dot.radiowaves.left.and.right", .mixing, 20, [
        K.intro("Room for the stabs",
                "Dry stabs sound tight and close. Add space and they bloom into the room. House producers often keep the kick dry and give the chords the air.",
                [], demo: stabLoop),
        K.space("Dial in the room", "From dry to huge. Notice the tail after each stab.", stabLoop),
        K.quiz("Dry or spacious?", "", [
            K.reverb(stabLoop, amount: 0, ["Dry", "Spacious"], 0),
            K.reverb(stabLoop, amount: 0.75, ["Dry", "Spacious"], 1),
        ]),
    ])

    static let h43 = K.lesson("house.h4.3", "Filter Ride", "The build-up trick", "slider.horizontal.3", .soundDesign, 20, [
        K.intro("Open it up",
                "Sweep a low-pass filter from dark to bright over a loop and you can hear energy rise. It's the oldest trick in house: hold the highs back, then let them in.",
                [], demo: full),
        K.filterSweep("Ride the filter", "Drag from dark to bright while it plays, then back down.", full),
        K.quiz("Open or closed?", "", [
            K.filtered(full, cutoff: 400, ["Closed (dark)", "Open (bright)"], 0),
            K.filtered(full, cutoff: 12000, ["Closed (dark)", "Open (bright)"], 1),
        ]),
    ])

    static let h4b = K.lesson("house.h4.boss", "House Sound Lab Boss", "Boss: match a synth", "crown.fill", .soundDesign, 40, [
        K.intro("Boss: match a sound",
                "Three knobs. Listen to the target, then get close: cutoff first, then envelope, then length.", [], demo: bassLoop),
        K.lab("Match the bass", "Start with Cutoff.", [.bassCutoff, .bassEnv, .bassDecay], start: [0.3, 0.3, 0.5],
              target: [0.55, 0.75, 0.2], loop: bassLoop),
        K.filterMatch("Match the filter", "Find the cutoff by ear.", cutoff: 900, resonance: 0.3, full),
    ])

    // MARK: - H5 · Dancefloor Arrangement

    static let h5 = K.unit("house.h5", 5, "Dancefloor Arrangement", "Intros, breaks, drops and transitions", [h51, h52, h53, h5b])

    static let h51 = K.lesson("house.h5.1", "Song X-Ray", "Intro, groove, break", "rectangle.split.3x1.fill", .arrangement, 20, [
        K.intro("Built for DJs",
                "House tracks are made to be mixed. They start with drums so a DJ can blend in, build to the full groove, break down without the kick, then drop back in.",
                [], demo: drop),
        K.tapChanges("Tap each new section", "Intro, groove, break. Hit the pad on each change.",
                     loops: [intro, groove, breakdown], barsEach: 2),
        K.quiz("Name the section", "", [
            K.hear([intro], ["Intro", "Break", "Drop"], 0, "Just kick and hats. Easy for a DJ to mix in.", bars: 2),
            K.hear([breakdown], ["Intro", "Break", "Drop"], 1, "No kick. The floor catches its breath.", bars: 2),
            K.hear([drop], ["Intro", "Break", "Drop"], 2, "Everything slams back in.", bars: 2),
        ]),
    ])

    static let h52 = K.lesson("house.h5.2", "Fill the Gap", "Fills before a new phrase", "arrow.forward.to.line", .arrangement, 20, [
        K.intro("Every eight bars",
                "House moves in phrases of eight bars. Right before a new phrase, a short fill, a clap roll or a missing kick, tells the floor something's coming.",
                [], demo: fill),
        K.order("Fill at the end", "Three bars of groove, then the fill.", .rule,
                tiles: [K.tile("Groove", groove), K.tile("Fill", fill, "Clap roll")], answer: [0, 0, 0, 1],
                names: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"]),
        K.drumMake("Write your fill", "Kick stays. Add claps building toward the end. At least five.",
                   tracks: [.kick, .clap, .openHat], edit: [.clap, .openHat], start: Pattern(kick: [0, 4, 8, 12]),
                   goal: .atLeast(.clap, 5)),
    ])

    static let h53 = K.lesson("house.h5.3", "Energy Rollercoaster", "Mute and bring back", "chart.line.uptrend.xyaxis", .arrangement, 20, [
        K.intro("Take it away",
                "The fastest way to make a part feel huge is to take it away first. Mute the kick for a few bars and when it comes back, the floor goes off.",
                [], demo: drop),
        K.arrange("Low, high, low, high", "Kick and bass off in sections 1 and 3, on in 2 and 4.", .rule,
                  sections: ["Low", "High", "Low", "High"], lanes: lanes, loop: song,
                  target: K.grid("-x-x", "-x-x", "xxxx", "-x-x", "xxxx")),
        K.tapChanges("Feel the drops", "Tap each time the energy switches.", loops: [breakdown, drop, breakdown, drop], barsEach: 2),
    ])

    static let h5b = K.lesson("house.h5.boss", "Dancefloor Boss", "Boss: a full house map", "crown.fill", .arrangement, 40, [
        K.intro("Boss: the dance-floor map",
                "Intro, groove, break, drop, outro. Put the blocks in order and hear a full track.", [], demo: drop),
        K.order("Map the track", "Intro first, outro last. The break comes right before the drop.", .rule,
                tiles: blocks(), answer: [0, 1, 2, 3, 4], barsEach: 2),
        K.arrange("Set the layers", "Five sections. No two neighbours the same.", .create(.variedSections),
                  sections: ["Intro", "Groove", "Break", "Drop", "Outro"], lanes: lanes, loop: song),
    ])

    // MARK: - H6 · Song Project Finale

    static let h6 = K.unit("house.h6", 6, "Song Project Finale", "Your first house track", [h6l])

    static let h6l = K.lesson("house.h6", "Song Project Finale", "Your house track", "flag.checkered", .arrangement, 60, [
        K.intro("Your house track",
                "Everything from this course in one track: the pulse, a bassline, stabs, a hook, and a dance-floor arrangement. Bronze is guided. Silver and Gold make it yours.",
                [], demo: song),
        K.drumRule("The groove", "Kick on every beat, clap on 2 and 4, open hats between, shakers on top.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14])),
        K.bassRule("The bass", "Follow the lit notes.", rows: rows, target: bass, backing: beat),
        K.lane("The stabs", "Am7, Am7, Dm7, Dm7 on the offbeats.", .rule, palette: [.am7, .dm7], backing: bassGroove,
               target: [2: 0, 6: 0, 10: 1, 14: 1]),
        K.order("The map", "Intro, groove, a fill, break, drop, outro.", .rule,
                tiles: blocks() + [K.tile("Fill", fill)], answer: [0, 1, 5, 2, 3, 4], barsEach: 2),
    ])

    // MARK: - Silver and Gold

    static let levels: [String: LevelPair] = [
        "house.h1.1": (silver: [
            L.silver("Spot the pulse",
                     "No labels. Which clip has a kick on every beat? Then keep the pulse with no lights."),
            K.quiz("Which one is four on the floor?", "", [
                K.hear([hipHopBeat, beat], ["The first", "The second"], 1, bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14]), Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14])],
                       ["The first", "The second"], 0, bars: 2),
                K.hear([Pattern(kick: [0, 3, 8, 11], clap: [4, 12]), tops], ["The first", "The second"], 1, bars: 2),
            ]),
            K.tapAlong("Kick, no lights", "Four bars at 124.", loop: tops, bars: 5, guideBars: 0, label: "Kick", unit: "kicks", sound: .kick),
        ], gold: [
            L.gold("Make it house",
                   "Take a hip-hop beat and turn it into house. Kick on every beat, clap on 2 and 4, open hats between."),
            K.fix("Turn this into house", "It's a hip-hop beat. Rebuild it as the reference.", tracks: [.kick, .clap, .hat, .openHat],
                  edit: [.kick, .clap, .hat, .openHat], broken: hipHopBeat, target: beat, guide: false),
            L.make("Add your touch", "Keep four on the floor. Add shakers or hats to make it yours.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .perc], start: beat, goal: .atLeast(.hat, 4)),
        ]),
        "house.h1.2": (silver: [
            L.silver("By ear",
                     "Rebuild grooves from the reference alone."),
            L.copy("Copy the groove", "Kick, clap, and something extra on top.", tracks: [.kick, .clap, .openHat],
                   edit: [.kick, .clap, .openHat], target: beat),
            K.fix("A kick is missing", "Find the gap.", tracks: [.kick, .clap, .openHat], edit: [.kick],
                  broken: Pattern(kick: [0, 4, 12], clap: [4, 12], openHat: [2, 6, 10, 14]), target: beat, guide: false),
        ], gold: [
            L.gold("Variation without losing the pulse",
                   "One extra kick, like a quick double on the last step, adds swagger. Too many and the pulse falls apart."),
            K.quiz("Still four on the floor?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12, 15], clap: [4, 12], openHat: [2, 6, 10, 14])], ["Pulse intact", "Pulse lost"], 0,
                       "One extra kick before the loop restarts. Still house.", bars: 2),
                K.hear([Pattern(kick: [0, 3, 6, 10, 13], clap: [4, 12], openHat: [2, 6, 10, 14])], ["Pulse intact", "Pulse lost"], 1, bars: 2),
            ]),
            L.make("Your variation", "Keep all four kicks. Add one or two more.", tracks: [.kick, .clap, .openHat, .perc],
                   edit: [.kick, .perc], start: beat, goal: .atLeast(.kick, 5)),
        ]),
        "house.h1.3": (silver: [
            L.silver("Shuffle",
                     "Many house grooves swing their hats slightly. It's subtle, but it's the difference between stiff and funky."),
            L.copy("Copy the shuffled tops", "Sixteenth hats with open hats on the offbeats.", tracks: [.kick, .clap, .hat, .openHat],
                   edit: [.hat, .openHat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), target: shuffle),
            K.quiz("Straight or shuffled?", "", [
                K.hear([shuffle], ["Straight", "Shuffled"], 0, bars: 2, swing: 0),
                K.hear([shuffle], ["Straight", "Shuffled"], 1, bars: 2, swing: 0.18),
            ]),
            K.swingMake("Shuffle it", "Just a touch.", tracks: [.kick, .clap, .hat, .openHat], start: shuffle, atLeast: 0.08),
        ], gold: [
            L.gold("Your percussion",
                   "Shakers, rims and hats are where house grooves get personality. Make a version that's still unmistakably house."),
            L.make("Your tops", "Kick, clap and open hats stay. Add rims and hats. At least three rims.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .perc], start: beat, goal: .atLeast(.perc, 3)),
            K.tapAlong("Tss, no lights", "Offbeats for four bars.", loop: tops, bars: 5, steps: [2, 6, 10, 14], guideBars: 0,
                       label: "Tss", unit: "offbeats", sound: .openHat),
        ]),
        "house.h1.boss": (silver: [
            L.silver("Audio only", "No beat guide. Just the reference."),
            L.copy("Rebuild it", "Five drums.", tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14], perc: [7, 15]),
                   threshold: 0.85),
            L.copy("A second bar", "The same groove with an accent.", tracks: [.kick, .clap, .hat, .openHat, .perc],
                   edit: [.kick, .clap, .hat, .openHat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12, 15], clap: [4, 12, 14], hat: [1, 5, 9, 13], openHat: [2, 6, 10], perc: [7, 15]),
                   threshold: 0.85),
        ], gold: [
            L.gold("Your signature groove",
                   "Start from the reference. Change it until it sounds like you, with at least one extra accent."),
            L.make("Signature groove", "Every lane is yours. Keep the four kicks.", tracks: [.kick, .clap, .hat, .openHat, .perc],
                   edit: [.clap, .hat, .openHat, .perc], start: tops, goal: .atLeast(.perc, 3)),
            K.swingMake("Give it feel", "Add a little shuffle.", tracks: [.kick, .clap, .hat, .openHat, .perc], start: tops, atLeast: 0.06),
        ]),
        "house.h2.1": (silver: [
            L.silver("Two lengths",
                     "Pro basslines mix short and long notes and sneak in syncopated hits."),
            L.bass("Copy the bassline", "Some notes short, one long.", [NoteEvent(2, 33), NoteEvent(6, 33, 2), NoteEvent(10, 36), NoteEvent(13, 40, 3)],
                   backing: beat),
            L.bass("Another one", "It moves up at the end.", [NoteEvent(2, 33, 2), NoteEvent(7, 33), NoteEvent(10, 38), NoteEvent(14, 43, 2)],
                   backing: beat),
        ], gold: [
            L.gold("Rests are notes too",
                   "The space between bass notes is half the groove. Leave gaps on purpose."),
            L.bassMake("Your interplay", "At least five notes. Leave at least two gaps of a beat or more.", backing: beat, notes: 5),
            K.quiz("Which groove breathes?", "", [
                K.hear([beat.merged(with: Pattern(bass: Array(0..<16).map { NoteEvent($0, 33) }))], ["Crowded", "Breathes"], 0, bars: 2),
                K.hear([bassGroove], ["Crowded", "Breathes"], 1, bars: 2),
            ]),
        ]),
        "house.h2.2": (silver: [
            L.silver("Longer phrases", "Four-note motifs by ear."),
            L.bass("Copy the phrase", "Four notes, then they repeat.", [NoteEvent(0, 33), NoteEvent(2, 45), NoteEvent(4, 33), NoteEvent(6, 43),
                                                                             NoteEvent(8, 33), NoteEvent(10, 45), NoteEvent(12, 33), NoteEvent(14, 43)],
                   backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12])),
            L.bass("One more", "A disco-style octave bounce.", HouseCourse.discoBass, backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12])),
        ], gold: [
            L.gold("Call and response",
                   "A bassline can talk to itself: a question in the first half, an answer in the second."),
            K.bassMake("Answer the call", "The first half is written. Answer it in the second half with at least three notes.",
                       rows: rows, backing: beat, notes: 6, start: motif),
            K.quiz("Question or answer?", "Does this half-bar sound like it's asking or finishing?", [
                K.hear([beat.merged(with: Pattern(bass: [NoteEvent(2, 33), NoteEvent(4, 38), NoteEvent(6, 43)]))], ["Asking", "Finishing"], 0,
                       "It climbs and stops high. A question.", bars: 2),
                K.hear([beat.merged(with: Pattern(bass: [NoteEvent(10, 43), NoteEvent(12, 38), NoteEvent(14, 33)]))], ["Asking", "Finishing"], 1,
                       "It falls back to A. An answer.", bars: 2),
            ]),
        ]),
        "house.h2.3": (silver: [
            L.silver("Two fixes", "Each groove has two problems. Listen to the reference."),
            K.fixNotes("Fix timing and length", "One note is late, one is too long.", rows: rows,
                       broken: [NoteEvent(2, 33, 3), NoteEvent(7, 33), NoteEvent(10, 36), NoteEvent(14, 40)],
                       target: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(10, 36), NoteEvent(14, 40)], backing: beat),
            K.fixNotes("Fix the pitch and timing", "One wrong note, one early note.", rows: rows,
                       broken: [NoteEvent(2, 33), NoteEvent(5, 33), NoteEvent(10, 43), NoteEvent(14, 40, 2)],
                       target: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(10, 36), NoteEvent(14, 40, 2)], backing: beat),
        ], gold: [
            L.gold("Two feels, same notes",
                   "Same pitches, different lengths. Short feels bouncy. Long feels smooth. Make both."),
            L.bassMake("Bouncy version", "Short notes, at least five.", backing: beat, notes: 5),
            L.bassMake("Smooth version", "Long notes, at least three.", backing: beat, notes: 3),
        ]),
        "house.h2.boss": (silver: [
            L.silver("By ear", "Rebuild the drums and bass from the reference."),
            L.copy("The drums", "Kick, clap, open hats, plus a shaker.", tracks: [.kick, .clap, .openHat, .perc],
                   edit: [.kick, .clap, .openHat, .perc], target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14], perc: [3, 11])),
            L.bass("The bass", "Six notes.", bass, backing: beat),
            L.bassMake("A variation", "Your own bassline for bar two. At least five notes.", backing: beat, notes: 5),
        ], gold: [
            L.gold("Eight bars with a turnaround",
                   "Loops get a turnaround: a different last bar that sends you back to the top. Write one, then place it."),
            L.bassMake("Turnaround bass", "Make it different from the main line. At least six notes.", backing: fill, notes: 6),
            K.order("Place the turnaround", "Eight bars. Mostly groove, with your fill bar in the right spot.", .create(.chordsAtLeast(8)),
                    tiles: [K.tile("Groove", bassGroove), K.tile("Fill", fill)], slots: 8),
        ]),
        "house.h3.1": (silver: [
            L.silver("Extensions by ear", "Build sevenths from new roots and hear the colour."),
            K.build("Build Fmaj7", "F A C E. Brighter than a minor seventh.", .fmaj7),
            K.build("Build Em7", "E G B D.", .em7),
            K.quiz("Minor 7 or major 7?", "", [
                K.round([.am7], ["Minor 7 (moody)", "Major 7 (dreamy)"], 0),
                K.round([.fmaj7], ["Minor 7 (moody)", "Major 7 (dreamy)"], 1),
                K.round([.cmaj7], ["Minor 7 (moody)", "Major 7 (dreamy)"], 1),
            ]),
        ], gold: [
            L.gold("Your progression",
                   "Two chords is enough for a house track. Pick a pair with contrasting colour."),
            K.build("Build Am9", "Am7 plus B on top. Lush.", .am9),
            K.lane("Your two-chord loop", "Use at least two different chords.", .create(.chordsAtLeast(2)),
                   palette: [.am7, .dm7, .fmaj7, .em7, .am9], backing: bassGroove, length: 6),
        ]),
        "house.h3.2": (silver: [
            L.silver("New rhythms", "Stab rhythms by ear."),
            K.lane("Copy the stabs", "Some on the offbeat, one pushed early.", .recreate, palette: [.am7, .dm7], backing: beat,
                   target: [2: 0, 7: 0, 10: 1, 13: 1]),
            K.lane("Another", "Sixteenth pushes.", .recreate, palette: [.am7, .fmaj7], backing: beat, target: [3: 0, 6: 0, 11: 1, 14: 1]),
        ], gold: [
            L.gold("Talk to the bass",
                   "Stabs that answer the bassline, landing where the bass rests, make a groove interlock."),
            K.lane("Answer the bass", "Place stabs in the gaps the bassline leaves. At least five.", .create(.chordsAtLeast(5)),
                   palette: [.am7, .dm7, .fmaj7], backing: bassGroove),
        ]),
        "house.h3.3": (silver: [
            L.silver("Match the hook", "Copy hooks by ear. Shape first, then notes."),
            K.leadCopy("Copy this hook", "Four notes.", rows: lead, target: K.tune([(2, 72, 2), (6, 74, 2), (10, 76, 2), (14, 72, 2)]), backing: full),
            K.leadCopy("Another", "It drops at the end.", rows: lead, target: K.tune([(0, 76, 2), (2, 74, 2), (4, 72, 4), (8, 64, 8)]), backing: full),
        ], gold: [
            L.gold("Breakdown variation",
                   "In the breakdown, the hook often changes: slower, higher, or with a new ending."),
            K.leadMake("Breakdown hook", "Start from the main hook and change it. At least six notes.", rows: lead,
                       backing: Pattern(chords: [K.ch(0, .am7, 7), K.ch(8, .dm7, 7)]), notes: 6, start: Array(hook.prefix(3))),
        ]),
        "house.h3.boss": (silver: [
            L.silver("Don't crowd it", "Chord rhythm should leave room for the bass."),
            K.lane("Stabs around the bass", "Copy the reference.", .recreate, palette: [.am7, .dm7], backing: bassGroove,
                   target: [4: 0, 8: 0, 12: 1]),
            K.leadMake("Hook over it", "Five notes or more.", rows: lead, backing: full, notes: 5),
        ], gold: [
            L.gold("Write the whole top",
                   "Chords and hook, both yours. Repeat an idea, then twist it."),
            K.lane("Your chords", "At least five stabs.", .create(.chordsAtLeast(5)), palette: [.am7, .dm7, .fmaj7, .em7], backing: bassGroove),
            K.leadMake("Your hook", "At least seven notes, with a repeat and a twist.", rows: lead, backing: full, notes: 7),
        ]),
        "house.h4.1": (silver: [
            L.silver("Match the pluck", "Envelope and cutoff, by ear."),
            K.lab("Match it", "Cutoff and envelope.", [.bassCutoff, .bassEnv, .bassDecay], start: [0.2, 0.1, 0.9],
                  target: [0.4, 0.75, 0.15], loop: bassLoop),
            K.quiz("Pluck, long or buzzy?", "", [
                K.sound(bassLoop, pluck, ["Pluck", "Long", "Buzzy"], 0),
                K.sound(bassLoop, [.bassWave: 0.9, .bassCutoff: 0.8, .bassResonance: 0.6], ["Pluck", "Long", "Buzzy"], 2),
                K.sound(bassLoop, long, ["Pluck", "Long", "Buzzy"], 1),
            ]),
            K.lab("Match a stab pluck", "Same idea on the chords.", [.chordDecay, .chordCutoff], start: [0.9, 0.9], target: [0.15, 0.5],
                  loop: stabLoop),
        ], gold: [
            L.gold("Your preset", "A bass that works against your groove. Make it yours."),
            K.lab("Your house bass", "Every knob.", [.bassWave, .bassCutoff, .bassEnv, .bassDecay], start: [0.5, 0.5, 0.5, 0.5], loop: bassLoop),
            K.lab("Your pluck", "A chord pluck to go with it.", [.chordAttack, .chordDecay, .chordCutoff], start: [0.5, 0.5, 0.5], loop: stabLoop),
            K.mix("Fit them together", "Balance your bass against the kick and stabs.", [.drum(.kick), .bass, .chords],
                  start: [K.u, K.u, K.u], loop: full),
        ]),
        "house.h4.2": (silver: [
            L.silver("Size of the room", "Hear small, medium and huge."),
            K.quiz("How much space?", "", [
                K.reverb(stabLoop, amount: 0.2, ["Small", "Medium", "Huge"], 0),
                K.reverb(stabLoop, amount: 0.9, ["Small", "Medium", "Huge"], 2),
                K.reverb(stabLoop, amount: 0.5, ["Small", "Medium", "Huge"], 1),
                K.reverb(full, amount: 0.85, ["Small", "Medium", "Huge"], 2, "Even the kick is washing out. Too much for a groove."),
            ]),
            K.space("Match the room", "Find a setting where the stabs bloom but stay short enough to groove.", stabLoop),
        ], gold: [
            L.gold("Groove versus breakdown",
                   "Keep the groove tight, then flood the breakdown with space."),
            K.space("Breakdown space", "Go big. There's no kick to blur.", breakdown),
            K.space("Groove space", "Now keep it tight so the kick stays punchy.", full),
        ]),
        "house.h4.3": (silver: [
            L.silver("Match the filter", "Find the setting by ear."),
            K.filterMatch("Match it", "Cutoff first.", cutoff: 1500, resonance: 0.2, full),
            K.filterMatch("A darker one", "Lower, with more resonance.", cutoff: 600, resonance: 0.55, full),
            K.quiz("Dark, warm or bright?", "", [
                K.filtered(full, cutoff: 350, ["Dark", "Warm", "Bright"], 0),
                K.filtered(full, cutoff: 1800, ["Dark", "Warm", "Bright"], 1),
                K.filtered(full, cutoff: 12000, ["Dark", "Warm", "Bright"], 2),
            ]),
        ], gold: [
            L.gold("Build and release", "Find two settings: a dark build and a bright release."),
            K.filterMatch("The build", "Dark and resonant.", cutoff: 500, resonance: 0.6, full),
            K.filterMatch("The release", "Wide open.", cutoff: 10000, resonance: 0.1, full),
        ]),
        "house.h4.boss": (silver: [
            L.silver("No highlights", "Match it from scratch."),
            K.lab("Match the stab sound", "Attack, length, cutoff.", [.chordAttack, .chordDecay, .chordCutoff], start: [0.5, 0.9, 0.9],
                  target: [0, 0.2, 0.45], loop: stabLoop),
        ], gold: [
            L.gold("Two states", "One sound for the groove, one for the breakdown."),
            K.lab("Groove state", "Short and tight.", [.chordDecay, .chordCutoff, .chordRelease], start: [0.5, 0.5, 0.5], loop: stabLoop),
            K.lab("Breakdown state", "Long and open.", [.chordDecay, .chordCutoff, .chordRelease], start: [0.5, 0.5, 0.5], loop: breakdown),
        ]),
        "house.h5.1": (silver: [
            L.silver("Five sections", "Map a full track by ear."),
            K.order("Map it", "Five parts, two bars each.", .recreate, tiles: blocks(), answer: [0, 1, 2, 3, 4], barsEach: 2),
            K.order("A different track", "Some sections repeat.", .recreate, tiles: blocks(), answer: [0, 1, 3, 2, 3, 4], barsEach: 2),
            K.tapChanges("Tap the changes", "Five sections.", loops: [intro, groove, breakdown, drop, outro], barsEach: 2),
        ], gold: [
            L.gold("Redesign it", "Same blocks, a new energy story."),
            K.order("Your order", "Eight blocks. No two neighbours the same.", .create(.variedSections), tiles: blocks(), slots: 8, barsEach: 2),
            K.quiz("Why does it work?", "", [
                K.ask("Why do house tracks start with just drums?", ["So DJs can mix them in", "To save time", "Because bass is hard"], 0),
                K.ask("What makes a drop hit hard?", ["A break before it", "A faster tempo", "More reverb"], 0),
            ]),
        ]),
        "house.h5.2": (silver: [
            L.silver("Fill and silence", "Hear a transition that uses both."),
            K.order("Rebuild the transition", "Groove, fill, silence, drop.", .recreate,
                    tiles: [K.tile("Groove", groove), K.tile("Fill", fill), K.tile("Silence", Pattern()), K.tile("Drop", drop)],
                    answer: [0, 0, 1, 2, 3]),
            K.quiz("Which cue?", "", [
                K.hear([groove, fill, drop], ["Fill", "Silence", "Nothing"], 0),
                K.hear([groove, Pattern(), drop], ["Fill", "Silence", "Nothing"], 1),
                K.hear([groove, groove, drop], ["Fill", "Silence", "Nothing"], 2),
            ]),
        ], gold: [
            L.gold("Your transition", "Eight bars, two different cues."),
            L.make("Your fill", "At least six claps.", tracks: [.kick, .clap, .openHat, .perc], edit: [.kick, .clap, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12]), goal: .atLeast(.clap, 6)),
            K.order("Place your cues", "Eight bars.", .create(.chordsAtLeast(8)),
                    tiles: [K.tile("Groove", groove), K.tile("Fill", fill), K.tile("Silence", Pattern()), K.tile("Drop", drop)], slots: 8),
        ]),
        "house.h5.3": (silver: [
            L.silver("Copy a build", "Recreate the layers."),
            K.arrange("Recreate it", "Four sections.", .recreate, sections: ["Intro", "Build", "Break", "Drop"], lanes: lanes, loop: song,
                      target: K.grid("xx-x", "-x-x", "xx-x", "-xxx", "--xx")),
            K.tapChanges("Tap the energy shifts", "", loops: [intro, groove, breakdown, drop], barsEach: 2),
        ], gold: [
            L.gold("Your journey", "Six sections, your energy story."),
            K.arrange("Your journey", "No two neighbours the same.", .create(.variedSections),
                      sections: ["1", "2", "3", "4", "5", "6"], lanes: lanes, loop: song),
        ]),
        "house.h5.boss": (silver: [
            L.silver("Longer", "Two transitions and variations."),
            K.order("A longer map", "Ten blocks.", .create(.variedSections), tiles: blocks() + [K.tile("Fill", fill)], slots: 10, barsEach: 2),
            K.arrange("Vary the drops", "Two drops, each a little different.", .create(.variedSections),
                      sections: ["Groove", "Drop", "Break", "Drop 2"], lanes: lanes, loop: song),
        ], gold: [
            L.gold("Your arrangement", "Contrast, a clean ending, your choices."),
            K.order("The map", "Twelve blocks.", .create(.variedSections), tiles: blocks() + [K.tile("Fill", fill)], slots: 12, barsEach: 2),
            K.arrange("The layers", "Six sections.", .create(.variedSections),
                      sections: ["Intro", "Groove", "Break", "Drop", "Drop 2", "Outro"], lanes: lanes, loop: song),
        ]),
        "house.h6": (silver: [
            L.silver("Make it yours",
                     "Your own groove, bass and sound, with balanced levels."),
            L.make("Your groove", "Keep four on the floor.", tracks: [.kick, .clap, .hat, .openHat, .perc],
                   edit: [.clap, .hat, .openHat, .perc], start: kick4, goal: .atLeast(.hat, 4)),
            L.bassMake("Your bass", "At least six notes.", backing: beat, notes: 6),
            K.lab("Your bass sound", "Shape it.", [.bassCutoff, .bassEnv, .bassDecay], start: [0.5, 0.5, 0.5], loop: bassLoop),
            K.mix("Balance it", "Kick, bass and chords.", [.drum(.kick), .bass, .chords], start: [K.u, K.u, K.u], loop: song),
        ], gold: [
            L.gold("Finish it",
                   "One to two minutes, two transitions, a hook people remember, and a clean ending."),
            L.make("Your groove", "Every drum.", tracks: [.kick, .clap, .hat, .openHat, .perc],
                   edit: [.kick, .clap, .hat, .openHat, .perc], start: kick4, goal: .atLeast(.kick, 4)),
            L.bassMake("Your bass", "At least six notes.", backing: beat, notes: 6),
            K.lane("Your chords", "At least four stabs.", .create(.chordsAtLeast(4)), palette: [.am7, .dm7, .fmaj7, .em7], backing: bassGroove),
            K.leadMake("Your hook", "At least six notes.", rows: lead, backing: full, notes: 6),
            K.order("Your map", "Fourteen blocks.", .create(.variedSections), tiles: blocks() + [K.tile("Fill", fill)], slots: 14, barsEach: 2),
        ]),
    ]
}
