//
//  SoundFlavor.swift
//  Groova
//
//  Small, genre-safe twists on a kit so every listening exercise sounds a little different.
//  Flavor 0 is the genre's own kit. The reference and your version always share a flavor,
//  so comparisons stay fair.
//

import Foundation

nonisolated enum SoundFlavor {
    static let count = 6

    static func kit(_ base: DrumKit, _ flavor: Int) -> DrumKit {
        var k = base
        switch ((flavor % count) + count) % count {
        case 1: // warm
            k.kickStartHz -= 18; k.kickDecay += 0.05
            k.clapTone -= 180; k.hatTone -= 1200
            k.chords = .electricPiano
            k.bass.sine = min(1, k.bass.sine + 0.2); k.bass.cutoff *= 0.85
        case 2: // bright
            k.kickClick += 0.15; k.hatTone += 1200; k.clapDecay = max(0.07, k.clapDecay - 0.03)
            k.chords = .organ
            k.bass.square += 0.2; k.bass.envAmount *= 1.2
        case 3: // punchy
            k.kickDecay = max(0.15, k.kickDecay - 0.08); k.kickDrive += 0.6
            k.percHz *= 1.3; k.clapGain *= 0.9
            k.chords = .pluck
        case 4: // dusty
            k.hatGain *= 0.75; k.clapTone += 300; k.clapDecay += 0.05; k.hatDecay += 0.012
            k.chords = .softPad
            k.bass.cutoff *= 0.75; k.bass.resonance *= 0.6
        case 5: // rubbery
            k.kickStartHz += 15; k.openHatDecay += 0.08; k.percDecay += 0.02
            k.chords.detuneCents += 8; k.chords.cutoff *= 1.3
            k.bass.resonance = min(0.8, k.bass.resonance + 0.2); k.bass.filterDecay *= 1.4
        default:
            break
        }
        return k
    }

    /// The instrument an ear-training round plays its chords on.
    static func earPatch(_ flavor: Int) -> SynthPatch {
        let patches: [SynthPatch] = [.keys, .electricPiano, .organ, .keys, .softPad, .pluck]
        return patches[((flavor % patches.count) + patches.count) % patches.count]
    }

    /// A stable number for a lesson step, so the same step always sounds the same.
    static func seed(_ id: String, step: Int) -> Int {
        id.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) & 0xFFFF } &+ step
    }
}

extension SynthPatch {
    nonisolated static let electricPiano = SynthPatch(saw: 0.05, square: 0, sine: 0.9, detuneCents: 4, cutoff: 1800,
                                                      envAmount: 1600, filterDecay: 0.2, resonance: 0.05, attack: 0.002,
                                                      decay: 0.55, sustain: 0.2, release: 0.3, gain: 0.2)
    nonisolated static let organ = SynthPatch(saw: 0.1, square: 0.55, sine: 0.45, detuneCents: 3, cutoff: 1500,
                                              envAmount: 400, filterDecay: 0.1, resonance: 0.1, attack: 0.004,
                                              decay: 0.2, sustain: 0.7, release: 0.08, gain: 0.13)
    nonisolated static let pluck = SynthPatch(saw: 0.6, square: 0.05, sine: 0.3, detuneCents: 6, cutoff: 500,
                                              envAmount: 4200, filterDecay: 0.06, resonance: 0.3, attack: 0.001,
                                              decay: 0.12, sustain: 0.0, release: 0.1, gain: 0.18)
    nonisolated static let softPad = SynthPatch(saw: 0.4, square: 0, sine: 0.55, detuneCents: 14, cutoff: 650,
                                                envAmount: 900, filterDecay: 0.4, resonance: 0.12, attack: 0.04,
                                                decay: 0.6, sustain: 0.45, release: 0.4, gain: 0.13)
}
