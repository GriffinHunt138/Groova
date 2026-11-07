//
//  Games.swift
//  Groova
//
//  The Game phase of a Foundations tier: Teach, then Studio, then Game. Each lesson has its own
//  named minigame with its own look and gesture. A game step holds that game's rounds, which
//  run back to back as one final phase. The views live in Views/Games.
//

import Foundation

nonisolated struct GameTask: Sendable {
    /// The game's name, e.g. "Blackout".
    var name: String
    /// One line under the name.
    var tagline: String
    var kind: GameKind
}

nonisolated enum GameKind: Sendable {
    case blackout([PulseRound])
    case drumDuel([DuelRound])
    case controlRoom(ControlRoomScore, [ControlRound])
    case reactor([ReactorLayer], [ReactorRound])
    case downbeat([DownbeatRound])
    case slicer([SliceRound])
    case forensics([ForensicsRound])
    case gravity([GravityRound])
    case grooveDNA([DNARound])
    case glider([GliderRound])
    case radar([RadarRound])
    /// Keyboard Maze, Harmonic Gravity and Echo Chase: tap notes on a surface.
    case notes(NoteSurface, [NoteRound])
    case chordLock([LockRound])
    case impostor([ImpostorRound])
    case resolution([RunRound])
    case tether([TetherRound])
    case xray([XRayRound])
    case surgery([SurgeryRound])
    case architect([ArchitectRound])
    case traffic([TrafficRound])
    case casting([CastRound])
    case detective([DetectiveRound])
    case surfer([SurferRound])
    case cut([CutRound])
    case jigsaw([SongSection], [JigsawRound])
    case live([LiveRound])
    /// Core game: hear a call on the pads, play it back.
    case echo(EchoConfig)
}

// MARK: - Blackout (F0.1)

/// Keep a pulse alive on a glowing ring while the guide fades to black.
nonisolated struct PulseRound: Sendable {
    var title: String
    var body: String
    /// What plays underneath. Bar 0 is a count-in.
    var loop: Pattern
    var bpm: Double = 100
    /// Taps to make after the count-in, one per beat.
    var beats: Int = 8
    /// How many of those beats the ring still lights up. Fewer means more blackout.
    var guideBeats: Int = 8
    /// Off-beat flashes that try to pull you away from the sound.
    var decoys: Bool = false
    /// Bars (counted from the count-in at 0) where the drums drop out and only `pad` plays.
    var dropBars: [Int] = []
    var pad: Pattern = Pattern()
    /// Your taps play this drum, so you become that part of the track.
    var tapSound: DrumTrack? = nil
    /// Taken out of the backing (e.g. the kick, when you are the kick).
    var mute: Set<DrumTrack> = []
    /// No lights at all, not even in the count-in.
    var hiddenStart = false
    /// Choose one of these tempos before starting.
    var paces: [Double] = []
    /// Timing window either side of the beat, in beats.
    var tolerance: Double = 0.24
    var threshold: Double = 0.6
}

// MARK: - Drum Duel (F0.2)

nonisolated enum DuelMode: Sendable, Equatable {
    /// Play the pads freely until you've tried each one.
    case free
    /// The game plays a call; you answer it on the pads.
    case echo
    /// The backing plays without one drum. You are that drum.
    case role(DrumTrack)
    /// Record your own one-bar call.
    case invent
    /// Answer your own call: keep at least one hit, change at least one.
    case answer
    /// Hear your call and answer together.
    case duet
}

nonisolated struct DuelRound: Sendable {
    var title: String
    var body: String
    var mode: DuelMode
    /// The call, one pattern per bar. Kick, snare and hat only.
    var call: [Pattern] = []
    /// Plays under your answer.
    var backing: Pattern = Pattern()
    /// Pads glow just before each hit you should play.
    var cues = true
    /// Hide the pad names while the call plays, so you go by sound.
    var hideLabels = false
    /// Call and answer exchanges in a row.
    var repeats = 1
    var bpm: Double = 90
    var threshold: Double = 0.6
}

