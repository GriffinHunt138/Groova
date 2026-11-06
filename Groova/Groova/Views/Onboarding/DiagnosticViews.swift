//
//  DiagnosticViews.swift
//  Groova
//
//  Onboarding: the "what brings you here" page, then four diagnostic questions. After each
//  answer Woofer replies and an insight card animates in with a small chart.
//

import SwiftUI

// MARK: - Purpose

struct PurposePage: View {
    let name: String
    @Binding var goal: LearnerGoal?
    let next: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingTitle(text: "What brings you to Groova?")
            ScrollView {
                VStack(spacing: 14) {
                    WooferCoach(line: "Good to meet you, \(name). Do you want to make your own music, or understand how music works?",
                                mood: .happy, size: 56)
                        .padding(.bottom, 4)
                    ForEach(LearnerGoal.allCases) { g in
                        PurposeCard(goal: g, selected: goal == g) {
                            Haptics.select()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { goal = g }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            Button("Continue", action: next)
                .buttonStyle(ChunkyButtonStyle(color: Theme.brand, enabled: goal != nil))
                .disabled(goal == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
    }
}

/// A tall, chunky card for the two big choices.
private struct PurposeCard: View {
    let goal: LearnerGoal
    let selected: Bool
    let tap: () -> Void

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 24, style: .continuous) }

    var body: some View {
        Button(action: tap) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: goal.symbol)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(selected ? Theme.onBrand : Theme.brand)
                    .frame(width: 64, height: 64)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(selected ? Theme.brand : Theme.brandSoft))
                    .symbolEffect(.bounce, value: selected)
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title).font(.display(24)).foregroundStyle(Theme.text)
                    Text(goal.detail).font(.label(15, weight: .medium)).foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(shape.fill(selected ? Theme.brandSoft : Theme.surface))
            .overlay(shape.strokeBorder(selected ? Theme.brand : Theme.stroke, lineWidth: selected ? 2.5 : Theme.border))
            .background(shape.fill(selected ? Theme.brandLip : Theme.stroke).offset(y: 5))
        }
        .buttonStyle(PressScaleStyle(scale: 0.98))
    }
}

// MARK: - Diagnostic

struct DiagnosticFlow: View {
    let goal: LearnerGoal
    let genre: Genre
    @Binding var answers: [String: String]
    let done: () -> Void

    @State private var index = 0
    @State private var choice: String?
    @State private var showingInsight = false

    private var questions: [DiagnosticQuestion] { Diagnosis.questions(for: goal) }
    private var q: DiagnosticQuestion { questions[index] }
    private var picked: DiagnosticOption? { q.options.first { $0.id == choice } }
    private var isLast: Bool { index == questions.count - 1 }

    var body: some View {
        Group {
            if showingInsight, let picked {
                InsightPage(question: q, option: picked, genre: genre, number: index + 1, total: questions.count,
                            button: isLast ? "Build my path" : "Next question", next: advance)
            } else {
                questionPage
            }
        }
        .id("\(index)-\(showingInsight)")
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)))
    }

    private var questionPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("QUESTION \(index + 1) OF \(questions.count)")
                .font(.label(14, weight: .black)).tracking(0.6)
                .foregroundStyle(Theme.brand)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            OnboardingTitle(text: q.prompt)
            ScrollView {
                VStack(spacing: 12) {
                    WooferCoach(line: q.coach, mood: .hint, size: 52)
                        .padding(.bottom, 4)
                    ForEach(q.options) { o in
                        OptionCard(option: o, selected: choice == o.id) {
                            Haptics.select()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { choice = o.id }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            Button("Continue") {
                guard let choice else { return }
                answers[q.id] = choice
                Haptics.thump()
                withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { showingInsight = true }
            }
            .buttonStyle(ChunkyButtonStyle(color: Theme.brand, enabled: choice != nil))
            .disabled(choice == nil)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }

    private func advance() {
        if isLast {
            done()
            return
        }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            index += 1
            choice = answers[questions[index].id]
            showingInsight = false
        }
    }
}

private struct OptionCard: View {
    let option: DiagnosticOption
    let selected: Bool
    let tap: () -> Void

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 18, style: .continuous) }

    var body: some View {
        Button(action: tap) {
            HStack(spacing: 14) {
                Image(systemName: option.symbol)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(selected ? Theme.onBrand : Theme.brand)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(selected ? Theme.brand : Theme.brandSoft))
                Text(option.title)
                    .font(.label(17, weight: .heavy))
                    .foregroundStyle(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(selected ? Theme.brand : Theme.stroke)
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(14)
            .background(shape.fill(selected ? Theme.brandSoft : Theme.surface))
            .overlay(shape.strokeBorder(selected ? Theme.brand : Theme.stroke, lineWidth: selected ? 2.5 : Theme.border))
            .background(shape.fill(selected ? Theme.brandLip : Theme.stroke).offset(y: 4))
        }
        .buttonStyle(PressScaleStyle(scale: 0.98))
    }
}

