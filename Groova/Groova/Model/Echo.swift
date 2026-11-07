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
