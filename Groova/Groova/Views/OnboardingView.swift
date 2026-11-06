//
//  OnboardingView.swift
//  Groova
//
//  Runs once, after the first sign in with no account: name, why you're here (making music
//  or understanding it), genre, experience, four diagnostic questions with an insight after
//  each, a daily goal, then the plan. The diagnostic lives in Onboarding/DiagnosticViews.swift.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var app
    @Environment(AuthStore.self) private var auth

    enum Page: Int { case hello, name, purpose, genre, experience, diagnose, goal, result }

    @State private var page: Page = .hello
    @State private var forward = true
    @State private var name = ""
    @State private var genre: Genre?
    @State private var level: ProducerLevel?
    @State private var purpose: LearnerGoal?
    /// Diagnostic answers: question id to option id.
    @State private var answers: [String: String] = [:]
    @State private var dailyGoal = 50

    private let flow: [Page] = [.hello, .name, .purpose, .genre, .experience, .diagnose, .goal, .result]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                if page != .hello && page != .result { topBar }
                Group {
                    switch page {
                    case .hello: HelloPage(next: next)
                    case .name: NamePage(name: $name, next: next)
                    case .purpose: PurposePage(name: firstName, goal: $purpose, next: next)
                    case .genre:
                        GenrePicker(choice: $genre, title: purpose == .knowledge ? "What do you listen to?" : "What do you want to make?",
                                    subtitle: "Pick a sound to start with, \(firstName). You can switch any time, and each genre keeps its own progress.") { g in
                            Transport.shared.stop()
                            Haptics.select()
                            genre = g
                            next()
                        }
                    case .experience: ExperiencePage(name: firstName, level: $level, next: next)
                    case .diagnose:
                        DiagnosticFlow(goal: purpose ?? .production, genre: genre ?? .house, answers: $answers, done: next)
                    case .goal: GoalPage(goal: $dailyGoal, next: next)
                    case .result:
                        PlanPage(name: firstName, level: level ?? .newcomer, genre: genre ?? .house,
                                 purpose: purpose ?? .production, focus: focus, dailyGoal: dailyGoal, finish: finish)
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

    /// The answer to the last diagnostic question: what they most want out of it.
    private var focus: String? {
        guard let q = Diagnosis.questions(for: purpose ?? .production).last, let id = answers[q.id] else { return nil }
        return q.options.first { $0.id == id }?.title
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
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { page = flow[i - 1] }
    }

    private func finish() {
        guard let session = auth.session, let genre else { return }
        Haptics.success()
        app.applyOnboarding(genre: genre, placedUnits: 0, dailyGoal: dailyGoal)
        let account = Account(userID: session.userID, provider: session.provider,
                              displayName: name.trimmingCharacters(in: .whitespacesAndNewlines),
                              email: session.email, level: level ?? .newcomer, genre: genre,
                              placedUnits: 0, dailyGoal: dailyGoal, createdAt: .now,
                              purpose: purpose, diagnosis: answers)
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
                    WooferCoach(line: "Be honest, \(name). It changes how fast I take you through the basics.",
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

/// The last screen: your rank, what you're focusing on, and the button into the app.
private struct PlanPage: View {
    let name: String
    let level: ProducerLevel
    let genre: Genre
    let purpose: LearnerGoal
    let focus: String?
    let dailyGoal: Int
    let finish: () -> Void

    @State private var appeared = false

    private var startTitle: String { FoundationCourse.units.first?.title ?? "Foundations" }

    private var line: String {
        let aim = purpose == .production ? "making music you're proud of" : "really understanding the music you hear"
        return level == .newcomer
            ? "Everyone starts somewhere, \(name). We'll begin with the basics and build up to \(aim), one small win at a time."
            : "Let's go, \(name). The early lessons fly by if you know them, and you can skip Foundations from your path any time. Next stop: \(aim)."
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
                    WooferView(mood: .party, size: 150, bouncing: true)
                        .scaleEffect(appeared ? 1 : 0.6)
                        .padding(.top, 4)
                    VStack(spacing: 0) {
                        planRow(purpose.symbol, "Here to", purpose.title)
                        Rectangle().fill(Theme.divider).frame(height: 1)
                        if let focus {
                            planRow("scope", "Focus", focus)
                            Rectangle().fill(Theme.divider).frame(height: 1)
                        }
                        planRow("music.note.house.fill", "Genre", genre.name)
                        Rectangle().fill(Theme.divider).frame(height: 1)
                        planRow("flag.fill", "You start at", startTitle)
                        Rectangle().fill(Theme.divider).frame(height: 1)
                        planRow("target", "Daily goal", "\(dailyGoal) XP")
                    }
                    .card(padding: 4)
                    .padding(.top, 16)
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

// MARK: - Shared pieces

struct OnboardingTitle: View {
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
