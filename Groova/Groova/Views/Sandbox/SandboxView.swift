//
//  SandboxView.swift
//  Groova
//
//  Free play. Build an 8-bar loop from five tracks, tap into any track to write notes and
//  shape its sound, then arrange the loop into a song. Everything saves on its own.
//

import Foundation
import SwiftUI

struct SandboxView: View {
    enum Mode: String, CaseIterable { case loop = "Loop", arrange = "Arrange" }

    @Environment(JamStore.self) private var store
    @State private var jam: Jam
    @State private var mode: Mode = .loop
    @State private var path: [JamPart] = []
    @State private var showLibrary = false
    @State private var showTempo = false
    @State private var renaming = false
    @State private var nameDraft = ""
    @State private var pendingGenre: Genre?
    @State private var toast: String?

    private var transport: Transport { Transport.shared }
    private var genre: Genre { jam.genre }
    private var isSaved: Bool { store.contains(jam.id) }

    init(genre: Genre) {
        _jam = State(initialValue: Jam.starter(genre))
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                ModeSwitch(selection: $mode)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                switch mode {
                case .loop: loopList
                case .arrange:
                    ArrangeView(jam: $jam) { section in playSong(from: section) }
                }
            }
            .background(Theme.background)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                JamTransportBar(jam: jam, arranged: mode == .arrange, showTempo: $showTempo)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: JamPart.self) { part in
                TrackEditorView(jam: $jam, part: part, showTempo: $showTempo)
            }
        }
        .overlay(alignment: .top) { toastView }
        .tint(Theme.brand)
        .environment(\.accent, Theme.brand)
        .onAppear { AudioEngine.shared.resetEffects() }
        .onDisappear { if transport.isRunning { transport.stop() } }
        .onChange(of: jam) { old, new in
            transport.liveUpdate(jam: new.song(arranged: transport.isPlaying(.jamSong)))
            if old.swing != new.swing { AudioEngine.shared.update(swing: new.swing) }
            if old.bpm != new.bpm, transport.isPlaying(.jamLoop) || transport.isPlaying(.jamSong) {
                restart(arranged: transport.isPlaying(.jamSong))
            }
        }
        .onChange(of: mode) { _, m in
            if transport.isPlaying(.jamLoop) || transport.isPlaying(.jamSong) { restart(arranged: m == .arrange) }
        }
        .task(id: jam) {
            // Autosave once there's something worth keeping.
            try? await Task.sleep(for: .seconds(0.8))
            guard !Task.isCancelled else { return }
            if isSaved || !jam.isUntouched { store.save(jam) }
        }
        .sheet(isPresented: $showLibrary) {
            JamLibraryView(current: jam.id) { loaded in
                load(loaded)
                showLibrary = false
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(Theme.background)
            .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showTempo) {
            TempoSheet(jam: $jam)
                .presentationDetents([.height(330)])
                .presentationBackground(Theme.background)
                .presentationCornerRadius(32)
        }
        .alert("Name your jam", isPresented: $renaming) {
            TextField("Jam name", text: $nameDraft)
            Button("Save") {
                let name = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty { jam.name = String(name.prefix(40)) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Start a new jam?", isPresented: Binding(
            get: { pendingGenre != nil }, set: { if !$0 { pendingGenre = nil } }), titleVisibility: .visible) {
            if let g = pendingGenre {
                Button("Start from a \(g.name) groove") { start(Jam.starter(g)) }
                Button("Start from scratch") { start(Jam.empty(g)) }
            }
            Button("Cancel", role: .cancel) { pendingGenre = nil }
        } message: {
            Text("Your current jam is saved in your library.")
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                GenreBadge(genre: genre, size: 44)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Sandbox").font(.label(13, weight: .black)).tracking(0.6).textCase(.uppercase)
                        .foregroundStyle(Theme.textTertiary)
                    Button {
                        nameDraft = jam.name
                        renaming = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(jam.name).font(.display(20)).foregroundStyle(Theme.text).lineLimit(1)
                            Image(systemName: "pencil").font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .buttonStyle(PressScaleStyle())
                    .accessibilityLabel("Rename \(jam.name)")
                }
                Spacer(minLength: 6)
                Menu {
                    ForEach(Genre.allCases) { g in
                        Button { pendingGenre = g } label: { Label("New \(g.name) jam", systemImage: g.symbol) }
                    }
                } label: {
                    Image(systemName: "plus").font(.system(size: 16, weight: .black))
                        .foregroundStyle(Theme.text)
                        .frame(width: 42, height: 42)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface)
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Theme.stroke, lineWidth: Theme.border)))
                }
                .accessibilityLabel("New jam")
                Button { Haptics.tap(); showLibrary = true } label: {
                    Image(systemName: "books.vertical.fill").font(.system(size: 15, weight: .black))
                        .foregroundStyle(Theme.text)
                        .frame(width: 42, height: 38)
                }
                .buttonStyle(LipStyle(fill: Theme.surface, lip: Theme.stroke, border: Theme.stroke, radius: 14, depth: 3))
                .accessibilityLabel("Your jams")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            Rectangle().fill(Theme.divider).frame(height: Theme.border)
        }
    }

    // MARK: Loop

    private var loopList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(JamPart.allCases) { part in
                    TrackRow(track: jam[part], genre: genre,
                             onOpen: { Haptics.tap(); path.append(part) },
                             onMute: { jam[part].muted.toggle() })
                }
                Text("Tap a track to write its notes and shape its sound.")
                    .font(.label(13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private var toastView: some View {
        if let toast {
            Text(toast)
                .font(.label(15, weight: .heavy))
                .foregroundStyle(Theme.onBrand)
                .padding(.horizontal, 18).frame(height: 46)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.text))
                .padding(.top, 70)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: Actions

    private func restart(arranged: Bool) {
        if arranged { playSong(from: 0) } else {
            transport.play(jam: jam.song(arranged: false), source: .jamLoop, bpm: jam.bpm, swing: jam.swing)
        }
    }

    private func playSong(from section: Int) {
        let song = jam.song(arranged: true)
        transport.play(jam: song, source: .jamSong, bpm: jam.bpm, swing: jam.swing, from: song.start(of: section))
    }

    private func start(_ j: Jam) {
        if transport.isRunning { transport.stop() }
        jam = j
        path = []
        mode = .loop
        pendingGenre = nil
    }

    private func load(_ j: Jam) {
        if transport.isRunning { transport.stop() }
        jam = j
        path = []
        show("Opened \(j.name)")
    }

    private func show(_ text: String) {
        withAnimation { toast = text }
        Task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation { toast = nil }
        }
    }
}

