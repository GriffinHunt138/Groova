//
//  Echo.swift
//  Groova
//
//  Echo, one of the four core games. I play a short call on big pads, you play it back.
//  Calls get longer, a streak builds, and you have three hearts.
//

import Foundation

nonisolated enum EchoSound: Sendable, Equatable {
    case drum(DrumTrack)
    case note(Int)
    case chord([Int])
}

nonisolated struct EchoPad: Sendable {
    var label: String
    var symbol: String?
    var sound: EchoSound

    /// One pad per drum, named and iconed after it.
    static func drums(_ tracks: [DrumTrack]) -> [EchoPad] {
        tracks.map { EchoPad(label: $0.name, symbol: $0.symbol, sound: .drum($0)) }
    }

    /// One pad per note, labelled with its letter name.
    static func notes(_ midis: [Int]) -> [EchoPad] {
        midis.map { EchoPad(label: EchoPad.letter($0), symbol: nil, sound: .note($0)) }
    }

    static func letter(_ midi: Int) -> String {
        ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "B♭", "B"][((midi % 12) + 12) % 12]
    }
}

nonisolated struct EchoConfig: Sendable {
    var pads: [EchoPad]
    /// The calls in order, each a list of pad indices. -1 is a rest. Make them get longer.
    var calls: [[Int]]
    /// Light the pads while the call plays. Off means you go by ear only.
    var showCall: Bool = true
    /// Speed of the call: one hit per beat.
    var bpm: Double = 110
    var lives: Int = 3
}

// MARK: - Play Along

/// Core rhythm game: the band loops, notes fall toward a line, and you play your part on the
/// pads as they land. Later bars can hide the notes so you keep it going by feel.
nonisolated struct PlayAlongConfig: Sendable {
    /// The drums you play, one lane each, left to right.
    var lanes: [DrumTrack] = []
    /// The full groove. Your lanes are muted in the band and become the notes you play.
    var groove: Pattern
    /// Bars to play after a one-bar count-in.
    var bars: Int = 8
    var bpm: Double = 90
    /// From this bar on (1 is the first bar after the count-in) the notes vanish: play by feel.
    var ghostFrom: Int? = nil
    var threshold: Double = 0.6
    /// Melody mode: one lane per key, in this order. When set, `lanes` is ignored.
    var keys: [Int] = []
    /// The line you play in melody mode. Steps past 15 fall in later bars; the line repeats.
    var melody: [NoteEvent] = []

    var laneCount: Int { keys.isEmpty ? lanes.count : keys.count }
    /// Bars the melody spans before it repeats.
    var melodyBars: Int { max(1, ((melody.map(\.step).max() ?? 0) / 16) + 1) }
}
