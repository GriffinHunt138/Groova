//
//  DSP.swift
//  Groova
//
//  A tiny real-time synthesizer: drum voices, a subtractive synth for bass/keys/chords,
//  a sample-accurate 16-step sequencer and a resonant master low-pass filter.
//  All sounds are synthesized from scratch. Nothing here touches the main actor.
//

import Foundation

// MARK: - Sound parameters

/// A subtractive synth preset (oscillators -> resonant low-pass -> amp envelope).
nonisolated struct SynthPatch: Sendable, Hashable {
    var saw: Float = 0.6
    var square: Float = 0
    var sine: Float = 0.4
    var detuneCents: Float = 0
    var cutoff: Float = 300
    var envAmount: Float = 1800
    var filterDecay: Float = 0.12
    var resonance: Float = 0.3
    var attack: Float = 0.003
    var decay: Float = 0.25
    var sustain: Float = 0.6
    var release: Float = 0.05
    var gain: Float = 0.45

    static let houseBass = SynthPatch(saw: 0.55, square: 0.15, sine: 0.6, cutoff: 260, envAmount: 1500,
                                      filterDecay: 0.11, resonance: 0.35, decay: 0.2, sustain: 0.55, gain: 0.5)
    static let technoBass = SynthPatch(saw: 0.8, square: 0, sine: 0.35, cutoff: 180, envAmount: 2600,
                                       filterDecay: 0.07, resonance: 0.6, decay: 0.12, sustain: 0.35, gain: 0.45)
    static let garageBass = SynthPatch(saw: 0.1, square: 0.5, sine: 0.75, cutoff: 420, envAmount: 900,
                                       filterDecay: 0.2, resonance: 0.15, decay: 0.3, sustain: 0.7, gain: 0.52)
    static let deepBass = SynthPatch(saw: 0.15, square: 0, sine: 0.9, cutoff: 350, envAmount: 500,
                                     filterDecay: 0.25, resonance: 0.1, decay: 0.35, sustain: 0.8, gain: 0.55)
    static let keys = SynthPatch(saw: 0.18, square: 0, sine: 0.8, cutoff: 1400, envAmount: 2600,
                                 filterDecay: 0.18, resonance: 0.1, attack: 0.002, decay: 0.7, sustain: 0.0,
                                 release: 0.25, gain: 0.32)
    static let stab = SynthPatch(saw: 0.7, square: 0.1, sine: 0.15, detuneCents: 9, cutoff: 700, envAmount: 3800,
                                 filterDecay: 0.09, resonance: 0.35, attack: 0.002, decay: 0.16, sustain: 0.25,
                                 release: 0.12, gain: 0.16)
    static let deepChord = SynthPatch(saw: 0.45, square: 0, sine: 0.5, detuneCents: 12, cutoff: 600, envAmount: 1400,
                                      filterDecay: 0.35, resonance: 0.15, attack: 0.01, decay: 0.6, sustain: 0.35,
                                      release: 0.35, gain: 0.13)
}

/// A drum kit. Each genre gets its own, so a techno kick really sounds different from a garage kick.
nonisolated struct DrumKit: Sendable, Hashable {
    var kickStartHz: Float = 170
    var kickEndHz: Float = 50
    var kickPitchDecay: Float = 0.032
    var kickDecay: Float = 0.32
    var kickDrive: Float = 1.4
    var kickClick: Float = 0.3
    var kickGain: Float = 0.95

    var clapTone: Float = 1250
    var clapDecay: Float = 0.15
    var clapGain: Float = 0.75

    var hatTone: Float = 7500
    var hatDecay: Float = 0.04
    var openHatDecay: Float = 0.26
    var hatGain: Float = 0.4

    var percHz: Float = 820
    var percDecay: Float = 0.055
    var percGain: Float = 0.5

    var bass: SynthPatch = .houseBass
    var chords: SynthPatch = .stab

    static let house = DrumKit()
    static let deepHouse = DrumKit(kickStartHz: 130, kickEndHz: 46, kickPitchDecay: 0.04, kickDecay: 0.36,
                                   kickDrive: 1.0, kickClick: 0.1, kickGain: 0.9, clapTone: 1000, clapDecay: 0.22,
                                   clapGain: 0.55, hatTone: 6000, hatDecay: 0.035, openHatDecay: 0.2, hatGain: 0.3,
                                   percHz: 600, percDecay: 0.08, percGain: 0.45, bass: .deepBass, chords: .deepChord)
    static let techno = DrumKit(kickStartHz: 210, kickEndHz: 44, kickPitchDecay: 0.025, kickDecay: 0.5,
                                kickDrive: 3.2, kickClick: 0.45, kickGain: 0.85, clapTone: 1600, clapDecay: 0.1,
                                clapGain: 0.55, hatTone: 9500, hatDecay: 0.028, openHatDecay: 0.18, hatGain: 0.38,
                                percHz: 1650, percDecay: 0.03, percGain: 0.45, bass: .technoBass, chords: .stab)
    static let techHouse = DrumKit(kickStartHz: 190, kickEndHz: 52, kickPitchDecay: 0.028, kickDecay: 0.28,
                                   kickDrive: 2.0, kickClick: 0.35, kickGain: 0.95, clapTone: 1400, clapDecay: 0.13,
                                   clapGain: 0.65, hatTone: 8500, hatDecay: 0.03, openHatDecay: 0.22, hatGain: 0.4,
                                   percHz: 980, percDecay: 0.045, percGain: 0.5, bass: .technoBass, chords: .stab)
    static let ukGarage = DrumKit(kickStartHz: 185, kickEndHz: 55, kickPitchDecay: 0.022, kickDecay: 0.22,
                                  kickDrive: 1.6, kickClick: 0.4, kickGain: 0.95, clapTone: 1900, clapDecay: 0.12,
                                  clapGain: 0.75, hatTone: 9000, hatDecay: 0.035, openHatDecay: 0.16, hatGain: 0.42,
                                  percHz: 1200, percDecay: 0.04, percGain: 0.45, bass: .garageBass, chords: .stab)
}

