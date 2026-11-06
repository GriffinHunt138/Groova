//
//  EffectStepViews.swift
//  Groova
//
//  Filter and reverb exercises. These change the real audio, and the spectrum
//  display is measured from the actual output.
//

import Foundation
import SwiftUI

enum FilterMap {
    static let minHz = 60.0
    static let maxHz = 18_000.0
    static func hz(_ v: Double) -> Double { minHz * pow(maxHz / minHz, v) }
    static func value(_ hz: Double) -> Double { log(hz / minHz) / log(maxHz / minHz) }
    static func label(_ hz: Double) -> String {
        hz >= 1000 ? String(format: "%.1f kHz", hz / 1000) : "\(Int(hz)) Hz"
    }
}

// MARK: - Spectrum

struct SpectrumView: View {
    var color: Color
    var cutoff: Double? = nil
    var resonance: Double = 0

    var body: some View {
        TimelineView(.animation) { _ in
            let levels = AudioEngine.shared.spectrumLevels
            Canvas { ctx, size in
                let n = levels.count
                let gap: CGFloat = 3
                let w = (size.width - gap * CGFloat(n - 1)) / CGFloat(n)
                for i in 0..<n {
                    let f = Double(Spectrum.bandFrequency(i))
                    let gain = cutoff.map { Self.response(f: f, cutoff: $0, resonance: resonance) } ?? 1
                    let h = max(4, CGFloat(levels[i]) * size.height)
                    let rect = CGRect(x: CGFloat(i) * (w + gap), y: size.height - h, width: w, height: h)
                    let passing = gain > 0.5
                    ctx.fill(Path(roundedRect: rect, cornerRadius: w / 2),
                             with: .color(passing ? color : Theme.surfaceHigh))
                }
                if let cutoff {
                    var path = Path()
                    let steps = 80
                    for s in 0...steps {
                        let x = CGFloat(s) / CGFloat(steps) * size.width
                        let f = Double(Spectrum.minHz) * pow(Double(Spectrum.maxHz / Spectrum.minHz), Double(s) / Double(steps))
                        let g = Self.response(f: f, cutoff: cutoff, resonance: resonance)
                        let db = 20 * log10(max(g, 1e-4))
                        let y = size.height * (1 - CGFloat((db + 36) / 54)) - 6
                        let point = CGPoint(x: x, y: min(size.height, max(2, y)))
                        if s == 0 { path.move(to: point) } else { path.addLine(to: point) }
                    }
                    ctx.stroke(path, with: .color(Theme.text), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous).fill(Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous).strokeBorder(Theme.stroke, lineWidth: Theme.border)))
        .overlay(alignment: .bottom) {
            HStack {
                Text("LOW").frame(maxWidth: .infinity, alignment: .leading)
                Text("MID")
                Text("HIGH").frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.label(10, weight: .bold)).tracking(1)
            .foregroundStyle(Theme.textTertiary)
            .padding(.horizontal, 16).padding(.bottom, -18)
        }
        .onAppear { AudioEngine.shared.setAnalysis(true) }
        .onDisappear { AudioEngine.shared.setAnalysis(false) }
    }

    /// Magnitude response of the 2-pole state-variable low-pass used in the DSP.
    static func response(f: Double, cutoff: Double, resonance: Double) -> Double {
        let k = 2 * (1 - 0.96 * resonance)
        let r = f / cutoff
        return 1 / sqrt(pow(1 - r * r, 2) + pow(r * k, 2))
    }
}

// MARK: - Filter step

struct FilterStepView: View {
    let task: FilterTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var cutoffValue = 1.0
    @State private var resonance = 0.2
    @State private var listeningToReference = false
    @State private var revealed = false
    @State private var wentLow = false
    @State private var wentHigh = false
    @State private var feedback: StepFeedback?
    @State private var lastScore = 1.0
    @State private var fails = 0

    private var transport: Transport { Transport.shared }
    private var cutoffHz: Double { FilterMap.hz(cutoffValue) }
    private var isMatch: Bool { task.target != nil }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: task.body, badge: isMatch ? "Sound match" : "Explore")

                    // Only ever shows your settings. While the reference plays it's hidden,
                    // so the match is made by ear, not by copying a picture.
                    SpectrumView(color: genre.color, cutoff: cutoffHz, resonance: resonance)
                        .frame(height: 170)
                        .blur(radius: listeningToReference ? 14 : 0)
                        .overlay {
                            if listeningToReference {
                                Label("Listen closely", systemImage: "ear.fill")
                                    .font(.label(14, weight: .heavy))
                                    .foregroundStyle(Theme.brand)
                                    .padding(.horizontal, 14).frame(height: 36)
                                    .background(Capsule().fill(Theme.brandSoft))
                            }
                        }
                        .animation(.easeOut(duration: 0.2), value: listeningToReference)
                        .padding(.bottom, 10)

