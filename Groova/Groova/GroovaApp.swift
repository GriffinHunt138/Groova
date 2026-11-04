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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(app)
                .environment(sketches)
                .onAppear { AudioEngine.shared.start() }
        }
    }
}