// MARK: - Soundtrack Control Room (F0.3)

/// The material a scene is scored with. Index 0 and 1 of each lever are its two positions.
nonisolated struct ControlRoomScore: Sendable {
    var melody: [NoteEvent]
    /// Chords and bass, one bar each.
    var harmony: [Pattern]
    /// Drums, one bar each.
    var movement: [Pattern]
    /// Chord brightness, 0...1.
    var color: [Double]
    var bpm: Double = 80
    var names: [[String]] = [["Major", "Minor"], ["Sparse", "Busy"], ["Warm", "Bright"]]
}

nonisolated enum ControlMode: Sendable {
    /// Two full soundtracks. Flip between them while the film runs.
    case swap(a: [Int], b: [Int])
    /// Turn every dial at least once.
    case explore
    /// Hear pairs where one lever changed. Tap that lever. Each pair is (start, changed lever).
    case spot([([Int], Int)])
    /// Match a reference using only the unlocked levers.
    case brief(target: [Int], start: [Int], unlocked: [Int])
    /// Make a change exactly when the door opens (bar 2).
    case cue(start: [Int], lever: Int)
    /// Gold: score the film live with at least two levers, then watch it back.
    case perform(start: [Int])
}

nonisolated struct ControlRound: Sendable {
    var title: String
    var body: String
    var mode: ControlMode
}

// MARK: - Loop Reactor (F0.4)

nonisolated struct ReactorLayer: Sendable {
    var name: String
    var symbol: String
    /// One-bar loops. Most layers have one; "choose" rounds offer two.
    var variants: [Pattern]
}

nonisolated enum ReactorMode: Sendable, Equatable {
    /// Switch on all four rings and let it spin for two bars.
    case build
    /// Pick a version of each ring, then bring them all in.
    case choose
    /// One ring is missing. Find it and bring it back.
    case missing(Int)
    /// Rings playing in each of the next bars, e.g. [1, 2, 4].
    case energy([Int])
    /// One ring is a beat late. Hit SYNC to put it back on the bar.
    case sync(Int)
    /// Gold: four bars, at least one entry, one exit and one full-band moment.
    case perform
}

nonisolated struct ReactorRound: Sendable {
    var title: String
    var body: String
    var mode: ReactorMode
    var bpm: Double = 100
}

// MARK: - Downbeat Hunter (F1.1)

nonisolated enum DownbeatMode: Sendable, Equatable {
    /// Tap LOCK each time the 1 comes round, with the dial showing you.
    case anchor
    /// The dial starts this many beats out. Turn it until its 1 lands on the real downbeat.
    case align(offset: Int)
    /// The clip starts mid-bar on this beat (0...3). Tap LOCK on the real 1.
    case lock(startBeat: Int)
    /// Tap every 1, including through these bars where the drums drop out.
    case follow(breakBars: [Int])
    /// Gold: your LOCK taps play a kick and a crash. Accent every downbeat.
    case accent
}

nonisolated struct DownbeatRound: Sendable {
    var title: String
    var body: String
    var mode: DownbeatMode
    var loop: Pattern
    /// What plays in break bars.
    var breakLoop: Pattern = Pattern()
    var bars: Int = 4
    var bpm: Double = 96
    /// Gold: pick one of these loops first.
    var choices: [(name: String, loop: Pattern)] = []
}

// MARK: - Time Slicer (F1.2)

nonisolated enum SliceMode: Sendable, Equatable {
    /// Match the target slices. Shown, or by ear.
    case match
    /// One beat has a slice too many. Join it back up.
    case fix
    /// Gold: shape the density, flat, rising or falling, with one sparse and one busy beat.
    case shape
}

nonisolated struct SliceRound: Sendable {
    var title: String
    var body: String
    var mode: SliceMode
    /// Hits per beat (1, 2 or 4) for the four beats.
    var start: [Int] = [1, 1, 1, 1]
    var target: [Int] = []
    var showTarget = true
    var backing: Pattern = Pattern(kick: [0, 8], clap: [4, 12])
    var bpm: Double = 96
}

