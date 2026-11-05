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
                     "Pitch and length set a kick's body. Drive adds grit, so the kick cuts through even on phone speakers. Hear what each knob does on its own, then match kicks that use all three."),
            K.quiz("Which knob changed?", "The same kick each time. Listen for what's different.", [
                K.sound(H.kickLoop, [.kickPitch: 0.3, .kickDecay: 0.3, .kickDrive: 0.75], ["Clean", "Gritty"], 1,
                        "That crunch is drive.", question: "Clean or gritty?"),
                K.sound(H.kickLoop, [.kickPitch: 0.3, .kickDecay: 0.3, .kickDrive: 0], ["Clean", "Gritty"], 0,
                        question: "Clean or gritty?"),
                K.sound(H.kickLoop, [.kickPitch: 0.3, .kickDecay: 0.85, .kickDrive: 0], ["Short and tight", "Long and boomy"], 1,
                        "Long length: the kick rings out like a tom.", question: "How long is the kick?"),
                K.ask("Your kick vanishes on phone speakers. Which knob helps most?", ["Drive", "Length", "Lower pitch"], 0,
                      "Phones can't play deep lows. Drive adds upper harmonics they can play, so you still hear the kick."),
            ]),
            K.lab("Match the dirty, deep kick", "Low, long and gritty.", kick3,
                  start: [0.3, 0.3, 0.0], target: [0.2, 0.55, 0.6], loop: H.kickLoop),
            K.lab("Match the clicky kick", "Higher, short and clean.", kick3,
                  start: [0.2, 0.6, 0.5], target: [0.55, 0.15, 0.2], loop: H.kickLoop),
        ],
        gold: [
            L.gold("a kick for every style",
                   "Every style has its own kick. Techno likes long and distorted, tech house likes short and punchy, deep house likes soft and round. Name them by ear, match two, then design a kick in a full track."),
            K.quiz("Name the style", "Three kicks. Which genre does each belong to?", [
                K.sound(H.kickLoop, [.kickPitch: 0.15, .kickDecay: 0.8, .kickDrive: 0.75], ["Techno", "Tech house", "Deep house"], 0,
                        "Long, low and driven hard."),
                K.sound(H.kickLoop, [.kickPitch: 0.45, .kickDecay: 0.2, .kickDrive: 0.35], ["Techno", "Tech house", "Deep house"], 1,
                        "Short and punchy."),
                K.sound(H.kickLoop, [.kickPitch: 0.25, .kickDecay: 0.45, .kickDrive: 0.05], ["Techno", "Tech house", "Deep house"], 2,
                        "Soft, round and clean."),
            ]),
            K.lab("Match the techno kick", "Long, low and driven hard.", kick3,
                  start: [0.5, 0.2, 0.0], target: [0.15, 0.8, 0.75], loop: H.kickLoop),
            K.lab("Match the deep house kick", "Soft, round and clean.", kick3,
                  start: [0.6, 0.2, 0.8], target: [0.25, 0.45, 0.05], loop: H.kickLoop),
            K.lab("Make it yours", "Design your signature kick inside the full track. Make sure it still punches through the bass.",
                  kick3, start: [0.5, 0.5, 0.5], loop: full),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("bass length",
                     "Cutoff and envelope set the tone. Length (decay) sets how long each note lasts, and that changes the groove as much as the notes do. Hear it, then match a long and a short bass."),
            K.quiz("Long or short?", "Same bassline, same notes. Only the length changes.", [
                K.sound(H.bassLoop, [.bassDecay: 0.9, .bassCutoff: 0.3], ["Short and bouncy", "Long and rolling"], 1,
                        "The notes run into each other, so the groove feels smooth."),
                K.sound(H.bassLoop, [.bassDecay: 0.12, .bassCutoff: 0.3], ["Short and bouncy", "Long and rolling"], 0,
                        "Gaps between notes let the kick through, so it bounces."),
                K.ask("Your bass and kick blur into one low rumble. What's the quickest fix?",
                      ["Shorten the bass notes", "Turn up the envelope", "Add more notes"], 0,
                      "Shorter notes leave gaps for the kick. That's the main job of the length knob in house."),
            ]),
            K.lab("Match the long, round bass", "Dark and held.", [.bassCutoff, .bassEnv, .bassDecay],
                  start: [0.3, 0.3, 0.5], target: [0.2, 0.2, 0.9], loop: H.bassLoop),
            K.lab("Match the short, plucky bass", "Bright attack, gone quickly.", [.bassCutoff, .bassEnv, .bassDecay],
                  start: [0.2, 0.2, 0.9], target: [0.55, 0.65, 0.15], loop: H.bassLoop),
        ],
        gold: [
            L.gold("bass for every style",
                   "Deep house bass is soft and long. Acid bass squelches. Garage bass is bright and short. Name each style by ear, match two, then design your own in a full track."),
            K.quiz("Name the bass", "Three tones on the same line.", [
                K.sound(H.bassLoop, [.bassCutoff: 0.1, .bassEnv: 0.05, .bassResonance: 0.1, .bassDecay: 0.8],
                        ["Deep sub", "Acid", "Garage"], 0, "Barely any top end, long notes."),
                K.sound(H.bassLoop, [.bassCutoff: 0.3, .bassEnv: 0.8, .bassResonance: 0.8, .bassDecay: 0.3],
                        ["Deep sub", "Acid", "Garage"], 1, "Resonance and envelope squelch on every note."),
                K.sound(H.bassLoop, [.bassCutoff: 0.6, .bassEnv: 0.4, .bassResonance: 0.2, .bassDecay: 0.15],
                        ["Deep sub", "Acid", "Garage"], 2, "Open, short and punchy."),
            ]),
            K.lab("Match the acid bass", "Resonance and envelope do the talking.", bass4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.3, 0.8, 0.8, 0.3], loop: H.bassLoop),
            K.lab("Match the bright garage bass", "Open, short, a little resonance.", bass4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.6, 0.4, 0.2, 0.15], loop: H.bassLoop),
            K.lab("Make it yours", "Design your own bass tone with the drums and chords playing. It should fill the bottom without hiding the kick.",
                  bass4, start: [0.5, 0.5, 0.5, 0.5], loop: full),
        ])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("attack and length",
                     "Length decides how long a chord rings. Attack decides how fast it arrives. Together they turn the same chord into a stab or a swell. Hear which knob is doing what, then match them."),
            K.quiz("Stab or swell?", "The same two chords with different settings.", [
                K.sound(H.stabLoop, [.chordAttack: 0, .chordDecay: 0.1], ["Stab", "Swell"], 0, "Instant and short."),
                K.sound(H.stabLoop, [.chordAttack: 0.6, .chordDecay: 0.7], ["Stab", "Swell"], 1, "It fades in, then holds."),
                K.ask("Which knob makes a chord fade in slowly?", ["Attack", "Length", "Cutoff"], 0,
                      "Attack is the time from silence to full volume."),
                K.ask("Your stabs blur into one long smear. Which knob do you turn down?", ["Attack", "Length", "Cutoff"], 1),
            ]),
            K.lab("Match the swell", "Fades in, then holds.", [.chordAttack, .chordDecay],
                  start: [0.0, 0.1], target: [0.6, 0.7], loop: H.stabLoop),
            K.lab("Match the dark stab", "Short and muffled.", [.chordCutoff, .chordDecay],
                  start: [0.8, 0.6], target: [0.2, 0.15], loop: H.stabLoop),
        ],
        gold: [
            L.gold("the full chord envelope",
                   "Attack, length, release and brightness together make a sound's character. With four knobs you can make an organ, a pluck or a pad from one chord. Name them by ear, match two, then design your own in a full track."),
            K.quiz("Organ, pluck or pad?", "One chord sound, three settings.", [
                K.sound(H.stabLoop, [.chordCutoff: 0.5, .chordDecay: 0.9, .chordAttack: 0.05, .chordRelease: 0.2],
                        ["Organ", "Pluck", "Pad"], 0, "Instant, held, then stops."),
                K.sound(H.stabLoop, [.chordCutoff: 0.7, .chordDecay: 0.1, .chordAttack: 0, .chordRelease: 0.15],
                        ["Organ", "Pluck", "Pad"], 1, "Bright, instant, gone."),
                K.sound(H.padLoop, [.chordCutoff: 0.3, .chordDecay: 0.8, .chordAttack: 0.7, .chordRelease: 0.8],
                        ["Organ", "Pluck", "Pad"], 2, "Dark, slow in, slow out."),
            ]),
            K.lab("Match the organ", "Instant, held and fairly bright.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.5, 0.9, 0.05, 0.2], loop: H.stabLoop),
            K.lab("Match the pad", "Dark, slow in and slow out.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.3, 0.8, 0.7, 0.8], loop: H.padLoop),
            K.lab("Make it yours", "Design a chord sound that fits the full track. Short and bright cuts through. Long and dark sits behind.",
                  chord4, start: [0.5, 0.5, 0.5, 0.5], loop: full),
        ])

    static let u3l4: LevelPair = (
        silver: [
            L.silver("cutoff moves the peak",
                     "Resonance boosts whatever frequency the cutoff sits on. Move the cutoff and the peak moves with it, from a low growl to a high whistle. Hear where the peak is, then match it on the bass and on the whole track."),
            K.quiz("Where's the peak?", "Resonance is up on both. Only the cutoff moves.", [
                K.sound(H.bassLoop, [.bassCutoff: 0.15, .bassResonance: 0.6, .bassEnv: 0], ["Low growl", "High whistle"], 0),
                K.sound(H.bassLoop, [.bassCutoff: 0.65, .bassResonance: 0.7, .bassEnv: 0], ["Low growl", "High whistle"], 1),
                K.ask("You turn up resonance but hear nothing change. Why?",
                      ["The cutoff is all the way open, above anything the bass plays", "The bass is too quiet",
                       "Resonance only works on drums"], 0,
                      "The peak sits at the cutoff. Bring the cutoff down into the notes and you'll hear it."),
            ]),
            K.lab("Match the high whistle", "Cutoff high, resonance up.", [.bassCutoff, .bassResonance],
                  start: [0.3, 0.2], target: [0.6, 0.7], loop: H.bassLoop),
            K.lab("Match the low growl", "Cutoff low, a medium peak.", [.bassCutoff, .bassResonance],
                  start: [0.6, 0.7], target: [0.15, 0.5], loop: H.bassLoop),
            K.filterMatch("Match the bright, peaky groove", "The whole track, cutoff fairly high with strong resonance.",
                          cutoff: 2200, resonance: 0.75, full),
        ],
        gold: [
            L.gold("resonance plus envelope",
                   "Add envelope to a resonant filter and every note sweeps the peak. That's the start of acid. Hear the sweep, match it, then design your own resonant bass."),
            K.quiz("Does it sweep?", "Same resonance. Listen to each note.", [
                K.sound(H.bassLoop, [.bassCutoff: 0.25, .bassResonance: 0.8, .bassEnv: 0.75], ["Every note sweeps", "Steady tone"], 0,
                        "Each note opens the filter, so the peak slides: wow."),
                K.sound(H.bassLoop, [.bassCutoff: 0.25, .bassResonance: 0.8, .bassEnv: 0], ["Every note sweeps", "Steady tone"], 1),
            ]),
            K.lab("Match the sweeping squelch", "Low cutoff, high resonance, lots of envelope.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.5, 0.2, 0.2], target: [0.25, 0.8, 0.7], loop: H.bassLoop),
            K.filterMatch("Match the deep, resonant groove", "Very dark with a strong peak.",
                          cutoff: 500, resonance: 0.85, full),
            K.lab("Make it yours", "Design your own resonant bass. Try a squelch, then pull the envelope back until it sits.",
                  [.bassCutoff, .bassResonance, .bassEnv, .bassDecay], start: [0.5, 0.5, 0.5, 0.5], loop: H.bassLoop),
        ])

    static let u3l5: LevelPair = (
        silver: [
            L.silver("release tails",
                     "Release is how long a sound lingers after the note ends. A pluck with a long release floats. A swell with no release stops dead. Hear the tail, then shape two."),
            K.quiz("Rings on or stops dead?", "Listen to the end of each chord.", [
                K.sound(H.padLoop, [.chordAttack: 0, .chordRelease: 0.85], ["Rings on", "Stops dead"], 0, "A long tail after each chord."),
                K.sound(H.padLoop, [.chordAttack: 0.5, .chordRelease: 0.05], ["Rings on", "Stops dead"], 1,
                        "It fades in, then cuts off sharply."),
                K.ask("Attack is how a sound starts. What is release?",
                      ["How it ends after you let go", "How loud it is", "How bright it is"], 0),
            ]),
            K.lab("Match the pluck with a long tail", "Instant start, rings on.", [.chordAttack, .chordRelease],
                  start: [0.5, 0.2], target: [0.0, 0.8], loop: H.padLoop),
            K.lab("Match the swell that stops", "Slow in, no tail.", [.chordAttack, .chordRelease],
                  start: [0.0, 0.8], target: [0.5, 0.1], loop: H.padLoop),
        ],
        gold: [
            L.gold("pads that breathe",
                   "Great pads move slowly and leave room for the drums. Get the brightness right first, then the attack and tails. Then put the pad in a room with reverb."),
            K.quiz("Which pad?", "Two pads. Which one is which?", [
                K.sound(H.padLoop, [.chordCutoff: 0.75, .chordDecay: 0.6, .chordAttack: 0.8, .chordRelease: 0.9],
                        ["Shimmering pad", "Soft keys"], 0, "Bright, slow and long."),
                K.sound(H.padLoop, [.chordCutoff: 0.4, .chordDecay: 0.5, .chordAttack: 0.1, .chordRelease: 0.4],
                        ["Shimmering pad", "Soft keys"], 1, "Mellow, quick in, medium tail."),
            ]),
            K.lab("Match the shimmering pad", "Bright, slow and long.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.75, 0.6, 0.8, 0.9], loop: H.padLoop),
            K.lab("Match the soft keys", "Mellow, quick in, medium tail.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], target: [0.4, 0.5, 0.1, 0.4], loop: H.padLoop),
            K.space("Give the pad a room", "Add reverb until the pad feels like it's in a big space, but stop before it washes out the kick.", H.padLoop),
            K.lab("Make it yours", "Design a pad you'd put in a breakdown.", chord4,
                  start: [0.5, 0.5, 0.5, 0.5], loop: H.padLoop),
        ])

    // MARK: Unit 5 — Build a Track

    static let drumsOnly = H.full.keeping([.kick, .clap, .hat], bass: false, chords: false)
    static let kickHat = H.full.keeping([.kick, .hat], bass: false, chords: false)
    static let chordsOnly = H.full.keeping([], bass: false, chords: true)
    static let bassChords = H.full.keeping([], bass: true, chords: true)
    static let hatsChords = H.full.keeping([.hat], bass: false, chords: true)
    static let noKick = H.full.keeping([.clap, .hat], bass: true, chords: true)

    static let u5l1: LevelPair = (
        silver: [
            L.silver("contrast between sections",
                     "Each section should feel different from its neighbours. The easiest way is to change which parts play: drop the kick, bring in the chords, strip back to hats. First learn to tell sections apart by ear."),
            K.quiz("Which section is this?", "Each loop is one section of the same track.", [
                K.hear([kickHat], ["Intro", "Drop", "Break"], 0, "Just kick and hats: the track is warming up.", bars: 2),
                K.hear([full], ["Intro", "Drop", "Break"], 1, "Everything at once.", bars: 2),
                K.hear([chordsOnly], ["Intro", "Drop", "Break"], 2, "No drums, just chords. The kick is gone.", bars: 2),
                K.ask("Two sections in a row play exactly the same parts. What happens?",
                      ["The track feels like it's stuck", "It sounds bigger", "Nothing, that's normal"], 0,
                      "Listeners notice change. Every new section should add or remove something."),
            ]),
            K.arrange("Copy this four-section track", "Listen to what changes at each section.", .recreate, loop: full,
                      target: K.grid("-xxx", "--x-", "xxx-", "-xx-", "x-xx")),
            K.arrange("Make the Break hats and chords only", "In the Break, switch off the kick, clap and bass.", .rule,
                      loop: full, start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                      target: K.grid("xxx-", "xxx-", "xxxx", "xxx-", "xxxx")),
        ],
        gold: [
            L.gold("whole tracks by ear",
                   "Hear a track once through and picture the grid. Then check one part at a time across all four sections. Start by spotting single changes, then map a whole track, then write one."),
            K.quiz("What changed?", "Two bars. One part leaves or arrives in bar 2.", [
                K.hear([full, noKick], ["The kick left", "The bass left", "The chords left"], 0, question: "What changed?"),
                K.hear([drumsOnly, H.full.keeping([.kick, .clap, .hat], bass: true, chords: false)],
                       ["The bass arrived", "The chords arrived", "The clap arrived"], 0, question: "What changed?"),
                K.hear([kickHat, drumsOnly], ["The bass arrived", "The chords arrived", "The clap arrived"], 2, question: "What changed?"),
            ]),
            K.arrange("Recreate this track", "The Build drops the kick. The Drop has everything.", .recreate, loop: full,
                      target: K.grid("x-x-", "-xx-", "xxxx", "--x-", "xxxx")),
            K.arrange("Make it yours", "Five sections this time. Every one different from the last.",
                      .create(.variedSections), sections: ["Intro", "Build", "Drop", "Break", "Drop 2"], loop: full),
        ])

    static let u5l2: LevelPair = (
        silver: [
            L.silver("intros that hold back",
                     "House intros are mostly drums. That's for DJs as much as listeners: a DJ blends the intro of your track over the end of the last one, and drums mix cleanly where chords would clash. Holding back gives the listener something to wait for."),
            K.quiz("Why drums first?", "", [
                K.ask("A DJ blends your intro over another track for 16 bars. What mixes most cleanly?",
                      ["Just drums", "The full track with chords and bass", "Chords alone"], 0,
                      "Two sets of chords or basslines in different keys clash. Two sets of drums just sound bigger."),
                K.hear([kickHat, drumsOnly, full], ["Bar 2", "Bar 3"], 1, "Drums first, then everything arrives at once.",
                       question: "When does the music arrive?"),
            ]),
            K.arrange("Build a drums-first intro", "Intro: kick and hats only. Build: add the clap.", .rule, loop: full,
                      start: K.grid("--xx", "--xx", "--xx", "--xx", "--xx"),
                      target: K.grid("xxxx", "-xxx", "xxxx", "--xx", "--xx")),
            K.arrange("Copy this intro", "Drums first, then the music arrives.", .recreate, loop: full,
                      target: K.grid("xxxx", "-xx-", "xxxx", "--x-", "---x")),
        ],
        gold: [
            L.gold("intros that tease",
                   "Some intros hint at the drop: a few bars of chords before the drums, or a bassline that arrives before the clap. Hear what's being teased, recreate two teases, then write your own."),
            K.quiz("What's the tease?", "Each intro hints at something from the drop.", [
                K.hear([chordsOnly, chordsOnly, full], ["The chords", "The bass", "The clap"], 0, "The chords play alone first.",
                       question: "What do you hear before the drop?"),
                K.hear([H.full.keeping([.kick, .hat], bass: true, chords: false), full], ["The chords", "The bass", "The clap"], 1,
                       "Kick, hats and bass. The bassline gives the groove away early.", question: "What do you hear before the drop?"),
            ]),
            K.arrange("Recreate the chord tease", "Chords open the track on their own.", .recreate, loop: full,
                      target: K.grid("-xxx", "--x-", "xxxx", "--xx", "x-xx")),
            K.arrange("Recreate the bass tease", "The bass arrives before the clap.", .recreate, loop: full,
                      target: K.grid("x-xx", "--xx", "xxx-", "-xx-", "--xx")),
            K.arrange("Make it yours", "Write an intro that teases one part of the drop, then the rest of the track.", .create(.variedSections),
                      loop: full),
        ])

    static let u5l3: LevelPair = (
        silver: [
            L.silver("drops need a build",
                     "A drop feels bigger when the section before it held back. It's contrast, not volume: empty the build and the drop lands harder. Hear the difference, then carve it."),
            K.quiz("Which drop hits harder?", "Bar 2 is the drop each time. Listen to how big the change feels.", [
                K.hear([noKick, full], ["Big change", "Small change"], 1, "Only the kick came back.", question: "How hard does the drop hit?"),
                K.hear([chordsOnly, full], ["Big change", "Small change"], 0,
                       "From chords alone to everything. That's a drop.", question: "How hard does the drop hit?"),
                K.ask("How do you make a drop feel bigger without touching the drop?",
                      ["Take more out of the section before it", "Add more parts to the drop", "Turn the drop up"], 0),
            ]),
            K.arrange("Empty the Build so the Drop hits", "In the Build, switch everything off except the chords.", .rule,
                      loop: full, start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                      target: K.grid("x-xx", "x-xx", "x-xx", "x-xx", "xxxx")),
            K.arrange("Copy this build and drop", "Chords open it alone. The bass waits for the Drop.", .recreate, loop: full,
                      target: K.grid("-xx-", "--x-", "xxx-", "--xx", "x-xx")),
        ],
        gold: [
            L.gold("two drops",
                   "Most club tracks have two drops with a break between. If the second drop is a copy of the first, it feels smaller. It usually adds something new to feel bigger."),
            K.quiz("Quick check", "", [
                K.ask("What does the second drop usually do?",
                      ["Adds a part the first drop didn't have", "Repeats the first drop exactly", "Drops the bass"], 0,
                      "By the second drop the listener knows the first one. Something new keeps it exciting."),
            ]),
            K.arrange("Recreate this two-drop track", "The Break is chords alone.", .recreate, sections: twoDrops, loop: full,
                      target: K.grid("-x-x", "-x-x", "xx-x", "-x-x", "x-xx")),
            K.arrange("Recreate this two-drop track", "The second drop brings in something the first didn't have.",
                      .recreate, sections: twoDrops, loop: full,
                      target: K.grid("xx-x", "-x-x", "xx-x", "-x-x", "--xx")),
            K.arrange("Make it yours", "Arrange two drops with a break in between. Make Drop 2 bigger than Drop 1.", .create(.variedSections),
                      sections: twoDrops, loop: full),
        ])

    static let u5l4: LevelPair = (
        silver: [
            L.silver("what stays in the break",
                     "A breakdown takes the kick away, but what's left decides the mood. Chords alone feel emotional. Bass and chords feel tense. Hats keep the pulse going. Hear each, then build them."),
            K.quiz("What's left in the break?", "The kick is gone. What's still playing?", [
                K.hear([chordsOnly], ["Chords alone", "Bass and chords", "Hats and chords"], 0, "Open and emotional.", bars: 2),
                K.hear([bassChords], ["Chords alone", "Bass and chords", "Hats and chords"], 1, "The bass keeps the tension up.", bars: 2),
                K.hear([hatsChords], ["Chords alone", "Bass and chords", "Hats and chords"], 2, "The hats keep time so dancers stay locked in.",
                       bars: 2),
            ]),
            K.arrange("Keep only bass and chords in the Break", "Switch off the kick, clap and hats in the Break.", .rule,
                      loop: full, start: K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx"),
                      target: K.grid("xxx-", "xxx-", "xxx-", "xxxx", "xxxx")),
            K.arrange("Copy this breakdown", "The hats stay in this time.", .recreate, loop: full,
                      target: K.grid("xxx-", "-xx-", "xxxx", "--x-", "-xxx")),
        ],
        gold: [
            L.gold("the drop after the break",
                   "The break is half the story. The drop that follows hits hardest when the break was empty, and the build between them decides how fast the energy comes back."),
            K.quiz("How does the energy come back?", "Three bars: break, build, drop.", [
                K.hear([chordsOnly, hatsChords, full], ["Hats", "Bass", "Kick"], 0, "Hats first, then everything.",
                       question: "What returns first in the build?"),
                K.hear([chordsOnly, bassChords, full], ["Hats", "Bass", "Kick"], 1, "The bass comes back early, before the drums.",
                       question: "What returns first in the build?"),
            ]),
            K.arrange("Recreate this section of a track", "The Break is chords alone. Hats return in the Build.", .recreate,
                      sections: ["Drop", "Break", "Build", "Drop 2"], loop: full,
                      target: K.grid("x--x", "x--x", "x-xx", "x--x", "xxxx")),
            K.arrange("Recreate this one", "The build brings the bass back early.", .recreate,
                      sections: ["Drop", "Break", "Build", "Drop 2"], loop: full,
                      target: K.grid("x--x", "x-xx", "x-xx", "x-xx", "xx-x")),
            K.arrange("Make it yours", "Write your own break and return. Decide what stays in the break and what comes back first.",
                      .create(.variedSections), sections: ["Drop", "Break", "Build", "Drop 2"], loop: full),
        ])

    static let u5l5: LevelPair = (
        silver: [
            L.silver("fill shapes",
                     "Fills come in shapes. Rolls get faster into the next bar, stops cut everything out, and pickups lead in with one hit. Name each by ear, copy one, fix one, then write your own."),
            K.quiz("Roll, stop or pickup?", "Bar 2 ends with a fill.", [
                K.hear([HouseLevels.drums, Pattern(kick: [0, 4, 8], clap: [4, 10, 12, 14, 15], hat: [2, 6, 10])],
                       ["Roll", "Stop", "Pickup"], 0, "The claps speed up into the next bar.", question: "What kind of fill?"),
                K.hear([HouseLevels.drums, Pattern(kick: [0, 4, 8], clap: [4, 15], hat: [2, 6, 10])],
                       ["Roll", "Stop", "Pickup"], 1, "Everything cuts out, then one clap.", question: "What kind of fill?"),
                K.hear([HouseLevels.drums, Pattern(kick: [0, 4, 8, 12, 15], clap: [4, 12], hat: [2, 6, 10, 14])],
                       ["Roll", "Stop", "Pickup"], 2, "One extra kick leads in.", question: "What kind of fill?"),
            ]),
            L.copy("Copy the roll", "Claps speed up through the last beat.", tracks: [.kick, .clap, .hat],
                   edit: [.clap], start: Pattern(kick: [0, 4, 8], hat: [2, 6, 10]),
                   target: Pattern(kick: [0, 4, 8], clap: [4, 10, 12, 14, 15], hat: [2, 6, 10])),
            K.fix("Fix the stop", "A stop needs silence before the last clap. The kick and hats are still playing through the last beat. Clear them.",
                  tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                  broken: Pattern(kick: [0, 4, 8, 12], clap: [4, 15], hat: [2, 6, 10, 14]),
                  target: Pattern(kick: [0, 4, 8], clap: [4, 15], hat: [2, 6, 10]), guide: false),
            L.make("Write a fill with rims", "Use the last beat. At least 4 rims.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.clap, .perc],
                   start: Pattern(kick: [0, 4, 8, 12], clap: [4], hat: [2, 6, 10, 14]), goal: .atLeast(.perc, 4)),
        ],
        gold: [
            L.gold("full-kit fills",
                   "Big fills use the whole kit: kick drops out, claps roll, percussion answers. Hear which part carries a fill, rebuild one part by part, fix a hat fill, then write a big one."),
            K.quiz("Which part fills?", "Bar 2 has a fill. Which drum is doing it?", [
                K.hear([HouseLevels.drums, Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 12, 13, 14, 15])],
                       ["Hats", "Claps", "Rims"], 0, "Hats speed up into the next bar.", question: "Which drum fills?"),
                K.hear([HouseLevels.drums, Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [12, 13, 14, 15])],
                       ["Hats", "Claps", "Rims"], 2, question: "Which drum fills?"),
                K.hear([HouseLevels.drums, Pattern(kick: [0, 4, 8], clap: [4, 12, 13, 14, 15], hat: [2, 6, 10])],
                       ["Hats", "Claps", "Rims"], 1, question: "Which drum fills?"),
            ]),
            L.copy("Rebuild this full-kit fill", "Kick, clap, hats and rims all change in the last beat.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   target: Pattern(kick: [0, 4, 8, 11], clap: [4, 12, 13, 14, 15], hat: [2, 6, 10], perc: [9, 11, 13, 15]),
                   threshold: 0.9),
            K.fix("Fix the hat fill", "The hats should speed up into the next bar: offbeats first, then every step of the last beat. Two of the fast hats are missing.",
                  tracks: [.kick, .clap, .hat], edit: [.hat],
                  broken: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 12, 14]),
                  target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 12, 13, 14, 15]), guide: false),
            L.make("Make it yours", "Write a full-kit fill. At least 5 claps, and drop the kick somewhere in the last beat.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], start: Pattern(hat: [2, 6, 10]), goal: .atLeast(.clap, 5)),
        ])

    // MARK: Unit 6 — House Styles

    static let discoDrums = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14])
    static let jackDrums = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14])
    static let acidDrums = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])

    static let u6l1: LevelPair = (
        silver: [
            L.silver("the disco groove",
                     "House grew out of disco: shuffled hats, open hats on the offbeat and an octave-jumping bass. Hear what disco gave house, shuffle the hats, then copy and fix octave lines on new notes."),
            K.quiz("Disco or house?", "Listen to the hats and the bass.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], openHat: [2, 6, 10, 14],
                                bass: L.n([(0, 33), (2, 45), (4, 33), (6, 45), (8, 33), (10, 45), (12, 33), (14, 45)]))],
                       ["Disco", "Chicago house"], 0, "Shuffled hats and a bass that jumps octaves on every 8th.", bars: 2, swing: 0.3),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], bass: L.n([(2, 33), (6, 33), (10, 33), (14, 33)]))],
                       ["Disco", "Chicago house"], 1, "Straight drum machine, simple offbeat bass.", bars: 2),
                K.ask("What did early house take from disco?", ["The four-on-the-floor kick and the open hats", "The guitar solos",
                                                                 "The live drummer"], 0,
                      "Chicago DJs looped disco records and added drum machines. The kick and hats stayed."),
            ]),
            K.swingMake("Shuffle the disco hats", "Push swing past 20%.", tracks: [.kick, .clap, .hat, .openHat],
                        start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                       openHat: [2, 6, 10, 14]), atLeast: 0.2),
            L.bass("Copy the moving octave bass", "Octaves on A, then it walks to C and E.",
                   L.n([(0, 33), (2, 45), (4, 33), (6, 45), (8, 36), (10, 36), (12, 40), (14, 43)]), backing: discoDrums),
            K.fixNotes("Fix the octaves", "Low A, high A, low A, high A, all on the 8ths. Two notes forgot to jump.",
                       rows: Curriculum.bassRows,
                       broken: L.n([(0, 33), (2, 45), (4, 33), (6, 33), (8, 33), (10, 45), (12, 33), (14, 33)]),
                       target: L.n([(0, 33), (2, 45), (4, 33), (6, 45), (8, 33), (10, 45), (12, 33), (14, 45)]),
                       backing: discoDrums),
        ],
        gold: [
            L.gold("disco to house",
                   "Strip disco down to drums and bass, add a drum machine kick, and you get early Chicago house. Rebuild the whole groove: heavy shuffle, a busy bass and rims, then write your own disco line."),
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
                     "Jackin' bass chases the kick: each note lands just after a kick, never on it. Hold some notes longer and the line starts to swing between short and long."),
            K.quiz("Where's the bass?", "Listen to the bass against the kick.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], bass: L.n([(1, 33), (5, 33), (9, 33), (13, 33)]))],
                       ["Chasing the kick", "On the offbeat"], 0, "Right behind every kick. That's jack.", bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], bass: L.n([(2, 33), (6, 33), (10, 33), (14, 33)]))],
                       ["Chasing the kick", "On the offbeat"], 1, "Between the kicks, classic house bounce.", bars: 2),
            ]),
            L.bass("Copy the jumping jack line", "Chasing the kick, with octave jumps.",
                   L.n([(1, 33), (5, 33), (7, 45), (9, 33), (13, 33), (15, 43)]), backing: jackDrums),
            K.fixNotes("Fix the long jack line", "Each note holds for two steps, just after each kick. One note lands on the kick instead, and one is too short.",
                       rows: Curriculum.bassRows,
                       broken: [NoteEvent(1, 33, 2), NoteEvent(4, 36, 2), NoteEvent(9, 33, 1), NoteEvent(13, 40, 2)],
                       target: [NoteEvent(1, 33, 2), NoteEvent(5, 36, 2), NoteEvent(9, 33, 2), NoteEvent(13, 40, 2)],
                       backing: jackDrums),
            L.bassMake("Write your own jack line", "At least 7 notes. Mix short and long, and keep them off the kick.", backing: jackDrums, notes: 7),
        ],
        gold: [
            L.gold("Chicago jack",
                   "Jackin' tracks lock bass and percussion together, so the drums answer the bass. Write the bass, rebuild the drums that answer it, then write a full jack line."),
            L.bass("Copy the full jack line", "Pairs of notes around every kick.",
                   L.n([(1, 33), (2, 33), (5, 36), (6, 33), (9, 33), (10, 38), (13, 40), (14, 43), (15, 45)]),
                   backing: jackDrums, threshold: 0.9),
            K.quiz("Who's answering?", "The bass plays just after each kick. Listen for the drum that fills the gaps.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [1, 7, 9, 15],
                                bass: L.n([(1, 33), (5, 36), (9, 33), (13, 40)]))],
                       ["Rims", "Open hats", "Extra claps"], 0, "Rims on the 16ths around the kick and clap.", bars: 2),
            ]),
            L.copy("Rebuild the jackin' drums", "Perc on the 16ths just after each kick and before each clap.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [1, 7, 9, 15]),
                   threshold: 0.9),
            L.bassMake("Make it yours", "A jack line with at least 9 notes.", backing: jackDrums, notes: 9),
        ])

    static let u6l3: LevelPair = (
        silver: [
            L.silver("acid length",
                     "Acid lines get their bite from short, resonant notes. Shorten the notes and the squelch becomes a stab. Hear the squelch, shape it, then copy a line."),
            K.quiz("Is it acid?", "The same busy line, two different sounds.", [
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine),
                        [.bassCutoff: 0.3, .bassEnv: 0.85, .bassResonance: 0.8, .bassDecay: 0.25], ["Acid squelch", "Plain bass"], 0),
                K.sound(Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine),
                        [.bassCutoff: 0.3, .bassEnv: 0, .bassResonance: 0, .bassDecay: 0.25], ["Acid squelch", "Plain bass"], 1),
                K.ask("Which two knobs make the acid sound?", ["Resonance and envelope", "Pitch and drive", "Attack and release"], 0,
                      "Resonance makes the peak. Envelope sweeps it on every note."),
            ]),
            K.lab("Match the short acid squelch", "Resonance high, notes short.", bass4,
                  start: [0.2, 0.85, 0.75, 0.5], target: [0.35, 0.85, 0.7, 0.2],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine)),
            L.bass("Copy this acid line", "Busy 16ths that jump up the octave.",
                   L.n([(0, 33), (1, 33), (3, 45), (4, 33), (6, 43), (8, 33), (9, 40), (11, 45), (12, 33), (14, 38)]),
                   backing: acidDrums),
        ],
        gold: [
            L.gold("full acid",
                   "Classic acid is a resonant filter, a busy line and a filter that moves. Match the sound, the filter and the line, then ride the filter like a DJ."),
            K.lab("Match the deepest squelch", "Dark cutoff, maximum resonance and envelope.",
                  [.bassCutoff, .bassResonance, .bassEnv], start: [0.5, 0.3, 0.3], target: [0.1, 0.9, 0.9],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine)),
            K.filterMatch("Match the acid filter", "The whole groove through a dark, resonant filter.",
                          cutoff: 700, resonance: 0.85, Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine)),
            L.bass("Copy the long acid line", "Eleven notes. Listen for every octave jump.",
                   L.n([(0, 33), (2, 45), (3, 33), (5, 43), (6, 33), (8, 40), (9, 45), (10, 33), (12, 38), (13, 45), (15, 36)]),
                   backing: acidDrums, threshold: 0.9),
            K.filterSweep("Ride the filter", "Acid lives on movement. Sweep the cutoff slowly up and down with resonance high, like a DJ on a 303.",
                          Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: H.acidLine)),
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
                   "Add one more note on top of a 7th and you get a 9th: richer and more open. This is the sound of soulful and deep house keys. Build them, hear them, copy a riff, then write with them."),
            K.build("Build Am9", "A, C, E, G and B.", .am9, low: 53, high: 72),
            K.build("Build Dm9", "D, F, A, C and E.", .dm9, low: 53, high: 72),
            K.quiz("7th or 9th?", "The 9th sounds wider and shimmers more.", [
                K.round([.am7], ["7th", "9th (richer)"], 0), K.round([.am9], ["7th", "9th (richer)"], 1),
                K.round([.dm9], ["7th", "9th (richer)"], 1), K.round([.dm7], ["7th", "9th (richer)"], 0),
                K.ask("Am7 is A, C, E, G. Which note do you add to make Am9?", ["B", "F", "D"], 0,
                      "Count up from A: the 9th is the 2nd an octave higher. B."),
            ]),
            K.lane("Copy the syncopated soulful riff", "Four chords with stabs pushed off the beat.", .recreate,
                   palette: [.fmaj7, .em7, .dm7, .cmaj7], backing: H.drums,
                   target: [0: 0, 3: 0, 6: 1, 8: 2, 11: 2, 14: 3], length: 2),
            K.lane("Make it yours", "Write a soulful loop with at least four stabs. Use at least one 9th.",
                   .create(.chordsAtLeast(4)), palette: [.am9, .dm9, .fmaj7, .cmaj7], backing: H.drums, length: 2),
        ])

    static let u6l5: LevelPair = (
        silver: [
            L.silver("peak-time energy",
                     "Peak-time house adds 16th hats and percussion for energy, and a harder, brighter kick to drive it. Hear what makes a groove peak-time, copy the hats, then tune the kick."),
            K.quiz("Peak-time or warm-up?", "Same tempo. Which one is for the peak of the night?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [7, 15], openHat: [2, 10])],
                       ["Warm-up", "Peak time"], 0, "Sparse and relaxed.", bars: 2),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15],
                                openHat: [2, 6, 10, 14], perc: [3, 11])],
                       ["Warm-up", "Peak time"], 1, "Busy 16ths and rims. Full energy.", bars: 2),
                K.sound(H.kickLoop, [.kickPitch: 0.5, .kickDecay: 0.2, .kickDrive: 0.7], ["Warm-up kick", "Peak-time kick"], 1,
                        "Higher, short and driven: it cuts through a loud club.", question: "Which kick is it?"),
            ]),
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
                   "Put it all together: a driving kit, a kick built for big speakers and a mix where everything punches. Rebuild the drums from silence, shape the kick, balance it, then write your own."),
            L.copy("Rebuild the peak-time kit", "Kick with a pickup, claps, 16th hats, offbeat open hats and two rims.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc],
                   target: Pattern(kick: [0, 4, 8, 12, 14], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                   openHat: [2, 6, 10, 14], perc: [7, 15]), threshold: 0.9),
            K.lab("Design the peak-time kick", "Pitch, length and drive. Punchy, not boomy.", [.kickPitch, .kickDecay, .kickDrive],
                  start: [0.1, 0.8, 0.0], target: [0.4, 0.2, 0.75], loop: H.kickLoop),
            K.quiz("What's wrong with the mix?", "Peak-time needs the kick on top.", [
                K.faders(full, [.drum(.kick): 0.3], ["The kick is too quiet", "The hats are too loud", "It's balanced"], 0,
                         "The kick should lead in peak-time. Here it's buried."),
                K.faders(full, [.drum(.hat): 1.0], ["The kick is too quiet", "The hats are too loud", "It's balanced"], 1),
            ]),
            L.make("Make it yours", "Write your own peak-time kit. At least 8 closed hats.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc],
                   goal: .atLeast(.hat, 8)),
        ])
}
