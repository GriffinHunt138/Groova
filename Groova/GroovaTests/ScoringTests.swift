//
//  ScoringTests.swift
//  GroovaTests
//
//  The grading has to be deterministic and fair. These pin it down.
//

import Foundation
import Testing
@testable import Groova

@MainActor
struct ScoringTests {

    @Test func perfectRhythmScoresOne() {
        let ref = Pattern(kick: [0, 4, 8, 12]).kick
        #expect(Scoring.rhythm(user: ref, reference: ref).accuracy == 1)
    }

    @Test func missingNotesCostMoreThanExtraOnes() {
        let ref = Pattern(kick: [0, 4, 8, 12]).kick
        let missingOne = Pattern(kick: [0, 4, 8]).kick
        let extraOne = Pattern(kick: [0, 4, 8, 12, 14]).kick
        let missing = Scoring.rhythm(user: missingOne, reference: ref).accuracy
        let extra = Scoring.rhythm(user: extraOne, reference: ref).accuracy
        #expect(missing < extra)
        #expect(Scoring.rhythm(user: missingOne, reference: ref).marks[12] == .missed)
        #expect(Scoring.rhythm(user: extraOne, reference: ref).marks[14] == .extra)
    }

    @Test func emptyGridDoesNotPassAFourOnTheFloor() {
        let ref = Pattern(kick: [0, 4, 8, 12]).kick
        let empty = [Bool](repeating: false, count: 16)
        #expect(Scoring.rhythm(user: empty, reference: ref).accuracy < 0.8)
    }

    @Test func melodyWeighsPitchTimingAndLength() {
        let ref = [NoteEvent(2, 33), NoteEvent(6, 36, 2)]
        #expect(Scoring.melody(user: ref.map { NoteEvent($0.step, $0.pitch, $0.length) }, reference: ref).accuracy == 1)

        let wrongPitch = [NoteEvent(2, 33), NoteEvent(6, 38, 2)]
        let wrongLength = [NoteEvent(2, 33), NoteEvent(6, 36, 1)]
        let pitchScore = Scoring.melody(user: wrongPitch, reference: ref).accuracy
        let lengthScore = Scoring.melody(user: wrongLength, reference: ref).accuracy
        #expect(pitchScore < lengthScore)
        #expect(lengthScore < 1)
    }

    @Test func extraNotesArePenalised() {
        let ref = [NoteEvent(2, 33)]
        let user = [NoteEvent(2, 33), NoteEvent(5, 40)]
        #expect(Scoring.melody(user: user, reference: ref).accuracy == 0.5)
    }

    @Test func filterMatchIsParameterBased() {
        #expect(Scoring.filterMatch(cutoff: 650, resonance: 0.55, targetCutoff: 650, targetResonance: 0.55) == 1)
        #expect(Scoring.filterMatch(cutoff: 2600, resonance: 0.55, targetCutoff: 650, targetResonance: 0.55) < 0.8)
    }

    @Test func houseMasteryReferenceIsSelfConsistent() {
        let ref = Curriculum.houseMasteryReference
        for t in DrumTrack.allCases {
            #expect(Scoring.rhythm(user: ref[t], reference: ref[t]).accuracy == 1)
        }
        #expect(Scoring.melody(user: ref.bass, reference: ref.bass).accuracy == 1)
        // Every mastery bass note must sit on a row the learner can actually reach.
        #expect(ref.bass.allSatisfy { Curriculum.bassRows.contains($0.pitch) })
    }

    @Test func chordLaneScoring() {
        var ref = [Int?](repeating: nil, count: 16)
        ref[2] = 0; ref[10] = 1
        #expect(Scoring.chordLane(user: ref, reference: ref).accuracy == 1)
        var wrongChord = ref
        wrongChord[10] = 0
        let half = Scoring.chordLane(user: wrongChord, reference: ref)
        #expect(half.marks[10] == .extra)
        var missing = ref
        missing[10] = nil
        let miss = Scoring.chordLane(user: missing, reference: ref)
        #expect(miss.marks[10] == .missed)
        // Right timing with the wrong chord beats leaving it out.
        #expect(half.accuracy > miss.accuracy)
    }

