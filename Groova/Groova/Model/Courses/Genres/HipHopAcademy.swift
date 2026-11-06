//
//  HipHopAcademy.swift
//  Groova
//
//  Hip-Hop, Part 2. Five units and a final song project, in D minor at 90 BPM with a swung pocket.
//
//  HH1 Feel the Pocket   HH2 Flip the Source   HH3 Bass & Musical Identity
//  HH4 Texture & Dynamics   HH5 Verse, Hook & Change-Up   HH6 Song Project Finale
//
//  The "sample" is an original four-bar soul phrase played on electric piano, so every flip is
//  cleared by design. Slices are one bar each.
//

import Foundation

nonisolated enum HipHopAcademy {
    static let units: [Unit] = [hh1, hh2, hh3, hh4, hh5, hh6]

    // MARK: Material

    static let rows = [50, 48, 45, 43, 41, 38]                 // D3 C3 A2 G2 F2 D2
    static let lead = [77, 74, 72, 69, 67, 65, 62, 60]         // D minor pentatonic, F5 down to C4
    static let eighths = [0, 2, 4, 6, 8, 10, 12, 14]

    static let boomBap = Pattern(kick: [0, 7, 10], clap: [4, 12], hat: eighths)
    static let simple = Pattern(kick: [0, 8], clap: [4, 12], hat: eighths)
    static let ghosts = Pattern(kick: [0, 7, 10], clap: [4, 12], hat: eighths, perc: [3, 11, 14])
    static let houseBeat = Pattern(kick: [0, 4, 8, 12], clap: [4, 12], openHat: [2, 6, 10, 14])
    static let dropout = Pattern(kick: [0, 7, 10], clap: [4], hat: [0, 2, 4, 6, 8, 10])
    static let fill = Pattern(kick: [0, 7, 10], clap: [4, 12, 13, 15], hat: [0, 2, 4, 6, 8, 10], perc: [14])

    static let dm7 = ChordShape.dm7, gm7 = ChordShape.gm7, bbmaj7 = ChordShape.bbmaj7, am7 = ChordShape.am7

    /// Four bars of an original soul phrase: one chord and a melodic fragment per bar.
    static let slices: [Pattern] = [
        K.melody(K.tune([(0, 69, 4), (4, 72, 4), (8, 74, 8)]), over: Pattern(chords: [K.ch(0, dm7, 14)])),
        K.melody(K.tune([(0, 74, 4), (4, 72, 2), (6, 70, 2), (8, 67, 8)]), over: Pattern(chords: [K.ch(0, gm7, 14)])),
        K.melody(K.tune([(0, 77, 4), (4, 74, 4), (8, 72, 8)]), over: Pattern(chords: [K.ch(0, bbmaj7, 14)])),
        K.melody(K.tune([(0, 72, 4), (4, 69, 4), (8, 67, 4), (12, 64, 4)]), over: Pattern(chords: [K.ch(0, am7, 14)])),
    ]
    static let sliceNames = ["Slice A", "Slice B", "Slice C", "Slice D"]

    static func sliceTiles() -> [OrderTile] {
        zip(sliceNames, slices).map { K.tile($0.0, $0.1) }
    }

    /// Move every note of a pattern up or down.
    static func shift(_ p: Pattern, _ n: Int) -> Pattern {
        var q = p
        q.chords = p.chords.map { ChordEvent(step: $0.step, pitches: $0.pitches.map { $0 + n }, length: $0.length) }
        q.bass = p.bass.map { NoteEvent($0.step, $0.pitch + n, $0.length) }
        return q
    }

    static func withBeat(_ p: Pattern, _ beat: Pattern = boomBap) -> Pattern { p.merged(with: beat) }

    static let bass = [NoteEvent(0, 38, 3), NoteEvent(7, 38), NoteEvent(10, 41, 2), NoteEvent(13, 36, 2)]
    static let beatBass = boomBap.merged(with: Pattern(bass: bass))
    static let loop = withBeat(slices[0]).merged(with: Pattern(bass: bass))
    static let chops = ChopSong.chops([69, 72, 74, 65])
    static let hookChops: [Int: Int] = [0: 0, 3: 1, 6: 2, 10: 1, 12: 3]

    // Sections
    static let intro = slices[0]
    static let verse = beatBass.merged(with: Pattern(chords: [K.ch(0, dm7, 6), K.ch(8, gm7, 6)]))
    static let hook = loop.merged(with: Pattern(perc: [3, 11]))
    static let changeUp = Pattern(clap: [4, 12], hat: eighths, bass: [NoteEvent(0, 43, 8), NoteEvent(8, 46, 8)],
                                  chords: [K.ch(0, gm7, 6), K.ch(8, bbmaj7, 6)])
    static let lanes: [Instrument] = [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords]

    static func sections() -> [OrderTile] {
        [K.tile("Intro", intro, "Sample alone"), K.tile("Verse", verse, "Beat & bass"), K.tile("Hook", hook, "Full flip"),
         K.tile("Change-up", changeUp, "New chords"), K.tile("Drop-out", dropout, "Beat stops")]
    }

    static let warm: [SoundParam: Double] = [.kickPitch: 0.15, .kickDecay: 0.7, .kickDrive: 0.1]
    static let crisp: [SoundParam: Double] = [.kickPitch: 0.6, .kickDecay: 0.2, .kickDrive: 0.3]
    static let punchy: [SoundParam: Double] = [.kickPitch: 0.4, .kickDecay: 0.35, .kickDrive: 0.9]

    // MARK: - HH1 · Feel the Pocket

    static let hh1 = K.unit("hiphop.hh1", 1, "Feel the Pocket", "Backbeat, swing and boom-bap drums", [hh11, hh12, hh13, hh1b])

    static let hh11 = K.lesson("hiphop.hh1.1", "Snare Locator", "The backbeat", "scope", .rhythm, 20, [
        K.intro("The snare runs the show",
                "In hip-hop the snare on beats 2 and 4, the backbeat, is the anchor. Rappers lock their flow to it. Heads nod to it. Find the snare and you've found the song.",
                [.kick, .clap], demo: boomBap),
        K.tapAlong("Tap the backbeat", "Every snare, on 2 and 4.", loop: boomBap, bars: 5, steps: [4, 12], label: "Snare",
                   unit: "snares", sound: .clap),
        K.quiz("Where's the snare?", "", [
            K.hear([boomBap], ["On 2 and 4", "On 1 and 3", "Everywhere"], 0, "The classic backbeat.", bars: 2),
            K.hear([Pattern(kick: [4, 12], clap: [0, 8], hat: eighths)], ["On 2 and 4", "On 1 and 3", "Everywhere"], 1,
                   "Flipped. It feels like it's tripping.", bars: 2),
        ]),
        K.drumRule("Place the backbeat", "Snare on steps 5 and 13.", tracks: [.kick, .clap, .hat], edit: [.clap],
                   start: Pattern(kick: [0, 7, 10], hat: eighths), target: boomBap),
    ])

    static let hh12 = K.lesson("hiphop.hh1.2", "Pocket Switch", "Straight versus swung", "metronome", .rhythm, 20, [
        K.intro("The pocket",
                "A beat is in the pocket when it feels relaxed and inevitable. Most of that comes from swing: every second hat arrives a little late, so the groove leans back instead of marching.",
                [.hat], demo: boomBap),
        K.quiz("Straight or swung?", "", [
            K.hear([boomBap.merged(with: Pattern(hat: Array(0..<16)))], ["Straight", "Swung"], 0, bars: 2, swing: 0),
            K.hear([boomBap.merged(with: Pattern(hat: Array(0..<16)))], ["Straight", "Swung"], 1, bars: 2, swing: 0.3),
        ]),
        K.swingMake("Swing the hats", "Drag swing up until the hats lean back.", tracks: [.kick, .clap, .hat],
                    start: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: Array(0..<16)), atLeast: 0.18),
        K.tapAlong("Feel the pocket", "Tap the snares while it swings.", loop: boomBap.merged(with: Pattern(hat: Array(0..<16))),
                   bars: 5, steps: [4, 12], label: "Snare", unit: "snares", sound: .clap),
    ])

    static let hh13 = K.lesson("hiphop.hh1.3", "Beat Builder", "Boom-bap from scratch", "square.grid.3x3.fill", .rhythm, 20, [
        K.intro("Boom-bap",
                "Boom is the kick, bap is the snare. The kick dances around beat 1 and the second half of the bar, the snare holds 2 and 4, and steady hats tie it together.",
                [.kick, .clap, .hat], demo: boomBap),
        K.drumRule("The kick", "Steps 1, 8 and 11.", tracks: [.kick, .clap, .hat], edit: [.kick],
                   start: Pattern(clap: [4, 12], hat: eighths), target: boomBap),
        K.drumRule("Add a ghost", "Quiet rim hits on steps 4, 12 and 15 fill the pocket.",
                   tracks: [.kick, .clap, .hat, .perc], edit: [.perc], start: boomBap, target: ghosts),
        K.drumMake("Your kick pattern", "Snare and hats stay. Move the kicks around. At least three.",
                   tracks: [.kick, .clap, .hat], edit: [.kick], start: Pattern(clap: [4, 12], hat: eighths), goal: .atLeast(.kick, 3)),
    ])

    static let hh1b = K.lesson("hiphop.hh1.boss", "Feel the Pocket Boss", "Boss: rebuild a beat", "crown.fill", .rhythm, 40, [
        K.intro("Boss: the pocket",
                "Rebuild a boom-bap beat from the reference, then give it swing.", [.kick, .clap, .hat, .perc], demo: ghosts),
        K.drumCopy("Rebuild the beat", "Kick, snare, hats and ghost rims.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], target: ghosts),
        K.swingMake("Put it in the pocket", "Swing it.", tracks: [.kick, .clap, .hat, .perc],
                    start: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: Array(0..<16), perc: [3, 11, 14]), atLeast: 0.2),
    ])

    // MARK: - HH2 · Flip the Source

    static let hh2 = K.unit("hiphop.hh2", 2, "Flip the Source", "Find, chop and flip a sample", [hh21, hh22, hh23, hh2b])

    static let hh21 = K.lesson("hiphop.hh2.1", "Sample Detective", "Find the loop", "magnifyingglass", .arrangement, 20, [
        K.intro("Digging",
                "Hip-hop producers dig through records for a few seconds worth looping. Here's an original soul phrase, four bars long. Your job: hear its parts and find the bit you'd loop.",
                [], demo: slices[0]),
        K.tapChanges("Tap each new slice", "Four bars, one chord each. Tap every time the chord changes.",
                     loops: slices, barsEach: 1, label: "Slice"),
        K.quiz("Which slice is this?", "", [
            K.hear([slices[0], slices[2]], ["Same slice", "Different slices"], 1),
            K.hear([slices[1], slices[1]], ["Same slice", "Different slices"], 0),
            K.hear([slices[3]], ["It rises", "It falls"], 1, "The melody walks down. A nice ending slice."),
        ]),
        K.order("Loop your favourite", "Pick one slice and loop it four times. Hear how a few seconds become a beat.",
                .create(.chordsAtLeast(4)), tiles: sliceTiles(), slots: 4, bed: boomBap),
    ])

    static let hh22 = K.lesson("hiphop.hh2.2", "Chop Shop", "Reorder the slices", "scissors", .arrangement, 20, [
        K.intro("Chop it up",
                "Chopping means cutting a sample into slices and playing them back in a new order. Same ingredients, brand-new phrase. It's the heart of hip-hop production.",
                [], demo: withBeat(slices[2])),
        K.order("Put it back together", "The original order is A, B, C, D. Rebuild it.", .rule, tiles: sliceTiles(),
                answer: [0, 1, 2, 3], bed: boomBap),
        K.order("Copy this chop", "A new order. Play the reference.", .recreate, tiles: sliceTiles(), answer: [2, 0, 2, 3], bed: boomBap),
        K.chops("Chop a vocal", "Vocal chops: place each one where you hear it.", .recreate, chops, backing: beatBass,
                target: hookChops),
    ])

    static let hh23 = K.lesson("hiphop.hh2.3", "Sample Flip", "Pitch and placement", "arrow.up.arrow.down", .arrangement, 20, [
        K.intro("Flip it",
                "Pitch a slice up and it sounds brighter and faster. Pitch it down and it's heavier and darker. Producers flip a sample's whole identity with a few moves.",
                [], demo: withBeat(shift(slices[0], -3))),
        K.quiz("Up or down?", "The original slice plays first, then a pitched copy.", [
            K.hear([slices[0], shift(slices[0], 3)], ["Pitched up", "Pitched down"], 0),
            K.hear([slices[0], shift(slices[0], -4)], ["Pitched up", "Pitched down"], 1),
        ]),
        K.order("Build a flip", "Original and pitched slices. Make a four-bar loop that mixes both.", .create(.chordsAtLeast(4)),
                tiles: [K.tile("A", slices[0]), K.tile("A down", shift(slices[0], -3), "Darker"), K.tile("C", slices[2]),
                        K.tile("C up", shift(slices[2], 2), "Brighter")],
                slots: 4, bed: boomBap),
    ])

    static let hh2b = K.lesson("hiphop.hh2.boss", "Flip the Source Boss", "Boss: your first flip", "crown.fill", .arrangement, 40, [
        K.intro("Boss: flip it",
                "Make a drum-backed loop from the sample. Copy a chop, then make one of your own.", [], demo: loop),
        K.order("Copy the chop", "Four bars, one slice repeats. Listen for which chord starts each bar.", .recreate, tiles: sliceTiles(), answer: [0, 0, 2, 3], bed: boomBap),
        K.order("Your chop", "Any order. Four bars.", .create(.chordsAtLeast(4)), tiles: sliceTiles(), slots: 4, bed: beatBass),
    ])

    // MARK: - HH3 · Bass & Musical Identity

    static let hh3 = K.unit("hiphop.hh3", 3, "Bass & Musical Identity", "Basslines and hooks that stick", [hh31, hh32, hh33, hh3b])

    static let hh31 = K.lesson("hiphop.hh3.1", "Bass Locksmith", "Roots under the sample", "key.fill", .theory, 20, [
        K.intro("Lock the bass to the sample",
                "The bass doubles the root of each chord in the sample, down low, so the loop feels heavy. Get the roots right and the whole beat clicks.",
                [], demo: withBeat(slices[0]).merged(with: Pattern(bass: [NoteEvent(0, 38, 8)]))),
        K.bassRule("Root under Dm7", "D, held under the first slice.", rows: rows, target: [NoteEvent(0, 38, 8)], backing: withBeat(slices[0])),
        K.bassRule("Root under Gm7", "G under slice B.", rows: rows, target: [NoteEvent(0, 43, 8)], backing: withBeat(slices[1])),
        K.bassRule("Dodge the kick", "Same D, but hit it with the kicks on steps 1 and 8, and let it ring.", rows: rows,
                   target: [NoteEvent(0, 38, 6), NoteEvent(7, 38, 3)], backing: withBeat(slices[0])),
    ])

    static let hh32 = K.lesson("hiphop.hh3.2", "Bass Echo", "Short motifs", "repeat", .theory, 20, [
        K.intro("Two notes can carry a beat",
                "Some of the heaviest hip-hop basslines are two notes. Root, then a jump. Repeat. The space between them is the groove.",
                [], demo: beatBass),
        K.bassRule("Two-note motif", "D, then F.", rows: rows, target: [NoteEvent(0, 38, 3), NoteEvent(10, 41, 2)], backing: boomBap),
        K.bassCopy("Echo it", "Same idea, new notes.", rows: rows, target: [NoteEvent(0, 38, 3), NoteEvent(7, 38), NoteEvent(10, 45, 2)],
                   backing: boomBap),
    ])

    static let hh33 = K.lesson("hiphop.hh3.3", "Hook Doctor", "Make a motif memorable", "stethoscope", .theory, 20, [
        K.intro("What makes a hook stick",
                "A hook needs one thing that grabs you: a surprising rhythm, a jump, or a repeat that changes at the end.",
                [], demo: K.melody(K.tune([(0, 74, 2), (3, 72, 1), (4, 69, 4), (10, 72, 2), (12, 74, 4)]), over: beatBass)),
        K.quiz("Which ending is stronger?", "Same start, two endings.", [
            K.round(K.phrase([74, 72, 69, 69]), ["Grabs me", "Forgettable"], 1, "Ends where it started to fall. Flat."),
            K.round(K.phrase([74, 72, 69, 77]), ["Grabs me", "Forgettable"], 0, "The jump at the end surprises you."),
        ]),
        K.leadRule("Doctor the hook", "Place the notes. The last one jumps up.", rows: lead,
                   target: K.tune([(0, 74, 2), (3, 72, 1), (4, 69, 4), (10, 72, 2), (12, 77, 4)]), backing: beatBass),
        K.leadMake("Your hook", "Five notes or more. Give it one surprise.", rows: lead, backing: beatBass, notes: 5),
    ])

    static let hh3b = K.lesson("hiphop.hh3.boss", "Bass & Identity Boss", "Boss: bass and motif", "crown.fill", .theory, 40, [
        K.intro("Boss: identity",
                "A stable bass foundation and a sample motif on top. Two layers that make the beat yours.", [], demo: loop),
        K.bassRule("The bass", "Follow the lit notes.", rows: rows, target: bass, backing: withBeat(slices[0])),
        K.chops("The motif", "Copy the chop rhythm.", .recreate, chops, backing: beatBass, target: hookChops),
    ])

    // MARK: - HH4 · Texture & Dynamics

    static let hh4 = K.unit("hiphop.hh4", 4, "Texture & Dynamics", "Kits, grit and dropouts", [hh41, hh42, hh43, hh4b])

    static let hh41 = K.lesson("hiphop.hh4.1", "Kit Curator", "Warm, crisp or punchy", "circle.grid.2x2.fill", .soundDesign, 20, [
        K.intro("The kit is the character",
                "Same pattern, different drums, totally different beat. Producers spend hours on kick and snare choice. Warm and round? Crisp and short? Punchy and loud?",
                [.kick], demo: boomBap),
        K.quiz("Name the kick", "", [
            K.sound(boomBap, warm, ["Warm", "Crisp", "Punchy"], 0, "Low, long and soft."),
            K.sound(boomBap, crisp, ["Warm", "Crisp", "Punchy"], 1, "Higher and short."),
            K.sound(boomBap, punchy, ["Warm", "Crisp", "Punchy"], 2, "Driven hard. It hits."),
        ]),
        K.lab("Shape the kick", "Pitch, length and drive.", [.kickPitch, .kickDecay, .kickDrive], start: [0.5, 0.5, 0.3], loop: boomBap),
    ])

    static let hh42 = K.lesson("hiphop.hh4.2", "Texture Lab", "Filtered, dusty samples", "camera.filters", .soundDesign, 20, [
        K.intro("Dust it",
                "Filter a sample and it sounds like it's coming from another room, or an old record. It also makes space for the drums to punch through.",
                [], demo: loop),
        K.filterSweep("Filter the loop", "Sweep down until the sample sounds distant, then back up.", loop),
        K.quiz("Clean or filtered?", "", [
            K.filtered(loop, cutoff: 600, ["Clean", "Filtered"], 1),
            K.filtered(loop, cutoff: 14000, ["Clean", "Filtered"], 0),
        ]),
    ])

    static let hh43 = K.lesson("hiphop.hh4.3", "One-Beat Surprise", "Dropouts", "pause.fill", .arrangement, 20, [
        K.intro("Take it away",
                "Cut the drums for one beat right before the hook and the return hits twice as hard. It's tiny, and it's everywhere.",
                [], demo: dropout),
        K.drumRule("Drop the last beat", "Remove every hit after step 12.", tracks: [.kick, .clap, .hat], edit: [.kick, .clap, .hat],
                   start: boomBap, target: dropout),
        K.order("Place it", "Three bars of beat, then the drop-out.", .rule,
                tiles: [K.tile("Beat", boomBap), K.tile("Drop-out", dropout)], answer: [0, 0, 0, 1], names: ["1", "2", "3", "4"]),
        K.tapMoments("Catch the return", "Tap the first kick after the drop-out.", loops: [boomBap, dropout, boomBap], barsEach: 1,
                     at: [32], label: "Back!", unit: "returns", sound: .kick, tolerance: 1.5, threshold: 0.99),
    ])

    static let hh4b = K.lesson("hiphop.hh4.boss", "Texture & Dynamics Boss", "Boss: loud, soft, bright, dark", "crown.fill", .mixing, 40, [
        K.intro("Boss: dynamics",
                "Match a loud-soft and bright-dark contrast by ear.", [], demo: loop),
        K.mix("Match the balance", "Drums up, sample down.", [.drum(.kick), .drum(.clap), .chords], start: [0.4, 0.4, 1],
              target: [0.8, 0.75, 0.45], loop: loop),
        K.filterMatch("Match the texture", "Dark and dusty.", cutoff: 900, resonance: 0.2, loop),
    ])

    // MARK: - HH5 · Verse, Hook & Change-Up

    static let hh5 = K.unit("hiphop.hh5", 5, "Verse, Hook & Change-Up", "Structure a full beat", [hh51, hh52, hh53, hh5b])

    static let hh51 = K.lesson("hiphop.hh5.1", "Section Spotter", "Verse versus hook", "rectangle.split.3x1.fill", .arrangement, 20, [
        K.intro("Verse and hook",
                "Verses leave room for words: sparser, often without the full sample. The hook brings everything in so the chorus hits.",
                [], demo: hook),
        K.tapChanges("Tap each change", "Verse, hook, verse, hook.", loops: [verse, hook, verse, hook], barsEach: 2),
        K.quiz("Verse or hook?", "", [
            K.hear([verse], ["Verse", "Hook"], 0, bars: 2),
            K.hear([hook], ["Verse", "Hook"], 1, bars: 2),
        ]),
    ])

    static let hh52 = K.lesson("hiphop.hh5.2", "Beat Architect", "Arrange verse and hook", "building.columns.fill", .arrangement, 20, [
        K.intro("Build the map",
                "A short hip-hop beat: intro, verse, hook, verse, hook. Each block is two bars.", []),
        K.order("Map the beat", "Intro first. Then verse, hook, verse, hook.", .rule, tiles: sections(),
                answer: [0, 1, 2, 1, 2], barsEach: 2),
        K.arrange("Set the layers", "Verse sparser than hook.", .rule, sections: ["Verse", "Hook"], lanes: lanes, loop: hook,
                  target: K.grid("xx", "xx", "-x", "xx", "-x")),
    ])

    static let hh53 = K.lesson("hiphop.hh5.3", "Hook Lift", "Make the hook bigger", "arrow.up.circle.fill", .arrangement, 20, [
        K.intro("Lift",
                "A hook needs to feel bigger than the verse. Add a layer, extra percussion, chops, or the full sample.",
                [], demo: hook),
        K.drumRule("Add percussion to the hook", "Rims on steps 4 and 12.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc],
                   start: boomBap, target: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: eighths, perc: [3, 11])),
        K.quiz("Which hook lifts more?", "", [
            K.hear([verse, hook], ["It lifts", "It doesn't"], 0),
            K.hear([verse, verse], ["It lifts", "It doesn't"], 1),
        ]),
    ])

    static let hh5b = K.lesson("hiphop.hh5.boss", "Verse, Hook, Change-Up Boss", "Boss: a full beat", "crown.fill", .arrangement, 40, [
        K.intro("Boss: the full beat",
                "Verse, hook, change-up. Put it together.", [], demo: hook),
        K.order("Map it", "Intro, verse, hook, change-up, hook.", .rule, tiles: sections(), answer: [0, 1, 2, 3, 2], barsEach: 2),
        K.arrange("Layers", "Your call. No two neighbours the same.", .create(.variedSections),
                  sections: ["Intro", "Verse", "Hook", "Change-up", "Hook"], lanes: lanes, loop: hook),
    ])

    // MARK: - HH6 · Song Project Finale

    static let hh6 = K.unit("hiphop.hh6", 6, "Song Project Finale", "Your first hip-hop beat", [hh6l])

    static let hh6l = K.lesson("hiphop.hh6", "Song Project Finale", "Your hip-hop beat", "flag.checkered", .arrangement, 60, [
        K.intro("Your beat",
                "Drums in the pocket, a sample flip, a bassline and two sections. Bronze guides you. Silver and Gold are yours.",
                [], demo: hook),
        K.drumRule("The drums", "Boom-bap with ghost rims.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   target: ghosts),
        K.order("The flip", "Copy this chop.", .recreate, tiles: sliceTiles(), answer: [0, 2, 0, 3], bed: boomBap),
        K.bassRule("The bass", "Follow the notes.", rows: rows, target: bass, backing: withBeat(slices[0])),
        K.order("The map", "Intro, verse, hook, verse, hook.", .rule, tiles: sections(), answer: [0, 1, 2, 1, 2], barsEach: 2),
    ])

    // MARK: - Silver and Gold

    static let levels: [String: LevelPair] = [
        "hiphop.hh1.1": (silver: [
            L.silver("Find it in the mess", "Busier beats hide the snare. Find it anyway."),
            K.tapAlong("Snares in a busy beat", "No lights.", loop: ghosts.merged(with: Pattern(hat: Array(0..<16))), bars: 5, steps: [4, 12],
                       guideBars: 0, label: "Snare", unit: "snares", sound: .clap),
            L.copy("Copy the beat", "Kick, snare, hats.", tracks: [.kick, .clap, .hat], edit: [.kick, .clap],
                   start: Pattern(hat: eighths), target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: eighths)),
            K.quiz("Backbeat or not?", "", [
                K.hear([Pattern(kick: [0, 10], clap: [8], hat: eighths)], ["Backbeat on 2 & 4", "Half-time snare on 3"], 1, bars: 2),
                K.hear([ghosts], ["Backbeat on 2 & 4", "Half-time snare on 3"], 0, bars: 2),
            ]),
        ], gold: [
            L.gold("Same backbeat, new texture",
                   "Keep the snare on 2 and 4 and change everything around it."),
            L.make("New texture", "Snare stays. Add rims, open hats, move kicks. At least three rims.",
                   tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .hat, .openHat, .perc], start: boomBap,
                   goal: .atLeast(.perc, 3)),
            K.tapAlong("Half-time", "The snare's only on beat 3 now. Tap it.", loop: Pattern(kick: [0, 10], clap: [8], hat: eighths),
                       bars: 5, steps: [8], guideBars: 0, label: "Snare", unit: "snares", sound: .clap),
        ]),
        "hiphop.hh1.2": (silver: [
            L.silver("Match the feel", "Hear the amount of swing and match it."),
            K.quiz("How much swing?", "", [
                K.hear([boomBap.merged(with: Pattern(hat: Array(0..<16)))], ["None", "Some", "Lots"], 2, bars: 2, swing: 0.38),
                K.hear([boomBap.merged(with: Pattern(hat: Array(0..<16)))], ["None", "Some", "Lots"], 1, bars: 2, swing: 0.15),
                K.hear([boomBap.merged(with: Pattern(hat: Array(0..<16)))], ["None", "Some", "Lots"], 0, bars: 2, swing: 0),
            ]),
            K.swingMake("Lay it back", "Go heavy.", tracks: [.kick, .clap, .hat],
                        start: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: Array(0..<16)), atLeast: 0.32),
        ], gold: [
            L.gold("Microtiming",
                   "Pros make one part feel late while the others stay tight. Here, rims sit just off the grid, so the swing makes them lope."),
            L.make("Loose rims", "Rims between the hats. At least four.", tracks: [.kick, .clap, .hat, .perc], edit: [.perc],
                   start: boomBap, goal: .atLeast(.perc, 4)),
            K.swingMake("Swing the whole thing", "Rims fill the gaps. Now swing everything past a quarter and hear them lope.", tracks: [.kick, .clap, .hat, .perc],
                        start: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: Array(0..<16), perc: [1, 5, 9, 13]), atLeast: 0.25),
        ]),
        "hiphop.hh1.3": (silver: [
            L.silver("Ghosts by ear", "Copy beats with quiet rim hits."),
            L.copy("Copy it", "Listen for the rims.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .perc],
                   start: Pattern(clap: [4, 12], hat: eighths), target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: eighths, perc: [7, 14])),
            L.copy("Another", "Different kick.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .perc],
                   start: Pattern(clap: [4, 12], hat: eighths), target: Pattern(kick: [0, 6, 9], clap: [4, 12], hat: eighths, perc: [3, 15])),
        ], gold: [
            L.gold("Your two-bar beat", "A main bar and a fill bar."),
            L.make("Main bar", "Your kicks. At least three.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .hat, .perc],
                   start: Pattern(clap: [4, 12]), goal: .atLeast(.kick, 3)),
            L.make("Fill bar", "Snares at the end. At least four.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   start: boomBap, goal: .atLeast(.clap, 4)),
        ]),
        "hiphop.hh1.boss": (silver: [
            L.silver("By ear, loose", "Two bars of feel."),
            L.copy("Bar 1", "The kick dodges around beat 1 and the second half. Rims hide between the hats.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc],
                   target: Pattern(kick: [0, 3, 10], clap: [4, 12], hat: eighths, perc: [7, 14]), threshold: 0.8),
            L.copy("Bar 2", "The fill bar: the snare rolls into the next bar and a rim sneaks in before it.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc], target: fill, threshold: 0.8),
        ], gold: [
            L.gold("Two pockets", "Tight and laid back from the same kit."),
            K.swingMake("Tight", "A little swing.", tracks: [.kick, .clap, .hat], start: Pattern(kick: [0, 7, 10], clap: [4, 12], hat: Array(0..<16)),
                        atLeast: 0.08),
            L.make("Laid back", "Fewer kicks, ghost rims. At least four rims.", tracks: [.kick, .clap, .hat, .perc],
                   edit: [.kick, .clap, .hat, .perc], start: Pattern(clap: [4, 12]), goal: .atLeast(.perc, 4)),
        ]),
        "hiphop.hh2.1": (silver: [
            L.silver("Phrase edges", "Where does a musical phrase start and end?"),
            K.quiz("Does it loop cleanly?", "", [
                K.hear([slices[0], slices[1]], ["Loops cleanly", "Cuts off"], 0, "Two whole bars. A clean loop."),
                K.hear([slices[3], slices[0]], ["Ends and restarts", "Cuts mid-phrase"], 0, "Slice D falls home, so A restarts naturally."),
            ]),
            K.order("Find the loop", "Two slices that loop well together.", .recreate, tiles: sliceTiles(), answer: [0, 1, 0, 1], bed: boomBap),
        ], gold: [
            L.gold("Find your own", "Pick a segment and build a rough loop from it."),
            K.order("Your loop", "Eight bars.", .create(.chordsAtLeast(8)), tiles: sliceTiles(), slots: 8, bed: boomBap),
        ]),
        "hiphop.hh2.2": (silver: [
            L.silver("From memory", "No labels on the order. Rebuild chops by ear."),
            K.order("Copy this chop", "Four slices, one repeats. Listen for which chord starts each bar.", .recreate, tiles: sliceTiles(), answer: [1, 3, 1, 0], bed: boomBap),
            K.chops("Copy the vocal chops", "Five chops land on the beat grid. Count where each one starts and which vowel it sings.", .recreate, chops, backing: beatBass, target: [0: 1, 4: 0, 8: 2, 12: 3]),
        ], gold: [
            L.gold("Your flip", "Four to eight slices in a new order."),
            K.order("Your chop", "Eight bars.", .create(.chordsAtLeast(8)), tiles: sliceTiles(), slots: 8, bed: beatBass),
            K.chops("Your vocal chops", "At least five.", .create(.chordsAtLeast(5)), chops, backing: beatBass),
        ]),
        "hiphop.hh2.3": (silver: [
            L.silver("Pitch plus rhythm", "Copy a flip that uses both."),
            K.order("Copy the flip", "Some slices are pitched. Listen for higher and darker versions of A and C.", .recreate,
                    tiles: [K.tile("A", slices[0]), K.tile("A down", shift(slices[0], -3)), K.tile("C", slices[2]), K.tile("C up", shift(slices[2], 2))],
                    answer: [1, 1, 3, 0], bed: boomBap),
        ], gold: [
            L.gold("Two identities", "Make a dark flip and a bright flip from the same source."),
            K.order("Dark flip", "Only pitched-down slices. Make four bars that feel heavy and late-night.", .create(.chordsAtLeast(4)),
                    tiles: [K.tile("A down", shift(slices[0], -3)), K.tile("B down", shift(slices[1], -3)), K.tile("D down", shift(slices[3], -5))],
                    slots: 4, bed: boomBap),
            K.order("Bright flip", "Only pitched-up slices. Make four bars that feel bright and urgent.", .create(.chordsAtLeast(4)),
                    tiles: [K.tile("A up", shift(slices[0], 3)), K.tile("C up", shift(slices[2], 2)), K.tile("D up", shift(slices[3], 4))],
                    slots: 4, bed: boomBap),
        ]),
        "hiphop.hh2.boss": (silver: [
            L.silver("Edit the flip", "New order and pitch."),
            K.order("Your flip", "Mix original and pitched slices. Four bars that sound like your flip, not the record.", .create(.chordsAtLeast(4)),
                    tiles: sliceTiles() + [K.tile("A down", shift(slices[0], -3)), K.tile("C up", shift(slices[2], 2))], slots: 4, bed: beatBass),
        ], gold: [
            L.gold("Two chops, one source", "Two strikingly different flips."),
            K.order("Flip 1", "Originals only. Four bars in any order.", .create(.chordsAtLeast(4)), tiles: sliceTiles(), slots: 4, bed: boomBap),
            K.order("Flip 2", "Use the pitched slices.", .create(.chordsAtLeast(4)),
                    tiles: [K.tile("A down", shift(slices[0], -3)), K.tile("B up", shift(slices[1], 2)), K.tile("C down", shift(slices[2], -5)),
                            K.tile("D up", shift(slices[3], 3))], slots: 4, bed: ghosts),
        ]),
        "hiphop.hh3.1": (silver: [
            L.silver("Roots by ear", "Find the bass for each slice."),
            L.bass("Under slice C", "Slice C is a B flat chord. Find its root down low and hold it.", [NoteEvent(0, 46, 8)], backing: withBeat(slices[2]), rows: [50, 48, 46, 45, 43, 41, 38]),
            L.bass("Two placements", "Root on two kicks without masking.", [NoteEvent(0, 43, 6), NoteEvent(10, 43, 4)],
                   backing: withBeat(slices[1])),
        ], gold: [
            L.gold("Lead into the next chord", "A passing note at the end of a bar pulls toward the next root."),
            L.bass("Hear the passing note", "D, then C walking to the next bar.", [NoteEvent(0, 38, 6), NoteEvent(7, 38, 3), NoteEvent(14, 48, 2)],
                   backing: withBeat(slices[0])),
            L.bassMake("Your bass", "At least five notes with a passing note.", backing: withBeat(slices[0]), notes: 5),
        ]),
        "hiphop.hh3.2": (silver: [
            L.silver("Longer grooves", "By ear."),
            L.bass("Copy it", "Five notes that bounce around the kick. Get the first and last right, then fill the middle.", [NoteEvent(0, 38, 2), NoteEvent(3, 38), NoteEvent(7, 41), NoteEvent(10, 43, 2), NoteEvent(14, 36, 2)],
                   backing: boomBap),
        ], gold: [
            L.gold("Answer with silence", "Extend the motif into an answering phrase. Leave space."),
            K.bassMake("Answer", "At least four notes.", rows: rows, backing: boomBap, notes: 4,
                       start: [NoteEvent(0, 38, 3), NoteEvent(7, 41)]),
        ]),
        "hiphop.hh3.3": (silver: [
            L.silver("Edit the motif", "Fix a dull hook."),
            K.fixNotes("Make it pop", "Change the last note to jump up.", rows: lead,
                       broken: K.tune([(0, 69, 2), (2, 72, 2), (4, 69, 4), (12, 69, 4)]),
                       target: K.tune([(0, 69, 2), (2, 72, 2), (4, 69, 4), (12, 77, 4)]), backing: beatBass, voice: .lead),
            K.leadCopy("Copy a hook", "Two quick repeats, then it falls. The last note is long.", rows: lead, target: K.tune([(0, 74, 1), (2, 74, 1), (4, 72, 2), (8, 69, 2), (11, 67, 5)]), backing: beatBass),
        ], gold: [
            L.gold("Your hook, twice", "Write it, then write a second version that changes one thing."),
            K.leadMake("Hook", "At least five notes.", rows: lead, backing: beatBass, notes: 5),
            K.leadMake("Hook, take two", "At least six notes. Change the ending.", rows: lead, backing: beatBass, notes: 6),
        ]),
        "hiphop.hh3.boss": (silver: [
            L.silver("Interlock", "Bass and sample must lock together."),
            L.bass("The bass", "Root, a pickup with the kick, a jump up, then a lead-in at the end.", [NoteEvent(0, 38, 3), NoteEvent(7, 38), NoteEvent(10, 41, 2), NoteEvent(14, 43, 2)], backing: withBeat(slices[0])),
            K.chops("The chops", "Four chops, one on each offbeat quarter. Listen to the vowels.", .recreate, chops, backing: beatBass, target: [2: 0, 6: 2, 10: 1, 14: 3]),
        ], gold: [
            L.gold("Eight bars of you", "A recognisable beat with its own hook."),
            L.bassMake("Bass", "At least five notes.", backing: withBeat(slices[0]), notes: 5),
            K.leadMake("Hook", "At least six notes.", rows: lead, backing: beatBass, notes: 6),
        ]),
        "hiphop.hh4.1": (silver: [
            L.silver("Choose the kit", "Which kick suits each beat?"),
            K.quiz("Which kick fits?", "", [
                K.sound(withBeat(slices[0]), warm, ["Fits the soul sample", "Too harsh"], 0),
                K.sound(withBeat(slices[0]), [.kickDrive: 1, .kickPitch: 0.9], ["Fits the soul sample", "Too harsh"], 1),
            ]),
            K.lab("Match the kick", "The target is warm: low pitch, long tail, little drive. Start with Pitch.", [.kickPitch, .kickDecay, .kickDrive], start: [0.8, 0.1, 0.9], target: [0.2, 0.65, 0.2], loop: boomBap),
        ], gold: [
            L.gold("Your kit", "Kick and snare from different worlds."),
            K.lab("Your kick", "Shape a kick for your beat. Round and heavy, or short and snappy.", [.kickPitch, .kickDecay, .kickDrive], start: [0.5, 0.5, 0.5], loop: boomBap),
            K.mix("Balance kick and snare", "Set the kick, snare and hats so the snare cracks without burying the kick.", [.drum(.kick), .drum(.clap), .drum(.hat)], start: [K.u, K.u, K.u], loop: boomBap),
        ]),
        "hiphop.hh4.2": (silver: [
            L.silver("Match the texture", "Hear a filtered sample and dial in the same dusty sound."),
            K.filterMatch("Match it", "Dark but not muffled. Find the cutoff, then add a touch of resonance.", cutoff: 1200, resonance: 0.15, loop),
            K.lab("Darken the keys", "Pull the keys' brightness down until they sit behind the drums.", [.chordCutoff], start: [0.9], target: [0.35], loop: loop),
        ], gold: [
            L.gold("Texture with room for drums", "Filter the sample so the drums cut through."),
            K.lab("Sample texture", "Darken the sample and shorten it until the drums cut through.", [.chordCutoff, .chordDecay], start: [0.9, 0.5], loop: loop),
            K.mix("Drums on top", "Balance the drums over your sample.", [.drum(.kick), .drum(.clap), .chords], start: [K.u, K.u, K.u], loop: loop),
        ]),
        "hiphop.hh4.3": (silver: [
            L.silver("Fills and drop-outs", "Without breaking the phrase."),
            K.order("Copy the arrangement", "Beat, fill, beat, drop-out. Rebuild the four bars from the reference.", .recreate, tiles: [K.tile("Beat", boomBap), K.tile("Fill", fill), K.tile("Drop-out", dropout)],
                    answer: [0, 1, 0, 2]),
        ], gold: [
            L.gold("Two surprises", "Two distinct fills, placed in different spots."),
            L.make("Fill 1", "Kick and snare build to the end of the bar. At least four snares.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc], start: boomBap, goal: .atLeast(.clap, 4)),
            K.order("Place them", "Eight bars.", .create(.chordsAtLeast(8)),
                    tiles: [K.tile("Beat", boomBap), K.tile("Fill", fill), K.tile("Drop-out", dropout)], slots: 8),
        ]),
        "hiphop.hh4.boss": (silver: [
            L.silver("Rebalance", "One edit."),
            K.mix("Fix the mix", "The sample is too loud.", [.drum(.kick), .drum(.clap), .bass, .chords], start: [0.5, 0.5, 0.5, 1],
                  target: [0.75, 0.7, 0.65, 0.5], loop: loop),
        ], gold: [
            L.gold("Polish", "Space and texture, your way."),
            K.lab("Texture", "Darken the keys and the bass until it sounds like an old record.", [.chordCutoff, .bassCutoff], start: [0.5, 0.5], loop: loop),
            K.mix("Final balance", "Every channel. Drums on top, sample behind, bass solid.", [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords], start: [K.u, K.u, K.u, K.u, K.u], loop: loop),
        ]),
        "hiphop.hh5.1": (silver: [
            L.silver("No labels", "Spot section changes."),
            K.order("Label the sections", "Four sections, two bars each. Some repeat.", .recreate, tiles: sections(), answer: [0, 1, 2, 1], barsEach: 2),
        ], gold: [
            L.gold("Your hook contrast", "Make the hook stand apart from the verse."),
            K.arrange("Verse and hook", "Four sections. The hook needs at least one more layer than the verse.", .create(.variedSections), sections: ["Verse", "Hook", "Verse", "Hook"], lanes: lanes, loop: hook),
        ]),
        "hiphop.hh5.2": (silver: [
            L.silver("Two verses, one hook", "Real beats vary the second verse so it doesn't feel like a copy-paste."),
            L.make("Verse 2 drums", "A second verse should feel familiar but not identical. Change the kicks or add rims.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .hat, .perc], start: boomBap, goal: .atLeast(.kick, 3)),
            K.order("Map it", "Six blocks: intro, two verses, two hooks and a drop-out. Rebuild it.", .recreate, tiles: sections(), answer: [0, 1, 2, 1, 2, 4], barsEach: 2),
        ], gold: [
            L.gold("Full structure", "Intro, verses, hooks and a change-up."),
            K.order("Your map", "Ten blocks.", .create(.variedSections), tiles: sections(), slots: 10, barsEach: 2),
        ]),
        "hiphop.hh5.3": (silver: [
            L.silver("Lift without clutter", "Add one, remove one."),
            K.arrange("Copy the lift", "The hook adds the bass and chords but loses the hats. Recreate it.", .recreate, sections: ["Verse", "Hook"], lanes: lanes, loop: hook,
                      target: K.grid("xx", "xx", "x-", "xx", "-x")),
        ], gold: [
            L.gold("Two lifts", "Build two hook versions and keep the clearer one."),
            K.arrange("Lift A", "Make the hook clearly bigger than the verse.", .create(.variedSections), sections: ["Verse", "Hook"], lanes: lanes, loop: hook),
            K.chops("Lift B: chops", "Add chops to the hook.", .create(.chordsAtLeast(4)), chops, backing: hook),
        ]),
        "hiphop.hh5.boss": (silver: [
            L.silver("Add a drop-out", "A one-bar drop-out right before a hook makes it land twice as hard."),
            K.order("Map with a drop-out", "Eight blocks with at least one drop-out right before a hook.", .create(.variedSections), tiles: sections(), slots: 8, barsEach: 2),
        ], gold: [
            L.gold("Your beat", "Verse, hook, verse, with a recognisable change-up."),
            K.order("Your map", "Twelve blocks.", .create(.variedSections), tiles: sections(), slots: 12, barsEach: 2),
            K.arrange("Layers", "Six sections. No two neighbours the same.", .create(.variedSections), sections: ["Intro", "Verse", "Hook", "Change-up", "Hook", "Outro"],
                      lanes: lanes, loop: hook),
        ]),
        "hiphop.hh6": (silver: [
            L.silver("Make it yours", "Hook contrast, variations and clear levels."),
            L.make("Your drums", "Your boom-bap. Snare stays on 2 and 4.", tracks: [.kick, .clap, .hat, .perc], edit: [.kick, .clap, .hat, .perc], start: Pattern(clap: [4, 12]),
                   goal: .atLeast(.kick, 3)),
            K.order("Your flip", "Four bars of your chop.", .create(.chordsAtLeast(4)), tiles: sliceTiles(), slots: 4, bed: boomBap),
            K.mix("Levels", "Drums on top, sample clear, bass solid.", [.drum(.kick), .drum(.clap), .bass, .chords], start: [K.u, K.u, K.u, K.u], loop: loop),
        ], gold: [
            L.gold("Finish it", "One to two minutes, an identifiable flip, transitions and contrasting sections."),
            L.make("Your drums", "Every drum is yours.", tracks: [.kick, .clap, .hat, .openHat, .perc], edit: [.kick, .clap, .hat, .openHat, .perc],
                   goal: .atLeast(.kick, 3)),
            K.order("Your flip", "Eight bars, originals and pitched.", .create(.chordsAtLeast(8)),
                    tiles: sliceTiles() + [K.tile("A down", shift(slices[0], -3))], slots: 8, bed: boomBap),
            L.bassMake("Your bass", "Lock the bass to your flip. At least five notes.", backing: withBeat(slices[0]), notes: 5),
            K.order("Your map", "Fourteen blocks.", .create(.variedSections), tiles: sections(), slots: 14, barsEach: 2),
        ]),
    ]
}
