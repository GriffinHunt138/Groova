//
//  EchoGame.swift
//  Groova
//
//  Core game: Echo. I play a call on the pads, you play it back. Each call you clear is a
//  little longer. Three hearts, a streak, and instant sound on every tap.
//

import Foundation
import SwiftUI

struct EchoGame: View {
    let task: GameTask
    let config: EchoConfig
    let genre: Genre
    let onComplete: (Double) -> Void

    private enum Phase: Equatable { case ready, listening, answering, cleared, oops, over, won }

    @State private var game = GameProgress(total: 1)
    @State private var phase: Phase = .ready
    @State private var callIndex = 0
    @State private var typed = 0
    @State private var lives: Int
    @State private var streak = 0
    @State private var bestStreak = 0
    @State private var lit: Int? = nil
    @State private var wrongPad: Int? = nil
    @State private var shake: CGFloat = 0
    @State private var held: Set<Int> = []
    /// Changes whenever a new sequence of events starts, so stale timers do nothing.
    @State private var run = UUID()
    @Environment(\.accent) private var accent

    private var transport: Transport { Transport.shared }

    init(task: GameTask, config: EchoConfig, genre: Genre, onComplete: @escaping (Double) -> Void) {
        self.task = task
        self.config = config
        self.genre = genre
        self.onComplete = onComplete
        _lives = State(initialValue: config.lives)
    }

