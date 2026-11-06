//
//  LessonPlayerView.swift
//  Groova
//
//  Full-screen lesson runner. Steps are data; this view sequences them and celebrates at the end.
//

import Foundation
import SwiftUI

struct LessonPlayerView: View {
    let lesson: Lesson
    let genre: Genre
    var tier: LessonTier = .bronze
    var practice: PracticeSession? = nil

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var index = 0
    @State private var scores: [Double] = []
    @State private var reward: CompletionReward?
    @State private var confirmQuit = false
    @State private var steps: [LessonStep] = []

    init(lesson: Lesson, genre: Genre, tier: LessonTier = .bronze, practice: PracticeSession? = nil) {
        self.lesson = practice?.lesson ?? lesson
        self.genre = genre
        self.tier = practice == nil ? tier : .bronze
        self.practice = practice
        _steps = State(initialValue: practice?.lesson.steps ?? Levels.steps(lesson, tier: tier))
    }

    init(practice: PracticeSession, genre: Genre) {
        self.init(lesson: practice.lesson, genre: genre, practice: practice)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            if let reward {
                LessonCompleteView(lesson: lesson, genre: genre, reward: reward, tier: tier) { dismiss() }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                VStack(spacing: 0) {
                    topBar
                    if let phases = TierPhase.map(steps) {
                        PhaseStrip(current: phases[min(index, phases.count - 1)], accent: genre.color)
                    }
                    stepView
                        .id(index)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)))
                }
            }
        }
        .environment(\.accent, genre.color)
        .tint(genre.color)
        .onAppear {
            AudioEngine.shared.start()
            Transport.shared.flavor = flavor(at: 0)
        }
        .onDisappear {
            Transport.shared.stop()
            Transport.shared.flavor = 0
            AudioEngine.shared.resetEffects()
        }
        .confirmationDialog("Leave this lesson?", isPresented: $confirmQuit, titleVisibility: .visible) {
            Button("Leave", role: .destructive) { dismiss() }
            Button("Keep playing", role: .cancel) {}
        } message: {
            Text("Your progress in this lesson won't be saved.")
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                if index == 0 { dismiss() } else { confirmQuit = true }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .frame(width: 32, height: 40)
            }
            .accessibilityLabel("Close lesson")
            ProgressBar(value: Double(index) / Double(max(1, steps.count)), color: genre.color, height: 16)
            if practice != nil {
                Image(systemName: "dumbbell.fill")
                    .font(.label(15, weight: .heavy))
                    .foregroundStyle(genre.color)
            } else if lesson.isMastery {
                Image(systemName: "crown.fill")
                    .font(.label(15, weight: .heavy))
                    .foregroundStyle(Theme.gold)
            } else {
                TierBadge(tier: tier)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var stepView: some View {
        let step = steps[min(index, steps.count - 1)]
        switch step {
        case .intro(let s):
            if let level = s.level {
                LevelBriefView(step: s, level: level, lessonTitle: lesson.title,
                               tasks: steps.filter(Levels.isGraded).count, genre: genre, onComplete: advance)
            } else {
                IntroStepView(step: s, genre: genre, onComplete: advance)
            }
        case .sequencer(let t): SequencerStepView(task: t, genre: genre, onComplete: advance)
        case .keyboard(let t): KeyboardStepView(task: t, genre: genre, onComplete: advance)
        case .pianoRoll(let t): PianoRollStepView(task: t, genre: genre, onComplete: advance)
        case .filter(let t): FilterStepView(task: t, genre: genre, onComplete: advance)
        case .reverb(let t): ReverbStepView(task: t, genre: genre, onComplete: advance)
        case .mastery(let t): MasteryChallengeView(task: t, genre: genre, onComplete: advance)
        case .chordBuilder(let t): ChordBuilderStepView(task: t, genre: genre, onComplete: advance)
        case .earChoice(let t): EarChoiceStepView(task: t, genre: genre, onComplete: advance)
        case .chordLane(let t):
            if t.chops != nil {
                ChopLaneStepView(task: t, genre: genre, onComplete: advance)
            } else {
                ChordLaneStepView(task: t, genre: genre, onComplete: advance)
            }
        case .soundLab(let t): SoundLabStepView(task: t, genre: genre, onComplete: advance)
        case .mixer(let t): MixerStepView(task: t, genre: genre, onComplete: advance)
        case .arrangement(let t): ArrangementStepView(task: t, genre: genre, onComplete: advance)
        case .tempo(let t): TempoStepView(task: t, genre: genre, onComplete: advance)
        case .tap(let t): TapStepView(task: t, genre: genre, onComplete: advance)
        case .order(let t): OrderStepView(task: t, genre: genre, onComplete: advance)
        case .game(let t): GameStepView(task: t, genre: genre, onComplete: advance)
        }
    }

    /// Intro cards play the genre's own sounds. Everything else gets its own flavor.
    private func flavor(at i: Int) -> Int {
        guard i < steps.count else { return 0 }
        if case .intro = steps[i] { return 0 }
        return SoundFlavor.seed(lesson.id + "\(tier)", step: i)
    }

    private func advance(_ score: Double) {
        Transport.shared.stop()
        AudioEngine.shared.resetEffects()
        scores.append(score)
        if index + 1 >= steps.count {
            let accuracy = scores.reduce(0, +) / Double(max(1, scores.count))
            let r = practice.map { app.completePractice($0, genre: genre, accuracy: accuracy) }
                ?? app.complete(lesson, genre: genre, accuracy: accuracy, tier: tier)
            AudioEngine.shared.playSuccess()
            Haptics.success()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { reward = r }
        } else {
            Transport.shared.flavor = flavor(at: index + 1)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) { index += 1 }
        }
    }
}

