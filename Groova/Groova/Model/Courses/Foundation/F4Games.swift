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

    static let lessons: [Lesson] = [f41, f42, f43, f44, f45]

    static let clapLoop = Pattern(kick: [0, 8], clap: [4, 12])
    static let clapAlone = Pattern(clap: [4, 12])

    // MARK: - F4.1 → Sound X-Ray

    static let xrayName = "Sound X-Ray"
    static let xrayLine = "Every sound has a fingerprint. Read it."

    static let f41 = K.lesson("f4.1", "What Makes Sounds Different?", "Timbre", "waveform", .soundDesign, 15, [
        K.opening("Same notes, new sound",
                  "The same melody can sound completely different on different instruments. First you'll keep a melody locked and swap the sound underneath it. Then you'll read each sound's fingerprint in the X-ray: how it starts, how it holds and how it fades."),
        K.teach("One melody, three characters",
                "Listen to how each note starts and how long it rings. The notes never change. That character is called timbre.",
                demo: S.lineBeat),
        K.lab("Reshape the instrument", "The notes are locked. Move Attack, Length and Cutoff and hear a pluck melt into a pad.",
              [.chordAttack, .chordDecay, .chordCutoff], start: [0, 0.2, 0.6], loop: S.lineBeat),
        K.game(xrayName, xrayLine, .xray([
            XRayRound(title: "Same melody, three identities", body: "Tap each fingerprint to hear the same four notes on a new instrument.",
                      mode: .identities([.piano, .pluck, .pad])),
            XRayRound(title: "Peel back the sound", body: "One long note. Swipe across it to hear its attack, its body and its tail on their own.",
                      mode: .peel(.keys)),
            XRayRound(title: "Match the X-ray", body: "Hear the mystery sound, then pick the fingerprint that fits it.",
                      mode: .match(.pluck, options: [.pad, .pluck])),
        ])),
    ])

    static let f41Silver: [LessonStep] = [
        L.silver("Identify hidden traits",
                 "Now the pictures go and only the sound is left. First you'll match a sound's shape by ear. Then you'll identify mystery sounds and pull a layered sound apart."),
        K.teach("Shape, not name",
                "A quick start and short ring makes a pluck. A slow start and long ring makes a pad. Listen for the shape, not the instrument's name.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [60], length: 2), ChordEvent(step: 8, pitches: [60], length: 7)])),
        K.lab("Match the pluck", "Find it by ear: how fast does it start, and how quickly does it die?",
              [.chordAttack, .chordDecay], start: [0.7, 0.9], target: [0, 0.15], loop: S.lineBeat),
        K.game(xrayName, xrayLine, .xray([
            XRayRound(title: "Invisible instrument", body: "No picture for the mystery sound. Which of the three shapes fits it?",
                      mode: .match(.pad, options: [.pluck, .bell, .pad])),
            XRayRound(title: "Same pitch trap", body: "Same note, same rhythm. Only the instrument is different. Which one is it?",
                      mode: .match(.organ, options: [.piano, .organ, .keys])),
            XRayRound(title: "Layer autopsy", body: "This sound is two sounds stacked. Hear it, then pick both of its layers.",
                      mode: .layers(.click, .pad, options: [.click, .bell, .pad, .organ])),
        ])),
    ]

    static let f41Gold: [LessonStep] = [
        L.gold("Invent a sound identity",
               "Now invent a sound that doesn't belong to just one instrument. Pick a brief, take the front of one sound and the tail of another, and save the fingerprint you made."),
        K.teach("Layering is a choice",
                "Producers stack a sharp sound and a soft one so a note starts with a snap and then blooms. Two sounds, one identity.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [60, 72], length: 10)])),
        K.lab("Design the bloom", "Shape a sound that starts quick and rings long. That's the tail half of your hybrid.",
              [.chordAttack, .chordRelease, .chordCutoff], start: [0, 0.1, 0.9], loop: S.stabs),
        K.game(xrayName, "Your sound, your fingerprint.", .xray([
            XRayRound(title: "Choose a sonic brief", body: "Pick the feeling you're designing for. There's no wrong choice.",
                      mode: .brief),
            XRayRound(title: "Assemble a hybrid", body: "Pick a front and a tail, then slide the blend. Tap the middle to hear your sound.",
                      mode: .hybrid([.click, .pluck, .bell, .pad, .organ])),
            XRayRound(title: "Reveal your fingerprint", body: "Play your hybrid against its two sources. Name it and save the card.",
                      mode: .reveal),
        ])),
    ]

    // MARK: - F4.2 → Synth Surgery

    static let surgeryName = "Synth Surgery"
    static let surgeryLine = "The sound is a sculpture. Reshape it with your hands."

    static let f42 = K.lesson("f4.2", "Shape a Synth", "Attack, release and filter", "dial.medium.fill", .soundDesign, 15, [
        K.opening("Snap, swell or disappear",
                  "A synth can snap, swell, shimmer or vanish, depending on how you shape it. First you'll turn real attack, release and cutoff controls. Then the sound becomes a sculpture you reshape with your fingers."),
        K.teach("A pluck becomes a pad",
                "The same note with a short attack, then a long one. Then the filter closes and the brightness drains away.",
                demo: Pattern(chords: [ChordEvent(step: 0, pitches: [60, 64, 67], length: 2), ChordEvent(step: 8, pitches: [60, 64, 67], length: 7)])),
        K.lab("The synth panel", "Attack, Release and Cutoff. Move one at a time and listen to what each does.",
              [.chordAttack, .chordRelease, .chordCutoff], start: [0, 0.1, 0.9], loop: S.lineBeat),
        K.game(surgeryName, surgeryLine, .surgery([
            SurgeryRound(title: "Snap or swell", body: "Drag the pink front edge to the right. The sound starts arriving slowly, like a pad.",
                         mode: .explore(.attack)),
            SurgeryRound(title: "Short or long", body: "Drag the gold tail handle. Trim it for staccato, stretch it to let notes ring.",
                         mode: .explore(.release)),
            SurgeryRound(title: "Bright or dark", body: "Pull the veil down over the sculpture. Same notes, darker colour.",
                         mode: .explore(.filter)),
        ])),
    ])

    static let f42Silver: [LessonStep] = [
        L.silver("Repair a sound",
                 "I'll play a sound, and your job is to work out how it was shaped. First you'll match a reference patch on the synth panel. Then you'll repair sounds with fewer and fewer hints."),
        K.teach("Listen in three parts",
                "Match a sound one question at a time. How does it start? How long does it ring? How bright is it?",
                demo: S.lineBeat),
        K.lab("Match the dark pluck", "Starting from a bright, sustained sound. Shorten it and darken it to match.",
              [.chordAttack, .chordRelease, .chordCutoff], start: [0.6, 0.9, 0.9], target: [0, 0.15, 0.3], loop: S.lineBeat),
        K.game(surgeryName, surgeryLine, .surgery([
            SurgeryRound(title: "Reference match", body: "The target is a quick pluck. Yours swells in slowly. Fix the front edge.",
                         mode: .match(target: SculptShape(attack: 0.02, release: 0.3, filter: 0.8),
                                      start: SculptShape(attack: 0.75, release: 0.3, filter: 0.8), tools: [.attack], showTarget: true)),
            SurgeryRound(title: "Three-tool challenge", body: "Make this bright, long sound short and dark like the target.",
                         mode: .match(target: SculptShape(attack: 0.02, release: 0.1, filter: 0.25),
                                      start: SculptShape(attack: 0.5, release: 0.9, filter: 0.95), tools: [.attack, .release, .filter], showTarget: true)),
            SurgeryRound(title: "Blind adjustment", body: "No outline this time. Flip between yours and the target and shape it by ear.",
                         mode: .match(target: SculptShape(attack: 0.45, release: 0.7, filter: 0.5),
                                      start: SculptShape(attack: 0, release: 0.1, filter: 0.9), tools: [.attack, .release, .filter], showTarget: false)),
        ])),
    ]

    static let f42Gold: [LessonStep] = [
        L.gold("Design your own instrument",
               "Design a synth sound for a real job. Pick whether it should pluck, pad or lead, sculpt two versions of it, and hear both inside a track before you keep one."),
        K.teach("Sounds have jobs",
                "There's no correct knob position. A sound is right when it does its job in the track: a pluck keeps rhythm, a pad fills space, a lead sings on top.",
                demo: S.song),
        K.lab("Your lead on the panel", "Four controls, one sound of your own. Land on something you'd put in a track.",
              [.chordAttack, .chordDecay, .chordRelease, .chordCutoff], start: [0.5, 0.5, 0.5, 0.5], loop: S.lineBeat),
        K.game(surgeryName, "Your instrument.", .surgery([
            SurgeryRound(title: "Choose a role", body: "Pluck, pad or lead. Tap each one to hear what it does.", mode: .role),
            SurgeryRound(title: "Sculpt version A", body: "Shape your instrument with all three gestures.", mode: .design(second: false)),
            SurgeryRound(title: "Sculpt version B", body: "Same notes, a contrasting shape. Move at least one edge a long way.", mode: .design(second: true)),
            SurgeryRound(title: "Hear it in music", body: "Flip between A and B over the band, then keep the one that fits.", mode: .inTrack),
        ])),
    ]

    // MARK: - F4.3 → Acoustic Architect

    static let architectName = "Acoustic Architect"
    static let architectLine = "Walk your sound into a room and hear the walls."

    static let f43 = K.lesson("f4.3", "Space & Echo", "Reverb and delay", "dot.radiowaves.left.and.right", .mixing, 15, [
        K.opening("Put it in a room",
                  "Sound can make a tiny room feel close or a huge hall feel endless. First you'll turn up real reverb on a clap. Then you'll drag the clap through a floor plan of rooms and down an echo tunnel."),
        K.teach("Dry, room, echo",
                "A dry clap has no tail. In a room it blooms into a smooth wash. An echo repeats it, one clear copy after another.",
                demo: clapLoop),
        K.space("Add reverb to the clap", "Drag the reverb up from dry and listen to the tail after each clap.", clapLoop),
        K.game(architectName, architectLine, .architect([
            ArchitectRound(title: "Tiny room, huge hall", body: "Drag the clap from the open air into each room. Listen to how long it rings.",
                           mode: .rooms([.room, .hall])),
            ArchitectRound(title: "Echo vs ambience", body: "Drop the clap in the hall, then slide it into the echo tunnel. A wash, then separate repeats.",
                           mode: .tunnel),
            ArchitectRound(title: "Find the space", body: "Three mystery clips. Hear each one, then tap the room it came from.",
                           mode: .identify([nil, .room, .hall])),
        ])),
    ])

    static let f43Silver: [LessonStep] = [
        L.silver("Solve audio architecture",
                 "A space can make music clearer or completely blur it. First you'll set reverb on a melody so it stays clear. Then you'll match an echo's timing, fix a muddy mix and spot a clip from the wrong room."),
        K.teach("Too much room",
                "Short notes in a huge wet space smear into each other. Echoes that line up with the beat sound tight. Ones that don't sound messy.",
                demo: S.lineBeat),
        K.space("Clear but spacious", "Find a setting where the melody sounds spacious but every note is still clear.", S.lineBeat),
        K.game(architectName, architectLine, .architect([
            ArchitectRound(title: "Time the echo", body: "The target echoes every half beat. Drag the end of the tunnel until your echoes line up.",
                           mode: .echoTime(target: 2)),
            ArchitectRound(title: "Too much room", body: "The melody is drowning in the hall. Drag it closer to you until every note is clear.",
                           mode: .wetFix(target: 0.3)),
            ArchitectRound(title: "Spatial mismatch", body: "Two of these clips share a room. Find the one from somewhere else.",
                           mode: .outlier([.room, .cathedral, .room])),
        ])),
    ]

    static let f43Gold: [LessonStep] = [
        L.gold("Make a spatial moment",
               "Give a sound a sense of place and motion. Pick a source, move it from close and dry to far and wide over four beats, throw one echo at the end, and save the moment."),
        K.teach("Space can move",
                "A sound can travel. Start close and dry, then drift into a huge room, and it feels like it's flying away.",
                demo: S.stabs),
        K.space("Soak the stabs", "These stabs are sparse, so they can take a lot of space. Find a big but tidy setting.",
                Pattern(kick: [0, 8], chords: [K.ch(6, F.am), K.ch(14, F.f)])),
        K.game(architectName, "Your sound, your space.", .architect([
            ArchitectRound(title: "Choose a source", body: "A synth stab, a piano note or a percussion hit.", mode: .chooseSource),
            ArchitectRound(title: "Design a spatial journey", body: "Tap record, then drag the source away from your ear over four beats. Add one echo throw.",
                           mode: .journey),
            ArchitectRound(title: "Record the reveal", body: "Dry, then your journey. Hear the difference and save it.", mode: .reveal),
        ])),
    ]

    // MARK: - F4.4 → Mix Traffic Control

    static let trafficName = "Mix Traffic Control"
    static let trafficLine = "Four lanes, one ear. Keep the traffic moving."

    static let f44 = K.lesson("f4.4", "Make Parts Fit", "Volume balance", "slider.vertical.3", .mixing, 15, [
        K.opening("Give each part space",
                  "When every instrument fights for attention, a mix gets crowded. First you'll balance real faders on a mixer. Then four lanes of sound flow into your ear like traffic, and you clear the way for the part that matters."),
        K.teach("Level changes clarity",
                "Everything at the same volume is a traffic jam. Pull the chords back a touch and the melody steps forward. The notes don't change at all.",
                demo: S.song),
        K.mix("Bring the melody out", "The melody (on Chords) is buried under the bass. Pull the bass down and push the melody up.",
              [.drum(.kick), .bass, .chords], start: [K.u, 0.95, 0.3], target: [K.u, 0.55, 0.75], loop: S.song),
        K.game(trafficName, trafficLine, .traffic([
            TrafficRound(title: "Hear the traffic jam", body: "Four lanes at the same loudness. Solo each one and name it.", mode: .solo),
            TrafficRound(title: "Set the lead", body: "The melody is too far back. Push its lane up into the gold pocket, then compare.",
                         mode: .level(lane: 3, from: 0.3)),
            TrafficRound(title: "Clear the route", body: "One lane is crowding the melody. Pull back only that one and watch the focus light.",
                         mode: .culprit(lane: 2)),
        ])),
    ])

    static let f44Silver: [LessonStep] = [
        L.silver("Make decisions in context",
                 "There's no single perfect mix. Every choice changes what a listener notices. First you'll untangle a crowded low end. Then you'll find a problem part by soloing and make two mixes for two different priorities."),
        K.teach("Masking",
                "A long, loud bass sits on top of the kick and hides it. Turn the bass down, or make it shorter, and the kick punches through again.",
                demo: S.bassLoop),
        K.mix("Separate the bass and chords", "Both are too loud and fighting. Find the balance.",
              [.drum(.kick), .drum(.hat), .bass, .chords], start: [K.u, K.u, 1, 1], target: [K.u, K.u, 0.6, 0.55], loop: S.song),
        K.game(trafficName, trafficLine, .traffic([
            TrafficRound(title: "Bass versus kick", body: "The bass is booming over the kick. Ease it back into the pocket.",
                         mode: .level(lane: 1, from: 1)),
            TrafficRound(title: "Find the culprit", body: "Something is too loud. Solo the lanes, find it, and fix only that one.",
                         mode: .culprit(lane: 0)),
            TrafficRound(title: "Two priorities", body: "Make a melody-forward mix, then a drum-forward one.", mode: .priorities),
        ])),
    ]

    static let f44Gold: [LessonStep] = [
        L.gold("Deliver a tiny mix",
               "Take control of a short track and decide what leads. Pick a feature, make two honest mixes from the same parts, then choose between them without looking at the faders."),
        K.teach("A mix has a point of view",
                "Two mixes can both be good and still feature different parts. One sings, one drives. You choose.",
                demo: S.song),
        K.mix("Your first balance", "Every fader starts at the bottom. Build the balance from the kick up.",
              [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords], start: [0.1, 0.1, 0.1, 0.1, 0.1], loop: S.song),
        K.game(trafficName, "Your mix, your call.", .traffic([
            TrafficRound(title: "Choose your focus", body: "Feature the melody or the drums. Tap one to hear a quick sketch.", mode: .focus),
            TrafficRound(title: "Mix with restraint", body: "Make mix A around your feature, then an alternate mix B that features something else.",
                         mode: .alternate),
            TrafficRound(title: "Blind A/B", body: "The faders are hidden. Listen to both mixes and keep the one you like. No score for taste.",
                         mode: .blind),
        ])),
    ]

    // MARK: - F4.5 → Sound Casting

    static let castingName = "Sound Casting"
    static let castingLine = "You're the casting director. Every sound auditions."

    static let f45 = K.lesson("f4.5", "Create a Palette", "Sounds that belong together", "crown.fill", .soundDesign, 20, [
        K.opening("Cast a band",
                  "Choosing instruments is like casting a band: every sound needs a role. First you'll swap sounds while the notes stay locked. Then you'll audition players, cast a lineup, and hear what happens when one doesn't fit."),
        K.teach("Same song, new band",
                "The bassline, chords and melody never change. Swap the sounds and the whole track gets a new personality. That set of sounds is your palette.",
                demo: S.song),
        K.lab("Swap the bass", "Same bassline. Turn the wave and cutoff from a round sub into a buzzy synth bass.",
              [.bassWave, .bassCutoff], start: [0, 0.3], loop: S.bassLoop),
        K.game(castingName, castingLine, .casting([
            CastRound(title: "Listen to the auditions", body: "Three bass players, one bassline. Tap each card to hear them.", mode: .audition(.bass)),
            CastRound(title: "Cast the lineup", body: "Pick a sound for each role. The whole band plays every choice straight away.", mode: .cast),
            CastRound(title: "Hear a bad fit", body: "Flip between a busy, bright extra part and the simple band. Which lets the melody through?",
                      mode: .badFit),
        ])),
    ])

    static let f45Silver: [LessonStep] = [
        L.silver("Curate with constraints",
                 "More instruments don't automatically make better music. First you'll fix a sound that doesn't belong. Then you'll thin out a crowded band, build two different lineups and match a reference."),
        K.teach("Less can be more",
                "Two parts in the same space hide each other. Take one away and the other gets clearer.",
                demo: S.song),
        K.lab("Fix the bass", "It's screaming over a soft loop. Make it rounder and darker so it fits.", [.bassWave, .bassCutoff],
              start: [1, 0.9], target: [0.1, 0.3], loop: S.bassLoop),
        K.game(castingName, castingLine, .casting([
            CastRound(title: "The overcrowded band", body: "Five parts for four roles. Mute the one that's crowding the melody.", mode: .overcrowd),
            CastRound(title: "Same song, different lineup", body: "Cast lineup A, then change at least two roles for lineup B.", mode: .lineups),
            CastRound(title: "Match the reference", body: "Plucky chords, a round bass and an airy bell on top. Cast the band that matches.",
                      mode: .matchRef([0, 1, 0, 1])),
        ])),
    ]

    static let f45Gold: [LessonStep] = [
        L.gold("Cast your first band",
               "Build the sound of a track from scratch. Choose a direction, cast your band, make one swap for a version B, and run a showcase. Your palette gets saved for your mini-track."),
        K.teach("Intention beats rules",
                "A palette works when the sounds suit what you're going for. Warm, edgy or minimal can all be right.",
                demo: S.song),
        K.lab("Your chord sound", "Plucky keys, a soft pad or anything between.", [.chordAttack, .chordDecay, .chordCutoff],
              start: [0, 0.5, 0.6], loop: S.stabs),
        K.game(castingName, "Your band.", .casting([
            CastRound(title: "Choose a direction", body: "Warm, edgy or minimal. Tap each one to hear a starting lineup.", mode: .direction),
            CastRound(title: "Curate the ensemble", body: "Make the band yours, then swap exactly one role for version B.", mode: .curate),
            CastRound(title: "Run the showcase", body: "Four bars, one part at a time: drums, bass, chords, lead. Then save your palette.",
                      mode: .showcase),
        ])),
    ]

    static let levels: [String: LevelPair] = [
        "f4.1": (silver: f41Silver, gold: f41Gold),
        "f4.2": (silver: f42Silver, gold: f42Gold),
        "f4.3": (silver: f43Silver, gold: f43Gold),
        "f4.4": (silver: f44Silver, gold: f44Gold),
        "f4.5": (silver: f45Silver, gold: f45Gold),
    ]
}
