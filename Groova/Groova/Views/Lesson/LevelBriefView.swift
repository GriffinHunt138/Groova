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

    /// This lesson's own explanation: the first paragraph of the step body that isn't a pro tip.
    private var line: String {
        let para = step.body.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty && !$0.hasPrefix("Pro tip:") }
        if let para { return para }
        return level == .gold
            ? "Bigger versions with more to control, all by ear. Then you finish with one of your own."
            : "Same idea, new material. You'll work it out by ear, with the beat guide off."
    }

    private var headline: String {
        let t = step.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? lessonTitle : t
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        Text("\(level.name.uppercased()) · \(level.focus.uppercased())")
                            .font(.label(14, weight: .black)).tracking(1)
                            .foregroundStyle(level.ink)
                        Text(headline)
                            .font(.display(30))
                            .foregroundStyle(Theme.text)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 6)
                        if headline != lessonTitle {
                            Text(lessonTitle)
                                .font(.label(15, weight: .bold))
                                .foregroundStyle(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
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
                            .background(DownBubble().fill(level.soft))
                            .padding(.top, 24)
                            .opacity(appeared ? 1 : 0)
                        ZStack(alignment: .bottomTrailing) {
                            WooferView(mood: .happy, size: 170, bouncing: true)
                            ZStack {
                                Circle().fill(level.lip).frame(width: 48, height: 48).offset(y: 3)
                                Circle().fill(level.color).frame(width: 48, height: 48)
                                Image(systemName: "medal.fill")
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundStyle(.white)
                                    .symbolEffect(.bounce, value: appeared)
                            }
                            .offset(x: 6, y: -8)
                        }
                        .scaleEffect(appeared ? 1 : 0.6)
                        .padding(.top, 6)
                        Text("\(tasks) \(tasks == 1 ? "task" : "tasks")")
                            .font(.label(15, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.top, 14)
                        Spacer(minLength: 0)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geo.size.height)
                }
            }
            StepFooter(feedback: nil, primaryTitle: "Let's go", primaryEnabled: true,
                       onPrimary: { onComplete(1) }, onContinue: {}, onRetry: {})
                .environment(\.accent, level.color)
        }
        .accessibilityElement(children: .contain)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { appeared = true }
        }
    }
}