// MARK: - Insight

private struct InsightPage: View {
    let question: DiagnosticQuestion
    let option: DiagnosticOption
    let genre: Genre
    let number: Int
    let total: Int
    let button: String
    let next: () -> Void

    @State private var shown = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    WooferCoach(line: option.reply, mood: .happy, size: 56)
                        .padding(.top, 20)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("WHY THIS MATTERS")
                            .font(.label(12, weight: .black)).tracking(0.8)
                            .foregroundStyle(Theme.brand)
                        Text(question.headline)
                            .font(.display(24))
                            .foregroundStyle(Theme.text)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(question.body)
                            .font(.label(15, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                        InsightChartView(chart: question.chart, genre: genre)
                            .padding(.top, 8)
                    }
                    .card()
                    .opacity(shown ? 1 : 0)
                    .offset(y: shown ? 0 : 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { i in
                    Capsule().fill(i < number ? Theme.brand : Theme.surfaceHigh)
                        .frame(width: i == number - 1 ? 22 : 8, height: 8)
                }
            }
            .padding(.bottom, 12)
            Button(button, action: next)
                .buttonStyle(ChunkyButtonStyle(color: Theme.brand))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.1)) { shown = true }
        }
    }
}

// MARK: - Charts

struct InsightChartView: View {
    let chart: InsightChart
    let genre: Genre

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// 0 to 1. Every chart animates off this one value.
    @State private var p: CGFloat = 0

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .onAppear { p = 1 }
    }

    @ViewBuilder private var content: some View {
        switch chart {
        case .path: PathChart(p: p, animate: !reduceMotion)
        case .spaced: SpacedChart(p: p, animate: !reduceMotion)
        case .milestones: MilestoneChart(stops: PathStats.milestones(genre), p: p, animate: !reduceMotion)
        case .skills:
            BarChart(rows: PathStats.skillCounts(genre).map { (symbol: Self.symbol(for: $0.skill), name: $0.skill.name, count: $0.count) },
                     unit: "lessons", caption: "Lessons in your \(genre.name) path, by skill.", p: p, animate: !reduceMotion)
        case .methods:
            BarChart(rows: PathStats.methodCounts(genre),
                     unit: "steps", caption: "Hands-on steps in your \(genre.name) path, before Silver and Gold.", p: p, animate: !reduceMotion)
        case .ear: EarChart(total: PathStats.earRounds, p: p, animate: !reduceMotion)
        }
    }

    static func symbol(for skill: Skill) -> String {
        switch skill {
        case .rhythm: "metronome.fill"
        case .theory: "pianokeys"
        case .soundDesign: "dial.medium.fill"
        case .mixing: "slider.vertical.3"
        case .arrangement: "rectangle.split.3x1.fill"
        }
    }
}

private func chartAnimation(_ animate: Bool, delay: Double = 0, duration: Double = 0.9) -> Animation? {
    animate ? .spring(response: duration, dampingFraction: 0.85).delay(0.2 + delay) : nil
}

