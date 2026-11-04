//
//  ProductionUnits.swift
//  Groova
//
//  One production unit per genre, each teaching a different core skill so nothing repeats
//  when you learn more than one genre:
//
//  House       Melody & Hooks          scales, motifs, variation, call and response
//  Deep House  Voice Leading           inversions, common notes, the top line
//  Techno      Riffs & Arps            one-note riffs, arpeggios, the dark half step, riffs in the gaps
//  Tech House  Keys & Transposing      moving ideas to a new key, hearing key changes
//  UK Garage   Bass & Chords Talking   leaving space, answering, hitting together
//

import Foundation

// MARK: - House: Melody & Hooks

extension HouseCourse {
    /// A minor pentatonic, A4 down to A3.
    static let melodyRows = [69, 67, 64, 62, 60, 57]
    static let melodyBed = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14],
                                   bass: [NoteEvent(0, 33, 6), NoteEvent(8, 38, 6)])

    static let melodyUnit = K.unit("house.mel", 4, "Melody & Hooks", "Scales, motifs & catchy riffs", [
        K.lesson("house.mel.l1", "Five Safe Notes", "The minor pentatonic", "pianokeys", .theory, 30, [
            K.play("Play the A minor pentatonic",
                   "A scale is a set of notes that belong together. This one has five: A, C, D, E and G. It's the most-used scale in dance music because none of its notes clash. Play them from low to high.",
                   [57, 60, 62, 64, 67, 69], low: 57, high: 69),
            K.quiz("Up or down?", "Every melody has a direction. Listen to which way this one moves.", [
                K.round(K.phrase([57, 60, 64]), ["Goes up", "Goes down"], 0, "A, C, E: climbing the scale."),
                K.round(K.phrase([69, 64, 60]), ["Goes up", "Goes down"], 1, "High A, E, C: stepping down."),
                K.round(K.phrase([60, 62, 64, 67]), ["Goes up", "Goes down"], 0),
                K.round(K.phrase([67, 64, 62, 57]), ["Goes up", "Goes down"], 1),
            ]),
            K.leadMake("Doodle in the scale",
                       "Every row is in the scale, so nothing you play will clash. Place at least four notes and play it back.",
                       rows: melodyRows, backing: melodyBed, notes: 4),
        ]),
        K.lesson("house.mel.l2", "Your First Motif", "A short idea that repeats", "repeat", .theory, 30, [
            K.intro("Meet the motif",
                    "A motif is a tiny musical idea, just two to four notes. Repeat it and the listener's ear grabs on. Most hooks are a motif played again and again. Hear one: C, D, E, twice.",
                    [], demo: K.withLead(melodyBed, K.line([(0, 60), (2, 62), (4, 64), (8, 60), (10, 62), (12, 64)]))),
            K.leadRule("Play the motif twice", "C, D and E on steps 1, 3 and 5. Then play it again on steps 9, 11 and 13.",
                       rows: melodyRows, target: K.line([(0, 60), (2, 62), (4, 64), (8, 60), (10, 62), (12, 64)]),
                       backing: melodyBed),
            K.leadCopy("Copy this motif", "Three notes, played twice. This one starts on the high A and falls.",
                       rows: melodyRows, target: K.line([(0, 69), (1, 67), (3, 64), (8, 69), (9, 67), (11, 64)]),
                       backing: melodyBed),
        ]),
        K.lesson("house.mel.l3", "Repeat, Then Twist", "Variation keeps it catchy", "arrow.triangle.branch", .theory, 30, [
            K.quiz("Does it feel finished?",
                   "A is home in this scale. A melody that ends on A feels finished. End anywhere else and it leaves you hanging, wanting more.", [
                K.round(K.phrase([60, 62, 64, 57]), ["Feels finished", "Leaves you hanging"], 0, "It lands on A, home."),
                K.round(K.phrase([60, 62, 64, 62]), ["Feels finished", "Leaves you hanging"], 1, "It stops on D, away from home."),
                K.round(K.phrase([69, 67, 64, 69]), ["Feels finished", "Leaves you hanging"], 0),
                K.round(K.phrase([64, 62, 60, 67]), ["Feels finished", "Leaves you hanging"], 1),
            ]),
            K.leadCopy("Same start, new ending",
                       "The motif plays twice. The second time, the last note changes and lands on home: the low A.",
                       rows: melodyRows,
                       target: [NoteEvent(0, 64), NoteEvent(2, 62), NoteEvent(4, 60, 2), NoteEvent(8, 64), NoteEvent(10, 62),
                                NoteEvent(12, 57, 4)],
                       backing: melodyBed),
            K.leadMake("Twist your own motif",
                       "Play a short motif, repeat it, and change the last note the second time. At least six notes.",
                       rows: melodyRows, backing: melodyBed, notes: 6),
        ]),
        K.lesson("house.mel.l4", "Question and Answer", "Call and response", "bubble.left.and.bubble.right.fill", .theory, 30, [
            K.intro("Call and response",
                    "Lots of hooks work like a conversation. The first half asks a question by stopping away from home. The second half answers by coming back to A. Listen for the question, then the answer.",
                    [], demo: K.withLead(melodyBed, [NoteEvent(0, 60), NoteEvent(2, 62), NoteEvent(4, 67, 2),
                                                    NoteEvent(8, 64), NoteEvent(10, 62), NoteEvent(12, 57, 4)])),
            K.leadRule("Answer the question",
                       "The question is already there, on steps 1 to 6. Answer it: E on step 9, D on step 11, then the low A on step 13, held for four steps.",
                       rows: melodyRows,
                       target: [NoteEvent(0, 60), NoteEvent(2, 62), NoteEvent(4, 67, 2),
                                NoteEvent(8, 64), NoteEvent(10, 62), NoteEvent(12, 57, 4)],
                       backing: melodyBed,
                       start: [NoteEvent(0, 60), NoteEvent(2, 62), NoteEvent(4, 67, 2)]),
            K.leadCopy("Copy this call and response",
                       "The question falls from the high A and stops on G. The answer comes home to A.",
                       rows: melodyRows,
                       target: [NoteEvent(0, 69), NoteEvent(1, 67), NoteEvent(2, 64), NoteEvent(6, 67, 2),
                                NoteEvent(8, 64), NoteEvent(9, 62), NoteEvent(10, 60), NoteEvent(12, 57, 4)],
                       backing: melodyBed),
        ]),
        K.lesson("house.mel.l5", "Hooks Between the Kicks", "Rhythm makes it stick", "music.note", .rhythm, 30, [
            K.leadRule("Push the motif off the beat",
                       "Same notes as before, C, D and E, but start between the kicks: steps 3, 4 and 7, then again on 11, 12 and 15. Dodging the kick makes a hook bounce.",
                       rows: melodyRows,
                       target: K.line([(2, 60), (3, 62), (6, 64), (10, 60), (11, 62), (14, 64)]), backing: melodyBed),
            K.leadCopy("Copy this offbeat hook", "Five notes, and none of them land on a kick.",
                       rows: melodyRows,
                       target: [NoteEvent(1, 64), NoteEvent(3, 67), NoteEvent(6, 69, 2), NoteEvent(10, 67), NoteEvent(14, 64)],
                       backing: melodyBed),
            K.leadMake("Write a hook",
                       "Use the scale, repeat a motif, twist the ending, and keep most notes off the kick. At least six notes.",
                       rows: melodyRows, backing: melodyBed, notes: 6),
        ]),
        K.mastery("house.mel.mastery", "Hook Mastery", "Recreate a piano house hook", .theory, 80, [
            K.leadCopy("Recreate this hook",
                       "A motif, repeated with a twist at the end, mostly between the kicks.",
                       rows: melodyRows,
                       target: [NoteEvent(2, 64), NoteEvent(3, 67), NoteEvent(6, 69), NoteEvent(10, 64), NoteEvent(11, 67),
                                NoteEvent(14, 57, 2)],
                       backing: melodyBed),
        ]),
    ])
}