// MARK: - Shared pieces

/// A chunky two- or three-way switch.
struct ModeSwitch<Value: Hashable & RawRepresentable>: View where Value.RawValue == String, Value: CaseIterable,
                                                                  Value.AllCases: RandomAccessCollection {
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(Value.allCases), id: \.self) { v in
                let on = v == selection
                Button {
                    guard !on else { return }
                    Haptics.select()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selection = v }
                } label: {
                    Text(v.rawValue)
                        .font(.label(15, weight: .heavy))
                        .foregroundStyle(on ? Theme.text : Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background {
                            if on {
                                RoundedRectangle(cornerRadius: 11, style: .continuous).fill(Theme.surface)
                                    .shadow(color: .black.opacity(0.08), radius: 0, y: 2)
                            }
                        }
                }
                .buttonStyle(PressScaleStyle(scale: 0.97))
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surfaceHigh))
    }
}

/// A track's icon on a soft tile of its colour.
struct PartTile: View {
    let part: JamPart
    var size: CGFloat = 48

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(part.color.mix(with: .white, by: 0.78))
            .overlay(
                Image(systemName: part.symbol)
                    .font(.system(size: size * 0.42, weight: .black))
                    .foregroundStyle(Theme.lip(for: part.color))
            )
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// One track on the Loop screen: what it is, what it plays across the 8 bars, and a mute.
struct TrackRow: View {
    let track: JamTrack
    let genre: Genre
    let onOpen: () -> Void
    let onMute: () -> Void

    private var transport: Transport { Transport.shared }

