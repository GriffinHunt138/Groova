//
//  MasteryChallengeView.swift
//  Groova
//
//  End-of-unit listen-and-recreate assessment: drums + bass, solo/mute, per-instrument scoring.
//

import Foundation
import SwiftUI

struct MasteryResult: Equatable {
    var parts: [(Instrument, Double)]
    var overall: Double
    var passed: Bool { overall >= 0.8 }

    static func == (a: MasteryResult, b: MasteryResult) -> Bool { a.overall == b.overall }

    var weakest: Instrument? { parts.min(by: { $0.1 < $1.1 })?.0 }
}

struct MasteryChallengeView: View {
    let task: MasteryTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var pattern = Pattern()
    @State private var muted = Set<DrumTrack>()
    @State private var bassMuted = false
    @State private var solo: Instrument?
    @State private var result: MasteryResult?
    @State private var showResult = false
    @State private var attempts = 0
    @State private var marks: [DrumTrack: [Int: CellMark]] = [:]
    @State private var wrongNotes = Set<UUID>()
    @State private var correctNotes = Set<UUID>()
    @State private var bassGhosts: [NoteEvent] = []

    private var transport: Transport { Transport.shared }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        header
                        transportBar
                        if transport.isPlaying(.compare) { CompareCaption() }
                        VStack(spacing: 16) {
                            SectionTitle(text: "Drums")
                            StepSequencerGrid(pattern: $pattern, tracks: task.tracks, editable: Set(task.tracks),
                                              playhead: (transport.isPlaying(.user) || transport.isPlaying(.compare)) ? transport.step : -1,
                                              marks: marks, kit: Transport.shared.kit(for: genre),
                                              muted: $muted, soloed: $solo)
                        }
                        .card()
                        VStack(spacing: 14) {
                            HStack {
                                SectionTitle(text: "Bass")
                                SmallToggle(title: "S", on: solo == .bass, color: Theme.brand) {
                                    solo = solo == .bass ? nil : .bass
                                }
                                SmallToggle(title: "M", on: bassMuted, color: Theme.text) { bassMuted.toggle() }
                            }
                            PianoRollGrid(notes: $pattern.bass, rows: task.bassRows,
                                          playhead: (transport.isPlaying(.user) || transport.isPlaying(.compare)) ? transport.step : -1,
                                          patch: Transport.shared.kit(for: genre).bass, correct: correctNotes, wrong: wrongNotes,
                                          ghosts: bassGhosts)
                                .opacity(bassSilenced ? 0.4 : 1)
                        }
                        .card()
                        if attempts > 0, let w = result?.weakest, !(result?.passed ?? false) {
                            Label(hint(for: w), systemImage: "lightbulb.fill")
                                .font(.label(14, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .card(padding: 14)
                        }
                    }
                    .padding(20)
                }
                VStack {
                    Button("Submit for scoring") { submit() }
                        .buttonStyle(ChunkyButtonStyle(color: genre.color, enabled: hasContent))
                        .disabled(!hasContent)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
            }

