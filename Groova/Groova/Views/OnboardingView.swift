//
//  OnboardingView.swift
//  Groova
//
//  Runs once, after the first sign in with no account: name, genre, experience, a quick
//  placement check, a daily goal, then the plan. The check skips Foundations units
//  you already know, capped by how much producing you said you've done.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var app
    @Environment(AuthStore.self) private var auth

    enum Page: Int { case hello, name, genre, experience, check, goal, result }

    @State private var page: Page = .hello
    @State private var forward = true
    @State private var name = ""
    @State private var genre: Genre?
    @State private var level: ProducerLevel?
    /// Questions answered right in a row from the start of the check.
    @State private var streak = 0
    @State private var dailyGoal = 50
    @State private var startFromTop = false

    private var flow: [Page] {
        level == .newcomer
            ? [.hello, .name, .genre, .experience, .goal, .result]
            : [.hello, .name, .genre, .experience, .check, .goal, .result]
    }

    private var placement: Int {
        guard let level else { return 0 }
        return min(streak, level.maxPlacement)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                if page != .hello && page != .result { topBar }
                Group {
                    switch page {
                    case .hello: HelloPage(next: next)
                    case .name: NamePage(name: $name, next: next)
                    case .genre:
                        GenrePicker(choice: $genre, title: "What do you want to make?",
                                    subtitle: "Pick a sound to start with, \(firstName). You can switch any time, and each genre keeps its own progress.") { g in
                            Transport.shared.stop()
                            Haptics.select()
                            genre = g
                            next()
                        }
                    case .experience: ExperiencePage(name: firstName, level: $level, next: next)
                    case .check:
                        PlacementCheck(genre: genre ?? .house, limit: level?.maxPlacement ?? 0) { right in
                            streak = right
                            next()
                        }
                    case .goal: GoalPage(goal: $dailyGoal, next: next)
                    case .result:
                        PlanPage(name: firstName, level: level ?? .newcomer, genre: genre ?? .house,
                                 placement: placement, dailyGoal: dailyGoal,
                                 startFromTop: $startFromTop, finish: finish)
                    }
                }
                .id(page)
                .transition(.asymmetric(
                    insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)))
            }
        }
        .onAppear {
            AudioEngine.shared.start()
            if name.isEmpty, let n = auth.session?.displayName, !n.isEmpty { name = n }
        }
    }

    private var firstName: String {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return n.split(separator: " ").first.map(String.init) ?? "friend"
    }

    private var topBar: some View {
        let i = flow.firstIndex(of: page) ?? 0
        return HStack(spacing: 14) {
            Button(action: back) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Theme.textTertiary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(PressScaleStyle())
            .accessibilityLabel("Back")
            .opacity(page == .check ? 0 : 1)
            .disabled(page == .check)
            ProgressBar(value: Double(i) / Double(flow.count - 1), color: Theme.brand)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func next() {
        guard let i = flow.firstIndex(of: page), i + 1 < flow.count else { return }
        forward = true
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { page = flow[i + 1] }
    }

    private func back() {
        guard let i = flow.firstIndex(of: page), i > 0 else { return }
        Haptics.tap()
        Transport.shared.stop()
        forward = false
        var target = flow[i - 1]
        if target == .check { target = .experience } // retaking the check starts it over
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { page = target }
    }

    private func finish() {
        guard let session = auth.session, let genre else { return }
        let placed = startFromTop ? 0 : placement
        Haptics.success()
        app.applyOnboarding(genre: genre, placedUnits: placed, dailyGoal: dailyGoal)
        let account = Account(userID: session.userID, provider: session.provider,
                              displayName: name.trimmingCharacters(in: .whitespacesAndNewlines),
                              email: session.email, level: level ?? .newcomer, genre: genre,
                              placedUnits: placed, dailyGoal: dailyGoal, createdAt: .now)
        Task { await auth.finishOnboarding(account) }
    }
}

// MARK: - Pages

/// Big Woofer, one line, one button. Used for the hello screen.
private struct HelloPage: View {
    let next: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("Hi, I'm Woofer!")
                .font(.display(30))
                .foregroundStyle(Theme.text)
            Text("I'll teach you to make music: beats, chords, melodies, whole songs. First, a few quick questions so I can set up your path. It takes about two minutes.")
                .font(.label(17, weight: .semibold))
                .foregroundStyle(Theme.text)
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 18 + DownBubble.tail)
                .frame(maxWidth: .infinity)
                .background(DownBubble().fill(Theme.brandSoft))
                .padding(.horizontal, 24)
                .padding(.top, 20)
            WooferView(mood: .party, size: 180, bouncing: true)
                .padding(.top, 6)
            Spacer()
            Button("Let's go") {
                Haptics.thump()
                AudioEngine.shared.trigger(.kick, kit: .house)
                next()
            }
            .buttonStyle(ChunkyButtonStyle(color: Theme.brand))
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }
}

