import Foundation
import Observation

/// A loop the learner made in the Studio. One bar of drums, bass and chord stabs plus a simple mix.
nonisolated struct Sketch: Codable, Identifiable, Hashable, Sendable {
    var id = UUID()
    var name: String
    var genre: Genre
    /// Drums and bass. Chords live in `chordCells` so they stay tied to the palette.
    var pattern: Pattern
    /// Step -> index in the genre's studio palette.
    var chordCells: [Int?]
    var bpm: Double
    var swing: Double
    var drumsFader = 2.0 / 3.0
    var bassFader = 2.0 / 3.0
    var chordsFader = 2.0 / 3.0
    var pump = 0.0
    var updated = Date.now

    static func fresh(_ genre: Genre, name: String = "Untitled loop") -> Sketch {
        var loop = genre.demoPattern
        loop.chords = []
        var cells = [Int?](repeating: nil, count: Pattern.steps)
        // Keep the genre's own stab rhythm, voiced with the first palette chord.
        for c in genre.demoPattern.chords where c.step < Pattern.steps { cells[c.step] = 0 }
        return Sketch(name: name, genre: genre, pattern: loop, chordCells: cells,
                      bpm: genre.bpm, swing: genre.swing)
    }

    static func empty(_ genre: Genre) -> Sketch {
        Sketch(name: "Untitled loop", genre: genre, pattern: Pattern(),
               chordCells: [Int?](repeating: nil, count: Pattern.steps), bpm: genre.bpm, swing: genre.swing)
    }

    /// The full pattern the engine plays.
    var playable: Pattern {
        var p = pattern
        let palette = Studio.palette(genre)
        p.chords = chordCells.enumerated().compactMap { step, idx in
            guard let idx, idx < palette.count else { return nil }
            return ChordEvent(step: step, pitches: palette[idx].pitches, length: 1)
        }
        return p
    }

    var isEmpty: Bool { pattern == Pattern() && chordCells.allSatisfy { $0 == nil } }
}

/// Per-genre Studio tools.
nonisolated enum Studio {
    static func palette(_ g: Genre) -> [ChordShape] {
        switch g {
        case .house: [.am7, .dm7, .em7, .fmaj7]
        case .techno: [.am7, .dm7]
        case .ukGarage: [.em9, .am9, .cmaj9, .dm9]
        case .deepHouse: [.fm9, .dbmaj7, .bbm7, .cm7]
        case .techHouse: [.cm7, .fm7, .gm7, .ebmaj7]
        }
    }

    /// Bass rows, high to low: the course rows plus any note the demo loop uses.
    static func bassRows(_ g: Genre) -> [Int] {
        let base: [Int]
        switch g {
        case .house, .techno: base = [45, 43, 40, 38, 36, 33]
        case .ukGarage: base = [47, 45, 43, 40, 38, 35]
        case .deepHouse: base = [48, 46, 44, 41, 39, 36]
        case .techHouse: base = [46, 43, 41, 39, 36, 34]
        }
        return Array(Set(base + g.demoPattern.bass.map(\.pitch))).sorted(by: >)
    }

    static let bpmRange: ClosedRange<Double> = 90...150
}

/// Saved sketches, newest first.
@Observable
final class SketchStore {
    private(set) var sketches: [Sketch] = []
    private let key = "groova.sketches.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([Sketch].self, from: data) {
            sketches = saved.sorted { $0.updated > $1.updated }
        }
    }

    func save(_ sketch: Sketch) {
        var s = sketch
        s.updated = .now
        if let i = sketches.firstIndex(where: { $0.id == s.id }) {
            sketches.remove(at: i)
        }
        sketches.insert(s, at: 0)
        persist()
    }

    func delete(_ ids: Set<UUID>) {
        sketches.removeAll { ids.contains($0.id) }
        persist()
    }

    func contains(_ id: UUID) -> Bool { sketches.contains { $0.id == id } }

    private func persist() {
        if let data = try? JSONEncoder().encode(sketches) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
