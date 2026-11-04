//
//  Genre.swift
//  Groova
//

import Foundation
import SwiftUI

nonisolated enum Genre: String, CaseIterable, Codable, Identifiable, Hashable, Sendable {
    case house, deepHouse, techno, techHouse, ukGarage

    var id: String { rawValue }

    var name: String {
        switch self {
        case .house: "House"
        case .deepHouse: "Deep House"
        case .techno: "Techno"
        case .techHouse: "Tech House"
        case .ukGarage: "UK Garage"
        }
    }

    var tagline: String {
        switch self {
        case .house: "Four on the floor. Warm, soulful, made for dancing."
        case .deepHouse: "Lush chords, soft kicks, late-night warmth."
        case .techno: "Hypnotic, driving, relentless machines."
        case .techHouse: "Rolling basslines and percussive swagger."
        case .ukGarage: "Shuffling two-step swing and bouncy bass."
        }
    }

    /// Prefix for academy units: "Unit H3".
    var academyCode: String {
        switch self {
        case .house: "H"
        case .deepHouse: "D"
        case .techno: "T"
        case .techHouse: "TH"
        case .ukGarage: "U"
        }
    }

    /// What this genre's academy is about, for the Part 2 header.
    var academyFocus: String {
        switch self {
        case .house: "Groove, soulful chords, vocals and the four-on-the-floor dance floor."
        case .deepHouse: "Warm sounds, jazzy chords and patient, late-night grooves."
        case .techno: "Hypnotic loops, machine rhythm, sound design and long tension."
        case .techHouse: "Rolling bass, percussion, vocal hooks and club energy."
        case .ukGarage: "Shuffle, swing, chopped vocals and bouncing bass."
        }
    }

    var traits: [String] {
        switch self {
        case .house: ["124 BPM", "Offbeat hats", "Piano & stabs"]
        case .deepHouse: ["120 BPM", "Jazzy chords", "Dubby space"]
        case .techno: ["132 BPM", "Driving kick", "Hypnotic loops"]
        case .techHouse: ["126 BPM", "Groovy bass", "Percussion"]
        case .ukGarage: ["132 BPM", "Swing", "Two-step kicks"]
        }
    }

    /// The genre's own hue. Used only for its small icon in the genre picker.
    var badgeColor: Color {
        switch self {
        case .house: Color(hex: 0xFFB23E)
        case .deepHouse: Color(hex: 0x4FD8C8)
        case .techno: Color(hex: 0xFF4D63)
        case .techHouse: Color(hex: 0xC5F23A)
        case .ukGarage: Color(hex: 0xFF6AD5)
        }
    }

    /// The app uses one brand color everywhere; genres are told apart by name and icon.
    var color: Color { Color(hex: 0x7B5CFA) }
    var deepColor: Color { Color(hex: 0x5A3FD6) }

    var symbol: String {
        switch self {
        case .house: "house.fill"
        case .deepHouse: "moon.stars.fill"
        case .techno: "bolt.fill"
        case .techHouse: "circle.hexagongrid.fill"
        case .ukGarage: "figure.dance"
        }
    }

    var bpm: Double {
        switch self {
        case .house: 124
        case .deepHouse: 120
        case .techno: 132
        case .techHouse: 126
        case .ukGarage: 132
        }
    }

    /// Default swing as a fraction of a 16th note.
    var swing: Double {
        switch self {
        case .ukGarage: 0.3
        case .deepHouse: 0.08
        case .techHouse: 0.1
        default: 0
        }
    }

    var kit: DrumKit {
        switch self {
        case .house: .house
        case .deepHouse: .deepHouse
        case .techno: .techno
        case .techHouse: .techHouse
        case .ukGarage: .ukGarage
        }
    }

    /// Lessons exist for these. The others get an honest preview.
    var hasLessons: Bool {
        true
    }

    /// A signature groove for each genre — deliberately different, not one loop reskinned.
    var demoPattern: Pattern {
        switch self {
        case .house:
            Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 5, 9, 13, 15], openHat: [2, 6, 10, 14],
                    bass: [NoteEvent(2, 33), NoteEvent(6, 33), NoteEvent(7, 36), NoteEvent(10, 33),
                           NoteEvent(13, 40), NoteEvent(14, 38, 2)],
                    chords: [ChordEvent(step: 3, pitches: [57, 60, 64, 67], length: 1),
                             ChordEvent(step: 10, pitches: [57, 60, 64, 67], length: 2)])
        case .deepHouse:
            Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [2, 6, 10, 14], perc: [7, 15],
                    bass: [NoteEvent(3, 41, 2), NoteEvent(11, 39, 2)],
                    chords: [ChordEvent(step: 0, pitches: [53, 56, 60, 63, 67], length: 6),
                             ChordEvent(step: 8, pitches: [51, 55, 58, 62], length: 6)])
        case .techno:
            Pattern(kick: [0, 4, 8, 12], hat: Array(0..<16), openHat: [2, 6, 10, 14], perc: [3, 6, 11],
                    bass: [2, 3, 6, 7, 10, 11, 14, 15].map { NoteEvent($0, 33) })
        case .techHouse:
            Pattern(kick: [0, 4, 8, 12], clap: [4, 12], hat: [1, 3, 5, 7, 9, 11, 13, 15],
                    openHat: [2, 6, 10, 14], perc: [3, 9, 13],
                    bass: [NoteEvent(2, 36), NoteEvent(3, 36), NoteEvent(7, 43), NoteEvent(10, 36),
                           NoteEvent(14, 38), NoteEvent(15, 36)])
        case .ukGarage:
            Pattern(kick: [0, 10], clap: [4, 12], hat: [2, 3, 6, 7, 10, 11, 14, 15], perc: [9],
                    bass: [NoteEvent(0, 40, 2), NoteEvent(3, 40), NoteEvent(6, 43), NoteEvent(10, 38, 2),
                           NoteEvent(14, 35)])
        }
    }
}

extension Color {
    nonisolated init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}
