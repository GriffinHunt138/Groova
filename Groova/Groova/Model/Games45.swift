//
//  Games45.swift
//  Groova
//
//  Game data for F4, Sounds & Production Tools, and F5, From Loop to Song.
//

import Foundation

// MARK: - Shared: voices and stems

/// A named synth sound for sound-design games.
nonisolated struct SoundVoice: Sendable, Hashable {
    var name: String
    var symbol: String
    var patch: SynthPatch

    static let piano = SoundVoice(name: "Piano", symbol: "pianokeys", patch: .popPiano)
    static let pluck = SoundVoice(name: "Pluck", symbol: "guitars.fill", patch: .pluck)
    static let pad = SoundVoice(name: "Pad", symbol: "cloud.fill", patch: .softPad)
    static let keys = SoundVoice(name: "Keys", symbol: "music.note", patch: .rhodes)
    static let organ = SoundVoice(name: "Organ", symbol: "building.columns.fill", patch: .organ)
    static let bell = SoundVoice(name: "Bell", symbol: "bell.fill",
                                 patch: SynthPatch(saw: 0, square: 0.05, sine: 1, detuneCents: 7, cutoff: 5000, envAmount: 0,
                                                   filterDecay: 0.3, resonance: 0, attack: 0.002, decay: 1.4, sustain: 0,
                                                   release: 0.9, gain: 0.3))
    static let click = SoundVoice(name: "Click", symbol: "bolt.fill",
                                  patch: SynthPatch(saw: 0.9, square: 0.3, sine: 0, cutoff: 3000, envAmount: 6000,
                                                    filterDecay: 0.02, resonance: 0.2, attack: 0.001, decay: 0.04, sustain: 0,
                                                    release: 0.02, gain: 0.35))
    static let brass = SoundVoice(name: "Brass", symbol: "music.mic",
                                  patch: SynthPatch(saw: 0.8, square: 0.1, sine: 0.2, detuneCents: 6, cutoff: 900, envAmount: 2400,
                                                    filterDecay: 0.25, resonance: 0.2, attack: 0.06, decay: 0.3, sustain: 0.7,
                                                    release: 0.2, gain: 0.22))

    /// Every voice, in a fixed order, so a saved choice can be stored as an index.
    static let all: [SoundVoice] = [.piano, .pluck, .pad, .keys, .organ, .bell, .click, .brass]
}

/// The four parts of a little song, for mixing, casting and arranging.
nonisolated struct Stems: Sendable {
    var drums: Pattern
    var bass: [NoteEvent]
    var chords: [ChordEvent]
    var lead: [NoteEvent]
}

// MARK: - Sound X-Ray (F4.1)

nonisolated enum XRayMode: Sendable, Equatable {
    /// The same melody on each voice.
    case identities([SoundVoice])
    /// One note split into attack, body and tail zones.
    case peel(SoundVoice)
    /// Hear a mystery voice, pick its fingerprint.
    case match(SoundVoice, options: [SoundVoice])
    /// A layered sound. Solo its parts and name both.
    case layers(SoundVoice, SoundVoice, options: [SoundVoice])
    /// Gold: pick a brief.
    case brief
    /// Gold: attack from one voice, tail from another, blended.
    case hybrid([SoundVoice])
    /// Gold: hybrid against its sources.
    case reveal
}

nonisolated struct XRayRound: Sendable {
    var title: String
    var body: String
    var mode: XRayMode
}

// MARK: - Synth Surgery (F4.2)

nonisolated enum SurgeryTool: Sendable, Hashable, CaseIterable { case attack, release, filter }

/// The sculpture's three controls, each 0...1.
nonisolated struct SculptShape: Sendable, Hashable {
    var attack = 0.05
    var release = 0.3
    var filter = 0.8

    func distance(_ o: SculptShape, tools: Set<SurgeryTool>) -> Double {
        var d = 0.0
        if tools.contains(.attack) { d = max(d, abs(attack - o.attack)) }
        if tools.contains(.release) { d = max(d, abs(release - o.release)) }
        if tools.contains(.filter) { d = max(d, abs(filter - o.filter)) }
        return d
    }
}

nonisolated enum SurgeryMode: Sendable, Equatable {
    /// Explore one gesture.
    case explore(SurgeryTool)
    /// Reshape `start` until it sounds like `target`, using these tools.
    case match(target: SculptShape, start: SculptShape, tools: Set<SurgeryTool>, showTarget: Bool)
    /// Gold: pick a role.
    case role
    /// Gold: design version A, then B.
    case design(second: Bool)
    /// Gold: hear A and B in a track and keep one.
    case inTrack
}

nonisolated struct SurgeryRound: Sendable {
    var title: String
    var body: String
    var mode: SurgeryMode
}

// MARK: - Acoustic Architect (F4.3)

nonisolated enum ArchitectMode: Sendable, Equatable {
    /// Drag the source between these rooms.
    case rooms([ReverbSpace])
    /// A room versus the echo tunnel.
    case tunnel
    /// Hear mystery spaces (nil is dry) and drop each into its room.
    case identify([ReverbSpace?])
    /// Set the echo tunnel to repeat every this many steps.
    case echoTime(target: Int)
    /// The mix is too wet. Pull it back to about this much.
    case wetFix(target: Double)
    /// Three clips, one from a different space.
    case outlier([ReverbSpace])
    /// Gold: pick a source.
    case chooseSource
    /// Gold: drag the source from close to far over four beats, with an echo at the end.
    case journey
    /// Gold: dry against your journey.
    case reveal
}

nonisolated struct ArchitectRound: Sendable {
    var title: String
    var body: String
    var mode: ArchitectMode
    var bpm: Double = 96
}

// MARK: - Mix Traffic Control (F4.4)

