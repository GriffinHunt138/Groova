//
//  ChopSong.swift
//  Groova
//
//  Lesson loops with vocal chops play through the Sandbox engine, which has the vocal synth.
//  This turns a one-bar lesson loop and a lane of chops into a song it can play.
//

import Foundation

nonisolated enum ChopSong {
    /// The backing's drums, bass and chords, plus one vocal lane per entry in `lanes`
    /// (two lanes play side by side, left and right, for comparing).
    static func song(backing: Pattern, kit: DrumKit, chops: [VoxChop], lanes: [[Int?]], length: Int,
                     vox: VoxSettings) -> JamSong {
        let n = Pattern.steps
        let empty = [[JamEvent]](repeating: [], count: n)

        var drums = JamLaneData()
        drums.steps = empty
        drums.kit = kit
        for s in 0..<n {
            for t in DrumTrack.allCases where backing[t][s] {
                let vel: Float = t == .hat ? (s % 4 == 2 ? 1 : 0.72) : 1
                drums.steps[s].append(.drum(t, vel))
            }
        }

        var bass = JamLaneData()
        bass.steps = empty
        bass.patch = kit.bass
        bass.duck = 0.5
        for note in backing.bass where note.step >= 0 && note.step < n {
            bass.steps[note.step].append(.note(note.pitch, Float(note.length), 1))
        }

        var keys = JamLaneData()
        keys.steps = empty
        keys.patch = kit.chords
        keys.level = 0.8
        keys.duck = 0.4
        keys.reverb = 0.15
        for c in backing.chords where c.step >= 0 && c.step < n {
            for p in c.pitches { keys.steps[c.step].append(.note(p, Float(c.length), 1)) }
        }

        var out = [drums, bass, keys]
        for (i, cells) in lanes.enumerated() {
            var v = JamLaneData()
            v.steps = empty
            v.vox = vox
            v.reverb = 0.25
            v.delay = 0.12
            v.pan = lanes.count > 1 ? (i == 0 ? -0.45 : 0.45) : 0
            for (s, idx) in cells.enumerated() where s < n {
                guard let idx, idx >= 0, idx < chops.count else { continue }
                let c = chops[idx]
                v.steps[s].append(.vox(c.pitch, Float(length), c.from, c.to))
            }
            out.append(v)
        }
        return JamSong(lanes: out, loopSteps: n)
    }

    /// Classic chop shapes: a short "oh", a rising "yeah", a bright "ee", an "ah" that falls to "oo".
    static func chops(_ pitches: [Int]) -> [VoxChop] {
        let shapes: [(String, Int, Int)] = [("Oh", 3, 3), ("Yeah", 1, 0), ("Ee", 2, 2), ("Ah-oo", 0, 4), ("Hey", 1, 2)]
        return pitches.enumerated().map { i, p in
            let s = shapes[i % shapes.count]
            return VoxChop(name: s.0, pitch: p, from: s.1, to: s.2)
        }
    }
}
