//
//  GameKit.swift
//  Groova
//
//  Shared pieces for the Game phase: the dark stage, the round header, round progress and
//  scoring, a beat clock that follows the transport, and a timing strip for results.
//

import Foundation
import QuartzCore
import SwiftUI

/// Opens the right game for a game step.
struct GameStepView: View {
    let task: GameTask
    let genre: Genre
    let onComplete: (Double) -> Void

    var body: some View {
        switch task.kind {
        case .blackout(let rounds): BlackoutGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .drumDuel(let rounds): DrumDuelGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .controlRoom(let score, let rounds):
            ControlRoomGame(task: task, score: score, rounds: rounds, genre: genre, onComplete: onComplete)
        case .reactor(let layers, let rounds):
            LoopReactorGame(task: task, layers: layers, rounds: rounds, genre: genre, onComplete: onComplete)
        case .downbeat(let rounds): DownbeatGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .slicer(let rounds): TimeSlicerGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .forensics(let rounds): ForensicsGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .gravity(let rounds): GravityGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .grooveDNA(let rounds): GrooveDNAGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .glider(let rounds): PitchGliderGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .radar(let rounds): IntervalRadarGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .notes(let surface, let rounds):
            NoteSurfaceGame(task: task, surface: surface, rounds: rounds, genre: genre, onComplete: onComplete)
        case .chordLock(let rounds): ChordLockGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .impostor(let rounds): ChordImpostorGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .resolution(let rounds): ResolutionRunGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .tether(let rounds): TetherGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .xray(let rounds): SoundXRayGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .surgery(let rounds): SynthSurgeryGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .architect(let rounds): AcousticArchitectGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .traffic(let rounds): MixTrafficGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .casting(let rounds): SoundCastingGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .detective(let rounds): StructureDetectiveGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .surfer(let rounds): EnergySurferGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .cut(let rounds): PerfectCutGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .jigsaw(let cards, let rounds):
            SongJigsawGame(task: task, cards: cards, rounds: rounds, genre: genre, onComplete: onComplete)
        case .live(let rounds): LiveTakeGame(task: task, rounds: rounds, genre: genre, onComplete: onComplete)
        case .echo(let config): EchoGame(task: task, config: config, genre: genre, onComplete: onComplete)
        case .playAlong(let config): PlayAlongGame(task: task, config: config, genre: genre, onComplete: onComplete)
        }
    }
}

enum GameStyle {
    // Games are light now: white stage, gray lines, dark ink, purple for anything lit.
    // The old "night" names are kept so every game picks up the light look.
    static let night = Theme.background
    static let nightRaised = Theme.surfaceRaised
    static let nightLine = Theme.surfaceHigh
    static let nightText = Theme.text
    static let nightDim = Theme.textSecondary
    /// Lines, playheads and markers drawn on the stage.
    static let ink = Theme.text

    // Part colours, shared by every game so kick, bass, chords and lead look the same everywhere.
    // All purple. Drums share the brand purple; other parts are shades so they stay tellable apart.
    static let kick = Theme.brand
    static let snare = Theme.brand
    static let hat = Theme.brand
    static let bass = Color(hex: 0x4A2EC0)
    static let chords = Color(hex: 0xA48BFF)
    static let lead = Color(hex: 0x6A45E8)
    static let extraA = Color(hex: 0x8F72FF)
    static let extraB = Color(hex: 0x5B3FD8)

    static func color(_ t: DrumTrack) -> Color {
        switch t {
        case .kick: kick
        case .clap: snare
        case .hat, .openHat: hat
        case .perc: lead
        }
    }
}

/// Rounds, scores and the feedback panel for one game.
@Observable
final class GameProgress {
    let total: Int
    var index = 0
    var scores: [Double] = []
    var fails = 0
    var feedback: StepFeedback?

    init(total: Int) { self.total = max(1, total) }

    var average: Double { scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count) }

    func pass(_ score: Double, _ message: String, title: String? = nil) {
        scores.append(max(0, min(1, score)))
        AudioEngine.shared.playSuccess()
        Haptics.success()
        withAnimation {
            feedback = StepFeedback(kind: .success, title: title ?? Cheer.win(), message: message,
                                    score: score < 0.999 ? score : nil)
        }
    }

    func miss(_ message: String, score: Double? = nil, title: String? = nil) {
        fails += 1
        AudioEngine.shared.playNudge()
        Haptics.warning()
        withAnimation {
            feedback = StepFeedback(kind: .retry, title: title ?? Cheer.near(score ?? 0), message: message, score: score)
        }
    }

    /// After two misses you can move on with a low score instead of getting stuck.
    var canSkip: Bool { fails >= 2 }

    func skip() {
        scores.append(0.35)
    }

    /// Moves to the next round. True when every round is done.
    func advance() -> Bool {
        withAnimation { feedback = nil }
        fails = 0
        if index + 1 >= total { return true }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { index += 1 }
        return false
    }
}

