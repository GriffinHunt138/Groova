//
//  AppState.swift
//  Groova
//
//  Progress, XP, levels, streaks and achievements. Persisted locally as JSON in UserDefaults.
//

import Foundation
import Observation
import SwiftUI

// MARK: - Persisted data

nonisolated struct GenreProgress: Codable, Sendable {
    var xp = 0
    var completed: [String] = []
    var bestScores: [String: Int] = [:]
    /// Highest level passed per lesson: 1 Bronze, 2 Silver, 3 Gold.
    var tiers: [String: Int] = [:]
    /// When each lesson was last played or practised. Drives "needs practice".
    var lastPlayed: [String: Date] = [:]

    init() {}

    // Tolerates progress saved by older versions of the app.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        xp = try c.decodeIfPresent(Int.self, forKey: .xp) ?? 0
        completed = try c.decodeIfPresent([String].self, forKey: .completed) ?? []
        bestScores = try c.decodeIfPresent([String: Int].self, forKey: .bestScores) ?? [:]
        tiers = try c.decodeIfPresent([String: Int].self, forKey: .tiers) ?? [:]
        lastPlayed = try c.decodeIfPresent([String: Date].self, forKey: .lastPlayed) ?? [:]
    }
}

nonisolated struct UserProgress: Codable, Sendable {
    var selectedGenre: Genre?
    var genres: [String: GenreProgress] = [:]
    var totalXP = 0
    var streak = 0
    var longestStreak = 0
    var lastActiveDay: String?
    var xpToday = 0
    var xpDay: String?
    var skillXP: [String: Int] = [:]
    var achievements: [String] = []
    var genresTried: [String] = []
    var dailyGoal = 50
    var practiceDay: String?
    var practiceSessions = 0
    /// Chose to skip Core Foundations and go straight to a genre academy.
    var skippedFoundations = false
    /// Core Foundations units the onboarding placement check let you skip (0 to 8).
    var placedUnits = 0

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // A genre that's no longer offered falls back to House.
        selectedGenre = (try? c.decodeIfPresent(Genre.self, forKey: .selectedGenre)).flatMap { g in
            Genre.allCases.contains(g) ? g : .house
        }
        genres = try c.decodeIfPresent([String: GenreProgress].self, forKey: .genres) ?? [:]
        totalXP = try c.decodeIfPresent(Int.self, forKey: .totalXP) ?? 0
        streak = try c.decodeIfPresent(Int.self, forKey: .streak) ?? 0
        longestStreak = try c.decodeIfPresent(Int.self, forKey: .longestStreak) ?? 0
        lastActiveDay = try c.decodeIfPresent(String.self, forKey: .lastActiveDay)
        xpToday = try c.decodeIfPresent(Int.self, forKey: .xpToday) ?? 0
        xpDay = try c.decodeIfPresent(String.self, forKey: .xpDay)
        skillXP = try c.decodeIfPresent([String: Int].self, forKey: .skillXP) ?? [:]
        achievements = try c.decodeIfPresent([String].self, forKey: .achievements) ?? []
        genresTried = try c.decodeIfPresent([String].self, forKey: .genresTried) ?? []
        dailyGoal = try c.decodeIfPresent(Int.self, forKey: .dailyGoal) ?? 50
        practiceDay = try c.decodeIfPresent(String.self, forKey: .practiceDay)
        practiceSessions = try c.decodeIfPresent(Int.self, forKey: .practiceSessions) ?? 0
        skippedFoundations = try c.decodeIfPresent(Bool.self, forKey: .skippedFoundations) ?? false
        placedUnits = try c.decodeIfPresent(Int.self, forKey: .placedUnits) ?? 0
    }

    /// Core Foundations progress is shared, so lessons finished inside a genre before the
    /// restructure move into the shared bucket. Safe to run every launch.
    mutating func gatherCoreProgress() {
        var core = genres[Curriculum.coreKey] ?? GenreProgress()
        for (key, gp) in genres where key != Curriculum.coreKey {
            for id in gp.completed where Curriculum.isCore(id) && !core.completed.contains(id) {
                core.completed.append(id)
            }
            for (id, t) in gp.tiers where Curriculum.isCore(id) { core.tiers[id] = max(core.tiers[id] ?? 0, t) }
            for (id, b) in gp.bestScores where Curriculum.isCore(id) {
                core.bestScores[id] = max(core.bestScores[id] ?? 0, b)
            }
            for (id, d) in gp.lastPlayed where Curriculum.isCore(id) {
                core.lastPlayed[id] = max(core.lastPlayed[id] ?? d, d)
            }
        }
        genres[Curriculum.coreKey] = core
    }
}

