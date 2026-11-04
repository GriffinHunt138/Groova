//
//  AcademyKit.swift
//  Groova
//
//  Lessons every genre academy needs, written once and filled in with each genre's own
//  sounds, loops and teaching: what makes the genre, the anatomy of a track, vocal chops,
//  turning a loop into a track, mixing the genre, and the final project.
//

import Foundation

/// Everything the shared academy lessons need to know about one genre.
nonisolated struct AcademyStyle: Sendable {
    let genre: Genre
    /// Lesson id prefix, like "house" or "ukg".
    let id: String
    let drums: Pattern
    let full: Pattern
    let rows: [Int]
    let lanes: [Instrument]
    /// Four sections. Index 2 is always the break.
    let sections: [String]
    /// lanes x sections: how a typical track in this genre is laid out.
    let anatomy: [[Bool]]
    /// Two genres to tell this one apart from.
    let neighbours: [Genre]
    let palette: [ChordShape]

    let what: String
    let tempoText: String
    let anatomyText: String
    let mixText: String
    let pumpText: String
    let finishText: String

    var vocal: Vocal? = nil
    let mix: Mix

    nonisolated struct Vocal: Sendable {
        let text: String
        let chops: [VoxChop]
        let backing: Pattern
        let length: Int
        let rule: [Int: Int]
        let ruleHint: String
        let rhythm: [Int: Int]
        let rhythm2: [Int: Int]
        let hook: [Int: Int]
        let hook2: [Int: Int]
        var vox = VoxSettings()
    }

    nonisolated struct Mix: Sendable {
        let channels: [MixChannel]
        let start: [Double]
        let target: [Double]
        let pumpLoop: Pattern
        let pump: Double
        let cutoff: Double
        let resonance: Double
        let lab: [SoundParam]
        let labStart: [Double]
        let labTarget: [Double]
        let labLoop: Pattern
        let labText: String
    }

    var name: String { genre.name }
    var tracks: [DrumTrack] { DrumTrack.allCases.filter { full.hits($0) > 0 } }
}

