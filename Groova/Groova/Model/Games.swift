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