nonisolated enum Achievement: String, CaseIterable, Identifiable, Sendable {
    case firstBeat, groovemaker, bassFace, filterFreak, unitMaster, flawless, genreHopper, streak3, streak7

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstBeat: "First Beat"
        case .groovemaker: "Groove Maker"
        case .bassFace: "Bass Face"
        case .filterFreak: "Filter Freak"
        case .unitMaster: "Unit Master"
        case .flawless: "Flawless"
        case .genreHopper: "Genre Hopper"
        case .streak3: "On a Roll"
        case .streak7: "Week Warrior"
        }
    }

    var detail: String {
        switch self {
        case .firstBeat: "Finish your first lesson"
        case .groovemaker: "Build a full drum groove"
        case .bassFace: "Write a bassline"
        case .filterFreak: "Sweep a filter"
        case .unitMaster: "Pass a mastery challenge"
        case .flawless: "Score 100% on a mastery"
        case .genreHopper: "Try three genres"
        case .streak3: "3 day streak"
        case .streak7: "7 day streak"
        }
    }

    var symbol: String {
        switch self {
        case .firstBeat: "play.circle.fill"
        case .groovemaker: "square.grid.3x3.fill"
        case .bassFace: "waveform.path"
        case .filterFreak: "dial.high.fill"
        case .unitMaster: "crown.fill"
        case .flawless: "star.circle.fill"
        case .genreHopper: "shuffle"
        case .streak3: "bolt.fill"
        case .streak7: "bolt.heart.fill"
        }
    }
}

// MARK: - Node state on the path

enum NodeState: Equatable {
    /// `open`: not done yet, but in a unit you skipped past, so play it any time.
    case completed, current, open, locked
}

struct CompletionReward {
    var xp: Int
    var accuracy: Double
    var leveledUp: Int?
    var newAchievements: [Achievement]
    var streak: Int
    var streakIncreased: Bool
    var unlockedUnit: Unit?
    var isPractice: Bool
    /// A Silver or Gold level earned for the first time.
    var tierEarned: LessonTier? = nil
    var isDailyPractice = false
}

// MARK: - App state