nonisolated enum AcademyKit {

    // MARK: Foundations

    static func identify(_ s: AcademyStyle) -> [EarRound] {
        let all = [s.genre] + s.neighbours
        let names = all.map(\.name)
        return all.enumerated().map { i, g in
            K.hear([g.demoPattern], names, i, "\(g.name): " + g.traits.joined(separator: ", ").lowercased() + ".",
                   bars: 2, genre: g)
        }
    }

    static func whatMakes(_ s: AcademyStyle) -> Lesson {
        K.lesson("\(s.id).acad.what", "What Makes It \(s.name)", "Sound, tempo & feel", s.genre.symbol, .rhythm, 25, [
            K.intro("What makes \(s.name)", s.what, [], demo: s.full),
            K.quiz("Which genre is it?",
                   "Each loop is a different genre. Listen for the tempo, where the kicks land and how much it swings.",
                   identify(s)),
            K.tempo("Set the \(s.name) tempo", s.tempoText, loop: s.drums, target: s.genre.bpm,
                    start: s.genre.bpm > 125 ? 110 : 140, swing: s.genre.swing),
        ])
    }

    /// The columns of a grid as loops, so a quiz can play one section at a time.
    private static func section(_ s: AcademyStyle, _ col: Int) -> Pattern {
        let t = ArrangementTask(prompt: "", hint: "", mode: .rule, sections: s.sections, lanes: s.lanes, loop: s.full,
                                target: s.anatomy)
        let p = t.patterns(s.anatomy)
        return col < p.count ? p[col] : s.full
    }

    static func anatomy(_ s: AcademyStyle) -> Lesson {
        K.lesson("\(s.id).acad.anatomy", "Anatomy of a \(s.name) Track", "How the parts come and go",
                 "rectangle.split.3x1.fill", .arrangement, 30, [
            K.intro("Anatomy of a track", s.anatomyText, [], demo: s.full),
            K.quiz("Which section is this?", "Each loop is one section of the same track. Which part of the track is it?", [
                K.hear([section(s, 0)], s.sections, 0, "Stripped back, so a DJ can mix it in."),
                K.hear([section(s, 2)], s.sections, 2, "The kick's gone. That's the break."),
                K.hear([section(s, 3)], s.sections, 3),
            ]),
            K.arrange("Map the track by ear", "Listen to each section and switch on the parts you hear.", .recreate,
                      sections: s.sections, lanes: s.lanes, loop: s.full, target: s.anatomy),
        ])
    }

    static func foundationsCheck(_ s: AcademyStyle) -> Lesson {
        let edit = Set(s.tracks.filter { s.drums.hits($0) > 0 })
        return K.mastery("\(s.id).acad.check", "\(s.name) Foundations", "Prove you know the sound", .rhythm, 60, [
            K.quiz("Spot the \(s.name)", "One more time, in a new order.", Array(identify(s).reversed())),
            K.drumCopy("Rebuild the \(s.name) groove", "Every drum, by ear. Start with the kick.",
                       tracks: s.tracks, edit: edit, target: s.drums.keeping(edit, bass: false, chords: false)),
            K.tempo("Find the tempo by ear", "Lock your loop to the reference.", loop: s.drums, target: s.genre.bpm,
                    start: s.genre.bpm > 125 ? 112 : 138, byEar: true, swing: s.genre.swing),
        ])
    }

    // MARK: Vocals

    static func chopIntro(_ s: AcademyStyle) -> Lesson? {
        guard let v = s.vocal else { return nil }
        return K.lesson("\(s.id).acad.chops", "Vocal Chops", "Slice a voice into rhythm", "waveform.and.mic", .soundDesign, 30, [
            K.intro("Chop it up", v.text, [], demo: s.full),
            K.chops("Place your first chops", v.ruleHint, .rule, v.chops, backing: v.backing, target: v.rule,
                    length: v.length, vox: v.vox),
            K.chops("Copy the chop rhythm", "Two different chops. Listen for which vowel lands where.", .recreate, v.chops,
                    backing: v.backing, target: v.rhythm, length: v.length, vox: v.vox),
        ])
    }

    static func chopRhythm(_ s: AcademyStyle) -> Lesson? {
        guard let v = s.vocal else { return nil }
        return K.lesson("\(s.id).acad.chopRhythm", "Chop Rhythms", "Syncopated vocals", "metronome.fill", .rhythm, 30, [
            K.intro("Rhythm first",
                    "A vocal hook is a rhythm before it's a melody. Put chops just before or after the kick and they push and pull against the beat. Keep one or two in the same place every bar so the ear has something to hold on to.",
                    []),
            K.chops("Copy this vocal rhythm", "Some chops land on the beat, some dodge it. Count the steps.", .recreate, v.chops,
                    backing: v.backing, target: v.rhythm2, length: max(1, v.length - 1), vox: v.vox),
            K.chops("Make it bounce", "Place at least four chops, mostly off the beat.", .create(.chordsAtLeast(4)), v.chops,
                    backing: v.backing, length: max(1, v.length - 1), vox: v.vox),
        ])
    }

    static func chopHook(_ s: AcademyStyle) -> Lesson? {
        guard let v = s.vocal else { return nil }
        return K.lesson("\(s.id).acad.hook", "Write a Vocal Hook", "A topline from chops", "music.mic", .theory, 30, [
            K.intro("The hook",
                    "A hook is the bit people sing back. With chops, that means a short pattern of pitches that repeats. Change one chop near the end of the bar, and it feels like an answer.",
                    [], demo: s.full),
            K.chops("Copy the hook", "Four chops on different notes. Listen to the pitch as well as the timing.", .recreate,
                    v.chops, backing: v.backing, target: v.hook, length: v.length, vox: v.vox),
            K.chops("Write your own hook", "Use at least three different chops and five hits in total.", .create(.chordsAtLeast(5)),
                    v.chops, backing: v.backing, length: v.length, vox: v.vox),
        ])
    }

    static func vocalMastery(_ s: AcademyStyle) -> Lesson? {
        guard let v = s.vocal else { return nil }
        return K.mastery("\(s.id).acad.voxMastery", "Vocal Mastery", "Recreate a chopped hook", .soundDesign, 80, [
            K.chops("Recreate the hook", "Six chops. Get the rhythm first, then fix the notes.", .recreate, v.chops,
                    backing: v.backing, target: v.hook2, length: v.length, vox: v.vox),
            K.chops("Answer it", "Write your own hook that answers the one you just copied.", .create(.chordsAtLeast(5)),
                    v.chops, backing: v.backing, start: [:], length: v.length, vox: v.vox),
        ])
    }

    // MARK: Arrangement

    /// The break column without the kick, the first column with only kick and hats.
    private static func subtracted(_ s: AcademyStyle) -> [[Bool]] {
        s.lanes.map { lane in
            (0..<s.sections.count).map { col in
                switch col {
                case 0: lane == .drum(.kick) || lane == .drum(.hat)
                case 2: lane != .drum(.kick)
                default: true
                }
            }
        }
    }

    static func loopToTrack(_ s: AcademyStyle) -> Lesson {
        let all = s.lanes.map { _ in s.sections.map { _ in true } }
        return K.lesson("\(s.id).acad.finish", "From 8 Bars to a Track", "Finish the loop", "rectangle.expand.vertical",
                        .arrangement, 35, [
            K.intro("Finish it", s.finishText, [], demo: s.full),
            K.arrange("Start full, then subtract",
                      "In the \(s.sections[0]), switch off everything except the kick and hats. In the \(s.sections[2]), switch off the kick.",
                      .rule, sections: s.sections, lanes: s.lanes, loop: s.full, start: all, target: subtracted(s)),
            K.arrange("Arrange the whole track",
                      "Every section different from the one before. Think about the energy: low, rising, a dip, then the peak.",
                      .create(.variedSections), sections: s.sections, lanes: s.lanes, loop: s.full, start: all),
        ])
    }

    // MARK: Mixing

    static func mixBalance(_ s: AcademyStyle) -> Lesson {
        K.lesson("\(s.id).acad.mix", "Mixing \(s.name)", "Levels that hit", "slider.vertical.3", .mixing, 35, [
            K.intro("Mixing \(s.name)", s.mixText, [], demo: s.full),
            K.mix("Balance the loop", "Everything's off. Set the kick first, then fit the rest around it.",
                  s.mix.channels, start: s.mix.start, target: s.mix.target, loop: s.full),
            K.lab(s.mix.labText, "Shape the sound so it sits right in a \(s.name) mix.", s.mix.lab,
                  start: s.mix.labStart, target: s.mix.labTarget, loop: s.mix.labLoop),
        ])
    }

    static func mixPump(_ s: AcademyStyle) -> Lesson {
        K.lesson("\(s.id).acad.pump", "Pump & Glue", "Sidechain, \(s.name) style", "waveform.path.ecg", .mixing, 35, [
            K.intro("The pump", s.pumpText, [], demo: s.full),
            K.mix("Set the pump", "Turn up Pump until it matches the reference.", [.bass, .chords, .sidechain],
                  start: [K.u, K.u, 0], target: [K.u, K.u, s.mix.pump], loop: s.mix.pumpLoop),
            K.mix("Bass, pump and kick", "The kick leads. Find the bass level and the pump together.",
                  [.drum(.kick), .bass, .sidechain], start: [K.u, 0.25, 0.9],
                  target: [K.u, 0.65, max(0.2, s.mix.pump - 0.15)], loop: s.full),
        ])
    }

    static func mixSpace(_ s: AcademyStyle) -> Lesson {
        K.lesson("\(s.id).acad.space", "Space & Tone", "Reverb, filter & polish", "sparkles.rectangle.stack.fill", .mixing, 35, [
            K.space("Add some space",
                    "Reverb puts a sound in a room. A little makes the mix feel real. Too much pushes everything to the back. Find the amount that suits \(s.name).",
                    s.full),
            K.filterMatch("Match the filter", "Filters tame harsh highs and make room. Cutoff first, then resonance.",
                          cutoff: s.mix.cutoff, resonance: s.mix.resonance, s.full),
            K.mix("Final balance", "One last pass. Listen at low volume: if a part disappears, it's too quiet.",
                  s.mix.channels, start: s.mix.channels.map { _ in K.u }, target: s.mix.target, loop: s.full),
        ])
    }

    // MARK: Final project

    static func finalProject(_ s: AcademyStyle) -> Lesson {
        var steps: [LessonStep] = [
            K.drumMake("Write the drums", "A \(s.name) groove of your own. Use every drum you need.",
                       tracks: s.tracks, edit: Set(s.tracks), goal: .atLeast(.kick, 2)),
            K.bassMake("Write the bass", "Lock it to the kick. At least five notes.", rows: s.rows,
                       backing: s.drums, notes: 5),
        ]
        if let v = s.vocal {
            steps.append(K.chops("Add a vocal hook", "At least four chops.", .create(.chordsAtLeast(4)), v.chops,
                                 backing: v.backing, length: v.length, vox: v.vox))
        } else {
            steps.append(K.lane("Add a stab", "At least three hits. Less is more.", .create(.chordsAtLeast(3)),
                                palette: s.palette, backing: s.drums))
        }
        steps += [
            K.arrange("Arrange the track", "Four sections, each one different from the last.", .create(.variedSections),
                      sections: s.sections, lanes: s.lanes, loop: s.full),
            K.mix("Mix it", "Set every fader by ear. Trust your ears.", s.mix.channels,
                  start: s.mix.channels.map { _ in K.u }, loop: s.full),
        ]
        return K.mastery("\(s.id).acad.final", "Final Project", "Finish a full \(s.name) track", .arrangement, 120, steps)
    }

    // MARK: Styles

    static let house = AcademyStyle(
        genre: .house, id: "house", drums: HouseCourse.drums, full: HouseCourse.full, rows: HouseCourse.rows,
        lanes: K.fullHouseLanes, sections: ["Intro", "Groove", "Break", "Drop"],
        anatomy: K.grid("xx-x", "-x-x", "xxxx", "-x-x", "--xx"),
        neighbours: [.deepHouse, .techno], palette: [.am7, .dm7],
        what: "House was born in Chicago in the early '80s, when DJs mixed disco records with drum machines. Its signature: a four-on-the-floor kick, a clap on 2 and 4, open hats on the offbeats, and warm chords or a soulful vocal on top. It runs at 120 to 128 BPM.",
        tempoText: "House sits between 120 and 128 BPM. 124 is the sweet spot for dancing.",
        anatomyText: "A house track usually runs Intro, Groove, Break, Drop, in phrases of 8 or 16 bars. The intro is kick and hats so DJs can mix it in. The groove adds claps and bass. The break pulls the kick out and lets the chords breathe. The drop brings everything back at once.",
        mixText: "House mixes are warm and punchy. The kick and bass share the low end, the clap sits just behind the kick, and the hats stay bright but polite.",
        pumpText: "House pumps, but gently. A little sidechain on the bass and chords lets the kick breathe without making everything wobble.",
        finishText: "A house loop becomes a track by taking things away. Copy the full loop across the timeline, strip the start back for DJs, drop the kick for a breakdown, and slam it all back in for the drop.",
        vocal: AcademyStyle.Vocal(
            text: "Vocal chops are tiny slices of a singer, retuned and played like drums. House loves a soulful \"oh\" or \"yeah\" answering the kick. Each pad is one sung slice on its own note. Tap them to hear each one.",
            chops: ChopSong.chops([69, 72, 76, 67]), backing: HouseCourse.melodyBed, length: 2,
            rule: [2: 0, 6: 0, 10: 0, 14: 0], ruleHint: "\"Oh\" on every offbeat: steps 3, 7, 11 and 15, between the kicks.",
            rhythm: [2: 1, 6: 0, 10: 1, 13: 0], rhythm2: [0: 0, 3: 1, 6: 2, 10: 0, 14: 1],
            hook: [2: 0, 4: 1, 7: 2, 10: 0, 12: 3], hook2: [0: 1, 3: 0, 6: 2, 8: 1, 11: 3, 14: 0]),
        mix: AcademyStyle.Mix(channels: [.drum(.kick), .drum(.clap), .drum(.hat), .bass, .chords],
                   start: [K.u, 0.25, 0.95, 0.3, 0.9], target: [K.u, 0.6, 0.45, 0.6, 0.5],
                   pumpLoop: HouseCourse.full, pump: 0.45, cutoff: 2500, resonance: 0.3,
                   lab: [.chordCutoff, .chordDecay], labStart: [0.85, 0.7], labTarget: [0.5, 0.3],
                   labLoop: HouseCourse.stabLoop, labText: "Tame the stabs"))

    static let deep = AcademyStyle(
        genre: .deepHouse, id: "deep", drums: DeepHouseCourse.drums, full: DeepHouseCourse.full,
        rows: DeepHouseCourse.rows, lanes: DeepHouseCourse.lanes, sections: DeepHouseCourse.sections,
        anatomy: K.grid("xx-x", "-x--", "xxxx", "-x-x", "xxxx"),
        neighbours: [.house, .ukGarage], palette: [.fm9, .dbmaj7],
        what: "Deep house slowed house down and soaked it in jazz and soul. Softer kicks, rimshots instead of big claps, lazy swing, and lush seventh and ninth chords that hang in the air. It runs at 118 to 124 BPM.",
        tempoText: "Deep house is relaxed: 118 to 124 BPM. Set it to 120 and feel how much space each beat has.",
        anatomyText: "Deep house takes its time. A long intro, a groove that barely changes, a break where the chords play alone, and a gentle outro. The magic is in tiny changes over a long time.",
        mixText: "Deep house mixes are warm and soft. The kick is round, not punchy. Chords sit forward and wide, and nothing should feel harsh.",
        pumpText: "Just a touch of pump in deep house. The chords should breathe with the kick, not bounce.",
        finishText: "Deep house tracks are long, so a loop has to last. Keep the full groove going, then let parts drift in and out every 16 bars. Subtle changes keep it hypnotic.",
        vocal: AcademyStyle.Vocal(
            text: "Deep house vocals are soft and breathy: a sigh, a hum, a single word drenched in reverb. Space them out. The silence around them is what makes them feel intimate.",
            chops: ChopSong.chops([65, 68, 72, 63]), backing: DeepHouseCourse.padLoop, length: 3,
            rule: [3: 0, 11: 0], ruleHint: "Two soft \"oh\"s, one in each half of the bar: steps 4 and 12.",
            rhythm: [3: 0, 7: 1, 11: 0], rhythm2: [0: 2, 6: 0, 10: 1, 14: 0],
            hook: [2: 0, 6: 1, 10: 2, 13: 3], hook2: [0: 1, 3: 0, 6: 2, 9: 1, 12: 3, 14: 0],
            vox: VoxSettings(formant: 0.95, breath: 0.25, vibrato: 0.16, robot: false, attack: 0.02, gain: 0.5)),
        mix: AcademyStyle.Mix(channels: [.drum(.kick), .drum(.perc), .bass, .chords],
                   start: [K.u, 0.95, 0.2, 0.3], target: [K.u, 0.45, 0.6, 0.8],
                   pumpLoop: DeepHouseCourse.full, pump: 0.3, cutoff: 1600, resonance: 0.25,
                   lab: [.kickPitch, .kickDecay], labStart: [0.7, 0.2], labTarget: [0.3, 0.55],
                   labLoop: HouseCourse.kickLoop, labText: "Soften the kick"))

    static let techno = AcademyStyle(
        genre: .techno, id: "techno", drums: TechnoCourse.groove, full: TechnoCourse.full, rows: TechnoCourse.rows,
        lanes: TechnoCourse.lanes, sections: TechnoCourse.sections,
        anatomy: K.grid("xx-x", "xxxx", "-xxx", "-xxx", "-x-x"),
        neighbours: [.techHouse, .house], palette: [.am7],
        what: "Techno came out of Detroit in the mid '80s and found a second home in Berlin. It's hypnotic and machine-driven: a relentless kick, rolling sixteenth hats, a rumbling bass and loops that change slowly over minutes. It runs at 128 to 140 BPM.",
        tempoText: "Techno drives at 128 to 140 BPM. Set it to 132 and feel the push.",
        anatomyText: "Techno is about tension over time. A long intro, a groove that keeps evolving, a breakdown that holds its breath, then the slam where everything crashes back in.",
        mixText: "Techno mixes are big and heavy. The kick and rumble are the stars. Hats are crisp, percussion sits around them, and there's plenty of drive.",
        pumpText: "Techno uses sidechain to glue the rumble to the kick, so the whole low end moves as one.",
        finishText: "In techno, the loop is the track. Finishing means planning tension: what drops out, how long you hold the breakdown, and how hard the slam lands.",
        mix: AcademyStyle.Mix(channels: [.drum(.kick), .drum(.hat), .drum(.perc), .bass],
                   start: [K.u, 0.95, 0.9, 0.2], target: [K.u, 0.5, 0.45, 0.7],
                   pumpLoop: Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), bass: TechnoCourse.rolling,
                                     chords: [K.ch(2, .am7, 2), K.ch(10, .am7, 2)]),
                   pump: 0.6, cutoff: 900, resonance: 0.55,
                   lab: [.kickDrive, .kickDecay], labStart: [0.1, 0.2], labTarget: [0.8, 0.6],
                   labLoop: HouseCourse.kickLoop, labText: "Make the kick rumble"))

    static let techHouse = AcademyStyle(
        genre: .techHouse, id: "tech", drums: TechHouseCourse.drums, full: TechHouseCourse.full,
        rows: TechHouseCourse.rows, lanes: TechHouseCourse.lanes, sections: ["Intro", "Groove", "Break", "Drop"],
        anatomy: K.grid("xx-x", "-x-x", "xxxx", "xxxx", "-x-x"),
        neighbours: [.techno, .house], palette: [.cm7],
        what: "Tech house sits between house and techno: house's groove with techno's punch. A fat kick, a rolling bassline that bounces between the kicks, plenty of percussion and short, catchy vocal hooks. It runs at 124 to 128 BPM.",
        tempoText: "Tech house sits at 124 to 128 BPM. Set it to 126.",
        anatomyText: "Tech house is built for DJs: long, mixable intros, a groove driven by the bassline, and drops that slam the bass back in after a break.",
        mixText: "Tech house mixes are tight and loud. The kick and bass lock together, percussion fills the space around them, and the hats are crisp.",
        pumpText: "Tech house pumps the bass hard, so it rolls around the kick instead of sitting on top of it.",
        finishText: "Tech house is about the drop. Build your loop, then arrange it so the bass disappears in the break and lands back with the kick. That moment is the whole track.",
        vocal: AcademyStyle.Vocal(
            text: "Tech house vocals are short, catchy and repetitive: one word or phrase, chopped and looped until it's stuck in your head. Think of the chop as another percussion part that happens to sing.",
            chops: ChopSong.chops([60, 63, 67, 58]), backing: TechHouseCourse.full, length: 1,
            rule: [3: 1, 11: 1], ruleHint: "\"Yeah\" just before each clap: steps 4 and 12.",
            rhythm: [3: 1, 6: 0, 11: 1, 14: 0], rhythm2: [1: 0, 3: 1, 9: 0, 11: 1, 14: 2],
            hook: [2: 0, 3: 1, 7: 2, 10: 0, 14: 3], hook2: [0: 1, 3: 1, 6: 0, 9: 2, 11: 1, 14: 3],
            vox: VoxSettings(formant: 1.05, breath: 0.1, vibrato: 0.05, robot: false, attack: 0.004, gain: 0.55)),
        mix: AcademyStyle.Mix(channels: [.drum(.kick), .drum(.clap), .drum(.perc), .bass],
                   start: [K.u, 0.95, 0.2, 0.25], target: [K.u, 0.55, 0.5, 0.7],
                   pumpLoop: Pattern(kick: [0, 4, 8, 12], clap: [4, 12], bass: TechHouseCourse.rolling,
                                     chords: [K.ch(2, .cm7, 2), K.ch(10, .cm7, 2)]),
                   pump: 0.6, cutoff: 1800, resonance: 0.35,
                   lab: [.bassCutoff, .bassDecay], labStart: [0.8, 0.8], labTarget: [0.4, 0.25],
                   labLoop: Pattern(kick: [0, 4, 8, 12], hat: [2, 6, 10, 14], bass: TechHouseCourse.rolling),
                   labText: "Tighten the bass"))

    static let garage = AcademyStyle(
        genre: .ukGarage, id: "ukg", drums: GarageCourse.skippy, full: GarageCourse.full, rows: GarageCourse.rows,
        lanes: GarageCourse.lanes, sections: ["Intro", "Verse", "Break", "Drop"],
        anatomy: K.grid("-x-x", "xx-x", "xxxx", "-x-x", "xxx-"),
        neighbours: [.house, .techHouse], palette: [.em9, .am9],
        what: "UK garage came out of London in the '90s. It took American garage house and gave it a skipping, swung two-step beat: kicks that dodge beats 2 and 4, shuffled hats, bouncy bass and chopped, pitched vocals. It runs at 130 to 135 BPM.",
        tempoText: "Garage runs at 130 to 135 BPM with heavy swing. Set it to 132.",
        anatomyText: "Garage tracks are built like songs: an intro, a verse groove, a break, then the drop where the bass comes back. The vocals often carry the structure.",
        mixText: "Garage mixes are punchy and bouncy. The sub bass is heavy, the hats shuffle on top, and the vocals sit right up front.",
        pumpText: "Garage uses a quick pump so the sub bass bounces with every kick.",
        finishText: "Garage is a song as much as a groove. Turn your loop into a track by giving the verse a little less, the break a lot less, and saving the bass for the drop.",
        vocal: AcademyStyle.Vocal(
            text: "Vocal chops are the soul of garage. A sung phrase is sliced into pieces, pitched to new notes and played back in a swung rhythm. The rhythm of the chops matters as much as the notes.",
            chops: ChopSong.chops([64, 67, 71, 69]),
            backing: Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15], bass: GarageCourse.bassline),
            length: 1,
            rule: [3: 0, 7: 0, 11: 0, 15: 0], ruleHint: "\"Oh\" on the last sixteenth of each beat: steps 4, 8, 12 and 16. The swing pushes them late.",
            rhythm: [2: 1, 3: 0, 7: 1, 11: 0], rhythm2: [0: 0, 3: 1, 6: 0, 9: 2, 13: 1],
            hook: [1: 0, 3: 1, 6: 2, 9: 3, 11: 0], hook2: [0: 2, 2: 1, 5: 0, 7: 2, 10: 3, 13: 1],
            vox: VoxSettings(formant: 1.12, breath: 0.08, vibrato: 0.08, robot: false, attack: 0.004, gain: 0.55)),
        mix: AcademyStyle.Mix(channels: [.drum(.kick), .drum(.hat), .bass, .chords],
                   start: [K.u, 0.95, 0.2, 0.9], target: [K.u, 0.5, 0.75, 0.5],
                   pumpLoop: GarageCourse.full, pump: 0.4, cutoff: 3000, resonance: 0.3,
                   lab: [.bassCutoff, .bassEnv], labStart: [0.8, 0.7], labTarget: [0.3, 0.2],
                   labLoop: Pattern(kick: [0, 10], hat: [2, 3, 6, 7, 10, 11, 14, 15], bass: GarageCourse.bassline),
                   labText: "Round off the sub"))
}
