//
//  GenreIcon.swift
//  Groova
//
//  One object per genre, drawn in Groova purple with a chunky darker lip underneath and a soft
//  highlight: House a disco ball, Deep House a crescent moon, Techno a robot head, Tech House
//  a rotary knob, UK Garage a boombox. Drawn in a 100 × 100 space.
//

import Foundation
import SwiftUI

struct GenreIcon: View {
    let genre: Genre
    var size: CGFloat = 48

    var body: some View {
        Canvas { ctx, canvas in
            var c = ctx
            let s = canvas.width / 100
            c.scaleBy(x: s, y: s)
            GenreArt.draw(c, genre)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// The icon on a soft purple tile.
struct GenreBadge: View {
    let genre: Genre
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .fill(Theme.brandSoft)
            GenreIcon(genre: genre, size: size * 0.84)
        }
        .frame(width: size, height: size)
    }
}

enum GenreArt {
    typealias A = WooferArt
    // Everything is drawn in Groova purple: body, lip, deep ink, light and pale tints.
    static let body = Color(hex: 0x7B5CFA)
    static let lip = Color(hex: 0x5A3FD6)
    static let ink = Color(hex: 0x2E1F7A)
    static let mid = Color(hex: 0x9B82FF)
    static let light = Color(hex: 0xCFC4FF)
    static let glow = Color(hex: 0xC8B9FF)
    static let pale = Color(hex: 0xF1EDFF)
    static let shine = Color.white.opacity(0.4)

    static func draw(_ c: GraphicsContext, _ g: Genre) {
        // Ground shadow
        c.fill(Path(ellipseIn: CGRect(x: 22, y: 88, width: 56, height: 8)), with: .color(.black.opacity(0.08)))
        switch g {
        case .house: discoBall(c)
        case .deepHouse: moon(c)
        case .techno: robot(c)
        case .techHouse: knob(c)
        case .ukGarage: boombox(c)
        }
    }

    /// Fill a shape with a chunky lip underneath, like Groova's buttons.
    static func chunky(_ c: GraphicsContext, _ p: Path, _ fill: Color = body, _ under: Color = lip, depth: CGFloat = 4) {
        c.fill(p.offsetBy(dx: 0, dy: depth), with: .color(under))
        c.fill(p, with: .color(fill))
    }

