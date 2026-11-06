//
//  Diagnosis.swift
//  Groova
//
//  The onboarding diagnostic: why you're here (making music or understanding it), then four
//  questions about what's held you back. Each answer gets a reply from Woofer and an insight
//  card with a small chart. Answers are saved on the account so the path can use them later.
//
//  Chart honesty: `path` and `spaced` are illustrations of general learning ideas and say so.
//  `milestones`, `skills`, `methods` and `ear` are counted from the real curriculum.
//

import Foundation

/// Why someone opened the app. Picked first in onboarding.
nonisolated enum LearnerGoal: String, Codable, CaseIterable, Identifiable, Sendable {
    case production, knowledge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .production: "Make music"
        case .knowledge: "Understand music"
        }
    }

    var detail: String {
        switch self {
        case .production: "Beats, chords, sound design and finished songs"
        case .knowledge: "Theory, ear training and how songs actually work"
        }
    }

    var symbol: String {
        switch self {
        case .production: "slider.vertical.3"
        case .knowledge: "music.quarternote.3"
        }
    }

    /// Shown on the plan screen.
    var short: String {
        switch self {
        case .production: "Production"
        case .knowledge: "Music knowledge"
        }
    }
}

nonisolated enum InsightChart: Sendable {
    /// A clear path versus random tutorials. Illustration.
    case path
    /// Short daily sessions versus one long one. Illustration of spaced practice.
    case spaced
    /// The finished things you'll have made, unit by unit. Real unit titles.
    case milestones
    /// Lessons in your path by skill. Real counts.
    case skills
    /// Steps in your path by what you do in them. Real counts.
    case methods
    /// Listening rounds in Foundations. Real count.
    case ear
}

nonisolated struct DiagnosticOption: Identifiable, Sendable {
    let id: String
    let symbol: String
    let title: String
    /// What Woofer says back before the insight card.
    let reply: String
}

nonisolated struct DiagnosticQuestion: Identifiable, Sendable {
    let id: String
    let prompt: String
    let coach: String
    let options: [DiagnosticOption]
    let headline: String
    let body: String
    let chart: InsightChart
}

