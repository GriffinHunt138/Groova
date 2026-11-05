//
//  IntroGuideView.swift
//  Groova
//
//  A three-stop tour the first time you land in the app: your path, the Sandbox, then your
//  first lesson. Each stop switches to the tab it's talking about, with Woofer explaining.
//

import Foundation
import SwiftUI

enum AppTab: Hashable { case learn, sandbox, profile }

struct IntroGuideView: View {
    let genre: Genre
    @Binding var tab: AppTab
    let onFinish: (_ startLesson: Bool) -> Void

    @Environment(AppState.self) private var app
    @State private var step = 0

    private struct Stop {
        let tab: AppTab
        let title: String
        let line: String
        let button: String
    }

    private var stops: [Stop] {
        let placed = app.placedUnits
        let path: String
        if placed >= CoreCourse.units.count {
            path = "This is your path. You've skipped Core Foundations, so you start in the \(genre.name) Academy. Every circle is a lesson, and each unit ends with a mastery test."
        } else if placed > 0 {
            path = "This is your path. I've opened the first \(placed == 1 ? "unit" : "\(placed) units") from your check, so you start at Unit \(placed + 1). Every circle is a lesson, and each unit ends with a mastery test."
        } else {
            path = "This is your path. Every circle is a lesson, and each unit ends with a mastery test. Pass it and the next unit opens."
        }
        let first = app.currentLesson(genre)?.title ?? "your first lesson"
        return [
            Stop(tab: .learn, title: "Your journey starts here", line: path, button: "Next"),
            Stop(tab: .sandbox, title: "This is the Sandbox",
                 line: "No lessons, no grades. A full studio where you make whatever you want with what you've learned. Everything you make saves here.",
                 button: "Next"),
            Stop(tab: .learn, title: "Ready when you are",
                 line: "Your first lesson is \(first). It takes about five minutes. Turn your sound up!",
                 button: "Start first lesson"),
        ]
    }

    var body: some View {
        let stop = stops[step]
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {}
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(stop.title)
                        .font(.display(24))
                        .foregroundStyle(Theme.text)
                        .multilineTextAlignment(.center)
                    Text(stop.line)
                        .font(.label(16, weight: .semibold))
                        .foregroundStyle(Theme.text)
                        .lineSpacing(3)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 18 + DownBubble.tail)
                .frame(maxWidth: .infinity)
                .background(DownBubble().fill(Theme.surface))
                .id(step)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                WooferView(mood: step == stops.count - 1 ? .party : .happy, size: 120, bouncing: true)
                    .padding(.top, 4)
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        ForEach(0..<stops.count, id: \.self) { i in
                            Capsule()
                                .fill(i == step ? Theme.brand : Theme.surfaceHigh)
                                .frame(width: i == step ? 22 : 8, height: 8)
                        }
                    }
                    Button(stop.button, action: advance)
                        .buttonStyle(ChunkyButtonStyle(color: Theme.brand))
                    Button(step == stops.count - 1 ? "I'll look around first" : "Skip tour") {
                        Haptics.tap()
                        onFinish(false)
                    }
                    .font(.label(15, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Theme.surface))
                .padding(.top, 10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)
        .onAppear { tab = stops[0].tab }
    }

    private func advance() {
        Haptics.thump()
        if step + 1 >= stops.count {
            onFinish(true)
            return
        }
        step += 1
        withAnimation(.easeInOut(duration: 0.3)) { tab = stops[step].tab }
    }
}