                    if isMatch {
                        Picker("Listen to", selection: $listeningToReference) {
                            Text("Reference").tag(true)
                            Text("Yours").tag(false)
                        }
                        .pickerStyle(.segmented)
                    }

                    HStack(spacing: 24) {
                        Knob(value: $cutoffValue, label: "Cutoff", valueText: FilterMap.label(cutoffHz),
                             color: genre.color, onChange: userTurned,
                             target: revealed ? task.target.map { FilterMap.value($0.cutoff) } : nil,
                             targetText: revealed ? task.target.map { FilterMap.label($0.cutoff) } : nil)
                        Knob(value: $resonance, label: "Resonance", valueText: "\(Int(resonance * 100))%",
                             color: genre.color, onChange: userTurned,
                             target: revealed ? task.target?.resonance : nil,
                             targetText: revealed ? task.target.map { "\(Int($0.resonance * 100))%" } : nil)
                    }
                    .opacity(listeningToReference ? 0.45 : 1)

                    if !isMatch {
                        VStack(alignment: .leading, spacing: 10) {
                            goal("Close it right down", done: wentLow)
                            goal("Open it all the way up", done: wentHigh)
                        }
                        .card()
                    } else {
                        Text("Scored on knob positions compared with the reference settings.")
                            .font(.label(12)).foregroundStyle(Theme.textTertiary)
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: feedback,
                       primaryTitle: isMatch ? "Check" : "Continue",
                       primaryEnabled: isMatch || (wentLow && wentHigh),
                       onPrimary: check,
                       onContinue: finish,
                       onRetry: { withAnimation { feedback = nil } })
        }
        .task {
            // Let the previous step finish tearing down its audio before we start ours.
            if isMatch { cutoffValue = 1; resonance = 0.1 }
            try? await Task.sleep(for: .milliseconds(450))
            transport.play(task.backing, genre: genre, source: .demo)
            apply()
        }
        .onChange(of: listeningToReference) { _, _ in apply(); Haptics.select() }
        .onDisappear {
            transport.stop()
            AudioEngine.shared.resetEffects()
        }
    }

    private func goal(_ text: String, done: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? Theme.success : Theme.textTertiary)
                .font(.system(size: 20, weight: .bold))
                .contentTransition(.symbolEffect(.replace))
            Text(text).font(.label(15, weight: .semibold))
                .foregroundStyle(done ? Theme.text : Theme.textSecondary)
            Spacer()
        }
    }

    private func userTurned() {
        if listeningToReference { listeningToReference = false }
        if feedback != nil { feedback = nil }
        apply()
        if cutoffHz < 350, !wentLow { withAnimation { wentLow = true }; Haptics.success() }
        if wentLow, cutoffHz > 9_000, !wentHigh { withAnimation { wentHigh = true }; Haptics.success() }
    }

    private func apply() {
        if listeningToReference, let t = task.target {
            AudioEngine.shared.setFilter(cutoff: t.cutoff, resonance: t.resonance)
        } else {
            AudioEngine.shared.setFilter(cutoff: cutoffHz, resonance: resonance)
        }
        if !transport.isRunning { transport.play(task.backing, genre: genre, source: .demo) }
    }

    private func check() {
        guard let t = task.target else {
            lastScore = 1
            withAnimation {
                feedback = StepFeedback(kind: .success, title: "Filter unlocked",
                                        message: "Closed = warm and muffled. Open = bright and present. Producers move it over time to build tension before a big moment.",
                                        score: nil)
            }
            AudioEngine.shared.playSuccess(); Haptics.success()
            return
        }
        listeningToReference = false
        let score = Scoring.filterMatch(cutoff: cutoffHz, resonance: resonance,
                                        targetCutoff: t.cutoff, targetResonance: t.resonance)
        lastScore = score
        if score >= 0.8 {
            withAnimation {
                revealed = true
                feedback = StepFeedback(kind: .success, title: Cheer.win(),
                                        message: "Reference was \(FilterMap.label(t.cutoff)) with \(Int(t.resonance * 100))% resonance. Your ears are tuning in.",
                                        score: score)
            }
            AudioEngine.shared.playSuccess(); Haptics.success()
        } else {
            fails += 1
            let hint: String
            let octaves = log2(cutoffHz / t.cutoff)
            if octaves > 0.7 { hint = "Yours is brighter. Turn the cutoff down." }
            else if octaves < -0.7 { hint = "Yours is darker. Open the cutoff a little." }
            else if resonance < t.resonance - 0.2 { hint = "Brightness is close! The reference has more of a whistle — add resonance." }
            else if resonance > t.resonance + 0.2 { hint = "Brightness is close! Yours rings more — ease off the resonance." }
            else { hint = "Very close. Flip between Reference and Yours." }
            withAnimation { feedback = StepFeedback(kind: .retry, title: Cheer.near(score), message: hint, score: score) }
            AudioEngine.shared.playNudge(); Haptics.warning()
        }
    }

    private func finish() {
        transport.stop()
        AudioEngine.shared.resetEffects()
        onComplete(lastScore)
    }
}

