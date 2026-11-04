//
//  GenreIcon.swift
//  Groova
//
//  One cartoon object per genre, drawn in Woofer's style: flat colour, a chunky darker lip
//  underneath, a soft highlight and dark ink details. Drawn in a 100 × 100 space.
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

/// The icon on a soft tile of the genre's colour.
struct GenreBadge: View {
    let genre: Genre
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .fill(genre.color.mix(with: .white, by: 0.78))
            GenreIcon(genre: genre, size: size * 0.84)
        }
        .frame(width: size, height: size)
    }
}

enum GenreArt {
    typealias A = WooferArt
    static let ink = Color(hex: 0x262833)
    static let cream = Color(hex: 0xFFF3DE)
    static let gold = Color(hex: 0xFFD166)
    static let shine = Color.white.opacity(0.4)

    static func draw(_ c: GraphicsContext, _ g: Genre) {
        // Ground shadow
        c.fill(Path(ellipseIn: CGRect(x: 22, y: 88, width: 56, height: 8)), with: .color(.black.opacity(0.08)))
        switch g {
        case .house: house(c)
        case .deepHouse: moon(c)
        case .techno: bolt(c)
        case .techHouse: conga(c)
        case .ukGarage: boombox(c)
        }
    }

    /// Fill a shape with a chunky lip underneath, like Groova's buttons.
    static func chunky(_ c: GraphicsContext, _ p: Path, _ fill: Color, _ lip: Color, depth: CGFloat = 4,
                       round: CGFloat = 0) {
        let style = StrokeStyle(lineWidth: round, lineCap: .round, lineJoin: .round)
        let low = p.offsetBy(dx: 0, dy: depth)
        c.fill(low, with: .color(lip))
        if round > 0 { c.stroke(low, with: .color(lip), style: style) }
        c.fill(p, with: .color(fill))
        if round > 0 { c.stroke(p, with: .color(fill), style: style) }
    }

    // MARK: House: a little house with a record for a window

    static func house(_ c: GraphicsContext) {
        let wall = Color(hex: 0xFFB23E), wallLip = Color(hex: 0xD98A1C)
        c.fill(A.rr(64, 20, 10, 20, 3), with: .color(wallLip))
        chunky(c, A.rr(22, 44, 56, 42, 8), wall, wallLip)
        var roof = Path()
        roof.move(to: CGPoint(x: 16, y: 50))
        roof.addLine(to: CGPoint(x: 50, y: 18))
        roof.addLine(to: CGPoint(x: 84, y: 50))
        roof.closeSubpath()
        chunky(c, roof, A.body, A.lip, round: 8)
        c.fill(A.rr(36, 30, 12, 4, 2), with: .color(shine))
        // Record window
        c.fill(A.dot(38, 65, 11), with: .color(ink))
        c.stroke(A.dot(38, 65, 7.5), with: .color(.white.opacity(0.18)), lineWidth: 1.2)
        c.fill(A.dot(38, 65, 3.8), with: .color(gold))
        // Door
        c.fill(A.rr(56, 60, 15, 26, 6), with: .color(cream))
        c.fill(A.dot(66, 74, 1.8), with: .color(wallLip))
        c.fill(A.rr(27, 54, 4, 10, 2), with: .color(shine))
    }

    // MARK: Deep house: a sleepy moon

