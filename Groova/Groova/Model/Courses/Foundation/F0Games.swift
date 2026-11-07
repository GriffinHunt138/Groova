//
//  F0Games.swift
//  Groova
//
//  F0, Make Sound Immediately, in the Teach → Studio → Game flow. Every tier opens with Woofer,
//  teaches one idea by ear, practises it in a real editor, then plays the lesson's game:
//
//  F0.1 Tap the Pulse      → Blackout              F0.2 Build a Beat  → Drum Duel
//  F0.3 Change the Feeling → Soundtrack Control Room  F0.4 My First Loop → Loop Reactor
//

import Foundation

nonisolated enum F0Games {
    typealias F = FKit

    static let lessons: [Lesson] = [f01, f02, f03, f04]

    // MARK: Material

    static let quarterHats = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])
    static let pad = Pattern(chords: [K.ch(0, F.c, 15)])
    static let melody = K.tune([(0, 64, 2), (2, 67, 2), (4, 69, 4), (8, 67, 2), (10, 64, 2), (12, 62, 4)])
    static let fullBand: Pattern = K.melody(melody, over: F.full)

    // MARK: - F0.1 Tap the Pulse → Blackout

    static let blackoutName = "Blackout"
    static let blackoutLine = "Keep the ring alive after the lights go out."

    static let f01 = K.lesson("f0.1", "Tap the Pulse", "Feel the heartbeat of a track", "hand.tap.fill", .rhythm, 15, [
        K.opening("Every track has a pulse",
                  "You can feel it even when nothing is flashing. First you'll see four kicks lined up in a real drum sequencer. Then you'll tap with a glowing ring, and keep going when its light goes out."),
        K.teach("Four even kicks",
                "Press play and watch the playhead pass beats 1, 2, 3 and 4. Nod along once. That steady thump is the pulse.",
                demo: F.pulse),
        K.drumRule("Put the pulse in the sequencer",
                   "This is a real drum roll: one bar, 16 steps. Put a kick on steps 1, 5, 9 and 13, then press play and watch the playhead cross each one.",
                   tracks: [.kick, .hat], edit: [.kick], target: F.pulse),
        K.game(blackoutName, blackoutLine, .blackout([
            PulseRound(title: "Wake the ring", body: "Eight deep, even pulses. Tap the ring with each one. Every tap on time lights a piece of the ring.",
                       loop: F.pulse, beats: 8, guideBeats: 8, tolerance: 0.28, threshold: 0.6),
            PulseRound(title: "Three-beat blackout", body: "The ring guides you for five beats, then goes dark for three. Keep tapping.",
                       loop: quarterHats, beats: 8, guideBeats: 5, tolerance: 0.26),
            PulseRound(title: "Make it to dawn", body: "Only the first four beats are lit. Keep the whole phrase alive by feel.",
                       loop: quarterHats, beats: 8, guideBeats: 4),
        ])),
    ])

    static let f01Silver: [LessonStep] = [
        L.silver("Hold time under distraction",
                 "The beat won't always announce itself, and the lights will try to throw you. First follow the same kicks under a busier beat in the drum roll. Then keep the ring alive through decoys, a dropout and a groove you've never heard."),
        K.teach("The pulse doesn't move",
                "This beat has hats between the kicks. The extra hits change the texture, but the four beats stay exactly as far apart.",
                demo: Pattern(kick: F.quarters, hat: F.eighths)),
        K.drumRule("Same kicks, busier beat",
                   "The hats are already ticking between the beats. Add the four kicks on 1, 5, 9 and 13 and hear that the pulse hasn't changed.",
                   tracks: [.kick, .hat], edit: [.kick], start: Pattern(hat: F.offbeats),
                   target: Pattern(kick: F.quarters, hat: F.offbeats)),
        K.game(blackoutName, blackoutLine, .blackout([
            PulseRound(title: "False lights", body: "Gold flashes land between the beats. Follow the sound, not the flashes.",
                       loop: F.beat, beats: 8, guideBeats: 8, decoys: true),
            PulseRound(title: "Beat dropout", body: "The drums cut out for a whole bar and only a pad is left. Tap straight through the silence.",
                       loop: F.beat, beats: 8, guideBeats: 4, dropBars: [2], pad: pad),
            PulseRound(title: "Hidden tempo", body: "A new groove, no lights at all. Listen for a bar, find the pulse, then hold it for eight beats.",
                       loop: F.groove, bpm: 92, beats: 8, guideBeats: 0, hiddenStart: true, tolerance: 0.26),
        ])),
    ]

    static let f01Gold: [LessonStep] = [
        L.gold("Perform a silent pulse",
               "Now you're the timekeeper. First program the groove you'll lead. Then pick your pace and play the kick yourself, with no guide, while the band plays along."),
        K.teach("Steady beats perfect",
                "A pulse that drifts pulls a band apart. One that stays steady holds it together, even if it isn't machine-perfect. Listen to this one hold.",
                demo: F.beat),
        K.drumMake("Program the groove you'll lead",
                   "Write one bar with a kick on every beat, plus any snares and hats you like. In the game, your taps take over that kick.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], goal: .atLeast(.kick, 4)),
        K.game(blackoutName, "You are the kick drum now.", .blackout([
            PulseRound(title: "Pick your pace", body: "Choose slow, medium or fast. The ring guides four beats while you play the kick.",
                       loop: F.beat, beats: 4, guideBeats: 4, tapSound: .kick, mute: [.kick], paces: [80, 100, 120]),
            PulseRound(title: "Lead the band", body: "No guide now. Your eight taps are the kick while the snare and hats keep playing.",
                       loop: F.beat, beats: 8, guideBeats: 0, tapSound: .kick, mute: [.kick], paces: [80, 100, 120]),
            PulseRound(title: "Twelve in the dark", body: "Longer, in the dark, over a busier groove. Keep the band together.",
                       loop: F.groove, beats: 12, guideBeats: 0, tapSound: .kick, mute: [.kick], tolerance: 0.24, threshold: 0.6),
        ])),
    ]

    // MARK: - F0.2 Build a Beat → Drum Duel

    static let duelName = "Drum Duel"
    static let duelLine = "Three giant pads. I call, you answer."
    static let rim = Pattern(perc: [0, 4, 8, 12])

    static let f02 = K.lesson("f0.2", "Build a Beat", "Kick, snare and hats", "square.grid.3x3.fill", .rhythm, 15, [
        K.opening("A beat is a conversation",
                  "Kick, snare and hi-hat each have their own job. First you'll meet them in their own drum-roll lanes. Then you'll answer my drum calls on three giant pads."),
        K.teach("Three voices",
                "Kick is the low thump. Snare is the crack. Hi-hat is the bright tick. Tap each pad, then press play and hear them talk.",
                pads: [.kick, .clap, .hat], demo: F.beat),
        K.drumRule("Build the backbeat",
                   "The hats are already ticking. Put kicks on steps 1 and 9 and snares on 5 and 13, then play it.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap], start: Pattern(hat: F.eighths), target: F.beat),
        K.game(duelName, duelLine, .drumDuel([
            DuelRound(title: "Kick and snare", body: "Watch the pads light up while I play. When it says Your turn, play the same thing back.",
                      mode: .echo, call: [Pattern(kick: [0, 8], clap: [4, 12])], cues: true, bpm: 80),
            DuelRound(title: "Add the hats", body: "Same kick and snare, now with two hi-hat ticks in between. Listen, then answer.",
                      mode: .echo, call: [Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 10])], cues: true, bpm: 80),
            DuelRound(title: "Take your turn", body: "Two bars with all three drums. Watch the call, then answer. The pads glow just before each hit.",
                      mode: .echo, call: [Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 10]),
                                          Pattern(kick: [0, 6, 8], clap: [4, 12], hat: [2, 10])], cues: true, bpm: 85),
        ])),
    ])

    static let f02Silver: [LessonStep] = [
        L.silver("Listen, remember, respond",
                 "You'll need your ears and your memory, not just glowing pads. First rebuild a groove in the drum roll by ear. Then answer calls with the names hidden and take over a missing part."),
        K.teach("Busier hats, same backbeat",
                "Same kick and snare. When the hats double up to eighth notes, the beat feels faster, but the tempo hasn't moved.",
                pads: [.kick, .clap, .hat], demo: F.beat),
        K.drumCopy("Finish the transcription",
                   "Kicks on 1 and 9 are already in. Play the reference and add the snares and hats you hear.",
                   tracks: [.kick, .clap, .hat], edit: [.clap, .hat], start: Pattern(kick: [0, 8]), target: F.beat),
        K.game(duelName, duelLine, .drumDuel([
            DuelRound(title: "No-name preview", body: "The pad names hide while I play. Go by sound, then answer.",
                      mode: .echo, call: [Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6])], cues: false, hideLabels: true, bpm: 85),
            DuelRound(title: "The missing voice", body: "Kick and snare are playing. You're the hi-hat: steady ticks between the beats.",
                      mode: .role(.hat), call: [Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 6, 10, 14])], cues: false,
                      repeats: 2, bpm: 85),
            DuelRound(title: "One-bar duel", body: "I play a bar, you answer, twice in a row. Timing and the right drum are scored separately.",
                      mode: .echo, call: [Pattern(kick: [0, 6, 8], clap: [4, 12], hat: [2, 10])], cues: false, repeats: 2, bpm: 90),
        ])),
    ]

    static let f02Gold: [LessonStep] = [
        L.gold("Make your own call",
               "You start the conversation now. First write a one-bar call in the drum roll. Then record your own call on the pads, answer it, and hear the two as one groove."),
        K.teach("Call and answer",
                "Bar one says something. Bar two repeats most of it and changes a hit or two. That small change is what makes a beat sound like it's talking.",
                demo: F.groove),
        K.drumMake("Write a call",
                   "One bar using all three drums: at least one kick, one snare and one hat. Play it until it feels like yours.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], goal: .atLeast(.clap, 1)),
        K.game(duelName, "Now you make the call.", .drumDuel([
            DuelRound(title: "Invent a signature", body: "After the count-in, play one bar on the pads using all three drums. It loops back to you.",
                      mode: .invent, backing: rim, bpm: 90),
            DuelRound(title: "Answer yourself", body: "Your call plays first. Then answer it: keep at least one hit the same and change at least one.",
                      mode: .answer, backing: rim, bpm: 90),
            DuelRound(title: "Hear the duet", body: "Your call and answer, back to back over a bassline.",
                      mode: .duet, backing: Pattern(bass: F.bassline), bpm: 90),
        ])),
    ]

    // MARK: - F0.3 Change the Feeling → Soundtrack Control Room

    static let roomName = "Control Room"
    static let roomLine = "Score a silent film with three big controls."

    static let filmScore = ControlRoomScore(
        melody: K.tune([(0, 64, 4), (4, 67, 4), (8, 69, 4), (12, 67, 4)]),
        harmony: [Pattern(bass: [NoteEvent(0, 36, 14)], chords: [K.ch(0, F.c, 15)]),
                  Pattern(bass: [NoteEvent(0, 33, 14)], chords: [K.ch(0, F.am, 15)])],
        movement: [Pattern(kick: [0, 8], hat: [0, 8]),
                   Pattern(kick: [0, 6, 8, 10], clap: [4, 12], hat: F.eighths)],
        color: [0.35, 0.9],
        bpm: 80)

    /// The film's melody over one combination of the levers, for Teach and Studio.
    static func cue(_ harmony: Int, _ movement: Int) -> Pattern {
        K.melody(filmScore.melody, over: filmScore.movement[movement].merged(with: filmScore.harmony[harmony]))
    }

    static let f03 = K.lesson("f0.3", "Change the Feeling", "Harmony, rhythm and sound set the mood", "theatermasks.fill", .theory, 15, [
        K.opening("Same scene, different feeling",
                  "Change the music and the same scene feels completely different. First you'll hear harmony, drums and sound as separate studio tracks. Then you'll score a short film with three big controls."),
        K.quiz("One change at a time", "The melody stays the same in every pair. What changed?", [
            K.hear([cue(0, 0), cue(1, 0)], ["The chords", "The drums"], 0, "The chords went from major to minor. Darker, same tune.", bars: 2),
            K.hear([cue(0, 0), cue(0, 1)], ["The chords", "The drums"], 1, "The drums got busier. More energy, same tune.", bars: 2),
        ]),
        K.lane("Swap the chord clip",
               "The melody is locked on top. Put C (major) in the first half and Am (minor) in the second, then play it and hear the mood turn.",
               .rule, palette: [F.c, F.am], backing: K.melody(filmScore.melody, over: filmScore.movement[0]),
               target: [0: 0, 8: 1], length: 7),
        K.game(roomName, roomLine, .controlRoom(filmScore, [
            ControlRound(title: "Same scene, different score", body: "Someone walks to a door. Flip between two scores while the film rolls. The melody never changes.",
                         mode: .swap(a: [0, 0, 0], b: [1, 1, 0])),
            ControlRound(title: "Turn the three dials", body: "Harmony, movement and color. Turn each one while the scene plays and watch the scene react.",
                         mode: .explore),
            ControlRound(title: "Spot the edit", body: "Each pair changes only one control. Play it, then tap the one that moved.",
                         mode: .spot([([0, 0, 0], 0), ([1, 0, 1], 1), ([0, 1, 0], 2)])),
        ])),
    ])

    static let f03Silver: [LessonStep] = [
        L.silver("Edit to a brief",
                 "You're in the editor's chair, and every scene has a musical problem. First match a reference by swapping chord clips. Then fix a score and land a change right on cue."),
        K.quiz("Hear the one edit", "Editing one thing at a time makes it easy to hear what it does.", [
            K.hear([cue(1, 0), cue(1, 1)], ["The chords", "The drums"], 1, "Only the drums moved. Same dark chords.", bars: 2),
        ]),
        K.lane("Match the reference cue",
               "Play the reference, then place the two chord clips you hear under the melody.",
               .recreate, palette: [F.c, F.am, F.f, F.g], backing: K.melody(filmScore.melody, over: filmScore.movement[0]),
               target: [0: 1, 8: 2], length: 7),
        K.game(roomName, roomLine, .controlRoom(filmScore, [
            ControlRound(title: "One control only", body: "This calm scene needs to feel urgent. Only Movement is unlocked.",
                         mode: .brief(target: [0, 1, 0], start: [0, 0, 0], unlocked: [1])),
            ControlRound(title: "Two edits to undo", body: "Someone changed this score in two ways. Hear the reference and put Harmony and Color back.",
                         mode: .brief(target: [1, 0, 1], start: [0, 0, 0], unlocked: [0, 2])),
            ControlRound(title: "Cue the door", body: "Turn Harmony the moment the door opens. The white dot on the timeline marks the cut.",
                         mode: .cue(start: [0, 0, 0], lever: 0)),
        ])),
    ]

    static let f03Gold: [LessonStep] = [
        L.gold("Direct a musical turn",
               "You decide how this scene feels. First set a change at bar 3 on the arrangement timeline. Then score the film live and watch your cut back."),
        K.teach("Change on the cut",
                "Film composers line a musical change up with a moment on screen. Here the cue is dark and busy, ready to turn at bar 3.",
                demo: cue(1, 1)),
        K.arrange("Put the turn at bar 3",
                  "Each column is a bar. Bring in the snare and the chords at bar 3, so the music turns right there.",
                  .rule, sections: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"], lanes: F.lanes, loop: F.full,
                  target: K.grid("xxxx", "--xx", "xxxx", "xxxx", "--xx")),
        K.game(roomName, "Your scene, your score.", .controlRoom(filmScore, [
            ControlRound(title: "Choose your arc", body: "Two directions for the scene: easy, or uneasy. Flip between them and pick the one you'll build from.",
                         mode: .swap(a: [0, 0, 1], b: [1, 1, 0])),
            ControlRound(title: "Perform the score", body: "The film rolls once. Use at least two controls to make the music turn. Then watch your cut.",
                         mode: .perform(start: [0, 0, 0])),
            ControlRound(title: "Hit the cut the other way", body: "Start dark and busy. Calm the movement right as the door opens.",
                         mode: .cue(start: [1, 1, 1], lever: 1)),
        ])),
    ]

    // MARK: - F0.4 My First Loop → Loop Reactor

    static let reactorName = "Loop Reactor"
    static let reactorLine = "Four spinning rings, one clock."

    static let reactorLayers: [ReactorLayer] = [
        ReactorLayer(name: "Drums", symbol: "square.grid.3x3.fill", variants: [F.beat]),
        ReactorLayer(name: "Bass", symbol: "waveform.path", variants: [
            Pattern(bass: F.bassline),
            Pattern(bass: [NoteEvent(0, 36, 6), NoteEvent(8, 45, 6)]),
        ]),
        ReactorLayer(name: "Chords", symbol: "pianokeys", variants: [
            K.halves(F.c, F.am),
            Pattern(chords: [K.ch(0, F.c, 2), K.ch(4, F.c, 2), K.ch(8, F.am, 2), K.ch(12, F.am, 2)]),
        ]),
        ReactorLayer(name: "Melody", symbol: "music.note", variants: [
            K.melody(melody),
            K.melody(K.tune([(0, 72, 2), (4, 69, 2), (8, 67, 4), (12, 64, 4)])),
        ]),
    ]

    static let f04 = K.lesson("f0.4", "My First Loop", "Four layers, one loop", "crown.fill", .arrangement, 30, [
        K.opening("A loop is parts repeating together",
                  "Not one giant sound, but layers that loop in sync. First you'll launch four clips in a real arrangement grid. Then you'll switch on spinning rings for drums, bass, chords and melody."),
        K.teach("Four parts, one clock",
                "Drums, bass, chords and melody each loop on their own, all locked to the same bar. Here they are together.",
                demo: fullBand),
        K.arrange("Launch the clips",
                  "Each row is a track and each column is a bar. Bring in one more part each bar: drums, then bass, then chords and melody.",
                  .rule, sections: ["Bar 1", "Bar 2", "Bar 3"], lanes: F.lanes, loop: fullBand,
                  target: K.grid("xxx", "xxx", "xxx", "-xx", "--x")),
        K.game(reactorName, reactorLine, .reactor(reactorLayers, [
            ReactorRound(title: "One ring at a time", body: "Start the reactor, then tap the rings to bring in drums, bass, chords and melody. Each one joins on the next bar.",
                         mode: .build),
            ReactorRound(title: "Fit the pieces", body: "Bass, chords and melody each have two versions. Try them, keep the ones you like, and get all four spinning.",
                         mode: .choose),
            ReactorRound(title: "Build it bar by bar", body: "One ring in bar 1, two in bar 2, three in bar 3, all four in bar 4. Queue each ring a bar early.",
                         mode: .energy([1, 2, 3, 4])),
        ])),
    ])

    static let f04Silver: [LessonStep] = [
        L.silver("Play the layers",
                 "A great loop needs every layer to land on time. First practise launching clips on the bar. Then find a missing ring, shape the energy and rescue a ring that slipped."),
        K.teach("On the bar, or off it",
                "Here the bass started one beat late. Every note is right, but the loop trips over itself.",
                demo: F.beat.merged(with: Pattern(bass: F.bassline).shifted(by: 4))),
        K.arrange("Copy the launches",
                  "Play the reference and switch on each part in the bar it comes in.",
                  .recreate, sections: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"], lanes: F.lanes, loop: fullBand,
                  target: K.grid("xxxx", "-xxx", "xxxx", "--xx", "---x")),
        K.game(reactorName, reactorLine, .reactor(reactorLayers, [
            ReactorRound(title: "Find the missing ring", body: "Three rings are spinning. Listen for the part that's missing and bring it back.",
                         mode: .missing(1)),
            ReactorRound(title: "Energy challenge", body: "One ring for bar 1, two for bar 2, all four for bar 3. Launch on the downbeats.",
                         mode: .energy([1, 2, 4])),
            ReactorRound(title: "Recover the trainwreck", body: "The bass ring is a beat late. Hit SYNC and it snaps back on the next bar.",
                         mode: .sync(1)),
        ])),
    ]

    static let f04Gold: [LessonStep] = [
        L.gold("Make a 16-second performance",
               "You've got the controls to perform a tiny track from start to finish. First plan four bars in the arrangement. Then perform them live on the reactor and keep your take."),
        K.teach("A loop can be a journey",
                "Four bars can have an intro and a big ending just by changing which parts play.",
                demo: fullBand),
        K.arrange("Plan your four bars",
                  "Switch parts on and off across four bars. No two bars next to each other can be the same.",
                  .create(.variedSections), sections: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"], lanes: F.lanes, loop: fullBand),
        K.game(reactorName, "Perform it, then keep your take.", .reactor(reactorLayers, [
            ReactorRound(title: "Choose your four sounds", body: "Pick a version of each ring and get the full band spinning.",
                         mode: .choose),
            ReactorRound(title: "Perform one journey", body: "Four bars, recorded live. Bring rings in, have one bar with all four, then take one out near the end.",
                         mode: .perform),
        ])),
    ]

    static let levels: [String: LevelPair] = [
        "f0.1": (silver: f01Silver, gold: f01Gold),
        "f0.2": (silver: f02Silver, gold: f02Gold),
        "f0.3": (silver: f03Silver, gold: f03Gold),
        "f0.4": (silver: f04Silver, gold: f04Gold),
    ]
}
