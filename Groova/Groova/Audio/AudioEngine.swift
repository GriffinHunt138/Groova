//
//  AudioEngine.swift
//  Groova
//
//  AVAudioEngine graph:  DSPCore (source node) -> Reverb -> Main mixer -> Output
//  A tap on the mixer feeds a lightweight spectrum analyser for the visuals.
//

import AVFoundation
import Foundation

nonisolated final class AudioEngine: @unchecked Sendable {
    static let shared = AudioEngine()

    let core = DSPCore()
    private let engine = AVAudioEngine()
    private let reverb = AVAudioUnitReverb()
    private var source: AVAudioSourceNode?
    private var isSetUp = false
    private var observers: [NSObjectProtocol] = []

    private let analysisLock = NSLock()
    private var analysisEnabled = false
    private var spectrum = [Float](repeating: 0, count: Spectrum.bandCount)
    private var window: [Float] = []

    private(set) var reverbSpace: ReverbSpace = .hall

    private init() {}

    // MARK: Lifecycle

    /// Safe to call many times. iOS doesn't need a user gesture to start audio,
    /// but we still start lazily and recover from interruptions and route changes.
    func start() {
        if !isSetUp { setUp() }
        guard !engine.isRunning else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            print("Groova audio failed to start: \(error)")
        }
    }

    private func setUp() {
        isSetUp = true
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
        } catch {
            print("Groova audio session error: \(error)")
        }

        let hwRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let sampleRate = hwRate > 0 ? hwRate : (session.sampleRate > 0 ? session.sampleRate : 48_000)
        core.lock.lock()
        core.sampleRate = Float(sampleRate)
        core.lock.unlock()

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return }

        let core = self.core
        let node = AVAudioSourceNode(format: format) { _, _, frameCount, bufferList -> OSStatus in
            let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
            let frames = Int(frameCount)
            guard buffers.count > 0, let left = buffers[0].mData?.assumingMemoryBound(to: Float.self) else {
                return noErr
            }
            let right = buffers.count > 1 ? buffers[1].mData?.assumingMemoryBound(to: Float.self) : nil
            core.render(left, right: right, frames: frames)
            if buffers.count > 2 {
                for b in 2..<buffers.count {
                    if let dst = buffers[b].mData {
                        memcpy(dst, left, frames * MemoryLayout<Float>.size)
                    }
                }
            }
            return noErr
        }
        source = node

        engine.attach(node)
        engine.attach(reverb)
        engine.connect(node, to: reverb, format: format)
        engine.connect(reverb, to: engine.mainMixerNode, format: format)
        reverb.loadFactoryPreset(.largeHall)
        reverb.wetDryMix = 0

        window = (0..<1024).map { i in 0.5 - 0.5 * cosf(2 * .pi * Float(i) / 1023) }
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { [weak self] buffer, _ in
            self?.analyse(buffer)
        }
        engine.prepare()

        let nc = NotificationCenter.default
        observers.append(nc.addObserver(forName: AVAudioSession.interruptionNotification, object: nil,
                                        queue: .main) { [weak self] note in
            guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            if type == .ended { self?.start() }
        })
        observers.append(nc.addObserver(forName: .AVAudioEngineConfigurationChange, object: engine,
                                        queue: .main) { [weak self] _ in
            self?.start()
        })
    }

    // MARK: One-shots

    func trigger(_ track: DrumTrack, kit: DrumKit, velocity: Float = 1) {
        start()
        withCore { $0.enqueue(.drum(track, velocity, kit)) }
    }

    func playNote(_ midi: Int, seconds: Double = 0.35, patch: SynthPatch, velocity: Float = 1, delay: Double = 0) {
        start()
        withCore { $0.enqueue(.note(midi: midi, seconds: seconds, patch: patch, velocity: velocity, delay: delay)) }
    }

    func playChord(_ midis: [Int], seconds: Double = 0.5, patch: SynthPatch, delay: Double = 0) {
        start()
        withCore { core in
            for m in midis {
                core.enqueue(.note(midi: m, seconds: seconds, patch: patch, velocity: 1, delay: delay))
            }
        }
    }

    /// A short rising arpeggio for wins.
    func playSuccess() {
        let notes = [69, 73, 76, 81]
        for (i, n) in notes.enumerated() {
            playNote(n, seconds: 0.18, patch: .keys, velocity: 0.9, delay: Double(i) * 0.075)
        }
        playChord([69, 73, 76], seconds: 0.6, patch: .stab, delay: 0.32)
    }

    /// A soft, non-judgmental "not quite" sound.
    func playNudge() {
        playNote(64, seconds: 0.12, patch: .keys, velocity: 0.6)
        playNote(62, seconds: 0.2, patch: .keys, velocity: 0.6, delay: 0.1)
    }

    // MARK: Sequencer

    func play(_ pattern: Pattern, kit: DrumKit, bpm: Double, swing: Double = 0, bars: Int? = nil,
              mutedDrums: Set<DrumTrack> = [], bassMuted: Bool = false, chordsMuted: Bool = false,
              overlay: Pattern? = nil, sequence: [Pattern] = [], barsPerSection: Int = 2) {
        start()
        withCore { c in
            c.pattern = pattern
            c.overlay = overlay
            c.sequence = sequence
            c.barsPerSection = barsPerSection
            c.kit = kit
            c.bpm = bpm
            c.swing = swing
            c.mutedDrums = mutedDrums
            c.bassMuted = bassMuted
            c.chordsMuted = chordsMuted
            c.startSequencer(bars: bars)
        }
    }

    func update(pattern: Pattern) { withCore { $0.pattern = pattern } }

    func update(swing: Double) { withCore { $0.swing = swing } }

    /// Swap the kit while playing (Sound Lab). New hits use the new sound.
    func update(kit: DrumKit) { withCore { $0.kit = kit } }

    func update(sequence: [Pattern]) { withCore { $0.sequence = sequence } }

    /// Mixer levels: 1 = as designed. Sidechain 0...1.
    func setMix(drums: [DrumTrack: Double] = [:], bass: Double = 1, chords: Double = 1, sidechain: Double = 0) {
        withCore { c in
            for t in DrumTrack.allCases { c.drumLevels[t.rawValue] = Float(drums[t] ?? 1) }
            c.bassLevel = Float(bass)
            c.chordLevel = Float(chords)
            c.sidechain = Float(max(0, min(1, sidechain)))
        }
    }

    func update(mutedDrums: Set<DrumTrack>, bassMuted: Bool, chordsMuted: Bool = false) {
        withCore { c in
            c.mutedDrums = mutedDrums
            c.bassMuted = bassMuted
            c.chordsMuted = chordsMuted
        }
    }

    func stop() { withCore { $0.stopSequencer() } }

    /// (current step or -1, is the sequencer running, how many limited runs have finished)
    var transportState: (step: Int, playing: Bool, finished: Int, section: Int) {
        core.lock.lock()
        defer { core.lock.unlock() }
        return (core.currentStep, core.seqPlaying, core.finishedCount, core.currentSection)
    }

    // MARK: Effects

    /// Master low-pass filter. `cutoff` in Hz, `resonance` 0...1.
    func setFilter(cutoff: Double, resonance: Double) {
        withCore { c in
            c.cutoffTarget = Float(cutoff)
            c.resonance = Float(resonance)
        }
    }

    func setReverb(mix: Double, space: ReverbSpace) {
        if space != reverbSpace {
            reverbSpace = space
            switch space {
            case .room: reverb.loadFactoryPreset(.mediumRoom)
            case .plate: reverb.loadFactoryPreset(.plate)
            case .hall: reverb.loadFactoryPreset(.largeHall)
            case .cathedral: reverb.loadFactoryPreset(.cathedral)
            }
        }
        reverb.wetDryMix = Float(max(0, min(100, mix * 100)))
    }

    func resetEffects() {
        setFilter(cutoff: 20_000, resonance: 0)
        reverb.wetDryMix = 0
        setMix()
    }

    // MARK: Spectrum

    func setAnalysis(_ on: Bool) {
        analysisLock.lock()
        analysisEnabled = on
        if !on { for i in spectrum.indices { spectrum[i] = 0 } }
        analysisLock.unlock()
    }

    /// Latest band levels, 0...1, low to high frequency.
    var spectrumLevels: [Float] {
        analysisLock.lock()
        defer { analysisLock.unlock() }
        return spectrum
    }

    private func analyse(_ buffer: AVAudioPCMBuffer) {
        analysisLock.lock()
        let on = analysisEnabled
        analysisLock.unlock()
        guard on, let data = buffer.floatChannelData?[0] else { return }
        let n = min(Int(buffer.frameLength), window.count)
        guard n > 64 else { return }
        let levels = Spectrum.analyse(data, count: n, window: window, sampleRate: Float(buffer.format.sampleRate))
        analysisLock.lock()
        for i in 0..<min(levels.count, spectrum.count) {
            // fast attack, smooth release
            spectrum[i] = max(levels[i], spectrum[i] * 0.82)
        }
        analysisLock.unlock()
    }

    private func withCore(_ body: (DSPCore) -> Void) {
        core.lock.lock()
        body(core)
        core.lock.unlock()
    }
}

/// Goertzel-based band analyser: cheap, dependency-free, plenty for a visualiser.
nonisolated enum Spectrum {
    static let bandCount = 28
    static let minHz: Float = 40
    static let maxHz: Float = 16_000

    static func bandFrequency(_ i: Int) -> Float {
        minHz * powf(maxHz / minHz, Float(i) / Float(bandCount - 1))
    }

    static func analyse(_ x: UnsafePointer<Float>, count n: Int, window: [Float], sampleRate: Float) -> [Float] {
        var out = [Float](repeating: 0, count: bandCount)
        for b in 0..<bandCount {
            let f = bandFrequency(b)
            let w = 2 * cosf(2 * .pi * f / sampleRate)
            var s1: Float = 0, s2: Float = 0
            for i in 0..<n {
                let s0 = x[i] * window[i] + w * s1 - s2
                s2 = s1
                s1 = s0
            }
            let power = max(0, s1 * s1 + s2 * s2 - w * s1 * s2)
            let mag = sqrtf(power) / (Float(n) * 0.25)
            let db = 20 * log10f(mag + 1e-7)
            out[b] = max(0, min(1, (db + 62) / 58))
        }
        return out
    }
}
