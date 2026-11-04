//
//  Music.swift
//  Groova
//
//  Core musical data: drum tracks, patterns, notes, and deterministic scoring.
//  Everything here is `nonisolated` so the audio thread can use it safely.
//

import Foundation

// MARK: - Drum tracks

nonisolated enum DrumTrack: Int, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case kick, clap, hat, openHat, perc

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .kick: "Kick"
        case .clap: "Clap"
        case .hat: "Hi-hat"
        case .openHat: "Open hat"
        case .perc: "Rim"
        }
    }

    var symbol: String {
        switch self {
        case .kick: "circle.circle.fill"
        case .clap: "hands.clap.fill"
        case .hat: "sparkle"
        case .openHat: "sparkles"
        case .perc: "triangle.fill"
        }
    }
}

/// Every instrument the mixer can solo or mute. Drums plus the bass and chord synths.
nonisolated enum Instrument: Hashable, Sendable {
    case drum(DrumTrack)
    case bass
    case chords

    var name: String {
        switch self {
        case .drum(let t): t.name
        case .bass: "Bass"
        case .chords: "Chords"
        }
    }
}

// MARK: - Notes

nonisolated struct NoteEvent: Codable, Hashable, Sendable, Identifiable {
    var id = UUID()
    var step: Int
    var pitch: Int      // MIDI note number
    var length: Int     // in 16th steps

    init(_ step: Int, _ pitch: Int, _ length: Int = 1) {
        self.step = step
        self.pitch = pitch
        self.length = length
    }

    var endStep: Int { step + length }

    func covers(_ s: Int) -> Bool { s >= step && s < endStep }

    static func == (a: NoteEvent, b: NoteEvent) -> Bool {
        a.step == b.step && a.pitch == b.pitch && a.length == b.length
    }

    func hash(into h: inout Hasher) {
        h.combine(step); h.combine(pitch); h.combine(length)
    }
}

nonisolated struct ChordEvent: Codable, Hashable, Sendable {
    var step: Int
    var pitches: [Int]
    var length: Int
}

/// A named chord voicing, e.g. "Am7" = A C E G.
nonisolated struct ChordShape: Hashable, Sendable {
    let name: String
    let pitches: [Int]

    var pitchClasses: Set<Int> { Set(pitches.map { (($0 % 12) + 12) % 12 }) }

    static let am = ChordShape(name: "Am", pitches: [57, 60, 64])
    static let c = ChordShape(name: "C", pitches: [60, 64, 67])
    static let em = ChordShape(name: "Em", pitches: [59, 64, 67])
    static let dm = ChordShape(name: "Dm", pitches: [57, 62, 65])
    static let am7 = ChordShape(name: "Am7", pitches: [57, 60, 64, 67])
    static let dm7 = ChordShape(name: "Dm7", pitches: [57, 60, 62, 65])
    static let em7 = ChordShape(name: "Em7", pitches: [59, 62, 64, 67])
    static let fmaj7 = ChordShape(name: "Fmaj7", pitches: [57, 60, 64, 65])
    static let cmaj7 = ChordShape(name: "Cmaj7", pitches: [55, 59, 60, 64])
    // Ninths and deep-house colours
    static let am9 = ChordShape(name: "Am9", pitches: [57, 60, 64, 67, 71])
    static let dm9 = ChordShape(name: "Dm9", pitches: [57, 60, 62, 64, 65])
    static let em9 = ChordShape(name: "Em9", pitches: [55, 59, 62, 64, 66])
    static let cmaj9 = ChordShape(name: "Cmaj9", pitches: [59, 60, 62, 64, 67])
    static let fm7 = ChordShape(name: "Fm7", pitches: [53, 56, 60, 63])
    static let fm9 = ChordShape(name: "Fm9", pitches: [53, 56, 60, 63, 67])
    static let dbmaj7 = ChordShape(name: "D♭maj7", pitches: [53, 56, 60, 61])
    static let bbm7 = ChordShape(name: "B♭m7", pitches: [53, 56, 58, 61])
    static let cm7 = ChordShape(name: "Cm7", pitches: [55, 58, 60, 63])
    static let ebmaj7 = ChordShape(name: "E♭maj7", pitches: [55, 58, 62, 63])
    static let gm7 = ChordShape(name: "Gm7", pitches: [55, 58, 62, 65])

    static let known: [ChordShape] = [.am, .c, .em, .dm, .am7, .dm7, .em7, .fmaj7, .cmaj7, .am9, .dm9, .em9, .cmaj9,
                                      .fm7, .fm9, .dbmaj7, .bbm7, .cm7, .ebmaj7, .gm7]

    /// The name of a known voicing, matched on note names so any octave counts.
    static func name(for pitches: [Int]) -> String? {
        let pcs = Set(pitches.map { (($0 % 12) + 12) % 12 })
        return known.first { $0.pitchClasses == pcs }?.name
    }
}

