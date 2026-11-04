//
//  OnboardingView.swift
//  Groova
//
//  "What do you want to make?" — pick a genre, hear it first.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var app
    @State private var page = 0
    @State private var choice: Genre?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            if page == 0 {
                WelcomePage { withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { page = 1 } }
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            } else {
                GenrePicker(choice: $choice, title: "What do you want to make?",
                            subtitle: "Pick a sound. You can switch any time — each genre keeps its own progress.") { g in
                    Transport.shared.stop()
                    Haptics.success()
                    withAnimation(.spring(response: 0.5)) { app.select(g) }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .onAppear { AudioEngine.shared.start() }
    }
}

private struct WelcomePage: View {
    let onStart: () -> Void
    @State private var animate = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            WooferView(mood: .party, size: 170, bouncing: true)
            HStack(alignment: .center, spacing: 5) {
                ForEach(0..<9, id: \.self) { i in
                    Capsule()
                        .fill(Theme.brand)
                        .frame(width: 10, height: animate ? CGFloat([32, 55, 24, 64, 42, 59, 28, 49, 21][i]) : 14)
                        .animation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true).delay(Double(i) * 0.08),
                                   value: animate)
                }
            }
            .frame(height: 70)

            VStack(spacing: 12) {
                Text("groova")
                    .font(.display(56, weight: .black))
                    .foregroundStyle(Theme.brand)
                Text("Hi, I'm Woofer!\nLet's learn production by making music.")
                    .font(.label(19, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            VStack(spacing: 14) {
                Label("Turn your sound on — or plug in headphones", systemImage: "headphones")
                    .font(.label(13, weight: .medium))
                    .foregroundStyle(Theme.textTertiary)
                Button("Let's make some noise") {
                    Haptics.thump()
                    AudioEngine.shared.trigger(.kick, kit: .house)
                    onStart()
                }
                .buttonStyle(ChunkyButtonStyle(color: Genre.house.color))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .onAppear { animate = true }
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
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(title).font(.display(30)).foregroundStyle(Theme.text)
                        .padding(.top, 24)
                    Text(subtitle).font(.label(15, weight: .medium)).foregroundStyle(Theme.textSecondary)
                        .padding(.bottom, 8)
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
                .padding(.bottom, 20)
            }
            if let choice {
                Button("Start with \(choice.name)") { onConfirm(choice) }
                    .buttonStyle(ChunkyButtonStyle(color: choice.color))
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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Theme.surfaceRaised)
                    Image(systemName: genre.symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(genre.badgeColor.mix(with: .black, by: 0.15))
                }
                .frame(width: 52, height: 52)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(genre.name).font(.display(22)).foregroundStyle(Theme.text)
                        if !genre.hasLessons {
                            Text("PREVIEW").font(.label(10, weight: .heavy)).tracking(1)
                                .foregroundStyle(Theme.textSecondary)
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(Capsule().strokeBorder(Theme.textTertiary))
                        }
                        if let level {
                            Text("LV \(level)").font(.label(10, weight: .heavy)).tracking(1)
                                .foregroundStyle(genre.color)
                        }
                    }
                    Text(genre.tagline).font(.label(14, weight: .medium)).foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Button(action: { Haptics.tap(); onPreview() }) {
                    Image(systemName: playing ? "stop.fill" : "play.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(playing ? Theme.onBrand : Theme.brand)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(playing ? Theme.brand : Theme.brandSoft))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(PressScaleStyle())
                .accessibilityLabel(playing ? "Stop \(genre.name) preview" : "Hear \(genre.name)")
            }
            PatternGlyph(pattern: genre.demoPattern, color: genre.color, playhead: playing ? playhead : -1)
                .frame(height: 46)
            HStack(spacing: 6) {
                ForEach(genre.traits, id: \.self) { t in
                    Text(t).font(.label(12, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 10).frame(height: 26)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Theme.surfaceRaised))
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(selected ? Theme.brandSoft : Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(selected ? Theme.brandBorder : Theme.stroke, lineWidth: Theme.border)
                )
        )
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(selected ? Theme.brandBorder : Theme.stroke)
                .offset(y: 4)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}