private struct NamePage: View {
    @Binding var name: String
    let next: () -> Void
    @FocusState private var focused: Bool

    private var valid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingTitle(text: "What should I call you?")
            WooferCoach(line: "This is how I'll cheer you on. A first name or a producer name both work.", mood: .happy, size: 56)
                .padding(.horizontal, 20)
            TextField("Your name", text: $name)
                .font(.label(20, weight: .bold))
                .foregroundStyle(Theme.text)
                .textContentType(.givenName)
                .submitLabel(.continue)
                .focused($focused)
                .onSubmit { if valid { next() } }
                .padding(.horizontal, 18)
                .frame(height: 60)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surfaceRaised))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(focused ? Theme.brand : Theme.stroke, lineWidth: Theme.border))
                .padding(.horizontal, 20)
                .padding(.top, 24)
            Spacer()
            Button("Continue") { focused = false; next() }
                .buttonStyle(ChunkyButtonStyle(color: Theme.brand, enabled: valid))
                .disabled(!valid)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
        .onAppear { focused = name.isEmpty }
    }
}

private struct ExperiencePage: View {
    let name: String
    @Binding var level: ProducerLevel?
    let next: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingTitle(text: "How much have you produced?")
            ScrollView {
                VStack(spacing: 12) {
                    WooferCoach(line: "Be honest, \(name). If you've done some already, I'll check what you know and skip ahead.",
                                mood: .happy, size: 56)
                        .padding(.bottom, 6)
                    ForEach(ProducerLevel.allCases) { l in
                        ChoiceCard(symbol: l.symbol, title: l.title, detail: l.detail, selected: level == l) {
                            Haptics.select()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { level = l }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            Button("Continue", action: next)
                .buttonStyle(ChunkyButtonStyle(color: Theme.brand, enabled: level != nil))
                .disabled(level == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
    }
}

private struct GoalPage: View {
    @Binding var goal: Int
    let next: () -> Void

    private let options: [(xp: Int, title: String, detail: String, symbol: String)] = [
        (20, "Casual", "About 5 minutes a day", "cup.and.saucer.fill"),
        (50, "Regular", "About 10 minutes a day", "headphones"),
        (100, "Serious", "About 20 minutes a day", "flame.fill"),
        (150, "Studio rat", "30 minutes or more", "bolt.fill"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingTitle(text: "Pick a daily goal")
            ScrollView {
                VStack(spacing: 12) {
                    WooferCoach(line: "Little and often beats one long session. Your ears improve while you sleep on it.",
                                mood: .hint, size: 56)
                        .padding(.bottom, 6)
                    ForEach(options, id: \.xp) { o in
                        ChoiceCard(symbol: o.symbol, title: o.title, detail: o.detail, trailing: "\(o.xp) XP",
                                   selected: goal == o.xp) {
                            Haptics.select()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { goal = o.xp }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            Button("Continue", action: next)
                .buttonStyle(ChunkyButtonStyle(color: Theme.brand))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
    }
}

/// The last screen: your rank, where you start, and the button into the app.
private struct PlanPage: View {
    let name: String
    let level: ProducerLevel
    let genre: Genre
    let placement: Int
    let dailyGoal: Int
    @Binding var startFromTop: Bool
    let finish: () -> Void

    @State private var appeared = false

    private var placed: Int { startFromTop ? 0 : placement }

    private var startTitle: String {
        let core = FoundationCourse.units
        if placed >= core.count {
            return "\(genre.name) course"
        }
        return "\(core[placed].title)"
    }

    private var line: String {
        if placed >= FoundationCourse.units.count {
            return "You know your stuff, \(name). You're skipping Foundations and going straight to the \(genre.name) course. The foundations stay open if you want a refresher."
        }
        if placed > 0 {
            return "Nice work, \(name). You already know the first \(placed == 1 ? "unit" : "\(placed) units"), so I've opened \(placed == 1 ? "it" : "them") up. Jump back any time."
        }
        return level == .newcomer
            ? "Everyone starts somewhere, \(name). We'll begin with the very basics and build from there, one beat at a time."
            : "We'll start at the beginning, \(name). The early lessons go quickly if you know them, and you can test out of any unit."
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    Text(level.rank.uppercased())
                        .font(.label(14, weight: .black)).tracking(1)
                        .foregroundStyle(Theme.brand)
                        .padding(.horizontal, 14).frame(height: 30)
                        .background(Capsule().fill(Theme.brandSoft))
                        .padding(.top, 28)
                    Text("Your path is ready")
                        .font(.display(30))
                        .foregroundStyle(Theme.text)
                        .padding(.top, 10)
                    Text(line)
                        .font(.label(17, weight: .semibold))
                        .foregroundStyle(Theme.text)
                        .lineSpacing(3)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 18 + DownBubble.tail)
                        .frame(maxWidth: .infinity)
                        .background(DownBubble().fill(Theme.brandSoft))
                        .padding(.top, 20)
                        .animation(.easeInOut(duration: 0.2), value: startFromTop)
                    WooferView(mood: .party, size: 150, bouncing: true)
                        .scaleEffect(appeared ? 1 : 0.6)
                        .padding(.top, 4)
                    VStack(spacing: 0) {
                        planRow("music.note.house.fill", "Genre", genre.name)
                        Rectangle().fill(Theme.divider).frame(height: 1)
                        planRow("flag.fill", "You start at", startTitle)
                        Rectangle().fill(Theme.divider).frame(height: 1)
                        planRow("target", "Daily goal", "\(dailyGoal) XP")
                    }
                    .card(padding: 4)
                    .padding(.top, 16)
                    if placement > 0 {
                        Button(startFromTop ? "Use my placement" : "Start from the beginning instead") {
                            Haptics.tap()
                            withAnimation(.spring(response: 0.35)) { startFromTop.toggle() }
                        }
                        .font(.label(15, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            Button("Start my journey", action: finish)
                .buttonStyle(ChunkyButtonStyle(color: Theme.brand))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
        .overlay { if appeared { ConfettiView(colors: [Theme.brand, Theme.gold, Theme.success]).allowsHitTesting(false) } }
        .onAppear {
            AudioEngine.shared.playSuccess()
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { appeared = true }
        }
    }

    private func planRow(_ symbol: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.brand)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.brandSoft))
            Text(label).font(.label(15, weight: .semibold)).foregroundStyle(Theme.textSecondary)
            Spacer(minLength: 8)
            Text(value).font(.label(15, weight: .heavy)).foregroundStyle(Theme.text)
                .multilineTextAlignment(.trailing)
                .contentTransition(.opacity)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

// MARK: - Placement check

/// One question per Foundations unit, in order. A right answer means you can skip that
/// unit. It stops at the first miss (or "I'm not sure"), or once you've reached the most
/// your experience allows, so beginners get a short check and nobody is over-placed.
nonisolated struct PlacementQuestion: Sendable {
    enum Sound: Sendable { case none, kickOrHat, majorOrMinor }
    let unit: Int
    let prompt: String
    let sound: Sound
    let options: [String]
    let answer: Int
    /// Woofer's one-line lesson, shown after you answer either way.
    let why: String

    static let all: [PlacementQuestion] = [
        .init(unit: 1, prompt: "Which sound is the kick drum?", sound: .kickOrHat,
              options: ["Sound A", "Sound B"], answer: 0,
              why: "The kick is the low thump that holds the beat down. The hi-hat is the short, bright tick."),
        .init(unit: 2, prompt: "What does BPM measure?", sound: .none,
              options: ["How loud a track is", "How fast a track is", "How long a track is"], answer: 1,
              why: "BPM is beats per minute: the tempo. Hip-hop often sits around 85 to 95, pop around 100 to 120, house around 124."),
        .init(unit: 3, prompt: "How many semitones are in an octave?", sound: .none,
              options: ["7", "8", "12"], answer: 2,
              why: "Twelve. Count every white and black key from one C up to the next."),
        .init(unit: 4, prompt: "Which chord sounds sadder?", sound: .majorOrMinor,
              options: ["Chord A", "Chord B"], answer: 1,
              why: "Chord B is minor. Its middle note sits one semitone lower than the major chord, and that darkens it."),
        .init(unit: 5, prompt: "What does a low-pass filter do?", sound: .none,
              options: ["Cuts the highs and lets the lows through", "Cuts the lows and lets the highs through", "Makes the sound longer"], answer: 0,
              why: "A low-pass lets the lows pass. Close it down and the sound gets darker and more muffled."),
        .init(unit: 6, prompt: "Why does a verse usually have fewer layers than the chorus?", sound: .none,
              options: ["To save space on the computer", "So the chorus hits harder when it arrives", "Because verses are shorter"], answer: 1,
              why: "Holding back in the verse leaves room to grow. When the chorus adds layers, it feels like a payoff."),
    ]
}

private struct PlacementCheck: View {
    let genre: Genre
    /// The most units this person can skip; the check ends once they reach it.
    let limit: Int
    let done: (Int) -> Void

    @State private var index = 0
    @State private var choice: Int?
    @State private var feedback: StepFeedback?
    @State private var streak = 0

    private var q: PlacementQuestion { PlacementQuestion.all[index] }
    private var count: Int { min(limit, PlacementQuestion.all.count) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("QUICK CHECK · \(index + 1) OF \(count)")
                        .font(.label(14, weight: .black)).tracking(0.6)
                        .foregroundStyle(Theme.brand)
                        .padding(.top, 16)
                    Text(q.prompt)
                        .font(.display(26))
                        .foregroundStyle(Theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                    if index == 0 {
                        WooferCoach(line: "Don't guess. If you're not sure, say so and I'll start you there.", mood: .hint, size: 52)
                    }
                    if q.sound != .none { soundButtons.padding(.vertical, 4) }
                    ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                        AnswerRow(text: option, selected: choice == i, result: result(for: i)) {
                            guard feedback == nil else { return }
                            Haptics.select()
                            choice = i
                        }
                    }
                    Button("I'm not sure") { answer(nil) }
                        .font(.label(15, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                        .opacity(feedback == nil ? 1 : 0)
                        .disabled(feedback != nil)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            StepFooter(feedback: feedback, primaryTitle: "Check", primaryEnabled: choice != nil,
                       onPrimary: { answer(choice) }, onContinue: advance, onRetry: {})
                .environment(\.accent, Theme.brand)
        }
        .id(index)
        .onDisappear { Transport.shared.stop() }
    }

    private func result(for i: Int) -> AnswerRow.Result? {
        guard feedback != nil else { return nil }
        if i == q.answer { return .right }
        if i == choice { return .wrong }
        return nil
    }

    @ViewBuilder
    private var soundButtons: some View {
        HStack(spacing: 12) {
            ForEach(0..<2, id: \.self) { i in
                Button {
                    Haptics.tap()
                    play(i)
                } label: {
                    Label(q.options[i], systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(GhostButtonStyle(textColor: Theme.brand))
            }
        }
    }

    private func play(_ i: Int) {
        switch q.sound {
        case .kickOrHat:
            AudioEngine.shared.trigger(i == 0 ? .kick : .hat, kit: genre.kit)
        case .majorOrMinor:
            AudioEngine.shared.playChord(i == 0 ? [60, 64, 67] : [60, 63, 67], seconds: 0.9, patch: .keys)
        case .none:
            break
        }
    }

    private func answer(_ picked: Int?) {
        let right = picked == q.answer
        if right {
            streak += 1
            AudioEngine.shared.playSuccess()
            feedback = StepFeedback(kind: .success, title: "Nice!", message: q.why, score: nil)
        } else {
            choice = picked
            AudioEngine.shared.playNudge()
            feedback = StepFeedback(kind: .reveal, title: picked == nil ? "No problem" : "Not quite",
                                    message: q.why, score: nil)
        }
    }

    private func advance() {
        let missed = feedback?.kind != .success
        if missed || index + 1 >= count {
            done(streak)
            return
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            index += 1
            choice = nil
            feedback = nil
        }
    }
}

private struct AnswerRow: View {
    enum Result { case right, wrong }
    let text: String
    let selected: Bool
    let result: Result?
    let tap: () -> Void

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 16, style: .continuous) }

    private var tint: Color {
        switch result {
        case .right: Theme.success
        case .wrong: Theme.miss
        case nil: selected ? Theme.brand : Theme.stroke
        }
    }

    private var fill: Color {
        switch result {
        case .right: Theme.successSoft
        case .wrong: Theme.missSoft
        case nil: selected ? Theme.brandSoft : Theme.surface
        }
    }

    var body: some View {
        Button(action: tap) {
            Text(text)
                .font(.label(17, weight: .bold))
                .foregroundStyle(Theme.text)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(shape.fill(fill))
                .overlay(shape.strokeBorder(tint, lineWidth: selected || result != nil ? 2.5 : Theme.border))
                .background(shape.fill(result == nil && !selected ? Theme.stroke : Theme.lip(for: tint)).offset(y: 4))
        }
        .buttonStyle(PressScaleStyle(scale: 0.98))
    }
}

// MARK: - Shared pieces

private struct OnboardingTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.display(28))
            .foregroundStyle(Theme.text)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)
    }
}

/// A selectable card with an icon, used for experience and daily goal.
struct ChoiceCard: View {
    let symbol: String
    let title: String
    let detail: String
    var trailing: String? = nil
    let selected: Bool
    let tap: () -> Void

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 20, style: .continuous) }

    var body: some View {
        Button(action: tap) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(selected ? Theme.onBrand : Theme.brand)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(selected ? Theme.brand : Theme.brandSoft))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.label(18, weight: .heavy)).foregroundStyle(Theme.text)
                    Text(detail).font(.label(14, weight: .medium)).foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let trailing {
                    Text(trailing).font(.label(14, weight: .black))
                        .foregroundStyle(selected ? Theme.brand : Theme.textTertiary)
                }
            }
            .padding(14)
            .background(shape.fill(selected ? Theme.brandSoft : Theme.surface))
            .overlay(shape.strokeBorder(selected ? Theme.brand : Theme.stroke, lineWidth: selected ? 2.5 : Theme.border))
            .background(shape.fill(selected ? Theme.brandLip : Theme.stroke).offset(y: 4))
        }
        .buttonStyle(PressScaleStyle(scale: 0.98))
    }
}

/// Shared by onboarding and the genre switcher.
struct GenrePicker: View {
    @Binding var choice: Genre?
    let title: String
    let subtitle: String
    let onConfirm: (Genre) -> Void
    @Environment(AppState.self) private var app