private struct Caption: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.label(12, weight: .semibold))
            .foregroundStyle(Theme.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A smooth line through evenly spaced points, each 0 (bottom) to 1 (top).
private struct CurveShape: Shape {
    let points: [CGFloat]

    func path(in r: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        func pt(_ i: Int) -> CGPoint {
            CGPoint(x: r.minX + r.width * CGFloat(i) / CGFloat(points.count - 1), y: r.maxY - r.height * points[i])
        }
        path.move(to: pt(0))
        for i in 1..<points.count {
            let a = pt(i - 1), b = pt(i)
            let mid = (a.x + b.x) / 2
            path.addCurve(to: b, control1: CGPoint(x: mid, y: a.y), control2: CGPoint(x: mid, y: b.y))
        }
        return path
    }
}

/// With a path versus random tutorials. An illustration, and labelled as one.
private struct PathChart: View {
    let p: CGFloat
    let animate: Bool

    private let withPath: [CGFloat] = [0.04, 0.14, 0.27, 0.41, 0.56, 0.71, 0.86, 0.96]
    private let random: [CGFloat] = [0.04, 0.16, 0.11, 0.22, 0.17, 0.26, 0.21, 0.27]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                legend(Theme.brand, "With a path")
                legend(Theme.textTertiary, "Random tutorials")
            }
            ZStack(alignment: .bottomLeading) {
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle().fill(Theme.divider).frame(height: 1)
                        Spacer()
                    }
                    Rectangle().fill(Theme.stroke).frame(height: 2)
                }
                CurveShape(points: random)
                    .trim(from: 0, to: p)
                    .stroke(Theme.textTertiary, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 8]))
                    .animation(chartAnimation(animate, duration: 1.3), value: p)
                CurveShape(points: withPath)
                    .trim(from: 0, to: p)
                    .stroke(Theme.brand, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .shadow(color: Theme.brand.opacity(0.3), radius: 6, y: 3)
                    .animation(chartAnimation(animate, delay: 0.15, duration: 1.4), value: p)
                GeometryReader { g in
                    Image(systemName: "star.fill")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Theme.onBrand)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Theme.gold))
                        .overlay(Circle().strokeBorder(Theme.surface, lineWidth: 3))
                        .scaleEffect(p)
                        .animation(chartAnimation(animate, delay: 1.2, duration: 0.5), value: p)
                        .position(x: g.size.width, y: g.size.height * (1 - withPath[withPath.count - 1]))
                }
            }
            .frame(height: 150)
            .padding(.trailing, 14)
            HStack {
                Text("Skill").font(.label(12, weight: .heavy)).foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("Time →").font(.label(12, weight: .heavy)).foregroundStyle(Theme.textSecondary)
            }
            Caption(text: "Illustration, not measured data.")
        }
    }

    private func legend(_ c: Color, _ text: String) -> some View {
        HStack(spacing: 6) {
            Capsule().fill(c).frame(width: 16, height: 6)
            Text(text).font(.label(12, weight: .bold)).foregroundStyle(Theme.textSecondary)
        }
    }
}

/// One long session versus seven short ones, as blocks that stack up.
private struct SpacedChart: View {
    let p: CGFloat
    let animate: Bool

    private let days = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What sticks a week later")
                .font(.label(13, weight: .heavy)).foregroundStyle(Theme.textSecondary)
            HStack(alignment: .bottom, spacing: 26) {
                column(title: "One 70-minute session") {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Theme.surfaceHigh)
                        .frame(height: 50 * p)
                        .animation(chartAnimation(animate), value: p)
                }
                column(title: "10 minutes × 7 days") {
                    VStack(spacing: 4) {
                        ForEach(Array(days.enumerated()).reversed(), id: \.offset) { i, d in
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(Theme.brand)
                                .overlay(Text(d).font(.label(10, weight: .black)).foregroundStyle(Theme.onBrand))
                                .frame(height: 18)
                                .scaleEffect(p, anchor: .bottom)
                                .opacity(Double(p))
                                .animation(chartAnimation(animate, delay: Double(i) * 0.12, duration: 0.5), value: p)
                        }
                    }
                }
            }
            .frame(height: 200, alignment: .bottom)
            Caption(text: "Illustration based on research into spaced practice.")
        }
    }

    private func column<Content: View>(title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 8) {
            Spacer(minLength: 0)
            content()
            Text(title)
                .font(.label(12, weight: .bold))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
    }
}