@Observable
final class AppState {
    private(set) var progress: UserProgress
    private let storeKey = "groova.progress.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: "groova.progress.v1"),
           let saved = try? JSONDecoder().decode(UserProgress.self, from: data) {
            progress = saved
        } else {
            progress = UserProgress()
        }
        progress.gatherCoreProgress()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }

    // MARK: Genre

    var selectedGenre: Genre? { progress.selectedGenre }

    func select(_ genre: Genre) {
        progress.selectedGenre = genre
        if !progress.genresTried.contains(genre.rawValue) { progress.genresTried.append(genre.rawValue) }
        save()
    }

    /// XP and level for a genre.
    func genreProgress(_ g: Genre) -> GenreProgress { progress.genres[g.rawValue] ?? GenreProgress() }

    /// Where a lesson's completion, levels and scores live: shared for Core Foundations, per genre otherwise.
    private func bucket(_ lessonID: String, _ g: Genre) -> String {
        Curriculum.isCore(lessonID) ? Curriculum.coreKey : g.rawValue
    }

    func lessonProgress(_ lessonID: String, in g: Genre) -> GenreProgress {
        progress.genres[bucket(lessonID, g)] ?? GenreProgress()
    }

    func isCompleted(_ lesson: Lesson, in g: Genre) -> Bool {
        lessonProgress(lesson.id, in: g).completed.contains(lesson.id)
    }

    func bestScore(_ lesson: Lesson, in g: Genre) -> Int? {
        lessonProgress(lesson.id, in: g).bestScores[lesson.id]
    }

    // MARK: Levels

    /// XP needed to go from `level` to `level + 1`.
    static func xpForNext(_ level: Int) -> Int { 100 + 50 * (level - 1) }

    static func level(for xp: Int) -> (level: Int, into: Int, needed: Int) {
        var level = 1
        var remaining = xp
        while remaining >= xpForNext(level) {
            remaining -= xpForNext(level)
            level += 1
        }
        return (level, remaining, xpForNext(level))
    }

    func level(_ g: Genre) -> Int { Self.level(for: genreProgress(g).xp).level }

    // MARK: Streak

    private static func dayString(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    private var today: String { Self.dayString(.now) }
    private var yesterday: String {
        Self.dayString(Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now)
    }

    /// The streak as it should be displayed (a missed day shows 0 until you practise again).
    var currentStreak: Int {
        guard let last = progress.lastActiveDay else { return 0 }
        return (last == today || last == yesterday) ? progress.streak : 0
    }

    var practicedToday: Bool { progress.lastActiveDay == today }

    var xpToday: Int { progress.xpDay == today ? progress.xpToday : 0 }

    // MARK: Path

    var skippedFoundations: Bool { progress.skippedFoundations }

    /// Start at the genre academy. Core Foundations lessons stay open to play any time.
    func skipFoundations(_ skip: Bool = true) {
        progress.skippedFoundations = skip
        save()
    }

    /// The furthest unit you're past: its mastery is passed, or it's part of skipped foundations. -1 for none.
    /// Passing any mastery, even one far ahead, opens everything up to the next unit.
    func frontier(_ g: Genre) -> Int {
        let units = Curriculum.units(for: g)
        var f = -1
        for (i, unit) in units.enumerated() {
            if let m = unit.mastery {
                if isCompleted(m, in: g) { f = i }
            } else if !unit.lessons.isEmpty, unit.lessons.allSatisfy({ isCompleted($0, in: g) }) {
                // Units without a challenge open the next one once every lesson is done.
                f = i
            }
        }
        let core = units.filter { $0.part == .foundations }.count
        if progress.skippedFoundations {
            f = max(f, core - 1)
        }
        f = max(f, min(progress.placedUnits, core) - 1)
        return f
    }

    /// Where onboarding placed you: the number of Core Foundations units you start past.
    var placedUnits: Int { progress.placedUnits }

    /// Applies the onboarding result: genre, starting point and daily goal.
    func applyOnboarding(genre: Genre, placedUnits: Int, dailyGoal: Int) {
        progress.placedUnits = max(0, min(placedUnits, FoundationCourse.units.count))
        progress.skippedFoundations = placedUnits >= FoundationCourse.units.count
        progress.dailyGoal = dailyGoal
        select(genre)
    }

    /// Set by the intro guide's last step; the Learn tab opens your first lesson and clears it.
    var pendingLessonStart = false

    /// Testing switch: opens every unit, lesson and level. Set to false before shipping.
    static let unlockEverything = true

    func unlockedUnitCount(_ g: Genre) -> Int {
        if Self.unlockEverything { return Curriculum.units(for: g).count }
        return min(Curriculum.units(for: g).count, frontier(g) + 2)
    }

    func unitIndex(_ unit: Unit, in g: Genre) -> Int {
        Curriculum.units(for: g).firstIndex { $0.id == unit.id } ?? 0
    }

    func isUnitUnlocked(_ unit: Unit, in g: Genre) -> Bool {
        unitIndex(unit, in: g) < unlockedUnitCount(g)
    }

    /// Units behind the frontier: you've tested out of them, so their lessons are open in any order.
    func isUnitSkipped(_ unit: Unit, in g: Genre) -> Bool {
        if Self.unlockEverything { return true }
        return unitIndex(unit, in: g) <= frontier(g)
    }

    /// The next lesson on the path: the first one not done in the unit after the frontier,
    /// then anything left behind it.
    func currentLesson(_ g: Genre) -> Lesson? {
        let units = Curriculum.units(for: g)
        let next = frontier(g) + 1
        if next < units.count, let l = units[next].lessons.first(where: { !isCompleted($0, in: g) }) { return l }
        for unit in units.prefix(unlockedUnitCount(g)) {
            if let l = unit.lessons.first(where: { !isCompleted($0, in: g) }) { return l }
        }
        return nil
    }

    func state(of lesson: Lesson, in unit: Unit, genre g: Genre) -> NodeState {
        if isCompleted(lesson, in: g) { return .completed }
        if isUnitUnlocked(unit, in: g), currentLesson(g)?.id == lesson.id { return .current }
        if isUnitSkipped(unit, in: g) { return .open }
        return .locked
    }

    /// A locked mastery can be taken early to test out of everything before it.
    func canTestOut(_ lesson: Lesson, in unit: Unit, genre g: Genre) -> Bool {
        lesson.isMastery && !isCompleted(lesson, in: g) && state(of: lesson, in: unit, genre: g) == .locked
    }

    func skillXP(_ s: Skill) -> Int { progress.skillXP[s.rawValue] ?? 0 }

    // MARK: Completing lessons

    // MARK: Levels (Bronze / Silver / Gold)

    /// Highest level passed: 0 = not started, 1 Bronze, 2 Silver, 3 Gold.
    func tier(of lesson: Lesson, in g: Genre) -> Int {
        let gp = lessonProgress(lesson.id, in: g)
        return max(gp.tiers[lesson.id] ?? 0, gp.completed.contains(lesson.id) ? 1 : 0)
    }

    func isTierAvailable(_ t: LessonTier, for lesson: Lesson, in g: Genre) -> Bool {
        if lesson.isMastery { return t == .bronze }
        if Self.unlockEverything { return true }
        return t.rawValue <= tier(of: lesson, in: g) + 1
    }

    /// The level a learner should play next: the first one not yet earned (Gold once all are done).
    func nextTier(for lesson: Lesson, in g: Genre) -> LessonTier {
        if lesson.isMastery { return .bronze }
        return LessonTier(rawValue: min(3, tier(of: lesson, in: g) + 1)) ?? .gold
    }

    static func xp(for lesson: Lesson, tier: LessonTier, replay: Bool) -> Int {
        let base: Int
        switch tier {
        case .bronze: base = lesson.xp
        case .silver: base = lesson.xp + 10
        case .gold: base = lesson.xp * 2
        }
        return replay ? max(5, base / 2) : base
    }

    // MARK: Practice

    /// A finished lesson not played for a week or more.
    func needsPractice(_ lesson: Lesson, in g: Genre) -> Bool {
        guard !lesson.isMastery, isCompleted(lesson, in: g),
              let last = lessonProgress(lesson.id, in: g).lastPlayed[lesson.id] else { return false }
        return Date.now.timeIntervalSince(last) > 7 * 24 * 3600
    }

    func fadedCount(_ g: Genre) -> Int {
        Curriculum.allLessons(for: g).filter { needsPractice($0, in: g) }.count
    }

    var practicedDrillsToday: Bool { progress.practiceDay == today }

    /// Records a day of activity: daily XP and streak. Returns whether the streak grew.
    private func recordActivity(xp: Int) -> Bool {
        if progress.xpDay != today { progress.xpDay = today; progress.xpToday = 0 }
        progress.xpToday += xp
        progress.totalXP += xp
        var increased = false
        if progress.lastActiveDay != today {
            progress.streak = (progress.lastActiveDay == yesterday) ? progress.streak + 1 : 1
            progress.lastActiveDay = today
            increased = true
        }
        progress.longestStreak = max(progress.longestStreak, progress.streak)
        return increased
    }

    func completePractice(_ session: PracticeSession, genre g: Genre, accuracy: Double) -> CompletionReward {
        var gp = genreProgress(g)
        let oldLevel = Self.level(for: gp.xp).level
        var xp = session.lesson.xp
        if accuracy >= 0.999 { xp += 5 }
        gp.xp += xp
        progress.genres[g.rawValue] = gp
        for id in session.sources {
            let key = bucket(id, g)
            var lp = progress.genres[key] ?? GenreProgress()
            lp.lastPlayed[id] = .now
            progress.genres[key] = lp
        }
        let share = max(1, xp / max(1, session.skills.count))
        for skill in session.skills { progress.skillXP[skill.rawValue, default: 0] += share }
        progress.practiceDay = today
        progress.practiceSessions += 1
        let increased = recordActivity(xp: xp)
        var unlocked: [Achievement] = []
        for a in [Achievement.streak3, .streak7] where !progress.achievements.contains(a.rawValue) {
            if (a == .streak3 && progress.streak >= 3) || (a == .streak7 && progress.streak >= 7) {
                progress.achievements.append(a.rawValue)
                unlocked.append(a)
            }
        }
        save()
        let newLevel = Self.level(for: gp.xp).level
        return CompletionReward(xp: xp, accuracy: accuracy, leveledUp: newLevel > oldLevel ? newLevel : nil,
                                newAchievements: unlocked, streak: progress.streak, streakIncreased: increased,
                                unlockedUnit: nil, isPractice: true, isDailyPractice: true)
    }

    // MARK: Completing lessons

    func complete(_ lesson: Lesson, genre g: Genre, accuracy: Double, tier: LessonTier = .bronze) -> CompletionReward {
        var gp = genreProgress(g)
        let key = bucket(lesson.id, g)
        var lp = progress.genres[key] ?? GenreProgress()
        let wasCompleted = lp.completed.contains(lesson.id)
        let previousTier = self.tier(of: lesson, in: g)
        let replay = previousTier >= tier.rawValue
        let oldLevel = Self.level(for: gp.xp).level
        let unitsBefore = unlockedUnitCount(g)

        var xp = Self.xp(for: lesson, tier: tier, replay: replay)
        if accuracy >= 0.999 { xp += 5 }
        if lesson.isMastery && !wasCompleted && accuracy >= 0.95 { xp += 20 }

        if !wasCompleted { lp.completed.append(lesson.id) }
        lp.tiers[lesson.id] = max(previousTier, tier.rawValue)
        lp.lastPlayed[lesson.id] = .now
        let pct = Int((accuracy * 100).rounded())
        lp.bestScores[lesson.id] = max(lp.bestScores[lesson.id] ?? 0, pct)
        if key == g.rawValue {
            lp.xp += xp
            gp = lp
        } else {
            gp.xp += xp
            progress.genres[key] = lp
        }
        progress.genres[g.rawValue] = gp
        progress.skillXP[lesson.skill.rawValue, default: 0] += xp

        let increased = recordActivity(xp: xp)

        // Achievements
        var unlocked: [Achievement] = []
        func award(_ a: Achievement, _ condition: Bool) {
            if condition && !progress.achievements.contains(a.rawValue) {
                progress.achievements.append(a.rawValue)
                unlocked.append(a)
            }
        }
        award(.firstBeat, true)
        award(.groovemaker, lesson.id == "house.u1.l3" || lesson.id.hasPrefix("techno") || lesson.id.hasPrefix("ukg"))
        award(.bassFace, lesson.steps.contains { step in
            if case .pianoRoll(let t) = step { t.voice == .bass } else { false }
        })
        award(.filterFreak, lesson.id == "house.u1.l5")
        award(.unitMaster, lesson.isMastery)
        award(.flawless, lesson.isMastery && accuracy >= 0.999)
        award(.genreHopper, progress.genresTried.count >= 3)
        award(.streak3, progress.streak >= 3)
        award(.streak7, progress.streak >= 7)

        save()

        let newLevel = Self.level(for: gp.xp).level
        let unitsAfter = unlockedUnitCount(g)
        let units = Curriculum.units(for: g)
        let newUnit: Unit? = unitsAfter > unitsBefore && unitsAfter <= units.count ? units[unitsAfter - 1] : nil

        return CompletionReward(xp: xp, accuracy: accuracy, leveledUp: newLevel > oldLevel ? newLevel : nil,
                                newAchievements: unlocked, streak: progress.streak, streakIncreased: increased,
                                unlockedUnit: newUnit, isPractice: replay,
                                tierEarned: !replay && tier != .bronze ? tier : nil)
    }

    func hasAchievement(_ a: Achievement) -> Bool { progress.achievements.contains(a.rawValue) }

    func resetAll() {
        progress = UserProgress()
        save()
    }
}
