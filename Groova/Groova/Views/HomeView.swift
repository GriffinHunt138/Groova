//
//  HomeView.swift
//  Groova
//
//  Dashboard + the winding learning path.
//

import Foundation
import SwiftUI

struct HomeView: View {
    let genre: Genre
    @Environment(AppState.self) private var app

    @State private var showGenres = false
    @State private var selectedLesson: Lesson?
    @State private var activeRun: LessonRun?
    @State private var lockedToast: String?

    @State private var showPractice = false
    @State private var testingOut = false

    var body: some View {
        ZStack(alignment: .top) {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
            topBar
            ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    if genre.hasLessons {
                        if app.currentLesson(genre) == nil { allDoneCard }
                    } else {
                        PreviewGenreCard(genre: genre) { showGenres = true }
                    }
                    let units = Curriculum.units(for: genre)
                    ForEach(Array(units.enumerated()), id: \.element.id) { i, unit in
                        VStack(spacing: 24) {
                            if i == 0 {
                                PartHeader(part: .foundations, genre: genre)
                                if showSkipCard { SkipFoundationsCard(genre: genre) }
                            } else if unit.part == .academy && units[i - 1].part == .foundations {
                                PartHeader(part: .academy, genre: genre)
                            }
                            UnitSection(unit: unit, genre: genre) { lesson, state in
                                tap(lesson, state, in: unit)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
            .task(id: genre) {
                // Open on the lesson you're up to, not the top of the list.
                guard let current = app.currentLesson(genre) else { return }
                try? await Task.sleep(for: .milliseconds(60))
                proxy.scrollTo(current.id, anchor: .center)
            }
            }
            }
            if let lockedToast {
                Text(lockedToast)
                    .font(.label(15, weight: .heavy))
                    .foregroundStyle(Theme.onBrand)
                    .padding(.horizontal, 18).frame(height: 46)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.text))
                    .padding(.top, 70)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showPractice) {
            DailyPracticeCard(genre: genre) {
                guard let session = app.makePractice(genre) else { return }
                Haptics.tap()
                showPractice = false
                Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    activeRun = LessonRun(lesson: session.lesson, tier: .bronze, practice: session)
                }
            }
            .padding(20)
            .presentationDetents([.height(360)])
            .presentationBackground(Theme.background)
            .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showGenres) {
            GenreSwitcher(current: genre)
                .presentationDetents([.large])
                .presentationBackground(Theme.background)
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonSheet(lesson: lesson, genre: genre, testOut: testingOut) { tier in
                selectedLesson = nil
                Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    activeRun = LessonRun(lesson: lesson, tier: tier, practice: nil)
                }
            }
            .presentationDetents([.height(lesson.isMastery || !(app.isCompleted(lesson, in: genre) || AppState.unlockEverything) ? 330 : 400)])
            .presentationBackground(Theme.surface)
            .presentationCornerRadius(32)
        }
        .fullScreenCover(item: $activeRun) { run in
            LessonPlayerView(lesson: run.lesson, genre: genre, tier: run.tier, practice: run.practice)
        }
        .onChange(of: app.pendingLessonStart, initial: true) { _, start in
            // The intro guide's last step: open the first lesson straight away.
            guard start else { return }
            app.pendingLessonStart = false
            guard let lesson = app.currentLesson(genre) else { return }
            activeRun = LessonRun(lesson: lesson, tier: .bronze, practice: nil)
        }
    }

    private var showSkipCard: Bool {
        guard !app.skippedFoundations else { return false }
        let core = Curriculum.units(for: genre).filter { $0.part == .foundations }
        let done = core.flatMap(\.lessons).filter { app.isCompleted($0, in: genre) }.count
        return done < 6 && app.frontier(genre) < core.count - 1
    }

    private func tap(_ lesson: Lesson, _ state: NodeState, in unit: Unit) {
        switch state {
        case .locked where app.canTestOut(lesson, in: unit, genre: genre) && !unit.isComingSoon:
            Haptics.tap()
            testingOut = true
            selectedLesson = lesson
        case .locked:
            Haptics.warning()
            withAnimation { lockedToast = unit.isComingSoon ? "This unit is still in the studio." :
                (app.isUnitUnlocked(unit, in: genre) ? "Finish the lesson before this one first." :
                    "Locked. Tap a crown to test out and skip ahead.") }
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation { lockedToast = nil }
            }
        default:
            Haptics.tap()
            testingOut = false
            selectedLesson = lesson
        }
    }

    // MARK: Header

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 18) {
                Button { Haptics.tap(); showGenres = true } label: {
                    HStack(spacing: 8) {
                        GenreIcon(genre: genre, size: 26)
                        Text(genre.name).font(.label(16, weight: .heavy)).foregroundStyle(Theme.text)
                        Image(systemName: "chevron.down").font(.system(size: 10, weight: .black))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .padding(.leading, 14).padding(.trailing, 12).frame(height: 38)
                    .background(Capsule().fill(Theme.surfaceRaised))
                }
                .buttonStyle(PressScaleStyle(scale: 0.96))
                Spacer()
                HStack(spacing: 16) {
                    Button { Haptics.tap(); showPractice = true } label: {
                        PracticeBadge(genre: genre)
                    }
                    .buttonStyle(PressScaleStyle(scale: 0.9))
                    .accessibilityLabel("Daily practice")
                    Pill(symbol: "bolt.fill", text: "\(app.currentStreak)",
                         color: app.practicedToday ? Theme.streak : Theme.textTertiary)
                    Pill(symbol: "star.fill", text: "\(app.progress.totalXP)", color: Theme.brand)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 12)
            Rectangle().fill(Theme.divider).frame(height: 1)
        }
        .background(Theme.background)
    }

    private var allDoneCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("All caught up", systemImage: "checkmark.seal.fill")
                .font(.display(20)).foregroundStyle(Theme.success)
            Text("You've finished every lesson in \(genre.name). Go for Silver and Gold on each one, keep up Daily Practice, or make something in the Sandbox.")
                .font(.label(14, weight: .medium)).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