// MARK: - Drum Forensics (F1.3)

nonisolated enum ForensicsMode: Sendable, Equatable {
    /// Hear each drum's fingerprint.
    case fingerprints
    /// Three hidden channels. Solo them and label them. Plays with kit number `kit`.
    case identify(kit: Int)
    /// Open the muted strips in order: kick, snare, hat.
    case restore
    /// A filter has hidden one drum. Which?
    case filtered
    /// The second version adds one drum. Which?
    case added(DrumTrack)
    /// Gold: choose each drum's sound from two kits.
    case chooseKit
    /// Gold: bring the strips in one by one over four bars.
    case entrance
}

nonisolated struct ForensicsRound: Sendable {
    var title: String
    var body: String
    var mode: ForensicsMode
    var groove: Pattern
    var bpm: Double = 96
}

// MARK: - Gravity Groove (F1.4)

nonisolated enum GravityMode: Sendable, Equatable {
    /// Watch the kick puck bounce, flick freely.
    case watch
    /// Land claps on these steps of every bar, with or without the landing zone shown.
    case land(steps: [Int], showZone: Bool)
    /// Hear a bar of kick and clap, then copy the clap.
    case copy(steps: [Int])
    /// Gold: four bars, at least two landings between the beats.
    case perform
}

nonisolated struct GravityRound: Sendable {
    var title: String
    var body: String
    var mode: GravityMode
    var kick: Pattern = Pattern(kick: [0, 4, 8, 12])
    var bars: Int = 2
    var bpm: Double = 88
}

// MARK: - Groove DNA (F1.5)

nonisolated enum DNAMode: Sendable, Equatable {
    /// Stretch the ribbon to add swing. With a target, match it.
    case swing(target: Double?)
    /// Bring these beats forward (0...3) with accents.
    case accent(target: Set<Int>)
    /// Push the swing too far, hear it fall apart, then find the pocket.
    case sloppy
    /// Gold: two feels from the same notes, then pick your favourite blind.
    case fingerprint
}

nonisolated struct DNARound: Sendable {
    var title: String
    var body: String
    var mode: DNAMode
    var groove: Pattern = Pattern(kick: [0, 8], clap: [4, 12], hat: Array(0..<16))
    var bpm: Double = 92
    /// Show a target band on the ribbon.
    var showRange = true
}

// MARK: - Pitch Glider (F2.1)

nonisolated enum GliderMode: Sendable, Equatable {
    /// Hear the notes while the glider flies them, then fly them yourself. `trail` leaves the path showing.
    case follow(trail: Bool)
    /// Hear `first`, then the round's notes, which change at the end. Fly the second one.
    case changed(first: [Int])
    /// A guide tone repeats. Steer the glider until you match it, and hold.
    case hold(target: Int)
    /// Gold: draw five notes in one flight.
    case draw
    /// Gold: your drawn melody plays; redraw the last two notes for a new ending.
    case redraw
    /// Gold: pick a backing and keep your flight.
    case showcase
}

nonisolated struct GliderRound: Sendable {
    var title: String
    var body: String
    var mode: GliderMode
    /// The melody, one note per beat.
    var notes: [Int] = []
    var bpm: Double = 84
}

// MARK: - Interval Radar (F2.3)

nonisolated enum RadarMode: Sendable, Equatable {
    /// Pull the second dot out and hear the distance grow.
    case grow
    /// Hear each pair and drop the dot into SAME, NEAR or FAR.
    case zones([Int])
    /// Hear a reference distance, then turn the dial through `choices` to match it. Signed if `direction`.
    case match(target: Int, choices: [Int], direction: Bool)
    /// Match these distances one after another, making a phrase.
    case chain([Int])
    /// Gold: pick a signature jump from these.
    case pick([Int])
    /// Gold: two signed distances from the root make a three-note motif.
    case motif
    /// Gold: change one distance of your motif to answer it.
    case reply
}

