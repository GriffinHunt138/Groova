//
//  RnBAcademy.swift
//  Groova
//
//  R&B, Part 2. Five units and a final song project, in C major and A minor at 84 BPM with a
//  gentle swing.
//
//  RB1 Pocket & Space   RB2 Richer Chord Colors   RB3 Bass & Melodic Phrasing
//  RB4 Tone & Space     RB5 Intimacy to Lift      RB6 Song Project Finale
//

import Foundation

nonisolated enum RnBAcademy {
    static let units: [Unit] = [rb1, rb2, rb3, rb4, rb5, rb6]

    // MARK: Material

    static let rows = [48, 45, 43, 41, 40, 36]                 // C3 A2 G2 F2 E2 C2
    static let lead = [76, 74, 72, 69, 67, 64, 62, 60]         // C major pentatonic, E5 down to C4
    static let eighths = [0, 2, 4, 6, 8, 10, 12, 14]
    static let sixteenths = Array(0..<16)

    static let pocket = Pattern(kick: [0, 9], clap: [4, 12], hat: eighths, perc: [7])
    static let busy = Pattern(kick: [0, 3, 6, 9, 11, 14], clap: [4, 10, 12], hat: sixteenths, openHat: [2, 6], perc: [1, 7, 13, 15])
    static let spacious = Pattern(kick: [0, 9], clap: [4, 12], hat: [0, 4, 8, 12])
    static let ghosted = Pattern(kick: [0, 9], clap: [4, 12], hat: eighths, perc: [7, 14])
    static let silky = Pattern(kick: [0, 9], clap: [4, 12], hat: sixteenths, perc: [7, 15])

    // Chords: close voicings so they move smoothly.
    static let cmaj7 = ChordShape.cmaj7                                         // G B C E
    static let am7 = ChordShape(name: "Am7", pitches: [55, 57, 60, 64])         // G A C E
    static let fmaj7 = ChordShape(name: "Fmaj7", pitches: [53, 57, 60, 64])     // F A C E
    static let dm7 = ChordShape(name: "Dm7", pitches: [53, 57, 60, 62])         // F A C D
    static let g7 = ChordShape(name: "G7", pitches: [53, 55, 59, 62])           // F G B D
    static let cTri = ChordShape.c, amTri = ChordShape.am, fTri = ChordShape.f, dmTri = ChordShape.dm
    static let cmaj9 = ChordShape.cmaj9, am9 = ChordShape.am9, dm9 = ChordShape.dm9, em9 = ChordShape.em9
    static let fmaj9 = ChordShape(name: "Fmaj9", pitches: [57, 60, 64, 65, 67])
    static let cOverE = ChordShape(name: "C/E", pitches: [52, 55, 60, 64])
    /// Wide, jumpy voicings, for hearing the difference voice leading makes.
    static let amWide = ChordShape(name: "Am7", pitches: [57, 64, 67, 72])
    static let fWide = ChordShape(name: "Fmaj7", pitches: [65, 69, 72, 76])

    static func pad(_ a: ChordShape, _ b: ChordShape) -> Pattern { Pattern(chords: [K.ch(0, a, 7), K.ch(8, b, 7)]) }
    static func held(_ c: ChordShape, root: Int) -> Pattern {
        Pattern(bass: [NoteEvent(0, root, 14)], chords: [K.ch(0, c, 14)])
    }
    static func inPocket(_ p: Pattern) -> Pattern { p.merged(with: pocket) }

    static let bass = [NoteEvent(0, 36, 6), NoteEvent(6, 43, 2), NoteEvent(9, 45, 5), NoteEvent(14, 43, 2)]
    static let groove = pocket.merged(with: Pattern(bass: bass, chords: [K.ch(0, cmaj9, 7), K.ch(8, am9, 7)]))
    static let topline = K.tune([(2, 67, 2), (4, 69, 3), (8, 72, 2), (11, 69, 1), (12, 67, 4)])
    static let song = K.melody(topline, over: groove)

    static func progression() -> [OrderTile] {
        [K.tile("Cmaj7", inPocket(held(cmaj7, root: 36)), "Home"), K.tile("Am7", inPocket(held(am7, root: 45))),
         K.tile("Fmaj7", inPocket(held(fmaj7, root: 41))), K.tile("G7", inPocket(held(g7, root: 43)), "Tension")]
    }

    // Sections
    static let verse = pocket.merged(with: Pattern(bass: bass, chords: [K.ch(0, cmaj7, 7), K.ch(8, am7, 7)]))
    static let lift = silky.merged(with: Pattern(bass: bass, chords: [K.ch(0, fmaj9, 7), K.ch(8, dm9, 7)]))
    static let chorus = K.melody(topline, over: silky.merged(with: Pattern(bass: bass, chords: [K.ch(0, cmaj9, 7), K.ch(8, am9, 7)])))
    static let intro = Pattern(chords: [K.ch(0, cmaj9, 7), K.ch(8, am9, 7)])
    static let outro = Pattern(chords: [K.ch(0, cmaj9, 14)])
    static let pickup = Pattern(kick: [0, 9], clap: [4], hat: [0, 2, 4, 6, 8, 10], perc: [13, 14, 15],
                                bass: bass, chords: [K.ch(0, cmaj7, 7), K.ch(8, am7, 7)])
    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]

    static func sections() -> [OrderTile] {
        [K.tile("Intro", intro, "Keys alone"), K.tile("Verse", verse, "Intimate"), K.tile("Lift", lift, "Rising"),
         K.tile("Chorus", chorus, "Full"), K.tile("Pickup", pickup, "Soft fill"), K.tile("Outro", outro, "One chord")]
    }

    static let rhodes: [SoundParam: Double] = [.chordAttack: 0.02, .chordDecay: 0.7, .chordRelease: 0.45, .chordCutoff: 0.6]
    static let padSound: [SoundParam: Double] = [.chordAttack: 0.7, .chordDecay: 1, .chordRelease: 0.9, .chordCutoff: 0.4]
    static let pluckSound: [SoundParam: Double] = [.chordAttack: 0, .chordDecay: 0.12, .chordRelease: 0.1, .chordCutoff: 0.55]
    static let keysLoop = inPocket(pad(cmaj9, am9))

    // MARK: - RB1 · Pocket & Space

    static let rb1 = K.unit("rnb.rb1", 1, "Pocket & Space", "Laid-back drums with room to breathe", [rb11, rb12, rb13, rb1b])

    static let rb11 = K.lesson("rnb.rb1.1", "Pocket Police", "Laid back or pushed", "figure.walk", .rhythm, 20, [
        K.intro("Lean back",
                "R&B drums sit behind the beat. The hats swing, the kick waits, and the snare feels like it's arriving a moment late. That lazy lean is called the pocket.",
                [.kick, .clap, .hat], demo: silky),
        K.quiz("Laid back or pushed?", "Same notes, different feel.", [
            K.hear([silky], ["Laid back", "Pushed"], 0, "Heavy swing. Everything leans back.", bars: 2, swing: 0.32),
            K.hear([silky], ["Laid back", "Pushed"], 1, "Dead straight. It drives forward instead.", bars: 2, swing: 0),
        ]),
        K.swingMake("Find the pocket", "Swing the hats until it leans back. Past a quarter of the way.",
                    tracks: [.kick, .clap, .hat, .perc], start: silky, atLeast: 0.25),
        K.tapAlong("Sit in it", "Tap the snares. Don't rush them.", loop: silky, bars: 5, steps: [4, 12], swing: 0.3,
                   label: "Snare", unit: "snares", sound: .clap),
    ])

    static let rb12 = K.lesson("rnb.rb1.2", "Less Is More", "Take hits away", "minus.circle.fill", .rhythm, 20, [
        K.intro("Space is the sound",
                "R&B beats leave room for a voice. A crowded pattern fights the singer. Taking hits away often makes a groove sound more expensive.",
                [], demo: pocket),
        K.fix("Clear it out", "This beat is crowded. Match the reference by removing hits.", tracks: [.kick, .clap, .hat, .openHat, .perc],
              edit: [.kick, .clap, .hat, .openHat, .perc], broken: busy, target: pocket, guide: true),
        K.quiz("Which leaves room for a voice?", "", [
            K.hear([busy, pocket], ["The first", "The second"], 1),
            K.hear([spacious, busy], ["The first", "The second"], 0),
        ]),
    ])

    static let rb13 = K.lesson("rnb.rb1.3", "Space Keeper", "Fill gaps, keep silence", "circle.dashed", .rhythm, 20, [
        K.intro("Fill only some gaps",
                "A ghost rim in the right gap adds motion. Fill every gap and the space disappears. Choose two spots and leave the rest silent.",
                [.perc], demo: ghosted),
        K.drumRule("Two ghost rims", "Steps 8 and 15 only.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: pocket.keeping([.kick, .clap, .hat], bass: false, chords: false),
                   target: ghosted),
        K.tapAlong("Tap the ghosts", "Just the two rims.", loop: ghosted, bars: 5, steps: [7, 14], label: "Rim", unit: "rims", sound: .perc),
    ])

    static let rb1b = K.lesson("rnb.rb1.boss", "Pocket & Space Boss", "Boss: a laid-back groove", "crown.fill", .rhythm, 40, [
        K.intro("Boss: the pocket",
                "Rebuild a laid-back groove with hints, then swing it.", [.kick, .clap, .hat, .perc], demo: silky),
        K.drumCopy("Rebuild it", "Kick on 1 and just after 3, snare on 2 and 4, sixteenth hats, two rims.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc], target: silky),
        K.swingMake("Lay it back", "Swing until the hats lean back, past a quarter.", tracks: [.kick, .clap, .hat, .perc], start: silky, atLeast: 0.25),
    ])

    // MARK: - RB2 · Richer Chord Colors

    static let rb2 = K.unit("rnb.rb2", 2, "Richer Chord Colors", "Sevenths, ninths and smooth voicings", [rb21, rb22, rb23, rb2b])

    static let rb21 = K.lesson("rnb.rb2.1", "Seventh Heaven", "Add the seventh", "sparkles", .theory, 20, [
        K.intro("One more note",
                "Stack one more note on a triad and you get a seventh chord. It's the first step from pop to R&B: warmer, softer, a little bittersweet.",
                [], demo: inPocket(Pattern(chords: [K.ch(0, cTri, 7), K.ch(8, cmaj7, 7)]))),
        K.build("Turn C into Cmaj7", "C E G is there. Add B.", .cmaj7, start: [60, 64]),
        K.build("Turn Am into Am7", "A C E, plus G.", am7, start: [57, 60, 64]),
        K.quiz("Triad or seventh?", "", [
            K.round([cTri], ["Triad", "Seventh"], 0),
            K.round([cmaj7], ["Triad", "Seventh"], 1),
            K.round([dmTri], ["Triad", "Seventh"], 0),
            K.round([dm7], ["Triad", "Seventh"], 1),
        ]),
    ])

    static let rb22 = K.lesson("rnb.rb2.2", "Chord Glow-Up", "Ninths and inversions", "wand.and.stars", .theory, 20, [
        K.intro("Glow-up",
                "Add a ninth on top of a seventh chord and it shimmers. Or keep the same notes and move the bottom one up an octave: that's an inversion, and it changes the colour without changing the chord.",
                [], demo: inPocket(Pattern(chords: [K.ch(0, cmaj7, 7), K.ch(8, cmaj9, 7)]))),
        K.build("Build Cmaj9", "B C D E G. A cluster that glows.", cmaj9, low: 55, high: 69),
        K.build("Build C over E", "C major with E at the bottom: E G C E.", cOverE, low: 50, high: 67, exact: true),
        K.quiz("Plain, seventh or ninth?", "", [
            K.round([cTri], ["Triad", "Seventh", "Ninth"], 0),
            K.round([am9], ["Triad", "Seventh", "Ninth"], 2),
            K.round([fmaj7], ["Triad", "Seventh", "Ninth"], 1),
        ]),
    ])

    static let rb23 = K.lesson("rnb.rb2.3", "Smooth Move", "Voice leading", "point.topleft.down.to.point.bottomright.curvepath.fill", .theory, 20, [
        K.intro("Move as little as possible",
                "When chords change, let each finger move the shortest distance. Notes the two chords share can stay put. It's called voice leading, and it's why R&B chords feel like they melt into each other.",
                [], demo: Pattern(chords: [K.ch(0, cmaj7, 7), K.ch(8, am7, 7)])),
        K.quiz("Smooth or jumpy?", "", [
            K.round([cmaj7, am7], ["Smooth", "Jumpy"], 0, "Only one note moved, B down to A."),
            K.round([cmaj7, amWide], ["Smooth", "Jumpy"], 1, "Every note jumped somewhere new."),
            K.round([am7, fmaj7], ["Smooth", "Jumpy"], 0, "G slid down to F. Everything else stayed."),
            K.round([am7, fWide], ["Smooth", "Jumpy"], 1),
        ]),
        K.build("Cmaj7 to Am7", "From G B C E, move just one note to make Am7: G A C E.", am7, start: [55, 60, 64], low: 52, high: 67, exact: true),
        K.build("Am7 to Fmaj7", "Move G down to F. Keep A, C, E.", fmaj7, start: [57, 60, 64], low: 50, high: 67, exact: true),
    ])

    static let rb2b = K.lesson("rnb.rb2.boss", "Chord Colors Boss", "Boss: four rich chords", "crown.fill", .theory, 40, [
        K.intro("Boss: the progression",
                "Cmaj7, Am7, Fmaj7, G7, voiced so they melt into each other. Put them in order and hear R&B harmony.",
                [], demo: inPocket(held(cmaj7, root: 36))),
        K.order("Order the chords", "Start home on Cmaj7, end on G7 so it pulls back.", .recreate, tiles: progression(), answer: [0, 1, 2, 3]),
        K.build("Build G7 from Dm7", "From F A C D, move A down to G and C down to B.", g7, start: [53, 62], low: 50, high: 67, exact: true),
    ])

    // MARK: - RB3 · Bass & Melodic Phrasing

    static let rb3 = K.unit("rnb.rb3", 3, "Bass & Melodic Phrasing", "Bass that connects, melodies that breathe", [rb31, rb32, rb33, rb3b])

    static let rb31 = K.lesson("rnb.rb3.1", "Bass Trail", "Roots and connectors", "point.3.connected.trianglepath.dotted", .theory, 20, [
        K.intro("A trail between chords",
                "R&B bass plays the root, then walks toward the next chord. Long notes, a few connectors, and lots of warmth.",
                [], demo: groove),
        K.bassRule("Roots under Cmaj9 and Am9", "C, then A.", rows: rows, target: [NoteEvent(0, 36, 7), NoteEvent(8, 45, 7)],
                   backing: inPocket(pad(cmaj9, am9))),
        K.bassRule("Add a connector", "Same roots, plus G right before the A.", rows: rows,
                   target: [NoteEvent(0, 36, 6), NoteEvent(6, 43, 2), NoteEvent(8, 45, 7)], backing: inPocket(pad(cmaj9, am9))),
    ])

    static let rb32 = K.lesson("rnb.rb3.2", "Phrase Painter", "Melodies that breathe", "paintbrush.fill", .theory, 20, [
        K.intro("Leave a breath",
                "Singers need air. R&B melodies are short phrases with gaps, often starting just after the beat. The rests are part of the melody.",
                [], demo: song),
        K.leadRule("Place the phrase", "It starts on step 3, after beat 1, and leaves gaps.", rows: lead, target: topline, backing: groove),
        K.leadMake("Paint your own", "At least four notes, with at least one rest of a beat or more.", rows: lead, backing: groove, notes: 4),
    ])

    static let rb33 = K.lesson("rnb.rb3.3", "Answer Me", "Call and response", "bubble.left.and.bubble.right.fill", .theory, 20, [
        K.intro("Call and response",
                "A phrase asks, another answers. It's from gospel and soul, and it's all over R&B: a vocal and a keyboard trading lines.",
                [], demo: K.melody(K.tune([(0, 67, 2), (2, 69, 2), (4, 72, 4), (8, 69, 2), (10, 67, 2), (12, 64, 4)]), over: groove)),
        K.quiz("Which answer fits?", "The call rises. Which answer brings it home?", [
            K.round(K.phrase([67, 69, 72]) + K.phrase([69, 67, 64]), ["Answers it", "Doesn't"], 0, "It comes back down."),
            K.round(K.phrase([67, 69, 72]) + K.phrase([74, 76, 76]), ["Answers it", "Doesn't"], 1, "It keeps climbing, like a second question."),
        ]),
        K.leadMake("Answer the call", "The call is placed. Answer it in the second half with at least three notes.", rows: lead,
                   backing: groove, notes: 6, start: K.tune([(0, 67, 2), (2, 69, 2), (4, 72, 4)])),
    ])

    static let rb3b = K.lesson("rnb.rb3.boss", "Bass & Melody Boss", "Boss: bass and response", "crown.fill", .theory, 40, [
        K.intro("Boss: bass and melody", "A bass phrase and a melodic response.", [], demo: song),
        K.bassRule("The bass", "Follow the lit notes.", rows: rows, target: bass, backing: inPocket(pad(cmaj9, am9))),
        K.leadCopy("The melody", "Copy it by ear. Notice the gaps.", rows: lead, target: topline, backing: groove),
    ])

    // MARK: - RB4 · Tone & Space

    static let rb4 = K.unit("rnb.rb4", 4, "Tone & Space", "Keys, pads and warm rooms", [rb41, rb42, rb43, rb4b])

    static let rb41 = K.lesson("rnb.rb4.1", "Tone Match", "Keys, pad or pluck", "pianokeys.inverse", .soundDesign, 20, [
        K.intro("Same chords, three tones",
                "R&B lives on electric piano, warm pads and soft plucks. Same notes, very different moods. Learn to hear which is which.",
                [], demo: keysLoop),
        K.quiz("Which sound?", "", [
            K.sound(keysLoop, rhodes, ["Electric piano", "Pad", "Pluck"], 0, "A soft hit that rings and fades."),
            K.sound(keysLoop, padSound, ["Electric piano", "Pad", "Pluck"], 1, "Swells in and hangs."),
            K.sound(keysLoop, pluckSound, ["Electric piano", "Pad", "Pluck"], 2, "Short and quick."),
        ]),
        K.lab("Morph between them", "Attack and length take you from pluck to pad.", [.chordAttack, .chordDecay], start: [0, 0.1], loop: keysLoop),
    ])

    static let rb42 = K.lesson("rnb.rb4.2", "Warmth Workshop", "Soften harsh tones", "flame.fill", .soundDesign, 20, [
        K.intro("Warm it up",
                "Harsh chords have a sharp attack and too much top end. Slow the attack a touch and lower the cutoff, and they turn warm.",
                [], demo: keysLoop),
        K.lab("Soften the chords", "Lower Cutoff, raise Attack a little.", [.chordCutoff, .chordAttack], start: [1, 0], target: [0.45, 0.25],
              loop: keysLoop),
        K.quiz("Harsh or warm?", "", [
            K.sound(keysLoop, [.chordCutoff: 1, .chordAttack: 0], ["Harsh", "Warm"], 0),
            K.sound(keysLoop, [.chordCutoff: 0.4, .chordAttack: 0.25], ["Harsh", "Warm"], 1),
        ]),
    ])

    static let rb43 = K.lesson("rnb.rb4.3", "Room Designer", "Gentle reverb", "house.lodge.fill", .mixing, 20, [
        K.intro("A soft room",
                "R&B reverb is like a warm room, not a cathedral. Enough to feel intimate and real, not so much the voice gets lost.",
                [], demo: song),
        K.space("Set the room", "Find gentle space. The melody should still be clear.", song),
        K.quiz("Intimate or too wet?", "", [
            K.reverb(song, amount: 0.25, ["Intimate", "Too wet"], 0),
            K.reverb(song, amount: 0.95, ["Intimate", "Too wet"], 1),
        ]),
    ])

    static let rb4b = K.lesson("rnb.rb4.boss", "Tone & Space Boss", "Boss: your palette", "crown.fill", .soundDesign, 40, [
        K.intro("Boss: palette",
                "Keys, bass and melody sounds that belong together.", [], demo: song),
        K.lab("Keys", "Match the electric piano.", [.chordAttack, .chordDecay, .chordCutoff], start: [0.6, 0.2, 0.9],
              target: [0.02, 0.7, 0.6], loop: keysLoop),
        K.lab("Bass", "Round and warm.", [.bassWave, .bassCutoff], start: [0.9, 0.9], target: [0.05, 0.3],
              loop: pocket.merged(with: Pattern(bass: bass))),
        K.mix("Balance", "Keys and bass under the drums.", [.drum(.kick), .bass, .chords], start: [K.u, K.u, K.u], loop: song),
    ])

    // MARK: - RB5 · Intimacy to Lift

    static let rb5 = K.unit("rnb.rb5", 5, "Intimacy to Lift", "From close-up verse to open chorus", [rb51, rb52, rb53, rb5b])

    static let rb51 = K.lesson("rnb.rb5.1", "Emotion Map", "Verse, lift, chorus", "heart.text.square.fill", .arrangement, 20, [
        K.intro("Close, then open",
                "An R&B song starts intimate, then lifts into a chorus that opens up. No big drops, just richer chords, busier hats and higher notes.",
                [], demo: chorus),
        K.tapChanges("Tap the shifts", "Verse, lift, chorus.", loops: [verse, lift, chorus], barsEach: 2),
        K.quiz("Which section?", "", [
            K.hear([verse], ["Verse", "Chorus"], 0, bars: 2),
            K.hear([chorus], ["Verse", "Chorus"], 1, bars: 2),
        ]),
    ])

    static let rb52 = K.lesson("rnb.rb5.2", "Lift the Chorus", "Higher voicings, extra layers", "arrow.up.heart.fill", .arrangement, 20, [
        K.intro("Lift it",
                "Swap sevenths for ninths, add sixteenth hats, put the melody up top. The chorus grows without anything getting louder.",
                [], demo: chorus),
        K.lane("Richer chords for the chorus", "Cmaj9 on beat 1, Am9 halfway.", .rule, palette: [cmaj7, am7, cmaj9, am9], backing: silky,
               target: [0: 2, 8: 3], length: 7),
        K.drumRule("Busier hats", "Sixteenth hats: every step.", tracks: [.kick, .clap, .hat], edit: [.hat],
                   start: Pattern(kick: [0, 9], clap: [4, 12], hat: eighths), target: Pattern(kick: [0, 9], clap: [4, 12], hat: sixteenths)),
    ])

    static let rb53 = K.lesson("rnb.rb5.3", "Subtle Shift", "Gentle transitions", "wind", .arrangement, 20, [
        K.intro("No big drops",
                "R&B transitions are soft: a rim pickup, a one-beat rest, a chord that hangs. They nudge you into the next section.",
                [], demo: pickup),
        K.order("Place the pickup", "Verse, verse, verse, pickup, then the chorus.", .rule,
                tiles: [K.tile("Verse", verse), K.tile("Pickup", pickup), K.tile("Chorus", chorus)], answer: [0, 0, 0, 1, 2]),
        K.quiz("Soft or hard?", "", [
            K.hear([verse, pickup, chorus], ["Soft nudge", "Hard drop"], 0),
            K.hear([verse, Pattern(), chorus], ["Soft nudge", "Hard drop"], 1, "A full bar of silence. That's EDM, not R&B."),
        ]),
    ])

    static let rb5b = K.lesson("rnb.rb5.boss", "Intimacy to Lift Boss", "Boss: the arc", "crown.fill", .arrangement, 40, [
        K.intro("Boss: the arc", "Intro, verse, lift, chorus, outro.", [], demo: chorus),
        K.order("Map it", "Intro, verse, pickup, lift, chorus, outro.", .rule, tiles: sections(), answer: [0, 1, 4, 2, 3, 5], barsEach: 2),
        K.arrange("Shape the layers", "Five sections, no two neighbours the same.", .create(.variedSections),
                  sections: ["Intro", "Verse", "Lift", "Chorus", "Outro"], lanes: lanes, loop: chorus),
    ])

    // MARK: - RB6 · Song Project Finale

    static let rb6 = K.unit("rnb.rb6", 6, "Song Project Finale", "Your first R&B track", [rb6l])

    static let rb6l = K.lesson("rnb.rb6", "Song Project Finale", "Your R&B track", "flag.checkered", .arrangement, 60, [
        K.intro("Your R&B track",
                "Laid-back drums, rich chords, a bass trail, a breathing melody and a gentle lift.", [], demo: chorus),
        K.drumRule("The pocket", "Kick on 1 and just after 3, snare on 2 and 4, sixteenth hats, two rims.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc], target: silky),
        K.order("The chords", "Cmaj7, Am7, Fmaj7, G7.", .rule, tiles: progression(), answer: [0, 1, 2, 3]),
        K.bassRule("The bass", "Follow the notes.", rows: rows, target: bass, backing: inPocket(pad(cmaj9, am9))),
        K.order("The map", "Intro, verse, pickup, chorus, outro.", .rule, tiles: sections(), answer: [0, 1, 4, 3, 5], barsEach: 2),
    ])

    // MARK: - Silver and Gold

    static let levels: [String: LevelPair] = [
        "rnb.rb1.1": (silver: [
            L.silver("Hear the lean", "Compare pockets with the reference always on hand."),
            K.quiz("Laid back, straight or pushed?", "", [
                K.hear([silky], ["Laid back", "Straight"], 0, bars: 2, swing: 0.36),
                K.hear([silky], ["Laid back", "Straight"], 1, bars: 2, swing: 0.02),
                K.hear([Pattern(kick: [0, 3, 8, 11], clap: [4, 12], hat: sixteenths)], ["Laid back", "Pushed"], 1,
                       "Kicks that jump ahead of the beat push it forward.", bars: 2, swing: 0),
            ]),
            K.tapAlong("Snares, no lights", "Heavy swing.", loop: silky, bars: 5, steps: [4, 12], guideBars: 0, swing: 0.34,
                       label: "Snare", unit: "snares", sound: .clap),
        ], gold: [
            L.gold("Set the lean yourself", "Write a two-bar groove, then choose how far back it sits."),
            L.make("Your groove", "Kick on 1, snare on 2 and 4, everything else yours. At least two rims.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .hat, .perc], start: Pattern(kick: [0], clap: [4, 12]),
                   goal: .atLeast(.perc, 2)),
            K.swingMake("Lean it back", "Find the swing that feels right for your groove. At least a third.",
                        tracks: [.kick, .clap, .hat, .perc], start: silky, atLeast: 0.33),
        ]),
        "rnb.rb1.2": (silver: [
            L.silver("Rebuild the space", "Rebuild a sparse groove from the reference."),
            L.copy("Copy the spacious groove", "Only a few hits. Count the gaps.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], target: Pattern(kick: [0, 10], clap: [4, 12], hat: [0, 6, 8, 14], perc: [11])),
            K.fix("Remove three hits", "Three hits are crowding this groove.", tracks: [.kick, .clap, .hat, .perc],
                  edit: [.kick, .clap, .hat, .perc], broken: Pattern(kick: [0, 3, 9, 13], clap: [4, 12], hat: eighths, perc: [7, 10]),
                  target: pocket, guide: false),
        ], gold: [
            L.gold("Elegant", "Rests on purpose, and two accents that matter."),
            L.make("Your elegant groove", "At most a handful of hits. Two rims as accents.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], goal: .atLeast(.perc, 2)),
            K.quiz("Too much or just right?", "", [
                K.hear([busy], ["Too much", "Just right"], 0, bars: 2),
                K.hear([ghosted], ["Too much", "Just right"], 1, bars: 2),
            ]),
        ]),
        "rnb.rb1.3": (silver: [
            L.silver("Ghosts by ear", "Find the ghost and accent hits."),
            L.copy("Copy it", "Two rims and an open hat.", tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.openHat, .perc],
                   start: pocket.keeping([.kick, .clap, .hat], bass: false, chords: false),
                   target: Pattern(kick: [0, 9], clap: [4, 12], hat: eighths, openHat: [14], perc: [3, 11])),
            K.tapAlong("Tap the rims", "No lights.", loop: Pattern(kick: [0, 9], clap: [4, 12], hat: eighths, perc: [3, 11]), bars: 5,
                       steps: [3, 11], guideBars: 0, label: "Rim", unit: "rims", sound: .perc),
        ], gold: [
            L.gold("Answer, don't crowd", "A percussion phrase that responds to the drums."),
            L.make("Your answer", "Rims only where the kick and snare rest. At least three.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.perc], start: pocket.keeping([.kick, .clap, .hat], bass: false, chords: false), goal: .atLeast(.perc, 3)),
        ]),
        "rnb.rb1.boss": (silver: [
            L.silver("Fewer markers", "No beat guide, one extra accent."),
            L.copy("Rebuild it", "Listen for the open hat accent.", tracks: [.kick, .clap, .hat, .openHat, .perc],
                   edit: [.kick, .clap, .hat, .openHat, .perc], target: Pattern(kick: [0, 9], clap: [4, 12], hat: sixteenths, openHat: [6], perc: [7, 15])),
        ], gold: [
            L.gold("Two levels of intimacy", "A very close version and a more open one."),
            L.make("Close", "Minimal. Two rims.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   goal: .atLeast(.perc, 2)),
            L.make("Open", "More hats and an open hat. At least ten hats.", tracks: [.kick, .clap, .hat, .openHat, .perc],
                   edit: [.kick, .clap, .hat, .openHat, .perc], start: silky, goal: .atLeast(.hat, 10)),
        ]),
        "rnb.rb2.1": (silver: [
            L.silver("Seventh colours", "Major sevenths dream. Minor sevenths sigh. Hear and build both."),
            K.quiz("Which seventh?", "", [
                K.round([cmaj7], ["Major 7", "Minor 7"], 0),
                K.round([am7], ["Major 7", "Minor 7"], 1),
                K.round([fmaj7], ["Major 7", "Minor 7"], 0),
                K.round([dm7], ["Major 7", "Minor 7"], 1),
            ]),
            K.build("Build Dm7", "D F A C.", ChordShape.dm7),
            K.build("Build Fmaj7", "F A C E.", fmaj7, low: 50, high: 67),
        ], gold: [
            L.gold("Two chords, one extended", "A two-chord loop where at least one has a seventh."),
            K.lane("Your loop", "Use at least one seventh chord.", .create(.chordsAtLeast(2)), palette: [cTri, amTri, cmaj7, am7, fmaj7, dm7],
                   backing: pocket, length: 7),
            K.build("Build Em7", "E G B D.", ChordShape.em7),
        ]),
        "rnb.rb2.2": (silver: [
            L.silver("Build the glow", "Ninth chords and inversions from a reference voicing."),
            K.build("Build Am9", "A C E G B.", am9, low: 55, high: 72),
            K.build("Build Dm9", "A C D E F, close together.", dm9, low: 55, high: 69),
            K.quiz("Root position or inversion?", "", [
                K.round([cTri], ["Root at the bottom", "Inverted"], 0),
                K.round([cOverE], ["Root at the bottom", "Inverted"], 1, "E at the bottom. Lighter, less anchored."),
            ]),
        ], gold: [
            L.gold("Two voicings, one chord", "Pick the voicing you'd use in your song."),
            K.build("Fmaj9", "F's richest form.", fmaj9, low: 55, high: 69),
            K.build("Em9", "E G B D F sharp.", em9, low: 53, high: 69),
            K.lane("Use your voicings", "At least two chords.", .create(.chordsAtLeast(2)), palette: [cmaj9, am9, fmaj9, em9],
                   backing: pocket, length: 7),
        ]),
        "rnb.rb2.3": (silver: [
            L.silver("Keep the common notes", "Revoice a progression so shared notes stay put."),
            K.build("Fmaj7 to Dm7", "Move E down to D. Keep F, A, C.", dm7, start: [53, 57, 60], low: 50, high: 67, exact: true),
            K.build("Dm7 to G7", "Move A to G and C to B.", g7, start: [53, 62], low: 50, high: 67, exact: true),
            K.quiz("Smooth or jumpy?", "", [
                K.round([fmaj7, dm7], ["Smooth", "Jumpy"], 0),
                K.round([dm7, fWide], ["Smooth", "Jumpy"], 1),
            ]),
        ], gold: [
            L.gold("Your smooth progression", "Four chords that melt into each other."),
            K.order("Your four chords", "Start home. Pick three more.", .create(.chordsAtLeast(4)), tiles: progression(), slots: 4,
                    start: [0], locked: [0]),
            K.lane("Play it as stabs", "Use your chords. At least four hits.", .create(.chordsAtLeast(4)), palette: [cmaj7, am7, fmaj7, g7],
                   backing: pocket, length: 3),
        ]),
        "rnb.rb2.boss": (silver: [
            L.silver("Two voicings each", "Same chords, extended."),
            K.lane("Copy the extended loop", "Two chords. Are they sevenths or ninths?", .recreate, palette: [cmaj7, cmaj9, am7, am9], backing: pocket, target: [0: 1, 8: 3], length: 7),
            K.lane("And the plain one", "Same roots, simpler colours.", .recreate, palette: [cmaj7, cmaj9, am7, am9], backing: pocket, target: [0: 0, 8: 2], length: 7),
        ], gold: [
            L.gold("Your four-chord loop", "Your voice leading, your dynamics."),
            K.order("Your order", "Any four chords, any order.", .create(.chordsAtLeast(4)), tiles: progression(), slots: 4),
            K.lane("Your rhythm", "Place chords with space. At least four.", .create(.chordsAtLeast(4)),
                   palette: [cmaj9, am9, fmaj9, g7], backing: pocket, length: 3),
        ]),
        "rnb.rb3.1": (silver: [
            L.silver("Passing notes by ear",
                     "Now find the connectors yourself. Listen for the short note that slides into each new chord."),
            L.bass("Copy the trail", "Root, connector, root, connector.",
                   [NoteEvent(0, 41, 6), NoteEvent(6, 40, 2), NoteEvent(8, 38, 6), NoteEvent(14, 40, 2)],
                   backing: inPocket(pad(fmaj7, dm7)), rows: [48, 45, 43, 41, 40, 38, 36]),
            L.bass("A walk down", "C, then two notes walking down into A.",
                   [NoteEvent(0, 36, 4), NoteEvent(4, 48, 2), NoteEvent(6, 47, 2), NoteEvent(8, 45, 8)],
                   backing: inPocket(pad(cmaj9, am9)), rows: [48, 47, 45, 43, 41, 40, 36]),
        ], gold: [
            L.gold("Connect the harmony",
                   "A great R&B bassline is half notes and half gaps. Play the root, connect where it matters, and let the rest breathe."),
            L.bassMake("Your bass trail", "At least five notes, with a connector into each chord.", backing: inPocket(pad(cmaj9, am9)), notes: 5,
                       rows: rows),
            L.bassMake("Under Fmaj7 and Dm7", "A second trail under new chords. At least four notes.", backing: inPocket(pad(fmaj7, dm7)),
                       notes: 4, rows: [48, 45, 43, 41, 40, 38, 36]),
        ]),
        "rnb.rb3.2": (silver: [
            L.silver("Syncopated phrases",
                     "R&B melodies love to start just after the beat, like a singer taking a breath first. Copy two by ear."),
            K.leadCopy("Copy the phrase", "It starts off the beat.", rows: lead,
                       target: K.tune([(1, 72, 2), (3, 69, 3), (9, 67, 2), (11, 64, 5)]), backing: groove),
            K.leadCopy("Another", "Short notes, then a long one.", rows: lead,
                       target: K.tune([(2, 64, 1), (3, 67, 1), (4, 69, 4), (10, 67, 1), (11, 69, 1), (12, 72, 4)]), backing: groove),
        ], gold: [
            L.gold("Two phrases",
                   "Write two phrases that feel like a singer: different note lengths, and room to breathe between them."),
            K.leadMake("Phrase 1", "At least four notes, starting off the beat.", rows: lead, backing: groove, notes: 4),
            K.leadMake("Phrase 2", "At least five notes, with different lengths from phrase 1.", rows: lead, backing: groove, notes: 5),
        ]),
        "rnb.rb3.3": (silver: [
            L.silver("Response by ear",
                     "Five notes to choose from. Hear the call and its answer, then rebuild both."),
            K.leadCopy("Copy the call and response", "Up for the call, down for the answer.", rows: [72, 69, 67, 64, 62],
                       target: K.tune([(0, 67, 2), (2, 69, 2), (4, 72, 4), (8, 69, 2), (10, 67, 2), (12, 64, 4)]), backing: groove),
            K.quiz("Call or response?", "", [
                K.round(K.phrase([64, 67, 69]), ["Sounds like a call", "Sounds like an answer"], 0, "It rises and hangs."),
                K.round(K.phrase([69, 67, 60]), ["Sounds like a call", "Sounds like an answer"], 1, "It lands home on C."),
            ]),
        ], gold: [
            L.gold("Your call and response",
                   "Write a call, leave a gap, then answer it. Same chords, your conversation."),
            K.leadMake("Call and answer", "At least eight notes: a call, a gap, an answer.", rows: lead, backing: groove, notes: 8),
        ]),
        "rnb.rb3.boss": (silver: [
            L.silver("Eight bars with space",
                     "A topline that leaves room, over a bassline that connects."),
            K.leadMake("Topline", "At least six notes with real gaps.", rows: lead, backing: groove, notes: 6),
            L.bassMake("Bass", "At least four notes that connect the chords.", backing: inPocket(pad(cmaj9, am9)), notes: 4, rows: rows),
        ], gold: [
            L.gold("Motif and variation",
                   "Write a short motif, then a variation that starts the same and ends somewhere new. That's how hooks develop."),
            K.leadMake("Motif", "At least four notes.", rows: lead, backing: groove, notes: 4),
            K.leadMake("Variation", "Keep the opening, change the ending. At least six notes.", rows: lead, backing: groove, notes: 6,
                       start: Array(topline.prefix(3))),
        ]),
        "rnb.rb4.1": (silver: [
            L.silver("Attack and sustain", "Name each sound from how it starts and how long it holds."),
            K.quiz("Which sound?", "", [
                K.sound(song, padSound, ["Electric piano", "Pad", "Pluck"], 1),
                K.sound(song, pluckSound, ["Electric piano", "Pad", "Pluck"], 2),
                K.sound(song, rhodes, ["Electric piano", "Pad", "Pluck"], 0),
            ]),
            K.lab("Match the pad", "Slow attack, long release.", [.chordAttack, .chordRelease], start: [0, 0.1], target: [0.7, 0.9], loop: keysLoop),
        ], gold: [
            L.gold("Verse tone, chorus tone",
                   "Two tones that still sound like the same record: more intimate for the verse, fuller for the chorus."),
            K.lab("Verse tone", "Soft and close.", [.chordAttack, .chordDecay, .chordCutoff], start: [0.5, 0.5, 0.5], loop: verse),
            K.lab("Chorus tone", "Fuller and brighter.", [.chordAttack, .chordDecay, .chordCutoff], start: [0.5, 0.5, 0.5], loop: chorus),
        ]),
        "rnb.rb4.2": (silver: [
            L.silver("Match a gentle sound", "Find the warm setting by ear."),
            K.lab("Match it", "Attack first, then cutoff.", [.chordAttack, .chordCutoff], start: [0, 1], target: [0.4, 0.35], loop: keysLoop),
            K.lab("Warm the bass", "Rounder wave, lower cutoff.", [.bassWave, .bassCutoff], start: [1, 0.9], target: [0.1, 0.3],
                  loop: pocket.merged(with: Pattern(bass: bass))),
        ], gold: [
            L.gold("Your soft sound", "Design a sustained chord sound you'd build a song around."),
            K.lab("Your chord sound", "Every chord knob.", [.chordAttack, .chordDecay, .chordRelease, .chordCutoff],
                  start: [0.5, 0.5, 0.5, 0.5], loop: keysLoop),
            K.quiz("Would it fit R&B?", "", [
                K.sound(keysLoop, [.chordCutoff: 1, .chordAttack: 0, .chordDecay: 0.1], ["Fits", "Too harsh"], 1),
                K.sound(keysLoop, rhodes, ["Fits", "Too harsh"], 0),
            ]),
        ]),
        "rnb.rb4.3": (silver: [
            L.silver("Room without burying", "Hear sizes, then set a room that keeps the lead clear."),
            K.quiz("How much room?", "", [
                K.reverb(song, amount: 0.15, ["Small", "Medium", "Huge"], 0),
                K.reverb(song, amount: 0.5, ["Small", "Medium", "Huge"], 1),
                K.reverb(song, amount: 0.9, ["Small", "Medium", "Huge"], 2),
            ]),
            K.space("Set it", "Roomy, with the lead still clear.", song),
        ], gold: [
            L.gold("Two treatments", "Give the backing more space than the hook, so the hook sits up front."),
            K.space("Backing", "Generous space on the chords.", keysLoop),
            K.space("Hook", "Drier, so it stays close.", K.melody(topline, over: pocket)),
        ]),
        "rnb.rb4.boss": (silver: [
            L.silver("Too wet", "This mix is soaked. Hear it, then fix it."),
            K.quiz("What's wrong?", "", [
                K.reverb(song, amount: 0.95, ["Too wet", "Fine"], 0),
                K.reverb(song, amount: 0.2, ["Too wet", "Fine"], 1),
            ]),
            K.space("Dry it out", "Bring it back to an intimate room.", song),
        ], gold: [
            L.gold("Your palette", "Keys, bass and balance, with one personal choice."),
            K.lab("Keys", "Your electric piano or pad.", [.chordAttack, .chordDecay, .chordCutoff], start: [0.5, 0.5, 0.5], loop: keysLoop),
            K.lab("Bass", "Your bass tone.", [.bassWave, .bassCutoff, .bassDecay], start: [0.5, 0.5, 0.5],
                  loop: pocket.merged(with: Pattern(bass: bass))),
            K.mix("Balance", "Every part clear, drums on top.", [.drum(.kick), .drum(.clap), .bass, .chords], start: [K.u, K.u, K.u, K.u],
                  loop: song),
        ]),
        "rnb.rb5.1": (silver: [
            L.silver("Label the arc", "No labels. Hear each section and name it."),
            K.order("Label it", "Four sections, two bars each.", .recreate, tiles: sections(), answer: [1, 2, 3, 1], barsEach: 2),
            K.tapChanges("Tap the changes", "These are subtle.", loops: [intro, verse, lift, chorus], barsEach: 2),
        ], gold: [
            L.gold("Your arc", "Build an A, B, return arc with voicing and layer changes."),
            K.arrange("A, B, return", "Three sections. B should feel more open.", .create(.variedSections), sections: ["A", "B", "A"],
                      lanes: lanes, loop: chorus),
            K.lane("B's chords", "Richer voicings for B. At least two.", .create(.chordsAtLeast(2)), palette: [cmaj9, am9, fmaj9, em9],
                   backing: silky, length: 7),
        ]),
        "rnb.rb5.2": (silver: [
            L.silver("Two subtle moves", "Copy a chorus that lifts with richer chords and one extra layer."),
            K.arrange("Copy the lift", "Which layers join in the chorus?", .recreate, sections: ["Verse", "Chorus"], lanes: lanes, loop: chorus,
                      target: K.grid("xx", "xx", "-x", "xx", "xx")),
            K.lane("Copy the chorus chords", "Ninths, with one pushed early.", .recreate, palette: [cmaj7, am7, cmaj9, am9], backing: silky,
                   target: [0: 2, 6: 2, 8: 3], length: 5),
        ], gold: [
            L.gold("Wider, still intimate", "Make the chorus feel wider while the verse keeps its pocket."),
            K.lane("Your chorus chords", "At least three chords.", .create(.chordsAtLeast(3)), palette: [cmaj9, am9, fmaj9, em9],
                   backing: silky, length: 5),
            K.arrange("Verse and chorus", "Four sections.", .create(.variedSections), sections: ["Verse", "Chorus", "Verse", "Chorus"],
                      lanes: lanes, loop: chorus),
        ]),
        "rnb.rb5.3": (silver: [
            L.silver("Match a transition", "Rebuild a soft transition from the reference."),
            K.order("Copy it", "Verse, pickup, then two bars of chorus.", .recreate,
                    tiles: [K.tile("Verse", verse), K.tile("Pickup", pickup), K.tile("Chorus", chorus)], answer: [0, 1, 2, 2]),
            K.quiz("Which fits R&B?", "", [
                K.ask("Before the chorus, an R&B song usually…", ["Nudges in with a pickup", "Drops a huge build", "Stops for four bars"], 0),
            ]),
        ], gold: [
            L.gold("Understated", "Two transitions of your own, nothing EDM about them."),
            L.make("Your pickup", "Rims and soft hits at the end of the bar. At least three rims.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], start: pocket, goal: .atLeast(.perc, 3)),
            K.order("Place it", "Eight bars, your order.", .create(.chordsAtLeast(8)),
                    tiles: [K.tile("Verse", verse), K.tile("Pickup", pickup), K.tile("Chorus", chorus)], slots: 8),
        ]),
        "rnb.rb5.boss": (silver: [
            L.silver("Vary between sections", "Different voicing, bass and percussion in every section."),
            K.order("Your map", "Eight blocks.", .create(.variedSections), tiles: sections(), slots: 8, barsEach: 2),
            K.arrange("Layers", "Four sections.", .create(.variedSections), sections: ["Verse", "Lift", "Chorus", "Outro"], lanes: lanes,
                      loop: chorus),
        ], gold: [
            L.gold("Expressive backing", "Nuanced builds and a satisfying ending."),
            K.order("Your map", "Ten blocks.", .create(.variedSections), tiles: sections(), slots: 10, barsEach: 2),
            K.arrange("Layers", "Six sections.", .create(.variedSections), sections: ["Intro", "Verse", "Lift", "Chorus", "Verse", "Outro"],
                      lanes: lanes, loop: chorus),
        ]),
        "rnb.rb6": (silver: [
            L.silver("Revise it", "Revised voicings, a melodic answer and two energy levels."),
            K.order("Your chords", "Four chords.", .create(.chordsAtLeast(4)), tiles: progression(), slots: 4),
            K.leadMake("Your melody", "At least six notes, with an answer.", rows: lead, backing: groove, notes: 6),
            K.arrange("Two energies", "Four sections.", .create(.variedSections), sections: ["Verse", "Chorus", "Verse", "Chorus"],
                      lanes: lanes, loop: chorus),
        ], gold: [
            L.gold("Your harmonic signature", "One to two minutes that sound unmistakably like you."),
            L.make("Your pocket", "Every drum is yours. At least two rims.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], goal: .atLeast(.perc, 2)),
            K.lane("Your chords", "At least three rich chords.", .create(.chordsAtLeast(3)), palette: [cmaj9, am9, fmaj9, em9, dm9, g7],
                   backing: pocket, length: 5),
            L.bassMake("Your bass", "At least five notes.", backing: inPocket(pad(cmaj9, am9)), notes: 5, rows: rows),
            K.leadMake("Your melody", "At least seven notes.", rows: lead, backing: groove, notes: 7),
            K.order("Your map", "Twelve blocks.", .create(.variedSections), tiles: sections(), slots: 12, barsEach: 2),
        ]),
    ]
}
