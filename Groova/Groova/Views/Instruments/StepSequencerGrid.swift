//
//  StepSequencerGrid.swift
//  Groova
//
//  A 16-step drum sequencer. Tap to toggle, drag across a row to paint.
//  A playhead sweeps the grid in time with the audio.
//

import Foundation
import SwiftUI

struct GridMetrics {
    static let gap: CGFloat = 3
    static let groupGap: CGFloat = 8

    let width: CGFloat
    var cell: CGFloat { (width - 12 * Self.gap - 3 * Self.groupGap) / 16 }

    func x(_ i: Int) -> CGFloat {
        CGFloat(i) * cell + CGFloat(i - i / 4) * Self.gap + CGFloat(i / 4) * Self.groupGap
    }

    func index(at px: CGFloat) -> Int {
        var idx = 0
        for i in 0..<16 where x(i) <= px { idx = i }
        return idx
    }
}

struct StepSequencerGrid: View {
    @Binding var pattern: Pattern
    let tracks: [DrumTrack]
    let editable: Set<DrumTrack>
    var playhead: Int
    var marks: [DrumTrack: [Int: CellMark]] = [:]
    var swing: Double = 0
    var beatGuide = true
    var kit: DrumKit
    /// Optional solo/mute controls (mastery challenge).
    var muted: Binding<Set<DrumTrack>>? = nil
    var soloed: Binding<Instrument?>? = nil
    var rowAccuracy: [DrumTrack: Double] = [:]

    var body: some View {
        VStack(spacing: 14) {
            StepNumbers(playhead: playhead, beatGuide: beatGuide)
            ForEach(tracks) { track in
                VStack(spacing: 6) {
                    header(track)
                    SequencerRow(cells: Binding(get: { pattern[track] }, set: { pattern[track] = $0 }),
                                 color: Theme.color(for: track),
                                 isEditable: editable.contains(track),
                                 playhead: playhead,
                                 marks: marks[track] ?? [:],
                                 swing: swing,
                                 beatGuide: beatGuide,
                                 dimmed: isSilenced(track),
                                 onActivate: {
                                     if !Transport.shared.isRunning { AudioEngine.shared.trigger(track, kit: kit) }
                                 })
                }
            }
        }
    }

    private func isSilenced(_ t: DrumTrack) -> Bool {
        if let s = soloed?.wrappedValue { return s != .drum(t) }
        return muted?.wrappedValue.contains(t) ?? false
    }

    @ViewBuilder
    private func header(_ track: DrumTrack) -> some View {
        let color = Theme.color(for: track)
        HStack(spacing: 8) {
            Button {
                Haptics.tap()
                AudioEngine.shared.trigger(track, kit: kit)
            } label: {
                HStack(spacing: 6) {
                    Text(track.name)
                        .font(.label(16, weight: .heavy))
                        .foregroundStyle(Theme.text)
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            .buttonStyle(PressScaleStyle())

            if !editable.contains(track) {
                Image(systemName: "lock.fill").font(.system(size: 10)).foregroundStyle(Theme.textTertiary)
            }
            if let acc = rowAccuracy[track] {
                Text("\(Int((acc * 100).rounded()))%")
                    .font(.mono(12, weight: .bold))
                    .foregroundStyle(acc >= 0.999 ? Theme.successInk : Theme.missInk)
                    .transition(.scale.combined(with: .opacity))
            }
            Spacer()
            if let soloed, let muted {
                SmallToggle(title: "S", on: soloed.wrappedValue == .drum(track), color: Theme.brand) {
                    soloed.wrappedValue = soloed.wrappedValue == .drum(track) ? nil : .drum(track)
                }
                SmallToggle(title: "M", on: muted.wrappedValue.contains(track), color: Theme.text) {
                    if muted.wrappedValue.contains(track) { muted.wrappedValue.remove(track) }
                    else { muted.wrappedValue.insert(track) }
                }
            }
        }
    }
}

struct SmallToggle: View {
    let title: String
    let on: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.select()
            action()
        } label: {
            Text(title)
                .font(.label(12, weight: .heavy))
                .foregroundStyle(on ? Theme.onBrand : Theme.textSecondary)
                .frame(width: 30, height: 26)
                .background(RoundedRectangle(cornerRadius: 8).fill(on ? color : Theme.surfaceRaised)
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(on ? .clear : Theme.stroke, lineWidth: Theme.border)))
        }
        .buttonStyle(PressScaleStyle())
    }
}