nonisolated enum TrafficMode: Sendable, Equatable {
    /// Solo each lane and name it.
    case solo
    /// One lane starts at this level. Raise or lower it into the pocket.
    case level(lane: Int, from: Double)
    /// One lane is too loud. Find it and fix only that one.
    case culprit(lane: Int)
    /// Make a melody-forward mix, then a drum-forward one.
    case priorities
    /// Gold: pick what to feature.
    case focus
    /// Gold: make the alternate mix.
    case alternate
    /// Gold: blind A/B.
    case blind
}

nonisolated struct TrafficRound: Sendable {
    var title: String
    var body: String
    var mode: TrafficMode
}

// MARK: - Sound Casting (F4.5)

nonisolated enum CastRole: Int, Sendable, CaseIterable { case drums, bass, chords, lead }

nonisolated enum CastMode: Sendable, Equatable {
    /// Hear each audition for one role.
    case audition(CastRole)
    /// Pick one sound for every role.
    case cast
    /// A busy, bright part fights the melody. Compare it with a simple one.
    case badFit
    /// Five parts for four roles. Mute the one that's in the way.
    case overcrowd
    /// Two different lineups from the same notes.
    case lineups
    /// Match a reference lineup.
    case matchRef([Int])
    /// Gold: choose a direction.
    case direction
    /// Gold: cast, then swap one for version B.
    case curate
    /// Gold: a four-bar reveal of your band.
    case showcase
}

nonisolated struct CastRound: Sendable {
    var title: String
    var body: String
    var mode: CastMode
}

// MARK: - Song sections (F5)

nonisolated struct SongSection: Sendable, Hashable {
    var name: String
    var pattern: Pattern
    var bars: Int = 2
    /// Which parts play, for the X-ray: drums, bass, chords, lead.
    var layers: [Bool] = [true, true, true, true]
}

// MARK: - Structure Detective (F5.1)

nonisolated enum DetectiveMode: Sendable, Equatable {
    /// Mark every section boundary.
    case mark
    /// Which layer changed at the boundary?
    case evidence
    /// A crash lands mid-section. Real change or not?
    case decoy(crashBar: Int, real: Bool)
    /// Put the sections in the order they played.
    case order
    /// Name each marked part: start, main, change or end.
    case label
}

nonisolated struct DetectiveRound: Sendable {
    var title: String
    var body: String
    var mode: DetectiveMode
    var song: [SongSection]
    var bpm: Double = 112
}

// MARK: - Energy Surfer (F5.2)

nonisolated enum SurferMode: Sendable, Equatable {
    /// Hear the flat loop, preview the sparse one.
    case flat
    /// Follow a visible ghost path, one level per bar.
    case follow([Int])
    /// Match a path you heard but can't see.
    case match([Int])
    /// The song stays full. Carve a rest before the return.
    case rest(bars: Int)
    /// Gold: pick a story for the arc.
    case narrative
    /// Gold: ride your own arc.
    case ride(bars: Int)
    /// Gold: hear your arc without the wave, against the flat loop.
    case replay
}

nonisolated struct SurferRound: Sendable {
    var title: String
    var body: String
    var mode: SurferMode
    var bpm: Double = 112
}

// MARK: - The Perfect Cut (F5.3)

nonisolated enum CutJoin: String, Sendable, CaseIterable { case hard = "Hard cut", pause = "Pause", fill = "Fill", echo = "Echo tail" }

nonisolated enum CutMode: Sendable, Equatable {
    /// The cut starts mid-beat. Drag it to a bar line.
    case align(start: Int)
    /// Add a beat of silence before the change.
    case pause
    /// Pick a fill that leads into the next section.
    case fill
    /// Mark by ear where the transition should start.
    case markByEar(bar: Int)
    /// Two fills, one lands late. Pick the one that matches the reference.
    case compare
    /// Pick the transition for a smooth or dramatic brief.
    case intention(dramatic: Bool)
    /// Gold: choose the two sections to join.
    case choose
    /// Gold: free edit.
    case direct
    /// Gold: before and after the join, against a hard cut.
    case render
}

nonisolated struct CutRound: Sendable {
    var title: String
    var body: String
    var mode: CutMode
    var bpm: Double = 108
}

// MARK: - Song Jigsaw (F5.4)

nonisolated enum JigsawMode: Sendable, Equatable {
    /// Flip every postcard.
    case preview
    /// Put the cards in this order.
    case assemble([Int], showNames: Bool)
    /// A draft repeats one card. Replace a repeat with this card.
    case duplicate(draft: [Int], fresh: Int)
    /// Play the assembled song through, the active card glowing.
    case playthrough([Int])
    /// Gold: your own order, any four or five cards with an opening and an ending.
    case story
    /// Gold: change one card and compare.
    case versionB
}

nonisolated struct JigsawRound: Sendable {
    var title: String
    var body: String
    var mode: JigsawMode
    var bpm: Double = 112
}

// MARK: - The Live Take (F5.5)

nonisolated enum LiveScene: Int, Sendable, CaseIterable { case intro, main, change, end }

nonisolated enum LiveMode: Sendable, Equatable {
    /// Audition the layers and pick a palette. With imports, your Gold creations are offered too.
    case load(imports: Bool)
    /// Cue points are highlighted.
    case guided
    /// Hear the whole take back and keep it.
    case playback
    /// Pick a fill and a pause or echo for the show.
    case transitions
    /// No cue labels: launch on the bar lines yourself.
    case cued
    /// Move the weakest scene launch to a better bar.
    case refine
    /// Gold: the full arc, your way.
    case free
    /// Gold: name the take and pick a favourite passage.
    case release
}

nonisolated struct LiveRound: Sendable {
    var title: String
    var body: String
    var mode: LiveMode
    var bars: Int = 12
    var bpm: Double = 112
}
