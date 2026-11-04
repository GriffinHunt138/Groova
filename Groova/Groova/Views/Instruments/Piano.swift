//
//  Piano.swift
//  Groova
//
//  A playable touchscreen keyboard and a drag-to-draw piano roll.
//

import Foundation
import SwiftUI

// MARK: - Keyboard

struct PianoKeyboard: View {
    let low: Int
    let high: Int
    var highlighted: Set<Int> = []
    var target: Int? = nil
    var color: Color
    var onPress: (Int) -> Void

    @State private var down = Set<Int>()

    private var whites: [Int] { (low...high).filter { !NoteName.isBlack($0) } }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width / CGFloat(whites.count)
            let h = geo.size.height
            ZStack(alignment: .topLeading) {
                ForEach(Array(whites.enumerated()), id: \.element) { i, note in
                    key(note, black: false)
                        .frame(width: w - 3, height: h)
                        .offset(x: CGFloat(i) * w)
                }
                ForEach(Array(whites.enumerated()), id: \.element) { i, note in
                    let black = note + 1
                    if black <= high, NoteName.isBlack(black) {
                        key(black, black: true)
                            .frame(width: w * 0.62, height: h * 0.6)
                            .offset(x: CGFloat(i + 1) * w - w * 0.31 - 1.5)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func key(_ note: Int, black: Bool) -> some View {
        let isDown = down.contains(note)
        let isLit = highlighted.contains(note)
        let isTarget = target == note
        let shape = UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10, style: .continuous)
        ZStack(alignment: .bottom) {
            shape.fill(black ? Color.black : Theme.stroke).offset(y: isDown ? 1 : 5)
            shape.fill(fill(black: black, down: isDown, lit: isLit))
                .overlay(shape.strokeBorder(black ? .clear : Theme.stroke, lineWidth: Theme.border))
                .offset(y: isDown ? 4 : 0)
            if isTarget && !isDown {
                shape.strokeBorder(color, lineWidth: 3)
                    .phaseAnimator([0.4, 1]) { v, p in v.opacity(p) } animation: { _ in .easeInOut(duration: 0.6) }
            }
            if !black {
                Text(NoteName.name(note))
                    .font(.label(12, weight: .bold))
                    .foregroundStyle(isDown || isLit ? Theme.onBrand : Theme.textTertiary)
                    .padding(.bottom, 10)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !down.contains(note) else { return }
                    down.insert(note)
                    Haptics.tap()
                    onPress(note)
                }
                .onEnded { _ in down.remove(note) }
        )
        .zIndex(black ? 1 : 0)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(NoteName.name(note, octave: true))
    }

    private func fill(black: Bool, down: Bool, lit: Bool) -> Color {
        if down { return color }
        if lit { return color.opacity(0.7) }
        return black ? Theme.text : Theme.surface
    }
}

// MARK: - Piano roll

/// Which chord is playing over each step, lined up with the piano roll columns.
struct ChordStrip: View {
    let chords: [ChordEvent]
    var playhead: Int = -1

    var body: some View {
        HStack(spacing: 6) {
            Text("Chord")
                .font(.label(11, weight: .heavy))
                .foregroundStyle(Theme.textTertiary)
                .frame(width: PianoRollGrid.keyWidth)
            GeometryReader { geo in
                let m = GridMetrics(width: geo.size.width)
                ZStack(alignment: .topLeading) {
                    ForEach(Array(chords.enumerated()), id: \.offset) { _, ch in
                        let last = min(15, ch.step + max(1, ch.length) - 1)
                        let lit = playhead >= ch.step && playhead <= last
                        Text(ChordShape.name(for: ch.pitches) ?? "Chord")
                            .font(.label(13, weight: .heavy))
                            .foregroundStyle(lit ? Theme.onBrand : Theme.brand)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(width: m.x(last) + m.cell - m.x(ch.step), height: 30)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(lit ? Theme.brand : Theme.brandSoft))
                            .offset(x: m.x(ch.step))
                    }
                }
            }
            .frame(height: 30)
        }
        .accessibilityElement(children: .combine)
    }
}

struct PianoRollGrid: View {
    @Binding var notes: [NoteEvent]
    let rows: [Int]                       // high -> low
    var playhead: Int
    var color: Color = Theme.bassColor
    var patch: SynthPatch
    var correct: Set<UUID> = []
    var wrong: Set<UUID> = []
    var ghosts: [NoteEvent] = []          // revealed reference notes (dashed)
    var editable = true

    private enum Drag {
        case drawing(UUID, Int)
        case moving(UUID, grab: Int, moved: Bool)
    }
    @State private var drag: Drag?

    static let rowHeight: CGFloat = 42
    static let keyWidth: CGFloat = 38