struct StepNumbers: View {
    var playhead: Int
    var beatGuide: Bool

    var body: some View {
        GeometryReader { geo in
            let m = GridMetrics(width: geo.size.width)
            ForEach(0..<16, id: \.self) { i in
                let isBeat = i % 4 == 0
                Text("\(i + 1)")
                    .font(.mono(isBeat ? 12 : 10, weight: isBeat ? .black : .semibold))
                    .foregroundStyle(i == playhead ? Theme.brand : (isBeat && beatGuide ? Theme.textSecondary : Theme.textTertiary))
                    .frame(width: m.cell)
                    .position(x: m.x(i) + m.cell / 2, y: 7)
            }
        }
        .frame(height: 14)
    }
}

struct SequencerRow: View {
    @Binding var cells: [Bool]
    let color: Color
    let isEditable: Bool
    let playhead: Int
    let marks: [Int: CellMark]
    let swing: Double
    let beatGuide: Bool
    var dimmed = false
    var onActivate: () -> Void

    @State private var paintValue: Bool?
    @State private var lastIndex = -1

    var body: some View {
        GeometryReader { geo in
            let m = GridMetrics(width: geo.size.width)
            ZStack(alignment: .topLeading) {
                ForEach(0..<16, id: \.self) { i in
                    StepCell(on: cells[i], color: color, isBeat: beatGuide && i % 4 == 0,
                             isPlayhead: i == playhead, mark: marks[i], locked: !isEditable)
                        .frame(width: m.cell, height: geo.size.height)
                        .offset(x: m.x(i) + (i % 2 == 1 ? swing * m.cell * 0.9 : 0))
                }
            }
            // Offsets don't affect layout, so pin the ZStack to the full row or only the first cell is tappable.
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        guard isEditable else { return }
                        let i = min(15, max(0, m.index(at: g.location.x)))
                        if paintValue == nil { paintValue = !cells[i] }
                        guard let paint = paintValue, i != lastIndex || cells[i] != paint else { return }
                        lastIndex = i
                        if cells[i] != paint {
                            cells[i] = paint
                            Haptics.tap()
                            if paint { onActivate() }
                        }
                    }
                    .onEnded { g in
                        // Inside a ScrollView a quick tap can end without ever calling onChanged,
                        // so treat a gesture that changed nothing as a single tap.
                        if isEditable, lastIndex == -1 {
                            let i = min(15, max(0, m.index(at: g.location.x)))
                            cells[i].toggle()
                            Haptics.tap()
                            if cells[i] { onActivate() }
                        }
                        paintValue = nil
                        lastIndex = -1
                    }
            )
        }
        .frame(height: 54)
        .opacity(dimmed ? 0.35 : 1)
        .animation(.easeOut(duration: 0.2), value: dimmed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: swing)
    }
}

struct StepCell: View {
    let on: Bool
    let color: Color
    let isBeat: Bool
    let isPlayhead: Bool
    let mark: CellMark?
    let locked: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 9, style: .continuous)
        let lipColor: Color = mark == .extra ? Theme.missLip : (mark == .correct ? Theme.successLip : Theme.lip(for: color))
        let fillColor: Color = mark == .extra ? Theme.miss : (mark == .correct ? Theme.success : color)
        ZStack {
            if on {
                shape.fill(lipColor).offset(y: 4)
                shape.fill(fillColor)
                    .brightness(isPlayhead ? 0.12 : 0)
            } else {
                shape.fill(isPlayhead ? Theme.brandSoft : (isBeat ? Theme.surfaceRaised : Theme.surface))
                shape.strokeBorder(isPlayhead ? Theme.brandBorder : Theme.stroke, lineWidth: Theme.border)
            }
            if mark == .missed {
                // A hit that should be here: soft green with a dashed outline.
                shape.fill(Theme.successSoft)
                shape.strokeBorder(Theme.successLip, style: StrokeStyle(lineWidth: 2.5, dash: [5, 3]))
            }
        }
        .padding(.bottom, 4)
        .opacity(locked ? 0.55 : 1)
        .offset(y: isPlayhead && on ? 2 : 0)
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: on)
        .animation(.easeOut(duration: 0.06), value: isPlayhead)
    }
}