    var body: some View {
        let playing = transport.isPlaying(.jamLoop) || transport.isPlaying(.jamSong)
        let head = playing && transport.bar >= 0 ? transport.bar * Pattern.steps + max(0, transport.step) : -1
        HStack(spacing: 12) {
            Button(action: onOpen) {
                HStack(spacing: 14) {
                    PartTile(part: track.part, size: 48)
                    VStack(alignment: .leading, spacing: 7) {
                        HStack(spacing: 6) {
                            Text(track.part.name).font(.label(17, weight: .heavy)).foregroundStyle(Theme.text)
                            Text(track.part.presets[min(track.preset, track.part.presets.count - 1)])
                                .font(.label(13, weight: .bold)).foregroundStyle(Theme.textTertiary)
                            Spacer(minLength: 0)
                        }
                        if track.isEmpty {
                            Text("Empty. Tap to add notes")
                                .font(.label(13, weight: .semibold)).foregroundStyle(Theme.textTertiary)
                                .frame(height: 16)
                        } else {
                            ActivityStrip(activity: track.activity, playhead: head)
                                .frame(height: 16)
                                .opacity(track.muted ? 0.35 : 1)
                        }
                    }
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .black))
                        .foregroundStyle(Theme.textTertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressScaleStyle(scale: 0.98))
            .accessibilityLabel("\(track.part.name), \(track.part.presets[min(track.preset, track.part.presets.count - 1)])")
            .accessibilityHint("Opens the track")

            Button { Haptics.select(); onMute() } label: {
                Image(systemName: track.muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(track.muted ? Theme.onBrand : Theme.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(track.muted ? Theme.text : Theme.surfaceRaised))
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(PressScaleStyle())
            .accessibilityLabel(track.muted ? "Unmute \(track.part.name)" : "Mute \(track.part.name)")
        }
        .card(padding: 14)
    }
}

/// The whole 8-bar loop in a thin strip: a tick wherever the track plays.
struct ActivityStrip: View {
    let activity: [Bool]
    var playhead: Int = -1

    var body: some View {
        Canvas { ctx, size in
            let bars = Jam.loopBars
            let gap: CGFloat = 4
            let barW = (size.width - gap * CGFloat(bars - 1)) / CGFloat(bars)
            let stepW = barW / CGFloat(Pattern.steps)
            for b in 0..<bars {
                let x = CGFloat(b) * (barW + gap)
                let rect = CGRect(x: x, y: 0, width: barW, height: size.height)
                ctx.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(Theme.surfaceRaised))
                for s in 0..<Pattern.steps {
                    let i = b * Pattern.steps + s
                    guard i < activity.count, activity[i] else { continue }
                    let r = CGRect(x: x + CGFloat(s) * stepW + 0.5, y: 3, width: max(1.5, stepW - 1), height: size.height - 6)
                    ctx.fill(Path(roundedRect: r, cornerRadius: 1.5),
                             with: .color(i == playhead ? Theme.brandLip : Theme.brand))
                }
                if playhead >= 0 && playhead / Pattern.steps == b {
                    let px = x + CGFloat(playhead % Pattern.steps) * stepW
                    ctx.fill(Path(roundedRect: CGRect(x: px, y: 0, width: 2, height: size.height), cornerRadius: 1),
                             with: .color(Theme.text))
                }
            }
        }
        .accessibilityHidden(true)
    }
}

/// Play and stop, where you are, and the tempo. Pinned to the bottom of every Sandbox screen.
struct JamTransportBar: View {
    let jam: Jam
    let arranged: Bool
    @Binding var showTempo: Bool