// MARK: - Deep House: Voice Leading

extension DeepHouseCourse {
    /// Fm7 stacked from C: C, E♭, F, A♭.
    static let fm7OnC = ChordShape(name: "Fm7", pitches: [60, 63, 65, 68])
    /// Cm7 stacked from E♭: E♭, G, B♭, C.
    static let cm7OnEb = ChordShape(name: "Cm7", pitches: [63, 67, 70, 72])
    /// D♭maj7 in root position, high up: a big jump away from Fm7.
    static let dbmaj7Wide = ChordShape(name: "D♭maj7", pitches: [61, 65, 68, 72])
    /// Cm7 in root position, low: a jump away from B♭m7.
    static let cm7Low = ChordShape(name: "Cm7", pitches: [48, 51, 55, 58])
    /// B♭m7 with A♭ at the bottom and F on top.
    static let bbm7TopF = ChordShape(name: "B♭m7", pitches: [56, 58, 61, 65])

    static let glideBed = Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], perc: [7, 15])

    static let voiceUnit = K.unit("deep.vl", 4, "Voice Leading", "Chords that glide", [
        K.lesson("deep.vl.l1", "Inversions", "Same notes, new order", "arrow.up.arrow.down", .theory, 30, [
            K.intro("Meet the inversion",
                    "Take the bottom note of a chord and move it up an octave. It's still the same chord, just stacked in a new order. That's an inversion. Hear Fm7 stacked two ways.",
                    [], demo: Pattern(kick: [0, 8], hat: [2, 6, 10, 14], chords: [K.ch(0, .fm7, 7), K.ch(8, fm7OnC, 7)])),
            K.build("Build Fm7 with C on the bottom",
                    "Fm7 is F, A♭, C and E♭. Stack it from C instead: C, then E♭, F and A♭ above it.",
                    fm7OnC, low: 53, high: 72, exact: true),
            K.quiz("Same chord or a new one?",
                   "An inversion keeps the chord's colour. Listen: is the second chord the first one restacked, or a different chord?", [
                K.round([.fm7, fm7OnC], ["Same chord", "New chord"], 0, "Fm7, then Fm7 stacked from C."),
                K.round([.fm7, .bbm7], ["Same chord", "New chord"], 1, "Fm7 moved to B♭m7."),
                K.round([.cm7, cm7OnEb], ["Same chord", "New chord"], 0, "Cm7 both times, stacked two ways."),
                K.round([fm7OnC, .dbmaj7], ["Same chord", "New chord"], 1),
            ]),
        ]),
        K.lesson("deep.vl.l2", "Keep the Common Notes", "Move as little as possible", "point.3.connected.trianglepath.dotted",
                 .theory, 30, [
            K.intro("Shared notes",
                    "Fm7 (F, A♭, C, E♭) and D♭maj7 (D♭, F, A♭, C) share three notes. Keep those still and move only E♭ down to D♭. The chords glide instead of jumping. That's voice leading.",
                    [], demo: Pattern(kick: [0, 8], hat: [2, 6, 10, 14], chords: [K.ch(0, .fm7, 7), K.ch(8, .dbmaj7, 7)])),
            K.build("Glide from Fm7 to D♭maj7",
                    "Fm7 is already there. Move just one note: take E♭ out and add the D♭ right below it.",
                    .dbmaj7, start: [53, 56, 60, 63], low: 53, high: 67, exact: true),
            K.quiz("Smooth or jumpy?", "Same two chords each time, voiced differently. Does the change glide or leap?", [
                K.round([.fm7, .dbmaj7], ["Smooth", "Jumpy"], 0, "Three notes stay put. Only one moves."),
                K.round([.fm7, dbmaj7Wide], ["Smooth", "Jumpy"], 1, "Every note jumps up to a new place."),
                K.round([.bbm7, .cm7], ["Smooth", "Jumpy"], 0, "Each note moves just a step."),
                K.round([.bbm7, cm7Low], ["Smooth", "Jumpy"], 1),
            ]),
        ]),
        K.lesson("deep.vl.l3", "The Top Note", "The highest note sings", "arrow.up.to.line", .theory, 30, [
            K.quiz("Where does the top note go?",
                   "In a progression, your ear follows the highest note like a melody. Listen to the very top of each chord.", [
                K.round([.fm7, .dbmaj7], ["Up", "Down", "Stays"], 1, "E♭ on top, then D♭: down a step."),
                K.round([.dbmaj7, .ebmaj7], ["Up", "Down", "Stays"], 0, "D♭ on top, then E♭: up a step."),
                K.round([.cm7, .ebmaj7], ["Up", "Down", "Stays"], 2, "E♭ on top both times."),
                K.round([.bbm7, .fm7], ["Up", "Down", "Stays"], 0),
            ]),
            K.build("Voice B♭m7 with F on top",
                    "B♭m7 is B♭, D♭, F and A♭. Put A♭ at the bottom, then B♭ and D♭, so F sings on top.",
                    bbm7TopF, low: 53, high: 69, exact: true),
        ]),
        K.lesson("deep.vl.l4", "Glide Through Four", "A smooth progression", "wave.3.right", .theory, 30, [
            K.lane("Copy this gliding progression",
                   "Four chords, one per beat. They're all voiced close together, so listen for small moves, not big jumps.",
                   .recreate, palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glideBed,
                   target: [0: 0, 4: 1, 8: 2, 12: 3], length: 4),
            K.lane("Write your own four-chord glide",
                   "These voicings already sit close together, so any order glides. Place at least four chords.",
                   .create(.chordsAtLeast(4)), palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glideBed, length: 4),
        ]),
        K.mastery("deep.vl.mastery", "Voice Leading Mastery", "Recreate a gliding progression", .theory, 80, [
            K.lane("Recreate this late-night progression",
                   "Four chords that barely move. Listen to the top note to keep your place.",
                   .recreate, palette: [.fm7, .dbmaj7, .bbm7, .cm7], backing: glideBed,
                   target: [0: 0, 6: 1, 8: 2, 14: 3], length: 2),
        ]),
    ])
}

