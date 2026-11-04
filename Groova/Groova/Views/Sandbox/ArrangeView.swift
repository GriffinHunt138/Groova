//
//  ArrangeView.swift
//  Groova
//
//  Turn the loop into a song. Each column is a section, each row a part of the loop.
//  Tap squares to bring parts in and out; tap a section's name to rename, resize or move it.
//

import Foundation
import SwiftUI

struct ArrangeView: View {
    @Binding var jam: Jam
    let playFrom: (Int) -> Void

    private var transport: Transport { Transport.shared }
    private let columnWidth: CGFloat = 72
    private let headerHeight: CGFloat = 54
    private let rowHeight: CGFloat = 48

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Each column is a section of your song. Tap a square to bring a part in or out.")
                    .font(.label(14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: 10) {
                    laneLabels
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 8) {
                                ForEach(Array(jam.sections.enumerated()), id: \.element.id) { i, section in
                                    column(i, section).id(section.id)
                                }
                                addButton
                            }
                            .padding(.vertical, 2)
                            .padding(.trailing, 4)
                        }
                        .onChange(of: transport.section) { _, s in
                            guard transport.isPlaying(.jamSong), s >= 0, s < jam.sections.count else { return }
                            withAnimation { proxy.scrollTo(jam.sections[s].id, anchor: .center) }
                        }
                    }
                }
                .card(padding: 14)
                Text("Tap a section's name to rename it, change its length, move it or play from there.")
                    .font(.label(13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    private var laneLabels: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear.frame(height: headerHeight + 8)
            ForEach(JamLane.allCases) { lane in
                HStack(spacing: 6) {
                    Image(systemName: lane.symbol)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Theme.lip(for: lane.part.color))
                        .frame(width: 26, height: 26)
                        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(lane.part.color.mix(with: .white, by: 0.78)))
                    Text(lane.name).font(.label(13, weight: .heavy)).foregroundStyle(Theme.text)
                        .lineLimit(1).minimumScaleFactor(0.8)
                }
                .frame(width: 78, height: rowHeight, alignment: .leading)
                .opacity(jam[lane.part].muted ? 0.4 : 1)
            }
        }
    }

    private func column(_ i: Int, _ section: JamSection) -> some View {
        let live = transport.isPlaying(.jamSong) && transport.section == i
        return VStack(spacing: 0) {
            Menu {
                Button { playFrom(i) } label: { Label("Play from here", systemImage: "play.fill") }
                Picker("Name", selection: binding(i, \.name)) {
                    ForEach(JamSection.names, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                Picker("Length", selection: binding(i, \.bars)) {
                    ForEach(JamSection.lengths, id: \.self) { Text("\($0) bars").tag($0) }
                }
                .pickerStyle(.menu)
                Section {
                    if i > 0 {
                        Button { move(i, by: -1) } label: { Label("Move left", systemImage: "arrow.left") }
                    }
                    if i < jam.sections.count - 1 {
                        Button { move(i, by: 1) } label: { Label("Move right", systemImage: "arrow.right") }
                    }
                    if jam.sections.count < Jam.maxSections {
                        Button { duplicate(i) } label: { Label("Duplicate", systemImage: "plus.square.on.square") }
                    }
                    if jam.sections.count > 1 {
                        Button(role: .destructive) { delete(i) } label: { Label("Delete", systemImage: "trash") }
                    }
                }
            } label: {
                VStack(spacing: 2) {
                    Text(section.name).font(.label(14, weight: .heavy))
                        .foregroundStyle(live ? Theme.onBrand : Theme.text)
                        .lineLimit(1).minimumScaleFactor(0.8)
                    Text("\(section.bars) bars").font(.label(11, weight: .bold))
                        .foregroundStyle(live ? Theme.onBrand.opacity(0.85) : Theme.textTertiary)
                }
                .frame(width: columnWidth, height: headerHeight)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(live ? Theme.brand : Theme.surfaceRaised))
            }
            .accessibilityLabel("\(section.name), \(section.bars) bars. Section options")
            .padding(.bottom, 8)
            ForEach(JamLane.allCases) { lane in
                let on = section.plays(lane)
                Button {
                    Haptics.tap()
                    toggle(i, lane)
                } label: {
                    ArrangeCell(on: on, isPlaying: live, mark: nil)
                        .frame(width: columnWidth)
                        .opacity(jam[lane.part].muted && on ? 0.45 : 1)
                }
                .buttonStyle(PressScaleStyle(scale: 0.94))
                .frame(height: rowHeight)
                .accessibilityLabel("\(lane.name) in \(section.name)")
                .accessibilityValue(on ? "On" : "Off")
            }
        }
    }

    private var addButton: some View {
        Button {
            Haptics.tap()
            addSection()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: "plus").font(.system(size: 18, weight: .black))
                Text("Section").font(.label(12, weight: .heavy))
            }
            .foregroundStyle(Theme.textSecondary)
            .frame(width: 64, height: headerHeight)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.stroke, style: StrokeStyle(lineWidth: 2, dash: [5, 4])))
        }
        .buttonStyle(PressScaleStyle())
        .disabled(jam.sections.count >= Jam.maxSections)
        .opacity(jam.sections.count >= Jam.maxSections ? 0.4 : 1)
        .accessibilityLabel("Add a section")
    }

    // MARK: Editing

    private func binding<T>(_ i: Int, _ key: WritableKeyPath<JamSection, T>) -> Binding<T> {
        Binding(get: { jam.sections[min(i, jam.sections.count - 1)][keyPath: key] },
                set: { v in
                    guard i < jam.sections.count else { return }
                    jam.sections[i][keyPath: key] = v
                    Haptics.select()
                })
    }

    private func toggle(_ i: Int, _ lane: JamLane) {
        guard i < jam.sections.count else { return }
        var lanes = jam.sections[i].lanes
        while lanes.count < JamLane.allCases.count { lanes.append(false) }
        lanes[lane.rawValue].toggle()
        jam.sections[i].lanes = lanes
    }

    private func move(_ i: Int, by d: Int) {
        let j = i + d
        guard jam.sections.indices.contains(i), jam.sections.indices.contains(j) else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { jam.sections.swapAt(i, j) }
        Haptics.select()
    }

    private func duplicate(_ i: Int) {
        guard jam.sections.indices.contains(i) else { return }
        var copy = jam.sections[i]
        copy.id = UUID()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { jam.sections.insert(copy, at: i + 1) }
    }

    private func delete(_ i: Int) {
        guard jam.sections.indices.contains(i), jam.sections.count > 1 else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { _ = jam.sections.remove(at: i) }
        Haptics.soft()
    }

    private func addSection() {
        guard jam.sections.count < Jam.maxSections else { return }
        let lanes = [Bool](repeating: true, count: JamLane.allCases.count)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            jam.sections.append(JamSection(name: "Drop", bars: 8, lanes: lanes))
        }
    }
}
