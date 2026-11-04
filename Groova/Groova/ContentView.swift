//
//  ContentView.swift
//  Groova
//
//  Root: onboarding until a genre is chosen, then Learn / Studio / Profile tabs.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        Group {
            if let genre = app.selectedGenre {
                MainTabs(genre: genre)
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: app.selectedGenre)
        .preferredColorScheme(.light)
    }
}

struct MainTabs: View {
    let genre: Genre

    var body: some View {
        TabView {
            Tab("Learn", systemImage: "music.note.house.fill") {
                HomeView(genre: genre)
            }
            Tab("Studio", systemImage: "slider.horizontal.3") {
                StudioView(genre: genre)
            }
            Tab("Profile", systemImage: "person.crop.circle.fill") {
                ProfileView(genre: genre)
            }
        }
        .tint(genre.color)
        .environment(\.accent, genre.color)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(SketchStore())
}