nonisolated enum Diagnosis {
    static func questions(for goal: LearnerGoal) -> [DiagnosticQuestion] {
        goal == .production ? production : knowledge
    }

    // MARK: Production

    static let production: [DiagnosticQuestion] = [
        .init(id: "p.block", prompt: "What's stopped you making music so far?",
              coach: "Be honest. Everyone hits a wall somewhere, and knowing yours is half the fix.",
              options: [
                .init(id: "start", symbol: "map.fill", title: "I don't know where to start",
                      reply: "The most common answer. Starting is the hardest part when nobody shows you step one."),
                .init(id: "tutorials", symbol: "play.rectangle.fill", title: "Tutorials go too fast or run too long",
                      reply: "Long videos are easy to watch and hard to learn from. You learn it by doing it, not by seeing it."),
                .init(id: "finish", symbol: "folder.fill", title: "I start ideas but never finish them",
                      reply: "A folder full of eight-bar loops. Nearly every producer has one."),
                .init(id: "software", symbol: "slider.horizontal.3", title: "The software feels overwhelming",
                      reply: "A DAW shows you every button at once. You only need a handful of them to start."),
              ],
              headline: "A path beats a pile of tutorials",
              body: "Random videos teach you pieces in a random order. A path puts them in the right order, so every lesson builds on the one before.",
              chart: .path),
        .init(id: "p.habit", prompt: "Why is it hard to make music every day?",
              coach: "Habits are the whole game. Talent matters a lot less than showing up.",
              options: [
                .init(id: "time", symbol: "clock.fill", title: "I don't have enough time",
                      reply: "You don't need much. Five to ten focused minutes counts."),
                .init(id: "motivation", symbol: "battery.25percent", title: "I lose motivation",
                      reply: "Motivation comes after progress, not before. Small wins keep it topped up."),
                .init(id: "nowhere", symbol: "arrow.triangle.2.circlepath", title: "Sessions feel like they go nowhere",
                      reply: "Noodling without a goal feels busy but doesn't build much. Each session needs one clear target."),
                .init(id: "what", symbol: "questionmark.circle.fill", title: "I never know what to work on",
                      reply: "Deciding what to practise burns the energy you'd spend practising. Let the path decide."),
              ],
              headline: "Little and often wins",
              body: "Your brain locks skills in between sessions. Ten minutes a day sticks far better than one long session a week.",
              chart: .spaced),
        .init(id: "p.finished", prompt: "How many tracks have you actually finished?",
              coach: "Finished means you could play it to someone, start to end.",
              options: [
                .init(id: "none", symbol: "circle.dashed", title: "None yet",
                      reply: "Then your first finished song is close. It's built into the path."),
                .init(id: "few", symbol: "circle.lefthalf.filled", title: "One or two",
                      reply: "You've proved you can. Now let's make it something you do on purpose."),
                .init(id: "some", symbol: "circle.fill", title: "A handful",
                      reply: "Nice. The path will fill the gaps so each one comes out better than the last."),
                .init(id: "lots", symbol: "star.circle.fill", title: "Loads, but I want them better",
                      reply: "Good problem to have. The later units and the Gold tiers are where you'll grow."),
              ],
              headline: "You'll finish things from day one",
              body: "Every lesson ends with something that plays. Each unit stacks on the last, all the way to a full song.",
              chart: .milestones),
        .init(id: "p.want", prompt: "What do you most want to get better at?",
              coach: "Pick the one that would make you proudest.",
              options: [
                .init(id: "beats", symbol: "square.grid.3x3.fill", title: "Beats that hit",
                      reply: "Groove first. You'll be programming drums in your very first lesson."),
                .init(id: "chords", symbol: "pianokeys", title: "Chords and melodies",
                      reply: "The bit that makes people feel something. You'll learn it by ear and by hand."),
                .init(id: "sound", symbol: "dial.medium.fill", title: "Sound design and mixing",
                      reply: "Making it sound like a record. You'll shape sounds with real filters and faders."),
                .init(id: "songs", symbol: "rectangle.split.3x1.fill", title: "Turning loops into songs",
                      reply: "The step most people never take. Arrangement is a big part of your path."),
              ],
              headline: "Your path covers all of it",
              body: "Here's how the lessons in your path split across the skills a producer needs.",
              chart: .skills),
    ]

    // MARK: Music knowledge

    static let knowledge: [DiagnosticQuestion] = [
        .init(id: "k.block", prompt: "What's made music theory hard to learn?",
              coach: "Most people bounce off theory for the same few reasons.",
              options: [
                .init(id: "reading", symbol: "book.closed.fill", title: "Too much reading",
                      reply: "Theory written down is a long way from theory you can hear. We'll keep it in your ears."),
                .init(id: "maths", symbol: "function", title: "It feels like maths",
                      reply: "It's more like spotting patterns. Once you hear them, the numbers stop mattering."),
                .init(id: "hear", symbol: "ear.fill", title: "I can't hear it in real songs",
                      reply: "That's the gap that matters. Every idea here comes with sound, so you learn to hear it, not just know it."),
                .init(id: "stick", symbol: "calendar.badge.exclamationmark", title: "I never stuck with lessons",
                      reply: "Most lessons feel like homework. These are short and hands-on, and they give you something every time."),
              ],
              headline: "You'll learn by ear and by hand",
              body: "Groova lessons are things you tap, play and listen to, not pages to read. Here's what's in your path.",
              chart: .methods),
        .init(id: "k.ear", prompt: "When you listen to music, what's hardest to pick out?",
              coach: "No wrong answers. Most people have never been shown how to listen.",
              options: [
                .init(id: "instruments", symbol: "guitars.fill", title: "Which instrument is which",
                      reply: "Separating layers is a skill. You'll learn to hear the kick, the bass and the chords on their own."),
                .init(id: "beat", symbol: "metronome.fill", title: "Where the beat is",
                      reply: "Feeling the pulse comes first in Foundations. You'll tap along until it's automatic."),
                .init(id: "mood", symbol: "theatermasks.fill", title: "Why a chord sounds happy or sad",
                      reply: "Major and minor is one note's difference. You'll hear it in the first few units."),
                .init(id: "sections", symbol: "list.bullet.rectangle.fill", title: "Where the chorus starts",
                      reply: "Songs have a shape you can learn to spot. You'll map whole songs by ear."),
              ],
              headline: "Your ear is a muscle",
              body: "Ear training works like the gym: short reps, often. Here's how many listening rounds are waiting in Foundations alone.",
              chart: .ear),
        .init(id: "k.habit", prompt: "Why is it hard to keep learning music?",
              coach: "Knowing why you stop makes it easier to keep going.",
              options: [
                .init(id: "time", symbol: "clock.fill", title: "I don't have enough time",
                      reply: "You don't need much. A lesson takes about five minutes."),
                .init(id: "bored", symbol: "zzz", title: "It gets boring",
                      reply: "If it's not fun you won't come back. Every lesson here is something you play with."),
                .init(id: "progress", symbol: "chart.line.flattrend.xyaxis", title: "I can't tell if I'm improving",
                      reply: "Progress you can't see doesn't feel like progress. You'll see yours on the path and in your tiers."),
                .init(id: "serious", symbol: "graduationcap.fill", title: "Lessons feel too serious",
                      reply: "This isn't school. No grades to fail, just levels to beat."),
              ],
              headline: "Little and often wins",
              body: "Your brain locks skills in between sessions. Ten minutes a day sticks far better than one long session a week.",
              chart: .spaced),
        .init(id: "k.want", prompt: "What do you want music knowledge to do for you?",
              coach: "Pick the one that sounds most like you.",
              options: [
                .init(id: "understand", symbol: "heart.fill", title: "Understand the songs I love",
                      reply: "Once you know what's going on, you hear your favourite songs in a whole new way."),
                .init(id: "play", symbol: "music.mic", title: "Play or sing with more confidence",
                      reply: "Knowing why notes fit together makes playing them a lot less scary."),
                .init(id: "talk", symbol: "bubble.left.and.bubble.right.fill", title: "Talk music with friends or a band",
                      reply: "Chords, keys and sections. You'll have the words for what you hear."),
                .init(id: "make", symbol: "sparkles", title: "Make my own music someday",
                      reply: "Someday can be soon. Theory here comes with the tools to use it."),
              ],
              headline: "Your path covers all of it",
              body: "Here's how the lessons in your path split across the skills that make music click.",
              chart: .skills),
    ]
}

