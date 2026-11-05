//
//  ContentView.swift
//  Groova
//
//  Root: sign in, then onboarding for a new account, then Learn / Sandbox / Profile tabs.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var app
    @Environment(AuthStore.self) private var auth

    private enum Route: Hashable { case signIn, onboarding, app }

    private var route: Route {
        if auth.session == nil { return .signIn }
        if auth.account == nil { return .onboarding }
        return .app
    }

    var body: some View {
        Group {
            switch route {
            case .signIn:
                AuthView().transition(.opacity)
            case .onboarding:
                OnboardingView().transition(.opacity)
            case .app:
                if let account = auth.account {
                    MainTabs(genre: app.selectedGenre ?? account.genre)
                        .transition(.opacity)
                        .onAppear {
                            // Signed in on a device with no progress yet: start where the account says.
                            if app.selectedGenre == nil {
                                app.applyOnboarding(genre: account.genre, placedUnits: account.placedUnits,
                                                    dailyGoal: account.dailyGoal)
                            }
                        }
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: route)
        .preferredColorScheme(.light)
    }
}

struct MainTabs: View {
    let genre: Genre
    @Environment(AppState.self) private var app
    @Environment(AuthStore.self) private var auth
    @State private var tab: AppTab = .learn
    @State private var showGuide = false

    var body: some View {
        TabView(selection: $tab) {
            Tab("Learn", systemImage: "music.note.house.fill", value: AppTab.learn) {
                HomeView(genre: genre)
            }
            Tab("Sandbox", systemImage: "square.stack.3d.up.fill", value: AppTab.sandbox) {
                SandboxView(genre: genre)
            }
            Tab("Profile", systemImage: "person.crop.circle.fill", value: AppTab.profile) {
                ProfileView(genre: genre)
            }
        }
        .tint(genre.color)
        .environment(\.accent, genre.color)
        .overlay {
            if showGuide {
                IntroGuideView(genre: genre, tab: $tab) { startLesson in
                    auth.markGuideSeen()
                    withAnimation(.easeInOut(duration: 0.25)) { showGuide = false }
                    tab = .learn
                    if startLesson { app.pendingLessonStart = true }
                }
                .transition(.opacity)
            }
        }
        .task {
            guard auth.account?.seenGuide == false else { return }
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.easeInOut(duration: 0.3)) { showGuide = true }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(SketchStore())
        .environment(JamStore())
        .environment(AuthStore())
}
