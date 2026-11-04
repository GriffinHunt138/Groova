//
//  Theme.swift
//  Groova
//
//  Light, flat, chunky. One brand color, grays, and green/red that only ever
//  mean right/wrong. Depth comes from a darker "lip" under pressable things,
//  never from glows or gradients.
//

import Foundation
import SwiftUI

enum Theme {
    // Brand
    static let brand = Color(hex: 0x7B5CFA)
    static let brandLip = Color(hex: 0x5A3FD6)
    static let brandSoft = Color(hex: 0xF1EDFF)
    static let brandBorder = Color(hex: 0xCFC4FF)

    // Neutrals
    static let background = Color.white
    static let surface = Color.white               // cards (with a border)
    static let surfaceRaised = Color(hex: 0xF2F2F5) // chips, idle cells
    static let surfaceHigh = Color(hex: 0xE5E5EB)   // tracks, locked nodes
    static let lockedLip = Color(hex: 0xCFCFD8)
    static let stroke = Color(hex: 0xE5E5EA)
    static let divider = Color(hex: 0xECECF1)
    static let text = Color(hex: 0x262833)
    static let textSecondary = Color(hex: 0x6E7180)
    static let textTertiary = Color(hex: 0xA3A6B2)
    static let onBrand = Color.white

    // Meaning
    static let success = Color(hex: 0x3CC37A)
    static let successLip = Color(hex: 0x2B9B5F)
    static let successInk = Color(hex: 0x1F7A4A)
    static let successSoft = Color(hex: 0xDDF6E8)
    static let miss = Color(hex: 0xFF4B4B)
    static let missLip = Color(hex: 0xD93636)
    static let missInk = Color(hex: 0xB42828)
    static let missSoft = Color(hex: 0xFFE3E3)

    // Rewards only
    static let gold = Color(hex: 0xFFB800)
    static let streak = Color(hex: 0xFF9600)
    static let bronze = Color(hex: 0xCD7F32)
    static let silver = Color(hex: 0xA8B0BD)

    static let radius: CGFloat = 18
    static let smallRadius: CGFloat = 12
    static let border: CGFloat = 2

    /// Instruments share the brand color; rows are labelled, so color isn't needed to tell them apart.
    static func color(for track: DrumTrack) -> Color { brand }
    static let bassColor = brand

    static func lip(for color: Color) -> Color {
        if color == brand { return brandLip }
        if color == success { return successLip }
        if color == miss { return missLip }
        return color.mix(with: .black, by: 0.22)
    }
}

extension Font {
    static func display(_ size: CGFloat, weight: Font.Weight = .black) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func label(_ size: CGFloat = 15, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func mono(_ size: CGFloat = 13, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded).monospacedDigit()
    }
}

// MARK: - Accent environment

extension EnvironmentValues {
    /// The current accent (the brand color).
    @Entry var accent: Color = Color(hex: 0x7B5CFA)
}