    var body: some View {
        HStack(spacing: 6) {
            VStack(spacing: 4) {
                ForEach(rows, id: \.self) { pitch in
                    Button {
                        Haptics.tap()
                        AudioEngine.shared.playNote(pitch, seconds: 0.3, patch: patch)
                    } label: {
                        Text(NoteName.name(pitch))
                            .font(.label(13, weight: .heavy))
                            .foregroundStyle(pitch % 12 == rows.last.map { $0 % 12 } ? Theme.onBrand : Theme.text)
                            .frame(width: Self.keyWidth, height: Self.rowHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(pitch % 12 == rows.last.map { $0 % 12 } ? color : Theme.surfaceHigh)
                            )
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
            GeometryReader { geo in
                let m = GridMetrics(width: geo.size.width)
                ZStack(alignment: .topLeading) {
                    // background cells
                    ForEach(Array(rows.enumerated()), id: \.offset) { r, _ in
                        ForEach(0..<16, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(i == playhead ? Theme.brandSoft
                                      : (i % 4 == 0 ? Theme.surfaceRaised : Theme.surface))
                                .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .strokeBorder(i == playhead ? Theme.brandBorder : Theme.stroke, lineWidth: 1.5))
                                .frame(width: m.cell, height: Self.rowHeight)
                                .offset(x: m.x(i), y: y(r))
                        }
                    }
                    ForEach(ghosts) { g in
                        if let r = rows.firstIndex(of: g.pitch) {
                            noteShape(g, m)
                                .stroke(color, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                                .frame(width: width(g, m), height: Self.rowHeight - 6)
                                .offset(x: m.x(g.step), y: y(r) + 3)
                        }
                    }
                    ForEach(notes) { n in
                        if let r = rows.firstIndex(of: n.pitch) {
                            let lit = playhead >= n.step && playhead < n.endStep
                            let fillC: Color = wrong.contains(n.id) ? Theme.miss : (correct.contains(n.id) ? Theme.success : color)
                            noteShape(n, m)
                                .fill(fillC)
                                .background(noteShape(n, m).fill(Theme.lip(for: fillC)).offset(y: 3))
                                .brightness(lit ? 0.12 : 0)
                                .frame(width: width(n, m), height: Self.rowHeight - 6)
                                .offset(x: m.x(n.step), y: y(r) + 3)
                                .animation(.spring(response: 0.2, dampingFraction: 0.75), value: n.step)
                                .animation(.spring(response: 0.2, dampingFraction: 0.75), value: n.length)
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                .contentShape(Rectangle())
                .gesture(editable ? gesture(m) : nil)
            }
            .frame(height: CGFloat(rows.count) * (Self.rowHeight + 4) - 4)
        }
    }

    private func y(_ row: Int) -> CGFloat { CGFloat(row) * (Self.rowHeight + 4) }

    private func noteShape(_ n: NoteEvent, _ m: GridMetrics) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
    }

    private func width(_ n: NoteEvent, _ m: GridMetrics) -> CGFloat {
        m.x(n.endStep - 1) + m.cell - m.x(n.step)
    }

    private func cellAt(_ p: CGPoint, _ m: GridMetrics) -> (row: Int, step: Int) {
        let row = min(rows.count - 1, max(0, Int(p.y / (Self.rowHeight + 4))))
        return (row, min(15, max(0, m.index(at: p.x))))
    }

    private func gesture(_ m: GridMetrics) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { g in
                let (row, step) = cellAt(g.location, m)
                let pitch = rows[row]
                switch drag {
                case nil:
                    if let hit = notes.first(where: { $0.pitch == pitch && $0.covers(step) }) {
                        drag = .moving(hit.id, grab: step - hit.step, moved: false)
                    } else {
                        var n = NoteEvent(step, pitch, 1)
                        n.id = UUID()
                        notes = placing(n)
                        drag = .drawing(n.id, step)
                        AudioEngine.shared.playNote(pitch, seconds: 0.25, patch: patch)
                        Haptics.tap()
                    }
                case let .drawing(id, start)?:
                    guard var n = notes.first(where: { $0.id == id }) else { return }
                    let len = max(1, step - start + 1)
                    if len != n.length {
                        n.length = len
                        notes = placing(n)
                        Haptics.select()
                    }
                case let .moving(id, grab, moved)?:
                    guard var n = notes.first(where: { $0.id == id }) else { return }
                    let newStep = min(16 - n.length, max(0, step - grab))
                    if newStep != n.step || pitch != n.pitch {
                        let pitchChanged = pitch != n.pitch
                        n.step = newStep
                        n.pitch = pitch
                        notes = placing(n)
                        drag = .moving(id, grab: grab, moved: true)
                        Haptics.select()
                        if pitchChanged { AudioEngine.shared.playNote(pitch, seconds: 0.2, patch: patch) }
                    } else if !moved, abs(g.translation.width) > 8 || abs(g.translation.height) > 8 {
                        drag = .moving(id, grab: grab, moved: true)
                    }
                }
            }
            .onEnded { g in
                if drag == nil {
                    // A quick tap in a ScrollView can skip onChanged entirely.
                    let (row, step) = cellAt(g.location, m)
                    let pitch = rows[row]
                    if let hit = notes.first(where: { $0.pitch == pitch && $0.covers(step) }) {
                        notes.removeAll { $0.id == hit.id }
                        Haptics.soft()
                    } else {
                        var n = NoteEvent(step, pitch, 1)
                        n.id = UUID()
                        notes = placing(n)
                        AudioEngine.shared.playNote(pitch, seconds: 0.25, patch: patch)
                        Haptics.tap()
                    }
                }
                if case let .moving(id, _, moved)? = drag, !moved {
                    notes.removeAll { $0.id == id }
                    Haptics.soft()
                }
                drag = nil
            }
    }

    private func placing(_ n: NoteEvent) -> [NoteEvent] {
        var p = Pattern()
        p.bass = notes
        p.placeBassNote(n)
        return p.bass
    }
}
