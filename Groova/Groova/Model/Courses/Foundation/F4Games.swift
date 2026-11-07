//
//  F4Games.swift
//  Groova
//
//  F4, Sounds & Production Tools, in the Teach → Studio → Game flow:
//
//  F4.1 What Makes Sounds Different? → Sound X-Ray        F4.2 Shape a Synth → Synth Surgery
//  F4.3 Space & Echo → Acoustic Architect                 F4.4 Make Parts Fit → Mix Traffic Control
//  F4.5 Create a Palette → Sound Casting
//

import Foundation

nonisolated enum F4Games {
    typealias F = FKit
    typealias S = F4F5

    static let earName = "Quick Ear"
    static let dialName = "Dial It In"
    static let lessons: [Lesson] = [f41, f42, f43, f44, f45]

    static let clapLoop = Pattern(kick: [0, 8], clap: [4, 12])
    static let clapAlone = Pattern(clap: [4, 12])

    // MARK: - F4.1 → Sound X-Ray

    static let xrayName = "Sound X-Ray"
    static let xrayLine = "Every sound has a fingerprint. Read it."

    static let f41 = K.lesson("f4.1", "What Makes Sounds Different?", "Timbre", "waveform", .soundDesign, 15, [
        K.opening("Same notes, new sound",
                  "The same melody can sound completely different on different instruments. First you'll keep a melody locked and swap the sound underneath it. Then you'll hear the same note on two sounds and pick the brighter one."),
        K.teach("One melody, three characters",
                "Listen to how each note starts and how long it rings. The notes never change. That character is called timbre.",
                demo: S.lineBeat),
        K.lab("Reshape the instrument", "The notes are locked. Move Attack, Length and Cutoff and hear a pluck melt into a pad.",
              [.chordAttack, .chordDecay, .chordCutoff], start: [0, 0.2, 0.6], loop: S.lineBeat),
        K.game(earName, "Same note, two sounds. Which is brighter?", .quickEar(.brighter("f4.1"))),
    ])

    static let f41Silver: [LessonStep] = [
        L.silver("Identify hidden traits",
                 "Now the pictures go and only the sound is left. First you'll match a sound's shape by ear. Then you'll pick the brighter sound when they're close."),
        K.teach("Shape, not name",
                "A quick start and short ring makes a pluck. A slow start and long ring makes a pad. Listen for the shape, not the instrument's name.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [60], length: 2), ChordEvent(step: 8, pitches: [60], length: 7)])),
        K.lab("Match the pluck", "Find it by ear: how fast does it start, and how quickly does it die?",
              [.chordAttack, .chordDecay], start: [0.7, 0.9], target: [0, 0.15], loop: S.lineBeat),
        K.game(earName, "Closer sounds now.", .quickEar(.brighter("f4.1s", count: 12, gap: 0.55))),
    ]

    static let f41Gold: [LessonStep] = [
        L.gold("Invent a sound identity",
               "Now invent a sound that doesn't belong to just one instrument. Pick a brief, take the front of one sound and the tail of another, and save the fingerprint you made."),
        K.teach("Layering is a choice",
                "Producers stack a sharp sound and a soft one so a note starts with a snap and then blooms. Two sounds, one identity.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [60, 72], length: 10)])),
        K.lab("Design the bloom", "Shape a sound that starts quick and rings long. That's the tail half of your hybrid.",
              [.chordAttack, .chordRelease, .chordCutoff], start: [0, 0.1, 0.9], loop: S.stabs),
        K.game(earName, "Very close. Trust your ears.", .quickEar(.brighter("f4.1g", count: 15, gap: 0.25))),
    ]

    // MARK: - F4.2 → Synth Surgery

    static let surgeryName = "Synth Surgery"
    static let surgeryLine = "The sound is a sculpture. Reshape it with your hands."

    static let f42 = K.lesson("f4.2", "Shape a Synth", "Attack, release and filter", "dial.medium.fill", .soundDesign, 15, [
        K.opening("Snap, swell or disappear",
                  "A synth can snap, swell, shimmer or vanish, depending on how you shape it. First you'll turn real attack, release and cutoff controls. Then you'll match a synth's attack by ear."),
        K.teach("A pluck becomes a pad",
                "The same note with a short attack, then a long one. Then the filter closes and the brightness drains away.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [60, 64, 67], length: 2), ChordEvent(step: 8, pitches: [60, 64, 67], length: 7)])),
        K.lab("The synth panel", "Attack, Release and Cutoff. Move one at a time and listen to what each does.",
              [.chordAttack, .chordRelease, .chordCutoff], start: [0, 0.1, 0.9], loop: S.lineBeat),
        K.game(dialName, "Match how the notes fade in.", .dial(DialConfig(kind: .attack, prompt: "Match the fade-in", low: "Snappy", high: "Slow", targets: [0.8, 0.15, 0.5], tolerance: 0.1))),
    ])

    static let f42Silver: [LessonStep] = [
        L.silver("Repair a sound",
                 "I'll play a sound, and your job is to work out how it was shaped. First you'll match a reference patch on the synth panel. Then you'll match a synth's release by ear."),
        K.teach("Listen in three parts",
                "Match a sound one question at a time. How does it start? How long does it ring? How bright is it?",
                demo: S.lineBeat),
        K.lab("Match the dark pluck", "Starting from a bright, sustained sound. Shorten it and darken it to match.",
              [.chordAttack, .chordRelease, .chordCutoff], start: [0.6, 0.9, 0.9], target: [0, 0.15, 0.3], loop: S.lineBeat),
        K.game(dialName, "Match how long the notes ring.", .dial(DialConfig(kind: .release, prompt: "Match the tail", low: "Short", high: "Long", targets: [0.75, 0.2, 0.5, 0.9], tolerance: 0.09))),
    ]

    static let f42Gold: [LessonStep] = [
        L.gold("Design your own instrument",
               "Design a synth sound for a real job. Pick whether it should pluck, pad or lead, sculpt two versions of it, and hear both inside a track before you keep one."),
        K.teach("Sounds have jobs",
                "There's no correct knob position. A sound is right when it does its job in the track: a pluck keeps rhythm, a pad fills space, a lead sings on top.",
                demo: S.song),
        K.lab("Your lead on the panel", "Four controls, one sound of your own. Land on something you'd put in a track.",
              [.chordAttack, .chordDecay, .chordRelease, .chordCutoff], start: [0.5, 0.5, 0.5, 0.5], loop: S.lineBeat),
        K.game(dialName, "Tighter matches.", .dial(DialConfig(kind: .attack, prompt: "Match the fade-in", low: "Snappy", high: "Slow", targets: [0.35, 0.65, 0.2, 0.85], tolerance: 0.07))),
    ]

    // MARK: - F4.3 → Acoustic Architect

    static let architectName = "Acoustic Architect"
    static let architectLine = "Walk your sound into a room and hear the walls."

    static let f43 = K.lesson("f4.3", "Space & Echo", "Reverb and delay", "dot.radiowaves.left.and.right", .mixing, 15, [
        K.opening("Put it in a room",
                  "Sound can make a tiny room feel close or a huge hall feel endless. First you'll turn up real reverb on a clap. Then you'll match how much reverb a beat has."),
        K.teach("Dry, room, echo",
                "A dry clap has no tail. In a room it blooms into a smooth wash. An echo repeats it, one clear copy after another.",
                demo: clapLoop),
        K.space("Add reverb to the clap", "Drag the reverb up from dry and listen to the tail after each clap.", clapLoop),
        K.game(dialName, "Match the reverb.", .dial(DialConfig(kind: .reverb, prompt: "Match the space", low: "Dry", high: "Huge", groove: Pattern(kick: [0, 8], clap: [4, 12]), targets: [0.75, 0.2, 0.5], tolerance: 0.12))),
    ])

    static let f43Silver: [LessonStep] = [
        L.silver("Solve audio architecture",
                 "A space can make music clearer or completely blur it. First you'll set reverb on a melody so it stays clear. Then you'll match reverb on a full mix."),
        K.teach("Too much room",
                "Short notes in a huge wet space smear into each other. Echoes that line up with the beat sound tight. Ones that don't sound messy.",
                demo: S.lineBeat),
        K.space("Clear but spacious", "Find a setting where the melody sounds spacious but every note is still clear.", S.lineBeat),
        K.game(dialName, "Now on a full mix.", .dial(DialConfig(kind: .reverb, prompt: "Match the space", low: "Dry", high: "Huge", groove: F.full, targets: [0.35, 0.6, 0.15, 0.85], tolerance: 0.09))),
    ]

    static let f43Gold: [LessonStep] = [
        L.gold("Make a spatial moment",
               "Give a sound a sense of place and motion. Pick a source, move it from close and dry to far and wide over four beats, throw one echo at the end, and save the moment."),
        K.teach("Space can move",
                "A sound can travel. Start close and dry, then drift into a huge room, and it feels like it's flying away.",
                demo: S.stabs),
        K.space("Soak the stabs", "These stabs are sparse, so they can take a lot of space. Find a big but tidy setting.",
                Pattern(kick: [0, 8], chords: [K.ch(6, F.am), K.ch(14, F.f)])),
        K.game(dialName, "Tighter matches.", .dial(DialConfig(kind: .reverb, prompt: "Match the space", low: "Dry", high: "Huge", groove: F.full, targets: [0.45, 0.25, 0.7, 0.55], tolerance: 0.07))),
    ]

    // MARK: - F4.4 → Mix Traffic Control

    static let trafficName = "Mix Traffic Control"
    static let trafficLine = "Four lanes, one ear. Keep the traffic moving."

    static let f44 = K.lesson("f4.4", "Make Parts Fit", "Volume balance", "slider.vertical.3", .mixing, 15, [
        K.opening("Give each part space",
                  "When every instrument fights for attention, a mix gets crowded. First you'll balance real faders on a mixer. Then you'll match the bass level by ear."),
        K.teach("Level changes clarity",
                "Everything at the same volume is a traffic jam. Pull the chords back a touch and the melody steps forward. The notes don't change at all.",
                demo: S.song),
        K.mix("Bring the melody out", "The melody (on Chords) is buried under the bass. Pull the bass down and push the melody up.",
              [.drum(.kick), .bass, .chords], start: [K.u, 0.95, 0.3], target: [K.u, 0.55, 0.75], loop: S.song),
        K.game(dialName, "Set the bass as loud as the target.", .dial(DialConfig(kind: .bassLevel, prompt: "Match the bass level", low: "Quiet", high: "Loud", groove: F.beatBass, targets: [0.6, 0.25, 0.85], tolerance: 0.12))),
    ])

    static let f44Silver: [LessonStep] = [
        L.silver("Make decisions in context",
                 "There's no single perfect mix. Every choice changes what a listener notices. First you'll untangle a crowded low end. Then you'll match the kick level in a full mix."),
        K.teach("Masking",
                "A long, loud bass sits on top of the kick and hides it. Turn the bass down, or make it shorter, and the kick punches through again.",
                demo: S.bassLoop),
        K.mix("Separate the bass and chords", "Both are too loud and fighting. Find the balance.",
              [.drum(.kick), .drum(.hat), .bass, .chords], start: [K.u, K.u, 1, 1], target: [K.u, K.u, 0.6, 0.55], loop: S.song),
        K.game(dialName, "Now the kick, in a full mix.", .dial(DialConfig(kind: .drumLevel(.kick), prompt: "Match the kick level", low: "Quiet", high: "Loud", groove: F.full, targets: [0.4, 0.75, 0.2, 0.6], tolerance: 0.1))),
    ]

    static let f44Gold: [LessonStep] = [
        L.gold("Deliver a tiny mix",
               "Take control of a short track and decide what leads. Pick a feature, make two honest mixes from the same parts, then choose between them without looking at the faders."),
        K.teach("A mix has a point of view",
                "Two mixes can both be good and still feature different parts. One sings, one drives. You choose.",
                demo: S.song),
        K.mix("Your first balance", "Every fader starts at the bottom. Build the balance from the kick up.",
              [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords], start: [0.1, 0.1, 0.1, 0.1, 0.1], loop: S.song),
        K.game(dialName, "The hi-hat. Small moves matter.", .dial(DialConfig(kind: .drumLevel(.hat), prompt: "Match the hi-hat level", low: "Quiet", high: "Loud", groove: F.full, targets: [0.55, 0.3, 0.8, 0.45], tolerance: 0.08))),
    ]

    // MARK: - F4.5 → Sound Casting

    static let castingName = "Sound Casting"
    static let castingLine = "You're the casting director. Every sound auditions."

    static let f45 = K.lesson("f4.5", "Create a Palette", "Sounds that belong together", "crown.fill", .soundDesign, 20, [
        K.opening("Cast a band",
                  "Choosing instruments is like casting a band: every sound needs a role. First you'll swap sounds while the notes stay locked. Then you'll match the brightness of a full band."),
        K.teach("Same song, new band",
                "The bassline, chords and melody never change. Swap the sounds and the whole track gets a new personality. That set of sounds is your palette.",
                demo: S.song),
        K.lab("Swap the bass", "Same bassline. Turn the wave and cutoff from a round sub into a buzzy synth bass.",
              [.bassWave, .bassCutoff], start: [0, 0.3], loop: S.bassLoop),
        K.game(dialName, "Match how bright the band sounds.", .dial(DialConfig(kind: .filter, prompt: "Match the brightness", low: "Dark", high: "Bright", groove: F.full, targets: [0.3, 0.8, 0.55], tolerance: 0.1))),
    ])

    static let f45Silver: [LessonStep] = [
        L.silver("Curate with constraints",
                 "More instruments don't automatically make better music. First you'll fix a sound that doesn't belong. Then you'll match brightness with less room for error."),
        K.teach("Less can be more",
                "Two parts in the same space hide each other. Take one away and the other gets clearer.",
                demo: S.song),
        K.lab("Fix the bass", "It's screaming over a soft loop. Make it rounder and darker so it fits.", [.bassWave, .bassCutoff],
              start: [1, 0.9], target: [0.1, 0.3], loop: S.bassLoop),
        K.game(dialName, "Four rounds, tighter.", .dial(DialConfig(kind: .filter, prompt: "Match the brightness", low: "Dark", high: "Bright", groove: F.full, targets: [0.65, 0.4, 0.2, 0.9], tolerance: 0.08))),
    ]

    static let f45Gold: [LessonStep] = [
        L.gold("Cast your first band",
               "Build the sound of a track from scratch. Choose a direction, cast your band, make one swap for a version B, and run a showcase. Your palette gets saved for your mini-track."),
        K.teach("Intention beats rules",
                "A palette works when the sounds suit what you're going for. Warm, edgy or minimal can all be right.",
                demo: S.song),
        K.lab("Your chord sound", "Plucky keys, a soft pad or anything between.", [.chordAttack, .chordDecay, .chordCutoff],
              start: [0, 0.5, 0.6], loop: S.stabs),
        K.game(dialName, "Five rounds. Very tight.", .dial(DialConfig(kind: .filter, prompt: "Match the brightness", low: "Dark", high: "Bright", groove: F.full, targets: [0.5, 0.35, 0.7, 0.6, 0.25], tolerance: 0.06))),
    ]

    static let levels: [String: LevelPair] = [
        "f4.1": (silver: f41Silver, gold: f41Gold),
        "f4.2": (silver: f42Silver, gold: f42Gold),
        "f4.3": (silver: f43Silver, gold: f43Gold),
        "f4.4": (silver: f44Silver, gold: f44Gold),
        "f4.5": (silver: f45Silver, gold: f45Gold),
    ]
}
