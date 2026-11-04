//
//  Components.swift
//  Groova
//
//  Flat, chunky building blocks. Everything pressable has a lip that
//  compresses when you push it.
//

import Foundation
import SwiftUI

// MARK: - Buttons

/// The primary button: solid color, darker lip underneath, uppercase label.
struct ChunkyButtonStyle: ButtonStyle {
    var color: Color
    var textColor: Color = Theme.onBrand
    var height: CGFloat = 54
    var enabled = true

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && enabled
        let lip: CGFloat = 5
        configuration.label
            .font(.label(17, weight: .heavy))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(enabled ? textColor : Theme.textTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(enabled ? color : Theme.surfaceHigh)
            )
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(enabled ? Theme.lip(for: color) : Theme.lockedLip)
                    .offset(y: pressed ? 0 : lip)
            )
            .offset(y: pressed ? lip : 0)
            .padding(.bottom, lip)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

/// Secondary button: white with a gray border and lip.
struct GhostButtonStyle: ButtonStyle {
    var height: CGFloat = 54
    var textColor: Color = Theme.textSecondary

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let lip: CGFloat = 4
        configuration.label
            .font(.label(17, weight: .heavy))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.surface)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Theme.stroke, lineWidth: Theme.border))
            )
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.stroke)
                    .offset(y: pressed ? 0 : lip)
            )
            .offset(y: pressed ? lip : 0)
            .padding(.bottom, lip)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

/// Generic press feedback for custom tappable things.
struct PressScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Play / stop / reference control: a chunky rounded square plus a label.
struct TransportButton: View {
    let title: String
    let symbol: String
    let active: Bool
    var color: Color
    let action: () -> Void

    var body: some View {
        Button(action: { Haptics.tap(); action() }) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .black))
                    .contentTransition(.symbolEffect(.replace))
                Text(title)
                    .font(.label(16, weight: .heavy))
            }
            .foregroundStyle(active ? Theme.onBrand : color)
            .padding(.horizontal, 14)
            .frame(height: 44)
        }
        .buttonStyle(LipStyle(fill: active ? color : Theme.surface,
                              lip: active ? Theme.lip(for: color) : Theme.stroke,
                              border: active ? .clear : Theme.stroke,
                              radius: 14))
    }
}

/// A lip + fill background for small custom buttons.
struct LipStyle: ButtonStyle {
    var fill: Color
    var lip: Color
    var border: Color = .clear
    var radius: CGFloat = 14
    var depth: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(border, lineWidth: Theme.border))
            )
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(lip)
                    .offset(y: pressed ? 0 : depth)
            )
            .offset(y: pressed ? depth : 0)
            .padding(.bottom, depth)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

// MARK: - Surfaces

/// White card with a 2pt gray border.
struct CardBackground: ViewModifier {
    var padding: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.radius, style: .continuous)
                    .fill(Theme.surface)
                    .overlay(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous)
                        .strokeBorder(Theme.stroke, lineWidth: Theme.border))
            )
    }
}

extension View {
    func card(padding: CGFloat = 18) -> some View { modifier(CardBackground(padding: padding)) }
}

/// Stat in the top bar: icon + number, no container.
struct Pill: View {
    let symbol: String
    let text: String
    var color: Color = Theme.text

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: symbol).font(.system(size: 17, weight: .black)).foregroundStyle(color)
            Text(text).font(.label(17, weight: .black)).foregroundStyle(color).monospacedDigit()
        }
        .fixedSize()
        .frame(height: 36)
    }
}

// MARK: - Progress

struct ProgressBar: View {
    var value: Double
    var color: Color
    var height: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.surfaceHigh)
                Capsule()
                    .fill(color)
                    .frame(width: max(height, geo.size.width * min(1, max(0, value))))
                    .overlay(alignment: .top) {
                        Capsule().fill(.white.opacity(0.3)).frame(height: max(2, height * 0.22))
                            .padding(.horizontal, height * 0.5).padding(.top, height * 0.2)
                    }
                    .opacity(value <= 0 ? 0 : 1)
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
    }
}

struct Ring: View {
    var value: Double
    var color: Color
    var lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            Circle().stroke(Theme.surfaceHigh, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(1, max(0, value)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.85), value: value)
    }
}

// MARK: - Knob