// MARK: - Reverb step

struct ReverbStepView: View {
    let task: ReverbTask
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var mix = 0.0
    @State private var space: ReverbSpace = .room
    @State private var spacesTried: Set<ReverbSpace> = [.room]
    @State private var feedback: StepFeedback?

    private var transport: Transport { Transport.shared }
    private var explored: Bool { mix > 0.2 && spacesTried.count >= 2 }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    StepPrompt(title: task.prompt, detail: task.body, badge: "Explore")

                    ReverbTailView(mix: mix, seconds: space.seconds, color: genre.color, step: transport.step)
                        .frame(height: 150)

                    HStack(spacing: 8) {
                        ForEach(ReverbSpace.allCases, id: \.self) { s in
                            Button {
                                Haptics.select()
                                withAnimation(.spring(response: 0.35)) { space = s }
                                spacesTried.insert(s)
                                apply()
                            } label: {
                                Text(s.name)
                                    .font(.label(15, weight: .heavy))
                                    .foregroundStyle(space == s ? Theme.onBrand : Theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                            .buttonStyle(LipStyle(fill: space == s ? genre.color : Theme.surface,
                                                  lip: space == s ? genre.deepColor : Theme.stroke,
                                                  border: space == s ? .clear : Theme.stroke))
                        }
                    }

                    Knob(value: $mix, label: "Wet / Dry", valueText: "\(Int(mix * 100))% wet", color: genre.color,
                         onChange: { apply(); if feedback != nil { feedback = nil } })

                    Text(mixDescription)
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .contentTransition(.opacity)
                        .animation(.easeInOut, value: mixDescription)
                }
                .padding(20)
            }
            StepFooter(feedback: feedback, primaryTitle: explored ? "I like this" : "Try two spaces & add some mix",
                       primaryEnabled: explored,
                       onPrimary: {
                           withAnimation {
                               feedback = StepFeedback(kind: .success, title: "Space created",
                                                       message: "\(mixDescription) There's no right answer — producers pick reverb to taste.",
                                                       score: nil)
                           }
                           AudioEngine.shared.playSuccess(); Haptics.success()
                       },
                       onContinue: {
                           transport.stop()
                           AudioEngine.shared.resetEffects()
                           onComplete(1)
                       },
                       onRetry: {})
        }
        .task {
            try? await Task.sleep(for: .milliseconds(450))
            transport.play(task.backing, genre: genre, source: .demo)
            apply()
        }
        .onDisappear {
            transport.stop()
            AudioEngine.shared.resetEffects()
        }
    }

    private var mixDescription: String {
        switch mix {
        case ..<0.12: "Dry: tight and up-front."
        case ..<0.35: "A touch of room. Still punchy."
        case ..<0.6: "Spacious. The snare blooms."
        default: "Huge and dreamy — perfect for a breakdown."
        }
    }

    private func apply() {
        AudioEngine.shared.setReverb(mix: mix, space: space)
        if !transport.isRunning { transport.play(task.backing, genre: genre, source: .demo) }
    }
}

/// Visualises a hit followed by its reverb tail; length follows the space, height follows the mix.
struct ReverbTailView: View {
    var mix: Double
    var seconds: Double
    var color: Color
    var step: Int

    var body: some View {
        Canvas { ctx, size in
            let bars = 48
            let w = size.width / CGFloat(bars)
            let tailFraction = min(1, seconds / 4.2)
            for i in 0..<bars {
                let x = Double(i) / Double(bars)
                let h: Double
                if i < 2 {
                    h = 1 - mix * 0.35
                } else {
                    let t = (x - 0.04) / max(0.05, tailFraction)
                    h = mix * 0.85 * exp(-3.2 * t) * (0.75 + 0.25 * sin(Double(i) * 1.7))
                }
                let barH = max(3, CGFloat(h) * size.height)
                let rect = CGRect(x: CGFloat(i) * w + 1, y: (size.height - barH) / 2, width: w - 2, height: barH)
                ctx.fill(Path(roundedRect: rect, cornerRadius: (w - 2) / 2),
                         with: .color(i < 2 ? Theme.text : color.opacity(0.3 + 0.7 * h)))
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous).fill(Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous).strokeBorder(Theme.stroke, lineWidth: Theme.border)))
        .scaleEffect(step == 4 || step == 12 ? 1.015 : 1)
        .animation(.spring(response: 0.25), value: step)
        .animation(.spring(response: 0.5), value: mix)
        .animation(.spring(response: 0.5), value: seconds)
    }
}
