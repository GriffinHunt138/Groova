//
//  AcademyLevels.swift
//  Groova
//
//  Hand-written Silver and Gold levels for the shared academy lessons (genre identity, track
//  anatomy, finishing, mixing, pump, space and vocal chops). They're written once and filled in
//  with each genre's own loops, sections, mix and vocal, just like the Bronze lessons.
//

import Foundation

nonisolated enum AcademyLevels {
    static let styles = [AcademyKit.house, AcademyKit.deep, AcademyKit.techno, AcademyKit.techHouse, AcademyKit.garage]

    static let all: [String: LevelPair] = {
        var r: [String: LevelPair] = [:]
        for s in styles {
            r["\(s.id).acad.what"] = what(s)
            r["\(s.id).acad.anatomy"] = anatomy(s)
            r["\(s.id).acad.finish"] = finish(s)
            r["\(s.id).acad.mix"] = mix(s)
            r["\(s.id).acad.pump"] = pump(s)
            r["\(s.id).acad.space"] = space(s)
            if let v = s.vocal {
                r["\(s.id).acad.chops"] = chops(s, v)
                r["\(s.id).acad.chopRhythm"] = chopRhythm(s, v)
                r["\(s.id).acad.hook"] = hook(s, v)
            }
        }
        return r
    }()

    // MARK: Helpers

    static func lane(_ s: AcademyStyle, _ i: Instrument) -> Int? { s.lanes.firstIndex(of: i) }

    /// The grid with one cell switched.
    static func flip(_ g: [[Bool]], _ lane: Int?, _ col: Int) -> [[Bool]] {
        guard let lane, lane < g.count, col < g[lane].count else { return g }
        var g = g
        g[lane][col].toggle()
        return g
    }

    static func count(_ g: [[Bool]], _ col: Int) -> Int { g.filter { col < $0.count && $0[col] }.count }

    static func swap(_ a: [Double], _ i: Int, _ j: Int) -> [Double] {
        guard i < a.count, j < a.count else { return a }
        var a = a
        a.swapAt(i, j)
        return a
    }

    /// One chop nudged a step out of place.
    static func nudged(_ d: [Int: Int]) -> [Int: Int] {
        guard let k = d.keys.max(), let v = d[k] else { return d }
        var d = d
        d[k] = nil
        let to = (k + 1 < 16 && d[k + 1] == nil) ? k + 1 : k - 1
        d[to] = v
        return d
    }

    /// The first two chops trade places.
    static func traded(_ d: [Int: Int]) -> [Int: Int] { d.mapValues { $0 == 0 ? 1 : $0 == 1 ? 0 : $0 } }

    static func later(_ d: [Int: Int], _ n: Int) -> [Int: Int] {
        Dictionary(uniqueKeysWithValues: d.map { (($0.key + n) % 16, $0.value) })
    }

    static func retuned(_ d: [Int: Int], at key: Int?, _ count: Int) -> [Int: Int] {
        guard let key, let v = d[key], count > 1 else { return d }
        var d = d
        d[key] = (v + 1) % count
        return d
    }

    // MARK: What makes it

    static func what(_ s: AcademyStyle) -> LevelPair {
        let bpm = s.genre.bpm, sw = s.genre.swing, n = s.neighbours
        let feel = sw >= 0.25 ? 0 : sw > 0 ? 1 : 2
        let feelText = ["\(s.name) swings hard. The in-between 16ths land late, like a shuffle.",
                        "\(s.name) has a little swing, just enough to loosen the hats.",
                        "\(s.name) is straight. Every 16th lands right on the grid."][feel]
        let speeds = ["Too slow", "Just right", "Too fast"]
        let ids = AcademyKit.identify(s)
        return (
            silver: [
                L.silver("tempo and feel",
                         "Two genres can share a drum pattern and still feel nothing alike. Tempo and swing do a lot of the work. Train your ear on both, then lock the \(s.name) tempo with no numbers to help."),
                K.quiz("Is this the right tempo?", "The \(s.name) drums at three speeds.", [
                    K.hear([s.drums], speeds, 2, bars: 2, bpm: bpm + 14, swing: sw),
                    K.hear([s.drums], speeds, 1, bars: 2, bpm: bpm, swing: sw),
                    K.hear([s.drums], speeds, 0, bars: 2, bpm: bpm - 14, swing: sw),
                    K.ask("How much does \(s.name) swing?", ["Hard, like a shuffle", "Just a little", "Not at all"], feel, feelText),
                ]),
                K.tempoByEar("Lock the tempo by ear", "No numbers this time. Match your loop to the reference.", loop: s.drums,
                             target: bpm, start: bpm > 125 ? 116 : 134, swing: sw),
                K.drumMake("Make a \(s.name) beat", "Use what makes it \(s.name): the kick pattern, the hats and the feel. At least 2 kicks.",
                           tracks: s.tracks, edit: Set(s.tracks), goal: .atLeast(.kick, 2)),
            ],
            gold: [
                L.gold("tell the neighbours apart",
                       "\(s.name) sits close to \(n[0].name) and \(n[1].name). Producers borrow from each other all the time, so learn the exact details that keep them apart."),
                K.quiz("Which genre?", "Three loops, new order.", ids.count == 3 ? [ids[1], ids[2], ids[0]] : ids),
                K.quiz("Know the signature", "", [
                    K.ask("Which of these is a \(s.name) signature?", [n[0].traits[1], s.genre.traits[1], n[1].traits[1]], 1,
                          "\(n[0].traits[1]) points to \(n[0].name). \(n[1].traits[1]) points to \(n[1].name)."),
                    K.ask("What tempo does \(s.name) usually sit at?", ["\(Int(n[0].bpm)) BPM", "\(Int(n[1].bpm)) BPM", "\(Int(bpm)) BPM"], 2),
                ]),
                K.drumMake("Make it unmistakably \(s.name)", "Write a groove nobody could mistake for \(n[0].name). At least 2 kicks.",
                           tracks: s.tracks, edit: Set(s.tracks), goal: .atLeast(.kick, 2)),
            ])
    }

    // MARK: Anatomy

    static func anatomy(_ s: AcademyStyle) -> LevelPair {
        let kick = lane(s, .drum(.kick)), bass = lane(s, .bass)
        let sec = s.sections
        let a = s.anatomy
        let kickInLast = kick.map { a[$0][3] } ?? true
        // Kick and hats open, everything in section 2, no kick or bass in the break, all back at the end.
        let variant: [[Bool]] = s.lanes.enumerated().map { i, l in
            [l == .drum(.kick) || l == .drum(.hat), true, i != kick && i != bass, true]
        }
        return (
            silver: [
                L.silver("listen for what changes",
                         "Between two sections, usually only one or two parts come in or drop out. Catch exactly which, and you can map any track by ear."),
                K.quiz("Compare the sections", "", [
                    K.hear([AcademyKit.section(s, 0), AcademyKit.section(s, 1)], ["The first", "The second"],
                           count(a, 1) >= count(a, 0) ? 1 : 0, question: "Which section has more parts playing?"),
                    K.hear([AcademyKit.section(s, 2), AcademyKit.section(s, 3)], ["The first", "The second"], kickInLast ? 1 : 0,
                           question: "Which section has the kick?"),
                ]),
                K.arrange("Fix the map", "One part is playing where it shouldn't. Listen closely to the \(sec[2]).", .recreate,
                          sections: sec, lanes: s.lanes, loop: s.full, start: flip(a, kick, 2), target: a),
                K.arrange("Map your own track", "Build an arc where each section is different from the one before.", .create(.variedSections),
                          sections: sec, lanes: s.lanes, loop: s.full),
            ],
            gold: [
                L.gold("draw the energy curve",
                       "A track is an energy curve: low, rising, a dip, then the peak. Every part you add or remove lifts or drops it."),
                K.quiz("Place the section", "", [
                    K.hear([AcademyKit.section(s, 1)], sec, 1),
                    K.hear([AcademyKit.section(s, 0)], sec, 0),
                    K.ask("Why does the \(sec[2]) usually drop the kick?", ["So the kick's return feels huge", "To make the track shorter",
                                                                             "Because DJs need silence"], 0),
                ]),
                K.arrange("Recreate a different track",
                          "Kick and hats open it. Everything plays in the \(sec[1]). The \(sec[2]) loses the kick and bass, then it all comes back.",
                          .recreate, sections: sec, lanes: s.lanes, loop: s.full, target: variant),
                K.arrange("Make it yours", "Draw your own energy curve.", .create(.variedSections), sections: sec, lanes: s.lanes, loop: s.full),
            ])
    }

    // MARK: Finishing

    static func finish(_ s: AcademyStyle) -> LevelPair {
        let sec = s.sections
        let kick = lane(s, .drum(.kick)), bass = lane(s, .bass)
        let all = s.lanes.map { _ in sec.map { _ in true } }
        let breakOut = s.lanes.indices.map { i in sec.indices.map { c in !(c == 2 && (i == kick || i == bass)) } }
        let drums = Set(s.tracks)
        let opts = ["The kick", "The bass", "The hats"]
        return (
            silver: [
                L.silver("subtract, don't add",
                         "Most producers finish a loop by copying it across the whole track, then muting parts. Every section stays in time and in key, and it's quicker than building up from nothing."),
                K.quiz("What's missing?", "The full loop, with one part muted.", [
                    K.hear([s.full.keeping(drums.subtracting([.kick]), bass: true, chords: true)], opts, 0, bars: 2),
                    K.hear([s.full.keeping(drums, bass: false, chords: true)], opts, 1, bars: 2),
                    K.hear([s.full.keeping(drums.subtracting([.hat]), bass: true, chords: true)], opts, 2, bars: 2),
                ]),
                K.arrange("Strip the \(sec[2])", "Everything starts on. In the \(sec[2]), switch off the kick and the bass. Leave the rest.", .rule,
                          sections: sec, lanes: s.lanes, loop: s.full, start: all, target: breakOut),
                K.arrange("Subtract your own track", "Start full and mute your way to four different sections.", .create(.variedSections),
                          sections: sec, lanes: s.lanes, loop: s.full, start: all),
            ],
            gold: [
                L.gold("make the big moment land",
                       "The moment a part comes back is the biggest moment in a track. Plan what leaves before it, so its return hits."),
                K.quiz("Plan the moment", "", [
                    K.ask("You want the \(sec[3]) to hit harder. What's the simplest move?",
                          ["Take something out of the section before it", "Turn everything up", "Add more hats"], 0,
                          "Contrast does the work. A gap before a part makes it land."),
                    K.hear([AcademyKit.section(s, 2), AcademyKit.section(s, 3)], ["The first", "The second"], 1,
                           question: "Which one is the \(sec[3])?"),
                ]),
                K.arrange("Bring the bass home", "The bass never comes back in the \(sec[3]). Fix it so the ending lands.", .recreate,
                          sections: sec, lanes: s.lanes, loop: s.full, start: flip(s.anatomy, bass, 3), target: s.anatomy),
                K.arrange("Make it yours", "A full track with one big moment you planned for.", .create(.variedSections),
                          sections: sec, lanes: s.lanes, loop: s.full, start: all),
            ])
    }

    // MARK: Mixing

    static func mix(_ s: AcademyStyle) -> LevelPair {
        let m = s.mix
        let balanced = Dictionary(uniqueKeysWithValues: zip(m.channels, m.target))
        let loud = ["The bass is too loud", "The hats are too loud", "It's balanced"]
        let quiet = ["The kick", "The bass", "The hats"]
        return (
            silver: [
                L.silver("name the problem first",
                         "Before you touch a fader, name the problem. Is the bass swallowing the kick? Are the hats piercing? Naming it tells you which fader to move."),
                K.quiz("What's wrong?", "", [
                    K.faders(s.full, [.bass: 1.0, .drum(.kick): 0.45], loud, 0, "The sub is covering the kick."),
                    K.faders(s.full, [.drum(.hat): 1.0, .drum(.kick): 0.6], loud, 1, "Bright and tiring after a minute."),
                    K.faders(s.full, balanced, loud, 2),
                ]),
                K.mix("Pull it into shape", "Everything's pushed up too loud. Bring each part down until it sits around the kick.",
                      m.channels, start: m.channels.map { _ in 0.95 }, target: m.target, loop: s.full),
                K.lab("Shape it your way", "Start from the sound you matched, then push it towards your own taste.", m.lab,
                      start: m.labTarget, loop: m.labLoop),
            ],
            gold: [
                L.gold("hear what's missing",
                       "A part that's too quiet is harder to spot than one that's too loud. Train your ear for what's hiding, then rescue a messy mix."),
                K.quiz("What's too quiet?", "", [
                    K.faders(s.full, [.bass: 0.1], quiet, 1),
                    K.faders(s.full, [.drum(.kick): 0.15], quiet, 0, "Without the kick, the groove has no centre."),
                    K.faders(s.full, [.drum(.hat): 0.05], quiet, 2),
                ]),
                K.mix("Two faders swapped", "Two faders have traded places. Find them and put them back.", m.channels,
                      start: swap(m.target, 1, m.channels.count - 1), target: m.target, loop: s.full),
                K.lab("Match it from the other side", "The knobs start at the opposite extreme this time.", m.lab,
                      start: m.labTarget.map { 1 - $0 }, target: m.labTarget, loop: m.labLoop),
                K.mix("Make it yours", "Your mix, by ear. Check it at low volume before you finish.", m.channels,
                      start: m.channels.map { _ in K.u }, loop: s.full),
            ])
    }

    static func pump(_ s: AcademyStyle) -> LevelPair {
        let m = s.mix
        let amount = ["None", "Some", "Heavy"]
        return (
            silver: [
                L.silver("hear the pump",
                         "Sidechain ducks the bass and chords every time the kick hits. A little glues the mix together. A lot makes it breathe like a heartbeat."),
                K.quiz("How much pump?", "", [
                    K.faders(m.pumpLoop, [.sidechain: 0], amount, 0),
                    K.faders(m.pumpLoop, [.sidechain: 1.0], amount, 2, "Everything ducks hard on every kick."),
                    K.faders(m.pumpLoop, [.sidechain: m.pump], amount, 1),
                ]),
                K.mix("Pull the pump back", "It's pumping far too hard. Bring it down to match the reference.", [.bass, .chords, .sidechain],
                      start: [K.u, K.u, 1.0], target: [K.u, K.u, m.pump], loop: m.pumpLoop),
                K.mix("Set your own pump", "Decide how much this track breathes.", [.bass, .chords, .sidechain],
                      start: [K.u, K.u, 0], loop: m.pumpLoop),
            ],
            gold: [
                L.gold("pump and level together",
                       "Pump changes how loud the bass feels, so set them together. The kick stays in charge."),
                K.quiz("Quick check", "", [
                    K.ask("Why sidechain the bass to the kick?", ["So they don't fight over the low end", "To make the bass louder", "To add reverb"], 0),
                    K.ask("More pump makes the bass feel...", ["Quieter and bouncier", "Louder and steadier"], 0, "It's ducking out of the way more."),
                ]),
                K.mix("Kick, bass, chords and pump", "Four faders. Kick first, then bass and pump together, then the chords.",
                      [.drum(.kick), .bass, .chords, .sidechain], start: [K.u, 0.95, 0.2, 0], target: [K.u, 0.65, K.u, m.pump],
                      loop: m.pumpLoop),
                K.mix("Make it yours", "Set the kick, bass and pump for your own \(s.name) feel.", [.drum(.kick), .bass, .sidechain],
                      start: [K.u, K.u, 0], loop: m.pumpLoop),
            ])
    }

    static func space(_ s: AcademyStyle) -> LevelPair {
        let m = s.mix
        let wet = ["Dry", "A touch", "Drenched"]
        return (
            silver: [
                L.silver("dry or wet",
                         "Reverb is the room a sound lives in. Dry sounds feel close and punchy. Wet sounds feel far away and dreamy. Filters decide how bright that room is."),
                K.quiz("Hear the room", "", [
                    K.reverb(s.full, amount: 0, wet, 0),
                    K.reverb(s.full, amount: 0.85, wet, 2),
                    K.reverb(s.full, amount: 0.3, wet, 1),
                    K.filtered(s.full, cutoff: 400, ["Dark", "Open"], 0, "Only the lows get through."),
                    K.filtered(s.full, cutoff: 16000, ["Dark", "Open"], 1),
                ]),
                K.filterMatch("Match a darker filter", "Darker than the Bronze one. Cutoff first, then resonance.",
                              cutoff: max(400, m.cutoff * 0.5), resonance: m.resonance, s.full),
                K.filterSweep("Ride the filter", "Sweep from dark to open, like a build into the drop.", s.full),
            ],
            gold: [
                L.gold("polish the whole mix",
                       "Reverb, filter and levels all affect each other. Polish in order: tone first, then space, then one last balance."),
                K.quiz("Smooth or resonant?", "Same cutoff both times. Listen for a whistle at the edge.", [
                    K.filtered(s.full, cutoff: m.cutoff, resonance: 0, ["Smooth", "Resonant"], 0),
                    K.filtered(s.full, cutoff: m.cutoff, resonance: 0.85, ["Smooth", "Resonant"], 1),
                ]),
                K.filterMatch("Match the resonant filter", "Cutoff first, then turn up resonance until you hear the same whistle.",
                              cutoff: m.cutoff, resonance: min(0.85, m.resonance + 0.4), s.full),
                K.mix("Rescue the balance", "Two faders have traded places. Find them by ear.", m.channels,
                      start: swap(m.target, 0, m.channels.count - 1), target: m.target, loop: s.full),
                K.space("Make it yours", "Set the room for your \(s.name) mix.", s.full),
            ])
    }

    // MARK: Vocals

    static func chops(_ s: AcademyStyle, _ v: AcademyStyle.Vocal) -> LevelPair {
        let busy = v.rhythm.merging(v.rule) { a, _ in a }
        return (
            silver: [
                L.silver("on the kick or off it",
                         "A chop on the kick sounds solid. A chop just after it sounds playful. Mix the two and a couple of syllables become a groove."),
                K.quiz("Quick check", "", [
                    K.ask("What's a vocal chop?", ["A short slice of a vocal, played like an instrument", "A whole sung verse", "A drum sound"], 0),
                    K.ask("Each pad plays...", ["One sung slice on its own note", "A different singer", "A drum hit"], 0),
                ]),
                K.chops("Fix the chop", "One chop has slipped out of place. Listen and put it back.", .recreate, v.chops,
                        backing: v.backing, start: nudged(v.rhythm), target: v.rhythm, length: v.length, vox: v.vox),
                K.chops("Swap the vowels", "Same rhythm as Bronze, but the two chops have traded places.", .recreate, v.chops,
                        backing: v.backing, target: traded(v.rhythm), length: v.length, vox: v.vox),
                K.chops("Write a chop groove", "Some chops on the kick, some just after it. At least 4.", .create(.chordsAtLeast(4)), v.chops,
                        backing: v.backing, length: v.length, vox: v.vox),
            ],
            gold: [
                L.gold("a busier chop part",
                       "Layer two simple chop rhythms and you get a busy, talking vocal part. Keep the main hits and add new ones around them."),
                K.chops("Copy the busy part", "Both Bronze rhythms, played together.", .recreate, v.chops,
                        backing: v.backing, target: busy, length: v.length, vox: v.vox),
                K.chops("Fix the busy part", "One chop has drifted. Find it.", .recreate, v.chops,
                        backing: v.backing, start: nudged(busy), target: busy, length: v.length, vox: v.vox),
                K.chops("Make it yours", "A busy chop part. At least 6 chops.", .create(.chordsAtLeast(6)), v.chops,
                        backing: v.backing, length: v.length, vox: v.vox),
            ])
    }

    static func chopRhythm(_ s: AcademyStyle, _ v: AcademyStyle.Vocal) -> LevelPair {
        let len = max(1, v.length - 1)
        let call = v.rhythm2.filter { $0.key < 8 }
        let answer = Dictionary(uniqueKeysWithValues: call.map { ($0.key + 8, (($0.value + 1) % max(1, v.chops.count))) })
        let callAnswer = call.merging(answer) { a, _ in a }
        return (
            silver: [
                L.silver("lean back",
                         "Move every chop one step later and the vocal leans back behind the beat. Same chops, a whole new attitude."),
                K.chops("Lean it back", "The Bronze rhythm, with every chop one step later.", .recreate, v.chops,
                        backing: v.backing, target: later(v.rhythm2, 1), length: len, vox: v.vox),
                K.chops("Fix the rhythm", "One chop has slipped. Put it back where the Bronze rhythm had it.", .recreate, v.chops,
                        backing: v.backing, start: nudged(v.rhythm2), target: v.rhythm2, length: len, vox: v.vox),
                K.quiz("Quick check", "", [
                    K.ask("Why keep one or two chops in the same place every bar?", ["It gives the ear something to hold on to",
                                                                                     "It makes the vocal louder", "Chops can't move"], 0),
                ]),
                K.chops("Write a laid-back rhythm", "Mostly just after the beat. At least 4 chops.", .create(.chordsAtLeast(4)), v.chops,
                        backing: v.backing, length: len, vox: v.vox),
            ],
            gold: [
                L.gold("call and answer",
                       "Write a chop rhythm for the first half of the bar, then answer it in the second half: same rhythm, different chop."),
                K.chops("Copy the call and answer", "The first half calls. The second half answers with the same rhythm on a new chop.",
                        .recreate, v.chops, backing: v.backing, target: callAnswer, length: len, vox: v.vox),
                K.chops("Fix the answer", "One chop in the answer is out of place.", .recreate, v.chops,
                        backing: v.backing, start: nudged(callAnswer), target: callAnswer, length: len, vox: v.vox),
                K.chops("Make it yours", "Your own call and answer. At least 5 chops.", .create(.chordsAtLeast(5)), v.chops,
                        backing: v.backing, length: len, vox: v.vox),
            ])
    }

    static func hook(_ s: AcademyStyle, _ v: AcademyStyle.Vocal) -> LevelPair {
        let n = v.chops.count
        let answered = retuned(v.hook, at: v.hook.keys.max(), n)
        let wrong = retuned(v.hook, at: v.hook.keys.min(), n)
        let bigger = v.hook.merging(v.rhythm2.filter { r in v.hook[r.key] == nil && v.hook[r.key - 1] == nil }) { a, _ in a }
        return (
            silver: [
                L.silver("the answer chop",
                         "A hook feels finished when its last chop answers the rest. Change the final chop and the same hook asks a new question."),
                K.chops("Fix the hook", "One chop is on the wrong note. Listen and swap it.", .recreate, v.chops,
                        backing: v.backing, start: wrong, target: v.hook, length: v.length, vox: v.vox),
                K.chops("Copy the new ending", "The Bronze hook, but the last chop changes.", .recreate, v.chops,
                        backing: v.backing, target: answered, length: v.length, vox: v.vox),
                K.chops("Write a hook with an ending", "Repeat one chop, then end on a different one. At least 5 chops.", .create(.chordsAtLeast(5)),
                        v.chops, backing: v.backing, length: v.length, vox: v.vox),
            ],
            gold: [
                L.gold("hooks that build",
                       "Play a hook, then fill its gaps with extra chops. It feels bigger without changing the tune, which is perfect for a final chorus."),
                K.quiz("Quick check", "", [
                    K.ask("What makes a vocal hook stick?", ["A short pattern that repeats", "Using every chop once", "Being as long as possible"], 0),
                ]),
                K.chops("Copy the bigger hook", "The Bronze hook, with extra chops filling its gaps.", .recreate, v.chops,
                        backing: v.backing, target: bigger, length: v.length, vox: v.vox),
                K.chops("Make it yours", "Write a hook, then make it bigger. At least 6 chops.", .create(.chordsAtLeast(6)), v.chops,
                        backing: v.backing, length: v.length, vox: v.vox),
            ])
    }
}
