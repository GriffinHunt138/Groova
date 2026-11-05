//
//  GenreIcon.swift
//  Groova
//
//  One object per genre, the gear that genre is built on, drawn in Groova purple with a chunky
//  darker lip underneath and a soft highlight: House a turntable, Deep House keys, Techno a
//  drum machine, Tech House a bass speaker, UK Garage an MC's mic. Drawn in a 100 × 100 space.
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
        case .house: turntable(c)
        case .deepHouse: keys(c)
        case .techno: drumMachine(c)
        case .techHouse: speaker(c)
        case .ukGarage: microphone(c)
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

    // MARK: House: a turntable, where house music was born

    static func turntable(_ c: GraphicsContext) {
        chunky(c, A.rr(8, 30, 84, 54, 12))
        c.fill(A.rr(14, 35, 20, 4, 2), with: .color(shine))
        // Record
        c.fill(A.dot(42, 58, 21), with: .color(ink))
        ring(c, 42, 58, 15, .white.opacity(0.16), 1.2)
        ring(c, 42, 58, 10, .white.opacity(0.16), 1.2)
        c.fill(A.dot(42, 58, 6.5), with: .color(light))
        c.fill(A.dot(42, 58, 1.6), with: .color(ink))
        // Tonearm
        c.fill(A.dot(77, 40, 5.5), with: .color(light))
        c.fill(A.dot(77, 40, 2), with: .color(lip))
        line(c, [CGPoint(x: 77, y: 40), CGPoint(x: 74, y: 58), CGPoint(x: 62, y: 66)], light, 4)
        let head = A.rr(57, 63, 8, 6, 2).applying(
            CGAffineTransform(translationX: 61, y: 66).rotated(by: .pi / 6).translatedBy(x: -61, y: -66))
        c.fill(head, with: .color(.white))
        // Knobs
        c.fill(A.dot(72, 75, 3), with: .color(light))
        c.fill(A.dot(81, 75, 3), with: .color(light))
    }

    // MARK: Deep house: late-night keys for lush chords

    static func keys(_ c: GraphicsContext) {
        chunky(c, A.rr(6, 42, 88, 40, 10))
        c.fill(A.rr(12, 46, 18, 4, 2), with: .color(shine))
        c.fill(A.rr(12, 54, 76, 22, 4), with: .color(.white))
        let key: CGFloat = 76 / 6
        for i in 1..<6 {
            c.fill(A.rr(12 + CGFloat(i) * key - 0.75, 54, 1.5, 22, 0.75), with: .color(light))
        }
        for i in [1, 2, 4, 5] {
            c.fill(A.rr(12 + CGFloat(i) * key - 4, 54, 8, 13, 2), with: .color(ink))
        }
        // Moon
        let disc = A.dot(72, 20, 13)
        let moon = disc.subtracting(A.dot(80, 12, 12))
        c.fill(moon.offsetBy(dx: 0, dy: 3), with: .color(lip))
        c.fill(moon, with: .color(light))
        sparkle(c, x: 30, y: 22, r: 7, color: body)
        sparkle(c, x: 45, y: 12, r: 4, color: light)
    }

    // MARK: Techno: a drum machine

    static func drumMachine(_ c: GraphicsContext) {
        chunky(c, A.rr(8, 18, 84, 68, 12))
        c.fill(A.rr(14, 23, 18, 4, 2), with: .color(shine))
        // Screen with a waveform
        c.fill(A.rr(16, 28, 34, 12, 3), with: .color(ink))
        line(c, [CGPoint(x: 20, y: 34), CGPoint(x: 25, y: 31), CGPoint(x: 30, y: 37),
                 CGPoint(x: 35, y: 31), CGPoint(x: 40, y: 35), CGPoint(x: 45, y: 33)], light, 1.8)
        for x: CGFloat in [60, 71, 82] {
            c.fill(A.dot(x, 34, 4.5), with: .color(ink))
            c.fill(A.dot(x, 32.5, 1.3), with: .color(light))
        }
        // Pads, some lit
        for (row, y) in [CGFloat(48), 65].enumerated() {
            for i in 0..<4 {
                let x = 16 + CGFloat(i) * 18
                let lit = row == 0 ? (i == 0 || i == 2) : (i == 1 || i == 3)
                c.fill(A.rr(x, y + 2.5, 14, 13, 3), with: .color(lit ? glow : lip))
                c.fill(A.rr(x, y, 14, 13, 3), with: .color(lit ? pale : mid))
            }
        }
    }

    // MARK: Tech house: a speaker pushing out bass

    static func speaker(_ c: GraphicsContext) {
        chunky(c, A.rr(16, 10, 68, 76, 13))
        c.fill(A.rr(22, 15, 18, 4, 2), with: .color(shine))
        c.fill(A.dot(50, 29, 8), with: .color(ink))
        c.fill(A.dot(50, 29, 3.5), with: .color(light))
        c.fill(A.dot(50, 60, 22), with: .color(ink))
        ring(c, 50, 60, 16, lip, 3)
        c.fill(A.dot(50, 60, 10), with: .color(mid))
        c.fill(A.dot(50, 60, 4), with: .color(light))
        // Sound waves
        let wave = StrokeStyle(lineWidth: 3.5, lineCap: .round)
        for (x, d, y0, y1, color) in [(10.0, -7.0, 48.0, 72.0, body), (5.0, -9.0, 42.0, 78.0, light),
                                      (90.0, 7.0, 48.0, 72.0, body), (95.0, 9.0, 42.0, 78.0, light)]
            as [(CGFloat, CGFloat, CGFloat, CGFloat, Color)] {
            var w = Path()
            w.move(to: CGPoint(x: x, y: y0))
            w.addQuadCurve(to: CGPoint(x: x, y: y1), control: CGPoint(x: x + d, y: (y0 + y1) / 2))
            c.stroke(w, with: .color(color), style: wave)
        }
    }

    // MARK: UK garage: an MC's microphone

    static func microphone(_ c: GraphicsContext) {
        var handle = Path()
        handle.move(to: CGPoint(x: 40, y: 50))
        handle.addLine(to: CGPoint(x: 60, y: 50))
        handle.addLine(to: CGPoint(x: 55, y: 82))
        handle.addQuadCurve(to: CGPoint(x: 45, y: 82), control: CGPoint(x: 50, y: 86))
        handle.closeSubpath()
        chunky(c, handle)
        c.fill(A.rr(44, 56, 3, 18, 1.5), with: .color(shine))
        // Collar
        c.fill(A.rr(33, 44, 34, 9, 4), with: .color(lip))
        c.fill(A.rr(33, 42, 34, 8, 4), with: .color(light))
        // Grille
        let head = A.dot(50, 27, 19)
        c.fill(head.offsetBy(dx: 0, dy: 3), with: .color(lip))
        c.fill(head, with: .color(body))
        var mesh = c
        mesh.clip(to: head)
        for y: CGFloat in [18, 24, 30, 36] { line(mesh, [CGPoint(x: 30, y: y), CGPoint(x: 70, y: y)], lip, 1.6) }
        for x: CGFloat in [42, 50, 58] { line(mesh, [CGPoint(x: x, y: 8), CGPoint(x: x, y: 46)], lip, 1.6) }
        c.stroke(head, with: .color(body), lineWidth: 3)
        c.fill(A.rr(38, 14, 8, 4, 2), with: .color(shine))
        sparkle(c, x: 80, y: 22, r: 7, color: light)
        sparkle(c, x: 20, y: 40, r: 4, color: body)
    }
}

#Preview {
    HStack(spacing: 10) {
        ForEach(Genre.allCases) { GenreBadge(genre: $0, size: 64) }
    }
    .padding()
}
