//
//  ProfileView.swift
//  Groova
//

import Foundation
import SwiftUI

struct ProfileView: View {
    let genre: Genre
    @Environment(AppState.self) private var app
    @State private var confirmReset = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    header
                    stats
                    SectionTitle(text: "Genres")
                    VStack(spacing: 10) {
                        ForEach(Genre.allCases) { g in genreRow(g) }
                    }
                    SectionTitle(text: "Skills")
                    VStack(spacing: 14) {
                        ForEach(Skill.allCases) { s in skillRow(s) }
                    }
                    .card()
                    SectionTitle(text: "Achievements")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(Achievement.allCases) { a in badge(a) }
                    }
                    Button("Reset all progress") { confirmReset = true }
                        .font(.label(14, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                        .padding(.top, 10)
                }
                .padding(20)
            }
        }
        .confirmationDialog("Reset all progress?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset everything", role: .destructive) { app.resetAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("XP, streaks, lessons and achievements will be erased from this device.")
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Theme.brand)
                Image(systemName: "headphones").font(.system(size: 30, weight: .bold)).foregroundStyle(Theme.background)
            }
            .frame(width: 76, height: 76)
            VStack(alignment: .leading, spacing: 4) {
                Text("Producer").font(.display(28)).foregroundStyle(Theme.text)
                Text("Level \(app.level(genre)) in \(genre.name)")
                    .font(.label(15, weight: .semibold)).foregroundStyle(genre.color)
            }
            Spacer()
        }
        .padding(.top, 12)
    }

    private var stats: some View {
        let lessons = app.progress.genres.values.reduce(0) { $0 + $1.completed.count }
        return HStack(spacing: 10) {
            stat("\(app.progress.totalXP)", "Total XP", "star.fill", Theme.brand)
            stat("\(app.currentStreak)", "Streak", "bolt.fill", Theme.streak)
            stat("\(app.progress.longestStreak)", "Best", "trophy.fill", Theme.success)
            stat("\(lessons)", "Lessons", "checkmark.seal.fill", genre.color)
        }
    }

    private func stat(_ value: String, _ label: String, _ symbol: String, _ color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: symbol).font(.system(size: 15, weight: .bold)).foregroundStyle(color)
            Text(value).font(.display(20)).foregroundStyle(Theme.text).monospacedDigit()
            Text(label.uppercased()).font(.label(9, weight: .bold)).tracking(0.8).foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Theme.stroke, lineWidth: Theme.border)))
    }

    private func genreRow(_ g: Genre) -> some View {
        let gp = app.genreProgress(g)
        let lvl = AppState.level(for: gp.xp)
        let total = Curriculum.allLessons(for: g).count
        return HStack(spacing: 14) {
            Image(systemName: g.symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(g.badgeColor.mix(with: .black, by: 0.15))
                .frame(width: 44, height: 44)
                .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Theme.surfaceRaised))
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(g.name).font(.label(16, weight: .bold)).foregroundStyle(Theme.text)
                    if g == genre {
                        Text("CURRENT").font(.label(9, weight: .heavy)).tracking(1).foregroundStyle(g.color)
                    }
                    Spacer()
                    Text(total == 0 ? "Preview" : "Lv \(lvl.level) · \(gp.xp) XP")
                        .font(.mono(12, weight: .semibold)).foregroundStyle(Theme.textSecondary)
                }
                ProgressBar(value: total == 0 ? 0 : Double(lvl.into) / Double(lvl.needed), color: g.color, height: 7)
            }
        }
        .card(padding: 14)
    }

    private func skillRow(_ s: Skill) -> some View {
        let xp = app.skillXP(s)
        let lvl = AppState.level(for: xp)
        return HStack(spacing: 12) {
            Image(systemName: s.symbol).font(.system(size: 15, weight: .bold)).foregroundStyle(s.color)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(s.name).font(.label(14, weight: .bold)).foregroundStyle(Theme.text)
                    Spacer()
                    Text(xp == 0 ? "Not started" : "Lv \(lvl.level)")
                        .font(.mono(11, weight: .semibold)).foregroundStyle(Theme.textTertiary)
                }
                ProgressBar(value: Double(lvl.into) / Double(lvl.needed), color: s.color, height: 6)
            }
        }
    }

    private func badge(_ a: Achievement) -> some View {
        let has = app.hasAchievement(a)
        return VStack(spacing: 8) {
            Image(systemName: a.symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(has ? Theme.gold : Theme.textTertiary)
                .frame(width: 56, height: 56)
                .background(Circle().fill(has ? Theme.gold.opacity(0.15) : Theme.surfaceRaised))
            Text(a.title).font(.label(12, weight: .bold))
                .foregroundStyle(has ? Theme.text : Theme.textTertiary)
                .multilineTextAlignment(.center)
            Text(a.detail).font(.label(10, weight: .medium))
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(has ? Theme.gold.opacity(0.6) : Theme.stroke, lineWidth: Theme.border)))
    }
}
