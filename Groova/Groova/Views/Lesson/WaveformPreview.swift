//
//  WaveformPreview.swift
//  Groova
//
//  Draws the sound you're shaping in a Sound Lab: the whole hit or note on top, and a close-up
//  of the wave itself underneath. Redrawn every time a knob moves.
//

import Foundation
import SwiftUI

enum PreviewSound: Equatable {
    case kick, bass, chord

    init(_ params: [SoundParam]) {
        let name = params.first?.rawValue ?? ""
        self = name.hasPrefix("kick") ? .kick : (name.hasPrefix("bass") ? .bass : .chord)
    }

    var title: String {
        switch self {
        case .kick: "Kick"
        case .bass: "Bass note"
        case .chord: "Chord"
        }
    }

    /// How much time the overview shows.
    var seconds: Double {
        switch self {
        case .kick: 0.7
        case .bass: 0.6
        case .chord: 1.8
        }
    }
}

struct WaveformPreview: View {
    let kit: DrumKit
    let sound: PreviewSound
    var color: Color = Theme.brand
    var dimmed = false

    @State private var samples: [Float] = []
    private let rate: Float = 24_000

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Waveform", systemImage: "waveform")
                    .font(.label(12, weight: .black)).tracking(0.6)
                    .foregroundStyle(Theme.textSecondary)
                    .textCase(.uppercase)
                Spacer()
                Text(sound.title).font(.label(12, weight: .bold)).foregroundStyle(Theme.textTertiary)
            }
            Canvas { ctx, size in drawOverview(ctx, size) }
                .frame(height: 70)
            HStack(spacing: 6) {
                Text("CLOSE-UP").font(.label(10, weight: .black)).tracking(0.8)
                    .foregroundStyle(Theme.textTertiary)
                Rectangle().fill(Theme.divider).frame(height: 1)
            }
            Canvas { ctx, size in drawCloseUp(ctx, size) }
                .frame(height: 54)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous)
            .strokeBorder(Theme.stroke, lineWidth: Theme.border))
        .opacity(dimmed ? 0.5 : 1)
        .task(id: kit) { samples = render() }
        .accessibilityHidden(true)
    }

    private func render() -> [Float] {
        let event: PendingEvent
        switch sound {
        case .kick: event = .drum(.kick, 1, kit)
        case .bass: event = .note(midi: 33, seconds: 0.32, patch: kit.bass, velocity: 1, delay: 0)
        case .chord:
            // Render each chord tone and sum, so the shape matches what you hear.
            let notes = ChordShape.am7.pitches.map {
                DSPCore.renderOffline(.note(midi: $0, seconds: 0.6, patch: kit.chords, velocity: 1, delay: 0),
                                      seconds: sound.seconds, sampleRate: rate)
            }
            guard var sum = notes.first else { return [] }
            for n in notes.dropFirst() { for i in sum.indices { sum[i] += n[i] } }
            return sum
        }
        return DSPCore.renderOffline(event, seconds: sound.seconds, sampleRate: rate)
    }

    private var peak: Float { max(samples.lazy.map { abs($0) }.max() ?? 0, 1e-4) }

    /// The whole sound, min/max per column, mirrored around the middle.
    private func drawOverview(_ ctx: GraphicsContext, _ size: CGSize) {
        let mid = size.height / 2
        var axis = Path()
        axis.move(to: CGPoint(x: 0, y: mid)); axis.addLine(to: CGPoint(x: size.width, y: mid))
        ctx.stroke(axis, with: .color(Theme.surfaceHigh), lineWidth: 1.5)
        guard !samples.isEmpty else { return }
        let cols = max(1, Int(size.width / 2))
        let per = max(1, samples.count / cols)
        let p = peak
        var top: [CGPoint] = [], bottom: [CGPoint] = []
        for c in 0..<cols {
            let lo = c * per, hi = min(samples.count, lo + per)
            guard lo < hi else { break }
            var mx: Float = 0
            for i in lo..<hi { mx = max(mx, abs(samples[i])) }
            let h = CGFloat(mx / p) * (mid - 2)
            let x = CGFloat(c) / CGFloat(cols - 1) * size.width
            top.append(CGPoint(x: x, y: mid - h))
            bottom.append(CGPoint(x: x, y: mid + h))
        }
        var shape = Path()
        shape.addLines(top)
        shape.addLines(bottom.reversed())
        shape.closeSubpath()
        ctx.fill(shape, with: .color(color.opacity(0.85)))
    }

    /// A few cycles of the wave, so you can see brightness, bite and squelch.
    private func drawCloseUp(_ ctx: GraphicsContext, _ size: CGSize) {
        let mid = size.height / 2
        guard !samples.isEmpty else { return }
        let start: Int, length: Int
        switch sound {
        case .kick: start = 0; length = Int(rate * 0.09)
        case .bass: start = Int(rate * 0.012); length = Int(rate * 0.055)
        case .chord:
            let attack = Double(kit.chords.attack)
            start = Int(rate * Float(min(0.5, max(0.02, attack)))); length = Int(rate * 0.03)
        }
        guard start + 2 < samples.count else { return }
        let end = min(samples.count, start + length)
        let window = samples[start..<end]
        let p = max(window.lazy.map { abs($0) }.max() ?? 0, peak * 0.05)
        var path = Path()
        let n = window.count
        for (k, v) in window.enumerated() {
            let x = CGFloat(k) / CGFloat(max(1, n - 1)) * size.width
            let y = mid - CGFloat(v / p) * (mid - 3)
            if k == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
    }
}