// MARK: - Voices

nonisolated enum VoiceKind: Sendable {
    case none, kick, clap, hat, openHat, perc, synth, vox
}

/// Extra state for a vocal chop voice.
nonisolated struct VoxVoice {
    var from: Int = 0
    var to: Int = 0
    var settings = VoxSettings()
    // Fixed-size vectors, so starting a voice never allocates on the audio thread.
    var g = SIMD4<Float>(repeating: 0)
    var k = SIMD4<Float>(repeating: 1)
    var s1 = SIMD4<Float>(repeating: 0)
    var s2 = SIMD4<Float>(repeating: 0)
    var vib: Float = 0
}

nonisolated struct Voice {
    var kind: VoiceKind = .none
    var t: Int = 0
    var gain: Float = 1
    var phase: Float = 0
    var phase2: Float = 0
    var freq: Float = 0
    var env: Float = 0
    var env2: Float = 0
    var coef: Float = 0
    var coef2: Float = 0
    var ic1: Float = 0
    var ic2: Float = 0
    var g: Float = 0
    var k: Float = 1
    // kick
    var startHz: Float = 0
    var endHz: Float = 0
    var drive: Float = 1
    var click: Float = 0
    // synth
    var patch = SynthPatch()
    var gate: Int = 0
    var attackSamples: Int = 1
    var decayCoef: Float = 0
    var releaseCoef: Float = 0
    var detuneRatio: Float = 1
    /// -1 hard left ... 0 centre ... 1 hard right.
    var pan: Float = 0
    /// Sandbox sends, 0...1.
    var rev: Float = 0
    var dly: Float = 0
    /// Sidechain depth for this voice. Below 0: use the global pump (synths only).
    var duck: Float = -1
    var vox = VoxVoice()
}

nonisolated enum ReverbSpace: Int, CaseIterable, Sendable {
    case room, plate, hall, cathedral

    var name: String {
        switch self {
        case .room: "Room"
        case .plate: "Plate"
        case .hall: "Hall"
        case .cathedral: "Cathedral"
        }
    }

    /// Rough tail length used by the visualisation.
    var seconds: Double {
        switch self {
        case .room: 0.5
        case .plate: 1.2
        case .hall: 2.2
        case .cathedral: 4.0
        }
    }
}

nonisolated enum PendingEvent {
    case drum(DrumTrack, Float, DrumKit)
    case note(midi: Int, seconds: Double, patch: SynthPatch, velocity: Float, delay: Double)
    case vox(midi: Int, seconds: Double, from: Int, to: Int, settings: VoxSettings)
}

nonisolated struct ScheduledNote {
    var time: Int64
    var midi: Int
    var gate: Int
    var patch: SynthPatch
    var velocity: Float
}

// MARK: - DSP helpers