nonisolated struct RadarRound: Sendable {
    var title: String
    var body: String
    var mode: RadarMode
    var root: Int = 60
}

// MARK: - Note surfaces: Keyboard Maze (F2.2), Harmonic Gravity (F2.4), Echo Chase (F2.5)

nonisolated enum NoteSurface: Sendable, Equatable {
    /// Five touch lanes, low to high.
    case strip([Int])
    /// A piano keyboard from `low` to `high`.
    case keyboard(low: Int, high: Int)
    /// Notes in orbit round a home note. One outside note can be unlocked.
    case orbit(home: Int, notes: [Int], outside: Int?)
    /// Hook Hotline: five big round pads in an arc.
    case pads([Int])
}

nonisolated enum NoteMode: Sendable, Equatable {
    /// Play anything, this many notes.
    case explore(Int)
    /// Play exactly these notes in order. Letters show after each right one if `reveal`.
    case find([Int], reveal: Bool)
    /// Hear the notes, then play them back. `show` lights them as they play. `gapBars` waits in silence first.
    case echo([Int], show: Bool, gapBars: Int)
    /// Hear `a` then `b`. Tap which note in `b` changed.
    case spot(a: [Int], b: [Int])
    /// Hear the phrase end on each option, then pick one. `answer` nil means any pick is fine.
    case ending(lead: [Int], options: [Int], answer: Int?)
    /// Gold: write `count` notes. Start and end on these if given; `shape` asks for a step and a leap.
    case compose(count: Int, start: Int?, end: [Int], shape: Bool)
    /// Gold: answer your call. Keep its first `keep` notes, change the rest.
    case answer(keep: Int)
    /// Gold: your phrase plays with the surface dark. Play it back.
    case retrace
    /// Gold: call and answer, back to back.
    case duet
}

nonisolated struct NoteRound: Sendable {
    var title: String
    var body: String
    var mode: NoteMode
    /// Overrides the game's surface for this round.
    var surface: NoteSurface? = nil
    var labels = true
    var backing: Pattern = Pattern()
    var bpm: Double = 90
}

/// "C", "F#" and so on. With `octave`, "C4".
nonisolated func noteName(_ midi: Int, octave: Bool = false) -> String {
    let names = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    let n = names[((midi % 12) + 12) % 12]
    return octave ? "\(n)\(midi / 12 - 1)" : n
}

nonisolated func isBlackKey(_ midi: Int) -> Bool { [1, 3, 6, 8, 10].contains(((midi % 12) + 12) % 12) }

// MARK: - Triads

/// A root-position triad, major or minor.
nonisolated struct Triad: Sendable, Hashable {
    var root: Int
    var minor = false

    var pitches: [Int] { [root, root + (minor ? 3 : 4), root + 7] }
    var name: String { noteName(root) + (minor ? "m" : "") }
    var flipped: Triad { Triad(root: root, minor: !minor) }
    var shape: ChordShape { ChordShape(name: name, pitches: pitches) }

    static let c = Triad(root: 60), f = Triad(root: 65), g = Triad(root: 67), d = Triad(root: 62)
    static let am = Triad(root: 57, minor: true), dm = Triad(root: 62, minor: true), em = Triad(root: 64, minor: true)
    static let a = Triad(root: 57), e = Triad(root: 64), bb = Triad(root: 58), cm = Triad(root: 60, minor: true)
}

// MARK: - Chord Lock (F3.1)

nonisolated enum LockMode: Sendable, Equatable {
    /// One beam, then all three.
    case reveal(Triad)
    /// Slide the unlocked beams to the chord. `ghost` shows where they go.
    case build(Triad, locked: [Bool], ghost: Bool)
    /// One beam is off. Tap it, then fix it.
    case wrongBeam(Triad, wrong: Int, by: Int)
    /// Several chords, each missing one voice, back to back.
    case chain([Triad], missing: [Int])
    /// Gold: choose a root and quality and build it.
    case voicing
    /// Gold: move one voice an octave. Same chord, new shape.
    case revoice
    /// Gold: alternate both voicings and keep one.
    case alternate
}

