//
//  Woofer.swift
//  Groova
//
//  Woofer, the Groova mascot: a chubby speaker cab with a subwoofer for a belly.
//  Drawn in a 200 × 200 space so it scales cleanly to any size.
//

import Foundation
import SwiftUI

enum WooferMood: Hashable {
    /// Talking you through something.
    case happy
    /// Thinking, with a lightbulb.
    case hint
    /// A miss: worried eyebrows and a wobbly mouth.
    case oops
    /// A win: eyes squeezed shut, mouth wide open, notes flying.
    case party
}

struct WooferView: View {
    var mood: WooferMood = .happy
    var size: CGFloat = 120
    /// Bops at 120 BPM, like it's listening to your loop.
    var bouncing = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var up = false

    var body: some View {
        Canvas { ctx, canvas in
            var c = ctx
            let s = canvas.width / 200
            c.scaleBy(x: s, y: s)
            WooferArt.draw(c, mood: mood)
        }
        .frame(width: size, height: size)
        .scaleEffect(x: up ? 0.98 : 1, y: up ? 1.04 : 1, anchor: .bottom)
        .offset(y: up ? -size * 0.03 : 0)
        .onAppear {
            guard bouncing, !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) { up = true }
        }
        .accessibilityHidden(true)
    }
}

/// Woofer with a speech bubble, the way he talks you through a lesson.
/// The bubble's tail sits level with his face, whatever the length of the line.
struct WooferCoach: View {
    let line: String
    var mood: WooferMood = .happy
    var size: CGFloat = 60
    var bouncing = false

    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            WooferView(mood: mood, size: size, bouncing: bouncing)
            Text(line)
                .font(.label(15, weight: .semibold))
                .foregroundStyle(Theme.text)
                .lineSpacing(2.5)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, SpeechBubble.tail + 14)
                .padding(.trailing, 16)
                .padding(.vertical, 13)
                .frame(minHeight: size * 0.8, alignment: .leading)
                .background(SpeechBubble(tailY: size * 0.42).fill(Theme.brandSoft))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// A rounded bubble with a small tail on the left, pointing at Woofer's face.
struct SpeechBubble: Shape {
    static let tail: CGFloat = 8
    /// Where the tip of the tail sits, from the top.
    var tailY: CGFloat = 24

    func path(in r: CGRect) -> Path {
        let tail = Self.tail
        let body = CGRect(x: r.minX + tail, y: r.minY, width: r.width - tail, height: r.height)
        var p = Path(roundedRect: body, cornerRadius: 18, style: .continuous)
        let y = min(max(r.minY + tailY, r.minY + 16), r.maxY - 16)
        var t = Path()
        t.move(to: CGPoint(x: body.minX + 1, y: y - 9))
        t.addQuadCurve(to: CGPoint(x: r.minX, y: y + 2), control: CGPoint(x: body.minX - 1, y: y - 2))
        t.addQuadCurve(to: CGPoint(x: body.minX + 1, y: y + 9), control: CGPoint(x: body.minX - 1, y: y + 7))
        t.closeSubpath()
        p.addPath(t)
        return p
    }
}

/// The drawing itself. Coordinates match the concept sketch.
enum WooferArt {
    static let body = Color(hex: 0x7B5CFA)
    static let lip = Color(hex: 0x5A3FD6)
    static let arm = Color(hex: 0x6A4FE6)
    static let cone = Color(hex: 0x3E2A9E)
    static let cap = Color(hex: 0x9B83FF)
    static let ink = Color(hex: 0x262833)
    static let cheek = Color(hex: 0xFF8FB1)
    static let tongue = Color(hex: 0xFF7A9A)

    static func rr(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> Path {
        Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: r, style: .continuous)
    }

    static func dot(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }

    static func draw(_ c: GraphicsContext, mood: WooferMood, extras showExtras: Bool = true) {
        // Ground shadow and feet
        c.fill(Path(ellipseIn: CGRect(x: 44, y: 183, width: 112, height: 14)), with: .color(.black.opacity(0.08)))
        c.fill(rr(58, 166, 30, 20, 10), with: .color(lip))
        c.fill(rr(112, 166, 30, 20, 10), with: .color(lip))

        // Arms behind the body
        let armStyle = StrokeStyle(lineWidth: 14, lineCap: .round)
        c.stroke(armPath(x: 40, y: 112, dir: -1, mood: mood, left: true), with: .color(arm), style: armStyle)
        c.stroke(armPath(x: 160, y: 112, dir: 1, mood: mood, left: false), with: .color(arm), style: armStyle)

        // Cabinet with its chunky lip, like Groova's buttons
        c.fill(rr(36, 34, 128, 140, 38), with: .color(lip))
        c.fill(rr(36, 26, 128, 140, 38), with: .color(body))
        c.fill(rr(50, 36, 40, 10, 5), with: .color(.white.opacity(0.22)))

        // Cheeks
        c.fill(dot(58, 92, 9), with: .color(cheek.opacity(0.75)))
        c.fill(dot(142, 92, 9), with: .color(cheek.opacity(0.75)))

        eyes(c, xs: [76, 124], cy: 66, r: 17, mood: mood)
        mouth(c, cx: 100, cy: 90, w: 26, mood: mood)

        // The subwoofer belly
        c.fill(dot(100, 132, 29), with: .color(lip))
        c.fill(dot(100, 132, 21), with: .color(cone))
        c.fill(dot(100, 132, 9), with: .color(cap))

        if showExtras { extras(c, mood: mood) }
    }

    static func armPath(x: CGFloat, y: CGFloat, dir d: CGFloat, mood: WooferMood, left: Bool) -> Path {
        let (cx, cy, ex, ey): (CGFloat, CGFloat, CGFloat, CGFloat)
        switch mood {
        case .party: (cx, cy, ex, ey) = (14, -6, 22, -34)
        case .hint where !left: (cx, cy, ex, ey) = (16, -4, 18, -30)
        case .oops where left: (cx, cy, ex, ey) = (16, -10, 6, -32)
        default: (cx, cy, ex, ey) = (16, 6, 16, 28)
        }
        var p = Path()
        p.move(to: CGPoint(x: x, y: y))
        p.addQuadCurve(to: CGPoint(x: x + d * ex, y: y + ey), control: CGPoint(x: x + d * cx, y: y + cy))
        return p
    }

    static func eyes(_ c: GraphicsContext, xs: [CGFloat], cy: CGFloat, r: CGFloat, mood: WooferMood) {
        for (i, cx) in xs.enumerated() {
            if mood == .party {
                var p = Path()
                p.move(to: CGPoint(x: cx - r * 0.75, y: cy + r * 0.25))
                p.addQuadCurve(to: CGPoint(x: cx + r * 0.75, y: cy + r * 0.25), control: CGPoint(x: cx, y: cy - r * 1.05))
                c.stroke(p, with: .color(ink), style: StrokeStyle(lineWidth: r * 0.38, lineCap: .round))
                continue
            }
            var px = cx, py = cy + r * 0.1, pr = r * 0.56
            if mood == .hint { px = cx + r * 0.28; py = cy - r * 0.28 }
            if mood == .oops { pr = r * 0.34; py = cy + r * 0.05 }
            c.fill(dot(cx, cy, r), with: .color(.white))
            c.fill(dot(px, py, pr), with: .color(ink))
            c.fill(dot(px - pr * 0.35, py - pr * 0.4, pr * 0.32), with: .color(.white))

            let brow = StrokeStyle(lineWidth: r * 0.3, lineCap: .round)
            if mood == .oops {
                let tilt: CGFloat = i == 0 ? 3 : -3
                var p = Path()
                p.move(to: CGPoint(x: cx - r * 0.9, y: cy - r * 1.35 - tilt))
                p.addLine(to: CGPoint(x: cx + r * 0.9, y: cy - r * 1.35 + tilt))
                c.stroke(p, with: .color(ink), style: brow)
            }
            if mood == .hint && i == 1 {
                var p = Path()
                p.move(to: CGPoint(x: cx - r * 0.9, y: cy - r * 1.5))
                p.addQuadCurve(to: CGPoint(x: cx + r * 0.9, y: cy - r * 1.4), control: CGPoint(x: cx, y: cy - r * 2))
                c.stroke(p, with: .color(ink), style: brow)
            }
        }
    }

