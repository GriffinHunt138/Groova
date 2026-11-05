//
//  GroovaApp.swift
//  Groova
//
//  Created by Griffin Hunt on 11/3/26.
//

import SwiftUI

@main
struct GroovaApp: App {
    @State private var app = AppState()
    @State private var sketches = SketchStore()
    @State private var jams = JamStore()
    @State private var auth = AuthStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(app)
                .environment(sketches)
                .environment(jams)
                .environment(auth)
                .onAppear { AudioEngine.shared.start() }
        }
    }
}
