//
//  QuickEar.swift
//  Groova
//
//  Quick Ear, one of the core games: hear a sound, tap the answer, ten in a row.
//  Builders make each question set from a seed, so a level is the same every time.
//

import Foundation

nonisolated enum EarSound: Sendable {
    /// One chord, held.
    case chord([Int])
    /// Notes one after another.
    case notes([Int])
    /// Chords one after another.
    case chords([[Int]])
    /// Two bars of a drum groove at this swing.
    case groove(Pattern, swing: Double)
    /// The same note on each sound in turn.
    case voices([SynthPatch], note: Int)
    /// One bar of each pattern in turn.
    case grooves([Pattern])
}

nonisolated struct EarQuestion: Sendable {
    var sound: EarSound
    var answer: Int
}

nonisolated struct QuickEarConfig: Sendable {
    /// The question, e.g. "Major or minor?"
    var prompt: String
    /// Two to four answers.
    var choices: [String]
    var questions: [EarQuestion]
    var lives: Int = 3
    var threshold: Double = 0.7
}

extension QuickEarConfig {
    nonisolated private static func major(_ r: Int) -> [Int] { [r, r + 4, r + 7] }
    nonisolated private static func minor(_ r: Int) -> [Int] { [r, r + 3, r + 7] }

    /// Major or minor triads on shifting roots.
    nonisolated static func majorMinor(_ seed: String, count: Int = 10, arpeggio: Bool = false) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            let root = 55 + rng.int(10)
            let isMinor = rng.int(2) == 1
            let notes = isMinor ? minor(root) : major(root)
            qs.append(EarQuestion(sound: arpeggio ? .notes(notes) : .chord(notes), answer: isMinor ? 1 : 0))
        }
        return QuickEarConfig(prompt: "Major or minor?", choices: ["Major", "Minor"], questions: qs)
    }

    /// Two notes: did the second go up or down? `smallest` is the closest the notes get, in semitones.
    nonisolated static func higherLower(_ seed: String, count: Int = 10, smallest: Int = 3, largest: Int = 9) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            let first = 58 + rng.int(10)
            let gap = smallest + rng.int(max(1, largest - smallest + 1))
            let up = rng.int(2) == 0
            qs.append(EarQuestion(sound: .notes([first, up ? first + gap : first - gap]), answer: up ? 0 : 1))
        }
        return QuickEarConfig(prompt: "Did it go up or down?", choices: ["Up", "Down"], questions: qs)
    }

    /// Two notes: the same, a step, or a leap.
    nonisolated static func stepLeap(_ seed: String, count: Int = 10) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            let first = 60 + rng.int(8)
            let kind = rng.int(3)
            let gap: Int
            switch kind {
            case 0: gap = 0
            case 1: gap = 1 + rng.int(2)
            default: gap = 5 + rng.int(4)
            }
            let second = rng.int(2) == 0 ? first + gap : first - gap
            qs.append(EarQuestion(sound: .notes([first, second]), answer: kind))
        }
        return QuickEarConfig(prompt: "Same, step or leap?", choices: ["Same", "Step", "Leap"], questions: qs)
    }

    /// A four-note line in a major key, or the same line with one note that doesn't belong.
    nonisolated static func inKey(_ seed: String, count: Int = 10) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        let scale = [0, 2, 4, 5, 7, 9, 11, 12]
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            let tonic = 57 + rng.int(7)
            var line = [tonic]
            for _ in 0..<3 { line.append(tonic + scale[rng.int(scale.count)]) }
            let wrong = rng.int(2) == 1
            if wrong {
                // Push one of the later notes onto a note outside the key.
                let i = 1 + rng.int(3)
                let outside = [1, 3, 6, 8, 10][rng.int(5)]
                line[i] = tonic + outside
            }
            qs.append(EarQuestion(sound: .notes(line), answer: wrong ? 1 : 0))
        }
        return QuickEarConfig(prompt: "Does every note fit?", choices: ["Fits", "Wrong note"], questions: qs)
    }

    /// Three chords that either come home to the first chord or stop away from it.
    nonisolated static func homeAway(_ seed: String, count: Int = 10) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            let r = 55 + rng.int(7)
            let one = major(r), four = major(r + 5), five = major(r + 7), six = minor(r + 9)
            let home = rng.int(2) == 0
            let middle = rng.int(2) == 0 ? four : six
            let prog = home ? [one, middle, five, one] : [one, middle, one, five]
            qs.append(EarQuestion(sound: .chords(prog), answer: home ? 0 : 1))
        }
        return QuickEarConfig(prompt: "Did it land home?", choices: ["Home", "Still away"], questions: qs)
    }

    /// The same groove, straight or swung.
    nonisolated static func straightSwung(_ seed: String, groove: Pattern, count: Int = 8, swing: Double = 0.5) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            let swung = rng.int(2) == 1
            qs.append(EarQuestion(sound: .groove(groove, swing: swung ? swing : 0), answer: swung ? 1 : 0))
        }
        return QuickEarConfig(prompt: "Straight or swung?", choices: ["Straight", "Swung"], questions: qs)
    }

    /// A chord of one, two or three notes: how many do you hear?
    nonisolated static func noteCount(_ seed: String, count: Int = 10) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            let root = 55 + rng.int(8)
            let triad = rng.int(2) == 0 ? major(root) : minor(root)
            let n = 1 + rng.int(3)
            qs.append(EarQuestion(sound: .chord(Array(triad.prefix(n))), answer: n - 1))
        }
        return QuickEarConfig(prompt: "How many notes?", choices: ["One", "Two", "Three"], questions: qs)
    }

    /// The same note on a dark and a bright sound, in either order. `gap` 0...1: smaller is harder.
    nonisolated static func brighter(_ seed: String, count: Int = 10, gap: Double = 1) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            var dark = SynthPatch(saw: 0.7, square: 0.1, sine: 0.3, cutoff: 500, envAmount: 300, filterDecay: 0.3,
                                  resonance: 0.1, decay: 0.4, sustain: 0.5, release: 0.2, gain: 0.35)
            var bright = dark
            dark.cutoff = Float(500 + (1 - gap) * 1200 + Double(rng.int(200)))
            bright.cutoff = Float(1900 + gap * 3500 + Double(rng.int(400)))
            let first = rng.int(2) == 0
            let note = 55 + rng.int(10)
            qs.append(EarQuestion(sound: .voices(first ? [bright, dark] : [dark, bright], note: note), answer: first ? 0 : 1))
        }
        return QuickEarConfig(prompt: "Which was brighter?", choices: ["First", "Second"], questions: qs)
    }

    /// Three bars of one section, then a fourth that either repeats it or changes.
    nonisolated static func sameChanged(_ seed: String, sections: [Pattern], count: Int = 10) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        for _ in 0..<count {
            let a = rng.int(sections.count)
            let changed = rng.int(2) == 1
            var b = a
            if changed, sections.count > 1 { b = (a + 1 + rng.int(sections.count - 1)) % sections.count }
            qs.append(EarQuestion(sound: .grooves([sections[a], sections[a], sections[b]]), answer: b == a ? 0 : 1))
        }
        return QuickEarConfig(prompt: "Did the section change?", choices: ["Same", "Changed"], questions: qs)
    }

    /// Two bars from a list ordered sparse to full: which one was fuller?
    nonisolated static func fuller(_ seed: String, layers: [Pattern], count: Int = 10, closest: Int = 1) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        let n = layers.count
        for _ in 0..<count {
            let d = min(n - 1, closest + rng.int(max(1, n - closest)))
            let low = rng.int(max(1, n - d))
            let high = low + d
            let fullFirst = rng.int(2) == 0
            let pair = fullFirst ? [layers[high], layers[low]] : [layers[low], layers[high]]
            qs.append(EarQuestion(sound: .grooves(pair), answer: fullFirst ? 0 : 1))
        }
        return QuickEarConfig(prompt: "Which bar was fuller?", choices: ["First", "Second"], questions: qs)
    }

    /// Three bars that add layers or take them away.
    nonisolated static func buildDrop(_ seed: String, layers: [Pattern], count: Int = 10) -> QuickEarConfig {
        var rng = LevelRNG(seed)
        var qs: [EarQuestion] = []
        let n = layers.count
        for _ in 0..<count {
            let start = rng.int(max(1, n - 2))
            let run = [layers[start], layers[min(n - 1, start + 1)], layers[min(n - 1, start + 2)]]
            let building = rng.int(2) == 0
            qs.append(EarQuestion(sound: .grooves(building ? run : Array(run.reversed())), answer: building ? 0 : 1))
        }
        return QuickEarConfig(prompt: "Building up or dropping?", choices: ["Building", "Dropping"], questions: qs)
    }
}
