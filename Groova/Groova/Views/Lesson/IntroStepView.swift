//
//  IntroStepView.swift
//  Groova
//
//  "Meet the sound": big tactile pads. Hear first, read second.
//

import Foundation
import SwiftUI

struct IntroStepView: View {
    let step: IntroStep
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var tapped = Set<DrumTrack>()
    private var transport: Transport { Transport.shared }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    if step.pads.isEmpty {
                        WooferTalks(title: step.title, line: step.body, badge: step.badge ?? (step.demo == nil ? "Woofer says" : "New idea"),
                                    compact: step.demo != nil)
                    } else {
                        StepPrompt(title: step.title, detail: step.body, badge: step.badge ?? "New sound")
                    }
                    if !step.pads.isEmpty {
                        HStack(spacing: 16) {
                            ForEach(step.pads) { track in
                                DrumPad(track: track, kit: Transport.shared.kit(for: genre), large: step.pads.count == 1) {
                                    tapped.insert(track)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                    }

                    if let demo = step.demo {
                        VStack(spacing: 12) {
                            TransportButton(title: transport.isPlaying(.demo) ? "Stop" : "Hear it in a groove",
                                            symbol: transport.isPlaying(.demo) ? "stop.fill" : "play.fill",
                                            active: transport.isPlaying(.demo), color: genre.color) {
                                transport.toggle(demo, genre: genre, source: .demo)
                            }
                            PatternGlyph(pattern: demo, color: genre.color,
                                         playhead: transport.isPlaying(.demo) ? transport.step : -1)
                                .frame(height: 54)
                        }
                        .card()
                    }
                }
                .padding(20)
            }
            StepFooter(feedback: nil, primaryTitle: allTapped ? "Continue" : "Tap to hear it",
                       primaryEnabled: allTapped,
                       onPrimary: { transport.stop(); onComplete(1) }, onContinue: {}, onRetry: {})
        }
    }

    private var allTapped: Bool { step.pads.allSatisfy { tapped.contains($0) } }
}

/// A teaching card with no pads to play: Woofer front and centre, his words in a bubble above him.
struct WooferTalks: View {
    let title: String
    let line: String
    let badge: String
    /// Smaller Woofer when a demo card sits underneath.
    var compact = false
    @Environment(\.accent) private var accent
    @State private var shown = false

    var body: some View {
        VStack(spacing: 0) {
            Text(badge.uppercased())
                .font(.label(14, weight: .black)).tracking(0.6)
                .foregroundStyle(accent)
            Text(title)
                .font(.display(28))
                .foregroundStyle(Theme.text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
            Text(line)
                .font(.label(17, weight: .semibold))
                .foregroundStyle(Theme.text)
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 18 + DownBubble.tail)
                .frame(maxWidth: .infinity)
                .background(DownBubble().fill(Theme.brandSoft))
                .padding(.top, 22)
                .scaleEffect(shown ? 1 : 0.92, anchor: .bottom)
                .opacity(shown ? 1 : 0)
            WooferView(mood: .happy, size: compact ? 120 : 180, bouncing: true)
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, compact ? 4 : 16)
        .accessibilityElement(children: .combine)
        .onAppear { withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.1)) { shown = true } }
    }
}

/// A rounded bubble with its tail pointing down at Woofer.
struct DownBubble: Shape {
    static let tail: CGFloat = 14

    func path(in r: CGRect) -> Path {
        let body = CGRect(x: r.minX, y: r.minY, width: r.width, height: r.height - Self.tail)
        var p = Path(roundedRect: body, cornerRadius: 22, style: .continuous)
        var t = Path()
        t.move(to: CGPoint(x: r.midX - 14, y: body.maxY - 1))
        t.addQuadCurve(to: CGPoint(x: r.midX, y: r.maxY), control: CGPoint(x: r.midX - 4, y: body.maxY + 4))
        t.addQuadCurve(to: CGPoint(x: r.midX + 14, y: body.maxY - 1), control: CGPoint(x: r.midX + 4, y: body.maxY + 4))
        t.closeSubpath()
        p.addPath(t)
        return p
    }
}

/// A big square performance pad that flashes and ripples when hit.
struct DrumPad: View {
    let track: DrumTrack
    let kit: DrumKit
    var large = false
    var onHit: () -> Void = {}

