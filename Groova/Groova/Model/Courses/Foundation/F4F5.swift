//
//  F4F5.swift
//  Groova
//
//  Foundation F4, Sounds & Production Tools, and F5, From Loop to Song. Shared production lessons
//  you can take alongside your genre.
//

import Foundation

nonisolated enum F4F5 {
    typealias F = FKit

    static let units: [Unit] = [f4, f5]

    // MARK: Sounds

    static let phrase = K.tune([(0, 64, 2), (2, 67, 2), (4, 72, 4), (8, 69, 2), (10, 67, 2), (12, 64, 4)])
    /// The phrase alone on the chord synth, for timbre rounds.
    static let line = K.melody(phrase)
    static let lineBeat = K.melody(phrase, over: F.beat)
    static let bassLoop = Pattern(kick: [0, 8], clap: [4, 12], bass: F.bassline)
    static let stabs = Pattern(kick: [0, 8], clap: [4, 12], hat: F.eighths,
                               chords: [K.ch(2, F.c), K.ch(6, F.c), K.ch(10, F.am), K.ch(14, F.am)])

    static let pluck: [SoundParam: Double] = [.chordAttack: 0, .chordDecay: 0.12, .chordRelease: 0.1, .chordCutoff: 0.55]
    static let keys: [SoundParam: Double] = [.chordAttack: 0, .chordDecay: 0.6, .chordRelease: 0.35, .chordCutoff: 0.75]
    static let pad: [SoundParam: Double] = [.chordAttack: 0.75, .chordDecay: 1, .chordRelease: 0.9, .chordCutoff: 0.4]

    // MARK: Song blocks

    static let song = K.melody(phrase, over: F.full)
    static let intro = Pattern(hat: F.eighths, chords: [K.ch(0, F.c, 6), K.ch(8, F.am, 6)])
    static let verse = F.beatBass
    static let chorus = song
    static let outro = Pattern(chords: [K.ch(0, F.c, 14)])
    static let breakdown = Pattern(chords: [K.ch(0, F.c, 6), K.ch(8, F.am, 6)])
    static let silence = Pattern()

    static func blocks() -> [OrderTile] {
        [K.tile("Intro", intro, "Hats & chords"), K.tile("Verse", verse, "Drums & bass"),
         K.tile("Chorus", chorus, "Everything"), K.tile("Outro", outro, "One chord")]
    }

    // MARK: - F4 · Sounds & Production Tools

    static let f4 = Unit(id: "f4", number: 4, title: "Sounds & Production Tools",
                         subtitle: "Timbre, synths, space and making parts fit",
                         lessons: [f41, f42, f43, f44, f45], part: .foundations, code: "F")

    static let f41 = K.lesson("f4.1", "What Makes Sounds Different?", "Timbre", "waveform", .soundDesign, 15, [
        K.intro("Same notes, new sound",
                "A piano and a synth can play the exact same notes and still sound nothing alike. That character is called timbre. It comes from how a sound starts, how long it rings and how bright it is.",
                [], demo: lineBeat),
        K.quiz("What's it played on?", "The same melody three ways. Name the sound.", [
            K.sound(line, pluck, ["Pluck", "Keys", "Pad"], 0, "Starts sharp and dies fast. A pluck."),
            K.sound(line, pad, ["Pluck", "Keys", "Pad"], 2, "Fades in slowly and hangs in the air. A pad."),
            K.sound(line, keys, ["Pluck", "Keys", "Pad"], 1, "A clear hit that rings out. Keys."),
        ]),
        K.lab("Morph the sound", "Attack is how fast a note starts. Length is how long it rings. Turn both and hear a pluck melt into a pad.",
              [.chordAttack, .chordDecay, .chordCutoff], start: [0, 0.2, 0.6], loop: lineBeat),
        K.quiz("What changed?", "Same melody twice. Did the sound change, or the notes?", [
            K.hear([K.melody(phrase), K.melody(K.tune([(0, 64, 2), (2, 67, 2), (4, 69, 4), (8, 67, 2), (10, 64, 2), (12, 60, 4)]))],
                   ["The sound", "The notes"], 1, "Same instrument. The second half of the melody went lower."),
        ]),
    ])

    static let f42 = K.lesson("f4.2", "Shape a Synth", "Filter and envelope", "dial.medium.fill", .soundDesign, 15, [
        K.intro("Two knobs do most of it",
                "A filter decides how bright a sound is: low cutoff is dark and muffled, high is buzzy and bright. An envelope shapes it over time: snappy and short, or slow and swelling.",
                [], demo: bassLoop),
        K.lab("Open the filter", "Turn Cutoff from dark to bright. Then add Envelope and hear each note snap open.",
              [.bassCutoff, .bassEnv], start: [0.15, 0.1], loop: bassLoop),
        K.quiz("Bright or dark?", "", [
            K.sound(bassLoop, [.bassCutoff: 0.1, .bassEnv: 0.1], ["Bright", "Dark"], 1, "Cutoff almost closed."),
            K.sound(bassLoop, [.bassCutoff: 0.85, .bassEnv: 0.5], ["Bright", "Dark"], 0, "Cutoff wide open."),
        ]),
        K.lab("Pluck to pad", "Attack at zero and short Release makes a pluck. Raise both for a pad.",
              [.chordAttack, .chordRelease], start: [0, 0.1], loop: stabs),
    ])

    static let f43 = K.lesson("f4.3", "Space & Echo", "Reverb", "dot.radiowaves.left.and.right", .mixing, 15, [
        K.intro("Put it in a room",
                "Reverb is the sound of a space: a sound bouncing off walls and fading away. A little makes things feel real. A lot makes them feel huge and far away. No reverb is called dry.",
                [], demo: stabs),
        K.space("Dry to wet", "Drag the reverb from dry to huge and listen to the tail after each stab.", stabs),
        K.quiz("Dry or wet?", "", [
            K.reverb(stabs, amount: 0, ["Dry", "Wet"], 0, "No tail at all."),
            K.reverb(stabs, amount: 0.8, ["Dry", "Wet"], 1, "Each stab rings out into a big room."),
            K.reverb(line, amount: 0.6, ["Dry", "Wet"], 1, "The melody blurs into its own echo."),
        ]),
    ])

    static let f44 = K.lesson("f4.4", "Make Parts Fit", "Volume balance", "slider.vertical.3", .mixing, 15, [
        K.intro("Balance first",
                "Mixing starts with volume. If the melody is buried or the bass is booming, no plug-in fixes it. Get the levels right and most of the mix is done.",
                [], demo: song),
        K.quiz("Which part is too loud?", "", [
            K.faders(song, [.bass: 1, .chords: 0.4], ["Bass", "Chords"], 0, "The bass swallows everything."),
            K.faders(song, [.chords: 1, .bass: 0.4], ["Bass", "Chords"], 1, "The chords and melody shout over the beat."),
        ]),
        K.mix("Bring the melody out", "The melody (on Chords) is buried under the bass. Pull the bass down and push the melody up.",
              [.drum(.kick), .bass, .chords], start: [K.u, 0.95, 0.3], target: [K.u, 0.55, 0.75], loop: song),
    ])

    static let f45 = K.lesson("f4.5", "Create a Palette", "Boss: sounds that belong together", "crown.fill", .soundDesign, 30, [
        K.intro("Boss: your palette",
                "A palette is the set of sounds a track uses. Good palettes have one sound per job: something low, something to keep time, something for chords, something on top. Build one.", []),
        K.quiz("Which sound fits the job?", "", [
            K.sound(bassLoop, [.bassCutoff: 0.2, .bassWave: 0], ["A deep, round bass", "A bright, buzzy bass"], 0),
            K.sound(stabs, pad, ["Short chord stabs", "Long washy pad"], 1, "Pads hold chords under everything."),
            K.sound(lineBeat, pluck, ["Good for a hook on top", "Good for a low bass"], 0, "Plucks cut through for melodies."),
        ]),
        K.lab("Pick your bass", "Make it deep and round, or rough and buzzy. Your call.", [.bassWave, .bassCutoff],
              start: [0, 0.3], loop: bassLoop),
        K.lab("Pick your chord sound", "Plucky keys, a soft pad or anything between.", [.chordAttack, .chordDecay, .chordCutoff],
              start: [0, 0.5, 0.6], loop: stabs),
        K.mix("Balance your palette", "Set the kick, bass and chords so each one is clear.",
              [.drum(.kick), .bass, .chords], start: [K.u, K.u, K.u], loop: song),
    ])

    // MARK: - F5 · From Loop to Song

    static let f5 = Unit(id: "f5", number: 5, title: "From Loop to Song",
                         subtitle: "Sections, contrast, transitions and your first mini-track",
                         lessons: [f51, f52, f53, f54, f55], part: .foundations, code: "F")

    static let f51 = K.lesson("f5.1", "Hear the Sections", "Songs come in parts", "rectangle.split.3x1.fill", .arrangement, 15, [
        K.intro("A song is a loop that changes",
                "A loop playing for three minutes gets boring. Songs move between sections: an intro, a verse, a chorus, a break. Each one adds or removes layers so your ears stay hooked.",
                [], demo: song),
        K.tapChanges("Tap when it changes", "Two sections take turns. Hit the pad the moment a new one starts.",
                     loops: [verse, chorus, verse, chorus], barsEach: 2),
        K.quiz("Which section is this?", "", [
            K.hear([intro], ["Intro", "Chorus"], 0, "Thin and quiet. Intros hold back.", bars: 2),
            K.hear([chorus], ["Intro", "Chorus"], 1, "Everything playing. That's the big moment.", bars: 2),
            K.hear([outro], ["Verse", "Outro"], 1, "One chord ringing out. The end.", bars: 2),
        ]),
    ])

    static let f52 = K.lesson("f5.2", "Contrast Creates Interest", "Sparse versus full", "chart.bar.fill", .arrangement, 15, [
        K.intro("Big needs small",
                "A chorus only feels big if something before it was smaller. Producers build that contrast by muting and unmuting layers. Less, then more.",
                [], demo: chorus),
        K.arrange("Sparse, then full", "Section one: just hats and chords. Section two: everything.", .rule,
                  sections: ["Sparse", "Full"], lanes: F.lanes, loop: song,
                  target: K.grid("-x", "-x", "xx", "-x", "xx")),
        K.quiz("Which feels bigger?", "", [
            K.hear([verse, chorus], ["The first", "The second"], 1, "The second adds chords and melody."),
            K.hear([chorus, intro], ["The first", "The second"], 0, "The first has every layer."),
        ]),
        K.arrange("Build it up", "Three sections. Add more layers each time.", .create(.variedSections),
                  sections: ["Low", "Mid", "High"], lanes: F.lanes, loop: song),
    ])

    static let f53 = K.lesson("f5.3", "Make a Transition", "Fills and silence", "arrow.forward.to.line", .arrangement, 15, [
        K.intro("Signal what's next",
                "Right before a new section, producers send a signal: a drum fill, a sudden gap, a sweep. It tells the listener something's about to happen, so the change feels exciting instead of random.",
                [], demo: F.fill),
        K.order("Put the fill at the end", "Four bars. Three plain beats, then the fill right before the next section.", .rule,
                tiles: [K.tile("Beat", F.beat), K.tile("Fill", F.fill, "Snare roll")], answer: [0, 0, 0, 1],
                names: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"]),
        K.order("Or use silence", "Same four bars, but drop everything in bar 4. Then hear the beat crash back in.", .rule,
                tiles: [K.tile("Beat", F.beat), K.tile("Silence", silence, "Nothing")], answer: [0, 0, 0, 1],
                names: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"]),
        K.quiz("Fill or gap?", "Listen to the last bar before the change.", [
            K.hear([F.beat, F.fill, chorus], ["A fill", "A gap", "No transition"], 0),
            K.hear([F.beat, silence, chorus], ["A fill", "A gap", "No transition"], 1),
            K.hear([F.beat, F.beat, chorus], ["A fill", "A gap", "No transition"], 2, "It just changes. Works, but less exciting."),
        ]),
    ])

    static let f54 = K.lesson("f5.4", "Arrange the Blocks", "Intro, verse, chorus, outro", "square.split.2x2.fill", .arrangement, 15, [
        K.intro("Build with blocks",
                "Most songs follow a simple map: start small, build to the big part, end. Here each block is two bars. Tap one to hear it.", []),
        K.order("Build the song", "Intro first, outro last. Verse before chorus.", .rule,
                tiles: blocks(), answer: [0, 1, 2, 3], barsEach: 2, names: ["Start", "", "", "End"]),
        K.quiz("Quick check", "", [
            K.ask("Which section usually has the most layers?", ["Intro", "Verse", "Chorus"], 2),
            K.ask("Why does a chorus feel bigger after a verse?", ["It's louder", "The verse held layers back", "It's faster"], 1,
                  "Contrast. The verse left room for the chorus to fill."),
        ]),
        K.order("A longer map", "Intro, verse, chorus, verse, chorus, outro.", .rule,
                tiles: blocks(), answer: [0, 1, 2, 1, 2, 3], barsEach: 2),
    ])

    static let f55 = K.lesson("f5.5", "My First Mini-Track", "Boss: a finished sketch", "crown.fill", .arrangement, 40, [
        K.intro("Boss: your first mini-track",
                "Time to finish something. Two sections, a transition between them, and an ending. About thirty seconds of music that's yours.",
                [], demo: song),
        K.order("Map it out", "Intro, verse, a fill, chorus, outro. Tap the blocks into place.", .rule,
                tiles: blocks() + [K.tile("Fill", F.fill, "Transition")], answer: [0, 1, 4, 2, 3], barsEach: 2),
        K.arrange("Shape the layers", "Now set the layers for each section yourself. No two neighbours the same.",
                  .create(.variedSections), sections: ["Intro", "Verse", "Chorus", "Outro"], lanes: F.lanes, loop: song),
    ])

    // MARK: - Silver and Gold

    static let levels: [String: LevelPair] = [
        "f4.1": (silver: [
            L.silver("Name the sound",
                     "New melody, new sounds. Listen to how each note starts and how long it rings."),
            K.quiz("Pluck, keys or pad?", "", [
                K.sound(stabs, pad, ["Pluck", "Keys", "Pad"], 2),
                K.sound(stabs, pluck, ["Pluck", "Keys", "Pad"], 0),
                K.sound(stabs, keys, ["Pluck", "Keys", "Pad"], 1),
                K.sound(line, [.chordAttack: 0.5, .chordDecay: 0.9, .chordRelease: 0.6, .chordCutoff: 0.3], ["Pluck", "Keys", "Pad"], 2),
            ]),
            K.lab("Match the pluck", "Find the sound by ear: how fast does it start, and how quickly does it die?",
                  [.chordAttack, .chordDecay], start: [0.7, 0.9], target: [0, 0.15], loop: lineBeat),
        ], gold: [
            L.gold("Sounds have jobs",
                   "Timbre is a tool. Low, round sounds hold the floor. Short, bright ones carry rhythm. Long, soft ones fill space. Design two sounds for two jobs."),
            K.lab("A sound for the floor", "Make a bass that's low and solid, not buzzy.", [.bassWave, .bassCutoff, .bassDecay],
                  start: [0.8, 0.8, 0.2], loop: bassLoop),
            K.lab("A sound for the top", "Now a melody sound that cuts through: bright and quick.", [.chordAttack, .chordDecay, .chordCutoff],
                  start: [0.8, 0.9, 0.2], loop: lineBeat),
            K.lab("Match the pad", "Slow start, long ring, soft and dark.", [.chordAttack, .chordRelease, .chordCutoff],
                  start: [0, 0.1, 0.9], target: [0.75, 0.9, 0.35], loop: stabs),
        ]),
        "f4.2": (silver: [
            L.silver("Match by ear",
                     "Sound designers hear a sound and know which knob made it. Match these targets."),
            K.lab("Match the bass", "Cutoff first, then Envelope.", [.bassCutoff, .bassEnv], start: [0.1, 0.1],
                  target: [0.6, 0.7], loop: bassLoop),
            K.lab("Match the chord shape", "Is it snappy or swelling?", [.chordAttack, .chordDecay], start: [0, 0.1],
                  target: [0.6, 0.85], loop: stabs),
        ], gold: [
            L.gold("Design a lead",
                   "Four knobs, one sound of your own. Then match a trickier target."),
            K.lab("Your lead", "Attack, length, release and cutoff. Land on something you'd put in a track.",
                  [.chordAttack, .chordDecay, .chordRelease, .chordCutoff], start: [0.5, 0.5, 0.5, 0.5], loop: lineBeat),
            K.lab("Match three knobs", "Bright, punchy bass with a resonant edge.", [.bassCutoff, .bassEnv, .bassResonance],
                  start: [0.2, 0.2, 0], target: [0.45, 0.8, 0.6], loop: bassLoop),
        ]),
        "f4.3": (silver: [
            L.silver("How big is the room?",
                     "Reverb isn't on or off. Producers choose a size. Hear the difference between a little and a lot."),
            K.quiz("How much reverb?", "", [
                K.reverb(stabs, amount: 0.15, ["A little", "Medium", "Huge"], 0),
                K.reverb(stabs, amount: 0.9, ["A little", "Medium", "Huge"], 2),
                K.reverb(stabs, amount: 0.5, ["A little", "Medium", "Huge"], 1),
                K.reverb(lineBeat, amount: 0.85, ["A little", "Medium", "Huge"], 2),
            ]),
            K.space("Set it for a melody", "Find a setting where the melody sounds spacious but every note is still clear.", lineBeat),
        ], gold: [
            L.gold("Space without mud",
                   "Too much reverb blurs everything together. The trick is to soak a few accents and keep the main parts clear."),
            K.quiz("Which one stays clear?", "Same loop, two reverb settings.", [
                K.reverb(song, amount: 0.95, ["Clear", "Muddy"], 1, "The drums and melody smear together."),
                K.reverb(song, amount: 0.25, ["Clear", "Muddy"], 0, "A hint of room, everything still sharp."),
            ]),
            K.space("Soak the stabs", "These stabs are sparse. They can take a lot more space. Find a big but tidy setting.",
                    Pattern(kick: [0, 8], chords: [K.ch(6, F.am), K.ch(14, F.f)])),
        ]),
        "f4.4": (silver: [
            L.silver("Fix the mud",
                     "When the bass and chords both crowd the low end, the mix turns to mud. Use volume, then brightness, to separate them."),
            K.mix("Separate the bass and chords", "Both are too loud and fighting. Find the balance.",
                  [.drum(.kick), .drum(.hat), .bass, .chords], start: [K.u, K.u, 1, 1], target: [K.u, K.u, 0.6, 0.55], loop: song),
            K.lab("Darken the chords", "Lower the chord cutoff until they sit behind the melody.", [.chordCutoff],
                  start: [0.9], target: [0.45], loop: song),
        ], gold: [
            L.gold("Before and after",
                   "Mix the full track from scratch. Then check yourself on a few broken mixes."),
            K.mix("Your mix", "Every fader starts at the bottom. Build the balance from the kick up.",
                  [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords], start: [0.1, 0.1, 0.1, 0.1, 0.1], loop: song),
            K.quiz("What's wrong with this mix?", "", [
                K.faders(song, [.drum(.hat): 1, .drum(.kick): 0.4], ["Hats too loud", "Bass too loud", "It's fine"], 0),
                K.faders(song, [:], ["Hats too loud", "Bass too loud", "It's fine"], 2),
                K.faders(song, [.bass: 1], ["Hats too loud", "Bass too loud", "It's fine"], 1),
            ]),
        ]),
        "f4.5": (silver: [
            L.silver("Something doesn't belong",
                     "One sound in each loop is out of place. Find it, then fix a sound by ear."),
            K.quiz("Which sound clashes?", "", [
                K.sound(song, [.bassWave: 1, .bassResonance: 0.9, .bassCutoff: 0.9], ["The bass", "The chords"], 0,
                        "A screaming square bass in a soft loop."),
                K.sound(song, [.chordAttack: 0.9, .chordRelease: 1], ["The bass", "The chords"], 1,
                        "The chords swell so slowly they smear the beat."),
            ]),
            K.lab("Fix the bass", "Make it fit: rounder and darker.", [.bassWave, .bassCutoff], start: [1, 0.9],
                  target: [0.1, 0.3], loop: bassLoop),
        ], gold: [
            L.gold("Your four sounds",
                   "Kick, bass, chords, mix. Design each one, then balance them. This palette is yours."),
            K.lab("Your kick", "Pitch, length and drive.", [.kickPitch, .kickDecay, .kickDrive], start: [0.5, 0.5, 0.3],
                  loop: Pattern(kick: [0, 4, 8, 12], hat: F.offbeats)),
            K.lab("Your bass", "Wave, cutoff and length.", [.bassWave, .bassCutoff, .bassDecay], start: [0.5, 0.5, 0.5], loop: bassLoop),
            K.lab("Your chords", "Attack, length, cutoff.", [.chordAttack, .chordDecay, .chordCutoff], start: [0.5, 0.5, 0.5], loop: stabs),
            K.mix("Balance it", "Make every part clear.", [.drum(.kick), .drum(.clap), .bass, .chords],
                  start: [K.u, K.u, K.u, K.u], loop: song),
        ]),
        "f5.1": (silver: [
            L.silver("Map the song",
                     "No labels now. Hear each part and work out what it is."),
            K.order("Label the sections", "Play the reference. Four parts, two bars each. Tap them in the order you hear.",
                    .recreate, tiles: blocks(), answer: [0, 1, 2, 1], barsEach: 2),
            K.tapChanges("Subtler changes", "Only one layer changes each time. Tap each new section.",
                         loops: [intro, verse, verse.merged(with: Pattern(chords: [K.ch(0, F.c, 6), K.ch(8, F.am, 6)])), chorus],
                         barsEach: 2),
        ], gold: [
            L.gold("Your structure",
                   "Build a two-part structure where each part is clearly different. Then label someone else's."),
            K.arrange("Build A and B", "Four sections: intro, A, B, A. Each different from its neighbour.",
                      .create(.variedSections), sections: ["Intro", "A", "B", "A"], lanes: F.lanes, loop: song),
            K.order("Label a longer song", "Six parts. Some repeat.", .recreate, tiles: blocks(), answer: [0, 1, 2, 1, 2, 3],
                    barsEach: 2),
        ]),
        "f5.2": (silver: [
            L.silver("Make the chorus bigger",
                     "Copy an arrangement where the chorus adds layers, then feel which layers matter most."),
            K.arrange("Recreate verse and chorus", "Listen to each section and switch on what's playing.", .recreate,
                      sections: ["Verse", "Chorus", "Verse", "Chorus"], lanes: F.lanes, loop: song,
                      target: K.grid("xxxx", "xxxx", "-x-x", "xxxx", "-x-x")),
            K.quiz("What made it bigger?", "", [
                K.hear([verse, chorus], ["Chords and melody joined", "The kick got louder", "It got faster"], 0),
                K.hear([intro, verse], ["Drums and bass joined", "Chords joined", "Nothing changed"], 0),
            ]),
        ], gold: [
            L.gold("An energy arc",
                   "Plan four stages: start, build, peak, drop back. Use only layer changes to tell the story."),
            K.arrange("Your arc", "Four sections, each different from the last.", .create(.variedSections),
                      sections: ["Start", "Build", "Peak", "Drop back"], lanes: F.lanes, loop: song),
            K.tapChanges("Feel the arc", "Tap each new stage.", loops: [intro, verse, chorus, intro], barsEach: 2),
        ]),
        "f5.3": (silver: [
            L.silver("Choose the transition",
                     "Different moments need different signals. A fill builds excitement. A gap creates suspense."),
            K.quiz("Which transition fits?", "", [
                K.ask("You want the chorus to hit like a punch. Before it…", ["A full bar of silence", "Keep the beat going", "Fade out slowly"], 0,
                      "Silence makes the return hit hard."),
                K.ask("You want to roll smoothly from verse to verse…", ["A short snare fill", "Stop everything", "Change tempo"], 0),
            ]),
            K.order("Build-up, then drop", "Two beats, a fill, a silent bar, then the chorus.", .rule,
                    tiles: [K.tile("Beat", F.beat), K.tile("Fill", F.fill), K.tile("Silence", silence), K.tile("Chorus", chorus)],
                    answer: [0, 0, 1, 2, 3]),
        ], gold: [
            L.gold("Your fill",
                   "Write your own one-bar fill, then decide where it goes."),
            L.make("Write a fill", "Snares and kicks building toward the end of the bar. At least five snares.",
                   tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat], start: F.beatNoHats,
                   goal: .atLeast(.clap, 5)),
            K.order("Place the transitions", "Eight bars. Use beats, fills, silence and the chorus however you like.",
                    .create(.chordsAtLeast(8)),
                    tiles: [K.tile("Beat", F.beat), K.tile("Fill", F.fill), K.tile("Silence", silence), K.tile("Chorus", chorus)],
                    slots: 8),
        ]),
        "f5.4": (silver: [
            L.silver("Too repetitive",
                     "This arrangement never changes. Hear the fixed version and rebuild it."),
            K.order("Repair it", "It starts as verse after verse. Listen to the reference and rebuild it.", .recreate,
                    tiles: blocks(), answer: [0, 1, 2, 1, 2, 3], start: [0, 1, 1, 1, 1, 3], barsEach: 2),
            K.quiz("Why was it boring?", "", [
                K.ask("Verse, verse, verse, verse is boring because…", ["Nothing contrasts", "It's too short", "It has no bass"], 0),
            ]),
        ], gold: [
            L.gold("Same blocks, new story",
                   "Producers reorder sections to tell different stories: a song that starts with the chorus, or one that strips down at the end. Build two versions."),
            K.order("Start with the hook", "Six blocks. Open with the chorus, then do whatever you like.", .create(.variedSections),
                    tiles: blocks(), slots: 6, start: [2], locked: [0], barsEach: 2),
            K.order("A slow build", "Eight blocks. Hold the chorus back until late.", .create(.variedSections),
                    tiles: blocks() + [K.tile("Fill", F.fill)], slots: 8, barsEach: 2),
        ]),
        "f5.5": (silver: [
            L.silver("Make it longer",
                     "Extend your sketch to about 45 seconds, with a fill of your own and a proper ending."),
            L.make("Your fill", "At least four snares.", tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                   start: F.beatNoHats, goal: .atLeast(.clap, 4)),
            K.order("Map a longer track", "Ten blocks, two bars each. End on the outro.", .create(.variedSections),
                    tiles: blocks() + [K.tile("Fill", F.fill)], slots: 10, barsEach: 2),
            K.arrange("Shape the layers", "Six sections, each different from its neighbour.", .create(.variedSections),
                      sections: ["Intro", "Verse", "Chorus", "Verse", "Chorus", "Outro"], lanes: F.lanes, loop: song),
        ], gold: [
            L.gold("A minute of music",
                   "Three sections, a variation, and an ending. Make it sound like you. When you finish, take the idea into the Studio and keep going."),
            L.make("Variation beat", "A second beat for your variation section. At least five kicks.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc], start: F.beat,
                   goal: .atLeast(.kick, 5)),
            K.leadMake("Your hook", "A melody for the chorus. At least six notes.", rows: F.leadRows, backing: F.full, notes: 6),
            K.order("The full map", "Twelve blocks. No two neighbours the same.", .create(.variedSections),
                    tiles: blocks() + [K.tile("Fill", F.fill), K.tile("Break", breakdown, "Chords only")], slots: 12, barsEach: 2),
        ]),
    ]
}