    private var transport: Transport { Transport.shared }
    private var playing: Bool { transport.isPlaying(arranged ? .jamSong : .jamLoop) }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Theme.divider).frame(height: Theme.border)
            HStack(spacing: 14) {
                Button {
                    Haptics.tap()
                    if transport.isPlaying(.jamLoop) || transport.isPlaying(.jamSong) {
                        transport.stop()
                    } else {
                        transport.play(jam: jam.song(arranged: arranged), source: arranged ? .jamSong : .jamLoop,
                                       bpm: jam.bpm, swing: jam.swing)
                    }
                } label: {
                    Image(systemName: playing ? "stop.fill" : "play.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Theme.onBrand)
                        .frame(width: 56, height: 52)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(LipStyle(fill: Theme.brand, lip: Theme.brandLip, radius: 18, depth: 4))
                .accessibilityLabel(playing ? "Stop" : (arranged ? "Play song" : "Play loop"))

                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.label(16, weight: .heavy)).foregroundStyle(Theme.text).lineLimit(1)
                        .contentTransition(.numericText())
                    if arranged {
                        Text(subtitle).font(.label(12, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                    } else {
                        BarDots(current: playing ? transport.bar : -1)
                    }
                }
                Spacer(minLength: 4)
                Button { Haptics.tap(); showTempo = true } label: {
                    VStack(spacing: 0) {
                        Text("\(Int(jam.bpm))").font(.display(18)).monospacedDigit().foregroundStyle(Theme.text)
                        Text("BPM").font(.label(10, weight: .black)).tracking(0.6).foregroundStyle(Theme.textTertiary)
                    }
                    .frame(width: 58, height: 46)
                }
                .buttonStyle(LipStyle(fill: Theme.surface, lip: Theme.stroke, border: Theme.stroke, radius: 14, depth: 3))
                .accessibilityLabel("Tempo, \(Int(jam.bpm)) BPM")
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
        .background(Theme.background)
    }

    private var title: String {
        if arranged {
            if playing, transport.section >= 0, transport.section < jam.sections.count {
                return jam.sections[transport.section].name
            }
            return "Play your song"
        }
        return playing && transport.bar >= 0 ? "Bar \(transport.bar + 1) of \(Jam.loopBars)" : "Play the loop"
    }

    private var subtitle: String {
        let secs = Int(jam.songSeconds.rounded())
        let length = "\(jam.songBars) bars · \(secs / 60):\(String(format: "%02ld", secs % 60))"
        if playing, transport.section >= 0 { return "Section \(transport.section + 1) of \(jam.sections.count) · \(length)" }
        return length
    }
}

/// Eight little dots, one per bar of the loop.
struct BarDots: View {
    let current: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<Jam.loopBars, id: \.self) { b in
                Capsule()
                    .fill(b == current ? Theme.brand : Theme.surfaceHigh)
                    .frame(width: b == current ? 16 : 8, height: 8)
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: current)
        .accessibilityHidden(true)
    }
}

/// Tempo and swing.
struct TempoSheet: View {
    @Binding var jam: Jam

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Tempo & swing").font(.display(22)).foregroundStyle(Theme.text)
            HStack(spacing: 16) {
                stepper("minus") { setBPM(jam.bpm - 1) }
                VStack(spacing: 0) {
                    Text("\(Int(jam.bpm))").font(.display(40)).monospacedDigit().foregroundStyle(Theme.text)
                        .contentTransition(.numericText())
                    Text("BPM").font(.label(12, weight: .black)).tracking(0.6).foregroundStyle(Theme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                stepper("plus") { setBPM(jam.bpm + 1) }
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Swing").font(.label(16, weight: .bold)).foregroundStyle(Theme.text)
                    Spacer()
                    Text("\(Int(jam.swing * 200))%").font(.mono(15, weight: .bold)).foregroundStyle(Theme.brand)
                }
                Slider(value: $jam.swing, in: 0...0.45, onEditingChanged: { if !$0 { Haptics.select() } })
                Text("Swing pushes every other 16th late, for a shuffle.")
                    .font(.label(13, weight: .medium)).foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }

    private func stepper(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button { Haptics.select(); action() } label: {
            Image(systemName: symbol).font(.system(size: 18, weight: .black))
                .foregroundStyle(Theme.text)
                .frame(width: 56, height: 52)
        }
        .buttonStyle(LipStyle(fill: Theme.surface, lip: Theme.stroke, border: Theme.stroke, radius: 16, depth: 4))
        .accessibilityLabel(symbol == "plus" ? "Faster" : "Slower")
    }

    private func setBPM(_ value: Double) {
        jam.bpm = min(Studio.bpmRange.upperBound, max(Studio.bpmRange.lowerBound, value.rounded()))
    }
}

// MARK: - Library

struct JamLibraryView: View {
    let current: UUID
    let onLoad: (Jam) -> Void

    @Environment(JamStore.self) private var store
    @State private var deleting: Jam?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Your jams").font(.display(24)).foregroundStyle(Theme.text)
                Spacer()
                Text("\(store.jams.count) saved").font(.label(14, weight: .bold)).foregroundStyle(Theme.textTertiary)
            }
            .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 14)
            if store.jams.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 40, weight: .bold)).foregroundStyle(Theme.surfaceHigh)
                    Text("Nothing saved yet").font(.display(19)).foregroundStyle(Theme.text)
                    Text("Change anything in a jam and it saves here by itself.")
                        .font(.label(14, weight: .medium)).foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                .padding(.horizontal, 32)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.jams) { j in row(j) }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .confirmationDialog("Delete this jam?", isPresented: Binding(
            get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let d = deleting { store.delete(d.id) }
                deleting = nil
            }
            Button("Cancel", role: .cancel) { deleting = nil }
        } message: {
            Text("This can't be undone.")
        }
    }

    private func row(_ j: Jam) -> some View {
        HStack(spacing: 14) {
            Button { Haptics.tap(); onLoad(j) } label: {
                HStack(spacing: 14) {
                    GenreBadge(genre: j.genre, size: 44)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(j.name).font(.label(16, weight: .heavy)).foregroundStyle(Theme.text).lineLimit(1)
                            if j.id == current {
                                Text("OPEN").font(.label(10, weight: .black)).tracking(0.5)
                                    .foregroundStyle(Theme.brand)
                                    .padding(.horizontal, 6).frame(height: 18)
                                    .background(Capsule().fill(Theme.brandSoft))
                            }
                        }
                        Text("\(j.genre.name) · \(Int(j.bpm)) BPM · \(j.updated.formatted(.relative(presentation: .named)))")
                            .font(.label(13, weight: .medium)).foregroundStyle(Theme.textSecondary).lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressScaleStyle(scale: 0.98))
            Button { Haptics.tap(); deleting = j } label: {
                Image(systemName: "trash").font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Delete \(j.name)")
        }
        .card(padding: 14)
    }
}