// MARK: - Pattern

/// One bar (16 steps) of music. Loops seamlessly.
nonisolated struct Pattern: Codable, Hashable, Sendable {
    static let steps = 16

    var kick = [Bool](repeating: false, count: 16)
    var clap = [Bool](repeating: false, count: 16)
    var hat = [Bool](repeating: false, count: 16)
    var openHat = [Bool](repeating: false, count: 16)
    var perc = [Bool](repeating: false, count: 16)
    var bass: [NoteEvent] = []
    var chords: [ChordEvent] = []

    init(kick: [Int] = [], clap: [Int] = [], hat: [Int] = [], openHat: [Int] = [],
         perc: [Int] = [], bass: [NoteEvent] = [], chords: [ChordEvent] = []) {
        for s in kick { self.kick[s] = true }
        for s in clap { self.clap[s] = true }
        for s in hat { self.hat[s] = true }
        for s in openHat { self.openHat[s] = true }
        for s in perc { self.perc[s] = true }
        self.bass = bass
        self.chords = chords
    }

    subscript(track: DrumTrack) -> [Bool] {
        get {
            switch track {
            case .kick: kick
            case .clap: clap
            case .hat: hat
            case .openHat: openHat
            case .perc: perc
            }
        }
        set {
            switch track {
            case .kick: kick = newValue
            case .clap: clap = newValue
            case .hat: hat = newValue
            case .openHat: openHat = newValue
            case .perc: perc = newValue
            }
        }
    }

    func hits(_ track: DrumTrack) -> Int { self[track].filter { $0 }.count }

    /// Copy only some instruments from another pattern.
    func keeping(_ tracks: Set<DrumTrack>, bass keepBass: Bool, chords keepChords: Bool) -> Pattern {
        var p = Pattern()
        for t in tracks { p[t] = self[t] }
        if keepBass { p.bass = bass }
        if keepChords { p.chords = chords }
        return p
    }

    /// Sorted, non-overlapping bass notes (monophonic line).
    mutating func placeBassNote(_ note: NoteEvent) {
        var n = note
        n.length = max(1, min(n.length, Pattern.steps - n.step))
        bass.removeAll { $0.id == n.id || ($0.step < n.endStep && n.step < $0.endStep) }
        bass.append(n)
        bass.sort { $0.step < $1.step }
    }
}

// MARK: - Note names

nonisolated enum NoteName {
    static let names = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]

    static func name(_ midi: Int, octave: Bool = false) -> String {
        let n = names[((midi % 12) + 12) % 12]
        return octave ? "\(n)\(midi / 12 - 1)" : n
    }

    static func isBlack(_ midi: Int) -> Bool {
        [1, 3, 6, 8, 10].contains(((midi % 12) + 12) % 12)
    }

    static func frequency(_ midi: Int) -> Double {
        440.0 * pow(2.0, Double(midi - 69) / 12.0)
    }
}

// MARK: - Scoring

/// What a cell looks like after grading.
nonisolated enum CellMark: Hashable, Sendable {
    case correct      // active in both
    case extra        // user placed a hit that isn't in the reference
    case missed       // reference had a hit the user didn't place
}

nonisolated struct RhythmScore: Sendable {
    var accuracy: Double
    var marks: [Int: CellMark]
}

