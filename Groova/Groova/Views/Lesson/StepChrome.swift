//
//  StepChrome.swift
//  Groova
//
//  Shared layout for every interactive lesson step: prompt on top, instrument in the
//  middle, one obvious action at the bottom, and a feedback panel that slides up.
//

import Foundation
import SwiftUI

struct StepFeedback: Equatable {
    /// success: passed. retry: try again. reveal: wrong, the answer is shown, carry on.
    enum Kind { case success, retry, reveal }
    var kind: Kind
    var title: String
    var message: String
    var score: Double?
}

/// Prompt header used at the top of each step.
struct StepPrompt: View {
    let title: String
    var detail: String? = nil
    var badge: String? = nil
    /// How Woofer looks while he reads the detail out.
    var mood: WooferMood = .happy
    @Environment(\.accent) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let badge {
                Text(badge.uppercased())
                    .font(.label(14, weight: .black)).tracking(0.6)
                    .foregroundStyle(accent)
            }
            Text(title)
                .font(.display(28))
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)
            if let detail, !detail.isEmpty {
                WooferCoach(line: detail, mood: mood)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The bottom action area. Shows a primary button, or a full-width feedback panel.
struct StepFooter: View {
    var feedback: StepFeedback?
    var primaryTitle: String = "Check"
    var primaryEnabled: Bool = true
    var onPrimary: () -> Void
    var onContinue: () -> Void
    var onRetry: () -> Void
    /// Offered after repeated misses, e.g. "Show me".
    var helpTitle: String? = nil
    var onHelp: (() -> Void)? = nil

    @Environment(\.accent) private var accent

    var body: some View {
        ZStack(alignment: .bottom) {
            if let feedback {
                feedbackPanel(feedback)
                    .transition(.move(edge: .bottom))
            } else {
                VStack(spacing: 0) {
                    Rectangle().fill(Theme.divider).frame(height: Theme.border)
                    Button(primaryTitle) {
                        guard primaryEnabled else { return }
                        Haptics.thump()
                        onPrimary()
                    }
                    .buttonStyle(ChunkyButtonStyle(color: accent, enabled: primaryEnabled))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 10)
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: feedback)
    }

    @ViewBuilder
    private func feedbackPanel(_ f: StepFeedback) -> some View {
        let ok = f.kind == .success
        let reveal = f.kind == .reveal
        let ink = ok ? Theme.successInk : Theme.missInk
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                WooferView(mood: ok ? .party : .oops, size: 64, bouncing: ok)
                    .id(f.title)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(f.title).font(.display(23)).foregroundStyle(ink)
                        Spacer()
                        if let s = f.score {
                            Text("\(Int((s * 100).rounded()))%")
                                .font(.mono(20, weight: .black))
                                .foregroundStyle(ink)
                        }
                    }
                    Text(f.message)
                        .font(.label(15, weight: .bold))
                        .foregroundStyle(ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if ok {
                Button("Continue", action: onContinue)
                    .buttonStyle(ChunkyButtonStyle(color: Theme.success))
            } else if reveal {
                Button("Continue", action: onContinue)
                    .buttonStyle(ChunkyButtonStyle(color: Theme.miss))
            } else {
                HStack(spacing: 10) {
                    if let helpTitle, let onHelp {
                        Button(helpTitle, action: onHelp)
                            .buttonStyle(GhostButtonStyle(textColor: Theme.missInk))
                    }
                    Button("Try again", action: onRetry)
                        .buttonStyle(ChunkyButtonStyle(color: Theme.miss))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background((ok ? Theme.successSoft : Theme.missSoft).ignoresSafeArea(edges: .bottom))
    }
}

/// Feedback copy that celebrates without being cheesy and never punishes.
enum Cheer {
    static let wins = ["Locked in!", "That groove!", "Nailed it!", "Sounds right!", "In the pocket!"]
    static func win() -> String { wins.randomElement() ?? "Nice!" }

    static func near(_ score: Double) -> String {
        switch score {
        case 0.7...: "So close"
        case 0.45...: "Getting there"
        default: "Keep listening"
        }
    }
}
