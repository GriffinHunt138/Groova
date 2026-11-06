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
                  "Songs feel like journeys because something changes along the way. First you'll spot a section change on an arrangement. Then a song plays under a blank map, and you slam MARK the moment it changes."),
        K.teach("Parts enter and leave",
                "A thin intro, then the full band comes in. That entrance is a section boundary.",
                demo: G.verse),
        K.tapChanges("Mark the boundary", "Hats and chords, then the full beat. Hit the pad the moment the drums come in.",
                     loops: [G.intro, G.verse], barsEach: 4),
        K.game(detectiveName, detectiveLine, .detective([
            DetectiveRound(title: "One obvious change", body: "A quiet intro, then the full drums. Hit MARK when they come in.",
                           mode: .mark, song: cueA),
            DetectiveRound(title: "See the evidence", body: "Now the X-ray is on. When the change comes, tap the lane that changed.",
                           mode: .evidence, song: cueA),
            DetectiveRound(title: "Find two boundaries", body: "A new cue. Mark both of the big changes.", mode: .mark, song: cueB),
        ])),
    ])

    static let f51Silver: [LessonStep] = [
        L.silver("Analyze without seeing the stems",
                 "Some changes are obvious, others hide. First you'll label the sections of a song by ear. Then you'll catch a section returning, ignore a crash that's only a decoy, and put the evidence in order."),
        K.teach("A loud hit isn't a section",
                "A crash cymbal can land in the middle of a section. What makes a real change is a group of parts entering or leaving, or an idea coming back.",
                demo: G.main),
        K.order("Label the sections", "Play the reference. Four parts, two bars each. Tap them in the order you hear.",
                .recreate, tiles: S.blocks(), answer: [0, 1, 2, 1], barsEach: 2),
        K.game(detectiveName, detectiveLine, .detective([
            DetectiveRound(title: "The return", body: "A, then something different, then A again. Mark both changes.", mode: .mark, song: returnSong),
            DetectiveRound(title: "Texture decoy", body: "A crash lands partway through. Is it a new section, or just a crash?",
                           mode: .decoy(crashBar: 3, real: false), song: decoySong),
            DetectiveRound(title: "Order the evidence", body: "Listen, then tap the three cards in the order they played.", mode: .order, song: orderSong),
        ])),
    ]

    static let f51Gold: [LessonStep] = [
        L.gold("Mark your own map",
               "Put your listening to work on a longer journey. Mark its changes live, name each part in plain words, and replay the map you heard."),
        K.teach("Form is a journey",
                "Not every song follows the same template. Hearing form means noticing where the journey turns, wherever that is.",
                demo: G.breakdown),
        K.arrange("Build a structure", "Four sections: start, main, change, end. Each different from its neighbour.",
                  .create(.variedSections), sections: ["Start", "Main", "Change", "End"], lanes: F.lanes, loop: S.song),
        K.game(detectiveName, "Your map.", .detective([
            DetectiveRound(title: "Draw the boundaries live", body: "No guide. Mark every place the journey turns.", mode: .mark, song: longSong),
            DetectiveRound(title: "Name the parts", body: "Give each part of your map a plain name.", mode: .label, song: longSong),
            DetectiveRound(title: "Publish the map", body: "Replay with the X-ray to see your map over the music. Tap the lane that changed first.",
                           mode: .evidence, song: longSong),
        ])),
    ]

    // MARK: - F5.2 → Energy Surfer

    static let surferName = "Energy Surfer"
    static let surferLine = "Ride the wave. Every bar is a choice."

    static let f52 = K.lesson("f5.2", "Contrast Creates Interest", "Sparse versus full", "chart.bar.fill", .arrangement, 15, [
        K.opening("Energy isn't just volume",
                  "Energy in music isn't only about turning it up. First you'll see energy change as parts drop out and come back in an arrangement. Then you'll surf a track, sliding between layers, and feel a quiet bar make the next big one hit harder."),
        K.teach("Big needs small",
                "The same full loop twice feels flat. Drop the bass and melody for a moment and the return feels bigger, without getting louder.",
                demo: G.main),
        K.arrange("Sparse, then full", "Section one: just hats and chords. Section two: everything.", .rule,
                  sections: ["Sparse", "Full"], lanes: F.lanes, loop: S.song, target: K.grid("-x", "-x", "xx", "-x", "xx")),
        K.game(surferName, surferLine, .surfer([
            SurferRound(title: "Flatline", body: "The same dense loop, over and over. Tap below to hear a sparse bar.", mode: .flat),
            SurferRound(title: "Ride the lift", body: "Follow the gold path with your finger. Each level adds parts on the next bar.",
                        mode: .follow([1, 1, 2, 3, 4, 4])),
            SurferRound(title: "Make a drop", body: "It starts full. Pull down for a bar or two, then bring it all back for the end.",
                        mode: .rest(bars: 6)),
        ])),
    ])

    static let f52Silver: [LessonStep] = [
        L.silver("Follow an energy story",
                 "Now you'll build energy without leaning on loudness. First you'll copy an arrangement where layers come and go. Then you'll match a shape from memory and rescue a song that never rests."),
        K.teach("Density, register, parts",
                "A build can come from busier drums, a higher melody or an extra part. The volume knob stays put.",
                demo: G.energy(4)),
        K.arrange("Recreate verse and chorus", "Listen to each section and switch on what's playing.", .recreate,
                  sections: ["Verse", "Chorus", "Verse", "Chorus"], lanes: F.lanes, loop: S.song,
                  target: K.grid("xxxx", "xxxx", "-x-x", "xxxx", "-x-x")),
        K.game(surferName, surferLine, .surfer([
            SurferRound(title: "Match the shape", body: "Hear the reference ride with the wave hidden. Then ride it from memory.",
                        mode: .match([3, 3, 1, 1, 3, 4])),
            SurferRound(title: "Don't just turn it up", body: "The volume is locked. Climb with layers alone, following the path.",
                        mode: .follow([0, 1, 2, 3, 4, 4, 3, 4])),
            SurferRound(title: "Recover from overbuilding", body: "Everything is full for too long. Carve out a rest before the last bar.",
                        mode: .rest(bars: 8)),
        ])),
    ]

    static let f52Gold: [LessonStep] = [
        L.gold("Perform an energy arc",
               "You're going to perform the rise and fall of a whole mini-track. Pick an energy story, ride it live, then listen back without the picture."),
        K.teach("Contrast makes the return new",
                "When a familiar loop comes back after a break, it sounds fresh. Your arc decides when that happens.",
                demo: G.breakdown),
        K.arrange("Your arc", "Four sections, each different from the last.", .create(.variedSections),
                  sections: ["Start", "Build", "Peak", "Drop back"], lanes: F.lanes, loop: S.song),
        K.game(surferName, "Your arc.", .surfer([
            SurferRound(title: "Choose your narrative", body: "Slow rise, surprise drop or two peaks. Tap one to hear it.", mode: .narrative),
            SurferRound(title: "Ride the full track", body: "Eight bars. Ride your story live, with real highs and lows.", mode: .ride(bars: 8)),
            SurferRound(title: "Replay blind", body: "No wave. Compare the flat loop with your arc, then keep it.", mode: .replay),
        ])),
    ]

    // MARK: - F5.3 → The Perfect Cut

    static let cutName = "The Perfect Cut"
    static let cutLine = "Scrub the scissors. Small moves change everything."

    static let f53 = K.lesson("f5.3", "Make a Transition", "Cuts, fills and pauses", "arrow.forward.to.line", .arrangement, 15, [
        K.opening("Find the cut",
                  "Two great sections can still sound awkward if they're joined in the wrong place. First you'll put a fill right before a section change. Then you'll drag the scissors on a cutting board and hear a rough splice turn into a real transition."),
        K.teach("Cut on the bar line",
                "Joined mid-beat, the groove trips. Joined on a bar line, it flows. A fill points the way in.",
                demo: F.fill),
        K.order("Put the fill at the end", "Four bars. Three plain beats, then the fill right before the next section.", .rule,
                tiles: [K.tile("Beat", F.beat), K.tile("Fill", F.fill, "Snare roll")], answer: [0, 0, 0, 1],
                names: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"]),
        K.game(cutName, cutLine, .cut([
            CutRound(title: "Hear the awkward splice", body: "The cut lands mid-beat. Play it, then drag the scissors onto a bold bar line.",
                     mode: .align(start: 38)),
            CutRound(title: "Pause for impact", body: "Hit CUT OUT for a beat of silence before the change. Hear both versions.", mode: .pause),
            CutRound(title: "Fill the gap", body: "Pick a fill that leads into the next section and hear it in context.", mode: .fill),
        ])),
    ])

    static let f53Silver: [LessonStep] = [
        L.silver("Make an intentional join",
                 "Now trust the music more than the timeline. First you'll place silence on a transition bar. Then you'll find a transition point with no grid, compare two fills, and pick the join that suits the moment."),
        K.teach("Three tools",
                "A pause creates suspense. A fill builds excitement. An echo tail lets one section melt into the next.",
                demo: G.fill),
        K.order("Or use silence", "Same four bars, but drop everything in bar 4. Then hear the beat crash back in.", .rule,
                tiles: [K.tile("Beat", F.beat), K.tile("Silence", G.silence, "Nothing")], answer: [0, 0, 0, 1],
                names: ["Bar 1", "Bar 2", "Bar 3", "Bar 4"]),
        K.game(cutName, cutLine, .cut([
            CutRound(title: "No visible grid", body: "Four bars of a verse. Mark where a two-bar transition should start, by ear.",
                     mode: .markByEar(bar: 2)),
            CutRound(title: "Compare two edits", body: "One fill lands on the next downbeat, one lands an eighth late. Which matches the reference?",
                     mode: .compare),
            CutRound(title: "Match the intention", body: "The brief is dramatic. Pick the transition that serves it.", mode: .intention(dramatic: true)),
        ])),
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
        K.game(cutName, "Your cut.", .cut([
            CutRound(title: "Choose two sections", body: "Pick where you're coming from and where you're going.", mode: .choose),
            CutRound(title: "Edit one transition", body: "Put the cut on a bar line and add a pause, a fill or an echo tail. Preview as often as you like.",
                     mode: .direct),
            CutRound(title: "Render the scene", body: "Hard cut, then yours. Hear both and save it.", mode: .render),
        ])),
    ]

    // MARK: - F5.4 → Song Jigsaw

    static let jigsawName = "Song Jigsaw"
    static let jigsawLine = "Every postcard is a section. Build the journey."

    static let f54 = K.lesson("f5.4", "Arrange the Blocks", "Intro, main, variation, ending", "square.split.2x2.fill", .arrangement, 15, [
        K.opening("Hear the pieces",
                  "A finished song isn't one loop forever. It's sections that make a journey. First you'll drop sections into place on an arrangement. Then you'll flip musical postcards, slot them into a frame and hear the whole song play through."),
        K.teach("Order makes form",
                "Intro, main, variation, ending. Same few ideas, and the order turns them into a story.",
                demo: G.variation),
        K.order("Build the song", "Intro first, outro last. Verse before chorus.", .rule,
                tiles: S.blocks(), answer: [0, 1, 2, 3], barsEach: 2, names: ["Start", "", "", "End"]),
        K.game(jigsawName, jigsawLine, .jigsaw(cards, [
            JigsawRound(title: "Preview the postcards", body: "Flip every card to hear its section.", mode: .preview),
            JigsawRound(title: "Assemble a known arc", body: "Tap the cards into the frame in the order shown.",
                        mode: .assemble([0, 1, 2, 3], showNames: true)),
            JigsawRound(title: "Play the whole song", body: "Hear it start to finish. Watch each card glow as it plays.",
                        mode: .playthrough([0, 1, 2, 3])),
        ])),
    ])

    static let f54Silver: [LessonStep] = [
        L.silver("Solve the musical puzzle",
                 "The labels are gone, and some pieces sound alike. First you'll repair a repetitive arrangement. Then you'll rebuild songs from what you hear and turn a repeat into a variation."),
        K.teach("Change beats repeat",
                "The same section three times in a row gets stale. Swap one for a variation and the song keeps moving.",
                demo: G.main),
        K.order("Repair it", "It starts as verse after verse. Listen to the reference and rebuild it.", .recreate,
                tiles: S.blocks(), answer: [0, 1, 2, 1, 2, 3], start: [0, 1, 1, 1, 1, 3], barsEach: 2),
        K.game(jigsawName, jigsawLine, .jigsaw(cards, [
            JigsawRound(title: "Unlabeled cards", body: "No names. Hear the reference, then flip the cards and rebuild it.",
                        mode: .assemble([0, 1, 2, 3], showNames: false)),
            JigsawRound(title: "Find the duplicate", body: "Main plays three times in a row. Tap the variation card, then a repeat to replace it.",
                        mode: .duplicate(draft: [0, 1, 1, 1, 3], fresh: 2)),
            JigsawRound(title: "Rebuild a reference", body: "Five slots, and one card is used twice. Rebuild what you hear.",
                        mode: .assemble([0, 1, 2, 1, 3], showNames: false)),
        ])),
    ]

    static let f54Gold: [LessonStep] = [
        L.gold("Tell your own musical story",
               "Now you're arranging the story. Pick four or five cards with an opening, a contrast and an ending, order them by ear, then make a version B and keep the one you like."),
        K.teach("Contrast, return, ending",
                "A good arrangement has somewhere to go, something to come back to, and a deliberate ending.",
                demo: G.breakdown),
        K.order("Start with the hook", "Six blocks. Open with the chorus, then do whatever you like.", .create(.variedSections),
                tiles: S.blocks(), slots: 6, start: [2], locked: [0], barsEach: 2),
        K.game(jigsawName, "Your story.", .jigsaw(goldCards, [
            JigsawRound(title: "Hear your cards", body: "Five postcards. Flip each one to hear it.", mode: .preview),
            JigsawRound(title: "Arrange by ear", body: "Open with the intro, end with the outro, and put a contrast in between. Tap two slots to swap them.",
                        mode: .story),
            JigsawRound(title: "Make a version B", body: "Swap two cards or replace one. Compare both and keep B.", mode: .versionB),
        ])),
    ]

    // MARK: - F5.5 → The Live Take

    static let liveName = "The Live Take"
    static let liveLine = "Launch the scenes. Finish the song."

    static let f55 = K.lesson("f5.5", "My First Mini-Track", "Boss: a finished song", "crown.fill", .arrangement, 30, [
        K.opening("Your first finished track",
                  "Everything you've learned comes together in one short performance. First you'll lay out the song's sections. Then you'll sit at a live desk, launch the scenes on cue and give the track a proper ending."),
        K.teach("A finished timeline",
                "Intro, main, a change, an ending. The drums, bass, chords and melody you know, coming in and out at the right moments.",
                demo: G.main),
        K.order("Map it out", "Intro, verse, a fill, chorus, outro. Tap the blocks into place.", .rule,
                tiles: S.blocks() + [K.tile("Fill", F.fill, "Transition")], answer: [0, 1, 4, 2, 3], barsEach: 2),
        K.game(liveName, liveLine, .live([
            LiveRound(title: "Load the stage", body: "Tap each channel to hear its layer, then choose the band's sound.", mode: .load(imports: false)),
            LiveRound(title: "Run the scenes", body: "Tap each scene pad in the bar before its gold arrow. Launches land on the next bar line.",
                      mode: .guided),
            LiveRound(title: "Finish on purpose", body: "Hear your whole take from the first bar to the last chord, then save it.", mode: .playback),
        ])),
    ])

    static let f55Silver: [LessonStep] = [
        L.silver("Perform with fewer cues",
                 "You know the song now, so the guide steps back. First you'll rehearse the map. Then you'll pick your transitions, run the show without cue labels, and fix the one moment that needs it."),
        K.teach("Scenes, not notes",
                "Launching scenes and muting channels turns a few loops into a whole performance, without rewriting a note.",
                demo: G.variation),
        K.arrange("Rehearse the layers", "Four sections, each different from its neighbour.", .create(.variedSections),
                  sections: ["Intro", "Main", "Change", "End"], lanes: F.lanes, loop: S.song),
        K.game(liveName, liveLine, .live([
            LiveRound(title: "Choose the transitions", body: "Pick a fill into the main part, and a pause or echo before the change.", mode: .transitions),
            LiveRound(title: "Run the show", body: "No cue arrows now. Intro, Main, Change, End, launched on bar lines you feel.", mode: .cued),
            LiveRound(title: "Refine one moment", body: "Tap the launch that felt weakest on the timeline, nudge it a bar, and listen back.", mode: .refine),
        ])),
    ]

    static let f55Gold: [LessonStep] = [
        L.gold("Your first finished mini-song",
               "This is your first finished song, and the big decisions are yours. Bring in your own sounds from earlier Gold challenges, perform the whole arc, then name it and release it."),
        K.teach("Finishing is choosing",
                "A finished song isn't a perfect one. It's a take you choose and commit to.",
                demo: G.main),
        K.leadMake("Your hook", "A melody for your main part. At least six notes.", rows: F.leadRows, backing: F.full, notes: 6),
        K.game(liveName, "Your song.", .live([
            LiveRound(title: "Make it personal", body: "Bring in your Gold sounds, or start from a starter kit.", mode: .load(imports: true)),
            LiveRound(title: "Perform the full arc", body: "Sixteen bars: an opening, the main idea, a change, and an ending. Mute channels as you go.",
                      mode: .free, bars: 16),
            LiveRound(title: "Release the take", body: "Name your song and mark your favourite moment.", mode: .release, bars: 16),
        ])),
    ]

    static let levels: [String: LevelPair] = [
        "f5.1": (silver: f51Silver, gold: f51Gold),
        "f5.2": (silver: f52Silver, gold: f52Gold),
        "f5.3": (silver: f53Silver, gold: f53Gold),
        "f5.4": (silver: f54Silver, gold: f54Gold),
        "f5.5": (silver: f55Silver, gold: f55Gold),
    ]
}