    @Test func curriculumIsReachable() {
        for genre in Genre.allCases {
            for lesson in Curriculum.allLessons(for: genre) {
                for step in lesson.steps {
                    switch step {
                    case .chordLane(let t):
                        #expect(t.target.values.allSatisfy { $0 < t.palette.count }, "\(lesson.id)")
                        #expect(t.start.values.allSatisfy { $0 < t.palette.count }, "\(lesson.id)")
                        #expect(t.target.keys.allSatisfy { (0..<16).contains($0) }, "\(lesson.id)")
                    case .pianoRoll(let t):
                        #expect(t.target.allSatisfy { t.rows.contains($0.pitch) }, "\(lesson.id)")
                    case .chordBuilder(let t):
                        let reachable = Set((t.lowNote...t.highNote).map { $0 % 12 })
                        #expect(t.target.pitchClasses.isSubset(of: reachable), "\(lesson.id)")
                    case .earChoice(let t):
                        #expect(t.rounds.allSatisfy { $0.answer < $0.options.count }, "\(lesson.id)")
                    case .soundLab(let t):
                        #expect(t.start.count == t.params.count, "\(lesson.id)")
                        #expect((t.target ?? t.start).count == t.params.count, "\(lesson.id)")
                    case .mixer(let t):
                        #expect(t.start.count == t.channels.count, "\(lesson.id)")
                        #expect((t.target ?? t.start).count == t.channels.count, "\(lesson.id)")
                    case .arrangement(let t):
                        for g in [t.start, t.target] where !g.isEmpty {
                            #expect(g.count == t.lanes.count, "\(lesson.id)")
                            #expect(g.allSatisfy { $0.count == t.sections.count }, "\(lesson.id)")
                        }
                    default:
                        break
                    }
                }
            }
        }
    }

    @Test func everyGenreHasAFullCourse() {
        var ids = Set<String>()
        for genre in Genre.allCases {
            let units = Curriculum.units(for: genre)
            #expect(units.count >= 4, "\(genre)")
            for unit in units {
                #expect(unit.mastery != nil, "\(unit.id) needs a mastery challenge")
                for lesson in unit.lessons {
                    #expect(!lesson.steps.isEmpty, "\(lesson.id)")
                    #expect(ids.insert(lesson.id).inserted, "duplicate id \(lesson.id)")
                }
            }
        }
        #expect(ids.count == 138)
    }

    @Test func everyLessonHasHarderLevels() {
        for genre in Genre.allCases {
            for lesson in Curriculum.allLessons(for: genre)
            where !lesson.isMastery && lesson.steps.contains(where: Levels.isGraded) {
                for tier in LessonTier.allCases {
                    let steps = Levels.steps(lesson, tier: tier)
                    #expect(steps.contains(where: Levels.isGraded), "\(lesson.id) \(tier.name) has nothing to grade")
                }
                #expect(AppState.drill(from: lesson) != nil, "\(lesson.id) has no practice drill")
                // Each level asks for something new, not the same task again.
                func graded(_ t: LessonTier) -> Set<String> {
                    Set(Levels.steps(lesson, tier: t).filter(Levels.isGraded).map(Levels.fingerprint))
                }
                let bronze = graded(.bronze), silver = graded(.silver), gold = graded(.gold)
                #expect(bronze.isDisjoint(with: silver), "\(lesson.id) Silver repeats Bronze")
                #expect(bronze.isDisjoint(with: gold), "\(lesson.id) Gold repeats Bronze")
                #expect(silver.isDisjoint(with: gold), "\(lesson.id) Gold repeats Silver")
                #expect(Levels.steps(lesson, tier: .gold).count >= Levels.steps(lesson, tier: .silver).count)
            }
        }
    }

    @Test func levelXPRewardsHarderPlay() {
        let lesson = Curriculum.allLessons(for: .house)[0]
        let bronze = AppState.xp(for: lesson, tier: .bronze, replay: false)
        let silver = AppState.xp(for: lesson, tier: .silver, replay: false)
        let gold = AppState.xp(for: lesson, tier: .gold, replay: false)
        #expect(bronze < silver && silver <= gold)
        #expect(AppState.xp(for: lesson, tier: .gold, replay: true) < gold)
    }

    @Test func sketchRoundTrips() throws {
        let s = Sketch.fresh(.deepHouse)
        let data = try JSONEncoder().encode(s)
        let back = try JSONDecoder().decode(Sketch.self, from: data)
        #expect(back == s)
        #expect(!back.playable.chords.isEmpty)
    }

    @Test func jamRoundTripsAndPlays() throws {
        var jam = Jam.starter(.house)
        jam[.bass].setBars(4)
        jam[.vox].set(.pitch, 0.75)
        let data = try JSONEncoder().encode(jam)
        let back = try JSONDecoder().decode(Jam.self, from: data)
        #expect(back == jam)
        #expect(back[.bass].bars == 4)

        let loop = jam.song(arranged: false)
        #expect(loop.lanes.count == JamLane.allCases.count)
        #expect(loop.lanes.allSatisfy { $0.steps.count == Jam.loopBars * Pattern.steps })
        #expect(loop.sections.isEmpty)
        // The starter groove plays a kick on every bar of the loop.
        let kicks = loop.lanes[JamLane.kick.rawValue].steps.filter { !$0.isEmpty }.count
        #expect(kicks == 4 * Jam.loopBars)

        let song = jam.song(arranged: true)
        #expect(song.totalSteps == jam.songBars * Pattern.steps)
        #expect(song.locate(song.start(of: 2)).section == 2)
        #expect(song.locate(song.totalSteps).section == 0)
    }

    @Test func levelCurve() {
        #expect(AppState.level(for: 0).level == 1)
        #expect(AppState.level(for: 100).level == 2)
        #expect(AppState.level(for: 249).level == 2)
        #expect(AppState.level(for: 250).level == 3)
    }
}
