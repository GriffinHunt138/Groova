//
//  LevelBriefView.swift
//  Groova
//
//  The opening card of a Silver or Gold level: what you're about to learn and how this level differs.
//

import Foundation
import SwiftUI

struct LevelBriefView: View {
    let step: IntroStep
    let level: LessonTier
    let lessonTitle: String
    /// Graded tasks in this level.
    let tasks: Int
    let genre: Genre
    let onComplete: (Double) -> Void

    @State private var appeared = false

    /// First paragraph is the teaching point; a "Pro tip:" paragraph becomes its own card.
    private var paragraphs: [String] {
        step.body.components(separatedBy: "\n\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    private var idea: String { paragraphs.first { !$0.hasPrefix("Pro tip:") } ?? step.body }
    private var tip: String? {
        paragraphs.first { $0.hasPrefix("Pro tip:") }
            .map { String($0.dropFirst("Pro tip:".count)).trimmingCharacters(in: .whitespaces) }
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 20) {
                        hero
                        ideaCard
                        if let tip { tipCard(tip) }
                        facts
                        Spacer(minLength: 0)
                        ladder
                    }
                    .padding(20)
                    .frame(minHeight: geo.size.height)
                }
            }
            StepFooter(feedback: nil, primaryTitle: "Let's go", primaryEnabled: true,
                       onPrimary: { onComplete(1) }, onContinue: {}, onRetry: {})
                .environment(\.accent, level.color)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { appeared = true }
        }
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                WooferView(mood: .happy, size: 116, bouncing: true)
                ZStack {
                    Circle().fill(level.lip).frame(width: 40, height: 40).offset(y: 3)
                    Circle().fill(level.color).frame(width: 40, height: 40)
                    Image(systemName: "medal.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: appeared)
                }
                .offset(x: 4, y: -6)
            }
            .scaleEffect(appeared ? 1 : 0.6)
            VStack(spacing: 6) {
                Text("\(level.name.uppercased()) · \(level.focus.uppercased())")
                    .font(.label(13, weight: .black)).tracking(1)
                    .foregroundStyle(level.ink)
                Text(step.title)
                    .font(.display(30))
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text(lessonTitle)
                    .font(.label(15, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(level.soft))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(level.color.opacity(0.35), lineWidth: Theme.border))
    }

    // MARK: Teaching point

    private var ideaCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("THE IDEA", systemImage: "book.fill")
                .font(.label(12, weight: .black)).tracking(0.8)
                .foregroundStyle(genre.color)
            Text(idea)
                .font(.label(17, weight: .semibold))
                .foregroundStyle(Theme.text)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 18)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func tipCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            WooferView(mood: .hint, size: 46)
            VStack(alignment: .leading, spacing: 4) {
                Text("PRO TIP").font(.label(12, weight: .black)).tracking(0.8)
                    .foregroundStyle(Theme.gold.mix(with: .black, by: 0.3))
                Text(text)
                    .font(.label(15, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .card(padding: 16)
        .opacity(appeared ? 1 : 0)
    }

    // MARK: What's in this level

    private var facts: some View {
        HStack(spacing: 10) {
            fact(symbol: "checklist", value: "\(tasks)", label: tasks == 1 ? "Task" : "Tasks")
            fact(symbol: "ear.fill", value: "By ear", label: "Listening")
            if level == .gold {
                fact(symbol: "wand.and.stars", value: "Yours", label: "Final brief")
            } else {
                fact(symbol: "eye.slash.fill", value: "Off", label: "Beat guide")
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private func fact(symbol: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(level.ink)
            Text(value).font(.display(18)).foregroundStyle(Theme.text)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(label.uppercased()).font(.label(10, weight: .black)).tracking(0.5)
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(Theme.stroke, lineWidth: Theme.border))
    }

    // MARK: Ladder

    private var ladder: some View {
        HStack(spacing: 0) {
            ForEach(LessonTier.allCases) { t in
                let reached = t.rawValue <= level.rawValue
                VStack(spacing: 6) {
                    Image(systemName: t == level ? "medal.fill" : (reached ? "checkmark" : "lock.fill"))
                        .font(.system(size: t == level ? 18 : 13, weight: .black))
                        .foregroundStyle(reached ? .white : Theme.textTertiary)
                        .frame(width: t == level ? 44 : 34, height: t == level ? 44 : 34)
                        .background(Circle().fill(reached ? t.color : Theme.surfaceHigh))
                    Text(t.focus)
                        .font(.label(12, weight: t == level ? .black : .bold))
                        .foregroundStyle(t == level ? t.ink : Theme.textTertiary)
                }
                .frame(width: 84)
                if t != .gold {
                    Capsule()
                        .fill(t.rawValue < level.rawValue ? t.color.opacity(0.6) : Theme.surfaceHigh)
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
}
