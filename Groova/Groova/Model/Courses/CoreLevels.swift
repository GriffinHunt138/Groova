//
//  CoreLevels.swift
//  Groova
//
//  Hand-written Silver and Gold levels for the Core Foundations lessons that used to get
//  generated ones. Each level teaches one new idea (named on its opening card) and mixes
//  activities: quick checks, listening, guided steps, copying by ear, fixing mistakes and
//  writing your own. Silver applies the idea somewhere new; Gold uses it in a full loop.
//

import Foundation

nonisolated enum CoreLevels {
    typealias C = CoreCourse
    typealias H = HouseCourse

    static let rows = Curriculum.bassRows
    static let mel = HouseCourse.melodyRows
    static let bed = HouseCourse.melodyBed
    static let beat = Curriculum.fourFloor
    static let drums = C.drums
    static let full = C.full
    static let kickHats = C.kickHats
    static let drumsBass = C.drumsBass
    static let fill = C.fill
    static let evens = C.evens
    static let sixteenths = C.sixteenths
    static let all5: [DrumTrack] = [.kick, .clap, .hat, .openHat, .perc]
    static let five = ["Intro", "Build", "Drop", "Break", "Drop 2"]
    static let twoPeaks = ["Intro", "Drop", "Break", "Drop 2"]
    static let f = ChordShape(name: "F", pitches: [53, 57, 60])
    static let g = ChordShape(name: "G", pitches: [55, 59, 62])

    static let noBass = full.keeping([.kick, .clap, .hat], bass: false, chords: true)
    static let noDrums = full.keeping([], bass: true, chords: true)
    static let noChords = full.keeping([.kick, .clap, .hat], bass: true, chords: false)
    static let noKick = full.keeping([.clap, .hat], bass: true, chords: true)
    static let fullRim = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [7, 15],
                                 bass: H.bassline, chords: H.stabs)
    static let fullOpen = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], openHat: [2, 6, 10, 14],
                                  bass: H.bassline, chords: H.stabs)
    static let stop = Pattern(kick: [0, 4, 8], clap: [4], hat: [2, 6, 10])
    static let halfTime = Pattern(kick: [0, 10], clap: [8], hat: [2, 6, 10, 14])
    static let allOn4 = K.grid("xxxx", "xxxx", "xxxx", "xxxx", "xxxx")
    static let allOn5 = K.grid("xxxxx", "xxxxx", "xxxxx", "xxxxx", "xxxxx")

    static let all: [String: LevelPair] = [
        "core.u1.l1": u1l1, "core.u1.l2": u1l2, "core.u1.l3": u1l3, "core.u1.l4": u1l4, "core.u1.l5": u1l5,
        "core.u2.l1": u2l1, "core.u2.l2": u2l2,
        "core.u3.l1": u3l1, "core.u3.l2": u3l2, "core.u3.l3": u3l3, "core.u3.l4": u3l4,
        "core.u4.l1": u4l1, "core.u4.l2": u4l2, "core.u4.l3": u4l3, "house.mel.l1": mel1, "core.u4.l5": u4l5,
        "core.u5.l4": u5l4,
        "core.u6.l1": u6l1, "core.u6.l2": u6l2,
        "core.u7.l1": u7l1, "core.u7.l2": u7l2, "core.u7.l3": u7l3, "core.u7.l5": u7l5,
        "core.u8.l2": u8l2, "core.u8.l3": u8l3, "core.u8.l4": u8l4, "core.u8.l5": u8l5,
    ]

    // MARK: - Unit 1: Welcome to Production

    static let u1l1: LevelPair = (
        silver: [
            L.silver("every layer has a job",
                     "Drums keep time, the bass fills the low end and moves the groove, and chords set the mood. Take one away and you feel the hole it leaves. Learn to hear what's missing, then add two layers yourself."),
            K.quiz("What's missing?", "The full loop plays without one layer. Which one is gone?", [
                K.hear([noBass], ["Drums", "Bass", "Chords"], 1, "No bass: the bottom of the track feels empty."),
                K.hear([noDrums], ["Drums", "Bass", "Chords"], 0, "No drums: nothing keeps time, nothing to dance to."),
                K.hear([noChords], ["Drums", "Bass", "Chords"], 2, "No chords: it grooves, but there's no mood on top."),
            ]),
            K.quiz("Which layer does that job?", "Match each job to the layer that does it.", [
                K.ask("Which layer sets the mood: happy, dark or dreamy?", ["Drums", "Bass", "Chords"], 2,
                      "Chords carry the harmony, and harmony is mood."),
                K.ask("Which layer gives you something to dance to?", ["Drums", "Bass", "Chords"], 0,
                      "The kick and clap are the pulse your body locks onto."),
                K.ask("The track sounds thin on big speakers. What's missing?", ["Drums", "Bass", "Chords"], 1,
                      "The bass fills the low end you feel in your chest."),
            ]),
            K.drumMake("Add the hats", "The kick and clap are there. Put at least four hats wherever they help the beat keep time.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       goal: .atLeast(.hat, 4)),
            K.bassMake("Add the low end", "Place at least three bass notes. Try them between the kicks.",
                       rows: rows, backing: drums, notes: 3),
        ],
        gold: [
            L.gold("build a loop in layers",
                   "Producers build a loop one layer at a time and listen after each one: does this layer add something the others don't? Count layers by ear, then build drums, bass and chords from nothing."),
            K.quiz("How many layers?", "Count the layers: drums, bass and chords.", [
                K.hear([drums], ["One", "Two", "Three"], 0, "Just drums."),
                K.hear([full], ["One", "Two", "Three"], 2, "Drums, bass and chords."),
                K.hear([drumsBass], ["One", "Two", "Three"], 1, "Drums and bass."),
                K.hear([noDrums], ["One", "Two", "Three"], 1, "Bass and chords, no drums."),
            ]),
            K.drumMake("Layer one: drums", "Kick, clap and hats from silence. At least four kicks.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], goal: .atLeast(.kick, 4)),
            K.bassMake("Layer two: bass", "At least four notes that leave room for the kick.", rows: rows, backing: drums, notes: 4),
            K.lane("Layer three: chords", "Place at least two chords to set the mood. Am7 is moody, Dm7 is softer.",
                   .create(.chordsAtLeast(2)), palette: [.am7, .dm7], backing: drumsBass, length: 4),
        ])

    static let u1l2: LevelPair = (
        silver: [
            L.silver("hear what leaves",
                     "Changes go both ways. Tracks pull parts out as often as they add them, and a part leaving is harder to notice. Listen for what disappears, and for tiny changes inside a part."),
            K.quiz("What dropped out?", "Two bars. Something is missing from the second. What?", [
                K.hear([full, full.keeping([.kick, .clap], bass: true, chords: true)], ["Hats", "Bass", "Kick"], 0,
                       "The hats went, and the groove lost its tick."),
                K.hear([full, noBass], ["Chords", "Bass", "Clap"], 1, "The bass left. The bottom fell out."),
                K.hear([drums, kickHats], ["Clap", "Hats", "Kick"], 0, "No clap on beats 2 and 4."),
                K.hear([full, noChords], ["Chords", "Hats", "Bass"], 0),
            ]),
            K.quiz("Same or different?", "Two bars. Are they exactly the same? Listen to every part.", [
                K.hear([drums, drums], ["Same", "Different"], 0, "Identical."),
                K.hear([drums, Pattern(kick: [0, 4, 8, 12, 14], clap: [4, 12], hat: [2, 6, 10, 14])], ["Same", "Different"], 1,
                       "An extra kick near the end of bar 2."),
                K.hear([drumsBass, drumsBass], ["Same", "Different"], 0),
                K.hear([drums, Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14, 15])], ["Same", "Different"], 1,
                       "One extra hat right at the end."),
            ]),
            K.arrange("Recreate what you hear", "Four sections this time. Listen to each and switch on what's playing.", .recreate,
                      sections: ["First", "Second", "Third", "Fourth"],
                      lanes: [.drum(.kick), .drum(.clap), .drum(.hat), .bass], loop: full,
                      target: K.grid("xxx-", "-xx-", "xxxx", "-xxx")),
        ],
        gold: [
            L.gold("follow one part",
                   "Pros listen to a track several times, following a different part each time. Track one part through four bars, then copy a groove down to the last hat."),
            K.quiz("Follow one part", "Four bars play. Keep your ears on one part.", [
                K.hear([kickHats, drums, drumsBass, full], ["Bar 2", "Bar 3", "Bar 4"], 1, "Bar 3: drums first, then the bass.",
                       question: "When does the bass come in?"),
                K.hear([full, full, noKick, full], ["Bar 2", "Bar 3", "Bar 4"], 1, "Bar 3 drops the kick for one bar.",
                       question: "When does the kick drop out?"),
                K.hear([drums, drumsBass, full, drumsBass], ["Bar 2 only", "Bar 3 only", "Bars 3 and 4"], 1,
                       question: "When do the chords play?"),
            ]),
            L.copy("Copy every detail", "Kick, clap and hats. One hat is extra. Find it.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14, 15]), threshold: 0.9),
            K.arrange("Map a whole track", "Five parts, four sections. Follow one part at a time across the sections.", .recreate,
                      loop: full, target: K.grid("-xxx", "--xx", "xxx-", "-x-x", "x-xx")),
        ])

    static let u1l3: LevelPair = (
        silver: [
            L.silver("tempo and genre",
                     "Every genre has a home tempo. Deep house sits around 120, house and tech house 122 to 128, UK garage around 132, and techno 130 and up. Learn to feel those speeds, then find one by ear."),
            K.quiz("Tempo and genre", "Answer from what you know, then from what you hear.", [
                K.ask("A track at 140 BPM is most likely…", ["Deep house", "Techno", "Hip-hop"], 1, "Techno runs fast: 130 and up."),
                K.ask("Deep house usually sits around…", ["90 BPM", "120 BPM", "150 BPM"], 1, "Slow and warm, around 120."),
                K.hear([drums], ["Around 120", "Around 140"], 1, "That's 140: techno speed.", bpm: 140,
                       question: "How fast is this?"),
                K.hear([drums], ["Around 120", "Around 140"], 0, "Around 120: deep house speed.", bpm: 120,
                       question: "How fast is this?"),
            ]),
            K.tempo("Set the deep house tempo", "Set it to 120 BPM.", loop: drums, target: 120, start: 140),
            K.tempoByEar("Find this tempo by ear", "Play the reference, then tap along or drag until your loop locks in.",
                         loop: drums, target: 136, start: 110),
        ],
        gold: [
            L.gold("half-time",
                   "The same tempo can feel twice as slow. Put the clap on beat 3 instead of 2 and 4, and a 140 BPM beat feels like 70. That's half-time. Hear it, then find tempos within 2 BPM."),
            K.quiz("Normal or half-time?", "Same tempo every round. Does it feel normal, or half as fast?", [
                K.hear([drums], ["Normal", "Half-time"], 0, bpm: 130),
                K.hear([halfTime], ["Normal", "Half-time"], 1, "The clap moved to beat 3, so it feels half as fast.", bpm: 130),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: sixteenths)], ["Normal", "Half-time"], 0, bpm: 130),
                K.hear([Pattern(kick: [0], clap: [8], hat: evens)], ["Normal", "Half-time"], 1, bpm: 130),
            ]),
            K.tempoByEar("Find this tempo within 2 BPM", "Tap along with the kick, then fine-tune with the buttons.",
                         loop: drums, target: 127, start: 100, tolerance: 2),
            K.tempoByEar("Find the half-time tempo", "It feels slow, but the hats tell the truth. Match the real tempo.",
                         loop: halfTime, target: 140, start: 110, tolerance: 2),
            K.quiz("Choose the tempo", "", [
                K.ask("Your loop is at 124 and feels too relaxed for techno. What do you change?",
                      ["Raise the tempo", "Lower the tempo", "Add reverb"], 0, "Techno wants 130 or more."),
                K.ask("A 140 BPM track with the clap on beat 3 feels like…", ["70 BPM", "140 BPM", "280 BPM"], 0,
                      "Half-time halves the feel, not the tempo."),
            ]),
        ])

    static let hatsEnd = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14, 15])

    static let u1l4: LevelPair = (
        silver: [
            L.silver("the turnaround",
                     "One bar is four beats of four steps: 16 steps. Two-bar loops usually change something in the second bar to keep the ear interested. That change is called a turnaround."),
            K.quiz("Count it out", "", [
                K.ask("How many steps make one bar?", ["4", "8", "16"], 2, "Four beats of four steps."),
                K.ask("Beat 3 starts on which step?", ["5", "9", "13"], 1, "Steps 1, 5, 9 and 13 are beats 1 to 4."),
                K.hear([drums, hatsEnd, drums, hatsEnd], ["1 bar", "2 bars", "4 bars"], 1, "The extra hat comes every second bar.",
                       question: "How long is the loop?"),
            ]),
            K.drumRule("Build a one-bar loop", "Kicks on steps 1, 5, 9 and 13. Hats on 3, 7, 11 and 15.",
                       tracks: [.kick, .hat], edit: [.kick, .hat], target: kickHats),
            K.drumCopy("Copy the turnaround bar", "This is bar 2 of a two-bar loop. Claps on 2 and 4, plus two quick claps at the very end.",
                       tracks: [.kick, .clap, .hat], edit: [.clap], start: kickHats,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 14, 15], hat: [2, 6, 10, 14])),
        ],
        gold: [
            L.gold("loops become phrases",
                   "Four bars make a phrase. The first three set up the idea and bar 4 changes it, often with a fill, telling the listener the loop is about to start again."),
            K.quiz("When does it repeat?", "Listen for the bar that changes, then count.", [
                K.hear([drums, drums, drums, fill, drums, drums, drums, fill], ["Every 2 bars", "Every 4 bars", "Every 8 bars"], 1,
                       "The fill ends every fourth bar."),
                K.hear([drums, fill, drums, fill], ["Every 2 bars", "Every 4 bars", "Every 8 bars"], 0),
                K.hear([drums, drums, drums, drums, drums, drums, drums, fill], ["Every 2 bars", "Every 4 bars", "Every 8 bars"], 2,
                       "Seven plain bars, then the fill."),
            ]),
            L.copy("Copy the bar-4 fill", "The kick skips the last beat, and the claps roll through it.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap], start: Pattern(hat: [2, 6, 10, 14]),
                   target: Pattern(kick: [0, 4, 8], clap: [4, 12, 13, 14, 15], hat: [2, 6, 10, 14])),
            L.make("Write your own bar-4 fill", "Change only the last beat, steps 13 to 16. Use at least four claps.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], start: drums, goal: .atLeast(.clap, 4)),
        ])

    static let u1l5: LevelPair = (
        silver: [
            L.silver("the right tool for the job",
                     "Each tool does one job. The grid places drums, the piano roll writes notes, the keys play chords, the knobs shape a sound and the faders set levels. Pick the right one, then use it."),
            K.quiz("Which tool?", "", [
                K.ask("You want claps on beats 2 and 4.", ["Drum grid", "Piano roll", "Knobs"], 0),
                K.ask("You want to write a bassline.", ["Drum grid", "Piano roll", "Faders"], 1),
                K.ask("The bass sounds too bright.", ["Piano roll", "Knobs", "Drum grid"], 1, "Turn its cutoff down."),
                K.ask("The hats are too loud.", ["Faders", "Keys", "Piano roll"], 0),
            ]),
            K.drumRule("Grid: claps on 2 and 4", "Steps 5 and 13.", tracks: [.kick, .clap], edit: [.clap], start: beat,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12])),
            K.play("Keys: play E minor", "E, G and B, one after another.", [64, 67, 71], low: 60, high: 72),
            K.lab("Knobs: make the bass dark", "Turn Cutoff down until the bass sounds muffled and round.",
                  [.bassCutoff], start: [0.7], target: [0.15], loop: H.bassLoop),
        ],
        gold: [
            L.gold("a loop with every tool",
                   "Real sessions jump between tools. Write a beat, add a bassline, shape its sound, then balance the levels. Every step is yours."),
            K.drumMake("Write the beat", "Kick, clap and hats. At least four hats.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], start: beat, goal: .atLeast(.hat, 4)),
            K.bassMake("Write the bass", "At least four notes.", rows: rows, backing: drums, notes: 4),
            K.lab("Shape the bass", "Cutoff and Envelope. Find a tone you like.", [.bassCutoff, .bassEnv], start: [0.3, 0.2],
                  loop: H.bassLoop),
            K.mix("Set the levels", "Bring each fader to where it sounds right. Start with the kick.",
                  [.drum(.kick), .drum(.clap), .drum(.hat), .bass], start: [0.3, 0.3, 0.3, 0.3], loop: drumsBass),
        ])

    // MARK: - Unit 2: Rhythm Basics

    static let u2l1: LevelPair = (
        silver: [
            L.silver("1 e and a",
                     "Each beat splits into four steps, counted 1, e, and, a. The 'and' sits halfway through the beat. Counting this way lets you place any hit exactly."),
            K.quiz("Count the steps", "", [
                K.ask("Which step is beat 4?", ["9", "13", "16"], 1),
                K.ask("Which step is the 'and' of beat 1?", ["2", "3", "5"], 1, "1 is step 1, e is 2, and is 3, a is 4."),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [6])], ["On beat 2", "The 'and' of beat 2", "On beat 3"], 1,
                       "Halfway between beats 2 and 3.", question: "Where's the clap?"),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [0])], ["On beat 1", "On beat 2", "On beat 4"], 0,
                       question: "Where's the clap?"),
            ]),
            K.drumRule("Kick on 1 and 3, clap on 2 and 4", "Kicks on steps 1 and 9, claps on 5 and 13.",
                       tracks: [.kick, .clap], edit: [.kick, .clap], target: Pattern(kick: [0, 8], clap: [4, 12])),
            K.drumRule("Hit every 'and'", "Hats on the 'and' of every beat: steps 3, 7, 11 and 15.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 8], clap: [4, 12]),
                       target: Pattern(kick: [0, 8], clap: [4, 12], hat: [2, 6, 10, 14])),
        ],
        gold: [
            L.gold("count anything",
                   "With 1 e and a you can count any rhythm and write it down. Count hits by ear, then place them with no beat guide."),
            K.quiz("How many claps?", "Count the claps in one bar.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12])], ["2", "3", "4"], 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 15])], ["2", "3", "4"], 1, "Two on the backbeat, one at the end."),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 7, 12, 15])], ["2", "3", "4"], 2),
            ]),
            L.copy("Copy the kick and clap", "No beat guide now. Count 1 e and a as it plays.",
                   tracks: [.kick, .clap], edit: [.kick, .clap], target: Pattern(kick: [0, 8, 10], clap: [4, 12]), threshold: 0.9),
            L.copy("Copy the rims on the 'a'", "Each rim lands on the last step of a beat, the 'a'.",
                   tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 7, 15]), threshold: 0.9),
        ])

    static let u2l2: LevelPair = (
        silver: [
            L.silver("drums in a groove",
                     "Picking out a drum on its own is easy. In a groove they overlap. Listen for each one's character: the kick's thump, the clap's snap, the hat's tick, the open hat's hiss and the rim's knock."),
            K.quiz("What's on the offbeats?", "The kick plays every beat. Another drum fills the offbeats. Which one?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], openHat: [2, 6, 10, 14])], ["Hi-hat", "Open hat", "Rim"], 1,
                       "Long and hissy: the open hat."),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14])], ["Hi-hat", "Open hat", "Rim"], 0,
                       "Short and bright: the closed hat."),
                K.hear([Pattern(kick: [0, 4, 8, 12], perc: [2, 6, 10, 14])], ["Hi-hat", "Open hat", "Rim"], 2,
                       "Woody and knocking: the rim."),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [2, 6, 10, 14])], ["Clap", "Rim", "Open hat"], 0),
            ]),
            K.drumCopy("Rebuild this kit", "Kick on the beats, claps on 2 and 4, open hats on the offbeats.",
                       tracks: [.kick, .clap, .openHat], edit: [.clap, .openHat], start: beat,
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14])),
            K.drumMake("Give every drum a job", "Use all five drums. At least two rims.",
                       tracks: all5, edit: Set(all5), start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       goal: .atLeast(.perc, 2)),
        ],
        gold: [
            L.gold("drums in a full track",
                   "Bass and chords hide the drums. Pick them out of a full loop, then rebuild a five-piece kit with no guide."),
            K.quiz("What joined the groove?", "Two bars of the full loop. A drum joins on the second. Which?", [
                K.hear([full, fullRim], ["Rim", "Open hat", "Clap"], 0),
                K.hear([full, fullOpen], ["Rim", "Open hat", "Hi-hat"], 1),
                K.hear([full.keeping([.kick, .hat], bass: true, chords: true), full], ["Clap", "Kick", "Rim"], 0),
            ]),
            L.copy("Rebuild the five-piece kit", "Kick, clap, closed hats just after each kick, open hats on the offbeats, and two rims.",
                   tracks: all5, edit: Set(all5),
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13], openHat: [2, 6, 10, 14], perc: [7, 15]),
                   threshold: 0.9),
            L.make("Make it yours", "A groove with all five drums. At least two open hats.",
                   tracks: all5, edit: Set(all5), goal: .atLeast(.openHat, 2)),
        ])

    // MARK: - Unit 3: Groove & Feel

    static let u3l1: LevelPair = (
        silver: [
            L.silver("stacked subdivisions",
                     "Grooves stack subdivisions: the kick plays quarters, the hats eighths, and a rim or shaker runs sixteenths. Each layer splits the beat finer than the one below it."),
            K.quiz("Which part plays sixteenths?", "Three drums, three speeds. Which is the fastest?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: evens, perc: sixteenths)], ["Kick", "Hi-hat", "Rim"], 2,
                       "The rim ticks on every step."),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: sixteenths, perc: [2, 6, 10, 14])], ["Kick", "Hi-hat", "Rim"], 1),
                K.ask("Quarters, eighths, sixteenths: how many hits per beat is each?", ["1, 2, 4", "1, 3, 6", "2, 4, 8"], 0),
            ]),
            K.drumRule("Sixteenths around the kick", "Hats on every step except where the kick plays: leave 1, 5, 9 and 13 empty.",
                       tracks: [.kick, .hat], edit: [.hat], start: beat,
                       target: Pattern(kick: [0, 4, 8, 12], hat: [1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15])),
            K.drumCopy("Eighths with a pickup", "Eighth-note hats, plus one sixteenth at the very end that leads back to the top.",
                       tracks: [.kick, .hat], edit: [.hat], start: beat, target: Pattern(kick: [0, 4, 8, 12], hat: evens + [15])),
        ],
        gold: [
            L.gold("subdivision is energy",
                   "Switching the hats from eighths to sixteenths lifts the energy without adding a new part. Producers do it going into a drop. Hear it, copy it, then write a build bar."),
            K.quiz("What changed in bar 2?", "", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: evens), Pattern(kick: [0, 4, 8, 12], hat: sixteenths)],
                       ["Hats got faster", "Hats got slower", "The kick changed"], 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: sixteenths), Pattern(kick: [0, 4, 8, 12], hat: [0, 4, 8, 12])],
                       ["Hats got faster", "Hats got slower", "The kick changed"], 1, "Sixteenths down to quarters: the energy drops."),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: evens), Pattern(kick: evens, hat: evens)],
                       ["Hats got faster", "Hats got slower", "The kick changed"], 2, "The kick doubled up to eighths."),
            ]),
            L.copy("Copy the groove", "Kick on the beats, open hats on the offbeats, and closed hats on the sixteenths with a gap.",
                   tracks: [.kick, .hat, .openHat], edit: [.kick, .hat, .openHat],
                   target: Pattern(kick: [0, 4, 8, 12], hat: [1, 3, 5, 7, 9, 11, 13, 14, 15], openHat: [2, 6, 10, 14])),
            L.make("Write a build bar", "Lift the energy with sixteenth hats. At least 12 hats.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                   goal: .atLeast(.hat, 12)),
        ])

    static let u3l2: LevelPair = (
        silver: [
            L.silver("offbeat bass",
                     "Offbeats aren't just for hats. Put the bass on the offbeat and it dodges every kick, so the two never fight. That's the bounce of house."),
            K.quiz("On or off?", "", [
                K.ask("Which steps are the offbeats?", ["1, 5, 9 and 13", "3, 7, 11 and 15", "2, 4, 6 and 8"], 1),
                K.hear([Pattern(kick: [0, 4, 8, 12], bass: K.notes(33, [0, 4, 8, 12]))], ["On the beat", "Off the beat"], 0,
                       "Bass and kick hit together.", question: "Where's the bass?"),
                K.hear([Pattern(kick: [0, 4, 8, 12], bass: K.notes(33, [2, 6, 10, 14]))], ["On the beat", "Off the beat"], 1,
                       "It bounces between the kicks.", question: "Where's the bass?"),
            ]),
            K.bassRule("Bass on every offbeat", "Low A, the bottom row, on steps 3, 7, 11 and 15.",
                       rows: rows, target: K.notes(33, [2, 6, 10, 14]), backing: drums),
            K.bassCopy("Copy the offbeat bass", "Offbeats only, but the notes move: A, A, C, then D.",
                       rows: rows, target: L.n([(2, 33), (6, 33), (10, 36), (14, 38)]), backing: drums),
        ],
        gold: [
            L.gold("the on-off engine",
                   "The engine of house: kick and clap on the beat, hats and bass off it. Every part knows its place, so nothing collides. Rebuild it from silence, then fix a bassline that crashes into the kick."),
            L.copy("Rebuild the drums", "Kick on every beat, clap on 2 and 4, open hats on every offbeat.",
                   tracks: [.kick, .clap, .openHat], edit: [.kick, .clap, .openHat],
                   target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14]), threshold: 0.9),
            L.bass("Add the offbeat bass", "Offbeats with an octave jump: low A, high A, low A, then G.",
                   L.n([(2, 33), (6, 45), (10, 33), (14, 43)]),
                   backing: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14])),
            K.fixNotes("Fix the collision", "Two notes land right on a kick. Move them to the offbeats so the bass bounces again.",
                       rows: rows, broken: L.n([(2, 33), (4, 33), (10, 33), (12, 40)]),
                       target: L.n([(2, 33), (6, 33), (10, 33), (14, 40)]), backing: drums),
        ])

    static let u3l3: LevelPair = (
        silver: [
            L.silver("syncopation in any part",
                     "Any part can syncopate: a clap that lands early, a rim that dodges the beat, a kick that skips. Hear which part breaks the pattern, then loosen a groove that's too stiff."),
            K.quiz("Which part is syncopated?", "One part dodges the beat. Which?", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 11, 12])], ["Kick", "Clap"], 1, "A clap sneaks in just before beat 4."),
                K.hear([Pattern(kick: [0, 6, 10], clap: [4, 12])], ["Kick", "Clap"], 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 6, 11, 14])], ["Clap", "Rim"], 1,
                       "Every rim lands between the beats."),
            ]),
            K.drumCopy("Copy the syncopated rims", "Four rims, none of them on a beat.",
                       tracks: [.kick, .clap, .perc], edit: [.perc], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], perc: [3, 6, 11, 14])),
            K.fix("Loosen the stiff kick", "This kick is too square. Two kicks should land just before beats 2 and 4, not on them.",
                  tracks: [.kick, .clap, .hat], edit: [.kick], broken: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: evens),
                  target: Pattern(kick: [0, 3, 8, 11], clap: [4, 12], hat: evens)),
        ],
        gold: [
            L.gold("syncopated bass",
                   "Syncopation hits hardest in the bass. Notes that land just before the beat pull the groove forward. Hear it, copy it, then write your own."),
            K.quiz("Straight or syncopated?", "Listen to the bass against the kick.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], bass: L.n([(0, 33), (4, 33), (8, 36), (12, 33)]))], ["Straight", "Syncopated"], 0),
                K.hear([Pattern(kick: [0, 4, 8, 12], bass: L.n([(0, 33), (3, 33), (6, 36), (11, 33), (14, 40)]))],
                       ["Straight", "Syncopated"], 1),
                K.hear([Pattern(kick: [0, 4, 8, 12], bass: L.n([(2, 33), (7, 36), (10, 33), (13, 40)]))], ["Straight", "Syncopated"], 1),
            ]),
            L.bass("Copy the syncopated bassline", "Five notes. Only the first lands on a kick.",
                   L.n([(0, 33), (3, 33), (6, 36), (10, 33), (13, 40)]), backing: drums, threshold: 0.9),
            L.bassMake("Make it yours", "A bassline with at least five notes, mostly off the beat.", backing: drums, notes: 5),
        ])

    static let swingHats = Pattern(kick: [0, 4, 8, 12], hat: sixteenths)

    static let u3l4: LevelPair = (
        silver: [
            L.silver("how much swing",
                     "Swing is a dial, not a switch. Techno stays straight, house uses a touch, and UK garage swings hard. The amount of swing tells you the genre before anything else does."),
            K.quiz("Which genre's swing?", "Same hats every time. How much do they swing?", [
                K.hear([swingHats], ["Techno: straight", "House: a touch", "Garage: heavy"], 0, swing: 0),
                K.hear([swingHats], ["Techno: straight", "House: a touch", "Garage: heavy"], 2, swing: 0.32),
                K.hear([swingHats], ["Techno: straight", "House: a touch", "Garage: heavy"], 1, swing: 0.12),
                K.ask("Swing moves which notes?", ["Every beat", "Every other sixteenth", "Only the kick"], 1,
                      "The in-between sixteenths get pushed late."),
            ]),
            K.swingMake("Swing it like garage", "Push it past 25% until the hats skip.", tracks: [.kick, .clap, .hat],
                        start: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15]), atLeast: 0.25),
        ],
        gold: [
            L.gold("swing needs sixteenths",
                   "Swing only moves the in-between sixteenths. A beat with only eighths barely changes when you swing it. For swing to show, a part has to play those in-between steps."),
            K.quiz("Does swing change it?", "The same swing amount every round.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: evens)], ["Sounds straight", "Sounds swung"], 0,
                       "Only eighths: there's nothing for swing to move.", swing: 0.3),
                K.hear([swingHats], ["Sounds straight", "Sounds swung"], 1, swing: 0.3),
                K.hear([Pattern(kick: [0, 4, 8, 12], hat: evens, perc: [3, 7, 11, 15])], ["Sounds straight", "Sounds swung"], 1,
                       "The rims sit on in-between steps, so they swing.", swing: 0.3),
            ]),
            K.drumMake("Write hats that can swing", "Use the in-between steps (2, 4, 6 and so on) so swing has something to move. At least eight hats.",
                       tracks: [.kick, .clap, .hat], edit: [.hat], start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12]),
                       goal: .atLeast(.hat, 8)),
            K.swingMake("Now swing it", "Rims on the in-between steps. Push swing past 20%.",
                        tracks: [.kick, .clap, .hat, .perc],
                        start: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: evens, perc: [3, 7, 11, 13, 15]), atLeast: 0.2),
        ])

    // MARK: - Unit 4: Notes & Melody

    static let u4l1: LevelPair = (
        silver: [
            L.silver("black keys",
                     "The black keys sit between the white ones, and each has two names. The black key above C is C sharp (C♯), and it's also D flat (D♭). Sharp means one key up, flat means one key down."),
            K.play("Play C, C♯ and D", "White, black, white: three keys in a row.", [60, 61, 62], low: 55, high: 67),
            K.quiz("Name the keys", "", [
                K.ask("The black key just above C is…", ["C♯", "D♯", "B♭"], 0),
                K.ask("D♭ is the same key as…", ["C♯", "D♯", "E"], 0, "One key down from D is one key up from C."),
                K.ask("Which white key sits just left of the group of three black keys?", ["C", "F", "A"], 1),
            ]),
            K.quiz("Higher or lower?", "Neighbouring keys this time. Listen carefully.", [
                K.round(K.phrase([60, 61]), ["Higher", "Lower"], 0),
                K.round(K.phrase([64, 63]), ["Higher", "Lower"], 1),
                K.round(K.phrase([67, 68]), ["Higher", "Lower"], 0),
                K.round(K.phrase([62, 61]), ["Higher", "Lower"], 1),
            ]),
            K.play("Play F, G, A and B", "The white keys next to the group of three black keys.", [65, 67, 69, 71], low: 60, high: 72),
        ],
        gold: [
            L.gold("from keys to the piano roll",
                   "The piano roll is the keyboard turned on its side: higher rows are higher keys. Play a tune, train your ear on single notes, then write phrases on the roll by ear."),
            K.play("Play this tune", "E, E, F, G, G, F, E, D. You might know it.", [64, 64, 65, 67, 67, 65, 64, 62], low: 60, high: 72),
            K.quiz("Same or different?", "Two notes. The same note twice, or two different ones?", [
                K.round(K.phrase([62, 62]), ["Same", "Different"], 0),
                K.round(K.phrase([62, 63]), ["Same", "Different"], 1, "One key apart."),
                K.round(K.phrase([67, 67]), ["Same", "Different"], 0),
                K.round(K.phrase([60, 59]), ["Same", "Different"], 1),
            ]),
            K.leadCopy("Write it on the roll", "Three notes going up: C, D, E. Find each one's row.",
                       rows: mel, target: K.line([(0, 60), (4, 62), (8, 64)]), backing: bed),
            K.leadCopy("Copy a falling phrase", "Four notes stepping down from the top.",
                       rows: mel, target: K.line([(0, 69), (2, 67), (4, 64), (8, 62)]), backing: bed),
        ])

    static let u4l2: LevelPair = (
        silver: [
            L.silver("tones and semitones",
                     "A semitone is one key to the very next. A tone is two semitones. There's no black key between E and F, or between B and C, so those white keys are only a semitone apart."),
            K.quiz("Tone or semitone?", "", [
                K.ask("From E to F is…", ["A semitone", "A tone"], 0, "No black key between them."),
                K.ask("From C to D is…", ["A semitone", "A tone"], 1, "C♯ sits in between."),
                K.round(K.phrase([60, 61]), ["Semitone", "Tone"], 0),
                K.round(K.phrase([62, 64]), ["Semitone", "Tone"], 1),
                K.round(K.phrase([71, 72]), ["Semitone", "Tone"], 0, "B to C."),
            ]),
            K.play("Climb in tones", "C, D, E, then F♯: a tone each time.", [60, 62, 64, 66], low: 55, high: 67),
            K.play("Climb in semitones", "E, F, F♯, G: a semitone each time.", [64, 65, 66, 67], low: 60, high: 72),
        ],
        gold: [
            L.gold("octaves in a bassline",
                   "Bass players jump between a note and its octave to make a line bounce without changing the harmony. Hear octaves down low, then copy and write a bouncing line."),
            K.quiz("Octave jump or new note?", "Low notes now. Same note higher, or a different note?", [
                K.round(K.phrase([45, 57]), ["Octave", "New note"], 0),
                K.round(K.phrase([45, 52]), ["Octave", "New note"], 1),
                K.round(K.phrase([50, 62]), ["Octave", "New note"], 0),
                K.round(K.phrase([48, 55]), ["Octave", "New note"], 1),
            ]),
            L.bass("Copy the octave bounce", "Low A and the A above it, then a jump to G at the end.",
                   L.n([(0, 33), (3, 45), (8, 33), (11, 45), (14, 43)]), backing: drums),
            L.bassMake("Make it yours", "A bassline that jumps octaves. Use both A rows and at least six notes.", backing: drums, notes: 6),
        ])

    static let u4l3: LevelPair = (
        silver: [
            L.silver("the third decides",
                     "Major and minor chords differ by one note, the middle one, called the third. Lower it a semitone and bright turns dark. C, E, G is C major. C, E♭, G is C minor."),
            K.play("Play C major, then C minor", "C, E, G. Then C, E♭, G. Hear the middle note darken.",
                   [60, 64, 67, 60, 63, 67], low: 55, high: 72),
            K.quiz("Major or minor chord?", "One chord at a time.", [
                K.round([.c], ["Major", "Minor"], 0),
                K.round([.am], ["Major", "Minor"], 1),
                K.round([f], ["Major", "Minor"], 0),
                K.round([.em], ["Major", "Minor"], 1),
                K.round([.dm], ["Major", "Minor"], 1),
                K.ask("To turn C major into C minor, which note moves?", ["C goes up", "E goes down to E♭", "G goes down"], 1),
            ]),
        ],
        gold: [
            L.gold("minor melodies",
                   "Most dance music is in a minor key. A minor melodies lean on A, C and E and come home to A. Hear major and minor melodies, copy a minor one, then write your own."),
            K.quiz("Major or minor melody?", "", [
                K.round(K.phrase([60, 62, 64, 67, 64, 60]), ["Major", "Minor"], 0),
                K.round(K.phrase([57, 60, 64, 62, 60, 57]), ["Major", "Minor"], 1),
                K.round(K.phrase([62, 66, 69, 66]), ["Major", "Minor"], 0),
                K.round(K.phrase([62, 65, 69, 65]), ["Major", "Minor"], 1),
            ]),
            K.leadCopy("Copy the minor melody", "It climbs A, C, E, steps down to D and C, and comes home to A.",
                       rows: mel, target: K.line([(0, 57), (2, 60), (4, 64), (6, 62), (8, 60), (12, 57)]), backing: bed),
            K.leadMake("Write a dark melody", "At least five notes. End on the low A so it feels finished.",
                       rows: mel, backing: bed, notes: 5),
        ])

    static let mel1: LevelPair = (
        silver: [
            L.silver("in or out of the scale",
                     "The pentatonic has five notes: A, C, D, E and G. Any other note sticks out. Train your ear to catch a note that doesn't belong, then play the scale coming down."),
            K.play("Play the scale coming down", "High A, G, E, D, C, then low A.", [69, 67, 64, 62, 60, 57], low: 57, high: 69),
            K.quiz("Does every note belong?", "Is every note in the scale, or does one stick out?", [
                K.round(K.phrase([57, 60, 62, 64]), ["All in the scale", "One sticks out"], 0),
                K.round(K.phrase([57, 60, 63, 64]), ["All in the scale", "One sticks out"], 1, "E♭ isn't in the scale."),
                K.round(K.phrase([64, 67, 69, 67]), ["All in the scale", "One sticks out"], 0),
                K.round(K.phrase([69, 68, 64, 62]), ["All in the scale", "One sticks out"], 1, "G♯ doesn't belong."),
                K.round(K.phrase([60, 62, 65, 64]), ["All in the scale", "One sticks out"], 1, "F isn't in this scale."),
            ]),
            K.leadCopy("Copy the run", "Straight up the scale, then hold the top.", rows: mel,
                       target: [NoteEvent(0, 57), NoteEvent(1, 60), NoteEvent(2, 62), NoteEvent(3, 64), NoteEvent(4, 67),
                                NoteEvent(6, 69, 4)], backing: bed),
        ],
        gold: [
            L.gold("melody shapes",
                   "Melodies have shapes. A climb builds tension, a fall relaxes, and an arch goes up and comes home. Hear the shape first, then write one on purpose."),
            K.quiz("What shape is it?", "", [
                K.round(K.phrase([57, 60, 64, 67]), ["Climb", "Fall", "Arch"], 0),
                K.round(K.phrase([60, 64, 69, 64, 60]), ["Climb", "Fall", "Arch"], 2),
                K.round(K.phrase([69, 64, 62, 57]), ["Climb", "Fall", "Arch"], 1),
                K.round(K.phrase([57, 62, 67, 62]), ["Climb", "Fall", "Arch"], 2),
            ]),
            K.leadCopy("Copy the arch", "Up to the high A, then back down home.", rows: mel,
                       target: K.line([(0, 57), (2, 60), (4, 64), (6, 69), (8, 64), (10, 60), (12, 57)]), backing: bed,
                       threshold: 0.85),
            K.leadMake("Make it yours", "Write an arch: climb to a high note, then come home to A. At least six notes.",
                       rows: mel, backing: bed, notes: 6),
        ])

    static let u4l5: LevelPair = (
        silver: [
            L.silver("leaps that land",
                     "A big leap grabs attention, and the best melodies follow it with a step back the other way. The leap is the surprise, and the step settles it."),
            K.quiz("Where's the leap?", "Three notes, two moves. Which move is the big one?", [
                K.round(K.phrase([57, 64, 62]), ["First move", "Second move"], 0),
                K.round(K.phrase([60, 62, 69]), ["First move", "Second move"], 1),
                K.round(K.phrase([69, 60, 62]), ["First move", "Second move"], 0),
                K.round(K.phrase([64, 62, 57]), ["First move", "Second move"], 1),
                K.ask("After a big leap up, a melody usually…", ["Leaps again", "Steps back down", "Stops"], 1,
                      "A step the other way balances the jump."),
            ]),
            K.leadCopy("Copy the leap and step", "Leap up from A to E, then step down to D and C.",
                       rows: mel, target: K.line([(0, 57), (2, 64), (4, 62), (8, 60)]), backing: bed),
        ],
        gold: [
            L.gold("balance steps and leaps",
                   "All steps sounds safe and sleepy. All leaps sounds random. Great hooks use mostly steps, with one leap where you want drama."),
            K.quiz("Smooth or dramatic?", "", [
                K.round(K.phrase([60, 62, 64, 62, 60]), ["Smooth", "Dramatic"], 0),
                K.round(K.phrase([57, 69, 60, 67]), ["Smooth", "Dramatic"], 1),
                K.round(K.phrase([64, 62, 60, 57]), ["Smooth", "Dramatic"], 0),
                K.round(K.phrase([60, 69, 57, 67]), ["Smooth", "Dramatic"], 1),
            ]),
            K.leadCopy("Copy the hook", "Steps up, one leap to the top, then steps home.", rows: mel,
                       target: K.line([(0, 57), (2, 60), (4, 62), (6, 69), (8, 67), (10, 64), (12, 62), (14, 60)]),
                       backing: bed, threshold: 0.85),
            K.leadMake("Make it yours", "At least six notes: mostly steps, with one big leap.", rows: mel, backing: bed, notes: 6),
        ])

    // MARK: - Unit 5: Chords & Harmony

    static let u5l4: LevelPair = (
        silver: [
            L.silver("mood across a progression",
                     "One chord has a mood. A progression tells a story. Mostly major chords feel bright, mostly minor feel moody, and mixing them gives the bittersweet feel of so much dance music."),
            K.quiz("Bright, moody or bittersweet?", "Four chords play. How does the whole thing feel?", [
                K.round([.c, f, g, .c], ["Bright", "Moody", "Bittersweet"], 0),
                K.round([.am, .dm, .em, .am], ["Bright", "Moody", "Bittersweet"], 1),
                K.round([.am, f, .c, g], ["Bright", "Moody", "Bittersweet"], 2, "Minor to major and back: bittersweet."),
                K.round([.dm, .am, .em, .am], ["Bright", "Moody", "Bittersweet"], 1),
            ]),
            K.build("Build F major", "F, A and C. A bright chord to lift a moody loop.", f, low: 53, high: 67),
            K.lane("Lift the loop", "A minor on beat 1, then F major on beat 3.", .rule, palette: [.am, f], backing: drums,
                   target: [0: 0, 8: 1], length: 6),
        ],
        gold: [
            L.gold("pick chords for a feeling",
                   "Producers choose chords for the scene: sunrise, late night, heartbreak. Start from the feeling, then pick the chords and their colour: plain, or a jazzy seventh."),
            K.quiz("Choose for the feeling", "", [
                K.ask("A sunrise moment, warm and hopeful. Start on…", ["C major", "A minor"], 0),
                K.ask("A dark, late-night groove. Start on…", ["F major", "A minor"], 1),
                K.round([.am, .dm], ["Plain", "Jazzy"], 0, question: "Plain triads or jazzy sevenths?"),
                K.round([.am7, .dm7], ["Plain", "Jazzy"], 1, question: "Plain triads or jazzy sevenths?"),
            ]),
            K.lane("Copy the late-night loop", "Two jazzy chords: Am7, then Fmaj7.", .recreate, palette: [.am7, .fmaj7],
                   backing: drums, target: [0: 0, 8: 1], length: 6),
            K.lane("Make it yours", "A bittersweet loop: mix moody and bright chords. At least three chords.",
                   .create(.chordsAtLeast(3)), palette: [.am, .c, f, g], backing: drums, length: 3),
        ])

    // MARK: - Unit 6: Sound Design Basics

    static let bassLoop = H.bassLoop

    static let u6l1: LevelPair = (
        silver: [
            L.silver("describe before you turn",
                     "Before you touch a knob, listen and describe. Is the filter open or closed? Does each note snap open or stay steady? Naming what you hear tells you which knob to reach for."),
            K.quiz("Describe the sound", "", [
                K.sound(bassLoop, [.bassCutoff: 0.08, .bassEnv: 0], ["Closed: dark", "Open: bright"], 0,
                        question: "Is the filter open or closed?"),
                K.sound(bassLoop, [.bassCutoff: 0.85, .bassEnv: 0], ["Closed: dark", "Open: bright"], 1,
                        question: "Is the filter open or closed?"),
                K.sound(bassLoop, [.bassCutoff: 0.2, .bassEnv: 0.85], ["Steady", "Snaps open on each note"], 1,
                        "That 'wow' on every note is the envelope opening the filter.", question: "Does each note snap open?"),
                K.sound(bassLoop, [.bassCutoff: 0.2, .bassEnv: 0], ["Steady", "Snaps open on each note"], 0,
                        question: "Does each note snap open?"),
            ]),
            K.lab("Match this bass", "Closed filter, big envelope: dark notes that bark.", [.bassCutoff, .bassEnv],
                  start: [0.6, 0.1], target: [0.15, 0.85], loop: bassLoop),
            K.quiz("Which part does that?", "", [
                K.ask("Which part makes the raw tone?", ["Oscillator", "Filter", "Envelope"], 0),
                K.ask("Which part removes brightness?", ["Oscillator", "Filter", "Envelope"], 1),
                K.ask("Which part shapes the sound over time?", ["Oscillator", "Filter", "Envelope"], 2),
            ]),
        ],
        gold: [
            L.gold("signal flow",
                   "Sound flows from the oscillator into the filter and out. The envelope moves the filter on every note. So the wave sets the raw buzz, the cutoff sets how much gets through, and the envelope makes it move."),
            K.quiz("What would you turn?", "", [
                K.ask("The bass is too buzzy and harsh.", ["Cutoff down", "Envelope up", "Wave to saw"], 0),
                K.ask("You want every note to 'wow'.", ["Cutoff up", "Envelope up", "Length down"], 1),
                K.ask("The bass is too smooth and needs edge.", ["Wave toward saw", "Cutoff down", "Envelope off"], 0),
            ]),
            K.lab("Match this bass", "Three knobs in signal order: wave, cutoff, envelope. Start with the wave.",
                  [.bassWave, .bassCutoff, .bassEnv], start: [0, 0.6, 0.1], target: [0.5, 0.25, 0.7], loop: bassLoop),
            K.lab("Design your own bass", "Every knob in the chain. Land on something you'd use.",
                  [.bassWave, .bassCutoff, .bassEnv, .bassResonance], start: [0.5, 0.5, 0.5, 0.2], loop: bassLoop),
        ])

    static let u6l2: LevelPair = (
        silver: [
            L.silver("name the wave by ear",
                     "Sine is smooth like a whistle, saw buzzes like a bee, square is hollow like a clarinet. Hear each one before you go hunting with the knob."),
            K.quiz("Which wave?", "The filter is wide open, so you hear the raw wave.", [
                K.sound(bassLoop, [.bassWave: 0, .bassCutoff: 0.9], ["Sine", "Saw", "Square"], 0),
                K.sound(bassLoop, [.bassWave: 0.5, .bassCutoff: 0.9], ["Sine", "Saw", "Square"], 1),
                K.sound(bassLoop, [.bassWave: 1, .bassCutoff: 0.9], ["Sine", "Saw", "Square"], 2),
                K.ask("Sub bass is usually a…", ["Sine", "Saw", "Square"], 0, "Pure and round, felt more than heard."),
            ]),
            K.lab("Find the hollow square", "Wave all the way up, filter wide open.", [.bassWave, .bassCutoff],
                  start: [0.3, 0.3], target: [1.0, 0.85], loop: bassLoop),
        ],
        gold: [
            L.gold("wave plus filter",
                   "The filter can only remove what the wave gives it. A sine has nothing to filter, a saw has plenty. That's why bright, moving basses start from a saw or a square."),
            K.quiz("What happens?", "", [
                K.ask("You close the filter on a sine. It sounds…", ["Much darker", "Almost the same", "Louder"], 1,
                      "A sine has no top end to remove."),
                K.ask("You want a bass that growls when the filter opens. Start on…", ["Sine", "Saw"], 1),
                K.sound(bassLoop, [.bassWave: 0.5, .bassCutoff: 0.12], ["A pure sine", "A saw with the filter closed"], 1,
                        "A closed saw is dark but keeps a faint buzz.", question: "Sine, or a filtered saw?"),
            ]),
            K.lab("Match the growl", "Saw wave, filter low, envelope high.", [.bassWave, .bassCutoff, .bassEnv],
                  start: [0, 0.6, 0.1], target: [0.5, 0.2, 0.75], loop: bassLoop),
            K.lab("Design a sub", "Pure and deep: pick the right wave and keep the filter still.", [.bassWave, .bassCutoff, .bassEnv],
                  start: [0.8, 0.6, 0.6], target: [0.0, 0.2, 0.05], loop: bassLoop),
        ])

    // MARK: - Unit 7: Mixing Basics

    static let mix5: [MixChannel] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]

    static let u7l1: LevelPair = (
        silver: [
            L.silver("spot what's out of balance",
                     "Before you move a fader, find the problem. Listen for the part that jumps out, or the one you can't find. Fix the biggest problem first."),
            K.quiz("Which part is off?", "One part is too loud or too quiet.", [
                K.faders(drums, [.drum(.hat): 1.0], ["Kick", "Clap", "Hats"], 2, "The hats poke out over everything.",
                         question: "Which part is too loud?"),
                K.faders(drums, [.drum(.clap): 1.0], ["Kick", "Clap", "Hats"], 1, question: "Which part is too loud?"),
                K.faders(drums, [.drum(.kick): 0.2], ["Kick", "Clap", "Hats"], 0, "The kick has almost vanished.",
                         question: "Which part is too quiet?"),
                K.faders(drumsBass, [.bass: 1.0], ["Kick", "Bass", "Hats"], 1, question: "Which part is too loud?"),
            ]),
            K.mix("Bring the clap back", "The clap is buried. Bring it up to sit with the kick.",
                  [.drum(.kick), .drum(.clap), .drum(.hat)], start: [K.u, 0.15, 0.45], target: [K.u, K.u, 0.45], loop: drums),
            K.mix("Pull the bass under the kick", "The bass is too loud. Bring it down until the kick leads.",
                  [.drum(.kick), .bass], start: [K.u, 1.0], target: [K.u, 0.55], loop: H.bassLoop),
        ],
        gold: [
            L.gold("build a mix from the kick",
                   "Set the kick first and leave it alone. Then bring each part in one at a time, just loud enough to hear clearly. Stop the moment it sits."),
            K.quiz("Find the problem", "Five parts. Which one is out?", [
                K.faders(full, [.chords: 1.0], ["Bass", "Chords", "Hats"], 1, question: "Which part is too loud?"),
                K.faders(full, [.bass: 0.15], ["Bass", "Chords", "Clap"], 0, question: "Which part is too quiet?"),
                K.faders(full, [.drum(.clap): 0.15], ["Kick", "Clap", "Chords"], 1, question: "Which part is too quiet?"),
            ]),
            K.mix("Balance the full loop", "Kick first, then clap, hats, bass and chords.", mix5,
                  start: [K.u, 0.2, 0.2, 0.2, 0.2], target: [K.u, 0.6, 0.4, 0.6, 0.45], loop: full),
            K.mix("Make your own mix", "All five faders. Trust your ears.", mix5, start: [0.2, 0.2, 0.2, 0.2, 0.2], loop: full),
        ])

    static let u7l2: LevelPair = (
        silver: [
            L.silver("filters reveal the spectrum",
                     "A low-pass filter takes away the highs first. Close it bit by bit and the hats vanish, then the claps and chords, until only kick and bass are left. It's a great way to hear what lives where."),
            K.quiz("What's left?", "The loop plays through a filter.", [
                K.filtered(full, cutoff: 250, ["Only the lows", "Lows and mids", "Everything"], 0, "Just kick and bass.",
                           question: "What can you hear?"),
                K.filtered(full, cutoff: 1500, ["Only the lows", "Lows and mids", "Everything"], 1,
                           "The hats have gone. Chords and claps remain.", question: "What can you hear?"),
                K.filtered(full, cutoff: 18000, ["Only the lows", "Lows and mids", "Everything"], 2, question: "What can you hear?"),
            ]),
            K.filterMatch("Lose only the sizzle", "Keep the lows and mids. Bring the cutoff down until the hats just disappear.",
                          cutoff: 1500, resonance: 0.1, full),
            K.quiz("Who's fighting?", "", [
                K.ask("Which two parts share the lows and can fight?", ["Kick and bass", "Hats and clap", "Chords and hats"], 0),
                K.ask("Which part lives highest?", ["Bass", "Chords", "Hi-hats"], 2),
            ]),
        ],
        gold: [
            L.gold("make room",
                   "When two parts fight, give each its own space: turn one down, filter one, or make one duck for the other. Chords can lose some brightness so the bass has room, and the bass can duck for the kick."),
            K.quiz("How would you fix it?", "", [
                K.ask("The bass and kick turn to mud together.", ["Make the bass duck for the kick", "Turn the hats down",
                                                                   "Add reverb to the kick"], 0),
                K.ask("The chords crowd everything.", ["Darken the chords", "Speed up the tempo", "Add more chords"], 0),
                K.ask("The hats are harsh and tiring.", ["Turn them down a touch", "Make them longer", "Add drive"], 0),
            ]),
            K.lab("Darken the chords", "Bring the chord cutoff down so they sit behind the bass.", [.chordCutoff],
                  start: [0.9], target: [0.35], loop: full),
            K.mix("Fit the bass under the kick", "Set the bass level and the pump together.", [.drum(.kick), .bass, .sidechain],
                  start: [K.u, 0.9, 0], target: [K.u, 0.6, 0.4], loop: H.bassLoop),
        ])

    static let u7l3: LevelPair = (
        silver: [
            L.silver("how much pump",
                     "Pump is a dial. A little keeps the kick clear without you noticing it. A lot makes everything breathe in time, the sound of French house and big-room tracks."),
            K.quiz("How much pump?", "Listen to the pad around each kick.", [
                K.faders(H.padLoop, [.sidechain: 0], ["None", "Gentle", "Heavy"], 0),
                K.faders(H.padLoop, [.sidechain: 0.85], ["None", "Gentle", "Heavy"], 2),
                K.faders(H.padLoop, [.sidechain: 0.35], ["None", "Gentle", "Heavy"], 1),
                K.ask("Sidechain turns other parts down when…", ["The kick hits", "The clap hits", "The bar ends"], 0),
            ]),
            K.mix("Match the gentle pump", "Just enough that the pad dips under each kick.", [.chords, .sidechain],
                  start: [K.u, 0.9], target: [K.u, 0.35], loop: H.padLoop),
        ],
        gold: [
            L.gold("pump the right parts",
                   "You don't pump everything. Bass and chords duck for the kick; the hats and clap usually don't. Hear when a full loop pumps, then set one."),
            K.quiz("Is it pumping?", "The full loop.", [
                K.faders(full, [.sidechain: 0.8], ["Pumping", "Not pumping"], 0),
                K.faders(full, [.sidechain: 0], ["Pumping", "Not pumping"], 1),
                K.faders(full, [.sidechain: 0.45], ["Pumping", "Not pumping"], 0, "Gentler, but it's there."),
            ]),
            K.mix("Match the full mix", "Bass, chords and pump.", [.drum(.kick), .bass, .chords, .sidechain],
                  start: [K.u, 0.3, 0.9, 0], target: [K.u, 0.6, 0.55, 0.7], loop: full),
            K.mix("Set your own pump", "Choose how much the loop breathes.", [.bass, .chords, .sidechain], start: [K.u, K.u, 0],
                  loop: full),
        ])

    static let kickLoop = H.kickLoop

    static let u7l5: LevelPair = (
        silver: [
            L.silver("how much drive",
                     "Drive has three zones: clean, warm and crushed. Warm adds grit you feel more than hear. Crushed is a sound in itself. Hear each zone, then dial one in."),
            K.quiz("How driven?", "", [
                K.sound(kickLoop, [.kickDrive: 0], ["Clean", "Warm", "Crushed"], 0),
                K.sound(kickLoop, [.kickDrive: 0.95], ["Clean", "Warm", "Crushed"], 2),
                K.sound(kickLoop, [.kickDrive: 0.4], ["Clean", "Warm", "Crushed"], 1),
            ]),
            K.lab("Dial in warm", "A little grit, not distortion. Pitch it a bit lower too.", [.kickDrive, .kickPitch],
                  start: [0.9, 0.6], target: [0.4, 0.3], loop: kickLoop),
        ],
        gold: [
            L.gold("drive in the mix",
                   "A driven kick sounds louder at the same level, because drive adds higher harmonics. That's why it cuts through on phone speakers. Shape a driven kick in the full loop, then rebalance around it."),
            K.quiz("Why drive?", "", [
                K.ask("Drive helps a kick on phone speakers because it…",
                      ["Adds higher harmonics small speakers can play", "Makes it longer", "Changes the tempo"], 0),
                K.ask("Which genre drives its kick hardest?", ["Deep house", "Techno", "UK garage"], 1),
            ]),
            K.lab("Shape the driven kick", "Pitch, length and drive, heard in the full loop.", [.kickPitch, .kickDecay, .kickDrive],
                  start: [0.6, 0.2, 0.0], target: [0.25, 0.6, 0.8], loop: full),
            K.mix("Rebalance after drive", "The kick got louder. Bring the bass up to meet it.", [.drum(.kick), .bass],
                  start: [K.u, 0.3], target: [K.u, 0.65], loop: full),
        ])

    // MARK: - Unit 8: Arrangement & Finishing

    static let u8l2: LevelPair = (
        silver: [
            L.silver("changes land on the phrase",
                     "A change at the start of a phrase, on bar 1, 5, 9 or 17, feels natural. A change anywhere else feels like a mistake. Learn to hear the difference."),
            K.quiz("On the phrase or off it?", "Eight bars. Did the bass arrive at the start of a phrase?", [
                K.hear([drums, drums, drums, drums, drumsBass, drumsBass, drumsBass, drumsBass], ["On the phrase", "Off the phrase"], 0,
                       "Bar 5: the start of the second phrase."),
                K.hear([drums, drums, drums, drumsBass, drumsBass, drumsBass, drumsBass, drumsBass], ["On the phrase", "Off the phrase"], 1,
                       "Bar 4 ends a phrase, so it feels early."),
                K.hear([drums, drums, drums, drums, drums, drumsBass, drumsBass, drumsBass], ["On the phrase", "Off the phrase"], 1,
                       "Bar 6 lands in the middle of a phrase."),
                K.ask("A DJ is mixing your track in. When should your next change come?",
                      ["After 3 bars", "After 8 bars", "After 10 bars"], 1),
            ]),
            K.arrange("Recreate the phrases", "Each section is one phrase. Listen to what each adds.", .recreate, loop: full,
                      target: K.grid("xxxx", "--xx", "-xxx", "---x", "x-xx")),
        ],
        gold: [
            L.gold("mark the end of a phrase",
                   "Producers flag the end of a phrase with a fill in its last bar, so the listener knows a change is coming. Hear the fill, copy one, then arrange in phrases."),
            K.quiz("Where's the fill?", "Eight bars. Which bar has the fill?", [
                K.hear([drums, drums, drums, fill, drums, drums, drums, drums], ["Bar 4", "Bar 8"], 0),
                K.hear([drums, drums, drums, drums, drums, drums, drums, fill], ["Bar 4", "Bar 8"], 1),
            ]),
            L.copy("Copy the phrase-end fill", "The hats stop, the kick lands on the 'and' of beat 3, and the claps double up at the end.",
                   tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                   target: Pattern(kick: [0, 4, 8, 10], clap: [4, 12, 14, 15], hat: [2, 6, 10])),
            K.arrange("Arrange in phrases", "Five sections, each a phrase. Every section different from the last.",
                      .create(.variedSections), sections: five, loop: full),
        ])

    static let u8l3: LevelPair = (
        silver: [
            L.silver("subtract one part at a time",
                     "Subtracting works best one part at a time. Each section loses or gains one thing, so the listener can follow the change."),
            K.quiz("What was taken away?", "", [
                K.hear([full, noKick], ["Kick", "Bass", "Chords"], 0),
                K.hear([full, noBass], ["Hats", "Bass", "Clap"], 1),
            ]),
            K.arrange("Carve the intro and break", "Everything is on. In the Intro, switch off the bass and chords. In the Break, switch off the kick, clap and hats.",
                      .rule, loop: full, start: allOn4, target: K.grid("xxx-", "xxx-", "xxx-", "-xxx", "-xxx")),
            K.arrange("Copy the build-up", "One part arrives at each section.", .recreate, loop: full,
                      target: K.grid("xxxx", "-xxx", "xxxx", "--xx", "---x")),
        ],
        gold: [
            L.gold("a whole track from one loop",
                   "Copy your full loop across five sections and carve out an intro, a build, a drop, a break and a second drop. The second drop can bring everything back."),
            K.arrange("Recreate this track", "Five sections. Follow one part at a time across all of them.", .recreate,
                      sections: five, loop: full, target: K.grid("x-x-x", "--x-x", "xxx-x", "-xxxx", "--xxx")),
            K.quiz("Quick check", "", [
                K.ask("Why start full and subtract?",
                      ["Every section comes from the same loop, and it's faster", "It makes the track louder", "It changes the tempo"], 0),
            ]),
            K.arrange("Make it yours", "Start full and carve out five sections, each different from the last.",
                      .create(.variedSections), sections: five, loop: full, start: allOn5),
        ])

    static let u8l4: LevelPair = (
        silver: [
            L.silver("energy without new parts",
                     "Adding parts isn't the only way up. Busier hats, a brighter filter or a clap roll all raise the energy with the same parts."),
            K.quiz("Which bar hits harder?", "The same parts play in both bars.", [
                K.hear([Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: evens), Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: sixteenths)],
                       ["First", "Second"], 1, "Sixteenth hats raise the energy."),
                K.hear([fill, drums], ["First", "Second"], 0, "The clap roll pushes harder."),
                K.ask("Which raises energy without adding a part?", ["Busier hats", "Removing the kick", "A slower tempo"], 0),
            ]),
            K.arrange("Shape the curve", "Low, building, peak, then a dip. Listen and recreate it.", .recreate, loop: full,
                      target: K.grid("--x-", "--x-", "xxx-", "-xxx", "x-xx")),
        ],
        gold: [
            L.gold("two peaks",
                   "Club tracks usually peak twice. The second peak has to feel bigger, so producers hold something back from the first drop and add it in the second."),
            K.quiz("Which drop is bigger?", "Two drops, two bars each.", [
                K.hear([noChords, full], ["First", "Second"], 1, "The chords join for the second drop.", bars: 2),
                K.hear([full, noChords], ["First", "Second"], 0, bars: 2),
            ]),
            K.arrange("Recreate the two peaks", "The second drop adds a part the first one didn't have.", .recreate,
                      sections: twoPeaks, loop: full, target: K.grid("xx-x", "-x-x", "xx-x", "-xxx", "--xx")),
            K.arrange("Make it yours", "Two drops, the second bigger than the first.", .create(.variedSections),
                      sections: twoPeaks, loop: full),
        ])

    static let u8l5: LevelPair = (
        silver: [
            L.silver("three kinds of transition",
                     "Most transitions are one of three moves: a fill that rolls into the next bar, a stop where everything cuts out for a beat, or a filter sweep that opens up. Hear each, then use two."),
            K.quiz("Which transition?", "Two bars. What happens at the end of the second?", [
                K.hear([drums, fill], ["Fill", "Stop", "Nothing"], 0),
                K.hear([drums, stop], ["Fill", "Stop", "Nothing"], 1, "Everything cut out for the last beat."),
                K.hear([drums, drums], ["Fill", "Stop", "Nothing"], 2),
            ]),
            K.drumCopy("Copy the stop", "Everything plays until beat 4, then silence until the next bar.",
                       tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat], start: drums, target: stop),
            K.filterMatch("Set the build filter", "Halfway through a sweep: dark, with a little ring.", cutoff: 900, resonance: 0.4, full),
        ],
        gold: [
            L.gold("stack transitions",
                   "Big moments stack moves: the filter sweeps up while the claps roll, then everything stops for a beat before the drop."),
            K.fix("Fix the fill", "This roll is on the wrong beat. Move it to the last beat, steps 13 to 16.",
                  tracks: [.kick, .clap, .hat], edit: [.clap],
                  broken: Pattern(kick: [0, 4, 8, 12], clap: [4, 8, 9, 10, 11], hat: [2, 6, 10, 14]),
                  target: Pattern(kick: [0, 4, 8, 12], clap: [4, 12, 13, 14, 15], hat: [2, 6, 10, 14]), guide: false),
            K.filterSweep("Sweep into the drop", "Start dark and open the filter slowly all the way.", full),
            L.make("Make it yours", "A stop and a roll: drop the kick on the last beat and roll the claps. At least five claps.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc], start: drums, goal: .atLeast(.clap, 5)),
        ])
}