    private var call: [Int] { config.calls[min(callIndex, config.calls.count - 1)] }
    private var answer: [Int] { call.filter { $0 >= 0 } }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                hud
                    .padding(.top, 12)
                Spacer(minLength: 16)
                status
                Spacer(minLength: 16)
                padGrid
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            StepFooter(feedback: game.feedback,
                       primaryTitle: primaryTitle,
                       primaryEnabled: phase == .ready,
                       onPrimary: playCall,
                       onContinue: { onComplete(game.average) },
                       onRetry: restart)
        }
        .onDisappear { run = UUID() }
    }

    private var primaryTitle: String {
        switch phase {
        case .ready: return "Start"
        case .answering: return "Your turn"
        default: return "Listen…"
        }
    }

    // MARK: Top bar: hearts, progress, streak

    private var hud: some View {
        let shown = min(callIndex + 1, config.calls.count)
        return HStack {
            HStack(spacing: 6) {
                ForEach(0..<config.lives, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(i < lives ? accent : Theme.surfaceHigh)
                }
            }
            Spacer()
            Text("\(shown) of \(config.calls.count)")
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

    // MARK: Status

    private var statusText: String {
        switch phase {
        case .ready: return task.name
        case .listening: return "Listen"
        case .answering: return "Your turn"
        case .cleared: return streak >= 3 ? "On fire!" : "Nice!"
        case .oops: return "Oops"
        case .over: return "Out of hearts"
        case .won: return "Cleared!"
        }
    }

    private var status: some View {
        let hot = phase == .answering || phase == .cleared || phase == .won
        return VStack(spacing: 16) {
            Text(statusText)
                .font(.display(34))
                .foregroundStyle(hot ? accent : (phase == .oops ? Theme.miss : Theme.text))
                .contentTransition(.opacity)
                .animation(.easeOut(duration: 0.15), value: phase)
            if phase == .ready {
                Text(task.tagline)
                    .font(.label(16, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            } else {
                HStack(spacing: 8) {
                    ForEach(0..<answer.count, id: \.self) { i in
                        Circle()
                            .fill(i < typed ? accent : Theme.surfaceHigh)
                            .frame(width: 12, height: 12)
                    }
                }
                .modifier(EchoShake(amount: shake))
                .animation(.spring(response: 0.25), value: typed)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
    }

    // MARK: Pads

    private var padGrid: some View {
        let n = config.pads.count
        let h: CGFloat = n >= 4 ? 150 : 230
        return Group {
            if n == 4 {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        pad(0, height: h)
                        pad(1, height: h)
                    }
                    HStack(spacing: 12) {
                        pad(2, height: h)
                        pad(3, height: h)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    ForEach(0..<n, id: \.self) { i in
                        pad(i, height: h)
                    }
                }
            }
        }
    }

    private func pad(_ i: Int, height: CGFloat) -> some View {
        let p = config.pads[i]
        let on = lit == i
        let wrong = wrongPad == i
        let fill: Color = wrong ? Theme.miss : (on ? accent : accent.opacity(0.12))
        let ink: Color = (on || wrong) ? Color.white : accent
        let shape = RoundedRectangle(cornerRadius: 26, style: .continuous)
        let scale: CGFloat = on ? 0.96 : 1
        return VStack(spacing: 10) {
            if let s = p.symbol {
                Image(systemName: s)
                    .font(.system(size: 30, weight: .black))
            }
            Text(p.label)
                .font(.label(p.symbol == nil ? 26 : 17, weight: .black))
        }
        .foregroundStyle(ink)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(shape.fill(fill))
        .background(shape.fill(Theme.surface))
        .background(shape.fill(accent.opacity(0.22)).offset(y: 6))
        .scaleEffect(scale)
        .animation(.easeOut(duration: 0.08), value: on)
        .contentShape(shape)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in press(i) }
            .onEnded { _ in held.remove(i) })
        .accessibilityLabel(p.label)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { press(i); held.remove(i) }
    }

    // MARK: Sound

    private func sound(_ i: Int) {
        switch config.pads[i].sound {
        case .drum(let t):
            AudioEngine.shared.trigger(t, kit: transport.kit(for: genre), velocity: 1)
        case .note(let m):
            AudioEngine.shared.playNote(m, seconds: 0.45, patch: .electricPiano)
        case .chord(let ms):
            AudioEngine.shared.playChord(ms, seconds: 0.7, patch: .electricPiano)
        }
    }

    private func flash(_ i: Int) {
        lit = i
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(170))
            if lit == i { lit = nil }
        }
    }

    // MARK: Flow

    private func press(_ i: Int) {
        guard !held.contains(i) else { return }
        held.insert(i)
        guard phase != .listening, phase != .oops else { return }
        sound(i)
        flash(i)
        Haptics.tap()
        guard phase == .answering, typed < answer.count else { return }
        if answer[typed] == i {
            typed += 1
            if typed == answer.count { cleared() }
        } else {
            missed(i)
        }
    }

    private func playCall() {
        let token = UUID()
        run = token
        typed = 0
        withAnimation { phase = .listening }
        let gap = 60.0 / max(40, config.bpm)
        let notes = call
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            for i in notes {
                guard run == token else { return }
                if i >= 0, i < config.pads.count {
                    sound(i)
                    if config.showCall { flash(i) }
                }
                try? await Task.sleep(for: .seconds(gap))
            }
            guard run == token else { return }
            withAnimation { phase = .answering }
        }
    }

    private func cleared() {
        streak += 1
        bestStreak = max(bestStreak, streak)
        Haptics.success()
        withAnimation { phase = .cleared }
        let token = UUID()
        run = token
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(750))
            guard run == token else { return }
            if callIndex + 1 >= config.calls.count {
                win()
            } else {
                callIndex += 1
                playCall()
            }
        }
    }

    private func missed(_ i: Int) {
        Haptics.warning()
        wrongPad = i
        streak = 0
        lives -= 1
        withAnimation { phase = .oops }
        withAnimation(.linear(duration: 0.4)) { shake += 1 }
        let token = UUID()
        run = token
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(800))
            guard run == token else { return }
            wrongPad = nil
            if lives <= 0 {
                over()
            } else {
                playCall()
            }
        }
    }

    private func win() {
        withAnimation { phase = .won }
        let lost = config.lives - lives
        let score = max(0.5, 1 - 0.15 * Double(lost))
        let hearts = lost == 0 ? "Not a single heart lost." : "Best streak \(bestStreak)."
        game.pass(score, "You echoed all \(config.calls.count) calls. " + hearts)
    }

    private func over() {
        withAnimation { phase = .over }
        game.miss("You got to call \(callIndex + 1) of \(config.calls.count). Go again, you'll get further.")
    }

    private func restart() {
        run = UUID()
        withAnimation {
            game.feedback = nil
            callIndex = 0
            lives = config.lives
            streak = 0
            typed = 0
            phase = .ready
        }
    }
}

/// A quick side-to-side shake for a wrong answer.
struct EchoShake: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let x: CGFloat = 8 * sin(amount * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
    }
}
