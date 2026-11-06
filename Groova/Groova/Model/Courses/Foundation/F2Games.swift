//
//  F2Games.swift
//  Groova
//
//  F2, Pitch, Notes & Your Ear, in the Teach → Studio → Game flow:
//
//  F2.1 High or Low?        → Pitch Glider      F2.2 Meet the Keys   → Keyboard Maze
//  F2.3 Notes Have Distance → Interval Radar    F2.4 Stay in a Key   → Harmonic Gravity
//  F2.5 Copy a Melody       → Echo Chase
//

import Foundation

nonisolated enum F2Games {
    typealias F = FKit

    static let lessons: [Lesson] = [f21, f22, f23, f24, f25]

    // MARK: Material

    static let drone = Pattern(chords: [K.ch(0, F.c, 15)])
    static let amBed = Pattern(chords: [K.ch(0, F.am, 15)])
    static let softBeat = Pattern(kick: [0, 8], clap: [4, 12], hat: F.offbeats)
    static let bed = F2F3.bedNoDrums
    static let rows = F.leadRows
    /// C major with F sharp squeezed in, for hearing the outside note.
    static let sharpRows = [72, 71, 69, 67, 66, 65, 64, 62, 60]

    static let lanes = [60, 62, 64, 67, 69]
    static let orbitC = NoteSurface.orbit(home: 60, notes: [62, 64, 65, 67, 69, 71], outside: nil)
    static let orbitCOut = NoteSurface.orbit(home: 60, notes: [62, 64, 65, 67, 69, 71], outside: 66)
    static let orbitA = NoteSurface.orbit(home: 69, notes: [71, 72, 74, 76, 64, 65, 67], outside: nil)

    static func line(_ n: [(Int, Int, Int)], over base: Pattern = bed) -> Pattern { K.melody(K.tune(n), over: base) }

    // MARK: - F2.1 High or Low? → Pitch Glider

    static let gliderName = "Pitch Glider"
    static let gliderLine = "Slide up and down. Fly the shape you hear."

    static let f21 = K.lesson("f2.1", "High or Low?", "The shape of a melody", "arrow.up.and.down", .theory, 15, [
        K.opening("Melodies have a shape",
                  "You can hear a melody climb and fall before you know a single note name. First you'll see higher notes sit higher in a piano roll. Then you'll fly a glider up and down with the sound."),
        K.teach("Up, down, level",
                "Three notes go up. Three come down. Three stay put. Higher sounds sit higher on the screen, and that's all you need for now.",
                demo: line([(0, 60, 2), (2, 64, 2), (4, 67, 4), (8, 67, 2), (10, 64, 2), (12, 60, 4)])),
        K.leadRule("Climb in the piano roll",
                   "Each row is a pitch, low at the bottom. Put C, E and G one beat apart: steps 1, 5 and 9. Play it and watch the notes climb. Then try E one row lower on D and hear a smaller rise.",
                   rows: rows, target: K.tune([(0, 60, 4), (4, 64, 4), (8, 67, 4)]), backing: bed),
        K.game(gliderName, gliderLine, .glider([
            GliderRound(title: "Two sonic hills", body: "Watch the glider fly up and down with the tune. Then it's your turn: slide your finger to fly the same hills.",
                        mode: .follow(trail: true), notes: [60, 64, 69, 64, 60]),
            GliderRound(title: "Follow the ghost", body: "Up, up, down. The path stays faintly lit. Trace it while you hear each note.",
                        mode: .follow(trail: true), notes: [60, 64, 67, 62]),
            GliderRound(title: "Fly by ear", body: "A new tune, and the path fades when you take off. Fly the shape from memory.",
                        mode: .follow(trail: false), notes: [62, 67, 64]),
        ])),
    ])

    static let f21Silver: [LessonStep] = [
        L.silver("Navigate without the trail",
                 "No trail this time. You'll have to remember the shape you heard. First copy a four-note melody in the piano roll. Then fly hidden shapes, spot a changed ending, and lock onto a pitch."),
        K.teach("Contour comes first",
                "The rise and fall of a melody is its contour. Hear this one: up a lot, down a bit, back down home. You can sing that shape before you know any of the notes.",
                demo: line([(0, 60, 4), (4, 67, 4), (8, 64, 4), (12, 60, 4)])),
        K.leadCopy("Copy the contour",
                   "Play the reference. Four notes: it jumps up, comes down a bit, then lands back where it started.",
                   rows: rows, target: K.tune([(0, 60, 4), (4, 67, 4), (8, 64, 4), (12, 60, 4)]), backing: bed),
        K.game(gliderName, gliderLine, .glider([
            GliderRound(title: "Hidden flight", body: "Four notes, no path left behind. Remember the shape and fly it.",
                        mode: .follow(trail: false), notes: [60, 67, 64, 69]),
            GliderRound(title: "False altitude", body: "Two tunes that start the same. Only the second one's ending changes. Fly the second one.",
                        mode: .changed(first: [60, 64, 67, 64]), notes: [60, 64, 67, 72]),
            GliderRound(title: "Land the note", body: "A guide tone keeps sounding. Slide until your glider sings the same pitch, and hold it there.",
                        mode: .hold(target: 67), bpm: 76),
        ])),
    ]

    static let f21Gold: [LessonStep] = [
        L.gold("Draw a melody",
               "Turn a drawing into a melody. First write five notes in the piano roll. Then fly a route that becomes five notes, change its ending, and keep the flight you like."),
        K.teach("Climb, fall or hold",
                "A five-note phrase is just five decisions: go up, go down, or stay. This one climbs twice, holds, then falls home.",
                demo: line([(0, 60, 3), (3, 64, 3), (6, 67, 3), (9, 67, 3), (12, 62, 4)])),
        K.leadMake("Write five notes",
                   "Any five notes in the piano roll. Decide where it climbs, where it falls and where it holds.",
                   rows: rows, backing: bed, notes: 5),
        K.game(gliderName, "Your flight path becomes a melody.", .glider([
            GliderRound(title: "Sketch a shape", body: "Five beats of open sky. Fly any route you like. Every beat turns into a note.",
                        mode: .draw),
            GliderRound(title: "Fly a new ending", body: "Your first three notes fly themselves. Take over for the last two and land somewhere new.",
                        mode: .redraw),
            GliderRound(title: "Save the flight", body: "Pick a backing, hear both flights over it, and keep the one you like.",
                        mode: .showcase),
        ])),
    ]

    // MARK: - F2.2 Meet the Keys → Keyboard Maze

    static let mazeName = "Keyboard Maze"
    static let mazeLine = "The keyboard is a map. Find your way by its landmarks."
    static let keys = NoteSurface.keyboard(low: 60, high: 72)

    static let f22 = K.lesson("f2.2", "Meet the Keys", "Note names on the keyboard", "pianokeys", .theory, 15, [
        K.opening("A map with landmarks",
                  "The keyboard looks complicated until you spot its landmarks. First you'll play keys and see them land in the piano roll. Then you'll find your way round the map using the groups of black keys."),
        K.teach("Twos and threes",
                "Black keys come in groups of two and three. C is always the white key just left of a group of two. Find that and you can find every other note.",
                demo: line([(0, 60, 4), (4, 62, 4), (8, 64, 4), (12, 67, 4)])),
        K.play("Play C, D, E and G", "Start on C, just left of the two black keys. Walk right to D and E, then skip F to land on G.",
               [60, 62, 64, 67], low: 55, high: 74),
        K.game(mazeName, mazeLine, .notes(keys, [
            NoteRound(title: "Find the landmark", body: "Find the white key just left of the two black keys. That's C. Its name appears when you find it.",
                      mode: .find([60], reveal: true)),
            NoteRound(title: "Step by step", body: "From C, walk right: C, then D, then E. Each name lights up after you land on it.",
                      mode: .find([60, 62, 64], reveal: true)),
            NoteRound(title: "Find home again", body: "A different stretch of keyboard, no letters. Find the C using the black keys.",
                      mode: .find([72], reveal: true), surface: .keyboard(low: 65, high: 83)),
        ])),
    ])

    static let f22Silver: [LessonStep] = [
        L.silver("Navigate by sound",
                 "The labels are fading, but the map is still there. First enter a four-note route in the piano roll. Then find notes by ear and follow directions with no letters at all."),
        K.teach("Names repeat",
                "After B the names start again at C, just higher. C, E, G and then C again, an octave up. Same name, higher room.",
                demo: line([(0, 60, 4), (4, 64, 4), (8, 67, 4), (12, 72, 4)])),
        K.leadCopy("Copy C, E, G, high C",
                   "Play the reference and enter the four notes. The last one is the same letter as the first, just higher.",
                   rows: rows, target: K.tune([(0, 60, 4), (4, 64, 4), (8, 67, 4), (12, 72, 4)]), backing: bed),
        K.game(mazeName, mazeLine, .notes(keys, [
            NoteRound(title: "Audio coordinates", body: "Hear C, E and G. Play them back. Start on C and use the map to find the others.",
                      mode: .echo([60, 64, 67], show: false, gapBars: 0), labels: false),
            NoteRound(title: "Two identical rooms", body: "There are two Cs here. You'll hear the low one, then the high one. Play them back in order.",
                      mode: .echo([60, 72], show: false, gapBars: 0), labels: false),
            NoteRound(title: "The landmark vanishes", body: "Start on C. Go two white keys right, then one left, then two right. Tap each stop.",
                      mode: .find([64, 62, 65], reveal: false), labels: false),
        ])),
    ]

    static let f22Gold: [LessonStep] = [
        L.gold("Design a keyboard route",
               "Design a route someone could hear instead of see. First write a five-note phrase in the piano roll. Then build a route across the keys, play it back by ear, and give it a new ending."),
        K.teach("Geography helps you write",
                "You don't need perfect fingers to write a tune. Knowing where C and G live is enough to build a phrase that goes somewhere.",
                demo: line([(0, 60, 3), (3, 62, 3), (6, 64, 3), (9, 65, 3), (12, 67, 4)])),
        K.leadMake("Write a five-note route",
                   "Start on C and write five notes. End on G or high C so it arrives somewhere.",
                   rows: rows, backing: bed, notes: 5, start: [NoteEvent(0, 60, 3)]),
        K.game(mazeName, "Build a route, then find it again by ear.", .notes(keys, [
            NoteRound(title: "Create a route", body: "Five stops. Start on C and end on G, A or high C. Each tap plays, so let it sing.",
                      mode: .compose(count: 5, start: 60, end: [67, 69, 72], shape: false)),
            NoteRound(title: "Challenge the route", body: "Your route plays with the lights off. Play it back from memory.",
                      mode: .retrace, labels: false),
            NoteRound(title: "Revise it", body: "Keep the first two stops, then take a new path to the end.",
                      mode: .answer(keep: 2)),
        ])),
    ]

    // MARK: - F2.3 Notes Have Distance → Interval Radar

    static let radarName = "Interval Radar"
    static let radarLine = "Two pings. Turn the dial until the distance matches."

    static let f23 = K.lesson("f2.3", "Notes Have Distance", "Repeats, steps and leaps", "ruler", .theory, 15, [
        K.opening("The space between notes",
                  "The distance between two notes has a sound of its own. First you'll measure it in the piano roll. Then you'll tune a radar until its two pings sound the right distance apart."),
        K.teach("Same, step, leap",
                "C then C again: no distance. C then D: a small step. C then G: a big leap. The bigger the gap, the more dramatic the jump.",
                demo: line([(0, 60, 2), (2, 60, 2), (4, 60, 2), (6, 62, 2), (8, 60, 2), (10, 67, 6)])),
        K.leadRule("Measure a leap",
                   "C is already on step 1. Put a G on step 5, seven semitones up. Then try D and E there and hear the distance shrink.",
                   rows: rows, target: K.tune([(0, 60, 4), (4, 67, 4)]), backing: bed, start: K.tune([(0, 60, 4)])),
        K.game(radarName, radarLine, .radar([
            RadarRound(title: "One point, two pings", body: "Both dots start together: same note. Drag the second dot out and round and hear the gap grow.",
                       mode: .grow),
            RadarRound(title: "Step or leap?", body: "Hear each pair, then drag the dot into SAME, NEAR or FAR and let go.",
                       mode: .zones([0, 2, 7])),
            RadarRound(title: "Match the sonar", body: "Hear the target. Turn the dial until your two pings sound the same distance apart.",
                       mode: .match(target: 3, choices: [0, 2, 3, 5, 7], direction: false)),
        ])),
    ])

    static let f23Silver: [LessonStep] = [
        L.silver("Calibrate the instrument",
                 "Your radar is losing its hints. First copy jumps up and down in the piano roll. Then match distances by ear, add direction, and lock two jumps in a row."),
        K.teach("Size and direction",
                "C up to G and C down to F are different moves, even though both are leaps. An interval has a size and a direction.",
                demo: line([(0, 60, 4), (4, 67, 4), (8, 72, 4), (12, 67, 4)])),
        K.leadCopy("Up, then down",
                   "Play the reference. It jumps up twice, then down once. Copy all four notes.",
                   rows: rows, target: K.tune([(0, 60, 4), (4, 64, 4), (8, 72, 4), (12, 67, 4)]), backing: bed),
        K.game(radarName, radarLine, .radar([
            RadarRound(title: "Blind distance", body: "Hear two notes. Is the gap 0, 2, 4 or 7? Turn the dial and compare.",
                       mode: .match(target: 4, choices: [0, 2, 4, 7], direction: false)),
            RadarRound(title: "Direction matters", body: "Now it can go down. Clockwise is up, counter-clockwise is down.",
                       mode: .match(target: -5, choices: [-7, -5, -2, 2, 5, 7], direction: true)),
            RadarRound(title: "Two-target radar", body: "A three-note phrase. Lock the first jump, then the second starts from where you landed.",
                       mode: .chain([4, -2])),
        ])),
    ]

    static let f23Gold: [LessonStep] = [
        L.gold("Make a leap memorable",
               "A memorable tune often starts with one distinctive jump. First write a three-note motif. Then pick your signature jump, build a motif round it, and answer it."),
        K.teach("Hooks repeat a jump",
                "Hear the same leap twice, then changed once. Repeating a jump makes it stick in your head.",
                demo: line([(0, 60, 2), (2, 67, 2), (4, 64, 4), (8, 60, 2), (10, 67, 2), (12, 69, 4)])),
        K.leadMake("Write a three-note motif",
                   "Start on C. Use one jump you like, then one more note to finish the idea.",
                   rows: rows, backing: bed, notes: 3, start: [NoteEvent(0, 60, 4)]),
        K.game(radarName, "Your jump, your motif, your answer.", .radar([
            RadarRound(title: "Pick a signature jump", body: "Four distances. Tap each to hear it open a melody, then keep the one you like.",
                       mode: .pick([2, 4, 7, 12])),
            RadarRound(title: "Build a motif", body: "Set two jumps from C. Up is clockwise, down is counter-clockwise. Your signature jump is loaded first.",
                       mode: .motif),
            RadarRound(title: "Make an echo", body: "Change one jump in your motif to answer it. Then hear question and answer together.",
                       mode: .reply),
        ])),
    ]

    // MARK: - F2.4 Stay in a Key → Harmonic Gravity

    static let gravityName = "Harmonic Gravity"
    static let gravityLine = "Notes orbit home. Feel the pull back to it."

    static let f24 = K.lesson("f2.4", "Stay in a Key", "Notes that belong together", "key.fill", .theory, 15, [
        K.opening("Every melody has a home",
                  "Most tunes have one note that feels like home, and the others pull towards it or away. First you'll see the C major notes in a piano roll. Then you'll steer through a constellation of notes and land back home."),
        K.teach("Home feels like rest",
                "The same phrase twice. Ending on C feels finished. Ending on D feels like it's still waiting for something.",
                demo: line([(0, 64, 2), (2, 67, 2), (4, 65, 2), (6, 60, 2), (8, 64, 2), (10, 67, 2), (12, 65, 2), (14, 62, 2)], over: drone)),
        K.leadRule("Bring it home",
                   "The last note is a D. Move it down to C on step 13 and hear the phrase settle over the drone.",
                   rows: rows, target: K.tune([(0, 60, 4), (4, 64, 4), (8, 67, 4), (12, 60, 4)]), backing: drone,
                   start: K.tune([(0, 60, 4), (4, 64, 4), (8, 67, 4), (12, 62, 4)])),
        K.game(gravityName, gravityLine, .notes(orbitC, [
            NoteRound(title: "Hear the gravity", body: "A phrase plays over a drone. Hear it end on C, then on D. Which one rests?",
                      mode: .ending(lead: [64, 67, 65, 62], options: [60, 62], answer: 60), backing: drone),
            NoteRound(title: "See the constellation", body: "Tap C, D, E, G, then back to C. Watch home glow when you land.",
                      mode: .find([60, 62, 64, 67, 60], reveal: false), backing: drone),
            NoteRound(title: "Guide a landing", body: "Watch the path light up, then fly it yourself and land on home.",
                      mode: .echo([67, 64, 62, 60], show: true, gapBars: 0), backing: drone),
        ])),
    ])

    static let f24Silver: [LessonStep] = [
        L.silver("Navigate with your ears",
                 "In-key notes are a palette, not a law. First match a phrase with one outside note in the piano roll. Then follow hidden routes, catch the note that steps outside, and hear home move."),
        K.teach("A note from outside",
                "Same phrase, but the F becomes F sharp. It isn't wrong, it's spicier. Composers do it on purpose.",
                demo: line([(0, 64, 4), (4, 65, 4), (8, 67, 4), (12, 64, 4)], over: drone)),
        K.leadCopy("Which F?",
                   "One note here is F sharp, outside the key. Play the reference and fix it to match, which here means plain F.",
                   rows: sharpRows, target: K.tune([(0, 64, 4), (4, 65, 4), (8, 67, 4), (12, 64, 4)]), backing: drone,
                   start: K.tune([(0, 64, 4), (4, 66, 4), (8, 67, 4), (12, 64, 4)])),
        K.game(gravityName, gravityLine, .notes(orbitC, [
            NoteRound(title: "Hidden waypoint", body: "Four notes, no lights. Play the route back.",
                      mode: .echo([60, 64, 62, 60], show: false, gapBars: 0), backing: drone),
            NoteRound(title: "Outside orbit", body: "Two versions. In the second, one note leaves the key. Which one?",
                      mode: .spot(a: [60, 64, 65, 67], b: [60, 64, 66, 67]), surface: orbitCOut, backing: drone),
            NoteRound(title: "Move the centre", body: "An A minor chord now. Home has moved to A. Play this phrase back and feel it land there.",
                      mode: .echo([69, 72, 71, 69], show: true, gapBars: 0), surface: orbitA, backing: amBed),
        ])),
    ]

    static let f24Gold: [LessonStep] = [
        L.gold("Write a homeward journey",
               "Write a short journey with a clear destination. First write a phrase that leaves home and comes back. Then chart routes round C and A, and try one detour outside the key."),
        K.teach("Leave, then return",
                "A melody can wander away and come back. One outside note on the way can make the return feel even better.",
                demo: line([(0, 60, 2), (2, 64, 2), (4, 69, 2), (6, 66, 2), (8, 67, 4), (12, 60, 4)], over: drone)),
        K.leadMake("Leave and return",
                   "Write five notes over the drone. Leave C, wander, and make the last note C again.",
                   rows: sharpRows, backing: drone, notes: 5),
        K.game(gravityName, "Chart a route that comes home.", .notes(orbitC, [
            NoteRound(title: "Home on C", body: "Five notes over a C drone. Use one small step and one leap, and end on C.",
                      mode: .compose(count: 5, start: nil, end: [60], shape: true), backing: drone),
            NoteRound(title: "Home on A", body: "Now home is A, over an A minor chord. Same rules: a step, a leap, and end on A.",
                      mode: .compose(count: 5, start: nil, end: [69], shape: true), surface: orbitA, backing: amBed),
            NoteRound(title: "Try a detour", body: "F sharp is unlocked, outside the key. Use it on the way if you like, then come home to C.",
                      mode: .compose(count: 5, start: nil, end: [60], shape: true), surface: orbitCOut, backing: drone),
        ])),
    ]

    // MARK: - F2.5 Copy a Melody → Echo Chase

    static let echoName = "Echo Chase"
    static let echoLine = "The echo plays in the dark. Chase it with your fingers."
    static let strip = NoteSurface.strip(lanes)

    static let f25 = K.lesson("f2.5", "Copy a Melody", "Boss: play it back by ear", "crown.fill", .theory, 30, [
        K.opening("Your ears remember",
                  "Your ears can hold a tune even when the notes vanish. First you'll write a three-note melody in a piano roll. Then you'll hear echoes in the dark and chase them back on five lanes."),
        K.teach("Pitch and rhythm",
                "Remembering a tune means remembering two things: which notes, and when. Two notes, then the same two with a gap. Hear the difference.",
                demo: line([(0, 60, 2), (2, 64, 2), (8, 60, 2), (12, 64, 2)])),
        K.leadCopy("Copy three notes",
                   "Play the reference: C, E, then D, one beat each. Put them in the piano roll.",
                   rows: rows, target: K.tune([(0, 60, 4), (4, 64, 4), (8, 62, 4)]), backing: bed),
        K.game(echoName, echoLine, .notes(strip, [
            NoteRound(title: "Two-note echo", body: "Hear two notes, then tap the lanes in the same order. Taller lanes are higher.",
                      mode: .echo([60, 67], show: true, gapBars: 0)),
            NoteRound(title: "Add a repeat", body: "Three notes, with one repeated. Catch them all.",
                      mode: .echo([60, 64, 64], show: true, gapBars: 0)),
            NoteRound(title: "Follow, then remember", body: "Four notes, in the dark this time. Replay it as often as you need.",
                      mode: .echo([60, 64, 67, 64], show: false, gapBars: 0)),
        ])),
    ])

    static let f25Silver: [LessonStep] = [
        L.silver("Hunt a moving echo",
                 "The echoes get quicker and harder to predict. First copy pitch and rhythm in the piano roll. Then catch a five-note phrase, spot a switched note, and hold a tune across a silent bar."),
        K.teach("Anchor notes",
                "C, D, E, D, C. The repeated notes are anchors: they help you hold the rest in your head.",
                demo: line([(0, 60, 4), (4, 62, 2), (6, 64, 2), (8, 62, 4), (12, 60, 4)])),
        K.leadCopy("Copy pitch and timing",
                   "Five notes, some long, some short. Play the reference and match both.",
                   rows: rows, target: K.tune([(0, 60, 4), (4, 62, 2), (6, 64, 2), (8, 62, 4), (12, 60, 4)]), backing: bed),
        K.game(echoName, echoLine, .notes(strip, [
            NoteRound(title: "Five in the dark", body: "Five notes with the lights off. Catch them all.",
                      mode: .echo([64, 67, 69, 67, 64], show: false, gapBars: 0), bpm: 96),
            NoteRound(title: "The switched note", body: "Two phrases, one note different. Which one changed?",
                      mode: .spot(a: [60, 64, 67, 64], b: [60, 64, 69, 64])),
            NoteRound(title: "Call across the gap", body: "Hear it, then hold it through a silent bar before you play it back.",
                      mode: .echo([62, 64, 67, 62], show: false, gapBars: 1)),
        ])),
    ]

    static let f25Gold: [LessonStep] = [
        L.gold("Become the echo",
               "Now you start the conversation. First write a call and answer in the piano roll. Then play your own call on the lanes, answer it, and hear the two together."),
        K.teach("Question and answer",
                "The answer keeps the start of the question and changes the end. Same opening, new destination.",
                demo: line([(0, 60, 2), (2, 64, 2), (4, 67, 2), (6, 64, 2), (8, 60, 2), (10, 64, 2), (12, 62, 2), (14, 60, 2)])),
        K.leadMake("Write a call and answer",
                   "Write six notes or more: a short call, then an answer that starts the same way and ends differently.",
                   rows: rows, backing: bed, notes: 6),
        K.game(echoName, "You call, you answer.", .notes(strip, [
            NoteRound(title: "Record a call", body: "Play any four notes on the lanes. That's your call.",
                      mode: .compose(count: 4, start: nil, end: [], shape: false), backing: softBeat),
            NoteRound(title: "Record an answer", body: "Your call plays first. Answer with four notes that start with the same two, then change the ending.",
                      mode: .answer(keep: 2), backing: softBeat),
            NoteRound(title: "Play the conversation", body: "Call, answer, call, answer. Eight notes of your own.",
                      mode: .duet, backing: softBeat),
        ])),
    ]

    static let levels: [String: LevelPair] = [
        "f2.1": (silver: f21Silver, gold: f21Gold),
        "f2.2": (silver: f22Silver, gold: f22Gold),
        "f2.3": (silver: f23Silver, gold: f23Gold),
        "f2.4": (silver: f24Silver, gold: f24Gold),
        "f2.5": (silver: f25Silver, gold: f25Gold),
    ]
}