    static func line(_ c: GraphicsContext, _ pts: [CGPoint], _ color: Color, _ width: CGFloat) {
        var p = Path()
        p.addLines(pts)
        c.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    static func ring(_ c: GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ color: Color, _ width: CGFloat) {
        c.stroke(A.dot(x, y, r), with: .color(color), lineWidth: width)
    }

    /// A four-point twinkle.
    static func sparkle(_ c: GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat, color: Color) {
        let k = r * 0.15
        var p = Path()
        p.move(to: CGPoint(x: x, y: y - r))
        p.addQuadCurve(to: CGPoint(x: x + r, y: y), control: CGPoint(x: x + k, y: y - k))
        p.addQuadCurve(to: CGPoint(x: x, y: y + r), control: CGPoint(x: x + k, y: y + k))
        p.addQuadCurve(to: CGPoint(x: x - r, y: y), control: CGPoint(x: x - k, y: y + k))
        p.addQuadCurve(to: CGPoint(x: x, y: y - r), control: CGPoint(x: x - k, y: y - k))
        c.fill(p, with: .color(color))
    }

    // MARK: House: a disco ball

    static func discoBall(_ c: GraphicsContext) {
        line(c, [CGPoint(x: 50, y: 2), CGPoint(x: 50, y: 22)], ink, 3)
        let ball = A.dot(50, 52, 31)
        c.fill(ball.offsetBy(dx: 0, dy: 3), with: .color(lip))
        c.fill(ball, with: .color(body))
        var tiles = c
        tiles.clip(to: ball)
        let shades: [Color] = [light, mid, body, .white, mid, lip, body]
        for (j, y) in stride(from: CGFloat(21), to: 84, by: 9).enumerated() {
            for (i, x) in stride(from: CGFloat(19), to: 82, by: 9).enumerated() {
                tiles.fill(A.rr(x + 0.8, y + 0.8, 7.4, 7.4, 1.5), with: .color(shades[(i * 3 + j * 5) % 7]))
            }
        }
        c.stroke(ball, with: .color(lip), lineWidth: 2)
        c.fill(A.rr(30, 30, 10, 5, 2.5), with: .color(shine))
        sparkle(c, x: 82, y: 22, r: 8, color: light)
        sparkle(c, x: 16, y: 78, r: 5, color: body)
        sparkle(c, x: 88, y: 70, r: 4, color: light)
    }

    // MARK: Deep house: a sleepy crescent moon

    static func moon(_ c: GraphicsContext) {
        let disc = A.dot(48, 48, 34)
        let bite = Path(ellipseIn: CGRect(x: 40, y: 6, width: 54, height: 58))
        let crescent = disc.subtracting(bite)
        chunky(c, crescent)
        c.fill(A.rr(20, 40, 4, 14, 2), with: .color(shine))
        var eye = Path()
        eye.move(to: CGPoint(x: 28, y: 58))
        eye.addQuadCurve(to: CGPoint(x: 40, y: 58), control: CGPoint(x: 34, y: 63))
        c.stroke(eye, with: .color(ink), style: StrokeStyle(lineWidth: 3.2, lineCap: .round))
        var smile = Path()
        smile.move(to: CGPoint(x: 35, y: 70))
        smile.addQuadCurve(to: CGPoint(x: 46, y: 69), control: CGPoint(x: 41, y: 74))
        c.stroke(smile, with: .color(ink), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        c.fill(A.dot(29, 66, 3.6), with: .color(A.cheek.opacity(0.8)))
        sparkle(c, x: 70, y: 30, r: 8, color: light)
        sparkle(c, x: 84, y: 48, r: 5, color: body)
        sparkle(c, x: 60, y: 16, r: 4, color: light)
    }

    // MARK: Tech house: a rotary knob, turned up

    static func knob(_ c: GraphicsContext) {
        let cx: CGFloat = 50, cy: CGFloat = 52
        func at(_ deg: Double, _ r: CGFloat, _ y: CGFloat = 52) -> CGPoint {
            let a = deg * .pi / 180
            return CGPoint(x: cx + r * CGFloat(cos(a)), y: y + r * CGFloat(sin(a)))
        }
        // Scale ticks, lit up to the pointer
        for i in 0...10 {
            let deg = 135 + Double(i) * 27
            let major = i % 5 == 0
            line(c, [at(deg, major ? 38 : 39), at(deg, major ? 44 : 42)], i > 7 ? lip : body, major ? 3 : 2.4)
        }
        let cap = A.dot(cx, cy, 32)
        chunky(c, cap)
        c.fill(A.dot(cx, cy + 3, 23), with: .color(ink))
        c.fill(A.dot(cx, cy - 1, 23), with: .color(mid))
        // Grip ridges
        for i in 0..<16 {
            let deg = Double(i) * 22.5
            line(c, [at(deg, 20, cy - 1), at(deg, 23, cy - 1)], body, 2)
        }
        line(c, [CGPoint(x: cx, y: cy - 1), at(135 + 7 * 27, 15, cy - 1)], .white, 5)
        c.fill(A.rr(30, 28, 10, 4, 2), with: .color(shine))
    }

    // MARK: Techno: a robot head

    static func robot(_ c: GraphicsContext) {
        line(c, [CGPoint(x: 50, y: 8), CGPoint(x: 50, y: 22)], ink, 3)
        c.fill(A.dot(50, 8, 5), with: .color(light))
        // Ears
        c.fill(A.rr(10, 44, 8, 18, 3), with: .color(lip))
        c.fill(A.rr(82, 44, 8, 18, 3), with: .color(lip))
        chunky(c, A.rr(16, 22, 68, 62, 16))
        c.fill(A.rr(22, 27, 16, 4, 2), with: .color(shine))
        // Visor and eyes
        c.fill(A.rr(24, 34, 52, 30, 9), with: .color(ink))
        for x: CGFloat in [38, 62] {
            c.fill(A.dot(x, 47, 6), with: .color(light))
            c.fill(A.dot(x + 1.5, 45.5, 2), with: .color(.white))
        }
        // Grille mouth
        for i in 0..<4 {
            c.fill(A.rr(36 + CGFloat(i) * 7.5, 70, 5, 7, 1.5), with: .color(light))
        }
    }

    // MARK: UK garage: a boombox

    static func boombox(_ c: GraphicsContext) {
        var handle = Path()
        handle.move(to: CGPoint(x: 30, y: 40))
        handle.addLine(to: CGPoint(x: 30, y: 26))
        handle.addQuadCurve(to: CGPoint(x: 36, y: 20), control: CGPoint(x: 30, y: 20))
        handle.addLine(to: CGPoint(x: 64, y: 20))
        handle.addQuadCurve(to: CGPoint(x: 70, y: 26), control: CGPoint(x: 70, y: 20))
        handle.addLine(to: CGPoint(x: 70, y: 40))
        c.stroke(handle, with: .color(ink), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
        chunky(c, A.rr(10, 36, 80, 48, 14))
        c.fill(A.rr(18, 41, 18, 4, 2), with: .color(shine))
        for x: CGFloat in [31, 69] {
            c.fill(A.dot(x, 64, 14), with: .color(ink))
            c.fill(A.dot(x, 64, 9), with: .color(mid))
            c.fill(A.dot(x, 64, 4), with: .color(light))
        }
        // Tape deck and buttons
        c.fill(A.rr(44, 42, 12, 8, 2), with: .color(pale))
        c.fill(A.rr(46, 54, 8, 4, 2), with: .color(lip))
        c.fill(A.rr(46, 61, 8, 4, 2), with: .color(lip))
        sparkle(c, x: 86, y: 24, r: 6, color: light)
        sparkle(c, x: 14, y: 22, r: 4, color: body)
    }
}

#Preview {
    HStack(spacing: 10) {
        ForEach(Genre.allCases) { GenreBadge(genre: $0, size: 64) }
    }
    .padding()
}