    private var transport: Transport { Transport.shared }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).font(.display(28)).foregroundStyle(Theme.text)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 14)
            Rectangle().fill(Theme.divider).frame(height: 1)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    WooferCoach(line: subtitle, mood: .happy, size: 56)
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                    ForEach(Genre.allCases) { g in
                        GenreCard(genre: g, selected: choice == g,
                                  level: app.genreProgress(g).xp > 0 ? app.level(g) : nil,
                                  playing: transport.isPlaying(.demo) && transport.source == .demo && previewing == g,
                                  playhead: previewing == g ? transport.step : -1,
                                  onPreview: { preview(g) })
                            .onTapGesture {
                                Haptics.select()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { choice = g }
                                if previewing != g || !transport.isRunning { preview(g) }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            if let choice {
                Button("Start with \(choice.name)") { onConfirm(choice) }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.brand))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onDisappear { transport.stop() }
    }

    @State private var previewing: Genre?

    private func preview(_ g: Genre) {
        if previewing == g && transport.isPlaying(.demo) {
            transport.stop()
            return
        }
        previewing = g
        transport.play(g.demoPattern, genre: g, source: .demo)
    }
}

struct GenreCard: View {
    let genre: Genre
    let selected: Bool
    var level: Int? = nil
    var playing: Bool
    var playhead: Int
    var onPreview: () -> Void

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 22, style: .continuous) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                GenreBadge(genre: genre, size: 68)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(genre.name).font(.display(21)).foregroundStyle(Theme.text)
                            .lineLimit(1).minimumScaleFactor(0.8)
                        if let level {
                            Text("LV \(level)").font(.label(11, weight: .black)).tracking(0.6)
                                .foregroundStyle(Theme.brand)
                                .padding(.horizontal, 8).frame(height: 20)
                                .background(Capsule().fill(selected ? Theme.surface : Theme.brandSoft))
                        }
                        if !genre.hasLessons {
                            Text("PREVIEW").font(.label(10, weight: .black)).tracking(0.8)
                                .foregroundStyle(Theme.textSecondary)
                                .padding(.horizontal, 7).frame(height: 20)
                                .background(Capsule().fill(Theme.surfaceRaised))
                        }
                    }
                    Text(genre.tagline).font(.label(14, weight: .medium)).foregroundStyle(Theme.textSecondary)
                        .lineSpacing(1.5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                playButton
            }
            if playing {
                PatternGlyph(pattern: genre.demoPattern, color: genre.color, playhead: playhead)
                    .frame(height: 40)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            HStack(spacing: 6) {
                ForEach(genre.traits, id: \.self) { t in
                    Text(t).font(.label(12, weight: .bold))
                        .foregroundStyle(selected ? Theme.brand : Theme.textSecondary)
                        .padding(.horizontal, 10).frame(height: 26)
                        .background(Capsule().fill(selected ? Theme.surface : Theme.surfaceRaised))
                }
            }
        }
        .padding(16)
        .background(shape.fill(selected ? Theme.brandSoft : Theme.surface))
        .overlay(shape.strokeBorder(selected ? Theme.brand : Theme.stroke, lineWidth: selected ? 2.5 : Theme.border))
        .background(shape.fill(selected ? Theme.brandLip : Theme.stroke).offset(y: 4))
        .overlay(alignment: .topTrailing) {
            if selected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Theme.onBrand)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Theme.brand))
                    .overlay(Circle().strokeBorder(Theme.background, lineWidth: 3))
                    .offset(x: 6, y: -6)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .contentShape(shape)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: playing)
    }

    private var playButton: some View {
        Button(action: { Haptics.tap(); onPreview() }) {
            Image(systemName: playing ? "stop.fill" : "play.fill")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(playing ? Theme.onBrand : Theme.brand)
                .frame(width: 44, height: 44)
                .background(Circle().fill(playing ? Theme.brandLip : Theme.brandBorder).offset(y: 3))
                .background(Circle().fill(playing ? Theme.brand : Theme.surface))
                .overlay(Circle().strokeBorder(playing ? Color.clear : Theme.brandBorder, lineWidth: 2))
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel(playing ? "Stop \(genre.name) preview" : "Hear \(genre.name)")
    }
}