    static func mouth(_ c: GraphicsContext, cx: CGFloat, cy: CGFloat, w: CGFloat, mood: WooferMood) {
        switch mood {
        case .hint:
            c.fill(Path(ellipseIn: CGRect(x: cx + 3 - w * 0.13, y: cy + 3 - w * 0.17, width: w * 0.26, height: w * 0.34)),
                   with: .color(ink))
        case .oops:
            let q = w / 4
            var p = Path()
            p.move(to: CGPoint(x: cx - w / 2, y: cy + 4))
            for k in 0..<4 {
                let x0 = cx - w / 2 + CGFloat(k) * q
                p.addQuadCurve(to: CGPoint(x: x0 + q, y: cy + 4),
                               control: CGPoint(x: x0 + q / 2, y: cy + 4 + (k.isMultiple(of: 2) ? -7 : 7)))
            }
            c.stroke(p, with: .color(ink), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        case .party:
            var p = Path()
            p.move(to: CGPoint(x: cx - w / 2, y: cy))
            p.addQuadCurve(to: CGPoint(x: cx + w / 2, y: cy), control: CGPoint(x: cx, y: cy + w * 0.95))
            p.closeSubpath()
            c.fill(p, with: .color(ink))
            c.fill(Path(ellipseIn: CGRect(x: cx - w * 0.2, y: cy + w * 0.21, width: w * 0.4, height: w * 0.22)),
                   with: .color(tongue))
        case .happy:
            var p = Path()
            p.move(to: CGPoint(x: cx - w / 2, y: cy))
            p.addQuadCurve(to: CGPoint(x: cx + w / 2, y: cy), control: CGPoint(x: cx, y: cy + w * 0.55))
            c.stroke(p, with: .color(ink), style: StrokeStyle(lineWidth: 5.5, lineCap: .round))
        }
    }

    static func note(_ c: GraphicsContext, x: CGFloat, y: CGFloat, color: Color, scale s: CGFloat = 1) {
        var n = c
        n.translateBy(x: x, y: y)
        n.scaleBy(x: s, y: s)
        n.fill(Path(ellipseIn: CGRect(x: -7, y: -5.5, width: 14, height: 11)), with: .color(color))
        n.fill(rr(4.5, -26, 3.6, 26, 1.5), with: .color(color))
        var flag = Path()
        flag.move(to: CGPoint(x: 8, y: -26))
        flag.addQuadCurve(to: CGPoint(x: 17, y: -12), control: CGPoint(x: 18, y: -22))
        flag.addQuadCurve(to: CGPoint(x: 8, y: -19), control: CGPoint(x: 14, y: -19))
        flag.closeSubpath()
        n.fill(flag, with: .color(color))
    }

    static func extras(_ c: GraphicsContext, mood: WooferMood) {
        switch mood {
        case .hint:
            c.fill(dot(170, 34, 15), with: .color(Color(hex: 0xFFB800)))
            c.fill(rr(163, 47, 14, 9, 3), with: .color(Color(hex: 0xA3A6B2)))
            var v = Path()
            v.move(to: CGPoint(x: 165, y: 35))
            v.addLine(to: CGPoint(x: 170, y: 30))
            v.addLine(to: CGPoint(x: 175, y: 35))
            c.stroke(v, with: .color(.white), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        case .oops:
            var d = Path()
            d.move(to: CGPoint(x: 168, y: 36))
            d.addQuadCurve(to: CGPoint(x: 168, y: 56), control: CGPoint(x: 159, y: 50))
            d.addQuadCurve(to: CGPoint(x: 168, y: 36), control: CGPoint(x: 177, y: 50))
            c.fill(d, with: .color(Color(hex: 0x6EC6FF)))
        case .party:
            note(c, x: 26, y: 52, color: Color(hex: 0xFFB800), scale: 1.1)
            note(c, x: 172, y: 40, color: Color(hex: 0x3CC37A))
            c.fill(rr(150, 70, 9, 9, 2), with: .color(Color(hex: 0xFF4B4B)))
            c.fill(rr(34, 84, 8, 8, 2), with: .color(body))
            c.fill(dot(160, 14, 4), with: .color(Color(hex: 0xFF9600)))
            c.fill(dot(46, 22, 4), with: .color(Color(hex: 0x3CC37A)))
        case .happy:
            break
        }
    }
}

/// Things Woofer gets up to beside the lesson path.
enum WooferActivity: CaseIterable {
    case decks, headphones, keys, pads, mic, vinyl, laptop, bass, drum, disco
}

/// Woofer busy with some gear. Grey and faded until `active`.
struct WooferScene: View {
    let activity: WooferActivity
    var size: CGFloat = 100
    var active = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var up = false

    var body: some View {
        Canvas { ctx, canvas in
            var c = ctx
            let s = canvas.width / 200
            c.scaleBy(x: s, y: s)
            WooferScenes.draw(c, activity)
        }
        .frame(width: size, height: size)
        .scaleEffect(x: 1, y: up ? 1.03 : 1, anchor: .bottom)
        .grayscale(active ? 0 : 1)
        .opacity(active ? 1 : 0.32)
        .animation(.easeOut(duration: 0.4), value: active)
        .onAppear {
            guard active, !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { up = true }
        }
        .accessibilityHidden(true)
    }
}

enum WooferScenes {
    typealias A = WooferArt
    static let dark = Color(hex: 0x262833)
    static let darker = Color(hex: 0x15161D)
    static let gold = Color(hex: 0xFFB800)
    static let orange = Color(hex: 0xFF9600)
    static let green = Color(hex: 0x3CC37A)
    static let pink = Color(hex: 0xFF7A9A)

    static func draw(_ c: GraphicsContext, _ a: WooferActivity) {
        switch a {
        case .decks:
            A.draw(c, mood: .party, extras: false)
            headphones(c)
            // Table
            c.fill(A.rr(8, 134, 184, 52, 14), with: .color(darker))
            c.fill(A.rr(8, 128, 184, 50, 14), with: .color(dark))
            for x: CGFloat in [56, 144] {
                c.fill(Path(ellipseIn: CGRect(x: x - 32, y: 136, width: 64, height: 22)), with: .color(Color(hex: 0x3A3D4A)))
                c.fill(Path(ellipseIn: CGRect(x: x - 11, y: 143, width: 22, height: 8)), with: .color(A.cap))
            }
            c.fill(A.rr(93, 140, 14, 7, 3.5), with: .color(gold))
            A.note(c, x: 30, y: 40, color: gold, scale: 0.9)
        case .headphones:
            A.draw(c, mood: .party, extras: false)
            headphones(c)
            A.note(c, x: 22, y: 128, color: gold)
            A.note(c, x: 178, y: 120, color: green, scale: 0.85)
        case .keys:
            A.draw(c, mood: .happy, extras: false)
            c.fill(A.rr(14, 138, 172, 42, 10), with: .color(Color(hex: 0xC9CBD3)))
            c.fill(A.rr(14, 132, 172, 42, 10), with: .color(.white))
            var lines = Path()
            for k in 1..<10 {
                let x = 14 + CGFloat(k) * 17.2
                lines.move(to: CGPoint(x: x, y: 136)); lines.addLine(to: CGPoint(x: x, y: 170))
            }
            c.stroke(lines, with: .color(Color(hex: 0xDCDDE3)), style: StrokeStyle(lineWidth: 2))
            for k in [1, 2, 4, 5, 6, 8, 9] {
                c.fill(A.rr(14 + CGFloat(k) * 17.2 - 5, 132, 10, 22, 3), with: .color(dark))
            }
            A.note(c, x: 176, y: 44, color: A.body, scale: 0.9)
        case .pads:
            A.draw(c, mood: .happy, extras: false)
            c.fill(A.rr(28, 138, 144, 42, 12), with: .color(darker))
            c.fill(A.rr(28, 132, 144, 42, 12), with: .color(dark))
            let colors = [orange, A.cap, green, pink]
            for (k, col) in colors.enumerated() {
                c.fill(A.rr(37 + CGFloat(k) * 33, 140, 27, 26, 7), with: .color(col))
            }
            c.fill(A.rr(150, 22, 9, 9, 2), with: .color(orange))
            c.fill(A.rr(36, 30, 8, 8, 2), with: .color(green))
        case .mic:
            A.draw(c, mood: .party, extras: false)
            c.fill(A.rr(176, 72, 9, 34, 4), with: .color(Color(hex: 0x6B6E7B)))
            c.fill(A.dot(180.5, 62, 13), with: .color(Color(hex: 0xA3A6B2)))
            c.fill(A.dot(180.5, 62, 8), with: .color(Color(hex: 0x8A8D99)))
            A.note(c, x: 24, y: 50, color: gold, scale: 1.05)
            A.note(c, x: 40, y: 18, color: pink, scale: 0.7)
        default:
            extra(c, a)
        }
    }

    static func extra(_ c: GraphicsContext, _ a: WooferActivity) {
        switch a {
        case .vinyl:
            // Holding a record up to admire it
            A.draw(c, mood: .hint, extras: false)
            c.fill(A.dot(176, 60, 24), with: .color(darker))
            for r: CGFloat in [18, 13] {
                c.stroke(A.dot(176, 60, r), with: .color(Color(hex: 0x3A3D4A)), lineWidth: 1.5)
            }
            c.fill(A.dot(176, 60, 8), with: .color(orange))
            c.fill(A.dot(176, 60, 2), with: .color(darker))
        case .laptop:
            A.draw(c, mood: .happy, extras: false)
            c.fill(A.rr(42, 110, 116, 66, 9), with: .color(Color(hex: 0xA3A6B2)))
            c.fill(A.rr(46, 114, 108, 58, 7), with: .color(Color(hex: 0xC9CBD3)))
            c.fill(A.dot(100, 143, 8), with: .color(A.body))
            c.fill(A.rr(24, 172, 152, 11, 5), with: .color(Color(hex: 0x8A8D99)))
            A.note(c, x: 30, y: 46, color: green, scale: 0.85)
            A.note(c, x: 174, y: 40, color: gold, scale: 0.75)
        case .bass:
            A.draw(c, mood: .happy, extras: false)
            var g = c
            g.translateBy(x: 98, y: 146)
            g.rotate(by: .degrees(-28))
            g.fill(A.rr(10, -6, 96, 12, 4), with: .color(Color(hex: 0x8A5A2B)))
            g.fill(A.rr(100, -10, 22, 20, 5), with: .color(darker))
            g.fill(Path(ellipseIn: CGRect(x: -46, y: -24, width: 48, height: 48)), with: .color(orange))
            g.fill(Path(ellipseIn: CGRect(x: -14, y: -18, width: 40, height: 36)), with: .color(orange))
            g.fill(A.rr(-26, -10, 12, 20, 3), with: .color(darker))
            g.fill(A.dot(2, 0, 6), with: .color(darker))
            A.note(c, x: 28, y: 48, color: A.body, scale: 0.9)
        case .drum:
            A.draw(c, mood: .party, extras: false)
            let stick = StrokeStyle(lineWidth: 5, lineCap: .round)
            var s1 = Path(); s1.move(to: CGPoint(x: 18, y: 78)); s1.addLine(to: CGPoint(x: 40, y: 38))
            var s2 = Path(); s2.move(to: CGPoint(x: 182, y: 78)); s2.addLine(to: CGPoint(x: 160, y: 38))
            c.stroke(s1, with: .color(Color(hex: 0xC08A4A)), style: stick)
            c.stroke(s2, with: .color(Color(hex: 0xC08A4A)), style: stick)
            c.fill(A.rr(46, 146, 108, 38, 8), with: .color(Color(hex: 0xFF4B4B)))
            c.fill(A.rr(46, 152, 108, 5, 2), with: .color(.white.opacity(0.6)))
            c.fill(A.rr(46, 174, 108, 5, 2), with: .color(.white.opacity(0.6)))
            c.fill(Path(ellipseIn: CGRect(x: 46, y: 136, width: 108, height: 20)), with: .color(Color(hex: 0xF1F2F5)))
            c.fill(A.dot(30, 24, 4), with: .color(gold))
            c.fill(A.dot(172, 22, 4), with: .color(green))
        case .disco:
            A.draw(c, mood: .party, extras: false)
            var cord = Path(); cord.move(to: CGPoint(x: 156, y: 0)); cord.addLine(to: CGPoint(x: 156, y: 8))
            c.stroke(cord, with: .color(Color(hex: 0xA3A6B2)), lineWidth: 2)
            c.fill(A.dot(156, 24, 16), with: .color(Color(hex: 0xC9CBD3)))
            var grid = Path()
            for d: CGFloat in [-8, 0, 8] {
                grid.move(to: CGPoint(x: 156 + d, y: 9)); grid.addLine(to: CGPoint(x: 156 + d, y: 39))
                grid.move(to: CGPoint(x: 141, y: 24 + d)); grid.addLine(to: CGPoint(x: 171, y: 24 + d))
            }
            var ball = c
            ball.clip(to: A.dot(156, 24, 16))
            ball.stroke(grid, with: .color(.white), lineWidth: 1.5)
            c.fill(A.dot(150, 18, 4), with: .color(.white))
            for (x, y, col) in [(26.0, 40.0, gold), (186.0, 60.0, pink), (40.0, 14.0, A.cap)] as [(CGFloat, CGFloat, Color)] {
                var sp = Path()
                sp.move(to: CGPoint(x: x, y: y - 7)); sp.addLine(to: CGPoint(x: x, y: y + 7))
                sp.move(to: CGPoint(x: x - 7, y: y)); sp.addLine(to: CGPoint(x: x + 7, y: y))
                c.stroke(sp, with: .color(col), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
            }
        default:
            break
        }
    }

    static func headphones(_ c: GraphicsContext) {
        var band = Path()
        band.move(to: CGPoint(x: 32, y: 66))
        band.addQuadCurve(to: CGPoint(x: 168, y: 66), control: CGPoint(x: 100, y: -18))
        c.stroke(band, with: .color(dark), style: StrokeStyle(lineWidth: 10, lineCap: .round))
        for x: CGFloat in [20, 156] {
            c.fill(A.rr(x, 50, 24, 46, 11), with: .color(dark))
            c.fill(A.rr(x + (x < 100 ? 5 : 7), 58, 12, 30, 6), with: .color(gold))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack {
            WooferView(mood: .happy, size: 80)
            WooferView(mood: .hint, size: 80)
            WooferView(mood: .oops, size: 80)
            WooferView(mood: .party, size: 80)
        }
        HStack {
            ForEach(WooferActivity.allCases, id: \.self) { WooferScene(activity: $0, size: 34) }
        }
        HStack {
            ForEach(WooferActivity.allCases, id: \.self) { WooferScene(activity: $0, size: 34, active: false) }
        }
        WooferCoach(line: "Every house track starts with the kick. Put one on each beat.", bouncing: true)
    }
    .padding()
}
