//
//  F5Games.swift
//  Groova
//
//  F5, From Loop to Song, in the Teach → Studio → Game flow:
//
//  F5.1 Hear the Sections → Structure Detective      F5.2 Contrast Creates Interest → Energy Surfer
//  F5.3 Make a Transition → The Perfect Cut          F5.4 Arrange the Blocks → Song Jigsaw
//  F5.5 My First Mini-Track → The Live Take
//

import Foundation

nonisolated enum F5Games {
    typealias F = FKit
    typealias S = F4F5
    typealias G = SongKit

    static let playName = "Play Along"
    static let earName = "Quick Ear"
    static let lessons: [Lesson] = [f51, f52, f53, f54, f55]

    // MARK: Songs

    static let cueA = [G.section("Intro", G.intro), G.section("Main", G.verse, bars: 4)]
    static let cueB = [G.section("Intro", G.intro), G.section("Main", G.main, bars: 3), G.section("End", G.outro)]
    static let returnSong = [G.section("A", G.main), G.section("B", G.breakdown), G.section("A", G.main)]
    static let decoySong = [G.section("Intro", G.intro), G.section("Main", G.verse, bars: 4)]
    static let orderSong = [G.section("Intro", G.intro), G.section("Main", G.main), G.section("Outro", G.outro)]
    static let longSong = [G.section("Start", G.intro), G.section("Main", G.main, bars: 3), G.section("Change", G.breakdown),
                           G.section("End", G.outro)]

    static let cards = [G.section("Intro", G.intro), G.section("Main", G.main), G.section("Variation", G.variation),
                        G.section("Outro", G.outro)]
    static let goldCards = cards + [G.section("Break", G.breakdown)]

    // MARK: - F5.1 → Structure Detective

    static let detectiveName = "Structure Detective"
    static let detectiveLine = "Mark the moment the music changes. Then see the evidence."

    static let f51 = K.lesson("f5.1", "Hear the Sections", "Songs come in parts", "rectangle.split.3x1.fill", .arrangement, 15, [
        K.opening("Hear the scene changes",
                  "Songs feel like journeys because something changes along the way. First you'll spot a section change on an arrangement. Then you'll hear a section and call when it changes."),
        K.teach("Parts enter and leave",
                "A thin intro, then the full band comes in. That entrance is a section boundary.",
                demo: G.verse),
        K.tapChanges("Mark the boundary", "Hats and chords, then the full beat. Hit the pad the moment the drums come in.",
                     loops: [G.intro, G.verse], barsEach: 4),
        K.game(earName, "Three bars, then: same or new section?", .quickEar(.sameChanged("f5.1", sections: [F.beat, F.full, Pattern(kick: [0, 8], hat: F.eighths)]))),
    ])

    static let f51Silver: [LessonStep] = [
        L.silver("Analyze without seeing the stems",
                 "Some changes are obvious, others hide. First you'll label the sections of a song by ear. Then you'll call section changes when they're subtle."),
        K.teach("A loud hit isn't a section",
                "A crash cymbal can land in the middle of a section. What makes a real change is a group of parts entering or leaving, or an idea coming back.",
                demo: G.main),
        K.order("Label the sections", "Play the reference. Four parts, two bars each. Tap them in the order you hear.",
                .recreate, tiles: S.blocks(), answer: [0, 1, 2, 1], barsEach: 2),
        K.game(earName, "Subtler changes.", .quickEar(.sameChanged("f5.1s", sections: [F.beat, F.groove, F.beatBass], count: 12))),
    ]

    static let f51Gold: [LessonStep] = [
        L.gold("Mark your own map",
               "Put your listening to work on a longer journey. Mark its changes live, name each part in plain words, and replay the map you heard."),
        K.teach("Form is a journey",
                "Not every song follows the same template. Hearing form means noticing where the journey turns, wherever that is.",
                demo: G.breakdown),
        K.arrange("Build a structure", "Four sections: start, main, change, end. Each different from its neighbour.",
                  .create(.variedSections), sections: ["Start", "Main", "Change", "End"], lanes: F.lanes, loop: S.song),
        K.game(earName, "Fifteen. Some changes are tiny.", .quickEar(.sameChanged("f5.1g", sections: [F.beat, F.groove, F.beatBass, F.fill], count: 15))),
    ]

    // MARK: - F5.2 → Energy Surfer

    static let surferName = "Energy Surfer"
    static let surferLine = "Ride the wave. Every bar is a choice."

    static let f52 = K.lesson("f5.2", "Contrast Creates Interest", "Sparse versus full", "chart.bar.fill", .arrangement, 15, [
        K.opening("Energy isn't just volume",
                  "Energy in music isn't only about turning it up. First you'll see energy change as parts drop out and come back in an arrangement. Then you'll hear two bars and pick the fuller one."),
        K.teach("Big needs small",
                "The same full loop twice feels flat. Drop the bass and melody for a moment and the return feels bigger, without getting louder.",
                demo: G.main),
        K.arrange("Sparse, then full", "Section one: just hats and chords. Section two: everything.", .rule,
                  sections: ["Sparse", "Full"], lanes: F.lanes, loop: S.song, target: K.grid("-x", "-x", "xx", "-x", "xx")),
        K.game(earName, "Two bars. Which was fuller?", .quickEar(.fuller("f5.2", layers: [Pattern(kick: [0, 8]), F.beatNoHats, F.beat, F.beatBass, F.full], closest: 2))),
    ])

    static let f52Silver: [LessonStep] = [
        L.silver("Follow an energy story",
                 "Now you'll build energy without leaning on loudness. First you'll copy an arrangement where layers come and go. Then you'll pick the fuller bar when they're close."),
        K.teach("Density, register, parts",
                "A build can come from busier drums, a higher melody or an extra part. The volume knob stays put.",
                demo: G.energy(4)),
        K.arrange("Recreate verse and chorus", "Listen to each section and switch on what's playing.", .recreate,
                  sections: ["Verse", "Chorus", "Verse", "Chorus"], lanes: F.lanes, loop: S.song,
                  target: K.grid("xxxx", "xxxx", "-x-x", "xxxx", "-x-x")),
        K.game(earName, "Closer contrasts.", .quickEar(.fuller("f5.2s", layers: [Pattern(kick: [0, 8]), F.beatNoHats, F.beat, F.beatBass, F.full], count: 12))),
    ]

    static let f52Gold: [LessonStep] = [
        L.gold("Perform an energy arc",
               "You're going to perform the rise and fall of a whole mini-track. Pick an energy story, ride it live, then listen back without the picture."),
        K.teach("Contrast makes the return new",
                "When a familiar loop comes back after a break, it sounds fresh. Your arc decides when that happens.",
                demo: G.breakdown),
        K.arrange("Your arc", "Four sections, each different from the last.", .create(.variedSections),
                  sections: ["Start", "Build", "Peak", "Drop back"], lanes: F.lanes, loop: S.song),
        K.game(earName, "Fifteen pairs.", .quickEar(.fuller("f5.2g", layers: [Pattern(kick: [0, 8]), F.beatNoHats, F.beat, F.beatBass, F.full], count: 15))),
    ]

    // MARK: - F5.3 → The Perfect Cut

    static let cutName = "The Perfect Cut"
    static let cutLine = "Scrub the scissors. Small moves change everything."

    static let f53 = K.lesson("f5.3", "Make a Transition", "Cuts, fills and pauses", "arrow.forward.to.line", .arrangement, 15, [
        K.opening("Find the cut",
                  "Two great sections can still sound awkward if they're joined in the wrong place. First you'll put a fill right before a section change. Then you'll play a snare fill along with the band."),
        K.teach("Cut on the bar line",
                "Joined mid-beat, the groove trips. Joined on a bar line, it flows. A fill points the way in.",
                demo: F.fill),
        K.order("Put the fill at the end", "Four bars. Three plain beats, then the fill right before the next section.", .rule,
                tiles: [K.tile("Beat", F.beat), K.tile("Fill", F.fill, "Snare roll")], answer: [0, 0, 0, 1],
                names: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"]),
        K.game(playName, "Play the snare fill at the end of each bar.", .playAlong(PlayAlongConfig(lanes: [.clap], groove: F.fill, bars: 6, bpm: 82))),
    ])

    static let f53Silver: [LessonStep] = [
        L.silver("Make an intentional join",
                 "Now trust the music more than the timeline. First you'll place silence on a transition bar. Then you'll play kick, snare and the fill, the last bars by feel."),
        K.teach("Three tools",
                "A pause creates suspense. A fill builds excitement. An echo tail lets one section melt into the next.",
                demo: G.fill),
        K.order("Or use silence", "Same four bars, but drop everything in bar 4. Then hear the beat crash back in.", .rule,
                tiles: [K.tile("Beat", F.beat), K.tile("Silence", G.silence, "Nothing")], answer: [0, 0, 0, 1],
                names: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"]),
        K.game(playName, "Kick, snare and the fill. Later by feel.", .playAlong(PlayAlongConfig(lanes: [.kick, .clap], groove: F.fill, bars: 8, bpm: 86, ghostFrom: 5))),
    ]

    static let f53Gold: [LessonStep] = [
        L.gold("Direct the cut",
               "Two sections, one chance to connect them with intention. Choose your sections, design the transition, and hear it against a plain hard cut."),
        K.teach("Every transition has a purpose",
                "Smooth motion, a surprise stop, or a big arrival. Decide what you want the listener to feel, then cut for it.",
                demo: G.variation),
        L.make("Write a fill", "Snares and kicks building toward the end of the bar. At least five snares.",
               tracks: [.kick, .clap, .hat, .openHat], edit: [.kick, .clap, .hat, .openHat], start: F.beatNoHats,
               goal: .atLeast(.clap, 5)),
        K.game(playName, "A trickier fill, mostly by feel.", .playAlong(PlayAlongConfig(lanes: [.kick, .clap], groove: Pattern(kick: [0, 8], clap: [4, 10, 12, 14, 15], hat: [0, 2, 4, 6, 8]), bars: 8, bpm: 90, ghostFrom: 4))),
    ]

    // MARK: - F5.4 → Song Jigsaw

    static let jigsawName = "Song Jigsaw"
    static let jigsawLine = "Every postcard is a section. Build the journey."

    static let f54 = K.lesson("f5.4", "Arrange the Blocks", "Intro, main, variation, ending", "square.split.2x2.fill", .arrangement, 15, [
        K.opening("Hear the pieces",
                  "A finished song isn't one loop forever. It's sections that make a journey. First you'll drop sections into place on an arrangement. Then you'll hear blocks and call whether it builds up or drops."),
        K.teach("Order makes form",
                "Intro, main, variation, ending. Same few ideas, and the order turns them into a story.",
                demo: G.variation),
        K.order("Build the song", "Intro first, outro last. Verse before chorus.", .rule,
                tiles: S.blocks(), answer: [0, 1, 2, 3], barsEach: 2, names: ["Start", "", "", "End"]),
        K.game(earName, "Is the music building or dropping?", .quickEar(.buildDrop("f5.4", layers: [Pattern(kick: [0, 8]), F.beatNoHats, F.beat, F.beatBass, F.full]))),
    ])

    static let f54Silver: [LessonStep] = [
        L.silver("Solve the musical puzzle",
                 "The labels are gone, and some pieces sound alike. First you'll repair a repetitive arrangement. Then you'll call build or drop, twelve in a row."),
        K.teach("Change beats repeat",
                "The same section three times in a row gets stale. Swap one for a variation and the song keeps moving.",
                demo: G.main),
        K.order("Repair it", "It starts as verse after verse. Listen to the reference and rebuild it.", .recreate,
                tiles: S.blocks(), answer: [0, 1, 2, 1, 2, 3], start: [0, 1, 1, 1, 1, 3], barsEach: 2),
        K.game(earName, "Twelve blocks.", .quickEar(.buildDrop("f5.4s", layers: [Pattern(kick: [0, 8]), F.beatNoHats, F.beat, F.beatBass, F.full], count: 12))),
    ]

    static let f54Gold: [LessonStep] = [
        L.gold("Tell your own musical story",
               "Now you're arranging the story. Pick four or five cards with an opening, a contrast and an ending, order them by ear, then make a version B and keep the one you like."),
        K.teach("Contrast, return, ending",
                "A good arrangement has somewhere to go, something to come back to, and a deliberate ending.",
                demo: G.breakdown),
        K.order("Start with the hook", "Six blocks. Open with the chorus, then do whatever you like.", .create(.variedSections),
                tiles: S.blocks(), slots: 6, start: [2], locked: [0], barsEach: 2),
        K.game(earName, "Fifteen blocks.", .quickEar(.buildDrop("f5.4g", layers: [Pattern(kick: [0, 8]), F.beatNoHats, F.beat, F.beatBass, F.full], count: 15))),
    ]

    // MARK: - F5.5 → The Live Take

    static let liveName = "The Live Take"
    static let liveLine = "Launch the scenes. Finish the song."

    static let f55 = K.lesson("f5.5", "My First Mini-Track", "Boss: a finished song", "crown.fill", .arrangement, 30, [
        K.opening("Your first finished track",
                  "Everything you've learned comes together in one short performance. First you'll lay out the song's sections. Then you'll play kick and snare through a whole track."),
        K.teach("A finished timeline",
                "Intro, main, a change, an ending. The drums, bass, chords and melody you know, coming in and out at the right moments.",
                demo: G.main),
        K.order("Map it out", "Intro, verse, a fill, chorus, outro. Tap the blocks into place.", .rule,
                tiles: S.blocks() + [K.tile("Fill", F.fill, "Transition")], answer: [0, 1, 4, 2, 3], barsEach: 2),
        K.game(playName, "The whole beat, kick and snare.", .playAlong(PlayAlongConfig(lanes: [.kick, .clap], groove: F.groove, bars: 8, bpm: 88))),
    ])

    static let f55Silver: [LessonStep] = [
        L.silver("Perform with fewer cues",
                 "You know the song now, so the guide steps back. First you'll rehearse the map. Then you'll play all three drums, the last bars by feel."),
        K.teach("Scenes, not notes",
                "Launching scenes and muting channels turns a few loops into a whole performance, without rewriting a note.",
                demo: G.variation),
        K.arrange("Rehearse the layers", "Four sections, each different from its neighbour.", .create(.variedSections),
                  sections: ["Intro", "Main", "Change", "End"], lanes: F.lanes, loop: S.song),
        K.game(playName, "All three drums. Later by feel.", .playAlong(PlayAlongConfig(lanes: [.kick, .clap, .hat], groove: F.beat, bars: 8, bpm: 90, ghostFrom: 5))),
    ]

    static let f55Gold: [LessonStep] = [
        L.gold("Your first finished mini-song",
               "This is your first finished song, and the big decisions are yours. Bring in your own sounds from earlier Gold challenges, perform the whole arc, then name it and release it."),
        K.teach("Finishing is choosing",
                "A finished song isn't a perfect one. It's a take you choose and commit to.",
                demo: G.main),
        K.leadMake("Your hook", "A melody for your main part. At least six notes.", rows: F.leadRows, backing: F.full, notes: 6),
        K.game(playName, "The full groove, mostly by feel.", .playAlong(PlayAlongConfig(lanes: [.kick, .clap, .hat], groove: F.groove, bars: 8, bpm: 94, ghostFrom: 4))),
    ]

    static let levels: [String: LevelPair] = [
        "f5.1": (silver: f51Silver, gold: f51Gold),
        "f5.2": (silver: f52Silver, gold: f52Gold),
        "f5.3": (silver: f53Silver, gold: f53Gold),
        "f5.4": (silver: f54Silver, gold: f54Gold),
        "f5.5": (silver: f55Silver, gold: f55Gold),
    ]
}