/// A rotary control. Drag up/down (or sideways) to turn it.
struct Knob: View {
    @Binding var value: Double       // 0...1
    let label: String
    let valueText: String
    var color: Color
    var size: CGFloat = 112
    var onChange: (() -> Void)? = nil
    /// When set, a green dot marks the correct position and the answer shows under the value.
    var target: Double? = nil
    var targetText: String? = nil

    @State private var dragStart: Double?
    @State private var lastDetent = -1

    private let startAngle = 135.0
    private let sweep = 270.0

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Theme.surfaceHigh, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(startAngle))
                Circle()
                    .trim(from: 0, to: 0.75 * value)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(startAngle))
                Circle()
                    .fill(Theme.lockedLip)
                    .padding(20)
                    .offset(y: 4)
                Circle()
                    .fill(Theme.surface)
                    .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: Theme.border))
                    .padding(20)
                Capsule()
                    .fill(color)
                    .frame(width: 5, height: size * 0.15)
                    .offset(y: -size * 0.2)
                    .rotationEffect(.degrees(startAngle + 90 + sweep * value))
                if let target {
                    Circle()
                        .fill(Theme.success)
                        .overlay(Circle().strokeBorder(Theme.surface, lineWidth: 2.5))
                        .frame(width: 16, height: 16)
                        .offset(y: -size / 2)
                        .rotationEffect(.degrees(startAngle + 90 + sweep * target))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        if dragStart == nil { dragStart = value }
                        let delta = (-g.translation.height + g.translation.width) / 220
                        let v = min(1, max(0, (dragStart ?? 0) + delta))
                        value = v
                        let detent = Int(v * 20)
                        if detent != lastDetent { lastDetent = detent; Haptics.select() }
                        onChange?()
                    }
                    .onEnded { _ in dragStart = nil }
            )
            VStack(spacing: 2) {
                Text(label.uppercased())
                    .font(.label(12, weight: .heavy)).tracking(0.8)
                    .foregroundStyle(Theme.textSecondary)
                Text(valueText)
                    .font(.mono(16, weight: .heavy))
                    .foregroundStyle(Theme.text)
                    .contentTransition(.numericText())
                if let targetText {
                    Text("Answer: \(targetText)")
                        .font(.label(12, weight: .heavy))
                        .foregroundStyle(Theme.successInk)
                        .transition(.opacity)
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue(valueText)
        .accessibilityAdjustableAction { dir in
            switch dir {
            case .increment: value = min(1, value + 0.05)
            case .decrement: value = max(0, value - 0.05)
            default: break
            }
            onChange?()
        }
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    var colors: [Color]
    var count = 70

    @State private var start = Date.now
    @State private var particles: [Particle] = []

    struct Particle {
        var x: Double, vx: Double, vy: Double, spin: Double, size: Double, color: Int, shape: Int
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSince(start)
                for p in particles {
                    let px = size.width * p.x + p.vx * t * 60
                    let py = -20 + p.vy * t * 60 + 320 * t * t
                    guard py < size.height + 40 else { continue }
                    let fade = max(0, 1 - t / 3.2)
                    var c = ctx
                    c.opacity = fade
                    c.translateBy(x: px, y: py)
                    c.rotate(by: .radians(p.spin * t * 6))
                    let rect = CGRect(x: -p.size / 2, y: -p.size / 4, width: p.size, height: p.size / 2)
                    let path = p.shape == 0 ? Path(roundedRect: rect, cornerRadius: 2) : Path(ellipseIn: rect)
                    c.fill(path, with: .color(colors[p.color % colors.count]))
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            start = .now
            particles = (0..<count).map { _ in
                Particle(x: .random(in: 0.05...0.95), vx: .random(in: -1.6...1.6), vy: .random(in: -2...5),
                         spin: .random(in: -2...2), size: .random(in: 8...14), color: .random(in: 0..<99),
                         shape: .random(in: 0...1))
            }
        }
    }
}

// MARK: - Section header

struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.label(12, weight: .bold))
            .tracking(1.4)
            .foregroundStyle(Theme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CompareCaption: View {
    var body: some View {
        Label("Reference in your left ear, yours in your right. Anything you only hear on one side is off.",
              systemImage: "headphones")
            .font(.label(13, weight: .semibold))
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .transition(.opacity)
    }
}
