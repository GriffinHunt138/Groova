//
//  TrackEditorView.swift
//  Groova
//
//  One Sandbox track up close. Notes: write it bar by bar. Sound: pick a preset, turn the
//  knobs, add effects. Every change is heard straight away.
//

import Foundation
import SwiftUI

struct TrackEditorView: View {
    enum Tab: String, CaseIterable { case notes = "Notes", sound = "Sound" }

    @Binding var jam: Jam
    let part: JamPart
    @Binding var showTempo: Bool

    @State private var tab: Tab = .notes
    @State private var barIndex = 0
    @State private var drum: DrumTrack = .kick
    @State private var brush = 0
    @State private var helpParam: JamParam?
    @State private var lastAudition = Date.distantPast

    private var transport: Transport { Transport.shared }
    private var genre: Genre { jam.genre }
    private var playing: Bool { transport.isPlaying(.jamLoop) || transport.isPlaying(.jamSong) }

    private var track: Binding<JamTrack> {
        Binding(get: { jam[part] }, set: { jam[part] = $0 })
    }

    private var bar: Binding<JamBar> {
        Binding(get: {
            let t = jam[part]
            return t.clips[min(barIndex, t.clips.count - 1)]
        }, set: { new in
            var t = jam[part]
            let i = min(barIndex, t.clips.count - 1)
            t.clips[i] = new
            jam[part] = t
        })
    }

