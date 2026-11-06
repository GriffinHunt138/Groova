//
//  GameSteps.swift
//  Groova
//
//  Builders for the Foundations tier flow: Woofer's opening, a short Teach moment, the Studio
//  task in a real editor, then the Game.
//

import Foundation

extension K {
    /// Woofer's opening screen for a Bronze tier: the idea and a preview of the game.
    nonisolated static func opening(_ title: String, _ body: String) -> LessonStep {
        .intro(IntroStep(title: title, body: body, pads: [], demo: nil, badge: "Woofer says"))
    }

    /// Teach: one idea, heard or tried in a few seconds.
    nonisolated static func teach(_ title: String, _ body: String, pads: [DrumTrack] = [], demo: Pattern? = nil) -> LessonStep {
        .intro(IntroStep(title: title, body: body, pads: pads, demo: demo, badge: "Teach"))
    }

    nonisolated static func game(_ name: String, _ tagline: String, _ kind: GameKind) -> LessonStep {
        .game(GameTask(name: name, tagline: tagline, kind: kind))
    }
}

/// Which part of the Teach, Studio, Game flow a step belongs to. Nil for the opening screen.
nonisolated enum TierPhase: Int, CaseIterable, Sendable {
    case teach, studio, game

    var name: String {
        switch self {
        case .teach: "Teach"
        case .studio: "Studio"
        case .game: "Game"
        }
    }

    var symbol: String {
        switch self {
        case .teach: "ear.fill"
        case .studio: "slider.horizontal.3"
        case .game: "gamecontroller.fill"
        }
    }

    /// Phases for a whole tier, or nil when the tier doesn't use this flow (it has no game).
    static func map(_ steps: [LessonStep]) -> [TierPhase?]? {
        guard steps.contains(where: { if case .game = $0 { true } else { false } }) else { return nil }
        var seenStudio = false
        return steps.map { step -> TierPhase? in
            switch step {
            case .game: return .game
            case .intro(let s):
                if s.level != nil || s.badge == "Woofer says" { return nil }
                return seenStudio ? .studio : .teach
            case .earChoice: return seenStudio ? .studio : .teach
            default:
                seenStudio = true
                return .studio
            }
        }
    }
}
