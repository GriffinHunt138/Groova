//
//  DialGame.swift
//  Groova
//
//  Core game: Dial It In. Flip between the target and your sound, drag one slider until they
//  match, then lock it in. Three hearts, a streak, and the target is revealed after each round.
//

import Foundation
import SwiftUI

struct DialGame: View {
    let task: GameTask
    let config: DialConfig
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, playing, judged, done }
    private enum Side { case target, mine }

    @State private var game = GameProgress(total: 1)
    @State private var phase: Phase = .ready
    @State private var index = 0
    @State private var value: Double = 0.5
    @State private var side: Side = .target
    @State private var lives: Int
    @State private var streak = 0
    @State private var won = 0
    @State private var revealed = false
    @State private var hint = ""
    @State private var looping = false
    @State private var shake: CGFloat = 0
    @State private var run = UUID()
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, config: DialConfig, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.config = config
        self.genre = genre
        self.onComplete = onComplete
        _lives = State(initialValue: config.lives)
    }

    private var target: Double { config.targets[min(index, config.targets.count - 1)] }

    private var isLoop: Bool {
        switch config.kind {
        case .attack, .release: return false
        default: return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                hud
                    .padding(.top, 12)
                Spacer(minLength: 16)
                Text(phase == .ready ? task.name : config.prompt)
                    .font(.display(30))
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.label(16, weight: .semibold))
                    .foregroundStyle(hint.isEmpty || phase == .ready ? Theme.textSecondary : accent)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .frame(height: 44, alignment: .top)
                Spacer(minLength: 16)
                abSwitch
                Spacer(minLength: 28)
                slider
                    .modifier(EchoShake(amount: shake))
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            StepFooter(feedback: game.feedback,
                       primaryTitle: phase == .ready ? "Start" : "Lock it in",
                       primaryEnabled: phase == .ready || phase == .playing,
                       onPrimary: primary,
                       onContinue: { stopSound(); onComplete(game.average) },
                       onRetry: restart)
        }
        .onDisappear {
            run = UUID()
            stopSound()
        }
    }

    private var subtitle: String {
        if phase == .ready { return task.tagline }
        if !hint.isEmpty { return hint }
        return "Flip between Target and Yours, then drag to match."
    }

    // MARK: Top bar

    private var hud: some View {
        let shown = min(index + 1, config.targets.count)
        return HStack {
            HStack(spacing: 6) {
                ForEach(0..<config.lives, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(i < lives ? accent : Theme.surfaceHigh)
                }
            }
            Spacer()
            Text("Round \(shown) of \(config.targets.count)")
                .font(.label(15, weight: .heavy))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16, weight: .black))
                Text("\(streak)")
                    .font(.label(17, weight: .black))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(streak > 0 ? accent : Theme.surfaceHigh)
            .animation(.spring(response: 0.3), value: streak)
        }
    }

    // MARK: Target / Yours

    private var abSwitch: some View {
        HStack(spacing: 12) {
            sideButton(.target, title: "Target", symbol: "scope")
            sideButton(.mine, title: "Yours", symbol: "slider.horizontal.3")
        }
    }

    private func sideButton(_ s: Side, title: String, symbol: String) -> some View {
        let on = side == s && phase != .ready
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)
        let fill: Color = on ? accent : accent.opacity(0.12)
        let ink: Color = on ? Color.white : accent
        return Button {
            listen(s)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 26, weight: .black))
                Text(title)
                    .font(.label(18, weight: .black))
            }
            .foregroundStyle(ink)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(shape.fill(fill))
            .background(shape.fill(Theme.surface))
            .background(shape.fill(accent.opacity(0.22)).offset(y: 5))
        }
        .buttonStyle(PressScaleStyle(scale: 0.96))
        .disabled(phase != .playing)
        .animation(.easeOut(duration: 0.15), value: on)
    }

    // MARK: Slider

    private var slider: some View {
        VStack(spacing: 10) {
            GeometryReader { g in
                let w = g.size.width
                let x = w * CGFloat(value)
                let tx = w * CGFloat(target)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surfaceRaised)
                        .frame(height: 16)
                    Capsule()
                        .fill(accent)
                        .frame(width: max(16, x), height: 16)
                    if revealed {
                        Capsule()
                            .fill(Theme.success)
                            .frame(width: 6, height: 40)
                            .offset(x: tx - 3)
                            .transition(.opacity)
                    }
                    Circle()
                        .fill(Theme.surface)
                        .overlay(Circle().strokeBorder(accent, lineWidth: 5))
                        .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                        .frame(width: 44, height: 44)
                        .offset(x: x - 22)
                }
                .frame(height: 48)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                    drag(to: Double(v.location.x / max(1, w)))
                })
            }
            .frame(height: 48)
            HStack {
                Text(config.low)
                Spacer()
                Text(config.high)
            }
            .font(.label(14, weight: .heavy))
            .foregroundStyle(Theme.textSecondary)
        }
        .opacity(phase == .ready ? 0.4 : 1)
        .allowsHitTesting(phase == .playing)
    }

    // MARK: Sound

    private func apply(_ v: Double) {
        switch config.kind {
        case .filter:
            AudioEngine.shared.setFilter(cutoff: 250 * pow(48, v), resonance: 0.15)
        case .reverb:
            AudioEngine.shared.setReverb(mix: v * 0.9, space: .hall)
        case .bassLevel:
            AudioEngine.shared.setMix(bass: v * 1.6)
        case .drumLevel(let t):
            AudioEngine.shared.setMix(drums: [t: v * 1.6])
        case .tempo:
            AudioEngine.shared.update(bpm: 70 + v * 70)
        case .attack, .release:
            break
        }
    }

    private func phrase(_ v: Double) {
        var patch = SynthPatch.electricPiano
        patch.sustain = 0.8
        switch config.kind {
        case .attack:
            patch.attack = Float(0.002 + v * v * 0.8)
            patch.release = 0.15
            sing(patch, config.notes, gap: 0.75, length: 0.6)
        case .release:
            patch.release = Float(0.02 + v * v * 1.6)
            sing(patch, config.notes, gap: 0.75, length: 0.18)
        default:
            break
        }
    }

    private func listen(_ s: Side) {
        side = s
        let v = s == .target ? target : value
        if isLoop {
            apply(v)
            if !looping {
                transport.play(config.groove, genre: genre, source: .reference, swing: 0, bpm: config.bpm)
                looping = true
                apply(v)
            }
        } else {
            phrase(v)
        }
    }

    private func drag(to v: Double) {
        let clamped = max(0, min(1, v))
        let before = Int(value * 20)
        value = clamped
        if Int(clamped * 20) != before { Haptics.select() }
        if side != .mine {
            side = .mine
            if !isLoop { phrase(clamped) }
        }
        if isLoop { apply(clamped) }
    }

    private func stopSound() {
        transport.stop()
        looping = false
        AudioEngine.shared.resetEffects()
        AudioEngine.shared.update(bpm: config.bpm)
    }

    // MARK: Flow

    private func primary() {
        if phase == .ready {
            startRound()
        } else {
            lock()
        }
    }

    private func startRound() {
        revealed = false
        hint = ""
        value = target > 0.5 ? 0.1 : 0.9
        withAnimation { phase = .playing }
        listen(.target)
    }

    private func lock() {
        guard phase == .playing else { return }
        let d = abs(value - target)
        if d <= config.tolerance {
            won += 1
            streak += 1
            Haptics.success()
            hint = d <= config.tolerance / 2 ? "Spot on." : "Close enough. Nice."
            withAnimation { revealed = true; phase = .judged }
            let token = UUID()
            run = token
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(1200))
                guard run == token else { return }
                if index + 1 >= config.targets.count {
                    finish()
                } else {
                    index += 1
                    startRound()
                }
            }
        } else {
            streak = 0
            lives -= 1
            Haptics.warning()
            withAnimation(.linear(duration: 0.4)) { shake += 1 }
            let word = value < target ? config.high : config.low
            hint = "Not yet. Go more towards \(word.lowercased())."
            if lives <= 0 {
                withAnimation { revealed = true }
                over()
            }
        }
    }

    private func finish() {
        stopSound()
        withAnimation { phase = .done }
        let lost = config.lives - lives
        let score = max(0.5, 1 - 0.12 * Double(lost))
        game.pass(score, "You matched all \(config.targets.count). " + (lost == 0 ? "First try every time." : "Best streak \(streak)."))
    }

    private func over() {
        stopSound()
        withAnimation { phase = .done }
        game.miss("Out of hearts on round \(index + 1). The green mark shows where the target was.")
    }

    private func restart() {
        run = UUID()
        stopSound()
        withAnimation {
            game.feedback = nil
            index = 0
            won = 0
            lives = config.lives
            streak = 0
            revealed = false
            hint = ""
            phase = .ready
        }
    }
}
