import Foundation

/// A short mixed review built from lessons the learner has already finished.
nonisolated struct PracticeSession: Sendable {
    let lesson: Lesson
    /// Ids of the lessons each drill came from (they count as played again).
    let sources: [String]
    let skills: [Skill]
}

extension AppState {
    /// Lessons that can feed Daily Practice: finished, not mastery, with at least one graded step.
    func practiceCandidates(_ g: Genre) -> [Lesson] {
        Curriculum.allLessons(for: g).filter {
            !$0.isMastery && isCompleted($0, in: g) && Self.drill(from: $0) != nil
        }
    }

    /// Picks up to four lessons, favouring ones that have faded, low scores and the weakest skill.
    func makePractice(_ g: Genre) -> PracticeSession? {
        let pool = practiceCandidates(g)
        guard !pool.isEmpty else { return nil }
        let weakest = Set(pool.map(\.skill)).min { skillXP($0) < skillXP($1) }

        let scored = pool.map { lesson -> (Lesson, Double) in
            var score = Double.random(in: 0..<1)
            if needsPractice(lesson, in: g) { score += 3 }
            if (bestScore(lesson, in: g) ?? 100) < 90 { score += 2 }
            if lesson.skill == weakest { score += 1 }
            return (lesson, score)
        }
        let picked = scored.sorted { $0.1 > $1.1 }.prefix(4).map(\.0)
        let steps = picked.compactMap { Self.drill(from: $0) }
        guard !steps.isEmpty else { return nil }

        let lesson = Lesson(id: "practice.\(g.rawValue)", title: "Daily Practice",
                            subtitle: "A quick mix of things you've learned",
                            symbol: "dumbbell.fill", skill: picked.first?.skill ?? .rhythm,
                            xp: 10 + 5 * steps.count, steps: steps)
        var skills: [Skill] = []
        for l in picked where !skills.contains(l.skill) { skills.append(l.skill) }
        return PracticeSession(lesson: lesson, sources: picked.map(\.id), skills: skills)
    }

    /// One graded step from a lesson: a by-ear task first, then a rule, then anything graded.
    nonisolated static func drill(from lesson: Lesson) -> LessonStep? {
        let graded = lesson.steps.filter { step in
            if case .mastery = step { return false }
            return Levels.isGraded(step)
        }
        func mode(_ s: LessonStep) -> TaskMode? {
            switch s {
            case .sequencer(let t): t.mode
            case .pianoRoll(let t): t.mode
            case .chordLane(let t): t.mode
            case .arrangement(let t): t.mode
            default: nil
            }
        }
        if let s = graded.first(where: { if case .recreate = mode($0) { true } else { false } }) { return s }
        if let s = graded.first(where: { if case .rule = mode($0) { true } else { false } }) { return s }
        return graded.first(where: { mode($0) == nil }) ?? graded.first
    }
}