// MARK: - Parts

/// Heads each half of the path: Core Foundations, then the genre's academy.
struct PartHeader: View {
    let part: CoursePart
    let genre: Genre
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(part == .foundations ? "PART 1 · FOUNDATIONS" : "PART 2 · \(genre.name.uppercased())")
                .font(.label(12, weight: .black)).tracking(1.2)
                .foregroundStyle(genre.color)
            Text(part == .foundations
                 ? "The skills every producer needs, whatever you make. Shared by every genre."
                 : genre.academyFocus)
                .font(.label(14, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if part == .foundations && app.skippedFoundations {
                HStack(spacing: 8) {
                    Text("Skipped. Every lesson here is still open.")
                        .font(.label(13, weight: .bold)).foregroundStyle(Theme.textTertiary)
                    Button("Undo") {
                        Haptics.tap()
                        withAnimation { app.skipFoundations(false) }
                    }
                    .font(.label(13, weight: .heavy))
                    .foregroundStyle(genre.color)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

/// For producers who already know the basics: start at the academy instead.
struct SkipFoundationsCard: View {
    let genre: Genre
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Already making music?", systemImage: "forward.fill")
                .font(.label(16, weight: .heavy)).foregroundStyle(Theme.text)
            Text("Skip Foundations and start the \(genre.name) course. The foundation lessons stay open, so you can dip back in any time. You can also tap any crown to test out of a single unit.")
                .font(.label(14, weight: .medium)).foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Skip to \(genre.name)") {
                Haptics.success()
                withAnimation { app.skipFoundations() }
            }
            .buttonStyle(ChunkyButtonStyle(color: genre.color))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

// MARK: - Preview genre

struct PreviewGenreCard: View {
    let genre: Genre
    let onSwitch: () -> Void
    private var transport: Transport { Transport.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("In the studio", systemImage: "hammer.fill")
                .font(.label(12, weight: .heavy)).tracking(1)
                .foregroundStyle(genre.color)
            Text("\(genre.name) lessons are still being produced.")
                .font(.display(22)).foregroundStyle(Theme.text)
            Text("We'd rather ship it right than ship it fake. Here's the sound you'll learn to make — and what's coming.")
                .font(.label(14, weight: .medium)).foregroundStyle(Theme.textSecondary)
            PatternGlyph(pattern: genre.demoPattern, color: genre.color,
                         playhead: transport.isPlaying(.demo) ? transport.step : -1)
                .frame(height: 50)
            HStack(spacing: 10) {
                TransportButton(title: transport.isPlaying(.demo) ? "Stop" : "Hear \(genre.name)",
                                symbol: transport.isPlaying(.demo) ? "stop.fill" : "play.fill",
                                active: transport.isPlaying(.demo), color: genre.color) {
                    transport.toggle(genre.demoPattern, genre: genre, source: .demo)
                }
                Spacer()
                Button("Switch genre", action: onSwitch)
                    .font(.label(14, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .card(padding: 20)
        .onDisappear { if transport.isPlaying(.demo) { transport.stop() } }
    }
}

// MARK: - Path

struct UnitSection: View {
    let unit: Unit
    let genre: Genre
    let onTap: (Lesson, NodeState) -> Void
    @Environment(AppState.self) private var app

    private let rowHeight: CGFloat = 150

    var body: some View {
        let unlocked = app.isUnitUnlocked(unit, in: genre) && !unit.isComingSoon
        VStack(spacing: 28) {
            UnitBanner(unit: unit, genre: genre, unlocked: unlocked,
                       completed: unit.lessons.filter { app.isCompleted($0, in: genre) }.count)
                .padding(.top, 12)
            if unit.isComingSoon {
                plannedPath
            } else {
                path
            }
        }
    }

    private func xOffset(_ i: Int, width: CGFloat) -> CGFloat {
        let amp = min(78, width * 0.2)
        return sin(Double(i) * 1.15) * amp
    }

    /// Where the path is furthest to one side: sin(t * 1.15) = ±1.
    private struct Peak { let k: Int; let t: CGFloat; let right: Bool; let lesson: Int }

    private var peaks: [Peak] {
        let n = unit.lessons.count
        var out: [Peak] = []
        var k = 0
        while true {
            let t = (Double.pi / 2 + Double(k) * Double.pi) / 1.15
            if t > Double(n) - 0.6 { break }
            out.append(Peak(k: k, t: CGFloat(t), right: k.isMultiple(of: 2), lesson: min(n - 1, Int(t.rounded()))))
            k += 1
        }
        return out
    }

    private var path: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let centers = unit.lessons.indices.map { i in
                CGPoint(x: w / 2 + xOffset(i, width: w), y: rowHeight * (CGFloat(i) + 0.5))
            }
            ZStack {
                // Connectors
                Path { p in
                    guard let first = centers.first else { return }
                    p.move(to: first)
                    for i in 1..<max(1, centers.count) {
                        let a = centers[i - 1], b = centers[i]
                        p.addCurve(to: b, control1: CGPoint(x: a.x, y: (a.y + b.y) / 2),
                                   control2: CGPoint(x: b.x, y: (a.y + b.y) / 2))
                    }
                }
                .stroke(Theme.surfaceHigh, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [0.5, 11]))

                ForEach(Array(unit.lessons.enumerated()), id: \.element.id) { i, lesson in
                    let state = app.state(of: lesson, in: unit, genre: genre)
                    PathNode(lesson: lesson, state: state, genre: genre,
                             tier: app.tier(of: lesson, in: genre),
                             faded: app.needsPractice(lesson, in: genre)) {
                        onTap(lesson, state)
                    }
                    .id(lesson.id)
                    .position(centers[i])
                }

                // At each bend, where the path swings to one side, Woofer fills the open space
                // on the other. He stays grey until you reach the lesson beside him.
                ForEach(peaks, id: \.k) { peak in
                    let amp = min(78, w * 0.2)
                    let freeCenter = (w / 2 + amp - 40) / 2
                    let x = peak.right ? freeCenter : w - freeCenter
                    let lesson = unit.lessons[peak.lesson]
                    let all = WooferActivity.allCases
                    WooferScene(activity: all[(unit.number * 3 + peak.k) % all.count],
                                size: 118,
                                active: app.state(of: lesson, in: unit, genre: genre) != .locked)
                        .position(x: x, y: rowHeight * (peak.t + 0.5))
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(height: rowHeight * CGFloat(unit.lessons.count))
    }

    private var plannedPath: some View {
        VStack(spacing: 10) {
            ForEach(Array(unit.plannedLessons.enumerated()), id: \.offset) { i, title in
                HStack(spacing: 14) {
                    Circle()
                        .strokeBorder(Theme.surfaceHigh, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .frame(width: 40, height: 40)
                        .overlay(Image(systemName: "lock.fill").font(.system(size: 13)).foregroundStyle(Theme.textTertiary))
                    Text(title).font(.label(15, weight: .semibold)).foregroundStyle(Theme.textTertiary)
                    Spacer()
                }
            }
        }
        .card()
    }
}

struct UnitBanner: View {
    let unit: Unit
    let genre: Genre
    let unlocked: Bool
    let completed: Int

    var body: some View {
        let ink: Color = unlocked ? Theme.onBrand : Theme.textTertiary
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.label)
                    .font(.label(12, weight: .black)).tracking(1.2)
                    .foregroundStyle(ink.opacity(unlocked ? 0.7 : 1))
                Text(unit.title)
                    .font(.display(22))
                    .foregroundStyle(unlocked ? Theme.onBrand : Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(unit.isComingSoon ? (unlocked ? "Unlocked · lessons arriving soon" : "Coming soon") : unit.subtitle)
                    .font(.label(14, weight: .semibold))
                    .foregroundStyle(ink.opacity(unlocked ? 0.8 : 1))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if unit.isComingSoon {
                Image(systemName: "lock.fill").font(.system(size: 18, weight: .bold)).foregroundStyle(Theme.textTertiary)
            } else {
                UnitProgressRing(done: completed, total: unit.lessons.count, unlocked: unlocked)
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(unlocked ? genre.color : Theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(unlocked ? .clear : Theme.stroke, lineWidth: Theme.border))
        )
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(unlocked ? genre.deepColor : Theme.stroke)
                .offset(y: 4)
        )
    }
}

/// How much of a unit is done, as a ring with the count inside.
struct UnitProgressRing: View {
    let done: Int
    let total: Int
    let unlocked: Bool

    var body: some View {
        let track: Color = unlocked ? .white.opacity(0.22) : Theme.surfaceHigh
        let fill: Color = unlocked ? .white : Theme.textTertiary
        ZStack {
            Circle().stroke(track, lineWidth: 5)
            Circle()
                .trim(from: 0, to: total == 0 ? 0 : CGFloat(done) / CGFloat(total))
                .stroke(fill, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(done)/\(total)")
                .font(.label(13, weight: .black)).monospacedDigit()
                .foregroundStyle(unlocked ? Theme.onBrand : Theme.textTertiary)
        }
        .frame(width: 54, height: 54)
        .accessibilityLabel("\(done) of \(total) lessons done")
    }
}

struct PathNode: View {
    let lesson: Lesson
    let state: NodeState
    let genre: Genre
    var tier = 0
    var faded = false
    let onTap: () -> Void

    @State private var bob = false

    var body: some View {
        let size: CGFloat = state == .current ? 80 : 72
        let locked = state == .locked
        let fill: Color = locked ? Theme.surfaceHigh : genre.color
        let lip: Color = locked ? Theme.lockedLip : genre.deepColor
        let symbol: String = {
            if state == .completed { return lesson.isMastery ? "crown.fill" : "checkmark" }
            if locked { return lesson.isMastery ? "crown.fill" : "lock.fill" }
            return lesson.isMastery ? "crown.fill" : "star.fill"
        }()
        Button(action: onTap) {
            ZStack {
                if state == .current {
                    Circle().strokeBorder(Theme.brandSoft, lineWidth: 8)
                        .frame(width: size + 26, height: size + 26)
                }
                Circle().fill(lip)
                    .frame(width: size, height: size)
                    .offset(y: 6)
                Circle().fill(fill)
                    .frame(width: size, height: size)
                Image(systemName: symbol)
                    .font(.system(size: state == .current ? 34 : 28, weight: .black))
                    .foregroundStyle(locked ? Theme.textTertiary : Theme.onBrand)
            }
        }
        .buttonStyle(PressScaleStyle(scale: 0.92))
        .overlay(alignment: .topTrailing) {
            if faded {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Theme.onBrand)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(Theme.streak))
                    .overlay(Circle().strokeBorder(Theme.background, lineWidth: 3))
                    .offset(x: 4, y: -4)
                    .accessibilityLabel("Needs practice")
            }
        }
        .overlay(alignment: .top) {
            if state == .current {
                Text(lesson.isMastery ? "CHALLENGE" : "START")
                    .font(.label(13, weight: .black)).tracking(1)
                    .foregroundStyle(Theme.onBrand)
                    .padding(.horizontal, 14).frame(height: 30)
                    .background(Capsule().fill(Theme.text))
                    .fixedSize()
                    .alignmentGuide(.top) { $0[.bottom] }
                    .offset(y: bob ? -8 : -4)
            }
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 4) {
                Text(lesson.title)
                    .font(.label(14, weight: state == .current ? .black : .bold))
                    .foregroundStyle(locked ? Theme.textTertiary : (state == .current ? Theme.text : Theme.textSecondary))
                if state == .completed && !lesson.isMastery {
                    TierStars(earned: tier)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Theme.background))
            .fixedSize()
            .alignmentGuide(.bottom) { $0[.top] }
            .offset(y: 14)
        }
        .onAppear {
            guard state == .current else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { bob = true }
        }
        .accessibilityLabel("\(lesson.title), \(state == .completed ? "completed" : state == .current ? "current lesson" : state == .open ? "open" : "locked")")
    }
}

// MARK: - Lesson sheet

struct LessonSheet: View {
    let lesson: Lesson
    let genre: Genre
    var testOut = false
    let onStart: (LessonTier) -> Void
    @Environment(AppState.self) private var app
    @State private var tier: LessonTier = .bronze

    var body: some View {
        let done = app.isCompleted(lesson, in: genre)
        let earned = app.tier(of: lesson, in: genre)
        let replay = earned >= tier.rawValue
        let color = genre.color
        VStack(spacing: 0) {
            Image(systemName: lesson.symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.onBrand)
                .frame(width: 52, height: 52)
                .background(Circle().fill(color))
                .padding(.bottom, 14)
            Text(lesson.title)
                .font(.display(26))
                .foregroundStyle(Theme.text)
                .multilineTextAlignment(.center)
            Text(meta(replay: replay))
                .font(.label(14, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
                .padding(.top, 6)
            if (done || AppState.unlockEverything) && !lesson.isMastery {
                TierSegment(selected: $tier, earned: earned, color: color) { t in
                    app.isTierAvailable(t, for: lesson, in: genre)
                }
                .padding(.top, 26)
            }
            Text(description(done: done))
                .font(.label(15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: tier)
            Spacer(minLength: 20)
            Button(buttonTitle(done: done, replay: replay)) { onStart(tier) }
                .buttonStyle(ChunkyButtonStyle(color: color))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 20)
        .onAppear { tier = app.nextTier(for: lesson, in: genre) }
    }

    /// One quiet line: skill, XP and best score.
    private func meta(replay: Bool) -> String {
        var parts = [lesson.skill.name, "+\(AppState.xp(for: lesson, tier: tier, replay: replay)) XP"]
        if let best = app.bestScore(lesson, in: genre) { parts.append("Best \(best)%") }
        return parts.joined(separator: "  ·  ")
    }

    private func description(done: Bool) -> String {
        if lesson.isMastery {
            if testOut && !done { return "Already know this? Pass to open everything up to the next unit." }
            return done ? "Replay the challenge to keep it sharp." : "Pass it to unlock the next unit."
        }
        if !done { return lesson.subtitle }
        switch tier {
        case .bronze: return "Learn it, with every guide on."
        case .silver: return "Apply it by ear, with no beat guide."
        case .gold: return "Master it with more parts, then make your own."
        }
    }

    private func buttonTitle(done: Bool, replay: Bool) -> String {
        if !done { return lesson.isMastery ? (testOut ? "Test out" : "Start challenge") : "Start lesson" }
        if lesson.isMastery { return "Play again" }
        return replay ? "Replay \(tier.name)" : "Go for \(tier.name)"
    }
}

/// Bronze, Silver and Gold as one sleek segmented control.
struct TierSegment: View {
    @Binding var selected: LessonTier
    let earned: Int
    let color: Color
    let isAvailable: (LessonTier) -> Bool
    @Namespace private var knob

    var body: some View {
        HStack(spacing: 4) {
            ForEach(LessonTier.allCases) { t in
                segment(t)
            }
        }
        .padding(4)
        .background(Capsule().fill(Theme.surfaceRaised))
    }

    private func segment(_ t: LessonTier) -> some View {
        let open = isAvailable(t)
        let isOn = selected == t
        let ink: Color = !open ? Theme.textTertiary : (isOn ? Theme.text : Theme.textSecondary)
        return Button {
            Haptics.select()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selected = t }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: open ? (earned >= t.rawValue ? "checkmark.circle.fill" : "medal.fill") : "lock.fill")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(open ? t.color : Theme.textTertiary)
                Text(t.name)
                    .font(.label(14, weight: .heavy))
                    .foregroundStyle(ink)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background {
                if isOn {
                    Capsule().fill(Theme.surface)
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                        .matchedGeometryEffect(id: "knob", in: knob)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!open)
        .accessibilityLabel("\(t.name)\(earned >= t.rawValue ? ", earned" : "")\(open ? "" : ", locked")")
    }
}

/// One of the three level chips in the lesson sheet.
struct TierChip: View {
    let tier: LessonTier
    let earned: Bool
    let available: Bool
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: available ? "medal.fill" : "lock.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(available ? tier.color : Theme.textTertiary)
                Text(tier.name)
                    .font(.label(13, weight: .heavy))
                    .foregroundStyle(available ? (selected ? tier.ink : Theme.textSecondary) : Theme.textTertiary)
                if earned {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Theme.success)
                } else {
                    Color.clear.frame(height: 12)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(LipStyle(fill: selected ? tier.soft : Theme.surface,
                              lip: selected ? tier.color : Theme.stroke,
                              border: selected ? tier.color : Theme.stroke,
                              radius: 14, depth: 3))
        .disabled(!available)
        .accessibilityLabel("\(tier.name)\(earned ? ", earned" : "")\(available ? "" : ", locked")")
    }
}

/// Three little medals under a finished lesson on the path.
struct TierStars: View {
    let earned: Int

    var body: some View {
        HStack(spacing: 3) {
            ForEach(LessonTier.allCases) { t in
                Image(systemName: "star.fill")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(earned >= t.rawValue ? t.color : Theme.surfaceHigh)
            }
        }
        .accessibilityLabel("\(earned) of 3 levels")
    }
}

/// Run of a lesson in the full-screen player.
struct LessonRun: Identifiable {
    let id = UUID()
    let lesson: Lesson
    let tier: LessonTier
    let practice: PracticeSession?
}

// MARK: - Daily Practice

/// Top-bar shortcut to Daily Practice: today's XP goal as a ring around a dumbbell.
struct PracticeBadge: View {
    let genre: Genre
    @Environment(AppState.self) private var app

    var body: some View {
        let goal = max(1, app.progress.dailyGoal)
        let value = min(1, Double(app.xpToday) / Double(goal))
        let done = app.practicedDrillsToday
        ZStack {
            Circle().stroke(Theme.surfaceHigh, lineWidth: 3.5)
            Circle()
                .trim(from: 0, to: value)
                .stroke(value >= 1 ? Theme.success : Theme.gold, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: done ? "checkmark" : "dumbbell.fill")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(done ? Theme.success : genre.color)
        }
        .frame(width: 32, height: 32)
    }
}

struct DailyPracticeCard: View {
    let genre: Genre
    let onStart: () -> Void
    @Environment(AppState.self) private var app

    var body: some View {
        let available = !app.practiceCandidates(genre).isEmpty
        let done = app.practicedDrillsToday
        let faded = app.fadedCount(genre)
        let goal = max(1, app.progress.dailyGoal)
        let today = app.xpToday
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: done ? "checkmark" : "dumbbell.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(done ? Theme.onBrand : (available ? genre.color : Theme.textTertiary))
                    .frame(width: 48, height: 48)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(done ? Theme.success : (available ? Theme.brandSoft : Theme.surfaceRaised)))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily Practice").font(.display(19)).foregroundStyle(Theme.text)
                    Text(subtitle(available: available, done: done))
                        .font(.label(13, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            if available && faded > 0 && !done {
                Label("\(faded) lesson\(faded == 1 ? "" : "s") need\(faded == 1 ? "s" : "") a refresh",
                      systemImage: "arrow.counterclockwise")
                    .font(.label(13, weight: .heavy))
                    .foregroundStyle(Theme.streak)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("DAILY GOAL").font(.label(11, weight: .black)).tracking(0.6)
                        .foregroundStyle(Theme.textTertiary)
                    Spacer()
                    Text("\(min(today, goal)) / \(goal) XP").font(.label(12, weight: .heavy)).monospacedDigit()
                        .foregroundStyle(today >= goal ? Theme.successInk : Theme.textSecondary)
                }
                ProgressBar(value: Double(today) / Double(goal),
                            color: today >= goal ? Theme.success : Theme.gold, height: 10)
                    .frame(height: 10)
            }
            if available {
                Button(done ? "Practise again" : "Start practice", action: onStart)
                    .buttonStyle(ChunkyButtonStyle(color: done ? Theme.surfaceHigh : genre.color,
                                                   textColor: done ? Theme.textSecondary : Theme.onBrand,
                                                   height: 46))
            }
        }
        .card(padding: 20)
    }

    private func subtitle(available: Bool, done: Bool) -> String {
        if !available { return "Finish your first lesson and a quick daily review unlocks here." }
        if done { return "Done for today. Nice work keeping it fresh." }
        return "A few quick drills picked from what you've learned."
    }
}

// MARK: - Genre switcher

struct GenreSwitcher: View {
    let current: Genre
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var choice: Genre?

    var body: some View {
        GenrePicker(choice: $choice, title: "Switch genre",
                    subtitle: "Each genre has its own levels and XP. Nothing is lost when you switch.") { g in
            Transport.shared.stop()
            app.select(g)
            Haptics.success()
            dismiss()
        }
        .onAppear { choice = current }
    }
}
