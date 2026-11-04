//
//  HouseCourse.swift
//  Groova
//
//  House units 3–6: sound design, melody & hooks, arrangement and house styles.
//  Units 1–2 live in Curriculum.swift.
//

import Foundation

nonisolated enum HouseCourse {
    static let rows = Curriculum.bassRows

    // Shared loops
    static let drums = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])
    static let bassline = [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(7, 36), NoteEvent(10, 33),
                           NoteEvent(13, 40), NoteEvent(14, 38, 2)]
    static let stabs = [K.ch(2, .am7), K.ch(6, .am7), K.ch(10, .dm7), K.ch(14, .dm7)]
    static let full = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], openHat: [],
                              bass: bassline, chords: stabs)
    static let kickLoop = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])
    static let bassLoop = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: bassline)
    static let stabLoop = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], chords: [K.ch(2, .am7, 4), K.ch(10, .dm7, 4)])
    static let padLoop = Pattern(kick: [0, 8], chords: [K.ch(0, .am7, 8), K.ch(8, .fmaj7, 8)])

    // MARK: Academy (Part 2)

    private static func pick(_ ids: String...) -> [Lesson] { Curriculum.lessons(ids, from: Curriculum.houseUnits) }
    private static let style = AcademyKit.house

    static let academy: [Unit] = [
        K.unit("house.a1", 1, "House Foundations", "Chicago, disco & the four-four",
               [AcademyKit.whatMakes(style)] + pick("house.u6.l1") + [AcademyKit.anatomy(style), AcademyKit.foundationsCheck(style)]),
        K.unit("house.a2", 2, "Drums & Groove", "Tops, shuffle & peak-time drums",
               [tops, shuffle] + pick("house.u6.l5", "house.u1.mastery")),
        K.unit("house.a3", 3, "Bass & Low End", "Bounce, tone, jack & acid",
               pick("house.u1.l4", "house.u3.l2", "house.u6.l2", "house.u6.l3", "house.u6.mastery")),
        K.unit("house.a4", 4, "Chords & Hooks", "Motifs, answers & soulful keys",
               pick("house.u3.l3", "house.mel.l2", "house.mel.l3", "house.mel.l4", "house.u6.l4", "house.mel.mastery")),
        K.unit("house.a5", 5, "Vocals & Sampling", "Chops, stabs & vocal hooks",
               [AcademyKit.chopIntro(style)].compactMap { $0 } + pick("house.mel.l5", "house.u2.l3")
                   + [AcademyKit.chopHook(style), AcademyKit.vocalMastery(style)].compactMap { $0 }),
        K.unit("house.a6", 6, "Arrangement", "Intros, drops & breakdowns",
               pick("house.u5.l2", "house.u5.l3", "house.u5.l4") + [AcademyKit.loopToTrack(style)] + pick("house.u5.mastery")),
        K.unit("house.a7", 7, "Mixing & Final Project", "Polish it, then finish a track",
               [AcademyKit.mixBalance(style), AcademyKit.mixPump(style), AcademyKit.mixSpace(style), AcademyKit.finalProject(style)]),
    ]

    static let tops = K.lesson("house.a2.tops", "Shakers & Tops", "The layer above the kick", "sparkles", .rhythm, 30, [
        K.intro("The tops",
                "Producers call everything above the kick and clap the tops: closed hats, open hats, shakers and rims. The kick is the same in almost every house track. The tops are where a groove gets its personality.",
                [.hat, .openHat, .perc],
                demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14], perc: [3, 11])),
        K.drumCopy("Copy the tops", "Closed hats just after each kick, open hats on the offbeats, and a rim before each clap.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14], perc: [3, 11])),
        K.drumMake("Design your own tops", "The kick and clap stay. Add hats, open hats and rims until it grooves.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]), goal: .atLeast(.hat, 4)),
    ])

    static let shuffleLoop = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: Array(0..<16))

    static let shuffle = K.lesson("house.a2.swing", "House Shuffle", "Swing, but just a touch", "metronome", .rhythm, 30, [
        K.intro("The shuffle",
                "Classic house was programmed on drum machines with a touch of swing on the hats. Not garage-heavy, just enough that the sixteenths lean and the groove feels human instead of robotic.",
                [.hat], demo: shuffleLoop),
        K.quiz("How much swing?", "None, a touch, or heavy? Listen to the hats.", [
            K.hear([shuffleLoop], ["None", "A touch", "Heavy"], 0, swing: 0),
            K.hear([shuffleLoop], ["None", "A touch", "Heavy"], 1, "A touch: that's the house shuffle.", swing: 0.12),
            K.hear([shuffleLoop], ["None", "A touch", "Heavy"], 2, "Heavy swing, garage style.", swing: 0.33),
        ]),
        K.swingMake("Give the hats a house shuffle", "Just a touch, so the hats lean without limping.",
                    tracks: [.kick, .clap, .hat], start: shuffleLoop, atLeast: 0.08),
    ])

    static let units: [Unit] = [unit3, melodyUnit, unit5, unit6]

    // MARK: Unit 3 — Shape Your Sound

    static let unit3 = K.unit("house.u3", 3, "Shape Your Sound", "Kick, bass, stabs & pads", [
        K.lesson("house.u3.l1", "Tune the Kick", "Pitch and length", "circle.circle.fill", .soundDesign, 30, [
            K.lab("Explore the kick", "Pitch sets how deep the kick sounds. Length sets how long it booms.",
                  [.kickPitch, .kickDecay], start: [0.32, 0.31], loop: kickLoop),
            K.lab("Match the deep, boomy kick", "Low and long. Think big club speakers.",
                  [.kickPitch, .kickDecay], start: [0.6, 0.2], target: [0.12, 0.65], loop: kickLoop),
            K.lab("Match the tight, punchy kick", "Higher and short. It snaps instead of booming.",
                  [.kickPitch, .kickDecay], start: [0.15, 0.6], target: [0.5, 0.1], loop: kickLoop),
        ]),
        K.lesson("house.u3.l2", "Bass Tone", "Cutoff and envelope", "waveform", .soundDesign, 30, [
            K.lab("Explore the bass", "Cutoff makes the bass darker or brighter. Envelope adds a 'wow' at the start of each note.",
                  [.bassCutoff, .bassEnv], start: [0.34, 0.38], loop: bassLoop),
            K.lab("Match the dark, round bass", "Soft and deep, felt more than heard.",
                  [.bassCutoff, .bassEnv], start: [0.6, 0.6], target: [0.12, 0.1], loop: bassLoop),
            K.lab("Match the bright, rubbery bass", "Lots of bite at the start of each note.",
                  [.bassCutoff, .bassEnv], start: [0.15, 0.15], target: [0.5, 0.75], loop: bassLoop),
        ]),
        K.lesson("house.u3.l3", "Short or Long", "Chord length", "timer", .soundDesign, 30, [
            K.lab("Explore chord length", "Short chords are stabs. Long chords hold and fill the space.",
                  [.chordDecay], start: [0.3], loop: stabLoop),
            K.lab("Match the short stab", "Tight and percussive, like a hit.",
                  [.chordDecay], start: [0.75], target: [0.08], loop: stabLoop),
            K.lab("Match the long chord", "Let it ring right up to the next one.",
                  [.chordDecay], start: [0.1], target: [0.85], loop: stabLoop),
        ]),
        K.lesson("house.u3.l4", "Resonance", "The squelch", "dial.high.fill", .soundDesign, 30, [
            K.lab("Explore resonance", "Resonance boosts the frequencies right at the cutoff. Turn it up for a whistle or squelch.",
                  [.bassCutoff, .bassResonance], start: [0.4, 0.3], loop: bassLoop),
            K.lab("Match the squelchy bass", "Resonance high, cutoff low-ish.",
                  [.bassCutoff, .bassResonance], start: [0.65, 0.1], target: [0.3, 0.85], loop: bassLoop),
            K.filterMatch("Match the whole-groove filter", "Same idea on the whole track: find the cutoff and the resonance.",
                          cutoff: 900, resonance: 0.7, full),
        ]),
        K.lesson("house.u3.l5", "Pads & Plucks", "Attack and release", "cloud.fill", .soundDesign, 30, [
            K.lab("Explore attack and release", "Attack is how slowly a chord fades in. Release is how long it lingers after.",
                  [.chordAttack, .chordRelease], start: [0.1, 0.2], loop: padLoop),
            K.lab("Match the soft pad", "Slow to arrive and slow to leave.",
                  [.chordAttack, .chordRelease], start: [0.05, 0.1], target: [0.8, 0.7], loop: padLoop),
            K.lab("Match the pluck", "Instant start, quick finish.",
                  [.chordAttack, .chordRelease], start: [0.7, 0.7], target: [0.0, 0.12], loop: padLoop),
        ]),
        K.mastery("house.u3.mastery", "Sound Design Mastery", "Match three sounds by ear", .soundDesign, 70, [
            K.lab("Match this kick", "Pitch, length, and Drive, which adds crunch.",
                  [.kickPitch, .kickDecay, .kickDrive], start: [0.6, 0.2, 0.1], target: [0.25, 0.5, 0.45], loop: kickLoop),
            K.lab("Match this bass", "Three knobs this time.",
                  [.bassCutoff, .bassEnv, .bassResonance], start: [0.6, 0.15, 0.1], target: [0.25, 0.6, 0.55], loop: bassLoop),
            K.lab("Match this pad", "How it fades in and out, and how bright it is. Cutoff sets the brightness.",
                  [.chordAttack, .chordRelease, .chordCutoff], start: [0.0, 0.1, 0.8], target: [0.6, 0.65, 0.35], loop: padLoop),
        ]),
    ])

    // MARK: Unit 5 — Build a Track

    static let unit5 = K.unit("house.u5", 5, "Build a Track", "Intro, drop, breakdown & fills", [
        K.lesson("house.u5.l1", "Sections", "A track is a story", "rectangle.split.3x1.fill", .arrangement, 35, [
            K.arrange("Strip the intro back to kick and hats",
                      "Columns are sections, rows are parts. In the Intro column, switch off the clap, bass and chords.", .rule, loop: full,
                      start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                      target: K.grid("xxxx", "-xxx", "xxxx", "-xxx", "-xxx")),
            K.arrange("Save the bass for the drop",
                      "Switch the bass on in the Drop column only.", .rule, loop: full,
                      start: K.grid("xxx-", "-xx-", "xxxx", "----", "-xxx"),
                      target: K.grid("xxx-", "-xx-", "xxxx", "--x-", "-xxx")),
            K.arrange("Arrange your own four sections",
                      "Every section needs something playing, and each one should be different from the last.",
                      .create(.variedSections), loop: full,
                      start: K.grid("x---", "----", "x---", "----", "----")),
        ]),
        K.lesson("house.u5.l2", "The Intro", "Start small", "arrow.up.right", .arrangement, 35, [
            K.arrange("Hats first, kick from the build",
                      "Intro: hats only. Build: add the kick. Leave the drop and break as they are.", .rule, loop: full,
                      start: K.grid("--x-", "--x-", "xxx-", "--x-", "--xx"),
                      target: K.grid("-xx-", "--x-", "xxx-", "--x-", "--xx")),
            K.arrange("Copy this intro", "Listen to which parts arrive in which section.", .recreate, loop: full,
                      start: K.grid("----", "----", "----", "----", "----"),
                      target: K.grid("-xx-", "--x-", "xxx-", "--x-", "-xxx")),
        ]),
        K.lesson("house.u5.l3", "The Drop", "Everything at once", "bolt.fill", .arrangement, 35, [
            K.arrange("Make the drop hit", "Switch every part on in the Drop.", .rule, loop: full,
                      start: K.grid("xx--", "-x--", "xx-x", "----", "---x"),
                      target: K.grid("xxx-", "-xx-", "xxxx", "--x-", "--xx")),
            K.arrange("Copy this build and drop", "The build adds one part at a time.", .recreate, loop: full,
                      target: K.grid("xxxx", "-xx-", "xxxx", "--x-", "-xx-")),
        ]),
        K.lesson("house.u5.l4", "The Breakdown", "Take the kick away", "pause.circle.fill", .arrangement, 35, [
            K.arrange("Clear the floor for the breakdown",
                      "In the Break, switch off the kick, clap and bass. Keep the chords.", .rule, loop: full,
                      start: K.grid("xxxx", "-xxx", "xxxx", "-xxx", "-xxx"),
                      target: K.grid("xxx-", "-xx-", "xxxx", "-xx-", "-xxx")),
            K.arrange("Copy this breakdown", "What's left when the kick drops out?", .recreate, loop: full,
                      target: K.grid("xxx-", "-xx-", "xxx-", "--x-", "xxxx")),
        ]),
        K.lesson("house.u5.l5", "Drum Fills", "Lead into the drop", "square.stack.3d.up.fill", .rhythm, 35, [
            K.drumRule("Roll claps into the next bar", "Fill the last beat with claps: steps 13, 14, 15 and 16.",
                       tracks: [.kick, .clap, .hat], edit: [.clap],
                       start: Pattern(kick: [0, 4, 8], clap: [4], hat: [2, 6, 10]),
                       target: Pattern(kick: [0, 4, 8], clap: [4, 12, 13, 14, 15], hat: [2, 6, 10])),
            K.drumCopy("Copy this fill", "The kick drops out for the last beat and the claps take over.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap],
                       start: Pattern(hat: [2, 6, 10, 14]),
                       target: Pattern(kick: [0, 4, 8], clap: [4, 11, 13, 14, 15], hat: [2, 6, 10, 14])),
            K.drumMake("Write your own fill", "Use the last beat (steps 13 to 16). Add at least 3 hits on the Rim row.",
                       tracks: [.kick, .clap, .hat, .perc], edit: [.clap, .perc],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4], hat: [2, 6, 10, 14]),
                       goal: .atLeast(.perc, 3)),
        ]),
        K.mastery("house.u5.mastery", "Arrangement Mastery", "Recreate a track by ear", .arrangement, 90, [
            K.arrange("Recreate this track", "Listen through all four sections. Use the section names as you go.",
                      .recreate, loop: full,
                      target: K.grid("-xx-", "--x-", "xxxx", "-xx-", "x-xx")),
        ]),
    ])

    // MARK: Unit 6 — House Styles

    static let discoBass = [NoteEvent(0, 33), NoteEvent(2, 45), NoteEvent(4, 33), NoteEvent(6, 45),
                            NoteEvent(8, 33), NoteEvent(10, 45), NoteEvent(12, 38), NoteEvent(14, 40)]
    static let acidLine = [NoteEvent(0, 33), NoteEvent(2, 33), NoteEvent(3, 45), NoteEvent(5, 33), NoteEvent(7, 43),
                           NoteEvent(8, 33), NoteEvent(10, 40), NoteEvent(11, 33), NoteEvent(13, 45), NoteEvent(14, 38)]

    static let unit6 = K.unit("house.u6", 6, "House Styles", "Disco, jackin', acid, soulful & peak time", [
        K.lesson("house.u6.l1", "Disco Shuffle", "Where house came from", "sparkles", .rhythm, 40, [
            K.swingMake("Give the hats a disco shuffle", "Push swing past 15% until the 16th hats skip.",
                        tracks: [.kick, .clap, .hat, .openHat],
                        start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14]),
                        atLeast: 0.15),
            K.bassCopy("Copy the octave disco bass", "It jumps between a low note and the same note an octave up.",
                       rows: rows, target: discoBass,
                       backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14])),
        ]),
        K.lesson("house.u6.l2", "Jackin' Bass", "Chicago bounce", "figure.dance", .theory, 40, [
            K.bassRule("Bass on every 16th after the kick", "Steps 2, 6, 10 and 14, on the bottom row.",
                       rows: rows, target: K.notes(33, [1, 5, 9, 13]),
                       backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])),
            K.bassCopy("Copy this jackin' bassline", "Short notes that chase the kick, then a climb at the end.",
                       rows: rows,
                       target: [NoteEvent(1, 33), NoteEvent(3, 33), NoteEvent(5, 33), NoteEvent(7, 36), NoteEvent(9, 33),
                                NoteEvent(11, 33), NoteEvent(13, 38), NoteEvent(15, 40)],
                       backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])),
            K.bassMake("Write your own jackin' line", "Short notes between the kicks. At least six.",
                       rows: rows, backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14]), notes: 6),
        ]),
        K.lesson("house.u6.l3", "Chicago Acid", "The 303 squelch", "waveform.path", .soundDesign, 40, [
            K.lab("Make it squelch", "Acid is all resonance and envelope. Match the reference.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.6, 0.1, 0.2], target: [0.2, 0.85, 0.75],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: acidLine)),
            K.bassCopy("Copy this acid line", "Busy 16ths with jumps up an octave. Listen for the high notes.",
                       rows: rows, target: acidLine, backing: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])),
        ]),
        K.lesson("house.u6.l4", "Soulful Keys", "Major 7th warmth", "pianokeys", .theory, 40, [
            K.build("Build Fmaj7: F, A, C and E", "Major 7ths sound warm and hopeful.", .fmaj7, low: 53, high: 67),
            K.quiz("Warm or moody?", "Major 7ths sound warm. Minor 7ths sound moodier.", [
                K.round([.fmaj7], ["Major 7th (warm)", "Minor 7th (moody)"], 0, "Fmaj7."),
                K.round([.am7], ["Major 7th (warm)", "Minor 7th (moody)"], 1, "Am7."),
                K.round([.cmaj7], ["Major 7th (warm)", "Minor 7th (moody)"], 0, "Cmaj7."),
            ]),
            K.lane("Copy this soulful progression", "Four chords, one per beat. It starts on Fmaj7.", .recreate,
                   palette: [.fmaj7, .em7, .dm7, .cmaj7], backing: drums,
                   target: [0: 0, 4: 1, 8: 2, 12: 3], length: 3),
        ]),
        K.lesson("house.u6.l5", "Peak Time", "Everything together", "flame.fill", .rhythm, 40, [
            K.drumCopy("Copy the peak-time drums", "Open hats on the offbeats, closed hats on every 16th in between.",
                       tracks: [.kick, .clap, .hat, .openHat], edit: [.hat, .openHat],
                       start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                       openHat: [2, 6, 10, 14])),
            K.lab("Make the kick peak-time", "Peak-time kicks hit hard: a little higher, short and driven.",
                  [.kickPitch, .kickDecay, .kickDrive], start: [0.2, 0.6, 0.1], target: [0.45, 0.25, 0.6], loop: full),
        ]),
        K.mastery("house.u6.mastery", "House Mastery", "A full peak-time groove", .rhythm, 100, [
            K.groove("Recreate this peak-time house groove",
                     reference: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                        openHat: [2, 6, 10, 14],
                                        bass: [NoteEvent(2, 33), NoteEvent(5, 33), NoteEvent(6, 45), NoteEvent(10, 33),
                                               NoteEvent(13, 38), NoteEvent(14, 40, 2)]),
                     tracks: [.kick, .clap, .hat, .openHat], rows: rows),
        ]),
    ])
}