// MARK: - Techno: Riffs & Arps

extension TechnoCourse {
    /// A3 up to A4, with A♯ for the dark half step.
    static let riffRows = [69, 67, 64, 60, 58, 57]
    /// A minor chord tones for arpeggios.
    static let arpRows = [69, 64, 60, 57]
    static let riffBed = Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14])
    static let riffBass = Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14], bass: rolling)

    static let riffUnit = K.unit("techno.riff", 4, "Riffs & Arps", "Hypnotic lead lines", [
        K.lesson("techno.riff.l1", "One-Note Riff", "Rhythm is the hook", "metronome.fill", .rhythm, 30, [
            K.leadRule("A one-note riff",
                       "Techno riffs often use a single note. The rhythm does all the work. Put A (bottom row) on steps 2, 4, 7, 10 and 13.",
                       rows: riffRows, target: K.notes(57, [1, 3, 6, 9, 12]), backing: riffBed),
            K.leadCopy("Copy this one-note riff",
                       "Still only A. Some notes are long and some are short. Listen for the gaps.",
                       rows: riffRows,
                       target: [NoteEvent(0, 57, 2), NoteEvent(3, 57), NoteEvent(6, 57, 3), NoteEvent(11, 57), NoteEvent(14, 57)],
                       backing: riffBed),
        ]),
        K.lesson("techno.riff.l2", "Arpeggios", "A chord, one note at a time", "chart.line.uptrend.xyaxis", .theory, 30, [
            K.intro("Meet the arpeggio",
                    "An arpeggio plays a chord's notes one after another instead of all at once. A minor is A, C and E. Cycle through them in 16ths and you get a classic hypnotic arp.",
                    [], demo: K.withLead(riffBed, (0..<16).map { NoteEvent($0, [57, 60, 64, 69][$0 % 4]) })),
            K.leadRule("Arpeggiate A minor upwards",
                       "A, C, E, then the high A, on steps 1 to 4. Repeat that four times to fill the bar.",
                       rows: arpRows, target: (0..<16).map { NoteEvent($0, [57, 60, 64, 69][$0 % 4]) }, backing: riffBed),
            K.leadCopy("Copy this rolling arp",
                       "Six notes up and back down: A, C, E, high A, E, C. Six doesn't divide into the bar, so it lands somewhere new each beat.",
                       rows: arpRows, target: (0..<16).map { NoteEvent($0, [57, 60, 64, 69, 64, 60][$0 % 6]) },
                       backing: riffBed),
        ]),
        K.lesson("techno.riff.l3", "The Dark Note", "Half-step tension", "moon.fill", .theory, 30, [
            K.intro("Meet the dark note",
                    "A♯ sits just one half step above A, the smallest gap there is. Against A it sounds tense and dark, and it's all over techno. Hear a riff that leans on it.",
                    [], demo: K.withLead(riffBed, K.line([(0, 57), (2, 57), (3, 58), (6, 57), (8, 57), (10, 58), (11, 57), (14, 58)]))),
            K.quiz("Dark or bright?", "Each riff starts on A. Listen to the note it leans on.", [
                K.round(K.phrase([57, 57, 58, 57]), ["Dark", "Bright"], 0, "A♯ rubs right against A."),
                K.round(K.phrase([57, 57, 60, 57]), ["Dark", "Bright"], 1, "C is a comfortable step away."),
                K.round(K.phrase([57, 58, 57, 64]), ["Dark", "Bright"], 0),
                K.round(K.phrase([57, 64, 60, 57]), ["Dark", "Bright"], 1),
            ]),
            K.leadCopy("Copy this dark riff",
                       "Mostly A, with A♯ (second row from the bottom) for tension.",
                       rows: riffRows,
                       target: K.line([(0, 57), (2, 57), (3, 58), (6, 57), (8, 57), (10, 58), (11, 57), (14, 58)]),
                       backing: riffBed),
        ]),
        K.lesson("techno.riff.l4", "Riff in the Gaps", "Lead and bass take turns", "square.split.2x1.fill", .rhythm, 30, [
            K.leadRule("Play only where the bass rests",
                       "The bass rolls on each offbeat and the 16th after it. Put a high A (top row) on steps 2, 6, 10 and 14, right after each kick, where the bass is silent.",
                       rows: riffRows, target: K.notes(69, [1, 5, 9, 13]), backing: riffBass),
            K.leadMake("Write a riff for the gaps",
                       "At least five notes, all kept out of the bass's way. Use A♯ somewhere for a dark edge.",
                       rows: riffRows, backing: riffBass, notes: 5),
        ]),
        K.mastery("techno.riff.mastery", "Riff Mastery", "Recreate a hypnotic lead", .theory, 80, [
            K.leadCopy("Recreate this hypnotic lead",
                       "A short arp, a dark note, and every note in the gaps of the bass.",
                       rows: riffRows,
                       target: K.line([(0, 57), (1, 60), (4, 64), (5, 57), (8, 57), (9, 60), (12, 58), (13, 57)]),
                       backing: riffBass),
        ]),
    ])
}

