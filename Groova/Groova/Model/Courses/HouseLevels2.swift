//
//  HouseLevels2.swift
//  Groova
//
//  Hand-written Silver and Gold levels for House Units 3–6.
//

import Foundation

typealias LevelPair = (silver: [LessonStep], gold: [LessonStep])

nonisolated enum HouseLevels2 {
    typealias H = HouseCourse
    static let u = K.u
    static let full = H.full
    static let lanes5: [Instrument] = K.fullHouseLanes
    static let twoDrops = ["Intro", "Drop", "Break", "Drop 2"]

    static let all: [String: LevelPair] = [
        "house.u3.l1": u3l1, "house.u3.l2": u3l2, "house.u3.l3": u3l3, "house.u3.l4": u3l4, "house.u3.l5": u3l5,
        "house.u5.l1": u5l1, "house.u5.l2": u5l2, "house.u5.l3": u5l3, "house.u5.l4": u5l4, "house.u5.l5": u5l5,
        "house.u6.l1": u6l1, "house.u6.l2": u6l2, "house.u6.l3": u6l3, "house.u6.l4": u6l4, "house.u6.l5": u6l5,
    ]

    // MARK: Unit 3 — Shape Your Sound

    static let kick3: [SoundParam] = [.kickPitch, .kickDecay, .kickDrive]
    static let bass4: [SoundParam] = [.bassCutoff, .bassEnv, .bassResonance, .bassDecay]
    static let chord4: [SoundParam] = [.chordCutoff, .chordDecay, .chordAttack, .chordRelease]

    static let u3l1: LevelPair = (
        silver: [
            L.silver("kick drive",
                     "Pitch and length set a kick's body. Drive adds grit, so the kick cuts through even on phone speakers. These kicks use all three."),
            K.lab("Match the dirty, deep kick", "Low, long and gritty.", kick3,
                  start: [0.3, 0.3, 0.0], target: [0.2, 0.55, 0.6], loop: H.kickLoop),
            K.lab("Match the clicky kick", "Higher, short and clean.", kick3,
                  start: [0.2, 0.6, 0.5], target: [0.55, 0.15, 0.2], loop: H.kickLoop),
            K.lab("Match the in-between kick", "Neither boomy nor tight. Small moves now.", [.kickPitch, .kickDecay],
                  start: [0.5, 0.5], target: [0.35, 0.4], loop: H.kickLoop),
        ],
        gold: [
            L.gold("a kick for every style",
                   "Every style has its own kick. Techno likes long and distorted, tech house likes short and punchy, deep house likes soft and round. Match each one by ear."),
            K.lab("Match the techno kick", "Long, low and driven hard.", kick3,
                  start: [0.5, 0.2, 0.0], target: [0.15, 0.8, 0.75], loop: H.kickLoop),
            K.lab("Match the tech house kick", "Short and punchy with some bite.", kick3,
                  start: [0.2, 0.7, 0.6], target: [0.45, 0.2, 0.35], loop: H.kickLoop),
            K.lab("Match the deep house kick", "Soft, round and clean.", kick3,
                  start: [0.6, 0.2, 0.8], target: [0.25, 0.45, 0.05], loop: H.kickLoop),
            K.lab("Make it yours", "Design your signature kick. Move every knob and land on something you'd use.",
                  kick3, start: [0.5, 0.5, 0.5], loop: H.kickLoop),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("bass length",
                     "Cutoff and envelope set the tone. Length (decay) sets how long each note lasts, and that changes the groove as much as the notes do."),
            K.lab("Match the long, round bass", "Dark and held.", [.bassCutoff, .bassEnv, .bassDecay],
                  start: [0.3, 0.3, 0.5], target: [0.2, 0.2, 0.9], loop: H.bassLoop),
            K.lab("Match the short, plucky bass", "Bright attack, gone quickly.", [.bassCutoff, .bassEnv, .bassDecay],
                  start: [0.2, 0.2, 0.9], target: [0.55, 0.65, 0.15], loop: H.bassLoop),
        ],
        gold: [
            L.gold("bass for every style",
                   "Deep house bass is soft and long. Acid bass squelches. Garage bass is bright and short. Four knobs, three styles."),
            K.lab("Match the deep sub bass", "Barely any top end, long notes.", bass4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.1, 0.05, 0.1, 0.8], loop: H.bassLoop),
            K.lab("Match the acid bass", "Resonance and envelope do the talking.", bass4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.3, 0.8, 0.8, 0.3], loop: H.bassLoop),
            K.lab("Match the bright garage bass", "Open, short, a little resonance.", bass4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.6, 0.4, 0.2, 0.15], loop: H.bassLoop),
            K.lab("Make it yours", "Design your own bass tone with all four knobs.", bass4,
                  start: [0.5, 0.5, 0.5, 0.5], loop: H.bassLoop),
        ])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("attack and length",
                     "Length decides how long a chord rings. Attack decides how fast it arrives. Together they turn the same chord into a stab or a swell."),
            K.lab("Match the instant stab", "No fade-in and very short.", [.chordAttack, .chordDecay],
                  start: [0.5, 0.5], target: [0.0, 0.1], loop: H.stabLoop),
            K.lab("Match the swell", "Fades in, then holds.", [.chordAttack, .chordDecay],
                  start: [0.0, 0.1], target: [0.6, 0.7], loop: H.stabLoop),
            K.lab("Match the dark stab", "Short and muffled.", [.chordCutoff, .chordDecay],
                  start: [0.8, 0.6], target: [0.2, 0.15], loop: H.stabLoop),
        ],
        gold: [
            L.gold("the full chord envelope",
                   "Attack, length, release and brightness together make a sound's character. With four knobs you can make an organ, a pluck or a pad from one chord."),
            K.lab("Match the organ", "Instant, held and fairly bright.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.5, 0.9, 0.05, 0.2], loop: H.stabLoop),
            K.lab("Match the pluck", "Bright, instant, short tail.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.7, 0.1, 0.0, 0.15], loop: H.stabLoop),
            K.lab("Match the pad", "Dark, slow in and slow out.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.3, 0.8, 0.7, 0.8], loop: H.padLoop),
            K.lab("Make it yours", "Design your own chord sound.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], loop: H.stabLoop),
        ])

    static let u3l4: LevelPair = (
        silver: [
            L.silver("cutoff moves the peak",
                     "Resonance boosts whatever frequency the cutoff sits on. Move the cutoff and the peak moves with it, from a low growl to a high whistle."),
            K.lab("Match the high whistle", "Cutoff high, resonance up.", [.bassCutoff, .bassResonance],
                  start: [0.3, 0.2], target: [0.6, 0.7], loop: H.bassLoop),
            K.lab("Match the low growl", "Cutoff low, a medium peak.", [.bassCutoff, .bassResonance],
                  start: [0.6, 0.7], target: [0.15, 0.5], loop: H.bassLoop),
            K.filterMatch("Match the bright, peaky groove", "The whole track, cutoff fairly high with strong resonance.",
                          cutoff: 2200, resonance: 0.75, full),
        ],
        gold: [
            L.gold("resonance plus envelope",
                   "Add envelope to a resonant filter and every note sweeps the peak. That's the start of acid. Now you'll balance all three."),
            K.lab("Match the sweeping squelch", "Low cutoff, high resonance, lots of envelope.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.5, 0.2, 0.2], target: [0.25, 0.8, 0.7], loop: H.bassLoop),
            K.lab("Match the gentle wah", "Less envelope, the peak still there.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.2, 0.8, 0.8], target: [0.45, 0.6, 0.2], loop: H.bassLoop),
            K.filterMatch("Match the deep, resonant groove", "Very dark with a strong peak.",
                          cutoff: 500, resonance: 0.85, full),
            K.lab("Make it yours", "Design your own resonant bass.", [.bassCutoff, .bassResonance, .bassEnv, .bassDecay],
                  start: [0.5, 0.5, 0.5, 0.5], loop: H.bassLoop),
        ])

    static let u3l5: LevelPair = (
        silver: [
            L.silver("release tails",
                     "Release is how long a sound lingers after the note ends. A pluck with a long release floats. A swell with no release stops dead."),
            K.lab("Match the pluck with a long tail", "Instant start, rings on.", [.chordAttack, .chordRelease],
                  start: [0.5, 0.2], target: [0.0, 0.8], loop: H.padLoop),
            K.lab("Match the swell that stops", "Slow in, no tail.", [.chordAttack, .chordRelease],
                  start: [0.0, 0.8], target: [0.5, 0.1], loop: H.padLoop),
            K.lab("Match the dark pad", "Slow, long and muffled.", [.chordAttack, .chordRelease, .chordCutoff],
                  start: [0.1, 0.2, 0.8], target: [0.7, 0.7, 0.2], loop: H.padLoop),
        ],
        gold: [
            L.gold("pads that breathe",
                   "Great pads move slowly and leave room for the drums. Get the brightness right first, then the attack and tails."),
            K.lab("Match the shimmering pad", "Bright, slow and long.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.75, 0.6, 0.8, 0.9], loop: H.padLoop),
            K.lab("Match the soft keys", "Mellow, quick in, medium tail.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.4, 0.5, 0.1, 0.4], loop: H.padLoop),
            K.lab("Make it yours", "Design a pad you'd put in a breakdown.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], loop: H.padLoop),
        ])

    // MARK: Unit 5 — Build a Track

    static let u5l1: LevelPair = (
        silver: [
            L.silver("contrast between sections",
                     "Each section should feel different from its neighbours. The easiest way is to change which parts play: drop the kick, bring in the chords, strip back to hats."),
            K.arrange("Copy this four-section track", "Listen to what changes at each section.", .recreate, loop: full,
                      target: K.grid("-xxx", "--x-", "xxx-", "-xx-", "x-xx")),
            K.arrange("Make the Break hats and chords only", "In the Break, switch off the kick, clap and bass.", .rule,
                      loop: full, start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                      target: K.grid("xxx-", "xxx-", "xxxx", "xxx-", "xxxx")),
        ],
        gold: [
            L.gold("whole tracks by ear",
                   "Hear a track once through and picture the grid. Then check one part at a time across all four sections."),
            K.arrange("Recreate this track", "The Build drops the kick. The Drop has everything.", .recreate, loop: full,
                      target: K.grid("x-x-", "-xx-", "xxxx", "--x-", "xxxx")),
            K.arrange("Recreate this track", "This one builds slowly.", .recreate, loop: full,
                      target: K.grid("-xxx", "--xx", "x-xx", "-x-x", "xx-x")),
            K.arrange("Make it yours", "Five sections this time. Every one different from the last.",
                      .create(.variedSections), sections: ["Intro", "Build", "Drop", "Break", "Drop 2"], loop: full),
        ])

    static let u5l2: LevelPair = (
        silver: [
            L.silver("intros that hold back",
                     "House intros are mostly drums. Holding back the chords and bass gives the listener something to wait for."),
            K.arrange("Build a drums-first intro", "Intro: kick and hats only. Build: add the clap.", .rule, loop: full,
                      start: K.grid("--xx", "--xx", "--xx", "--xx", "--xx"),
                      target: K.grid("xxxx", "-xxx", "xxxx", "--xx", "--xx")),
            K.arrange("Copy this intro", "Drums first, then the music arrives.", .recreate, loop: full,
                      target: K.grid("xxxx", "-xx-", "xxxx", "--x-", "---x")),
        ],
        gold: [
            L.gold("intros that tease",
                   "Some intros hint at the drop: a few bars of chords before the drums, or a filtered bassline. Hear how each one teases what's coming."),
            K.arrange("Recreate the chord tease", "Chords open the track on their own.", .recreate, loop: full,
                      target: K.grid("-xxx", "--x-", "xxxx", "--xx", "x-xx")),
            K.arrange("Recreate the bass tease", "The bass arrives before the clap.", .recreate, loop: full,
                      target: K.grid("x-xx", "--xx", "xxx-", "-xx-", "--xx")),
            K.arrange("Make it yours", "Write your own intro and the rest of the track.", .create(.variedSections),
                      loop: full),
        ])

    static let u5l3: LevelPair = (
        silver: [
            L.silver("drops need a build",
                     "A drop feels bigger when the section before it held back. Empty the build and the drop lands harder."),
            K.arrange("Empty the Build so the Drop hits", "In the Build, switch everything off except the chords.", .rule,
                      loop: full, start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                      target: K.grid("x-xx", "x-xx", "x-xx", "x-xx", "xxxx")),
            K.arrange("Copy this build and drop", "Chords open it alone. The bass waits for the Drop.", .recreate, loop: full,
                      target: K.grid("-xx-", "--x-", "xxx-", "--xx", "x-xx")),
        ],
        gold: [
            L.gold("two drops",
                   "Most club tracks have two drops with a break between. The second drop often adds something new to feel bigger."),
            K.arrange("Recreate this two-drop track", "The Break is chords alone.", .recreate, sections: twoDrops, loop: full,
                      target: K.grid("-x-x", "-x-x", "xx-x", "-x-x", "x-xx")),
            K.arrange("Recreate this two-drop track", "The second drop brings in something the first didn't have.",
                      .recreate, sections: twoDrops, loop: full,
                      target: K.grid("xx-x", "-x-x", "xx-x", "-x-x", "--xx")),
            K.arrange("Make it yours", "Arrange two drops with a break in between.", .create(.variedSections),
                      sections: twoDrops, loop: full),
        ])

    static let u5l4: LevelPair = (
        silver: [
            L.silver("what stays in the break",
                     "A breakdown takes the kick away, but what's left decides the mood. Chords alone feel emotional. Bass and chords feel tense."),
            K.arrange("Keep only bass and chords in the Break", "Switch off the kick, clap and hats in the Break.", .rule,
                      loop: full, start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                      target: K.grid("xxx-", "xxx-", "xxx-", "xxxx", "xxxx")),
            K.arrange("Copy this breakdown", "The hats stay in this time.", .recreate, loop: full,
                      target: K.grid("xxx-", "-xx-", "xxxx", "--x-", "-xxx")),
        ],
        gold: [
            L.gold("the drop after the break",
                   "The break is half the story. The drop that follows hits hardest when the break was empty."),
            K.arrange("Recreate this section of a track", "The Break is chords alone. Hats return in the Build.", .recreate,
                      sections: ["Drop", "Break", "Build", "Drop 2"], loop: full,
                      target: K.grid("x--x", "x--x", "x-xx", "x--x", "xxxx")),
            K.arrange("Recreate this one", "The build brings the bass back early.", .recreate,
                      sections: ["Drop", "Break", "Build", "Drop 2"], loop: full,
                      target: K.grid("x--x", "x-xx", "x-xx", "x-xx", "xx-x")),
            K.arrange("Make it yours", "Write your own break and return.", .create(.variedSections),
                      sections: ["Drop", "Break", "Build", "Drop 2"], loop: full),
        ])

    static let u5l5: LevelPair = (
        silver: [
            L.silver("fill shapes",
                     "Fills come in shapes. Rolls get faster into the next bar, stops cut everything out, and pickups lead in with one hit. Hear each and copy it."),
            L.copy("Copy the roll", "Claps speed up through the last beat.", tracks: [.kick, .clap, .hat],
                   edit: [.clap], start: Pattern(kick: [0, 4, 8], hat: [2, 6, 10]),
                   target: Pattern(kick: [0, 4, 8], clap: [4, 10, 12, 14, 15], hat: [2, 6, 10])),
            L.copy("Copy the stop", "Everything drops out for the last beat except one clap.", tracks: [.kick, .clap, .hat],
                   edit: [.kick, .clap, .hat],
                   target: Pattern(kick: [0, 4, 8], clap: [4, 15], hat: [2, 6, 10])),
            L.make("Write a fill with rims", "Use the last beat. At least 4 rims.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.clap, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4], hat: [2, 6, 10, 14]), goal: .atLeast(.perc, 4)),
        ],
        gold: [
            L.gold("full-kit fills",
                   "Big fills use the whole kit: kick drops out, claps roll, percussion answers. Rebuild them part by part."),
            L.copy("Rebuild this full-kit fill", "Kick, clap, hats and rims all change in the last beat.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   target: Pattern(kick: [0, 4, 8, 11], clap: [4, 12, 13, 14, 15], hat: [2, 6, 10], perc: [9, 11, 13, 15]),
                   threshold: 0.9),
            L.copy("Copy the hat fill", "Hats speed up into the next bar.", tracks: [.kick, .clap, .hat],
                   edit: [.hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 12, 13, 14, 15]), threshold: 0.9),
            L.make("Make it yours", "Write a full-kit fill. At least 5 claps.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], start: Pattern(hat: [2, 6, 10]), goal: .atLeast(.clap, 5)),
        ])

    // MARK: Unit 6 — House Styles

    static let discoDrums = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14])
    static let jackDrums = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])
    static let acidDrums = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])

    static let u6l1: LevelPair = (
        silver: [
            L.silver("the disco groove",
                     "House grew out of disco: shuffled hats, open hats on the offbeat and an octave-jumping bass. These grooves move the octave line to new notes."),
            K.swingMake("Shuffle the disco hats", "Push swing past 20%.", tracks: [.kick, .clap, .hat, .openHat],
                        start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                       openHat: [2, 6, 10, 14]), atLeast: 0.2),
            L.bass("Copy the moving octave bass", "Octaves on A, then it walks to C and E.",
                   L.n([(0, 33), (2, 45), (4, 33), (6, 45), (8, 36), (10, 36), (12, 40), (14, 43)]), backing: discoDrums),
        ],
        gold: [
            L.gold("disco to house",
                   "Strip disco down to drums and bass, add a drum machine kick, and you get early Chicago house. Rebuild the whole groove."),
            K.swingMake("Heavy shuffle", "Push swing past 30%.", tracks: [.kick, .clap, .hat, .openHat],
                        start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14]),
                        atLeast: 0.3),
            L.bass("Copy the busy disco bass", "Octave jumps with an extra 16th.",
                   L.n([(0, 33), (2, 45), (3, 45), (4, 33), (6, 45), (8, 38), (10, 38), (11, 43), (12, 40), (14, 45)]),
                   backing: discoDrums, threshold: 0.9),
            L.copy("Rebuild the disco drums with rims", "Open hats on the offbeat, rims dancing around them.",
                   tracks: [.kick, .clap, .openHat, .perc], edit: [.kick, .clap, .openHat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14], perc: [3, 7, 11, 13]),
                   threshold: 0.9),
            L.bassMake("Make it yours", "Write a disco bassline with octave jumps. At least 8 notes.",
                       backing: discoDrums, notes: 8),
        ])

    static let u6l2: LevelPair = (
        silver: [
            L.silver("jack with length",
                     "Jackin' bass chases the kick. Hold some notes longer and the line starts to swing between short and long."),
            L.bass("Copy the jumping jack line", "Chasing the kick, with octave jumps.",
                   L.n([(1, 33), (5, 33), (7, 45), (9, 33), (13, 33), (15, 43)]), backing: jackDrums),
            L.bass("Copy the long jack line", "Each note holds for two steps.",
                   [NoteEvent(1, 33, 2), NoteEvent(5, 36, 2), NoteEvent(9, 33, 2), NoteEvent(13, 40, 2)], backing: jackDrums),
            L.bassMake("Write your own jack line", "At least 7 notes. Mix short and long.", backing: jackDrums, notes: 7),
        ],
        gold: [
            L.gold("Chicago jack",
                   "Jackin' tracks lock bass and percussion together. Write the bass, then hear how the drums answer it."),
            L.bass("Copy the full jack line", "Pairs of notes around every kick.",
                   L.n([(1, 33), (2, 33), (5, 36), (6, 33), (9, 33), (10, 38), (13, 40), (14, 43), (15, 45)]),
                   backing: jackDrums, threshold: 0.9),
            L.copy("Rebuild the jackin' drums", "Perc on the 16ths just after each kick and before each clap.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [1, 7, 9, 15]),
                   threshold: 0.9),
            L.bassMake("Make it yours", "A jack line with at least 9 notes.", backing: jackDrums, notes: 9),
        ])

    static let u6l3: LevelPair = (
        silver: [
            L.silver("acid length",
                     "Acid lines get their bite from short, resonant notes. Shorten the notes and the squelch becomes a stab."),
            K.lab("Match the short acid squelch", "Resonance high, notes short.", bass4,
                  start: [0.2, 0.85, 0.75, 0.5], target: [0.35, 0.85, 0.7, 0.2],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine)),
            L.bass("Copy this acid line", "Busy 16ths that jump up the octave.",
                   L.n([(0, 33), (1, 33), (3, 45), (4, 33), (6, 43), (8, 33), (9, 40), (11, 45), (12, 33), (14, 38)]),
                   backing: acidDrums),
        ],
        gold: [
            L.gold("full acid",
                   "Classic acid is a resonant filter, a busy line and a filter that moves. Match the sound, the filter and the line."),
            K.lab("Match the deepest squelch", "Dark cutoff, maximum resonance and envelope.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.5, 0.3, 0.3], target: [0.1, 0.9, 0.9],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine)),
            K.filterMatch("Match the acid filter", "The whole groove through a dark, resonant filter.",
                          cutoff: 700, resonance: 0.85, Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine)),
            L.bass("Copy the long acid line", "Eleven notes. Listen for every octave jump.",
                   L.n([(0, 33), (2, 45), (3, 33), (5, 43), (6, 33), (8, 40), (9, 45), (10, 33), (12, 38), (13, 45), (15, 36)]),
                   backing: acidDrums, threshold: 0.9),
            L.bassMake("Make it yours", "Write your own acid line. At least 10 notes.", backing: acidDrums, notes: 10),
        ])

    static let u6l4: LevelPair = (
        silver: [
            L.silver("the major 7th family",
                     "Soulful house leans on major 7ths for warmth, with minor 7ths for colour. Build another, then hear the progression in a new order."),
            K.build("Build Cmaj7", "C, E, G and B.", .cmaj7, low: 53, high: 67),
            K.quiz("Warm or moody?", "New chords this time.", [
                K.round([.dm7], ["Major 7th (warm)", "Minor 7th (moody)"], 1, "Dm7."),
                K.round([.cmaj7], ["Major 7th (warm)", "Minor 7th (moody)"], 0, "Cmaj7."),
                K.round([.em7], ["Major 7th (warm)", "Minor 7th (moody)"], 1, "Em7."),
                K.round([.fmaj7], ["Major 7th (warm)", "Minor 7th (moody)"], 0, "Fmaj7."),
            ]),
            K.lane("Copy this soulful progression", "It starts on Cmaj7 this time.", .recreate,
                   palette: [.fmaj7, .em7, .dm7, .cmaj7], backing: H.drums,
                   target: [0: 3, 4: 0, 8: 1, 12: 2], length: 3),
        ],
        gold: [
            L.gold("9th chords",
                   "Add one more note on top of a 7th and you get a 9th: richer and more open. This is the sound of soulful and deep house keys."),
            K.build("Build Am9", "A, C, E, G and B.", .am9, low: 53, high: 72),
            K.build("Build Dm9", "D, F, A, C and E.", .dm9, low: 53, high: 72),
            K.quiz("7th or 9th?", "The 9th sounds wider and shimmers more.", [
                K.round([.am7], ["7th", "9th (richer)"], 0), K.round([.am9], ["7th", "9th (richer)"], 1),
                K.round([.dm9], ["7th", "9th (richer)"], 1), K.round([.dm7], ["7th", "9th (richer)"], 0),
            ]),
            K.lane("Copy the syncopated soulful riff", "Four chords with stabs pushed off the beat.", .recreate,
                   palette: [.fmaj7, .em7, .dm7, .cmaj7], backing: H.drums,
                   target: [0: 0, 3: 0, 6: 1, 8: 2, 11: 2, 14: 3], length: 2),
        ])

    static let u6l5: LevelPair = (
        silver: [
            L.silver("peak-time energy",
                     "Peak-time house adds 16th hats and percussion for energy, and a harder, brighter kick to drive it."),
            L.copy("Copy the peak-time hats", "16th hats everywhere except the open hats, plus a rim after beats 1 and 3.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.hat, .openHat, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15],
                                   openHat: [2, 6, 10, 14], perc: [3, 11])),
            K.lab("Tune a peak-time kick", "Higher and driven, with a short tail.", [.kickPitch, .kickDrive],
                  start: [0.15, 0.1], target: [0.5, 0.7], loop: H.kickLoop),
        ],
        gold: [
            L.gold("the whole peak-time groove",
                   "Put it all together: a driving kit and a kick built for big speakers. Rebuild the drums from silence, then shape the kick."),
            L.copy("Rebuild the peak-time kit", "Kick with a pickup, claps, 16th hats, offbeat open hats and two rims.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12, 14], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                   openHat: [2, 6, 10, 14], perc: [7, 15]), threshold: 0.9),
            K.lab("Design the peak-time kick", "Pitch, length and drive. Punchy, not boomy.", [.kickPitch, .kickDecay, .kickDrive],
                  start: [0.1, 0.8, 0.0], target: [0.4, 0.2, 0.75], loop: H.kickLoop),
            L.make("Make it yours", "Write your own peak-time kit. At least 8 closed hats.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc],
                   goal: .atLeast(.hat, 8)),
        ])
}