    static func moon(_ c: GraphicsContext) {
        let teal = Color(hex: 0x4FD8C8), tealLip = Color(hex: 0x2FAE9F)
        let disc = Path(ellipseIn: CGRect(x: 14, y: 14, width: 68, height: 68))
        let bite = Path(ellipseIn: CGRect(x: 40, y: 6, width: 54, height: 58))
        let crescent = disc.subtracting(bite)
        chunky(c, crescent, teal, tealLip)
        c.fill(A.rr(22, 40, 4, 12, 2), with: .color(shine))
        // Closed, sleepy eye and a little smile
        var eye = Path()
        eye.move(to: CGPoint(x: 30, y: 52))
        eye.addQuadCurve(to: CGPoint(x: 42, y: 52), control: CGPoint(x: 36, y: 57))
        c.stroke(eye, with: .color(ink), style: StrokeStyle(lineWidth: 3.2, lineCap: .round))
        var smile = Path()
        smile.move(to: CGPoint(x: 36, y: 64))
        smile.addQuadCurve(to: CGPoint(x: 46, y: 62), control: CGPoint(x: 42, y: 68))
        c.stroke(smile, with: .color(ink), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        c.fill(A.dot(30, 60, 3.6), with: .color(A.cheek.opacity(0.8)))
        sparkle(c, x: 72, y: 30, r: 8, color: gold)
        sparkle(c, x: 84, y: 54, r: 5, color: .white)
        sparkle(c, x: 62, y: 16, r: 4, color: gold)
    }

    static func sparkle(_ c: GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat, color: Color) {
        var p = Path()
        p.move(to: CGPoint(x: x, y: y - r))
        p.addQuadCurve(to: CGPoint(x: x + r, y: y), control: CGPoint(x: x + r * 0.15, y: y - r * 0.15))
        p.addQuadCurve(to: CGPoint(x: x, y: y + r), control: CGPoint(x: x + r * 0.15, y: y + r * 0.15))
        p.addQuadCurve(to: CGPoint(x: x - r, y: y), control: CGPoint(x: x - r * 0.15, y: y + r * 0.15))
        p.addQuadCurve(to: CGPoint(x: x, y: y - r), control: CGPoint(x: x - r * 0.15, y: y - r * 0.15))
        if color == .white {
            c.fill(p.offsetBy(dx: 0, dy: 1.5), with: .color(Color(hex: 0x2FAE9F).opacity(0.5)))
        }
        c.fill(p, with: .color(color))
    }

    // MARK: Techno: a chunky lightning bolt

    static func bolt(_ c: GraphicsContext) {
        let red = Color(hex: 0xFF4D63), redLip = Color(hex: 0xC92F45)
        var p = Path()
        p.move(to: CGPoint(x: 58, y: 10))
        p.addLine(to: CGPoint(x: 26, y: 54))
        p.addLine(to: CGPoint(x: 46, y: 54))
        p.addLine(to: CGPoint(x: 38, y: 86))
        p.addLine(to: CGPoint(x: 74, y: 40))
        p.addLine(to: CGPoint(x: 54, y: 40))
        p.addLine(to: CGPoint(x: 62, y: 10))
        p.closeSubpath()
        chunky(c, p, red, redLip, depth: 5, round: 7)
        var hl = Path()
        hl.move(to: CGPoint(x: 53, y: 20))
        hl.addLine(to: CGPoint(x: 40, y: 40))
        c.stroke(hl, with: .color(shine), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        // Sparks
        let spark = StrokeStyle(lineWidth: 3.5, lineCap: .round)
        for (a, b) in [((80, 22), (88, 16)), ((84, 34), (93, 34)), ((14, 66), (6, 72)), ((18, 78), (10, 84))] {
            var s = Path()
            s.move(to: CGPoint(x: a.0, y: a.1)); s.addLine(to: CGPoint(x: b.0, y: b.1))
            c.stroke(s, with: .color(ink), style: spark)
        }
    }

    // MARK: Tech house: a conga drum

    static func conga(_ c: GraphicsContext) {
        let lime = Color(hex: 0xB5E32A), limeLip = Color(hex: 0x86AE12)
        var barrel = Path()
        barrel.move(to: CGPoint(x: 28, y: 30))
        barrel.addCurve(to: CGPoint(x: 36, y: 86), control1: CGPoint(x: 22, y: 52), control2: CGPoint(x: 26, y: 72))
        barrel.addLine(to: CGPoint(x: 64, y: 86))
        barrel.addCurve(to: CGPoint(x: 72, y: 30), control1: CGPoint(x: 74, y: 72), control2: CGPoint(x: 78, y: 52))
        barrel.closeSubpath()
        chunky(c, barrel, lime, limeLip, round: 4)
        // Bands
        c.fill(A.rr(25, 50, 50, 6, 3), with: .color(limeLip))
        c.fill(A.rr(29, 72, 42, 6, 3), with: .color(limeLip))
        c.fill(A.rr(32, 36, 4, 12, 2), with: .color(shine))
        // Drum head
        c.fill(Path(ellipseIn: CGRect(x: 24, y: 23, width: 52, height: 17)), with: .color(Color(hex: 0x5E7A0C)))
        c.fill(Path(ellipseIn: CGRect(x: 27, y: 22, width: 46, height: 13)), with: .color(cream))
        // Sound waves
        let wave = StrokeStyle(lineWidth: 3.5, lineCap: .round)
        for (x, d) in [(14.0, -1.0), (86.0, 1.0)] as [(CGFloat, CGFloat)] {
            var w = Path()
            w.move(to: CGPoint(x: x, y: 12))
            w.addQuadCurve(to: CGPoint(x: x, y: 28), control: CGPoint(x: x + d * 6, y: 20))
            c.stroke(w, with: .color(ink), style: wave)
        }
    }

    // MARK: UK garage: a boombox

    static func boombox(_ c: GraphicsContext) {
        let pink = Color(hex: 0xFF6AD5), pinkLip = Color(hex: 0xD645AE)
        var handle = Path()
        handle.move(to: CGPoint(x: 30, y: 40))
        handle.addLine(to: CGPoint(x: 30, y: 26))
        handle.addQuadCurve(to: CGPoint(x: 36, y: 20), control: CGPoint(x: 30, y: 20))
        handle.addLine(to: CGPoint(x: 64, y: 20))
        handle.addQuadCurve(to: CGPoint(x: 70, y: 26), control: CGPoint(x: 70, y: 20))
        handle.addLine(to: CGPoint(x: 70, y: 40))
        c.stroke(handle, with: .color(ink), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
        chunky(c, A.rr(10, 36, 80, 48, 14), pink, pinkLip)
        c.fill(A.rr(18, 41, 18, 4, 2), with: .color(shine))
        for x: CGFloat in [31, 69] {
            c.fill(A.dot(x, 64, 14), with: .color(ink))
            c.fill(A.dot(x, 64, 9), with: .color(Color(hex: 0x3A3D4A)))
            c.fill(A.dot(x, 64, 4), with: .color(Color(hex: 0xFFB3EC)))
        }
        c.fill(A.rr(44, 42, 12, 8, 2), with: .color(cream))
        c.fill(A.rr(46, 54, 8, 4, 2), with: .color(pinkLip))
        c.fill(A.rr(46, 61, 8, 4, 2), with: .color(pinkLip))
        A.note(c, x: 84, y: 26, color: A.body, scale: 0.55)
    }
}

#Preview {
    HStack(spacing: 10) {
        ForEach(Genre.allCases) { GenreBadge(genre: $0, size: 64) }
    }
    .padding()
}
