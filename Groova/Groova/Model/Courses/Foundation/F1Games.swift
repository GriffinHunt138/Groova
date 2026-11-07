//
//  F1Games.swift
//  Groova
//
//  F1, Rhythm & Groove, in the Teach → Studio → Game flow:
//
//  F1.1 Find the Beat      → Downbeat Hunter   F1.2 Divide Time       → Time Slicer
//  F1.3 Kick, Snare, Hat   → Drum Forensics    F1.4 Move Off the Beat → Gravity Groove
//  F1.5 Give It a Feel     → Groove DNA
//

import Foundation

nonisolated enum F1Games {
    typealias F = FKit

    static let lessons: [Lesson] = [f11, f12, f13, f14, f15]

    // MARK: Material

    /// A beat with a crash on the 1, so the downbeat stands out.
    static let anchor = Pattern(kick: F.quarters, clap: [4, 12], hat: F.eighths, openHat: [0])
    /// Beat 1 has no kick; the chord and bass changing there mark the bar instead.
    static let quietOne = Pattern(kick: [6, 10], clap: [4, 12], hat: F.eighths,
                                  bass: [NoteEvent(0, 36, 4)], chords: [K.ch(0, F.c, 6), K.ch(8, F.am, 6)])
    /// A lead pickup just before the bar, trying to fool you.
    static let pickupLoop = Pattern(kick: [0, 8], clap: [4, 12], hat: F.eighths, perc: [13, 14, 15],
                                    chords: [K.ch(0, F.f, 12)])
    /// Two beats of drums, then two beats of nothing.
    static let halfBreak = Pattern(kick: [0], hat: [0, 2, 4, 6])
    /// Melodic loops with no drums, for Gold.
    static let keysLoop = Pattern(bass: [NoteEvent(0, 41, 6), NoteEvent(8, 43, 6)], chords: [K.ch(0, F.f, 6), K.ch(8, F.g, 6)])
    static let bassLoop = Pattern(bass: [NoteEvent(0, 45, 3), NoteEvent(4, 45, 1), NoteEvent(6, 48, 2), NoteEvent(10, 43, 4)],
                                  chords: [K.ch(0, F.am, 14)])
    static let leadLoop = K.melody(K.tune([(0, 72, 3), (4, 69, 2), (6, 67, 2), (8, 64, 4), (12, 67, 2)]),
                                   over: Pattern(chords: [K.ch(0, F.c, 14)]))

    static let kickSnare = Pattern(kick: [0, 8], clap: [4, 12])
    static let groove16 = Pattern(kick: [0, 8], clap: [4, 12], hat: F.sixteenths)
    static let lazyGroove = Pattern(kick: [0, 7, 10], clap: [4, 12], hat: F.sixteenths)

    // MARK: - F1.1 Find the Beat → Downbeat Hunter

    static let hunterName = "Downbeat Hunter"
    static let hunterLine = "Turn the dial until its gold 1 locks onto the music."

    static let f11 = K.lesson("f1.1", "Find the Beat", "Beat one and the bar", "scope", .rhythm, 15, [
        K.opening("One beat feels like the start",
                  "Music has a steady beat, but one beat in every bar feels like the beginning. First you'll mark beat one in a real drum roll. Then you'll hunt it down with a dial that has to lock onto the music."),
        K.teach("1, 2, 3, 4, and around again",
                "Listen to the crash. It lands on the first of every four beats. The pulse keeps going evenly, but that first beat, the downbeat, is where each bar starts.",
                demo: anchor),
        K.drumRule("Mark the bar",
                   "One bar, four beats. Put a kick on 1, snares on 2 and 4 (steps 5 and 13), and a hat on every beat (1, 5, 9, 13). When it loops, the kick on step 1 is where the bar restarts.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                   target: Pattern(kick: [0], clap: [4, 12], hat: F.quarters)),
        K.game(hunterName, hunterLine, .downbeat([
            DownbeatRound(title: "Hear the anchor", body: "Watch the light go round the dial once a bar. Hit LOCK every time it lands on the gold 1.",
                          mode: .anchor, loop: anchor, bars: 5, bpm: 92),
            DownbeatRound(title: "Turn to align", body: "The dial is one beat out. Its 1 clicks in the wrong place. Turn it until the click lands on the crash.",
                          mode: .align(offset: 1), loop: anchor, bpm: 92),
            DownbeatRound(title: "Catch the restart", body: "No numbers now, and the clip starts mid-bar. Listen for the crash and LOCK on every 1.",
                          mode: .lock(startBeat: 2), loop: anchor, bars: 5, bpm: 92),
        ])),
    ])

    static let f11Silver: [LessonStep] = [
        L.silver("Follow the hidden structure",
                 "The 1 is harder to find when no drum points it out. First copy a beat that skips the kick on beat one. Then find the bar by the chords, dodge a pickup, and keep counting through a break."),
        K.teach("The chords know where the bar starts",
                "There's no kick on beat one here, but the chord and bass change right there. Harmony can mark the downbeat even when the drums don't.",
                demo: quietOne),
        K.drumCopy("No kick on the 1",
                   "Hats and snares are in. Play the reference and add the two kicks you hear. Neither is on beat one.",
                   tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: F.eighths),
                   target: Pattern(kick: [6, 10], clap: [4, 12], hat: F.eighths)),
        K.game(hunterName, hunterLine, .downbeat([
            DownbeatRound(title: "No obvious kick", body: "Beat one has no kick. LOCK where the chord changes, which is where the bar begins.",
                          mode: .lock(startBeat: 1), loop: quietOne, bars: 5, bpm: 90),
            DownbeatRound(title: "Pickup trap", body: "Three quick notes come just before the bar. Turn the dial to the real 1, not the first note you hear.",
                          mode: .align(offset: 3), loop: pickupLoop, bpm: 90),
            DownbeatRound(title: "Through the break", body: "In bar 3 the drums stop halfway. Keep counting and LOCK the 1 when they come back.",
                          mode: .follow(breakBars: [2]), loop: F.groove, breakLoop: halfBreak, bars: 5, bpm: 96),
        ])),
    ]

    static let f11Gold: [LessonStep] = [
        L.gold("Establish the downbeat",
               "Now you decide where the phrase begins. First accent a downbeat in the drum roll. Then pick a melodic loop with no drums, find its 1, and announce every bar with a kick and crash."),
        K.teach("Accents make a bar audible",
                "A kick and a crash on beat one tell everyone, \"the bar starts here\". Without them the phrase floats. With them it lands.",
                demo: Pattern(kick: [0], openHat: [0], bass: [NoteEvent(0, 41, 6), NoteEvent(8, 43, 6)],
                              chords: [K.ch(0, F.f, 6), K.ch(8, F.g, 6)])),
        K.drumRule("Accent the 1",
                   "An empty drum lane under a melody. Put a kick and an open hat on step 1 only, then hear the bar snap into place.",
                   tracks: [.kick, .openHat], edit: [.kick, .openHat], target: Pattern(kick: [0], openHat: [0])),
        K.game(hunterName, "Pick a loop, then announce every bar.", .downbeat([
            DownbeatRound(title: "Choose and align", body: "Pick a loop and listen for its natural start. Then turn the dial until the 1 clicks with it.",
                          mode: .align(offset: 2), loop: keysLoop, bpm: 92,
                          choices: [("Keys", keysLoop), ("Bass", bassLoop), ("Lead", leadLoop)]),
            DownbeatRound(title: "Set the anchor", body: "Your LOCK button is now a kick and a crash. Hit it on every downbeat of your loop.",
                          mode: .accent, loop: keysLoop, bars: 5, bpm: 92,
                          choices: [("Keys", keysLoop), ("Bass", bassLoop), ("Lead", leadLoop)]),
            DownbeatRound(title: "Reveal your version", body: "One more take, a little faster. Then hear the loop with your accents on it.",
                          mode: .accent, loop: keysLoop, bars: 5, bpm: 96,
                          choices: [("Keys", keysLoop), ("Bass", bassLoop), ("Lead", leadLoop)]),
        ])),
    ]

    // MARK: - F1.2 Divide Time → Time Slicer

    static let slicerName = "Time Slicer"
    static let slicerLine = "Swipe a beat to slice it. Every slice is a hat."

    static let f12 = K.lesson("f1.2", "Divide Time", "Quarters, eighths and sixteenths", "divide", .rhythm, 15, [
        K.opening("One beat, many pieces",
                  "One beat can hold one hit, two hits, or four quick ones. First you'll see them as quarters, eighths and sixteenths in the drum roll. Then you'll slice glowing beats with your finger and hear every cut."),
        K.teach("Same beat, more pieces",
                "First one hat per beat, then two, then four. The kick doesn't speed up. Each beat just gets cut into smaller pieces.",
                pads: [.hat], demo: Pattern(kick: F.quarters, hat: [0, 4, 6, 8, 9, 10, 11])),
        K.drumRule("Three densities",
                   "Put hats on 1, 5, 9 and 13 for quarters. Then fill in 3, 7, 11 and 15 for eighths. Play it after each step and hear it get busier without getting faster.",
                   tracks: [.kick, .hat], edit: [.hat], start: Pattern(kick: F.quarters),
                   target: Pattern(kick: F.quarters, hat: F.eighths)),
        K.game(slicerName, slicerLine, .slicer([
            SliceRound(title: "Split in half", body: "Four whole beats over a kick. Swipe down on each one to cut it in two. Hear the hats double.",
                       mode: .match, target: [2, 2, 2, 2], backing: Pattern(kick: F.quarters)),
            SliceRound(title: "Slice into four", body: "Now cut each half again, so every beat holds four. The kick stays at the same speed.",
                       mode: .match, start: [2, 2, 2, 2], target: [4, 4, 4, 4], backing: Pattern(kick: F.quarters)),
            SliceRound(title: "Slice the target", body: "No ticks to copy. Hear the target, then slice each beat to match it.",
                       mode: .match, target: [1, 2, 4, 2], showTarget: false, backing: Pattern(kick: F.quarters)),
        ])),
    ])

    static let f12Silver: [LessonStep] = [
        L.silver("Cut a rhythm by ear",
                 "You can mix slices inside one bar instead of speeding everything up. First transcribe a mixed rhythm in the drum roll. Then match references by ear and repair a slice that doesn't belong."),
        K.teach("Mix the divisions",
                "Beat 1 is whole, beat 2 is in halves, beat 3 is in quarters, beat 4 rests. One bar, three speeds of hat.",
                pads: [.hat], demo: Pattern(kick: [0, 8], clap: [4, 12], hat: [0, 4, 6, 8, 9, 10, 11])),
        K.drumCopy("Copy the mixed bar",
                   "Play the reference. One hat on beat 1, two on beat 2, four on beat 3, none on beat 4.",
                   tracks: [.kick, .clap, .hat], edit: [.hat], start: kickSnare,
                   target: Pattern(kick: [0, 8], clap: [4, 12], hat: [0, 4, 6, 8, 9, 10, 11])),
        K.game(slicerName, slicerLine, .slicer([
            SliceRound(title: "Mixed slices", body: "Hear the target. Some beats stay whole, some split in two, and one splits into four.",
                       mode: .match, target: [1, 2, 4, 1], showTarget: false),
            SliceRound(title: "The false slice", body: "One beat has been cut too many times. Swipe up or double-tap it to join it back.",
                       mode: .fix, start: [2, 4, 2, 2], target: [2, 2, 2, 2], showTarget: false),
            SliceRound(title: "Quarter, eighth, eighth, sixteenth", body: "Follow the gold ticks while the loop keeps moving. Don't stop it.",
                       mode: .match, target: [1, 2, 2, 4], bpm: 104),
        ])),
    ]

    static let f12Gold: [LessonStep] = [
        L.gold("Make a dynamic rhythm",
               "Shape a rhythm's energy without touching the tempo. First build a hat line that gets busier in the drum roll. Then sculpt slices into a rising, falling or wave-shaped bar."),
        K.teach("Density is energy",
                "Sparse hits leave room to breathe. Dense hits push forward. Going from quarters to sixteenths in one bar feels like a run-up.",
                pads: [.hat], demo: Pattern(kick: [0, 8], clap: [4, 12], hat: [0, 4, 6, 8, 10, 12, 13, 14, 15])),
        K.drumMake("Build a run-up",
                   "Over the kick and snare, write a hat line that starts sparse and gets busier by the end of the bar. Use at least seven hats.",
                   tracks: [.kick, .clap, .hat], edit: [.hat], start: kickSnare, goal: .atLeast(.hat, 7)),
        K.game(slicerName, "Sculpt the energy across four beats.", .slicer([
            SliceRound(title: "Warm up the blade", body: "Calm to busy by ear: hear the target and slice to match it.",
                       mode: .match, target: [1, 2, 4, 4], showTarget: false, backing: F.beatNoHats),
            SliceRound(title: "Choose an energy curve", body: "Pick rising, falling or wave. Then slice so the bar follows it, with at least one whole beat and one beat in quarters.",
                       mode: .shape, backing: F.beatNoHats),
            SliceRound(title: "Make the beat breathe", body: "A new groove underneath. Pick another shape and sculpt it.",
                       mode: .shape, backing: Pattern(kick: [0, 7, 10], clap: [4, 12]), bpm: 100),
        ])),
    ]

    // MARK: - F1.3 Kick, Snare, Hat → Drum Forensics

    static let echoName = "Echo"
    static let playName = "Play Along"
    static let forensicsName = "Drum Forensics"
    static let forensicsLine = "A dark console. Solve which drum is which."

    static let f13 = K.lesson("f1.3", "Kick, Snare, Hat", "Three jobs in every kit", "circle.grid.2x2.fill", .rhythm, 15, [
        K.opening("Three suspects",
                  "Kick, snare and hi-hat each have a different job in a beat. First you'll build them in their own lanes. Then you'll play kick and snare along with the band."),
        K.teach("Low, crack, tick",
                "Tap each pad. The kick is a low thump you feel. The snare is a sharp crack on 2 and 4. The hat is a bright, high tick that keeps time.",
                pads: [.kick, .clap, .hat], demo: F.beat),
        K.drumRule("One lane per job",
                   "Kick on 1 and 9, snare on 5 and 13, hats on every odd step. Press play and watch which lane flashes for each sound.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], target: F.beat),
        K.game(playName, "Notes fall to the line. Hit them as they land.", .playAlong(PlayAlongConfig(
            lanes: [.kick, .clap], groove: F.beat, bars: 6, bpm: 85))),
    ])

    static let f13Silver: [LessonStep] = [
        L.silver("Solve a disguised mix",
                 "Real kits don't all sound alike, so the job matters more than the sample. First copy a groove where the kick moves around. Then play along while the kick moves, and keep going when the notes disappear."),
        K.teach("Same job, different sound",
                "Same pattern, different kit. The kick still sits low, the snare still cracks on 2 and 4, the hats still tick on top.",
                pads: [.kick, .clap, .hat], demo: Pattern(kick: [0, 3, 8, 11], clap: [4, 12], hat: F.eighths)),
        K.drumCopy("Find the moving kick",
                   "Snare and hats are in. The kick lands in four places, two of them between beats. Copy it by ear.",
                   tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: F.eighths),
                   target: Pattern(kick: [0, 3, 8, 11], clap: [4, 12], hat: F.eighths)),
        K.game(playName, "The kick moves. Halfway through, the notes vanish.", .playAlong(PlayAlongConfig(
            lanes: [.kick, .clap], groove: Pattern(kick: [0, 3, 8, 11], clap: [4, 12], hat: F.eighths),
            bars: 8, bpm: 88, ghostFrom: 5))),
    ]

    static let f13Gold: [LessonStep] = [
        L.gold("Conduct a drum entrance",
               "You're casting the rhythm section and bringing it on stage. First write the beat. Then play all three drums along with the band, the last bars by feel."),
        K.teach("Notes and sounds are separate choices",
                "The same notes can trigger any sound. Swap the kick sample and the pattern stays, but the whole beat changes character.",
                pads: [.kick, .clap, .hat], demo: F.beat),
        K.drumMake("Write the beat you'll cast",
                   "Write one bar using kick, snare and hats. In the game you'll choose their sounds and stage their entrance.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], goal: .atLeast(.kick, 2)),
        K.game(playName, "All three drums. The last bars are yours to feel.", .playAlong(PlayAlongConfig(
            lanes: [.kick, .clap, .hat], groove: Pattern(kick: [0, 8, 10], clap: [4, 12], hat: [0, 4, 8, 12]),
            bars: 8, bpm: 92, ghostFrom: 5))),
    ]

    // MARK: - F1.4 Move Off the Beat → Gravity Groove

    static let gravityName = "Gravity Groove"
    static let gravityLine = "Throw the snare so it lands between the bounces."

    static let f14 = K.lesson("f1.4", "Move Off the Beat", "Offbeats and syncopation", "arrow.right.to.line", .rhythm, 15, [
        K.opening("The spaces between",
                  "Some of the best surprises happen between the main beats. First you'll slide a clap between beat lines in the drum roll. Then you'll throw a snare puck so it lands in the gaps while the kick bounces on the beat."),
        K.teach("On the beat, then between",
                "The kick lands on every beat. Now hear a clap halfway between beats 2 and 3. That in-between spot is an offbeat, and it pushes the groove forward.",
                demo: Pattern(kick: F.quarters, clap: [6])),
        K.drumRule("Slide the clap",
                   "Kicks are on every beat. Put a clap on step 7, the \"and\" after beat 2. Try it on step 5, then put it back on 7 and hear the push.",
                   tracks: [.kick, .clap], edit: [.clap], start: Pattern(kick: F.quarters),
                   target: Pattern(kick: F.quarters, clap: [6])),
        K.game(gravityName, gravityLine, .gravity([
            GravityRound(title: "See the bounce", body: "The kick puck bounces on every beat. Hold the pink launcher and let go. The snare lands one beat later. Land four.",
                         mode: .watch),
            GravityRound(title: "Throw between", body: "Land a snare in the gold zone, between beats 2 and 3, in each bar. Let go one beat before it.",
                         mode: .land(steps: [6], showZone: true)),
            GravityRound(title: "Beat or between?", body: "Two snares a bar: one on beat 2 with the kick, one between beats 3 and 4. Hear which one pushes.",
                         mode: .land(steps: [4, 10], showZone: true)),
        ])),
    ])

    static let f14Silver: [LessonStep] = [
        L.silver("Land without the guide",
                 "The landing zones are going away. First transcribe two offbeat claps in the drum roll. Then land snares by ear and bounce, and copy a surprise hit."),
        K.teach("Surprise against a steady pulse",
                "Syncopation only works because the pulse stays put. The kick holds still and the claps dodge around it.",
                demo: Pattern(kick: F.quarters, clap: [2, 10])),
        K.drumCopy("Copy the offbeat claps",
                   "The kick is locked. Play the reference and add the two claps. Neither is on a beat.",
                   tracks: [.kick, .clap], edit: [.clap], start: Pattern(kick: F.quarters),
                   target: Pattern(kick: F.quarters, clap: [2, 10])),
        K.game(gravityName, gravityLine, .gravity([
            GravityRound(title: "Invisible zone", body: "No gold zones. Land snares on the \"and\" after beat 2 and after beat 4.",
                         mode: .land(steps: [6, 14], showZone: false)),
            GravityRound(title: "On, off, on, off", body: "Four snares a bar: on beat 1, after beat 2, on beat 3, after beat 4. Keep the tempo.",
                         mode: .land(steps: [0, 6, 8, 14], showZone: false), bpm: 84),
            GravityRound(title: "Catch the surprise", body: "Hear two bars of kick and clap. Then copy only the claps, one of which lands where you don't expect.",
                         mode: .copy(steps: [4, 10])),
        ])),
    ]

    static let f14Gold: [LessonStep] = [
        L.gold("Create your own syncopation",
               "Turn offbeat landings into a groove of your own. First write a syncopated clap line in the drum roll. Then perform snare throws, and compare them with a version on the beats."),
        K.teach("Grounded and surprising",
                "The best grooves mix both: some hits on the beat to stand on, some between to lean against. There isn't one right answer.",
                demo: Pattern(kick: F.quarters, clap: [4, 7, 14], hat: F.eighths)),
        K.drumMake("Write your syncopation",
                   "Kicks are on every beat. Add at least three claps, with most of them between the beats.",
                   tracks: [.kick, .clap, .hat], edit: [.clap], start: Pattern(kick: F.quarters, hat: F.eighths),
                   goal: .atLeast(.clap, 3)),
        K.game(gravityName, "Perform four bars of your own offbeats.", .gravity([
            GravityRound(title: "Sparse pocket", body: "Kicks only. Throw two bars of snares, with at least two landing between the beats.",
                         mode: .perform, bars: 2),
            GravityRound(title: "Perform the offbeats", body: "Four bars over a fuller beat. Mix on-beat and between-beat landings.",
                         mode: .perform, kick: Pattern(kick: F.quarters, hat: F.eighths), bars: 4),
            GravityRound(title: "Hear the difference", body: "One more run, a little faster. Then compare yours with every snare moved onto the beats.",
                         mode: .perform, kick: Pattern(kick: F.quarters, hat: F.eighths), bars: 4, bpm: 96),
        ])),
    ]

    // MARK: - F1.5 Give It a Feel → Groove DNA

    static let dnaName = "Groove DNA"
    static let dnaLine = "Stretch the ribbon. Same notes, new feel."

    static let f15 = K.lesson("f1.5", "Give It a Feel", "Boss: swing and accents", "crown.fill", .rhythm, 30, [
        K.opening("Same notes, different groove",
                  "Two beats can use exactly the same notes and still feel completely different. First you'll add swing to a real drum roll. Then you'll stretch a living groove ribbon and shape its accents with your fingers."),
        K.teach("Straight, then swung",
                "The same sixteenth hats, played straight and then with every second one pushed late. Nothing moved on the grid, but now it bounces.",
                pads: [.hat], demo: groove16),
        K.swingMake("Swing the drum roll",
                    "Same notes. Drag the swing control up until the hats lope, past about a sixth of the way.",
                    tracks: [.kick, .clap, .hat], start: groove16, atLeast: 0.15),
        K.game(dnaName, dnaLine, .grooveDNA([
            DNARound(title: "Straight vs swung", body: "Drag the ribbon right. Every second dot slides later and you hear the hats start to skip.",
                     mode: .swing(target: nil)),
            DNARound(title: "Accent wave", body: "Tap beats 2 and 4 to make their hats loud. The notes stay put, only the push changes.",
                     mode: .accent(target: [1, 3])),
            DNARound(title: "Match the swing", body: "Hear the target, then stretch the ribbon into the gold band.",
                     mode: .swing(target: 0.3)),
        ])),
    ])

    static let f15Silver: [LessonStep] = [
        L.silver("Build and recognise a feel",
                 "A groove's feel lives in small details. First swing a new groove in the drum roll. Then match a feel by ear, fix flat accents, and find out what too much swing does."),
        K.teach("Spacing and weight",
                "Swing changes how far apart the notes are. Accents change how hard they hit. Neither one changes the tempo.",
                pads: [.hat], demo: lazyGroove),
        K.swingMake("Find the pocket",
                    "This groove has a lazy kick. Bring the swing up to around 60%, then play it and nod along.",
                    tracks: [.kick, .clap, .hat], start: lazyGroove, atLeast: 0.18),
        K.game(dnaName, dnaLine, .grooveDNA([
            DNARound(title: "Blind swing match", body: "No gold band this time. Hear the target and stretch the ribbon until yours feels the same.",
                     mode: .swing(target: 0.22), groove: lazyGroove, showRange: false),
            DNARound(title: "Fix the stiffness", body: "Every hat is the same volume. Hear the target and accent the beats that jump out.",
                     mode: .accent(target: [0, 2]), groove: lazyGroove),
            DNARound(title: "Too far, then back", body: "Push the swing past 70% and hear it fall apart. Then pull it back into a groove between 55 and 65%.",
                     mode: .sloppy, groove: lazyGroove),
        ])),
    ]

    static let f15Gold: [LessonStep] = [
        L.gold("Design a groove fingerprint",
               "Give a rhythm its own identity. First set a feel in the drum roll. Then make two different feels from the exact same notes, and pick your favourite without peeking."),
        K.teach("Subtle is powerful",
                "These two grooves use identical notes. One is straight and even, the other leans with swing and accents. You can feel the difference before you can name it.",
                pads: [.hat], demo: groove16),
        K.swingMake("Set your feel",
                    "Your groove, your swing. Set it anywhere you like past a touch.",
                    tracks: [.kick, .clap, .hat], start: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.sixteenths), atLeast: 0.08),
        K.game(dnaName, "Two feels, one set of notes.", .grooveDNA([
            DNARound(title: "Set the lean", body: "Stretch the ribbon until this groove makes you want to move. Then lock it.",
                     mode: .swing(target: nil), groove: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.sixteenths)),
            DNARound(title: "Two fingerprints", body: "Set a feel and save it as A. Change the swing or accents and save B. Then pick your favourite blind.",
                     mode: .fingerprint, groove: Pattern(kick: [0, 7, 8], clap: [4, 12], hat: F.sixteenths)),
            DNARound(title: "One more identity", body: "A new beat. Make two feels again and find out which one you really prefer.",
                     mode: .fingerprint, groove: lazyGroove, bpm: 96),
        ])),
    ]

    static let levels: [String: LevelPair] = [
        "f1.1": (silver: f11Silver, gold: f11Gold),
        "f1.2": (silver: f12Silver, gold: f12Gold),
        "f1.3": (silver: f13Silver, gold: f13Gold),
        "f1.4": (silver: f14Silver, gold: f14Gold),
        "f1.5": (silver: f15Silver, gold: f15Gold),
    ]
}
