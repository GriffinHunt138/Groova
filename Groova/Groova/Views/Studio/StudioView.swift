//
//  StudioView.swift
//  Groova
//
//  A free sandbox: drums, bass, chords and a mix, with no grading. Loops save to the Sketchbook.
//

import Foundation
import SwiftUI

struct StudioView: View {
    let homeGenre: Genre

    @Environment(SketchStore.self) private var store
    @State private var sketch: Sketch
    @State private var savedVersion: Sketch?
    @State private var brush = 0
    @State private var muted: Set<DrumTrack> = []
    @State private var soloed: Instrument?
    @State private var bassMuted = false
    @State private var chordsMuted = false
    @State private var showBook = false
    @State private var renaming = false
    @State private var nameDraft = ""
    @State private var pendingGenre: Genre?
    @State private var toast: String?

    private var transport: Transport { Transport.shared }
    private var genre: Genre { sketch.genre }
    private var playing: Bool { transport.isPlaying(.user) }
    private var playhead: Int { playing ? transport.step : -1 }
    private var isDirty: Bool { savedVersion.map { $0 != sketch } ?? !sketch.isEmpty }

    init(genre: Genre) {
        homeGenre = genre
        _sketch = State(initialValue: Sketch.fresh(genre))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(spacing: 18) {
                        titleRow
                        transportCard
                        drumsCard
                        bassCard
                        chordsCard
                        mixCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                }
            }
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
        .environment(\.accent, genre.color)
        .tint(genre.color)
        .onChange(of: sketch.pattern) { _, _ in transport.liveUpdate(sketch.playable) }
        .onChange(of: sketch.chordCells) { _, _ in transport.liveUpdate(sketch.playable) }
        .onChange(of: sketch.swing) { _, v in if playing { AudioEngine.shared.update(swing: v) } }
        .onChange(of: muted) { _, _ in applyMutes() }
        .onChange(of: soloed) { _, _ in applyMutes() }
        .onChange(of: bassMuted) { _, _ in applyMutes() }
        .onChange(of: chordsMuted) { _, _ in applyMutes() }
        .onDisappear {
            if playing { transport.stop() }
            AudioEngine.shared.resetEffects()
        }
        .sheet(isPresented: $showBook) {
            SketchbookView(current: sketch.id) { loaded in
                load(loaded)
                showBook = false
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(Theme.background)
            .presentationCornerRadius(32)
        }
        .alert("Name your loop", isPresented: $renaming) {
            TextField("Loop name", text: $nameDraft)
            Button("Save") {
                let name = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty { sketch.name = String(name.prefix(40)) }
                save()
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Start a new loop?", isPresented: Binding(
            get: { pendingGenre != nil }, set: { if !$0 { pendingGenre = nil } }), titleVisibility: .visible) {
            if let g = pendingGenre {
                Button("Start from the \(g.name) groove") { start(Sketch.fresh(g)) }
                Button("Start from an empty grid") { start(Sketch.empty(g)) }
            }
            Button("Cancel", role: .cancel) { pendingGenre = nil }
        } message: {
            Text(isDirty ? "Your current loop has unsaved changes." : "Pick a starting point.")
        }
    }

