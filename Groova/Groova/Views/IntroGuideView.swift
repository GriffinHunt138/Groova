//
//  IntroGuideView.swift
//  Groova
//
//  A three-stop tour the first time you land in the app: your path, the Sandbox, then your
//  first lesson. Each stop switches to the tab it's talking about. Woofer sits in a compact
//  card above the tab bar so the screen he's describing stays in view.
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
        if placed >= FoundationCourse.units.count {
            path = "This is your path. You've skipped Foundations, so you start in the \(genre.name) course. Every circle is a lesson, and each unit ends with a boss."
        } else if placed > 0 {
            path = "This is your path. I've opened the first \(placed == 1 ? "unit" : "\(placed) units") from your check, so you start at \(FoundationCourse.units[min(placed, FoundationCourse.units.count - 1)].title). Every circle is a lesson, and each unit ends with a boss."
        } else {
            path = "This is your path. Every circle is a lesson, and each unit ends with a boss. Beat it and the next unit opens."
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
            // Keeps taps off the screen behind while touring, but leaves it in full view.
            Color.black.opacity(0.12)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {}
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    WooferView(mood: step == stops.count - 1 ? .party : .happy, size: 64, bouncing: true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stop.title)
                            .font(.display(19))
                            .foregroundStyle(Theme.text)
                        Text(stop.line)
                            .font(.label(14, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id(step)
                    .transition(.opacity)
                }
                HStack(spacing: 12) {
                    HStack(spacing: 5) {
                        ForEach(0..<stops.count, id: \.self) { i in
                            Capsule()
                                .fill(i == step ? Theme.brand : Theme.surfaceHigh)
                                .frame(width: i == step ? 18 : 7, height: 7)
                        }
                    }
                    Button(step == stops.count - 1 ? "Later" : "Skip") {
                        Haptics.tap()
                        onFinish(false)
                    }
                    .font(.label(15, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.leading, 4)
                    Spacer(minLength: 4)
                    Button(stop.button, action: advance)
                        .buttonStyle(ChunkyButtonStyle(color: Theme.brand, height: 44))
                        .fixedSize()
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(Theme.stroke, lineWidth: Theme.border))
            .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
            .padding(.horizontal, 12)
            // Sits just above the tab bar, so the tab it's talking about stays visible.
            .padding(.bottom, 84)
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