nonisolated struct MelodyScore: Sendable {
    var accuracy: Double
    var correctNotes: Set<UUID>   // user notes that matched perfectly
    var wrongNotes: Set<UUID>     // user notes that didn't match anything
    var missedSteps: Set<Int>     // reference onsets the user didn't play
}

nonisolated enum Scoring {
    /// Rhythm accuracy. Each step is scored, but steps that hold a real hit
    /// count three times as much as empty ones, so reproducing the notes matters most.
    static func rhythm(user: [Bool], reference: [Bool]) -> RhythmScore {
        let activeWeight = 3.0
        var total = 0.0, earned = 0.0
        var marks: [Int: CellMark] = [:]
        for i in 0..<min(user.count, reference.count) {
            let w = reference[i] ? activeWeight : 1.0
            total += w
            if user[i] == reference[i] {
                earned += w
                if user[i] { marks[i] = .correct }
            } else {
                marks[i] = user[i] ? .extra : .missed
            }
        }
        return RhythmScore(accuracy: total == 0 ? 1 : earned / total, marks: marks)
    }

    /// Melody accuracy. For each reference note we look for a user note starting on the
    /// same step: timing is worth 40%, pitch 45% (an octave off earns half), and
    /// duration 15%. Extra notes subtract half a note each.
    static func melody(user: [NoteEvent], reference: [NoteEvent]) -> MelodyScore {
        guard !reference.isEmpty else {
            return MelodyScore(accuracy: user.isEmpty ? 1 : 0, correctNotes: [],
                               wrongNotes: Set(user.map(\.id)), missedSteps: [])
        }
        // Points are counted in hundredths so the maths stays exact.
        var points = 0
        var used = Set<UUID>()
        var correct = Set<UUID>()
        var missed = Set<Int>()
        for ref in reference {
            guard let u = user.first(where: { $0.step == ref.step && !used.contains($0.id) }) else {
                missed.insert(ref.step)
                continue
            }
            used.insert(u.id)
            var p = 40
            if u.pitch == ref.pitch { p += 45 }
            else if (u.pitch - ref.pitch) % 12 == 0 { p += 22 }
            if u.length == ref.length { p += 15 }
            points += p
            if p == 100 { correct.insert(u.id) }
        }
        let extras = user.filter { !used.contains($0.id) }
        points -= 50 * extras.count
        var wrong = Set(extras.map(\.id))
        for u in user where used.contains(u.id) && !correct.contains(u.id) { wrong.insert(u.id) }
        let acc = max(0, min(1, Double(points) / Double(100 * reference.count)))
        return MelodyScore(accuracy: acc, correctNotes: correct, wrongNotes: wrong, missedSteps: missed)
    }

    /// Chord-lane accuracy. Each step holds a chord index or nothing. Like `rhythm`, steps
    /// with a reference chord weigh three times as much. The right timing with the wrong
    /// chord earns half.
    static func chordLane(user: [Int?], reference: [Int?]) -> RhythmScore {
        let activeWeight = 3.0
        var total = 0.0, earned = 0.0
        var marks: [Int: CellMark] = [:]
        for i in 0..<min(user.count, reference.count) {
            let u = user[i], r = reference[i]
            let w = r != nil ? activeWeight : 1.0
            total += w
            switch (u, r) {
            case (nil, nil):
                earned += w
            case let (u?, r?) where u == r:
                earned += w
                marks[i] = .correct
            case (_?, _?):
                earned += w * 0.5
                marks[i] = .extra
            case (_?, nil):
                marks[i] = .extra
            case (nil, _?):
                marks[i] = .missed
            }
        }
        return RhythmScore(accuracy: total == 0 ? 1 : earned / total, marks: marks)
    }

    /// Parameter-based sound matching. Honest: this compares knob positions, not audio.
    static func filterMatch(cutoff: Double, resonance: Double,
                            targetCutoff: Double, targetResonance: Double) -> Double {
        let octaves = abs(log2(cutoff / targetCutoff))
        let cutoffScore = max(0, 1 - octaves / 2.0)          // 2 octaves away = 0
        let resScore = max(0, 1 - abs(resonance - targetResonance) / 0.6)
        return 0.75 * cutoffScore + 0.25 * resScore
    }
}
