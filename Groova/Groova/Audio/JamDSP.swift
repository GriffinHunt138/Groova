//
//  JamDSP.swift
//  Groova
//
//  Render-side data for Sandbox playback: an 8-bar loop split into lanes, each with its own
//  sound and effect sends, plus the song's sections. Also the vocal chop voice settings and
//  the small send effects (ping-pong delay and reverb) the Sandbox mixes into.
//

import Foundation

nonisolated enum JamEvent: Sendable {
    case drum(DrumTrack, Float)
    /// A synth note held for `steps` sixteenths.
    case note(Int, Float, Float)
    /// A vocal chop: pitch, length in steps, vowel it starts on and vowel it glides to.
    case vox(Int, Float, Int, Int)
}

/// How a vocal chop voice sounds.
nonisolated struct VoxSettings: Sendable, Hashable {
    /// Multiplies every formant. Above 1 sounds smaller and brighter, below 1 bigger and darker.
    var formant: Float = 1
    /// Noise mixed into the voice, 0...1.
    var breath: Float = 0.12
    /// Vibrato depth in semitones.
    var vibrato: Float = 0.12
    /// Square source instead of a saw: robotic.
    var robot = false
    var attack: Float = 0.008
    var gain: Float = 0.5
}

/// One playable lane of the loop.
nonisolated struct JamLaneData: Sendable {
    /// Events at each step of the loop, `loopSteps` long.
    var steps: [[JamEvent]] = []
    var kit = DrumKit.house
    var patch = SynthPatch()
    var vox = VoxSettings()
    var level: Float = 1
    var pan: Float = 0
    var reverb: Float = 0
    var delay: Float = 0
    /// How much this lane ducks under the kick, 0...1.
    var duck: Float = 0
}

nonisolated struct JamSectionData: Sendable {
    var bars: Int
    /// One flag per lane.
    var lanes: [Bool]
}

nonisolated struct JamSong: Sendable {
    var lanes: [JamLaneData]
    var loopSteps: Int
    /// Empty: loop forever. Otherwise play the sections in order, then start again.
    var sections: [JamSectionData] = []

    var totalSteps: Int { sections.reduce(0) { $0 + $1.bars * Pattern.steps } }

    /// For a step of the song: which section, and where in the loop.
    func locate(_ n: Int) -> (section: Int, pos: Int) {
        guard !sections.isEmpty, totalSteps > 0 else { return (-1, n % max(1, loopSteps)) }
        var m = n % totalSteps
        for (i, s) in sections.enumerated() {
            let len = s.bars * Pattern.steps
            if m < len { return (i, m % max(1, loopSteps)) }
            m -= len
        }
        return (0, 0)
    }

    /// First step of a section.
    func start(of section: Int) -> Int {
        sections.prefix(max(0, section)).reduce(0) { $0 + $1.bars * Pattern.steps }
    }
}

// MARK: - Vowels

nonisolated enum Vowel {
    /// a, e, i, o, u: first three formants (Hz) and their bandwidths.
    static let formants: [[Float]] = [
        [800, 1150, 2900],
        [480, 1750, 2600],
        [300, 2300, 3000],
        [450, 800, 2830],
        [325, 700, 2530],
    ]
    static let bandwidth: [Float] = [80, 90, 120]
    static let gains: [Float] = [1, 0.55, 0.28]
}

// MARK: - Send effects

/// A stereo ping-pong delay and a small Freeverb-style reverb, fed by per-voice sends.
nonisolated final class JamFX {
    let sampleRate: Float
    private var dlyL: [Float], dlyR: [Float]
    private var dlyPos = 0
    private var dlyLP: Float = 0, dlyLPR: Float = 0

    private var combs: [[Float]] = []
    private var combPos: [Int] = []
    private var combStore: [Float] = []
    private var aps: [[Float]] = []
    private var apPos: [Int] = []

    private static let combTuning = [1116, 1188, 1277, 1356]
    private static let apTuning = [556, 441]
    private static let stereoSpread = 23

    init(sampleRate: Float) {
        self.sampleRate = sampleRate
        let maxDelay = Int(sampleRate * 2)
        dlyL = [Float](repeating: 0, count: maxDelay)
        dlyR = [Float](repeating: 0, count: maxDelay)
        let scale = sampleRate / 44_100
        for ch in 0..<2 {
            for t in Self.combTuning {
                combs.append([Float](repeating: 0, count: max(8, Int(Float(t + ch * Self.stereoSpread) * scale))))
                combPos.append(0)
                combStore.append(0)
            }
            for t in Self.apTuning {
                aps.append([Float](repeating: 0, count: max(8, Int(Float(t + ch * Self.stereoSpread) * scale))))
                apPos.append(0)
            }
        }
    }

    /// Adds the wet signal of both sends into `left` and `right`.
    func process(delayIn: UnsafePointer<Float>, reverbIn: UnsafePointer<Float>, left: UnsafeMutablePointer<Float>,
                 right: UnsafeMutablePointer<Float>, frames: Int, delaySamples: Int) {
        let d = max(1, min(dlyL.count - 1, delaySamples))
        let size = dlyL.count
        let feedback: Float = 0.42
        let damp: Float = 0.28, room: Float = 0.84
        for i in 0..<frames {
            // Ping-pong: the input goes left, each repeat swaps sides.
            var read = dlyPos - d
            if read < 0 { read += size }
            let outL = dlyL[read], outR = dlyR[read]
            dlyLP += (outR - dlyLP) * 0.5
            dlyLPR += (outL - dlyLPR) * 0.5
            dlyL[dlyPos] = delayIn[i] + dlyLP * feedback
            dlyR[dlyPos] = dlyLPR * feedback
            dlyPos += 1
            if dlyPos >= size { dlyPos = 0 }
            left[i] += outL * 0.7
            right[i] += outR * 0.7

            // Reverb: four damped combs into two allpasses, per side.
            let x = reverbIn[i] * 0.03
            for ch in 0..<2 {
                var acc: Float = 0
                for c in 0..<4 {
                    let idx = ch * 4 + c
                    let p = combPos[idx]
                    let y = combs[idx][p]
                    combStore[idx] = y * (1 - damp) + combStore[idx] * damp
                    combs[idx][p] = x + combStore[idx] * room
                    combPos[idx] = p + 1 >= combs[idx].count ? 0 : p + 1
                    acc += y
                }
                for a in 0..<2 {
                    let idx = ch * 2 + a
                    let p = apPos[idx]
                    let buf = aps[idx][p]
                    let y = buf - acc
                    aps[idx][p] = acc + buf * 0.5
                    apPos[idx] = p + 1 >= aps[idx].count ? 0 : p + 1
                    acc = y
                }
                if ch == 0 { left[i] += acc * 1.6 } else { right[i] += acc * 1.6 }
            }
        }
    }
}
