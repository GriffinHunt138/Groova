import Foundation

/// Every regular lesson has three levels that go deeper into the same idea.
///
/// Bronze, "Learn it": the lesson as written, with clear instructions and every guide.
/// Silver, "Apply it": fresh variations of the same idea that you work out by ear, without the beat guide.
/// Gold, "Master it": bigger versions with more parts to control at once, by ear, then a creative brief.
nonisolated enum LessonTier: Int, CaseIterable, Codable, Sendable, Identifiable {
    case bronze = 1, silver, gold

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .bronze: "Bronze"
        case .silver: "Silver"
        case .gold: "Gold"
        }
    }

    var focus: String {
        switch self {
        case .bronze: "Learn it"
        case .silver: "Apply it"
        case .gold: "Master it"
        }
    }

    var detail: String {
        switch self {
        case .bronze: "Learn it. Step-by-step tasks with every guide switched on."
        case .silver: "Apply it. New variations of this idea that you recreate by ear, with no beat guide and tougher goals."
        case .gold: "Master it. Rebuild whole grooves and sounds by ear with more parts to control, then make your own."
        }
    }

    var symbol: String { "medal.fill" }
}

/// A small deterministic random source, so a level is the same every time you play it.
nonisolated struct LevelRNG {
    private var state: UInt64

    init(_ seed: String) {
        var h: UInt64 = 1_469_598_103_934_665_603
        for b in seed.utf8 { h = (h ^ UInt64(b)) &* 1_099_511_628_211 }
        state = h
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    mutating func int(_ n: Int) -> Int { n <= 1 ? 0 : Int(next() % UInt64(n)) }

    mutating func double(_ range: ClosedRange<Double>) -> Double {
        let u = Double(next() >> 11) / Double(UInt64(1) << 53)
        return range.lowerBound + u * (range.upperBound - range.lowerBound)
    }

    mutating func pick<T>(_ a: [T]) -> T? { a.isEmpty ? nil : a[int(a.count)] }

    mutating func shuffled<T>(_ a: [T]) -> [T] {
        var a = a
        if a.count > 1 {
            for i in stride(from: a.count - 1, to: 0, by: -1) { a.swapAt(i, int(i + 1)) }
        }
        return a
    }
}

nonisolated enum Levels {

    // MARK: Building a level

    /// The steps for a lesson at a level. Mastery lessons only have one level.
    static func steps(_ lesson: Lesson, tier: LessonTier) -> [LessonStep] {
        guard !lesson.isMastery, tier != .bronze else { return lesson.steps }
        if let written = authored(lesson.id, tier) { return written }
        var out: [LessonStep] = [brief(lesson, tier)]
        // Chords to avoid when building new ones, so a level never repeats a chord from an easier level.
        let builders = lesson.steps.compactMap { step -> ChordShape? in
            if case .chordBuilder(let t) = step { return t.target } else { return nil }
        }
        var avoid = Set(builders.map(\.name))
        if tier == .gold {
            let bronzeNames = avoid
            for b in builders { for c in newChords(b, .silver, avoid: bronzeNames) { avoid.insert(c.name) } }
        }
        for (i, step) in lesson.steps.enumerated() {
            var rng = LevelRNG("\(lesson.id).\(i).\(tier.rawValue)")
            out += adapt(step, tier, &rng, avoid: avoid)
        }
        if tier == .gold, let f = finale(lesson) { out.append(f) }
        return out.contains(where: isGraded) ? out : lesson.steps
    }

    /// Hand-written levels. Lessons without them fall back to the generated levels below.
    static func authored(_ id: String, _ tier: LessonTier) -> [LessonStep]? {
        guard let pair = registry[id] else { return nil }
        switch tier {
        case .bronze: return nil
        case .silver: return pair.silver
        case .gold: return pair.gold
        }
    }

    static func hasAuthored(_ id: String) -> Bool { registry[id] != nil }

    static let registry: [String: LevelPair] = {
        var r: [String: LevelPair] = [:]
        let sources: [[String: LevelPair]] = [FoundationCourse.levels, HouseAcademy.levels, HipHopAcademy.levels,
                                               RnBAcademy.levels, PopAcademy.levels, CoreLevels.all, HouseLevels.all, HouseLevels2.all, TechnoLevels.all,
                                               GarageLevels.all, DeepHouseLevels.all, TechHouseLevels.all,
                                               ProductionLevels.all, AcademyLevels.all]
        for d in sources { r.merge(d) { first, _ in first } }
        return r
    }()

    static func isGraded(_ step: LessonStep) -> Bool {
        switch step {
        case .intro, .keyboard, .reverb: false
        case .filter(let t): t.target != nil
        case .soundLab(let t): t.target != nil
        case .mixer(let t): t.target != nil
        case .tempo(let t): t.target != nil
        default: true
        }
    }

    /// Opening card: what this level asks of you, plus a deeper idea for the skill.
    private static func brief(_ lesson: Lesson, _ tier: LessonTier) -> LessonStep {
        if let note = LevelNotes.note(lesson.id, tier) {
            return .intro(IntroStep(title: note.title, body: note.body,
                                    pads: [], demo: nil, badge: "\(tier.name) level", level: tier))
        }
        let topic = lesson.subtitle.isEmpty ? lesson.title.lowercased() : lesson.subtitle.lowercased()
        let intro: String
        switch tier {
        case .silver:
            intro = "Bronze taught you \(topic). Now use it on material you haven't heard yet. Each task is a new variation you work out by ear, with fewer guides."
        default:
            intro = "Time to own \(topic). Gold tasks are bigger, with more parts to control at once, and finish with a brief where you make your own."
        }
        return .intro(IntroStep(title: lesson.subtitle.isEmpty ? lesson.title : lesson.subtitle,
                                body: intro + "\n\n" + tip(lesson.skill, tier),
                                pads: [], demo: nil, badge: "\(tier.name) level", level: tier))
    }

    private static func tip(_ skill: Skill, _ tier: LessonTier) -> String {
        let gold = tier == .gold
        switch skill {
        case .rhythm:
            return gold
                ? "Pro tip: work out a beat one layer at a time. Lock in the kick, then the clap, then the hats. Focus your ears on one sound per listen."
                : "Pro tip: producers rarely copy a groove exactly. They keep the idea and change the details. Listen for what moved, and count steps in fours."
        case .theory:
            return gold
                ? "Pro tip: hear chords as colours before names. Major 7ths glow, minor 7ths brood, 9ths shimmer. Name the colour, then find the notes."
                : "Pro tip: a chord shape works from any root. Keep the same gaps between the notes and the chord type stays the same."
        case .soundDesign:
            return gold
                ? "Pro tip: knobs affect each other. Get the biggest difference right first, usually pitch or cutoff, then fine-tune the rest."
                : "Pro tip: describe the sound in words before you touch a knob. Dark or bright? Short or long? Soft or snappy?"
        case .mixing:
            return gold
                ? "Pro tip: start from the most important part, usually the kick, and build every other level around it."
                : "Pro tip: check a mix quietly. If a part disappears at low volume, it's too low."
        case .arrangement:
            return gold
                ? "Pro tip: listen for what enters and leaves at each section change. Most tracks add or remove one part at a time."
                : "Pro tip: arrangement is contrast. A drop only hits hard if the section before it held something back."
        }
    }

    // MARK: Adapting one step

    static func adapt(_ step: LessonStep, _ tier: LessonTier, _ rng: inout LevelRNG,
                      avoid: Set<String> = []) -> [LessonStep] {
        let gold = tier == .gold
        switch step {
        case .intro, .keyboard, .reverb:
            // Already learned at Bronze. Higher levels go straight to the work.
            return []

        case .mastery:
            return [step]

        case .sequencer(let t):
            if case .create(let goal) = t.mode {
                var n = t
                n.showBeatGuide = false
                n.mode = .create(harder(goal, tier))
                if gold && !t.swingControl { n.editable = Set(t.tracks) }
                n.hint = t.hint + " " + goalLine(harder(goal, tier))
                return [.sequencer(n)]
            }
            guard t.target != Pattern() else { return [step] }
            return [.sequencer(drumVariation(t, gold: gold, &rng))]

        case .pianoRoll(let t):
            if case .create(let goal) = t.mode {
                var n = t
                n.mode = .create(harder(goal, tier))
                n.hint = t.hint + " " + goalLine(harder(goal, tier))
                return [.pianoRoll(n)]
            }
            guard !t.target.isEmpty else { return [step] }
            var n = t
            n.target = varyBass(t.target, rows: t.rows, gold: gold, &rng)
            n.mode = .recreate
            n.threshold = gold ? 0.9 : 0.85
            // The pre-placed notes stay only if they're still part of the new answer.
            n.start = t.start.filter { s in n.target.contains { $0.step == s.step && $0.pitch == s.pitch } }
            let line = t.voice == .lead ? "melody" : "bassline"
            n.prompt = gold ? "Recreate this longer variation by ear" : "New \(line), same idea"
            n.hint = "At Bronze: \(t.prompt). This one moves some notes. Listen for higher or lower, earlier or later."
            return [.pianoRoll(n)]

        case .chordLane(let t):
            if case .create(let goal) = t.mode {
                var n = t
                n.mode = .create(harder(goal, tier))
                n.hint = t.hint + " " + goalLine(harder(goal, tier))
                return [.chordLane(n)]
            }
            guard !t.target.isEmpty else { return [step] }
            var n = t
            n.target = varyChords(t.target, paletteCount: t.palette.count, gold: gold, &rng)
            n.start = [:]
            n.mode = .recreate
            n.threshold = gold ? 0.9 : 0.85
            n.prompt = gold ? "Recreate the new progression by ear" : "Same stabs, new order"
            if t.chops != nil { n.prompt = gold ? "Recreate this vocal hook by ear" : "Same chops, new rhythm" }
            n.hint = t.chops != nil ? "Count where each chop lands, and listen for which vowel it sings." : t.palette.count > 1
                ? "The chords swapped places or moved earlier. Listen for which one comes first."
                : "The stabs moved. Count where each one lands."
            return [.chordLane(n)]

        case .arrangement(let t):
            var n = t
            if case .create = t.mode {
                // Free arranging is the Gold finale. Here, hear a classic build-up and recreate it.
                n.target = (0..<t.lanes.count).map { l in (0..<t.sections.count).map { s in l <= s + 1 } }
            } else if t.target.isEmpty {
                return [step]
            }
            n.target = varyArrangement(n, gold: gold, &rng)
            n.mode = .recreate
            n.threshold = gold ? 0.95 : 0.9
            n.prompt = gold ? "A different track: rebuild its arrangement by ear" : "New arrangement: recreate it by ear"
            n.hint = "Listen to each section and ask which parts are playing. Bronze idea: \(t.prompt)."
            return [.arrangement(n)]

        case .chordBuilder(let t):
            return newChords(t.target, tier, avoid: avoid).map { chord -> LessonStep in
                var n = t
                n.target = chord
                n.start = []
                if t.exact {
                    // Make room on the keyboard for the exact voicing.
                    n.lowNote = min(t.lowNote, (chord.pitches.min() ?? t.lowNote) - 2)
                    n.highNote = max(t.highNote, (chord.pitches.max() ?? t.highNote) + 2)
                }
                n.prompt = "Build \(chord.name)"
                n.body = gold
                    ? "No starting notes. Same type of chord as \(t.target.name), from a new root."
                    : "Same shape as \(t.target.name), moved to a new root. Keep the gaps between the notes the same."
                return .chordBuilder(n)
            }

        case .earChoice(let t) where t.rounds.contains(where: \.isListening):
            // Listening rounds can't be transposed. Silver plays them in reverse order with the
            // answers moved around; Gold starts from the second round. With Silver and Gold sounds.
            var n = t
            let order = gold ? Array(t.rounds.dropFirst()) + Array(t.rounds.prefix(1)) : Array(t.rounds.reversed())
            n.rounds = order.map { shuffleOptions($0, &rng) }
            n.body = gold ? "New sounds, new order. Listen to the whole loop before you answer."
                          : "Same idea, new sounds. " + t.body
            return [.earChoice(n)]

        case .earChoice(let t):
            // Quick checks of an idea were answered at Bronze; only the musical rounds move to new keys.
            let musical = t.rounds.filter { !$0.isQuestion }
            guard !musical.isEmpty else { return [] }
            var n = t
            let rounds = gold
                ? musical.map { transpose($0, 9) } + musical.map { transpose($0, 2) }
                : musical.map { transpose($0, 5) }
            n.rounds = Array(rng.shuffled(rounds).map { shuffleOptions($0, &rng) }.prefix(6))
            n.body = gold ? "More rounds in new keys. Trust the colour, not the pitch." : "Same question, new keys. " + t.body
            return [.earChoice(n)]

        case .soundLab(let t):
            return [.soundLab(soundVariation(t, gold: gold, &rng))]

        case .mixer(let t):
            return [.mixer(mixVariation(t, gold: gold, &rng))]

        case .tempo(let t):
            guard let target = t.target else { return [] }
            var n = t
            // A new tempo each level, found by ear.
            let options: [Double] = gold ? [96, 118, 136, 150, 172] : [100, 112, 128, 140, 160]
            let far = options.filter { abs($0 - target) >= 10 }
            n.target = rng.pick(far) ?? (target > 120 ? target - 20 : target + 20)
            n.byEar = true
            n.tolerance = gold ? 2 : 3
            n.start = (n.target ?? 120) > 120 ? 100 : 140
            n.prompt = gold ? "Find this tempo by ear, within 2 BPM" : "Find this tempo by ear"
            n.body = "Play the reference, then tap along or drag until your loop locks in with it."
            return [.tempo(n)]

        case .tap(let t):
            // Same idea, fewer lights: Silver fades them after a bar, Gold plays without them.
            var n = t
            n.guideBars = gold ? 0 : 1
            n.tolerance = gold ? 1 : 1.1
            n.prompt = gold ? t.prompt + ", no lights" : t.prompt + ", lights fade"
            return [.tap(n)]

        case .order(let t):
            guard case .create = t.mode else {
                var n = t
                n.start = []
                n.mode = .recreate
                n.prompt = "Rebuild it by ear"
                n.hint = "Listen to the reference, then put the tiles in the order you hear. Bronze idea: \(t.prompt)."
                return [.order(n)]
            }
            return [step]

        case .filter(let t):
            var n = t
            n.target = filterTarget(t.target, gold: gold, &rng)
            if t.target == nil {
                n.prompt = "Match this filter by ear"
                n.body = "You've swept it at Bronze. Now find the exact setting: cutoff first, then resonance."
            } else {
                n.prompt = gold ? "Match a new filter setting" : "Match the opposite filter"
            }
            return [.filter(n)]
        }
    }

    // MARK: Gold finale

    /// "Make it yours": an open brief using the lesson's main tool, with a stricter goal.
    static func finale(_ lesson: Lesson) -> LessonStep? {
        let topic = lesson.subtitle.isEmpty ? lesson.title.lowercased() : lesson.subtitle.lowercased()
        for step in lesson.steps {
            switch step {
            case .sequencer(let t) where !t.swingControl:
                let main = t.editable.sorted { $0.rawValue < $1.rawValue }.first ?? t.tracks.first ?? .kick
                let n = min(12, max(4, t.target.hits(main) + 2))
                var start = Pattern()
                start.bass = t.start.bass
                start.chords = t.start.chords
                return .sequencer(SequencerTask(
                    prompt: "Make it yours",
                    hint: "Write your own groove that uses \(topic). Every drum is yours. Use at least \(n) \(main.name.lowercased()) hits.",
                    mode: .create(.atLeast(main, n)), tracks: t.tracks, editable: Set(t.tracks),
                    start: start, showBeatGuide: false))
            case .pianoRoll(let t):
                let n = max(5, t.target.count + 2)
                return .pianoRoll(PianoRollTask(
                    prompt: "Make it yours",
                    hint: "Write your own \(t.voice == .lead ? "melody" : "bassline") that uses \(topic). Use at least \(n) notes and at least two different pitches.",
                    mode: .create(.notesAtLeast(n)), rows: t.rows, backing: t.backing, voice: t.voice))
            case .chordLane(let t):
                let n = max(3, t.target.count + 1)
                let part = t.chops == nil ? "chord part" : "vocal hook"
                var task = ChordLaneTask(
                    prompt: "Make it yours",
                    hint: "Write your own \(part) that uses \(topic). Place at least \(n) \(t.chops == nil ? "stabs" : "chops").",
                    mode: .create(.chordsAtLeast(n)), palette: t.palette, backing: t.backing,
                    stabLength: t.stabLength)
                task.chops = t.chops
                task.vox = t.vox
                return .chordLane(task)
            case .arrangement(let t):
                return .arrangement(ArrangementTask(
                    prompt: "Arrange your own track",
                    hint: "Every section should play something, and no two neighbouring sections should match.",
                    mode: .create(.variedSections), sections: t.sections, lanes: t.lanes, loop: t.loop,
                    start: t.start, barsPerSection: t.barsPerSection))
            case .soundLab(let t):
                let params = Array(group(of: t.params).prefix(4))
                return .soundLab(SoundLabTask(
                    prompt: "Design your own sound",
                    body: "Every knob for this sound. Move each one and land on something you'd put in a track.",
                    params: params, start: params.map { _ in 0.5 }, loop: t.loop))
            case .mixer(let t):
                let channels = Array(available(t.loop).prefix(5))
                return .mixer(MixerTask(
                    prompt: "Make your own mix",
                    body: "Every fader starts low. Bring each part up to where it sounds right to you.",
                    channels: channels, start: channels.map { _ in 0.2 }, loop: t.loop))
            default:
                continue
            }
        }
        return nil
    }

    // MARK: Goals

    static func harder(_ goal: CreativeGoal, _ tier: LessonTier) -> CreativeGoal {
        let gold = tier == .gold
        switch goal {
        case .atLeast(let t, let n): return .atLeast(t, min(12, n + (gold ? 4 : 2)))
        case .swingAtLeast(let s): return .swingAtLeast(min(0.4, s + (gold ? 0.12 : 0.06)))
        case .notesAtLeast(let n): return .notesAtLeast(min(12, n + (gold ? 3 : 2)))
        case .chordsAtLeast(let n): return .chordsAtLeast(min(10, n + (gold ? 2 : 1)))
        case .variedSections: return .variedSections
        }
    }

    static func goalLine(_ goal: CreativeGoal) -> String {
        switch goal {
        case .atLeast(let t, let n): "Goal: at least \(n) \(t.name.lowercased()) hits."
        case .swingAtLeast(let s): "Goal: swing of at least \(Int(s * 200))%."
        case .notesAtLeast(let n): "Goal: at least \(n) notes."
        case .chordsAtLeast(let n): "Goal: at least \(n) stabs."
        case .variedSections: "Goal: every section different from the one before."
        }
    }

    // MARK: Drums

    private static func drumVariation(_ t: SequencerTask, gold: Bool, _ rng: inout LevelRNG) -> SequencerTask {
        // The full Bronze groove: playable parts from the answer, the rest from the backing.
        var ref = t.start
        for tr in t.tracks {
            if t.editable.contains(tr) || t.start.hits(tr) == 0 { ref[tr] = t.target[tr] }
        }
        if ref.bass.isEmpty { ref.bass = t.target.bass }
        if ref.chords.isEmpty { ref.chords = t.target.chords }

        let edit: Set<DrumTrack> = gold ? Set(t.tracks) : t.editable
        let active = rng.shuffled(t.tracks.filter { edit.contains($0) && ref.hits($0) > 0 })
        let count = gold ? active.count : (active.count >= 3 ? 2 : 1)
        var varied = ref
        for tr in active.prefix(count) {
            varied[tr] = varyRow(varied[tr], tr, &rng)
            if gold { varied[tr] = varyRow(varied[tr], tr, &rng) }
        }
        if varied == ref, let tr = active.first ?? t.tracks.first(where: { edit.contains($0) }) {
            var row = varied[tr]
            row[rng.pick([15, 7, 11, 3]) ?? 15].toggle()
            varied[tr] = row
        }

        var start = varied
        for tr in edit { start[tr] = [Bool](repeating: false, count: Pattern.steps) }

        var n = t
        n.editable = edit
        n.target = varied
        n.start = start
        n.mode = .recreate
        n.showBeatGuide = false
        n.threshold = gold ? 0.9 : 0.85
        if gold {
            n.prompt = edit.count > 1 ? "Rebuild the whole groove by ear" : "Recreate this busier pattern by ear"
        } else if edit.count == 1, let only = edit.first {
            n.prompt = "New \(only.name.lowercased()) pattern: recreate it by ear"
        } else {
            n.prompt = "New variation: recreate it by ear"
        }
        n.hint = "At Bronze: \(t.prompt). This one changes a few hits. Listen for what's new."
        return n
    }

    /// An idiomatic change to one drum row that keeps the lesson's idea.
    private static func varyRow(_ row: [Bool], _ t: DrumTrack, _ rng: inout LevelRNG) -> [Bool] {
        let on = row.indices.filter { row[$0] }
        func adding(_ s: [Int]) -> [Bool] { var r = row; for i in s where i < r.count { r[i] = true }; return r }
        func removing(_ s: [Int]) -> [Bool] { var r = row; for i in s where i < r.count { r[i] = false }; return r }
        func rotated(_ k: Int) -> [Bool] { (0..<row.count).map { row[(($0 - k) % row.count + row.count) % row.count] } }
        let options: [[Bool]]
        switch t {
        case .kick: options = [adding([14]), adding([7]), adding([10]), adding([3, 14])]
        case .clap: options = [adding([15]), adding([7]), adding([11, 15])]
        case .hat:
            options = on.count >= 12
                ? [removing([0, 8]), removing([4, 12]), removing([3, 7, 11, 15])]
                : [adding([3, 11]), adding([15]), adding([1, 9]), rotated(2)]
        case .openHat: options = [adding([14]), adding([6]), adding([2, 10]), removing([on.last ?? 0])]
        case .perc: options = [rotated(3), rotated(2), adding([7]), adding([13])]
        }
        let valid = options.filter { $0 != row && $0.contains(true) }
        return rng.pick(valid) ?? row
    }

    // MARK: Bass

    private static func varyBass(_ notes: [NoteEvent], rows: [Int], gold: Bool, _ rng: inout LevelRNG) -> [NoteEvent] {
        var out = notes.sorted { $0.step < $1.step }
        func free(_ step: Int, _ len: Int, except id: UUID?) -> Bool {
            step >= 0 && step + len <= Pattern.steps
                && !out.contains { $0.id != id && $0.step < step + len && step < $0.endStep }
        }
        // New notes: move one (two at Gold) to a neighbouring row.
        for _ in 0..<(gold ? 2 : 1) where !out.isEmpty && rows.count > 1 {
            let i = rng.int(out.count)
            guard let r = rows.firstIndex(of: out[i].pitch) else { out[i].pitch = rows[0]; continue }
            let up = rng.int(2) == 0
            let nr = up ? (r > 0 ? r - 1 : r + 1) : (r < rows.count - 1 ? r + 1 : r - 1)
            out[i].pitch = rows[nr]
        }
        // New rhythm: nudge a note a step earlier or later.
        for _ in 0..<(gold ? 2 : 1) where !out.isEmpty {
            let i = rng.int(out.count)
            let note = out[i]
            if let s = [note.step + 1, note.step - 1].first(where: { free($0, note.length, except: note.id) }) {
                out[i].step = s
            }
        }
        // Gold: one extra note in a gap.
        if gold, !rows.isEmpty {
            let gaps = (0..<Pattern.steps).filter { $0 % 2 == 1 && free($0, 1, except: nil) }
            if let g = rng.pick(gaps) { out.append(NoteEvent(g, rows[rng.int(rows.count)])) }
        }
        let same = out.count == notes.count && zip(out.sorted { $0.step < $1.step }, notes.sorted { $0.step < $1.step })
            .allSatisfy { $0.step == $1.step && $0.pitch == $1.pitch && $0.length == $1.length }
        if same, rows.count > 1, !out.isEmpty {
            let r = rows.firstIndex(of: out[0].pitch) ?? 0
            out[0].pitch = rows[r == 0 ? 1 : r - 1]
        }
        return out.sorted { $0.step < $1.step }
    }

    // MARK: Chords

    private static func varyChords(_ map: [Int: Int], paletteCount: Int, gold: Bool,
                                   _ rng: inout LevelRNG) -> [Int: Int] {
        func pushed(_ m: [Int: Int]) -> [Int: Int] {
            var out: [Int: Int] = [:]
            for (step, idx) in m.sorted(by: { $0.key < $1.key }) {
                let s = step > 0 && m[step - 1] == nil && out[step - 1] == nil ? step - 1 : step
                out[s] = idx
            }
            return out
        }
        var out = map
        let canReorder = paletteCount > 1
        if canReorder { out = out.mapValues { ($0 + 1) % paletteCount } }
        if gold || !canReorder { out = pushed(out) }
        if gold {
            let free = (0..<Pattern.steps).filter { $0 % 2 == 1 && out[$0] == nil && out[$0 - 1] == nil }
            if let s = rng.pick(free) { out[s] = rng.int(max(1, paletteCount)) }
        }
        if out == map {
            let s = (0..<Pattern.steps).first { out[$0] == nil } ?? 0
            out[s] = 0
        }
        return out
    }

    /// New roots for a chord-building step: one at Silver, two at Gold.
    static func newChords(_ chord: ChordShape, _ tier: LessonTier, avoid: Set<String>) -> [ChordShape] {
        let shifts = tier == .gold ? [7, 3, 9, 4, 11, 6] : [5, 2, 10, 1, 8]
        var out: [ChordShape] = []
        for s in shifts {
            guard let c = transpose(chord, s), !avoid.contains(c.name),
                  !out.contains(where: { $0.name == c.name }) else { continue }
            out.append(c)
            if out.count == (tier == .gold ? 2 : 1) { break }
        }
        return out
    }

    private static let flatNames = ["C", "D♭", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "B♭", "B"]
    private static let suffixes: Set<String> = ["", "m", "7", "m7", "maj7", "m9", "maj9", "9", "dim", "sus2", "sus4",
                                                "6", "m6", "add9"]

    /// "D♭maj7" -> (1, "maj7")
    static func parseChord(_ name: String) -> (root: Int, suffix: String)? {
        let letters: [Character: Int] = ["C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11]
        guard let first = name.first, let base = letters[first] else { return nil }
        var rest = name.dropFirst()
        var root = base
        if let acc = rest.first {
            if acc == "♭" || acc == "b" { root -= 1; rest = rest.dropFirst() }
            else if acc == "♯" || acc == "#" { root += 1; rest = rest.dropFirst() }
        }
        let suffix = String(rest)
        guard suffixes.contains(suffix) else { return nil }
        return ((root + 12) % 12, suffix)
    }

    static func transpose(_ c: ChordShape, _ semitones: Int) -> ChordShape? {
        guard let (root, suffix) = parseChord(c.name) else { return nil }
        var pitches = c.pitches.map { $0 + semitones }
        if (pitches.max() ?? 0) > 76 { pitches = pitches.map { $0 - 12 } }
        if (pitches.min() ?? 60) < 45 { pitches = pitches.map { $0 + 12 } }
        return ChordShape(name: flatNames[(root + semitones % 12 + 12) % 12] + suffix, pitches: pitches)
    }

    /// Chord names inside free text ("Fmaj7.", "Am9") move with the chords.
    private static func transposeText(_ text: String, _ semitones: Int) -> String {
        text.split(separator: " ", omittingEmptySubsequences: false).map { word -> String in
            let w = String(word)
            let core = w.trimmingCharacters(in: CharacterSet(charactersIn: ".,!?()"))
            guard !core.isEmpty, let parsed = parseChord(core) else { return w }
            let name = flatNames[(parsed.root + semitones % 12 + 12) % 12] + parsed.suffix
            return w.replacingOccurrences(of: core, with: name)
        }.joined(separator: " ")
    }

    /// Moves a whole round by the same amount, so "up or down" and "smooth or jumpy" answers still hold.
    /// Single notes (melodic phrases) are renamed by pitch; chords by their root.
    private static func transpose(_ r: EarRound, _ semitones: Int) -> EarRound {
        let all = r.chords.flatMap(\.pitches)
        var shift = semitones
        if (all.max() ?? 0) + shift > 76 { shift -= 12 }
        if (all.min() ?? 60) + shift < 45 { shift += 12 }
        var moved: [ChordShape] = []
        for c in r.chords {
            let pitches = c.pitches.map { $0 + shift }
            if c.pitches.count == 1 {
                moved.append(ChordShape(name: NoteName.name(pitches[0]), pitches: pitches))
            } else if let (root, suffix) = parseChord(c.name) {
                moved.append(ChordShape(name: flatNames[(root + semitones % 12 + 12) % 12] + suffix, pitches: pitches))
            } else {
                return r
            }
        }
        var n = r
        n.chords = moved
        n.options = r.options.map { transposeText($0, semitones) }
        n.explain = transposeText(r.explain, semitones)
        return n
    }

    private static func shuffleOptions(_ r: EarRound, _ rng: inout LevelRNG) -> EarRound {
        let order = rng.shuffled(Array(r.options.indices))
        var n = r
        n.options = order.map { r.options[$0] }
        n.answer = order.firstIndex(of: r.answer) ?? r.answer
        return n
    }

    // MARK: Arrangement

    private static func varyArrangement(_ t: ArrangementTask, gold: Bool, _ rng: inout LevelRNG) -> [[Bool]] {
        let original = t.grid(t.target)
        var g = original
        let lanes = t.lanes.count, cols = t.sections.count
        guard lanes > 0, cols > 1 else { return g }
        func column(_ s: Int) -> [Bool] { (0..<lanes).map { g[$0][s] } }
        var pairs: [(Int, Int)] = []
        for a in 0..<cols { for b in (a + 1)..<cols where column(a) != column(b) { pairs.append((a, b)) } }
        if let (a, b) = rng.pick(pairs) {
            for l in 0..<lanes { g[l].swapAt(a, b) }
        }
        if gold || g == original {
            for _ in 0..<(gold ? 2 : 1) {
                let l = rng.int(lanes), s = rng.int(cols)
                g[l][s].toggle()
                // Never leave a section silent.
                if !column(s).contains(true) { g[l][s] = true; g[(l + 1) % lanes][s] = true }
            }
        }
        return g
    }

    // MARK: Sound design

    /// Every knob for the same sound as `params` (kick, bass or chords).
    static func group(of params: [SoundParam]) -> [SoundParam] {
        let prefix = params.first.map { p -> String in
            p.rawValue.hasPrefix("kick") ? "kick" : p.rawValue.hasPrefix("bass") ? "bass" : "chord"
        } ?? "kick"
        return SoundParam.allCases.filter { $0.rawValue.hasPrefix(prefix) }
    }

    private static func distance(_ a: [Double], _ b: [Double]) -> Double {
        zip(a, b).map { abs($0 - $1) }.max() ?? 0
    }

    private static func soundVariation(_ t: SoundLabTask, gold: Bool, _ rng: inout LevelRNG) -> SoundLabTask {
        let base = t.target ?? t.start
        var n = t
        n.loop = t.loop
        if !gold {
            // The opposite character: dark becomes bright, short becomes long.
            var target = base.map { min(0.9, max(0.1, 1 - $0)) }
            if distance(target, base) < 0.35, !target.isEmpty {
                target[0] = base[0] > 0.5 ? max(0.1, base[0] - 0.45) : min(0.9, base[0] + 0.45)
            }
            n.start = base
            n.target = target
            n.threshold = 0.85
            n.prompt = t.target == nil ? "Match this sound by ear" : "Match the opposite sound"
            n.body = "Describe it first. Brighter or darker? Longer or shorter? Then turn the knobs."
            return n
        }
        var params = t.params
        if params.count < 4, let extra = group(of: t.params).first(where: { !params.contains($0) }) {
            params.append(extra)
        }
        var target = params.map { _ in rng.double(0.1...0.9) }
        let compare = Array(target.prefix(base.count))
        if distance(compare, base) < 0.3, !target.isEmpty {
            target[0] = base.first.map { $0 > 0.5 ? max(0.1, $0 - 0.45) : min(0.9, $0 + 0.45) } ?? 0.5
        }
        n.params = params
        n.start = params.map { _ in 0.5 }
        n.target = target
        n.threshold = 0.9
        n.prompt = "Match this sound with \(params.count) knobs"
        n.body = params.count > t.params.count
            ? "A new knob joins in: \(params.last?.label ?? ""). Find the biggest difference first."
            : "All knobs, new target. Find the biggest difference first."
        return n
    }

    // MARK: Mixing

    private static func available(_ loop: Pattern) -> [MixChannel] {
        var out: [MixChannel] = DrumTrack.allCases.filter { loop.hits($0) > 0 }.map { .drum($0) }
        if !loop.bass.isEmpty { out.append(.bass) }
        if !loop.chords.isEmpty { out.append(.chords) }
        if !loop.bass.isEmpty || !loop.chords.isEmpty { out.append(.sidechain) }
        return out
    }

    private static func mixVariation(_ t: MixerTask, gold: Bool, _ rng: inout LevelRNG) -> MixerTask {
        let base = t.target ?? t.start
        var n = t
        if !gold {
            var target: [Double]
            if base.count > 1 {
                target = Array(base.dropFirst()) + [base[0]]
            } else {
                target = base.map { $0 < 0.3 ? 0.65 : max(0.1, 1 - $0) }
            }
            if distance(target, base) < 0.25 {
                target = base.map { _ in rng.double(0.3...0.9) }
                if distance(target, base) < 0.25, !target.isEmpty {
                    target[0] = base[0] > 0.5 ? 0.25 : 0.9
                }
            }
            n.start = base
            n.target = target
            n.threshold = 0.85
            n.prompt = "Match a new balance"
            n.body = "Same parts, different mix. Listen for which part leads now."
            return n
        }
        var channels = t.channels
        if channels.count < 5, let extra = available(t.loop).first(where: { !channels.contains($0) }) {
            channels.append(extra)
        }
        var target = channels.map { ch -> Double in
            ch == .sidechain ? rng.double(0.3...0.8) : rng.double(0.3...0.9)
        }
        if distance(Array(target.prefix(base.count)), base) < 0.25, !target.isEmpty {
            target[0] = (base.first ?? 0.5) > 0.5 ? 0.3 : 0.85
        }
        n.channels = channels
        n.start = channels.map { $0 == .sidechain ? 0 : MixerTask.unity }
        n.target = target
        n.threshold = 0.9
        n.prompt = "Match this mix with \(channels.count) controls"
        n.body = channels.count > t.channels.count
            ? "\(channels.last?.label ?? "A new part") joins the mix. Set the loudest part first."
            : "Every control, new targets. Set the loudest part first."
        return n
    }

    // MARK: Filter

    private static func filterTarget(_ t: (cutoff: Double, resonance: Double)?, gold: Bool,
                                     _ rng: inout LevelRNG) -> (cutoff: Double, resonance: Double) {
        let options: [Double] = gold ? [350, 650, 1800, 4000] : [500, 800, 1200, 2500]
        guard let t else {
            return (rng.pick(options) ?? 1200, rng.double(0.2...0.8))
        }
        if !gold {
            let c = t.cutoff < 1500 ? min(6000, t.cutoff * 3) : max(300, t.cutoff / 3)
            return (c, min(0.85, max(0.1, 1 - t.resonance)))
        }
        let far = options.filter { abs(log2($0 / t.cutoff)) > 0.8 }
        return (rng.pick(far) ?? 4000, rng.double(0.2...0.85))
    }

    // MARK: Checks

    /// A description of what a step asks for, used to make sure the levels really differ.
    static func fingerprint(_ step: LessonStep) -> String {
        func bits(_ p: Pattern) -> String {
            DrumTrack.allCases.map { t in p[t].map { $0 ? "x" : "-" }.joined() }.joined(separator: "|")
        }
        switch step {
        case .sequencer(let t):
            return "seq \(t.mode) \(t.editable.map(\.rawValue).sorted()) \(bits(t.target))"
        case .pianoRoll(let t):
            return "bass \(t.mode) " + t.target.sorted { $0.step < $1.step }.map { "\($0.step):\($0.pitch):\($0.length)" }.joined(separator: ",")
        case .chordLane(let t):
            return "lane \(t.mode) " + t.target.sorted { $0.key < $1.key }.map { "\($0.key):\($0.value)" }.joined(separator: ",")
        case .arrangement(let t):
            return "arr \(t.mode) \(t.sections) \(t.target)"
        case .chordBuilder(let t):
            return "build \(t.target.name)"
        case .earChoice(let t):
            let rounds = t.rounds.map { r -> String in
                let chords = r.chords.map(\.name).joined(separator: "+")
                let loops = r.loops.map(bits).joined(separator: "+")
                return "\(chords)/\(r.options.joined(separator: ","))/\(r.answer)/\(loops)"
            }
            return "ear " + rounds.joined(separator: ";")
        case .tempo(let t):
            return "tempo \(t.target ?? 0) \(t.byEar)"
        case .soundLab(let t):
            return "lab \(t.params.map(\.rawValue)) \(t.target ?? [])"
        case .mixer(let t):
            return "mix \(t.channels.map(\.label)) \(t.target ?? [])"
        case .filter(let t):
            return "filter \(t.target.map { "\($0.cutoff)/\($0.resonance)" } ?? "explore")"
        case .tap(let t):
            return "tap \(t.targets) \(t.guideBars)"
        case .order(let t):
            return "order \(t.mode) \(t.tiles.map(\.name)) \(t.answer)"
        case .intro, .keyboard, .reverb, .mastery:
            return "other"
        }
    }
}