/// A staircase of real units, ending in the genre's song project.
private struct MilestoneChart: View {
    let stops: [(code: String, title: String)]
    let p: CGFloat
    let animate: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(stops.enumerated()), id: \.offset) { i, s in
                    let last = i == stops.count - 1
                    VStack(spacing: 6) {
                        Image(systemName: last ? "flag.checkered" : "checkmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Theme.onBrand)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(last ? Theme.gold : Theme.success))
                            .scaleEffect(p)
                            .animation(chartAnimation(animate, delay: Double(i) * 0.22 + 0.25, duration: 0.45), value: p)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(last ? Theme.brand : Theme.brand.opacity(0.35 + 0.18 * Double(i)))
                            .overlay(alignment: .top) {
                                Text(s.code).font(.label(12, weight: .black)).foregroundStyle(Theme.onBrand).padding(.top, 6)
                            }
                            .frame(height: (40 + CGFloat(i) * 30) * p)
                            .animation(chartAnimation(animate, delay: Double(i) * 0.22), value: p)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 170, alignment: .bottom)
            HStack(alignment: .top, spacing: 8) {
                ForEach(Array(stops.enumerated()), id: \.offset) { _, s in
                    Text(s.title)
                        .font(.label(11, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

/// Horizontal bars with icons and counts that tick up.
private struct BarChart: View {
    let rows: [(symbol: String, name: String, count: Int)]
    let unit: String
    let caption: String
    let p: CGFloat
    let animate: Bool

    private var top: Int { max(1, rows.map(\.count).max() ?? 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(rows.enumerated()), id: \.offset) { i, r in
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Image(systemName: r.symbol)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.brand)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Theme.brandSoft))
                        Text(r.name).font(.label(14, weight: .heavy)).foregroundStyle(Theme.text)
                        Spacer()
                        Text("\(r.count) \(unit)").font(.label(13, weight: .black)).foregroundStyle(Theme.textSecondary)
                            .opacity(Double(p))
                            .animation(chartAnimation(animate, delay: Double(i) * 0.12 + 0.4), value: p)
                    }
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.surfaceRaised)
                            Capsule().fill(i == 0 ? Theme.brand : Theme.brand.opacity(0.6))
                                .frame(width: max(12, g.size.width * CGFloat(r.count) / CGFloat(top) * p))
                                .animation(chartAnimation(animate, delay: Double(i) * 0.12), value: p)
                        }
                    }
                    .frame(height: 12)
                }
            }
            Caption(text: caption)
        }
    }
}

/// A ring that fills while the number counts up.
private struct EarChart: View {
    let total: Int
    let p: CGFloat
    let animate: Bool

    @State private var shown = 0

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().stroke(Theme.surfaceRaised, lineWidth: 16)
                Circle()
                    .trim(from: 0, to: p)
                    .stroke(Theme.brand, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(chartAnimation(animate, duration: 1.4), value: p)
                VStack(spacing: 0) {
                    Text("\(shown)")
                        .font(.display(44))
                        .foregroundStyle(Theme.text)
                        .contentTransition(.numericText())
                        .monospacedDigit()
                    Text("listening rounds").font(.label(13, weight: .bold)).foregroundStyle(Theme.textSecondary)
                }
            }
            .frame(width: 170, height: 170)
            Caption(text: "Counted from the Foundations lessons, before Silver and Gold.")
        }
        .task {
            guard animate else { shown = total; return }
            try? await Task.sleep(for: .milliseconds(250))
            let steps = 30
            for i in 1...steps {
                withAnimation(.snappy(duration: 0.04)) { shown = total * i / steps }
                try? await Task.sleep(for: .milliseconds(40))
            }
        }
    }
}