// MARK: - Tech House: Keys & Transposing

extension TechHouseCourse {
    /// C2 up to C3: enough notes to play the same line in C and in D.
    static let keyRows = [48, 46, 45, 43, 41, 39, 38, 36]
    static let lineInC = [NoteEvent(2, 36), NoteEvent(6, 36), NoteEvent(7, 39), NoteEvent(10, 36), NoteEvent(14, 43)]
    static let keyBed = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], perc: [3, 9, 13])

    static let keyUnit = K.unit("tech.key", 3, "Keys & Transposing", "Move ideas to any key", [
        K.lesson("tech.key.l1", "Same Shape, New Key", "What transposing means", "arrow.up.circle.fill", .theory, 30, [
            K.intro("Meet transposing",
                    "Transposing moves every note up or down by the same amount. The line keeps its shape and rhythm, it just sits higher or lower. Producers do it to fit a vocal, or to lift the energy late in a track.",
                    [], demo: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15], bass: lineInC)),
            .pianoRoll(PianoRollTask(
                prompt: "Move this bassline up to D",
                hint: "This line is in C. Move every note up one whole step: C becomes D, D♯ becomes F, G becomes A. Keep the rhythm the same.",
                mode: .rule, rows: keyRows,
                target: lineInC.map { NoteEvent($0.step, $0.pitch + 2, $0.length) },
                backing: keyBed, start: lineInC)),
            K.bassCopy("Copy it in the new key",
                       "A new tech house line in D. Same idea: find the first note, and the rest follow the shape.",
                       rows: keyRows,
                       target: [NoteEvent(1, 38), NoteEvent(3, 38), NoteEvent(6, 45), NoteEvent(9, 41), NoteEvent(11, 38),
                                NoteEvent(14, 45)],
                       backing: keyBed),
        ]),
        K.lesson("tech.key.l2", "Higher or Lower?", "Hear a key change", "ear.fill", .theory, 30, [
            K.quiz("Did it move up or down?",
                   "You'll hear a short riff, then the same riff in a new key. Did the second one move up or down?", [
                K.round(K.phrase([48, 51, 55, 50, 53, 57]), ["Moved up", "Moved down"], 0, "C, E♭, G, then the same from D."),
                K.round(K.phrase([55, 58, 62, 53, 56, 60]), ["Moved up", "Moved down"], 1, "Down a whole step."),
                K.round(K.phrase([52, 55, 59, 57, 60, 64]), ["Moved up", "Moved down"], 0, "Up five half steps: a big lift."),
                K.round(K.phrase([57, 60, 64, 52, 55, 59]), ["Moved up", "Moved down"], 1),
            ]),
        ]),
        K.lesson("tech.key.l3", "Move the Chords", "A whole progression, new key", "pianokeys.inverse", .theory, 30, [
            K.lane("Move this progression up to C minor",
                   "Am7 to Dm7 is the loop. Move it up three half steps: Am7 becomes Cm7, and Dm7 becomes Fm7. Swap every stab.",
                   .rule, palette: [.am7, .dm7, .cm7, .fm7], backing: keyBed,
                   start: [2: 0, 6: 0, 10: 1, 14: 1], target: [2: 2, 6: 2, 10: 3, 14: 3]),
            K.lane("Copy this progression in C minor",
                   "Already moved to the new key. Copy the rhythm and the two chords.",
                   .recreate, palette: [.am7, .dm7, .cm7, .fm7], backing: keyBed, target: [0: 2, 3: 2, 8: 3, 11: 3]),
        ]),
        K.lesson("tech.key.l4", "Bass and Chords Agree", "Everything in one key", "link", .theory, 30, [
            K.bassRule("Move the bass with the chords",
                       "The chords are now Cm7 then Fm7. Move the roots to match: C (bottom row) under Cm7 on step 3, F (fourth row up) under Fm7 on step 11.",
                       rows: keyRows, target: [NoteEvent(2, 36, 4), NoteEvent(10, 41, 4)],
                       backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                        chords: [K.ch(2, .cm7, 6), K.ch(10, .fm7, 6)])),
            K.bassMake("Write a line in the new key",
                       "Stay on C, D♯, F, G and A♯ and it'll fit the chords. At least five notes.",
                       rows: keyRows,
                       backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                        chords: [K.ch(2, .cm7, 6), K.ch(10, .fm7, 6)]), notes: 5),
        ]),
        K.mastery("tech.key.mastery", "Key Mastery", "Recreate a groove in a new key", .theory, 80, [
            K.bassCopy("Recreate this groove in C minor",
                       "Roots under the chords, with a jump up the octave and a pickup into the next bar.",
                       rows: keyRows,
                       target: [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(6, 48), NoteEvent(10, 41), NoteEvent(11, 41),
                                NoteEvent(14, 39)],
                       backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                                        chords: [K.ch(2, .cm7, 6), K.ch(10, .fm7, 6)])),
        ]),
    ])
}

