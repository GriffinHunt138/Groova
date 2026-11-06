//
//  Genre.swift
//  Groova
//

import Foundation
import SwiftUI

nonisolated enum Genre: String, CaseIterable, Codable, Identifiable, Hashable, Sendable {
    case house, hipHop, rnb, pop
    // Written earlier and kept in the code, but not offered right now.
    case deepHouse, techno, techHouse, ukGarage

    /// The genres you can pick. The others stay in the code for later.
    static var allCases: [Genre] { [.house, .hipHop, .rnb, .pop] }
    static var archived: [Genre] { [.deepHouse, .techno, .techHouse, .ukGarage] }

    var id: String { rawValue }

    var name: String {
        switch self {
        case .house: "House"
        case .hipHop: "Hip-Hop"
        case .rnb: "R&B"
        case .pop: "Pop"
        case .deepHouse: "Deep House"
        case .techno: "Techno"
        case .techHouse: "Tech House"
        case .ukGarage: "UK Garage"
        }
    }

    var tagline: String {
        switch self {
        case .house: "Four on the floor. Warm, soulful, made for dancing."
        case .hipHop: "Head-nod drums, flipped samples and heavy bass."
        case .rnb: "Silky chords, laid-back drums and room to breathe."
        case .pop: "Big hooks, clear sections and choruses that lift."
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
        case .hipHop: "HH"
        case .rnb: "RB"
        case .pop: "P"
        case .deepHouse: "D"
        case .techno: "T"
        case .techHouse: "TH"
        case .ukGarage: "U"
        }
    }

    /// What this genre's academy is about, for the Part 2 header.
    var academyFocus: String {
        switch self {
        case .house: "The four-on-the-floor pulse, bass grooves, chord stabs, filter rides and dance-floor arrangement."
        case .hipHop: "The pocket, sample flips, bass, texture and verse-hook structure."
        case .rnb: "Laid-back pocket, rich chords, expressive melody, warm tone and subtle lifts."
        case .pop: "Song shape, supportive chords, hooks, layering and telling a story."
        case .deepHouse: "Warm sounds, jazzy chords and patient, late-night grooves."
        case .techno: "Hypnotic loops, machine rhythm, sound design and long tension."
        case .techHouse: "Rolling bass, percussion, vocal hooks and club energy."
        case .ukGarage: "Shuffle, swing, chopped vocals and bouncing bass."
        }
    }

    var traits: [String] {
        switch self {
        case .house: ["124 BPM", "Offbeat hats", "Piano & stabs"]
        case .hipHop: ["90 BPM", "Swung pocket", "Sample flips"]
        case .rnb: ["84 BPM", "Lush chords", "Laid back"]
        case .pop: ["112 BPM", "Big hooks", "Verse & chorus"]
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
        case .hipHop: Color(hex: 0xFF6A3D)
        case .rnb: Color(hex: 0xB86BFF)
        case .pop: Color(hex: 0xFF5EA8)
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
        case .hipHop: "hifispeaker.fill"
        case .rnb: "heart.fill"
        case .pop: "music.mic"
        case .deepHouse: "moon.stars.fill"
        case .techno: "bolt.fill"
        case .techHouse: "circle.hexagongrid.fill"
        case .ukGarage: "figure.dance"
        }
    }

    var bpm: Double {
        switch self {
        case .house: 124
        case .hipHop: 90
        case .rnb: 84
        case .pop: 112
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
        case .hipHop: 0.2
        case .rnb: 0.14
        case .deepHouse: 0.08
        case .techHouse: 0.1
        default: 0
        }
    }

    var kit: DrumKit {
        switch self {
        case .house: .house
        case .hipHop: .hipHop
        case .rnb: .rnb
        case .pop: .pop
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
        case .hipHop:
            Pattern(kick: [0, 7, 10], clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14], perc: [15],
                    bass: [NoteEvent(0, 38, 3), NoteEvent(7, 38), NoteEvent(10, 41, 2), NoteEvent(13, 36, 2)],
                    chords: [ChordEvent(step: 0, pitches: [57, 60, 62, 65], length: 6),
                             ChordEvent(step: 8, pitches: [55, 58, 62, 65], length: 6)])
        case .rnb:
            Pattern(kick: [0, 9], clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14], perc: [7],
                    bass: [NoteEvent(0, 36, 4), NoteEvent(6, 43), NoteEvent(9, 45, 4)],
                    chords: [ChordEvent(step: 0, pitches: [59, 60, 62, 64, 67], length: 7),
                             ChordEvent(step: 8, pitches: [57, 60, 64, 67, 71], length: 7)])
        case .pop:
            Pattern(kick: [0, 6, 8], clap: [4, 12], hat: [0, 2, 4, 6, 8, 10, 12, 14],
                    bass: [NoteEvent(0, 36, 2), NoteEvent(6, 36), NoteEvent(8, 43, 2), NoteEvent(14, 43)],
                    chords: [ChordEvent(step: 0, pitches: [60, 64, 67], length: 3),
                             ChordEvent(step: 4, pitches: [60, 64, 67], length: 3),
                             ChordEvent(step: 8, pitches: [55, 59, 62], length: 3),
                             ChordEvent(step: 12, pitches: [55, 59, 62], length: 3)])
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