@inline(__always) nonisolated func svfStep(_ x: Float, g: Float, k: Float,
                                           _ ic1: inout Float, _ ic2: inout Float) -> (lp: Float, bp: Float, hp: Float) {
    let a1 = 1 / (1 + g * (g + k))
    let a2 = g * a1
    let a3 = g * a2
    let v3 = x - ic2
    let v1 = a1 * ic1 + a2 * v3
    let v2 = ic2 + a2 * ic1 + a3 * v3
    ic1 = 2 * v1 - ic1
    ic2 = 2 * v2 - ic2
    return (v2, v1, x - k * v1 - v2)
}

// MARK: - Core

/// Owns all audio state. The render thread and the UI share it through `lock`.
nonisolated final class DSPCore: @unchecked Sendable {
    let lock = NSLock()

    var sampleRate: Float = 48_000
    private var voices = [Voice](repeating: Voice(), count: 40)
    private var rng: UInt32 = 0x9E37_79B9
    private var clock: Int64 = 0

    // Sequencer
    private(set) var seqPlaying = false
    var pattern = Pattern(kick: [])
    var kit = DrumKit.house
    var bpm: Double = 124
    var swing: Double = 0              // 0 ... 0.5 of a 16th
    var mutedDrums = Set<DrumTrack>()
    var bassMuted = false
    var chordsMuted = false
    /// When set, this pattern plays alongside `pattern`: overlay on the left, `pattern` on the right.
    var overlay: Pattern?
    /// Arrangement playback: one pattern per section, each held for `barsPerSection` bars.
    var sequence: [Pattern] = []
    var barsPerSection = 2
    private(set) var currentSection = -1
    /// Mixer: per-instrument level (1 = as designed) and sidechain pump depth (0...1).
    var drumLevels = [Float](repeating: 1, count: DrumTrack.allCases.count)
    var bassLevel: Float = 1
    var chordLevel: Float = 1
    var sidechain: Float = 0
    private var duckEnv: Float = 0
    private let duckBuf: UnsafeMutablePointer<Float>
    private var voicePan: Float = 0
    private var voiceGain: Float = 1
    private var voiceRev: Float = 0
    private var voiceDly: Float = 0
    private var voiceDuck: Float = -1

    /// Sandbox playback. When set, the sequencer plays this instead of `pattern`.
    var jam: JamSong?
    /// Bar of the loop that's playing in Sandbox playback, else -1.
    private(set) var currentBar = -1
    private var fx: JamFX?
    private var fxTail = 0
    private let revBus: UnsafeMutablePointer<Float>
    private let dlyBus: UnsafeMutablePointer<Float>
    private let scratchCapacity = 8192
    private let scratch: UnsafeMutablePointer<Float>
    private let rightBuf: UnsafeMutablePointer<Float>
    private var seqStart: Double = 0
    private var stepIndex = 0
    private var nextStepTime: Double = 0
    private var maxSteps = 0           // 0 = loop forever
    private(set) var currentStep = -1
    private(set) var finishedCount = 0

    // Events from the UI
    private var pending: [PendingEvent] = []
    private var scheduled: [ScheduledNote] = []

    // Master filter
    var cutoffTarget: Float = 20_000
    var resonance: Float = 0
    private var logCutoff: Float = log2f(20_000)
    private var fic1: Float = 0
    private var fic2: Float = 0
    private var fic1R: Float = 0
    private var fic2R: Float = 0
    private var fg: Float = 1
    var masterGain: Float = 0.8

    init() {
        scratch = .allocate(capacity: scratchCapacity)
        scratch.initialize(repeating: 0, count: scratchCapacity)
        rightBuf = .allocate(capacity: scratchCapacity)
        rightBuf.initialize(repeating: 0, count: scratchCapacity)
        duckBuf = .allocate(capacity: scratchCapacity)
        duckBuf.initialize(repeating: 1, count: scratchCapacity)
        revBus = .allocate(capacity: scratchCapacity)
        revBus.initialize(repeating: 0, count: scratchCapacity)
        dlyBus = .allocate(capacity: scratchCapacity)
        dlyBus.initialize(repeating: 0, count: scratchCapacity)
        pending.reserveCapacity(64)
        scheduled.reserveCapacity(64)
    }

    deinit {
        scratch.deallocate()
        rightBuf.deallocate()
        duckBuf.deallocate()
        revBus.deallocate()
        dlyBus.deallocate()
    }

    /// Renders one sound offline, for drawing it. Uses a throwaway core, never the live one.
    static func renderOffline(_ event: PendingEvent, seconds: Double, sampleRate: Float = 24_000) -> [Float] {
        let core = DSPCore()
        core.sampleRate = sampleRate
        let n = Int(Double(sampleRate) * seconds)
        var out = [Float](repeating: 0, count: n)
        core.lock.lock()
        core.enqueue(event)
        core.lock.unlock()
        out.withUnsafeMutableBufferPointer { buf in
            if let base = buf.baseAddress { core.render(base, right: nil, frames: n) }
        }
        return out
    }

    // MARK: Control (call with lock held via the AudioEngine wrappers)

    func enqueue(_ e: PendingEvent) { pending.append(e) }

    /// Builds the Sandbox send effects ahead of time, so the audio thread never has to.
    func prepareFX() {
        if fx?.sampleRate != sampleRate { fx = JamFX(sampleRate: sampleRate) }
    }

    func startSequencer(bars: Int?, from first: Int = 0) {
        seqPlaying = true
        stepIndex = max(0, first)
        // Shift the start back so step `first` lands 10 ms from now, with swing still on odd steps.
        seqStart = Double(clock) + Double(sampleRate) * 0.01 - Double(stepIndex) * samplesPerStep
        nextStepTime = stepTime(stepIndex)
        maxSteps = bars.map { $0 * Pattern.steps } ?? 0
    }

    /// Change tempo while playing, keeping the beat in place: the next step lands where it would have.
    func setTempo(_ newBPM: Double) {
        guard newBPM > 20 else { return }
        guard seqPlaying else { bpm = newBPM; return }
        let base = seqStart + Double(stepIndex) * samplesPerStep
        bpm = newBPM
        seqStart = base - Double(stepIndex) * samplesPerStep
        nextStepTime = max(Double(clock), stepTime(stepIndex))
    }

    func stopSequencer() {
        seqPlaying = false
        currentStep = -1
        currentSection = -1
        currentBar = -1
    }

    private var samplesPerStep: Double { Double(sampleRate) * 60.0 / bpm / 4.0 }

    private func stepTime(_ n: Int) -> Double {
        seqStart + Double(n) * samplesPerStep + (n % 2 == 1 ? swing * samplesPerStep : 0)
    }

    // MARK: Render

    /// Renders stereo: `out` is the left channel, `outRight` (if given) the right.
    func render(_ out: UnsafeMutablePointer<Float>, right outRight: UnsafeMutablePointer<Float>?, frames total: Int) {
        lock.lock()
        defer { lock.unlock() }
        var done = 0
        while done < total {
            let chunk = min(scratchCapacity, total - done)
            renderChunk(out + done, frames: chunk)
            if let outRight {
                (outRight + done).update(from: rightBuf, count: chunk)
            } else {
                for i in 0..<chunk { out[done + i] = 0.5 * (out[done + i] + rightBuf[i]) }
            }
            done += chunk
        }
    }

    private func renderChunk(_ out: UnsafeMutablePointer<Float>, frames: Int) {
        for i in 0..<frames { out[i] = 0; rightBuf[i] = 0; revBus[i] = 0; dlyBus[i] = 0 }
        var sent = false

        // Immediate events from the UI start at the top of this buffer.
        for e in pending {
            switch e {
            case let .drum(track, vel, kit):
                startDrum(track, velocity: vel, kit: kit)
            case let .note(midi, seconds, patch, velocity, delay):
                let gate = max(1, Int(seconds * Double(sampleRate)))
                if delay <= 0 {
                    startSynth(midi: midi, gate: gate, patch: patch, velocity: velocity)
                } else {
                    scheduled.append(ScheduledNote(time: clock + Int64(delay * Double(sampleRate)),
                                                   midi: midi, gate: gate, patch: patch, velocity: velocity))
                }
            case let .vox(midi, seconds, from, to, settings):
                startVox(midi: midi, gate: max(1, Int(seconds * Double(sampleRate))), from: from, to: to,
                         settings: settings, velocity: 1)
            }
        }
        pending.removeAll(keepingCapacity: true)

        var pos = 0
        while pos < frames {
            // Fire anything due now.
            if seqPlaying {
                while seqPlaying && Double(clock) >= nextStepTime { fireStep() }
            }
            var nextEvent = Double.infinity
            if !scheduled.isEmpty {
                var i = 0
                while i < scheduled.count {
                    let s = scheduled[i]
                    if s.time <= clock {
                        startSynth(midi: s.midi, gate: s.gate, patch: s.patch, velocity: s.velocity)
                        scheduled.remove(at: i)
                    } else {
                        nextEvent = min(nextEvent, Double(s.time))
                        i += 1
                    }
                }
            }
            if seqPlaying { nextEvent = min(nextEvent, nextStepTime) }

            var segEnd = frames
            if nextEvent.isFinite {
                let ahead = max(1, Int((nextEvent - Double(clock)).rounded(.up)))
                segEnd = min(frames, pos + ahead)
            }
            let n = segEnd - pos
            let ptrL = out + pos
            let ptrR = rightBuf + pos
            // Sidechain: voices duck after every sequenced kick, then swell back.
            // duckBuf holds the envelope; each voice scales it by its own depth.
            let ducking = duckEnv > 0.0005
            if ducking {
                let coef = coefFor(0.16)
                for i in 0..<n {
                    duckBuf[i] = duckEnv
                    duckEnv *= coef
                }
            }
            for v in 0..<voices.count where voices[v].kind != .none {
                let pan = voices[v].pan
                let isSynth = voices[v].kind == .synth
                let depth = voices[v].duck >= 0 ? voices[v].duck : (isSynth ? sidechain : 0)
                for i in 0..<n { scratch[i] = 0 }
                renderVoice(&voices[v], scratch, n)
                if ducking && depth > 0.001 {
                    for i in 0..<n { scratch[i] *= 1 - depth * duckBuf[i] }
                }
                let gl: Float = pan > 0 ? 1 - pan : 1
                let gr: Float = pan < 0 ? 1 + pan : 1
                for i in 0..<n {
                    ptrL[i] += scratch[i] * gl
                    ptrR[i] += scratch[i] * gr
                }
                let rev = voices[v].rev, dly = voices[v].dly
                if rev > 0.001 {
                    sent = true
                    let bus = revBus + pos
                    for i in 0..<n { bus[i] += scratch[i] * rev }
                }
                if dly > 0.001 {
                    sent = true
                    let bus = dlyBus + pos
                    for i in 0..<n { bus[i] += scratch[i] * dly }
                }
            }
            clock += Int64(n)
            pos = segEnd
        }

        // Sandbox sends. Keep running a few seconds after the last send so tails ring out.
        if sent { fxTail = Int(sampleRate * 4) }
        if fxTail > 0 {
            if fx == nil || fx?.sampleRate != sampleRate { fx = JamFX(sampleRate: sampleRate) }
            fx?.process(delayIn: dlyBus, reverbIn: revBus, left: out, right: rightBuf, frames: frames,
                        delaySamples: Int(samplesPerStep * 3))
            fxTail -= frames
        }

        // Master: resonant low-pass + soft clip.
        let targetLog = log2f(max(40, min(cutoffTarget, 20_000)))
        let filterActive = targetLog < 14.2 || logCutoff < 14.2
        let k = 2 * (1 - 0.96 * max(0, min(resonance, 1)))
        let sr = sampleRate
        for i in 0..<frames {
            var x = out[i]
            var y = rightBuf[i]
            if filterActive {
                if i & 15 == 0 {
                    logCutoff += (targetLog - logCutoff) * 0.04
                    let fc = min(exp2f(logCutoff), sr * 0.45)
                    fg = tanf(Float.pi * fc / sr)
                }
                x = svfStep(x, g: fg, k: k, &fic1, &fic2).lp
                y = svfStep(y, g: fg, k: k, &fic1R, &fic2R).lp
            } else {
                logCutoff = targetLog
                fic1 = 0; fic2 = 0
                fic1R = 0; fic2R = 0
            }
            out[i] = tanhf(x * masterGain)
            rightBuf[i] = tanhf(y * masterGain)
        }
    }

    private func fireStep() {
        if maxSteps > 0 && stepIndex >= maxSteps {
            seqPlaying = false
            currentStep = -1
            finishedCount += 1
            return
        }
        let s = stepIndex % Pattern.steps
        currentStep = s
        if let jam {
            fireJam(jam)
        } else if !sequence.isEmpty {
            let section = (stepIndex / Pattern.steps / max(1, barsPerSection)) % sequence.count
            currentSection = section
            fire(sequence[section], step: s)
        } else if let overlay {
            // Compare mode: reference in the left ear, yours in the right. Matching hits sound centred.
            voiceGain = 0.75
            voicePan = -0.85
            fire(overlay, step: s)
            voicePan = 0.85
            fire(pattern, step: s)
            voicePan = 0
            voiceGain = 1
        } else {
            fire(pattern, step: s)
        }
        stepIndex += 1
        nextStepTime = stepTime(stepIndex)
    }

    private func fireJam(_ jam: JamSong) {
        let (section, pos) = jam.locate(stepIndex)
        currentSection = section
        currentBar = pos / Pattern.steps
        let mask = section >= 0 && section < jam.sections.count ? jam.sections[section].lanes : []
        for (l, lane) in jam.lanes.enumerated() {
            if !mask.isEmpty && (l >= mask.count || !mask[l]) { continue }
            guard lane.level > 0.001, pos < lane.steps.count else { continue }
            let events = lane.steps[pos]
            if events.isEmpty { continue }
            voicePan = lane.pan
            voiceRev = lane.reverb
            voiceDly = lane.delay
            voiceDuck = lane.duck
            for e in events {
                switch e {
                case let .drum(track, vel):
                    startDrum(track, velocity: vel * lane.level, kit: lane.kit)
                    if track == .kick { duckEnv = 1 }
                case let .note(midi, steps, vel):
                    let gate = Int(Double(steps) * samplesPerStep * 0.92)
                    startSynth(midi: midi, gate: gate, patch: lane.patch, velocity: vel * lane.level)
                case let .vox(midi, steps, from, to):
                    let gate = Int(Double(steps) * samplesPerStep * 0.92)
                    startVox(midi: midi, gate: gate, from: from, to: to, settings: lane.vox, velocity: lane.level)
                }
            }
        }
        voicePan = 0
        voiceRev = 0
        voiceDly = 0
        voiceDuck = -1
    }

    private func fire(_ p: Pattern, step s: Int) {
        for track in DrumTrack.allCases where p[track][s] && !mutedDrums.contains(track) {
            var vel: Float = 1
            if track == .hat { vel = (s % 4 == 2) ? 1.0 : 0.72 }
            let level = drumLevels[track.rawValue]
            if level > 0.001 { startDrum(track, velocity: vel * level, kit: kit) }
            if track == .kick { duckEnv = 1 }
        }
        if !bassMuted && bassLevel > 0.001 {
            for note in p.bass where note.step == s {
                let gate = Int(Double(note.length) * samplesPerStep * 0.9)
                startSynth(midi: note.pitch, gate: gate, patch: kit.bass, velocity: bassLevel)
            }
        }
        if !chordsMuted && chordLevel > 0.001 {
            for chord in p.chords where chord.step == s {
                let gate = Int(Double(chord.length) * samplesPerStep * 0.9)
                for pitch in chord.pitches { startSynth(midi: pitch, gate: gate, patch: kit.chords, velocity: chordLevel) }
            }
        }
    }

    // MARK: Voice allocation

    private func allocate() -> Int {
        var oldest = 0
        var oldestT = -1
        for i in 0..<voices.count {
            if voices[i].kind == .none { return i }
            if voices[i].t > oldestT { oldestT = voices[i].t; oldest = i }
        }
        return oldest
    }

    private func coefFor(_ seconds: Float) -> Float {
        expf(-1 / max(0.0005, seconds) / sampleRate)
    }

    private func startDrum(_ track: DrumTrack, velocity: Float, kit: DrumKit) {
        var v = Voice()
        v.t = 0
        switch track {
        case .kick:
            v.kind = .kick
            v.startHz = kit.kickStartHz
            v.endHz = kit.kickEndHz
            v.env = 1
            v.env2 = 1
            v.coef = coefFor(kit.kickDecay)
            v.coef2 = coefFor(kit.kickPitchDecay)
            v.drive = kit.kickDrive
            v.click = kit.kickClick
            v.gain = kit.kickGain * velocity
        case .clap:
            v.kind = .clap
            v.env = 1
            v.coef = coefFor(kit.clapDecay)
            v.g = tanf(Float.pi * kit.clapTone / sampleRate)
            v.k = 1.1
            v.gain = kit.clapGain * velocity * 2.2
        case .hat, .openHat:
            v.kind = track == .hat ? .hat : .openHat
            v.env = 1
            v.coef = coefFor(track == .hat ? kit.hatDecay : kit.openHatDecay)
            v.g = tanf(Float.pi * min(kit.hatTone, sampleRate * 0.45) / sampleRate)
            v.k = 1.4
            v.gain = kit.hatGain * velocity * (track == .openHat ? 0.8 : 1)
            if track == .hat {
                // Closed hat chokes ringing open hats, like real hardware.
                let choke = coefFor(0.012)
                for i in 0..<voices.count where voices[i].kind == .openHat { voices[i].coef = choke }
            }
        case .perc:
            v.kind = .perc
            v.freq = kit.percHz
            v.env = 1
            v.env2 = 1
            v.coef = coefFor(kit.percDecay)
            v.coef2 = coefFor(0.006)
            v.g = tanf(Float.pi * min(kit.percHz * 2.2, sampleRate * 0.45) / sampleRate)
            v.k = 0.8
            v.gain = kit.percGain * velocity
        }
        v.pan = voicePan
        v.gain *= voiceGain
        v.rev = voiceRev
        v.dly = voiceDly
        v.duck = voiceDuck >= 0 ? voiceDuck : 0
        let slot = allocate()
        voices[slot] = v
    }

    private func startSynth(midi: Int, gate: Int, patch: SynthPatch, velocity: Float) {
        var v = Voice()
        v.kind = .synth
        v.freq = Float(NoteName.frequency(midi))
        v.patch = patch
        v.gate = gate
        v.attackSamples = max(1, Int(patch.attack * sampleRate))
        v.decayCoef = coefFor(patch.decay)
        v.releaseCoef = coefFor(patch.release)
        v.env = 0
        v.env2 = 1
        v.coef2 = coefFor(patch.filterDecay)
        v.k = 2 * (1 - 0.9 * patch.resonance)
        v.gain = patch.gain * velocity
        v.detuneRatio = exp2f(patch.detuneCents / 1200)
        v.phase = Float(Double(rng % 1000) / 1000)
        rng = rng &* 1_664_525 &+ 1_013_904_223
        v.pan = voicePan
        v.gain *= voiceGain
        v.rev = voiceRev
        v.dly = voiceDly
        v.duck = voiceDuck
        let slot = allocate()
        voices[slot] = v
    }

    private func startVox(midi: Int, gate: Int, from: Int, to: Int, settings: VoxSettings, velocity: Float) {
        var v = Voice()
        v.kind = .vox
        v.freq = Float(NoteName.frequency(midi))
        v.gate = gate
        v.attackSamples = max(1, Int(settings.attack * sampleRate))
        v.releaseCoef = coefFor(0.07)
        v.env = 0
        v.gain = settings.gain * velocity
        v.vox.from = max(0, min(Vowel.formants.count - 1, from))
        v.vox.to = max(0, min(Vowel.formants.count - 1, to))
        v.vox.settings = settings
        v.phase = Float(Double(rng % 1000) / 1000)
        rng = rng &* 1_664_525 &+ 1_013_904_223
        v.pan = voicePan
        v.rev = voiceRev
        v.dly = voiceDly
        v.duck = voiceDuck >= 0 ? voiceDuck : 0
        let slot = allocate()
        voices[slot] = v
    }

    @inline(__always) private func noise() -> Float {
        rng ^= rng << 13
        rng ^= rng >> 17
        rng ^= rng << 5
        return Float(Int32(bitPattern: rng)) / 2_147_483_648
    }

    // MARK: Voice rendering

    private func renderVoice(_ v: inout Voice, _ out: UnsafeMutablePointer<Float>, _ n: Int) {
        let sr = sampleRate
        let inv = 1 / sr
        let twoPi = 2 * Float.pi
        switch v.kind {
        case .none:
            return

        case .kick:
            let clickLen = Int(0.004 * sr)
            let norm = 1 / tanhf(v.drive)
            for i in 0..<n {
                let f = v.endHz + (v.startHz - v.endHz) * v.env2
                v.phase += f * inv
                if v.phase >= 1 { v.phase -= 1 }
                var s = sinf(twoPi * v.phase) * v.env
                if v.t < clickLen {
                    s += noise() * v.click * (1 - Float(v.t) / Float(clickLen))
                }
                s = tanhf(s * v.drive) * norm
                out[i] += s * v.gain
                v.env *= v.coef
                v.env2 *= v.coef2
                v.t += 1
            }
            if v.env < 0.0005 { v.kind = .none }

        case .clap:
            let burst = Int(0.0105 * sr)
            let burstDecay = 0.0032 * sr
            for i in 0..<n {
                let x = noise()
                let bp = svfStep(x, g: v.g, k: v.k, &v.ic1, &v.ic2).bp
                let e: Float
                if v.t < burst * 3 {
                    let local = v.t % burst
                    e = expf(-Float(local) / burstDecay) * (v.t < burst * 2 ? 0.75 : 1)
                } else {
                    e = v.env
                    v.env *= v.coef
                }
                out[i] += bp * e * v.gain
                v.t += 1
            }
            if v.t > burst * 3 && v.env < 0.0005 { v.kind = .none }

        case .hat, .openHat:
            for i in 0..<n {
                let x = noise()
                let r = svfStep(x, g: v.g, k: v.k, &v.ic1, &v.ic2)
                out[i] += (r.hp * 0.8 + r.bp * 0.4) * v.env * v.gain
                v.env *= v.coef
                v.t += 1
            }
            if v.env < 0.0005 { v.kind = .none }

        case .perc:
            for i in 0..<n {
                v.phase += v.freq * inv
                if v.phase >= 1 { v.phase -= 1 }
                let tri = 4 * abs(v.phase - 0.5) - 1
                let bp = svfStep(noise(), g: v.g, k: v.k, &v.ic1, &v.ic2).bp
                out[i] += (tri * v.env + bp * v.env2 * 0.6) * v.gain
                v.env *= v.coef
                v.env2 *= v.coef2
                v.t += 1
            }
            if v.env < 0.0005 { v.kind = .none }

        case .synth:
            let p = v.patch
            let maxFc = sr * 0.45
            let sustain = p.sustain
            for i in 0..<n {
                // Amp envelope
                if v.t < v.attackSamples {
                    v.env = Float(v.t) / Float(v.attackSamples)
                } else if v.t < v.gate {
                    v.env = sustain + (v.env - sustain) * v.decayCoef
                } else {
                    v.env *= v.releaseCoef
                }
                // Filter envelope, updated every 8 samples
                if v.t & 7 == 0 {
                    let fc = min(maxFc, max(30, p.cutoff + p.envAmount * v.env2))
                    v.g = tanf(Float.pi * fc / sr)
                }
                v.env2 *= v.coef2

                v.phase += v.freq * inv
                if v.phase >= 1 { v.phase -= 1 }
                v.phase2 += v.freq * v.detuneRatio * inv
                if v.phase2 >= 1 { v.phase2 -= 1 }

                var osc = p.sine * sinf(twoPi * v.phase)
                if p.saw > 0 {
                    let saw1 = 2 * v.phase - 1
                    let saw2 = 2 * v.phase2 - 1
                    osc += p.saw * (p.detuneCents != 0 ? (saw1 + saw2) * 0.5 : saw1)
                }
                if p.square > 0 { osc += p.square * (v.phase < 0.5 ? 1 : -1) }
                let lp = svfStep(osc, g: v.g, k: v.k, &v.ic1, &v.ic2).lp
                out[i] += lp * v.env * v.gain
                v.t += 1
            }
            if v.t >= v.gate && v.env < 0.0003 { v.kind = .none }

        case .vox:
            // A pulse-like source through three formant band-passes that glide between two vowels.
            let set = v.vox.settings
            let a = Vowel.formants[v.vox.from], b = Vowel.formants[v.vox.to]
            let glide = max(1, Float(v.gate) * 0.6)
            let maxFc = sr * 0.45
            for i in 0..<n {
                if v.t < v.attackSamples {
                    v.env = Float(v.t) / Float(v.attackSamples)
                } else if v.t < v.gate {
                    v.env = 0.85 + (v.env - 0.85) * 0.9995
                } else {
                    v.env *= v.releaseCoef
                }
                if v.t & 7 == 0 {
                    let mix = min(1, Float(v.t) / glide)
                    let w = mix * mix * (3 - 2 * mix)
                    for f in 0..<3 {
                        let hz = min(maxFc, (a[f] + (b[f] - a[f]) * w) * set.formant)
                        v.vox.g[f] = tanf(Float.pi * hz / sr)
                        v.vox.k[f] = max(0.04, min(1.5, Vowel.bandwidth[f] * set.formant / hz))
                    }
                }
                // Vibrato fades in after the first 120 ms.
                v.vox.vib += 5.5 * inv
                if v.vox.vib >= 1 { v.vox.vib -= 1 }
                let fade = min(1, max(0, Float(v.t) * inv - 0.12) * 4)
                let bend = exp2f(set.vibrato * fade * sinf(twoPi * v.vox.vib) / 12)
                v.phase += v.freq * bend * inv
                if v.phase >= 1 { v.phase -= 1 }
                var src: Float = set.robot ? (v.phase < 0.5 ? 0.8 : -0.8) : (1 - 2 * v.phase)
                src = src * (1 - set.breath * 0.7) + noise() * set.breath
                var y: Float = 0
                for f in 0..<3 {
                    var z1 = v.vox.s1[f], z2 = v.vox.s2[f]
                    let bp = svfStep(src, g: v.vox.g[f], k: v.vox.k[f], &z1, &z2).bp
                    v.vox.s1[f] = z1
                    v.vox.s2[f] = z2
                    y += bp * v.vox.k[f] * Vowel.gains[f]
                }
                out[i] += y * v.env * v.gain * 2.4
                v.t += 1
            }
            if v.t >= v.gate && v.env < 0.0003 { v.kind = .none }
        }
    }
}