    // MARK: Header

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("Studio").font(.display(24)).foregroundStyle(Theme.text)
                Spacer()
                Menu {
                    ForEach(Genre.allCases) { g in
                        Button { pendingGenre = g } label: { Label("New \(g.name) loop", systemImage: g.symbol) }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus").font(.system(size: 13, weight: .black))
                        Text("New").font(.label(15, weight: .heavy))
                    }
                    .foregroundStyle(Theme.text)
                    .padding(.horizontal, 12).frame(height: 40)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Theme.stroke, lineWidth: Theme.border)))
                }
                Button { Haptics.tap(); showBook = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "books.vertical.fill").font(.system(size: 14, weight: .black))
                        if !store.sketches.isEmpty {
                            Text("\(store.sketches.count)").font(.label(15, weight: .heavy)).monospacedDigit()
                        }
                    }
                    .foregroundStyle(Theme.text)
                    .padding(.horizontal, 12).frame(height: 40)
                }
                .buttonStyle(LipStyle(fill: Theme.surface, lip: Theme.stroke, border: Theme.stroke, radius: 14, depth: 3))
                .accessibilityLabel("Sketchbook")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            Rectangle().fill(Theme.divider).frame(height: Theme.border)
        }
        .background(Theme.background)
    }

    private var titleRow: some View {
        HStack(spacing: 12) {
            GenreBadge(genre: genre, size: 48)
            VStack(alignment: .leading, spacing: 2) {
                Button {
                    nameDraft = sketch.name == "Untitled loop" ? "" : sketch.name
                    renaming = true
                } label: {
                    HStack(spacing: 6) {
                        Text(sketch.name).font(.display(20)).foregroundStyle(Theme.text).lineLimit(1)
                        Image(systemName: "pencil").font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
                .buttonStyle(PressScaleStyle())
                Text(isDirty ? "\(genre.name) · unsaved" : "\(genre.name) · saved")
                    .font(.label(13, weight: .semibold))
                    .foregroundStyle(isDirty ? Theme.textSecondary : Theme.successInk)
            }
            Spacer(minLength: 8)
            Button("Save") {
                if sketch.name == "Untitled loop" && !store.contains(sketch.id) {
                    nameDraft = ""
                    renaming = true
                } else {
                    save()
                }
            }
            .buttonStyle(ChunkyButtonStyle(color: genre.color, height: 42, enabled: isDirty))
            .frame(width: 96)
            .disabled(!isDirty)
        }
    }

    // MARK: Transport

    private var transportCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                TransportButton(title: playing ? "Stop" : "Play", symbol: playing ? "stop.fill" : "play.fill",
                                active: playing, color: genre.color) {
                    playing ? transport.stop() : play()
                }
                Spacer(minLength: 0)
                stepperButton("minus") { setBPM(sketch.bpm - 1) }
                VStack(spacing: 0) {
                    Text("\(Int(sketch.bpm))").font(.display(22)).monospacedDigit()
                        .foregroundStyle(Theme.text)
                        .contentTransition(.numericText())
                    Text("BPM").font(.label(11, weight: .black)).tracking(0.6).foregroundStyle(Theme.textTertiary)
                }
                .frame(width: 56)
                stepperButton("plus") { setBPM(sketch.bpm + 1) }
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Swing").font(.label(15, weight: .bold)).foregroundStyle(Theme.text)
                    Spacer()
                    Text("\(Int(sketch.swing * 200))%").font(.mono(14, weight: .bold)).foregroundStyle(genre.color)
                }
                Slider(value: $sketch.swing, in: 0...0.45, onEditingChanged: { if !$0 { Haptics.select() } })
            }
        }
        .card()
    }

    private func stepperButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button { Haptics.select(); action() } label: {
            Image(systemName: symbol).font(.system(size: 15, weight: .black))
                .foregroundStyle(Theme.text)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(LipStyle(fill: Theme.surface, lip: Theme.stroke, border: Theme.stroke, radius: 12, depth: 3))
    }

    // MARK: Sections

    private func sectionHeader(_ title: String, symbol: String, onClear: @escaping () -> Void,
                               @ViewBuilder trailing: () -> some View) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).font(.system(size: 15, weight: .black)).foregroundStyle(genre.color)
            Text(title.uppercased()).font(.label(14, weight: .black)).tracking(0.6).foregroundStyle(Theme.text)
            Spacer()
            trailing()
            Button("Clear") { Haptics.tap(); withAnimation { onClear() } }
                .font(.label(13, weight: .heavy))
                .foregroundStyle(Theme.textTertiary)
                .padding(.leading, 6)
        }
    }

    private var drumsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Drums", symbol: "square.grid.4x3.fill", onClear: {
                let bass = sketch.pattern.bass
                sketch.pattern = Pattern()
                sketch.pattern.bass = bass
            }) {
                EmptyView()
            }
            StepSequencerGrid(pattern: $sketch.pattern, tracks: DrumTrack.allCases,
                              editable: Set(DrumTrack.allCases), playhead: playhead,
                              swing: sketch.swing, beatGuide: true, kit: genre.kit,
                              muted: $muted, soloed: $soloed)
        }
        .card()
    }

    private var bassCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Bass", symbol: "waveform.path", onClear: { sketch.pattern.bass = [] }) {
                SmallToggle(title: "S", on: soloed == .bass, color: Theme.brand) {
                    soloed = soloed == .bass ? nil : .bass
                }
                SmallToggle(title: "M", on: bassMuted, color: Theme.text) { bassMuted.toggle() }
            }
            PianoRollGrid(notes: $sketch.pattern.bass, rows: Studio.bassRows(genre), playhead: playhead,
                          patch: genre.kit.bass)
                .opacity(isSilenced(.bass) ? 0.4 : 1)
        }
        .card()
    }

    private var chordsCard: some View {
        let palette = Studio.palette(genre)
        return VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Chords", symbol: "pianokeys",
                          onClear: { sketch.chordCells = Array(repeating: nil, count: Pattern.steps) }) {
                SmallToggle(title: "S", on: soloed == .chords, color: Theme.brand) {
                    soloed = soloed == .chords ? nil : .chords
                }
                SmallToggle(title: "M", on: chordsMuted, color: Theme.text) { chordsMuted.toggle() }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(palette.enumerated()), id: \.offset) { i, chord in
                        let on = brush == i
                        Button {
                            Haptics.select()
                            brush = i
                            AudioEngine.shared.playChord(chord.pitches, seconds: 0.45, patch: genre.kit.chords)
                        } label: {
                            Text(chord.name)
                                .font(.label(16, weight: .heavy))
                                .foregroundStyle(on ? Theme.onBrand : Theme.text)
                                .padding(.horizontal, 14)
                                .frame(minWidth: 64)
                                .frame(height: 44)
                        }
                        .buttonStyle(LipStyle(fill: on ? genre.color : Theme.surface,
                                              lip: on ? Theme.lip(for: genre.color) : Theme.stroke,
                                              border: on ? .clear : Theme.stroke, radius: 14))
                    }
                }
                .padding(.vertical, 2)
            }
            VStack(spacing: 8) {
                StepNumbers(playhead: playhead, beatGuide: true)
                ChordLaneRow(cells: $sketch.chordCells, names: palette.map(\.name), brush: min(brush, palette.count - 1),
                             playhead: playhead, marks: [:]) { idx in
                    if !transport.isRunning {
                        AudioEngine.shared.playChord(palette[idx].pitches, seconds: 0.3, patch: genre.kit.chords)
                    }
                }
            }
            .opacity(isSilenced(.chords) ? 0.4 : 1)
            Text("Pick a chord, then tap steps to place it. Tap again to remove.")
                .font(.label(13, weight: .medium)).foregroundStyle(Theme.textSecondary)
        }
        .card()
    }

    private var mixCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "slider.vertical.3").font(.system(size: 15, weight: .black)).foregroundStyle(genre.color)
                Text("MIX").font(.label(14, weight: .black)).tracking(0.6).foregroundStyle(Theme.text)
                Spacer()
                Button("Reset") {
                    Haptics.tap()
                    sketch.drumsFader = MixerTask.unity
                    sketch.bassFader = MixerTask.unity
                    sketch.chordsFader = MixerTask.unity
                    sketch.pump = 0
                    applyMix()
                }
                .font(.label(13, weight: .heavy))
                .foregroundStyle(Theme.textTertiary)
            }
            mixSlider("Drums", value: $sketch.drumsFader)
            mixSlider("Bass", value: $sketch.bassFader)
            mixSlider("Chords", value: $sketch.chordsFader)
            mixSlider("Pump", value: $sketch.pump, text: "\(Int(sketch.pump * 100))%")
            Text("Pump ducks the bass and chords every time the kick hits.")
                .font(.label(13, weight: .medium)).foregroundStyle(Theme.textSecondary)
        }
        .card()
    }

    private func mixSlider(_ label: String, value: Binding<Double>, text: String? = nil) -> some View {
        HStack(spacing: 12) {
            Text(label).font(.label(15, weight: .bold)).foregroundStyle(Theme.text)
                .frame(width: 62, alignment: .leading)
            Slider(value: value, in: 0...1, onEditingChanged: { if !$0 { Haptics.select() } })
                .onChange(of: value.wrappedValue) { _, _ in applyMix() }
            Text(text ?? db(value.wrappedValue))
                .font(.mono(13, weight: .bold)).foregroundStyle(Theme.textSecondary)
                .frame(width: 56, alignment: .trailing)
        }
    }

    private func db(_ fader: Double) -> String {
        let level = MixerTask.level(fader)
        guard level > 0.001 else { return "−∞" }
        let v = 20 * log10(level)
        return abs(v) < 0.5 ? "0 dB" : String(format: "%+.0f dB", v)
    }

    // MARK: Actions

    private func play() {
        transport.play(sketch.playable, genre: genre, source: .user, swing: sketch.swing, bpm: sketch.bpm)
        applyMix()
        applyMutes()
    }

    private func setBPM(_ value: Double) {
        sketch.bpm = min(Studio.bpmRange.upperBound, max(Studio.bpmRange.lowerBound, value.rounded()))
        if playing { play() }
    }

    private func applyMix() {
        let d = MixerTask.level(sketch.drumsFader)
        AudioEngine.shared.setMix(drums: Dictionary(uniqueKeysWithValues: DrumTrack.allCases.map { ($0, d) }),
                                  bass: MixerTask.level(sketch.bassFader),
                                  chords: MixerTask.level(sketch.chordsFader),
                                  sidechain: sketch.pump)
    }

    private func isSilenced(_ i: Instrument) -> Bool {
        if let soloed { return soloed != i }
        switch i {
        case .bass: return bassMuted
        case .chords: return chordsMuted
        case .drum(let t): return muted.contains(t)
        }
    }

    private func applyMutes() {
        let drums = Set(DrumTrack.allCases.filter { isSilenced(.drum($0)) })
        AudioEngine.shared.update(mutedDrums: drums, bassMuted: isSilenced(.bass), chordsMuted: isSilenced(.chords))
    }

    private func save() {
        store.save(sketch)
        savedVersion = sketch
        Haptics.success()
        show("Saved to your Sketchbook")
    }

    private func start(_ s: Sketch) {
        if playing { transport.stop() }
        sketch = s
        savedVersion = nil
        resetChannels()
        pendingGenre = nil
    }

    private func load(_ s: Sketch) {
        if playing { transport.stop() }
        sketch = s
        savedVersion = s
        resetChannels()
        show("Loaded \(s.name)")
    }

    private func resetChannels() {
        brush = 0
        muted = []
        soloed = nil
        bassMuted = false
        chordsMuted = false
        AudioEngine.shared.resetEffects()
    }

    private func show(_ text: String) {
        withAnimation { toast = text }
        Task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation { toast = nil }
        }
    }
}