            if showResult, let result {
                Color.black.opacity(0.35).ignoresSafeArea()
                    .transition(.opacity)
                MasteryResultCard(result: result, genre: genre, attempts: attempts,
                                  onRetry: {
                                      withAnimation(.spring(response: 0.4)) { showResult = false }
                                  },
                                  onHearPart: { part in playReference(only: part) },
                                  onClaim: {
                                      transport.stop()
                                      onComplete(result.overall)
                                  })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            if showResult, result?.passed == true {
                ConfettiView(colors: [Theme.brand, Theme.gold, Theme.success, Theme.streak])
                    .ignoresSafeArea()
            }
        }
        .onChange(of: pattern) { _, p in
            transport.liveUpdate(p)
            if !marks.isEmpty || !wrongNotes.isEmpty || !bassGhosts.isEmpty {
                marks = [:]; wrongNotes = []; correctNotes = []; bassGhosts = []
            }
        }
        .onChange(of: muted) { _, _ in pushMix() }
        .onChange(of: bassMuted) { _, _ in pushMix() }
        .onChange(of: solo) { _, _ in pushMix() }
        .onDisappear { transport.stop() }
    }

    // MARK: Pieces

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill").foregroundStyle(Theme.gold)
                Text("MASTERY CHALLENGE").font(.label(12, weight: .heavy)).tracking(1.4).foregroundStyle(Theme.gold)
            }
            Text(task.prompt).font(.display(26)).foregroundStyle(Theme.text)
            Text("Listen to the \(task.bars)-bar reference, then rebuild the kick, clap, hats and bass by ear. Score 80% to unlock the next unit.")
                .font(.label(15, weight: .medium)).foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var transportBar: some View {
        HStack(spacing: 10) {
            TransportButton(title: "Reference", symbol: transport.isPlaying(.reference) ? "stop.fill" : "ear.fill",
                            active: transport.isPlaying(.reference), color: Theme.text) {
                transport.toggle(task.reference, genre: genre, source: .reference, bars: task.bars)
            }
            TransportButton(title: "Yours", symbol: transport.isPlaying(.user) ? "stop.fill" : "play.fill",
                            active: transport.isPlaying(.user), color: genre.color) {
                if transport.isPlaying(.user) { transport.stop() } else {
                    let m = mix
                    transport.play(pattern, genre: genre, source: .user, mutedDrums: m.drums, bassMuted: m.bass)
                }
            }
            TransportButton(title: "Both", symbol: transport.isPlaying(.compare) ? "stop.fill" : "headphones",
                            active: transport.isPlaying(.compare), color: Theme.text) {
                if transport.isPlaying(.compare) { transport.stop() } else {
                    let m = mix
                    transport.play(pattern, genre: genre, source: .compare, mutedDrums: m.drums, bassMuted: m.bass,
                                   overlay: task.reference)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var hasContent: Bool {
        task.tracks.contains { pattern.hits($0) > 0 } || !pattern.bass.isEmpty
    }

    private var bassSilenced: Bool { solo != nil ? solo != .bass : bassMuted }

    private var mix: (drums: Set<DrumTrack>, bass: Bool) {
        if let solo {
            let drums = Set(DrumTrack.allCases.filter { solo != .drum($0) })
            return (drums, solo != .bass)
        }
        return (muted, bassMuted)
    }

    private func pushMix() {
        let m = mix
        if transport.isPlaying(.user) || transport.isPlaying(.compare) {
            AudioEngine.shared.update(mutedDrums: m.drums, bassMuted: m.bass)
        }
    }

    private func playReference(only part: Instrument) {
        let drums = Set(DrumTrack.allCases.filter { part != .drum($0) })
        transport.play(task.reference, genre: genre, source: .reference, bars: 2, mutedDrums: drums,
                       bassMuted: part != .bass)
    }

    private func hint(for part: Instrument) -> String {
        switch part {
        case .drum(.kick): "Solo the kick in the reference and count the hits against the step numbers."
        case .drum(.clap): "Claps usually answer the kick on 2 and 4. Listen for anything extra."
        case .drum(.hat), .drum(.openHat): "Solo the hats and listen for gaps and doubles."
        case .drum(.perc): "Rims hide between the other hits. Solo them in the reference."
        case .bass: "Bass notes dodge the kick. Listen for when the line moves, and for any long notes."
        default: "Solo that part in the reference and compare."
        }
    }

    // MARK: Scoring

    private func submit() {
        transport.stop()
        attempts += 1
        var parts: [(Instrument, Double)] = []
        var newMarks: [DrumTrack: [Int: CellMark]] = [:]
        for t in task.tracks {
            let r = Scoring.rhythm(user: pattern[t], reference: task.reference[t])
            parts.append((.drum(t), r.accuracy))
            newMarks[t] = r.marks
        }
        let m = Scoring.melody(user: pattern.bass, reference: task.reference.bass)
        parts.append((.bass, m.accuracy))
        let overall = parts.map(\.1).reduce(0, +) / Double(parts.count)
        let r = MasteryResult(parts: parts, overall: overall)
        result = r
        marks = newMarks
        wrongNotes = m.wrongNotes
        correctNotes = m.correctNotes
        bassGhosts = task.reference.bass.filter { t in !pattern.bass.contains(where: { $0 == t }) }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { showResult = true }
        if r.passed {
            AudioEngine.shared.playSuccess()
            Haptics.success()
        } else {
            AudioEngine.shared.playNudge()
            Haptics.warning()
        }
    }
}

struct MasteryResultCard: View {
    let result: MasteryResult
    let genre: Genre
    let attempts: Int
    let onRetry: () -> Void
    let onHearPart: (Instrument) -> Void
    let onClaim: () -> Void

    @State private var revealed = false

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                ZStack {
                    Ring(value: revealed ? result.overall : 0, color: result.passed ? Theme.success : Theme.streak,
                         lineWidth: 12)
                    VStack(spacing: 0) {
                        Text("\(Int((result.overall * 100).rounded()))%")
                            .font(.display(40))
                            .foregroundStyle(Theme.text)
                            .contentTransition(.numericText(value: result.overall))
                        Text("overall").font(.label(13)).foregroundStyle(Theme.textSecondary)
                    }
                }
                .frame(width: 150, height: 150)

                Text(result.passed ? "Mastered!" : "Not quite — \(80 - Int((result.overall * 100).rounded()))% to go")
                    .font(.display(24))
                    .foregroundStyle(result.passed ? Theme.success : Theme.text)

                VStack(spacing: 12) {
                    ForEach(Array(result.parts.enumerated()), id: \.offset) { i, part in
                        HStack(spacing: 12) {
                            Text(part.0.name)
                                .font(.label(15, weight: .bold))
                                .foregroundStyle(Theme.text)
                                .frame(width: 70, alignment: .leading)
                            ProgressBar(value: revealed ? part.1 : 0, color: color(for: part.0), height: 10)
                                .animation(.spring(response: 0.7).delay(Double(i) * 0.12), value: revealed)
                            Text("\(Int((part.1 * 100).rounded()))%")
                                .font(.mono(14, weight: .bold))
                                .foregroundStyle(part.1 >= 0.8 ? Theme.text : Theme.streak)
                                .frame(width: 46, alignment: .trailing)
                            if !result.passed {
                                Button { Haptics.tap(); onHearPart(part.0) } label: {
                                    Image(systemName: "ear.fill").font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Theme.gold)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Theme.surfaceRaised))
                                }
                                .buttonStyle(PressScaleStyle())
                                .accessibilityLabel("Hear only the \(part.0.name) in the reference")
                            }
                        }
                    }
                }

                if result.passed {
                    Button("Claim reward", action: onClaim)
                        .buttonStyle(ChunkyButtonStyle(color: Theme.success))
                } else {
                    Text("Tap \(Image(systemName: "ear.fill")) to hear just that part of the reference. Your mistakes are marked on the grid — no penalty for retrying.")
                        .font(.label(13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                    Button("Back to the groove", action: onRetry)
                        .buttonStyle(ChunkyButtonStyle(color: genre.color))
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Theme.surface)
                    .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).strokeBorder(Theme.stroke))
            )
            .padding(12)
        }
        .onAppear {
            revealed = false
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.15)) { revealed = true }
        }
    }

    private func color(for i: Instrument) -> Color {
        switch i {
        case .drum(let t): Theme.color(for: t)
        case .bass: Theme.bassColor
        case .chords: Theme.gold
        }
    }
}
