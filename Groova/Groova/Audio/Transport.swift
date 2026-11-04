//
//  Transport.swift
//  Groova
//
//  Main-actor face of the audio engine: what is playing, and where the playhead is.
//

import Foundation
import Observation
import UIKit

enum PlaySource: Hashable {
    case reference
    case user
    case demo
    /// Reference (left ear) and the user's pattern (right ear) together.
    case compare
}

@Observable
final class Transport {
    static let shared = Transport()

    private(set) var step: Int = -1
    private(set) var isRunning = false
    private(set) var source: PlaySource?
    /// Section index during arrangement playback, else -1.
    private(set) var section: Int = -1

    private var timer: Timer?
    private var lastFinished = 0
    private let engine = AudioEngine.shared

    private init() {}

    /// Which sound flavor lesson playback uses. 0 = the genre's own kit (Studio, Sound Lab).
    var flavor = 0

    /// The kit lesson audio plays with right now.
    func kit(for genre: Genre) -> DrumKit { SoundFlavor.kit(genre.kit, flavor) }

    func isPlaying(_ s: PlaySource) -> Bool { isRunning && source == s }

    func play(_ pattern: Pattern, genre: Genre, source: PlaySource, bars: Int? = nil,
              mutedDrums: Set<DrumTrack> = [], bassMuted: Bool = false, chordsMuted: Bool = false,
              swing: Double? = nil, bpm: Double? = nil, overlay: Pattern? = nil, kit: DrumKit? = nil,
              sequence: [Pattern] = [], barsPerSection: Int = 2) {
        engine.play(pattern, kit: kit ?? self.kit(for: genre), bpm: bpm ?? genre.bpm, swing: swing ?? genre.swing, bars: bars,
                    mutedDrums: mutedDrums, bassMuted: bassMuted, chordsMuted: chordsMuted, overlay: overlay,
                    sequence: sequence, barsPerSection: barsPerSection)
        self.source = source
        isRunning = true
        lastFinished = engine.transportState.finished
        startPolling()
    }

    func toggle(_ pattern: Pattern, genre: Genre, source: PlaySource, bars: Int? = nil,
                mutedDrums: Set<DrumTrack> = [], bassMuted: Bool = false, swing: Double? = nil) {
        if isPlaying(source) {
            stop()
        } else {
            play(pattern, genre: genre, source: source, bars: bars, mutedDrums: mutedDrums,
                 bassMuted: bassMuted, swing: swing)
        }
    }

    func stop() {
        engine.stop()
        isRunning = false
        source = nil
        step = -1
        section = -1
    }

    /// Push live edits while the user's own loop is playing.
    func liveUpdate(_ pattern: Pattern) {
        if isPlaying(.user) || isPlaying(.demo) || isPlaying(.compare) { engine.update(pattern: pattern) }
    }

    private func startPolling() {
        guard timer == nil else { return }
        let t = Timer(timeInterval: 1.0 / 60.0, repeats: true) { _ in
            MainActor.assumeIsolated { Transport.shared.poll() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func poll() {
        let s = engine.transportState
        if s.step != step { step = s.step }
        if s.section != section { section = s.section }
        if isRunning && !s.playing {
            isRunning = false
            source = nil
            step = -1
            section = -1
        }
        if !isRunning {
            timer?.invalidate()
            timer = nil
        }
    }
}

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func soft() { UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.7) }
    static func thump() { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }
    static func select() { UISelectionFeedbackGenerator().selectionChanged() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
}