// MARK: - Phase strip

/// Teach, Studio, Game: where you are in a Foundations tier.
struct PhaseStrip: View {
    let current: TierPhase?
    let accent: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TierPhase.allCases, id: \.self) { p in
                let on = p == current
                let past = (current?.rawValue ?? -1) > p.rawValue
                HStack(spacing: 5) {
                    Image(systemName: past ? "checkmark" : p.symbol)
                        .font(.system(size: 11, weight: .black))
                    Text(p.name.uppercased())
                        .font(.label(11, weight: .black)).tracking(0.6)
                }
                .foregroundStyle(on ? Theme.onBrand : (past ? accent : Theme.textTertiary))
                .padding(.horizontal, 10)
                .frame(height: 26)
                .background(Capsule().fill(on ? accent : (past ? accent.opacity(0.12) : Theme.surfaceRaised)))
                if p != .game {
                    Rectangle().fill(past ? accent.opacity(0.5) : Theme.divider).frame(width: 10, height: 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
        .animation(.spring(response: 0.35), value: current)
    }
}

// MARK: - Completion

struct LessonCompleteView: View {
    let lesson: Lesson
    let genre: Genre
    let reward: CompletionReward
    var tier: LessonTier = .bronze
    let onDone: () -> Void

    private var title: String {
        if lesson.isMastery { return "Unit mastered!" }
        if reward.isDailyPractice { return "Practice complete!" }
        if let t = reward.tierEarned { return "\(t.name) earned!" }
        return reward.isPractice ? "Nice replay!" : "Lesson complete!"
    }

    private var heroColor: Color { reward.tierEarned.map { $0.color } ?? Theme.brand }
    private var heroLip: Color { reward.tierEarned.map { $0.lip } ?? Theme.brandLip }
    private var heroSymbol: String {
        if lesson.isMastery { return "crown.fill" }
        if reward.isDailyPractice { return "dumbbell.fill" }
        if reward.tierEarned != nil { return "medal.fill" }
        return "star.fill"
    }

    @State private var shownXP = 0
    @State private var appeared = false

    var body: some View {
        ZStack {
            ConfettiView(colors: [Theme.brand, Theme.brandBorder, Color(hex: 0x9B83FF), Theme.brandLip], count: 90)
                .ignoresSafeArea()
            VStack(spacing: 26) {
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    Circle().fill(Theme.brandSoft).frame(width: 190, height: 190)
                    WooferView(mood: .party, size: 180, bouncing: true)
                        .offset(x: -5, y: -6)
                    ZStack {
                        Circle().fill(heroLip).frame(width: 54, height: 54).offset(y: 4)
                        Circle().fill(heroColor).frame(width: 54, height: 54)
                        Image(systemName: heroSymbol)
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(Theme.onBrand)
                            .symbolEffect(.bounce, value: appeared)
                    }
                }
                .scaleEffect(appeared ? 1 : 0.4)
                VStack(spacing: 8) {
                    Text(title)
                        .font(.display(32))
                        .foregroundStyle(Theme.text)
                    Text(lesson.title)
                        .font(.label(16, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                }

                HStack(spacing: 12) {
                    statTile(value: "+\(shownXP)", label: "XP", symbol: "star.fill")
                    statTile(value: "\(Int((reward.accuracy * 100).rounded()))%", label: "Accuracy",
                             symbol: "target")
                    statTile(value: "\(reward.streak)", label: reward.streakIncreased ? "Streak +1" : "Day streak",
                             symbol: "bolt.fill")
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                VStack(spacing: 10) {
                    if let t = reward.tierEarned, t != .gold, let next = LessonTier(rawValue: t.rawValue + 1) {
                        banner(symbol: "medal.fill", text: "\(next.name) level unlocked for this lesson", color: next.color)
                    }
                    if let level = reward.leveledUp {
                        banner(symbol: "arrow.up.circle.fill", text: "\(genre.name) level \(level)!", color: Theme.brand)
                    }
                    if let unit = reward.unlockedUnit {
                        banner(symbol: "lock.open.fill", text: "\(unit.shortLabel) unlocked: \(unit.title)", color: Theme.brand)
                    }
                    ForEach(reward.newAchievements) { a in
                        banner(symbol: a.symbol, text: "Achievement: \(a.title)", color: Theme.brand)
                    }
                }
                .opacity(appeared ? 1 : 0)

                Spacer()
                Button("Continue", action: onDone)
                    .buttonStyle(ChunkyButtonStyle(color: Theme.brand))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 20)
        }
        .task {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { appeared = true }
            let steps = 20
            for i in 1...steps {
                try? await Task.sleep(for: .milliseconds(35))
                shownXP = Int(Double(reward.xp) * Double(i) / Double(steps))
                if i % 4 == 0 { Haptics.select() }
            }
        }
    }

    private func statTile(value: String, label: String, symbol: String) -> some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        return VStack(spacing: 0) {
            Text(label.uppercased()).font(.label(11, weight: .black)).tracking(0.6)
                .foregroundStyle(Theme.brand)
                .frame(maxWidth: .infinity).frame(height: 28)
                .background(Theme.brandSoft)
            HStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 16, weight: .black))
                    .foregroundStyle(Theme.brand)
                Text(value).font(.display(22)).monospacedDigit()
                    .foregroundStyle(Theme.text)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(Theme.surface)
        }
        .clipShape(shape)
        .overlay(shape.strokeBorder(Theme.brandBorder, lineWidth: Theme.border))
        .background(shape.fill(Theme.brandBorder).offset(y: 4))
    }

    private func banner(symbol: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).foregroundStyle(color)
            Text(text).font(.label(15, weight: .bold)).foregroundStyle(Theme.text)
            Spacer()
        }
        .padding(.horizontal, 16).frame(height: 48)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.stroke, lineWidth: Theme.border)))
    }
}


// MARK: - Level badge

/// A small medal chip: "Bronze", "Silver" or "Gold".
struct TierBadge: View {
    let tier: LessonTier
    var compact = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "medal.fill")
            if !compact { Text(tier.name.uppercased()).tracking(0.4) }
        }
        .font(.label(12, weight: .black))
        .foregroundStyle(tier.ink)
        .padding(.horizontal, compact ? 6 : 10)
        .frame(height: 26)
        .background(Capsule().fill(tier.soft))
        .overlay(Capsule().strokeBorder(tier.color, lineWidth: Theme.border))
    }
}

extension LessonTier {
    var color: Color {
        switch self {
        case .bronze: Theme.bronze
        case .silver: Theme.silver
        case .gold: Theme.gold
        }
    }
    var lip: Color { color.mix(with: .black, by: 0.2) }
    var soft: Color { color.mix(with: .white, by: 0.82) }
    var ink: Color { color.mix(with: .black, by: 0.35) }
}
