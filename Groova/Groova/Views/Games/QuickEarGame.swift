//
//  QuickEarGame.swift
//  Groova
//
//  Core game: Quick Ear. A sound plays, you tap the answer, and the next one comes straight
//  away. Three hearts and a streak. Tap the big circle to hear it again.
//

import Foundation
import SwiftUI

struct QuickEarGame: View {
    let task: GameTask
    let config: QuickEarConfig
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase { case ready, asking, judged, done }

    @State private var game = GameProgress(total: 1)
    @State private var phase: Phase = .ready
    @State private var index = 0
    @State private var correct = 0
    @State private var lives: Int
    @State private var streak = 0
    @State private var bestStreak = 0
    @State private var picked: Int? = nil
    @State private var pulse = false
    @State private var shake: CGFloat = 0
    @State private var run = UUID()
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, config: QuickEarConfig, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.config = config
        self.genre = genre
        self.onComplete = onComplete
        _lives = State(initialValue: config.lives)
    }

    private var question: EarQuestion { config.questions[min(index, config.questions.count - 1)] }

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
                if phase == .ready {
                    Text(task.tagline)
                        .font(.label(16, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                Spacer(minLength: 16)
                listenButton
                Spacer(minLength: 24)
                choices
                    .modifier(EchoShake(amount: shake))
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            StepFooter(feedback: game.feedback,
                       primaryTitle: phase == .ready ? "Start" : "Pick an answer",
                       primaryEnabled: phase == .ready,
                       onPrimary: begin,
                       onContinue: { transport.stop(); onComplete(game.average) },
                       onRetry: restart)
        }
        .onDisappear {
            run = UUID()
            transport.stop()
        }
    }

    // MARK: Top bar

    private var hud: some View {
        let shown = min(index + 1, config.questions.count)
        return HStack {
            HStack(spacing: 6) {
                ForEach(0..<config.lives, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(i < lives ? accent : Theme.surfaceHigh)
                }
            }
            Spacer()
            Text("\(shown) of \(config.questions.count)")
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

    // MARK: Listen

    private var listenButton: some View {
        let size: CGFloat = 150
        let ring: CGFloat = pulse ? 1.18 : 1
        return Button {
            if phase == .asking { play(question.sound) }
        } label: {
            ZStack {
                Circle()
                    .stroke(accent.opacity(pulse ? 0 : 0.35), lineWidth: 6)
                    .scaleEffect(ring)
                Circle()
                    .fill(accent.opacity(0.12))
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(accent)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(PressScaleStyle(scale: 0.94))
        .disabled(phase != .asking)
        .opacity(phase == .ready ? 0.5 : 1)
        .accessibilityLabel("Hear it again")
    }

    // MARK: Answers

    private var choices: some View {
        let n = config.choices.count
        return VStack(spacing: 12) {
            if n <= 2 {
                HStack(spacing: 12) {
                    ForEach(0..<n, id: \.self) { i in choice(i) }
                }
            } else {
                ForEach(0..<n, id: \.self) { i in choice(i) }
            }
        }
    }

    private func choice(_ i: Int) -> some View {
        let tall = config.choices.count <= 2
        let isAnswer = i == question.answer
        let shownRight = phase == .judged && isAnswer
        let shownWrong = phase == .judged && picked == i && !isAnswer
        let fill: Color = shownRight ? Theme.success : (shownWrong ? Theme.miss : accent.opacity(0.12))
        let ink: Color = (shownRight || shownWrong) ? Color.white : accent
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)
        return Button {
            answer(i)
        } label: {
            Text(config.choices[i])
                .font(.label(20, weight: .black))
                .foregroundStyle(ink)
                .frame(maxWidth: .infinity)
                .frame(height: tall ? 110 : 64)
                .background(shape.fill(fill))
                .background(shape.fill(Theme.surface))
                .background(shape.fill(accent.opacity(0.22)).offset(y: 5))
        }
        .buttonStyle(PressScaleStyle(scale: 0.96))
        .disabled(phase != .asking)
        .animation(.easeOut(duration: 0.15), value: phase)
    }

    // MARK: Sound

    private func play(_ s: EarSound) {
        transport.stop()
        withAnimation(.easeOut(duration: 0.6)) { pulse = true }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(650))
            pulse = false
        }
        switch s {
        case .chord(let notes):
            AudioEngine.shared.playChord(notes, seconds: 1.1, patch: .electricPiano)
        case .notes(let notes):
            sing(.electricPiano, notes, gap: 0.5, length: 0.45)
        case .chords(let chords):
            for (i, c) in chords.enumerated() {
                AudioEngine.shared.playChord(c, seconds: 0.8, patch: .electricPiano, delay: Double(i) * 0.85)
            }
        case .groove(let p, let swing):
            transport.play(p, genre: genre, source: .reference, bars: 2, swing: swing, bpm: 92)
        }
    }

    // MARK: Flow

    private func begin() {
        index = 0
        ask()
    }

    private func ask() {
        picked = nil
        withAnimation { phase = .asking }
        let token = UUID()
        run = token
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            guard run == token else { return }
            play(question.sound)
        }
    }

    private func answer(_ i: Int) {
        guard phase == .asking else { return }
        picked = i
        let right = i == question.answer
        if right {
            correct += 1
            streak += 1
            bestStreak = max(bestStreak, streak)
            Haptics.success()
        } else {
            streak = 0
            lives -= 1
            Haptics.warning()
            withAnimation(.linear(duration: 0.4)) { shake += 1 }
        }
        withAnimation { phase = .judged }
        let token = UUID()
        run = token
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(right ? 650 : 1100))
            guard run == token else { return }
            if lives <= 0 {
                over()
            } else if index + 1 >= config.questions.count {
                finish()
            } else {
                index += 1
                ask()
            }
        }
    }

    private func finish() {
        transport.stop()
        withAnimation { phase = .done }
        let total = max(1, config.questions.count)
        let score = Double(correct) / Double(total)
        let line = "\(correct) of \(total) right. Best streak \(bestStreak)."
        if score >= config.threshold {
            game.pass(score, line)
        } else {
            game.miss(line + " Tap the speaker to hear each one again before you answer.", score: score)
        }
    }

    private func over() {
        transport.stop()
        withAnimation { phase = .done }
        game.miss("Out of hearts at question \(index + 1) of \(config.questions.count). Go again, you'll get further.")
    }

    private func restart() {
        run = UUID()
        transport.stop()
        withAnimation {
            game.feedback = nil
            index = 0
            correct = 0
            lives = config.lives
            streak = 0
            picked = nil
            phase = .ready
        }
    }
}