    @State private var hits = 0
    @State private var pressed = false
    @State private var ripples: [UUID] = []

    var body: some View {
        let color = Theme.color(for: track)
        let size: CGFloat = large ? 210 : 150
        ZStack {
            ForEach(ripples, id: \.self) { id in
                RippleRing(color: color)
                    .id(id)
            }
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(pressed ? Theme.brandLip : Theme.stroke)
                .offset(y: pressed ? 2 : 7)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(pressed ? color : Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(pressed ? .clear : Theme.stroke, lineWidth: Theme.border)
                )
                .offset(y: pressed ? 2 : 0)
            VStack(spacing: 10) {
                Image(systemName: track.symbol)
                    .font(.system(size: large ? 54 : 38, weight: .bold))
                    .symbolEffect(.bounce, value: hits)
                Text(track.name)
                    .font(.label(large ? 20 : 16, weight: .black))
            }
            .foregroundStyle(pressed ? Theme.onBrand : color)
            .offset(y: pressed ? 2 : 0)
        }
        .frame(width: size, height: size)
        .animation(.easeOut(duration: 0.07), value: pressed)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !pressed else { return }
                    pressed = true
                    hits += 1
                    AudioEngine.shared.trigger(track, kit: kit)
                    Haptics.thump()
                    let id = UUID()
                    ripples.append(id)
                    Task {
                        try? await Task.sleep(for: .seconds(0.9))
                        ripples.removeAll { $0 == id }
                    }
                    onHit()
                }
                .onEnded { _ in pressed = false }
        )
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Play \(track.name)")
    }
}

struct RippleRing: View {
    let color: Color
    @State private var grow = false

    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .strokeBorder(color.opacity(0.5), lineWidth: 3)
            .scaleEffect(grow ? 1.5 : 1)
            .opacity(grow ? 0 : 0.8)
            .onAppear { withAnimation(.easeOut(duration: 0.8)) { grow = true } }
            .allowsHitTesting(false)
    }
}

/// Tiny visual fingerprint of a groove: one dotted lane per active instrument.
struct PatternGlyph: View {
    let pattern: Pattern
    let color: Color
    var playhead: Int = -1

    var body: some View {
        let lanes = DrumTrack.allCases.filter { pattern.hits($0) > 0 }
        let hasBass = !pattern.bass.isEmpty
        let hasChords = !pattern.chords.isEmpty
        GeometryReader { geo in
            let rows = lanes.count + (hasBass ? 1 : 0) + (hasChords ? 1 : 0)
            let rowH = geo.size.height / CGFloat(max(rows, 1))
            let w = geo.size.width / 16
            Canvas { ctx, _ in
                if playhead >= 0 {
                    let rect = CGRect(x: CGFloat(playhead) * w, y: 0, width: w, height: geo.size.height)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(Theme.brandSoft))
                }
                for (r, track) in lanes.enumerated() {
                    let c = Theme.color(for: track)
                    for i in 0..<16 {
                        let on = pattern[track][i]
                        let d = min(w, rowH) * (on ? 0.62 : 0.22)
                        let rect = CGRect(x: CGFloat(i) * w + (w - d) / 2, y: CGFloat(r) * rowH + (rowH - d) / 2,
                                          width: d, height: d)
                        let lit = i == playhead && on
                        ctx.fill(Path(ellipseIn: rect),
                                 with: .color(on ? (lit ? Theme.brandLip : c) : Theme.surfaceHigh))
                    }
                }
                if hasBass {
                    let r = CGFloat(lanes.count)
                    for n in pattern.bass {
                        let rect = CGRect(x: CGFloat(n.step) * w + 1, y: r * rowH + rowH * 0.3,
                                          width: CGFloat(n.length) * w - 2, height: rowH * 0.4)
                        ctx.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(Theme.bassColor))
                    }
                }
                if hasChords {
                    let r = CGFloat(lanes.count + (hasBass ? 1 : 0))
                    for ch in pattern.chords {
                        let rect = CGRect(x: CGFloat(ch.step) * w + 1, y: r * rowH + rowH * 0.2,
                                          width: CGFloat(max(1, min(ch.length, 16 - ch.step))) * w - 2, height: rowH * 0.6)
                        ctx.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(Theme.brandBorder))
                    }
                }
            }
        }
    }
}