nonisolated struct LockRound: Sendable {
    var title: String
    var body: String
    var mode: LockMode
}

// MARK: - Chord Impostor (F3.2)

nonisolated enum ImpostorMode: Sendable, Equatable {
    /// Swipe the middle ribbon to flip the third.
    case morph(Triad)
    /// Chords play one by one. Tap the cup hiding the odd one out.
    case lineup([Triad])
    /// Hear two versions. Tap the chord that changed.
    case edit(a: [Triad], b: [Triad])
    /// Catch the odd one, then flip its third with the lever to match the rest.
    case reverse([Triad])
    /// Gold: pick a phrase.
    case choose([[Triad]])
    /// Gold: flip the third of one chord in the second pass.
    case twist
    /// Gold: hear the original, then the twist.
    case reveal
}

nonisolated struct ImpostorRound: Sendable {
    var title: String
    var body: String
    var mode: ImpostorMode
    var bpm: Double = 96
}

// MARK: - Resolution Run (F3.3)

nonisolated enum RunMode: Sendable, Equatable {
    /// The route plays up to a gate. Audition the options, then open the gate with one.
    case gate(lead: [Triad], options: [Triad], answer: Int?, reference: [Triad])
    /// One block is missing from the route. Fill it.
    case slot(route: [Triad], missing: Int, options: [Triad])
    /// The route plays. Tap HOME when it arrives.
    case follow([Triad], home: Triad)
    /// Gold: choose the destination.
    case destination([Triad])
    /// Gold: pick the two middle blocks.
    case route([Triad])
    /// Gold: two final chords, keep one.
    case endings
}

nonisolated struct RunRound: Sendable {
    var title: String
    var body: String
    var mode: RunMode
    var bpm: Double = 100
}

// MARK: - Kick-Bass Tether (F3.4)

nonisolated enum TetherMode: Sendable, Equatable {
    /// Kick and bass land together.
    case together
    /// Slide one bass note to these steps, off the kick.
    case slide(from: Int, to: Int)
    /// Follow the chord roots, bar by bar.
    case roots
    /// Place bass hits on these steps.
    case rhythm([Int])
    /// Shorten the held bass to this many steps so the kick comes through.
    case length(Int)
    /// Gold: pick a chord loop.
    case chooseLoop([[Triad]])
    /// Gold: record four bars on bass pads.
    case perform
    /// Gold: yours against roots on the beat.
    case compare
}

nonisolated struct TetherRound: Sendable {
    var title: String
    var body: String
    var mode: TetherMode
    var chords: [Triad] = [.c]
    var kick: Pattern = Pattern(kick: [0, 4, 8, 12])
    var bpm: Double = 100
}

// MARK: - Helpers

extension Pattern {
    /// The same pattern with some drums taken out.
    nonisolated func without(_ tracks: Set<DrumTrack>) -> Pattern {
        var p = self
        for t in tracks { p[t] = [Bool](repeating: false, count: Pattern.steps) }
        return p
    }

    /// Only drums, no bass or chords.
    nonisolated var drumsOnly: Pattern {
        var p = self
        p.bass = []
        p.chords = []
        return p
    }

    /// Shifted later by some steps, wrapping round the bar.
    nonisolated func shifted(by n: Int) -> Pattern {
        var p = Pattern()
        for t in DrumTrack.allCases {
            let row = self[t]
            p[t] = (0..<Pattern.steps).map { row[(($0 - n) % Pattern.steps + Pattern.steps) % Pattern.steps] }
        }
        p.bass = bass.map { NoteEvent(($0.step + n) % Pattern.steps, $0.pitch, $0.length) }
        p.chords = chords.map { ChordEvent(step: ($0.step + n) % Pattern.steps, pitches: $0.pitches, length: $0.length) }
        return p
    }

    nonisolated var isEmpty: Bool {
        bass.isEmpty && chords.isEmpty && DrumTrack.allCases.allSatisfy { !self[$0].contains(true) }
    }
}