    /// The step playing in the bar on screen, else -1.
    private var playhead: Int {
        guard playing, transport.bar >= 0 else { return -1 }
        return jam[part].bar(at: transport.bar) == barIndex ? transport.step : -1
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                presetPicker
                ModeSwitch(selection: $tab)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 10)
            Rectangle().fill(Theme.divider).frame(height: Theme.border)
            ScrollView {
                VStack(spacing: 16) {
                    switch tab {
                    case .notes: notesTab
                    case .sound: soundTab
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Theme.background)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            JamTransportBar(jam: jam, arranged: false, showTempo: $showTempo)
        }
        .navigationTitle(part.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.select()
                    track.wrappedValue.muted.toggle()
                } label: {
                    Image(systemName: jam[part].muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundStyle(jam[part].muted ? Theme.miss : Theme.text)
                        .contentTransition(.symbolEffect(.replace))
                }
                .accessibilityLabel(jam[part].muted ? "Unmute" : "Mute")
            }
        }
        .onChange(of: jam[part].bars) { _, n in barIndex = min(barIndex, n - 1) }
    }

    // MARK: Presets

    private var presetPicker: some View {
        HStack(spacing: 12) {
            PartTile(part: part, size: 44)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(part.presets.enumerated()), id: \.offset) { i, name in
                        let on = jam[part].preset == i
                        Button {
                            Haptics.select()
                            track.wrappedValue.preset = i
                            if !playing { JamSound.audition(jam[part], genre, drum: drum) }
                        } label: {
                            Text(name)
                                .font(.label(15, weight: .heavy))
                                .foregroundStyle(on ? Theme.onBrand : Theme.text)
                                .padding(.horizontal, 14)
                                .frame(height: 38)
                        }
                        .buttonStyle(LipStyle(fill: on ? Theme.brand : Theme.surface,
                                              lip: on ? Theme.brandLip : Theme.stroke,
                                              border: on ? .clear : Theme.stroke, radius: 12, depth: 3))
                        .accessibilityAddTraits(on ? .isSelected : [])
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: Notes

    @ViewBuilder
    private var notesTab: some View {
        barPicker
        VStack(alignment: .leading, spacing: 14) {
            switch part {
            case .drums:
                StepSequencerGrid(pattern: bar.drums, tracks: DrumTrack.allCases, editable: Set(DrumTrack.allCases),
                                  playhead: playhead, swing: jam.swing, beatGuide: true,
                                  kit: JamSound.kit(jam[part], genre))
            case .bass:
                PianoRollGrid(notes: bar.notes, rows: Studio.bassRows(genre), playhead: playhead,
                              patch: JamSound.patch(jam[part]))
            case .lead:
                PianoRollGrid(notes: bar.notes, rows: JamSound.leadRows(genre), playhead: playhead,
                              patch: JamSound.patch(jam[part]))
            case .keys:
                chordEditor
            case .vox:
                chopEditor
            }
        }
        .card(padding: 14)
        Text(notesTip)
            .font(.label(13, weight: .medium))
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    private var notesTip: String {
        switch part {
        case .drums: "Tap to add a hit, drag across a row to paint. Tap a drum's name to hear it."
        case .bass: "Tap to add a note, drag right to hold it, drag a note to move it. Tap it again to remove."
        case .lead: "Every row is in the scale, so nothing clashes. Drag right to hold a note."
        case .keys: "Pick a chord, then tap steps to place it. Each chord rings until the next one, up to the Length on the Sound tab."
        case .vox: "Each row is a sung slice with its own note. Tap a row's name to hear it."
        }
    }

    private var barPicker: some View {
        let t = jam[part]
        let playingBar = playing && transport.bar >= 0 ? t.bar(at: transport.bar) : -1
        return HStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(0..<t.bars, id: \.self) { i in
                        let on = i == barIndex
                        Button {
                            Haptics.select()
                            barIndex = i
                        } label: {
                            VStack(spacing: 3) {
                                Text("\(i + 1)").font(.label(15, weight: .heavy))
                                Circle().fill(i == playingBar ? (on ? Theme.onBrand : Theme.brand) : .clear)
                                    .frame(width: 5, height: 5)
                            }
                            .foregroundStyle(on ? Theme.onBrand : Theme.text)
                            .frame(width: 40, height: 40)
                        }
                        .buttonStyle(LipStyle(fill: on ? Theme.brand : Theme.surface,
                                              lip: on ? Theme.brandLip : Theme.stroke,
                                              border: on ? .clear : Theme.stroke, radius: 12, depth: 3))
                        .accessibilityLabel("Bar \(i + 1)")
                        .accessibilityAddTraits(on ? .isSelected : [])
                    }
                }
                .padding(.vertical, 2)
            }
            Menu {
                Section("Length") {
                    ForEach([1, 2, 4, 8], id: \.self) { n in
                        Button {
                            track.wrappedValue.setBars(n)
                        } label: {
                            if n == t.bars { Label(n == 1 ? "1 bar" : "\(n) bars", systemImage: "checkmark") }
                            else { Text(n == 1 ? "1 bar" : "\(n) bars") }
                        }
                    }
                }
                Section("Bar \(barIndex + 1)") {
                    if t.bars > 1 {
                        Button { copyBarToAll() } label: { Label("Copy to every bar", systemImage: "square.on.square") }
                    }
                    Button(role: .destructive) { clearBar() } label: { Label("Clear this bar", systemImage: "eraser") }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(t.bars == 1 ? "1 bar" : "\(t.bars) bars").font(.label(14, weight: .heavy))
                    Image(systemName: "chevron.down").font(.system(size: 11, weight: .black))
                }
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 12).frame(height: 40)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surfaceRaised))
            }
            .accessibilityLabel("Track length and bar options")
        }
    }

    private var chordEditor: some View {
        let palette = Studio.palette(genre)
        let patch = JamSound.patch(jam[part])
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ForEach(Array(palette.enumerated()), id: \.offset) { i, chord in
                    let on = brush == i
                    Button {
                        Haptics.select()
                        brush = i
                        if !playing { AudioEngine.shared.playChord(chord.pitches, seconds: 0.5, patch: patch) }
                    } label: {
                        Text(chord.name)
                            .font(.label(15, weight: .heavy))
                            .foregroundStyle(on ? Theme.onBrand : Theme.text)
                            .lineLimit(1).minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(LipStyle(fill: on ? Theme.brand : Theme.surface,
                                          lip: on ? Theme.brandLip : Theme.stroke,
                                          border: on ? .clear : Theme.stroke, radius: 12))
                }
            }
            VStack(spacing: 8) {
                StepNumbers(playhead: playhead, beatGuide: true)
                ChordLaneRow(cells: bar.chords, names: palette.map(\.name), brush: min(brush, palette.count - 1),
                             playhead: playhead, marks: [:]) { idx in
                    if !playing { AudioEngine.shared.playChord(palette[idx].pitches, seconds: 0.35, patch: patch) }
                }
            }
        }
    }

    private var chopEditor: some View {
        let pads = JamSound.pads(genre)
        return VStack(spacing: 12) {
            StepNumbers(playhead: playhead, beatGuide: true)
            ForEach(Array(pads.enumerated()), id: \.offset) { r, pad in
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Button {
                            Haptics.tap()
                            JamSound.audition(pad: r, jam[part], genre)
                        } label: {
                            HStack(spacing: 6) {
                                Text(pad.syllable).font(.label(16, weight: .heavy)).foregroundStyle(Theme.text)
                                Text(NoteName.name(pad.pitch + JamSound.pitchShift(jam[part])))
                                    .font(.label(12, weight: .bold)).foregroundStyle(Theme.textTertiary)
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.textTertiary)
                            }
                        }
                        .buttonStyle(PressScaleStyle())
                        Spacer()
                    }
                    SequencerRow(cells: Binding(get: { bar.wrappedValue.chops[r] },
                                                set: { bar.wrappedValue.chops[r] = $0 }),
                                 color: Theme.brand, isEditable: true, playhead: playhead, marks: [:],
                                 swing: jam.swing, beatGuide: true,
                                 onActivate: { if !playing { JamSound.audition(pad: r, jam[part], genre) } })
                }
            }
        }
    }

    private func copyBarToAll() {
        var t = jam[part]
        let source = t.clips[min(barIndex, t.clips.count - 1)]
        t.clips = t.clips.map { _ in source }
        jam[part] = t
        Haptics.success()
    }

    private func clearBar() {
        var t = jam[part]
        let i = min(barIndex, t.clips.count - 1)
        var b = t.clips[i]
        switch part {
        case .drums: b.drums = Pattern()
        case .bass, .lead: b.notes = []
        case .keys: b.chords = [Int?](repeating: nil, count: Pattern.steps)
        case .vox: b.chops = JamBar().chops
        }
        t.clips[i] = b
        jam[part] = t
        Haptics.soft()
    }

    // MARK: Sound

    @ViewBuilder
    private var soundTab: some View {
        volumeCard
        if part == .drums {
            VStack(alignment: .leading, spacing: 14) {
                cardTitle("Drum sounds", symbol: "slider.horizontal.3")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DrumTrack.allCases) { d in
                            let on = drum == d
                            Button {
                                Haptics.select()
                                drum = d
                                if !playing { JamSound.audition(jam[part], genre, drum: d) }
                            } label: {
                                Text(d.name).font(.label(14, weight: .heavy))
                                    .foregroundStyle(on ? Theme.onBrand : Theme.text)
                                    .padding(.horizontal, 12).frame(height: 36)
                            }
                            .buttonStyle(LipStyle(fill: on ? Theme.brand : Theme.surface,
                                                  lip: on ? Theme.brandLip : Theme.stroke,
                                                  border: on ? .clear : Theme.stroke, radius: 11, depth: 3))
                        }
                    }
                    .padding(.vertical, 2)
                }
                knobGrid(JamParam.drum(drum))
            }
            .card(padding: 16)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                cardTitle("Sound", symbol: "slider.horizontal.3")
                knobGrid(part.soundParams)
            }
            .card(padding: 16)
        }
        VStack(alignment: .leading, spacing: 14) {
            cardTitle("Effects", symbol: "sparkles")
            knobGrid(JamParam.effects)
        }
        .card(padding: 16)
        Text(helpParam?.help ?? "Turn a knob to hear what it does.")
            .font(.label(13, weight: .medium))
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .animation(.none, value: helpParam)
        Button("Reset sound") {
            Haptics.tap()
            var t = jam[part]
            t.knobs = [:]
            t.volume = MixerTask.unity
            jam[part] = t
        }
        .buttonStyle(GhostButtonStyle(height: 46))
    }

    private var volumeCard: some View {
        let level = MixerTask.level(jam[part].volume)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                cardTitle("Volume", symbol: "speaker.wave.2.fill")
                Spacer()
                Text(level < 0.001 ? "Off" : decibels(level))
                    .font(.mono(14, weight: .bold)).foregroundStyle(Theme.textSecondary)
            }
            Slider(value: track.volume, in: 0...1, onEditingChanged: { if !$0 { Haptics.select() } })
        }
        .card(padding: 16)
    }

    private func decibels(_ level: Double) -> String {
        let v = 20 * log10(level)
        return abs(v) < 0.5 ? "0 dB" : String(format: "%+.0f dB", v)
    }

    private func cardTitle(_ title: String, symbol: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).font(.system(size: 14, weight: .black)).foregroundStyle(Theme.brand)
            Text(title.uppercased()).font(.label(13, weight: .black)).tracking(0.6).foregroundStyle(Theme.text)
        }
    }

    private func knobGrid(_ params: [JamParam]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 16) {
            ForEach(params) { p in
                Knob(value: Binding(get: { jam[part].value(p) }, set: { track.wrappedValue.set(p, $0) }),
                     label: p.label, valueText: JamSound.text(p, jam[part], genre), color: Theme.brand, size: 66,
                     onChange: { turned(p) })
            }
        }
    }

    /// Show what the knob does and, when nothing is playing, let you hear it.
    private func turned(_ p: JamParam) {
        if helpParam != p { helpParam = p }
        guard !playing, Date.now.timeIntervalSince(lastAudition) > 0.32 else { return }
        lastAudition = .now
        let d: DrumTrack
        switch p {
        case .clapTone, .clapLength, .clapLevel: d = .clap
        case .hatTone, .hatLength, .hatLevel: d = .hat
        case .openLength, .openLevel: d = .openHat
        case .rimTune, .rimLength, .rimLevel: d = .perc
        default: d = part == .drums ? drum : .kick
        }
        JamSound.audition(jam[part], genre, drum: d)
    }
}