/// Follows the transport so a game knows exactly where the beat is, in steps since the start.
@Observable
final class BeatClock {
    private(set) var startTime: Double?
    private(set) var bars = 0
    private var lastStep = -1
    var stepSeconds: Double = 0.15

    func reset(bpm: Double) {
        startTime = nil
        bars = 0
        lastStep = -1
        stepSeconds = 60 / bpm / 4
    }

    /// Call from onChange of the transport step.
    func follow(_ step: Int) {
        guard step >= 0 else { return }
        if startTime == nil {
            startTime = CACurrentMediaTime() - Double(step) * stepSeconds
        } else if lastStep >= 0, step < lastStep {
            bars += 1
        }
        lastStep = step
    }

    /// Steps since bar 0, step 0. Smooth, so it can drive animation.
    func now(_ t: Double = CACurrentMediaTime()) -> Double? {
        startTime.map { (t - $0) / stepSeconds }
    }

    /// The bar and step the transport is on.
    var bar: Int { bars }
    var step: Int { lastStep }
}

/// The header above a game: its name, the round, and what to do.
struct GameHeader: View {
    let task: GameTask
    let round: Int
    let total: Int
    let title: String
    let detail: String
    @Environment(\.accent) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text("Round \(round + 1): \(title)")
                    .font(.display(25))
                    .foregroundStyle(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                HStack(spacing: 5) {
                    ForEach(0..<total, id: \.self) { i in
                        Capsule()
                            .fill(i <= round ? accent : Theme.surfaceHigh)
                            .frame(width: i == round ? 20 : 8, height: 8)
                    }
                }
                .padding(.top, 12)
            }
            if !detail.isEmpty {
                Text(detail)
                    .font(.label(15, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(response: 0.4), value: round)
    }
}

/// The stage a game is played on: no card, straight on the white page.
struct GameStage<Content: View>: View {
    var height: CGFloat = 330
    /// White stage with a light border, instead of the dark night stage.
    var light = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        // No card: the game sits straight on the white page.
        content()
            .frame(maxWidth: .infinity)
            .frame(height: height)
    }
}

/// A label on the stage, e.g. "LISTEN" or "YOUR TURN".
struct StageTag: View {
    let text: String
    var color: Color = GameStyle.nightDim
    var light = false

    var body: some View {
        // Plain text, no chip.
        Text(text.uppercased())
            .font(.label(12, weight: .black)).tracking(1)
            .foregroundStyle(color)
            .frame(height: 26)
            .contentTransition(.opacity)
    }
}

/// Where the hits belonged and where you tapped, on one strip. Positions are in steps.
struct TimingStrip: View {
    let targets: [Double]
    let hits: Set<Int>
    let taps: [Double]
    let length: Double
    var caption = "Dots are where the beats belong. Lines are your taps."

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR TIMING").font(.label(12, weight: .black)).foregroundStyle(Theme.textTertiary)
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surfaceRaised).frame(height: 10)
                    ForEach(Array(targets.enumerated()), id: \.offset) { i, t in
                        Circle()
                            .fill(hits.contains(i) ? Theme.success : Theme.miss.opacity(0.35))
                            .frame(width: 14, height: 14)
                            .offset(x: w * t / max(1, length) - 7)
                    }
                    ForEach(Array(taps.enumerated()), id: \.offset) { _, t in
                        Capsule()
                            .fill(Theme.text)
                            .frame(width: 3, height: 26)
                            .offset(x: w * min(1, max(0, t / max(1, length))) - 1.5)
                    }
                }
                .frame(height: 26)
            }
            .frame(height: 26)
            Text(caption)
                .font(.label(13, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
        .card(padding: 14)
    }
}

/// Matches taps to targets: each target takes the closest unused tap inside the window.
/// Returns the matched targets and each match's signed offset (positive is late).
nonisolated func matchTaps(_ taps: [Double], to targets: [Double], window: Double) -> (hits: Set<Int>, offsets: [Double]) {
    var used = Set<Int>()
    var hits = Set<Int>()
    var offsets: [Double] = []
    for (i, t) in targets.enumerated() {
        var best: (j: Int, d: Double)?
        for (j, x) in taps.enumerated() where !used.contains(j) {
            let d = x - t
            if abs(d) <= window, abs(d) < abs(best?.d ?? .infinity) { best = (j, d) }
        }
        if let best {
            used.insert(best.j)
            hits.insert(i)
            offsets.append(best.d)
        }
    }
    return (hits, offsets)
}

/// "A touch early", "right on it" or "a touch late", from offsets in beats.
nonisolated func timingAdvice(_ offsets: [Double]) -> String {
    guard !offsets.isEmpty else { return "" }
    let mean = offsets.reduce(0, +) / Double(offsets.count)
    if mean < -0.06 { return " You were rushing a little. Let the beat come to you." }
    if mean > 0.06 { return " You were a touch behind. Lean in a bit earlier." }
    return " Your timing sat right on the beat."
}