/// Numbers for the insight charts, counted from the real curriculum.
nonisolated enum PathStats {
    static func skillCounts(_ genre: Genre) -> [(skill: Skill, count: Int)] {
        let lessons = Curriculum.units(for: genre).flatMap(\.lessons)
        return Skill.allCases
            .map { s in (skill: s, count: lessons.filter { $0.skill == s }.count) }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    /// Steps in the path, grouped by what you do in them.
    static func methodCounts(_ genre: Genre) -> [(symbol: String, name: String, count: Int)] {
        var listen = 0, play = 0, shape = 0, arrange = 0
        for step in Curriculum.units(for: genre).flatMap(\.lessons).flatMap(\.steps) {
            switch step {
            case .earChoice: listen += 1
            case .sequencer, .keyboard, .pianoRoll, .chordBuilder, .chordLane, .tap, .tempo, .game: play += 1
            case .filter, .reverb, .soundLab, .mixer: shape += 1
            case .arrangement, .order: arrange += 1
            case .intro, .mastery: break
            }
        }
        return [(symbol: "hand.tap.fill", name: "Play and tap", count: play),
                (symbol: "ear.fill", name: "Listen and choose", count: listen),
                (symbol: "rectangle.split.3x1.fill", name: "Arrange", count: arrange),
                (symbol: "dial.medium.fill", name: "Shape sound", count: shape)]
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    /// Listening rounds across every Foundations lesson.
    static var earRounds: Int {
        FoundationCourse.units.flatMap(\.lessons).flatMap(\.steps).reduce(0) { n, step in
            if case .earChoice(let t) = step { return n + t.rounds.count }
            return n
        }
    }

    /// Four stops on the way to a finished song: three Foundations units and the genre finale.
    static func milestones(_ genre: Genre) -> [(code: String, title: String)] {
        let units = Curriculum.units(for: genre)
        let core = units.filter { $0.part == .foundations }
        let academy = units.filter { $0.part == .academy }
        var picks: [Unit] = []
        if let first = core.first { picks.append(first) }
        if core.count > 3 { picks.append(core[core.count / 2]) }
        if let last = core.last, core.count > 1 { picks.append(last) }
        if let finale = academy.last { picks.append(finale) }
        return picks.map { (code: "\($0.code)\($0.number)", title: $0.title) }
    }
}