// MARK: - UK Garage: Bass & Chords Talking

extension GarageCourse {
    static let gapBass = [NoteEvent(0, 40, 2), NoteEvent(3, 40), NoteEvent(8, 45, 2), NoteEvent(11, 45)]
    static let talkDrums = Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14])

    static let talkUnit = K.unit("ukg.talk", 4, "Bass & Chords Talking", "Parts that answer each other", [
        K.lesson("ukg.talk.l1", "Leave a Gap", "Chords where the bass rests", "rectangle.split.2x1", .theory, 30, [
            K.lane("Stab only where the bass rests",
                   "The bass plays on steps 1, 4, 9 and 12. Put Em9 stabs on steps 6 and 14, in its gaps, so the two never collide.",
                   .rule, palette: [.em9],
                   backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], bass: gapBass),
                   target: [5: 0, 13: 0]),
            K.lane("Copy these gap stabs",
                   "Four stabs, all in the bass's gaps. It moves to Am9 for the second half.",
                   .recreate, palette: [.em9, .am9],
                   backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], bass: gapBass),
                   target: [5: 0, 6: 0, 13: 1, 14: 1]),
        ]),
        K.lesson("ukg.talk.l2", "Bass Answers", "Reply to the chords", "arrowshape.turn.up.left.fill", .theory, 30, [
            K.bassRule("Answer each chord",
                       "The chords hit on steps 1 and 9. Answer each one: E (fourth row) on step 3 after Em9, then A (second row) on step 11 after Am9. Make each note two steps long.",
                       rows: rows, target: [NoteEvent(2, 40, 2), NoteEvent(10, 45, 2)],
                       backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                        chords: [K.ch(0, .em9, 2), K.ch(8, .am9, 2)])),
            K.bassCopy("Copy this answer line", "Each chord gets a quick two-note reply.",
                       rows: rows, target: [NoteEvent(2, 40), NoteEvent(3, 47), NoteEvent(10, 45), NoteEvent(11, 43)],
                       backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                        chords: [K.ch(0, .em9, 2), K.ch(8, .am9, 2)])),
        ]),
        K.lesson("ukg.talk.l3", "Hit Together", "Accents in unison", "burst.fill", .rhythm, 30, [
            K.intro("Hit together",
                    "Most of the time the parts take turns. Every so often they land on the same step, and that shared hit becomes an accent the whole groove leans on. Listen for the two big hits.",
                    [], demo: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                      bass: [NoteEvent(0, 40, 2), NoteEvent(10, 45, 2)],
                                      chords: [K.ch(0, .em9, 2), K.ch(10, .am9, 2)])),
            K.lane("Hit with the bass",
                   "The bass plays on steps 1 and 11. Stab Em9 on step 1 and Am9 on step 11, right on top of it.",
                   .rule, palette: [.em9, .am9],
                   backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                    bass: [NoteEvent(0, 40, 2), NoteEvent(10, 45, 2)]),
                   target: [0: 0, 10: 1]),
        ]),
        K.lesson("ukg.talk.l4", "The Conversation", "Write both parts", "bubble.left.and.text.bubble.right.fill", .theory, 30, [
            K.bassMake("Write a bass part that answers",
                       "Fill the gaps between these stabs, and land one note with a stab for an accent. At least five notes.",
                       rows: rows,
                       backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                        chords: [K.ch(1, .em9), K.ch(5, .em9), K.ch(9, .am9), K.ch(13, .am9)]),
                       notes: 5),
            K.lane("Now write stabs around this bass",
                   "Leave the bass room, then hit together once. At least four stabs.",
                   .create(.chordsAtLeast(4)), palette: [.em9, .am9],
                   backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14], bass: gapBass)),
        ]),
        K.mastery("ukg.talk.mastery", "Conversation Mastery", "Recreate a bass and chord riff", .theory, 80, [
            K.bassCopy("Recreate this garage bassline",
                       "Two hits land with the chords. Everything else answers in the gaps.",
                       rows: rows,
                       target: [NoteEvent(0, 40, 2), NoteEvent(3, 47), NoteEvent(6, 40), NoteEvent(10, 45, 2), NoteEvent(13, 43),
                                NoteEvent(15, 38)],
                       backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 6, 10, 14],
                                        chords: [K.ch(0, .em9, 2), K.ch(5, .em9), K.ch(10, .am9, 2), K.ch(14, .am9)])),
        ]),
    ])
}