// MARK: - Sketchbook

struct SketchbookView: View {
    let current: UUID
    let onLoad: (Sketch) -> Void

    @Environment(SketchStore.self) private var store
    @State private var deleting: Sketch?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Sketchbook").font(.display(24)).foregroundStyle(Theme.text)
                Spacer()
                Text("\(store.sketches.count) loop\(store.sketches.count == 1 ? "" : "s")")
                    .font(.label(14, weight: .bold)).foregroundStyle(Theme.textTertiary)
            }
            .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 14)
            if store.sketches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 40, weight: .bold)).foregroundStyle(Theme.surfaceHigh)
                    Text("No loops yet").font(.display(19)).foregroundStyle(Theme.text)
                    Text("Make something in the Studio and tap Save. It'll live here.")
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
                        ForEach(store.sketches) { s in row(s) }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .confirmationDialog("Delete this loop?", isPresented: Binding(
            get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let d = deleting { store.delete([d.id]) }
                deleting = nil
            }
            Button("Cancel", role: .cancel) { deleting = nil }
        } message: {
            Text("This can't be undone.")
        }
    }

    private func row(_ s: Sketch) -> some View {
        HStack(spacing: 14) {
            Button { Haptics.tap(); onLoad(s) } label: {
                HStack(spacing: 14) {
                    GenreBadge(genre: s.genre, size: 44)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(s.name).font(.label(16, weight: .heavy)).foregroundStyle(Theme.text).lineLimit(1)
                            if s.id == current {
                                Text("OPEN").font(.label(10, weight: .black)).tracking(0.5)
                                    .foregroundStyle(Theme.brand)
                                    .padding(.horizontal, 6).frame(height: 18)
                                    .background(Capsule().fill(Theme.brandSoft))
                            }
                        }
                        Text("\(s.genre.name) · \(Int(s.bpm)) BPM · \(s.updated.formatted(.relative(presentation: .named)))")
                            .font(.label(13, weight: .medium)).foregroundStyle(Theme.textSecondary).lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressScaleStyle(scale: 0.98))
            Button { Haptics.tap(); deleting = s } label: {
                Image(systemName: "trash").font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Delete \(s.name)")
        }
        .card(padding: 14)
    }
}
