//
//  LevelNotes.swift
//  Groova
//
//  The opening card of Silver and Gold for every lesson whose levels are generated rather than
//  hand-written: what this level asks of you, in words written for that lesson.
//

import Foundation

nonisolated struct LevelNote: Sendable {
    let silverTitle: String
    let silver: String
    let goldTitle: String
    let gold: String
}

nonisolated enum LevelNotes {
    private static func n(_ st: String, _ s: String, _ gt: String, _ g: String) -> LevelNote {
        LevelNote(silverTitle: st, silver: s, goldTitle: gt, gold: g)
    }

    static func note(_ id: String, _ tier: LessonTier) -> (title: String, body: String)? {
        guard let note = all[id] else { return nil }
        switch tier {
        case .bronze: return nil
        case .silver: return (note.silverTitle, note.silver)
        case .gold: return (note.goldTitle, note.gold)
        }
    }

    static let all: [String: LevelNote] = core.merging(production) { a, _ in a }.merging(academy) { a, _ in a }

    // MARK: Core Foundations

    static let core: [String: LevelNote] = [
        "core.u1.l1": n("Pick out the layers",
                        "Same question, different sounds. Name each layer with nothing but your ears.",
                        "Layers in a new order",
                        "The loops come in a new order and your beat needs more kicks. Then make a beat that's all yours."),
        "core.u1.l2": n("Spot the change again",
                        "New sounds on the same changes. Listen for the exact bar where something enters or drops out.",
                        "A whole new arrangement",
                        "Three sections, a different track. Map which parts play where, then arrange your own."),
        "core.u1.l3": n("Tempo without numbers",
                        "No target on screen this time. Play the reference and match its speed by ear.",
                        "Within two BPM",
                        "Two new tempos to find by ear, and you have to land within 2 BPM. Tap along to get close fast."),
        "core.u1.l4": n("Count the bars",
                        "A new one-bar loop to copy by ear, then count how long each loop runs before it repeats.",
                        "Loops by ear",
                        "Rebuild a busier loop without the beat guide, then make your own one-bar loop."),
        "core.u1.l5": n("Use the tools by ear",
                        "Each tool asks for a bit more: more hats, more bass notes, and a knob setting to match by ear.",
                        "Every tool, harder",
                        "More notes, more hits, and a sound with extra knobs to match. Then make something with the lot."),
        "core.u2.l1": n("Count without the guide",
                        "The beat guide is off. Count 1, 2, 3, 4 in your head to find where the claps land.",
                        "Every beat, by ear",
                        "Claps on new beats with no guide, then write your own pattern that uses all four."),
        "core.u2.l2": n("Name the drum",
                        "Same five drums, new sounds. Name each one, then rebuild a groove with rims and claps by ear.",
                        "The whole kit",
                        "Every drum is yours to place. Rebuild the groove from scratch, then build your own kit pattern."),
        "core.u3.l1": n("Hear the subdivision",
                        "A new hat pattern to copy, and new sounds for the quarters, eighths and sixteenths quiz.",
                        "Split it yourself",
                        "Busier hats and kicks to rebuild by ear, then write a groove that mixes eighths and sixteenths."),
        "core.u3.l2": n("Off the beat, by ear",
                        "The offbeats move around. Listen for which hits land on the \"and\" and copy them.",
                        "Offbeats everywhere",
                        "Open hats, kicks and rims all play around the beat. Rebuild them, then write your own pull."),
        "core.u3.l3": n("A new skip",
                        "A different syncopated kick to copy by ear. Count which steps dodge the beat.",
                        "Syncopate it all",
                        "Kick, clap and hats all move off the grid. Rebuild it, then write a groove that surprises."),
        "core.u3.l4": n("More swing",
                        "Push the swing further this time, until the hats really lean.",
                        "Heavy swing",
                        "Go further still, garage territory. Hear the difference between a lilt and a full shuffle."),
        "core.u4.l1": n("Higher or lower, new keys",
                        "The same higher-or-lower question, moved to new notes. Trust the direction, not the note.",
                        "More notes, more keys",
                        "Twice as many rounds in new keys. Listen to the gap between the notes, not where they start."),
        "core.u4.l2": n("Octave or not?",
                        "The same question from new starting notes. An octave sounds like the same note, just higher.",
                        "Octaves everywhere",
                        "More rounds in more keys. Some gaps are close to an octave but not quite, so listen carefully."),
        "core.u4.l3": n("Bright or dark, new keys",
                        "Major and minor phrases from new roots. The mood stays the same wherever they start.",
                        "Mood in any key",
                        "More phrases in more keys. Name the mood quickly, before you start counting notes."),
        "core.u4.l5": n("Steps and leaps by ear",
                        "A new melody to copy without a guide, and the step-or-leap quiz in new keys.",
                        "Write with intervals",
                        "A longer melody to rebuild by ear, then write one of your own that uses at least one big leap."),
        "core.u5.l4": n("Moods in new keys",
                        "The same chord moods, built on new roots. Bright stays bright, moody stays moody.",
                        "Colour by ear",
                        "More chords from more roots, and a new chord to build without any starting notes."),
        "core.u6.l1": n("Hear the filter",
                        "Match the filter and envelope by ear, this time going the opposite way: bright and snappy.",
                        "Three knobs at once",
                        "Match a bass with an extra knob, then design a bass sound of your own."),
        "core.u6.l2": n("Name the wave",
                        "Find the wave shapes by ear, starting from the opposite end of the knob.",
                        "Wave and filter together",
                        "Match a sound with the wave, the filter and one more knob, then design your own tone."),
        "core.u7.l1": n("A new balance",
                        "The parts swap places. Listen for which one leads now and set the faders to match.",
                        "Balance the full loop",
                        "More channels and new targets. Set the kick first, then fit everything else around it."),
        "core.u7.l2": n("A different filter",
                        "Now keep the highs instead. Open the filter up until only the bright parts are left.",
                        "Match by ear",
                        "Match a new filter setting with cutoff and resonance, by ear alone."),
        "core.u7.l3": n("A different pump",
                        "A new amount of pump to match. Listen to how far the pad dips under each kick.",
                        "Pump the whole mix",
                        "More channels and a new pump setting. Get the balance right before you touch the pump."),
        "core.u7.l5": n("Clean or crunchy?",
                        "Match the opposite kick: less drive, a shorter tail. Hear how much drive changes the feel.",
                        "The whole kick",
                        "Pitch joins drive and length. Match it, then design a kick you'd use."),
        "core.u8.l2": n("Phrases in new places",
                        "The changes move to different bars. Count from 1 and catch each one.",
                        "Map the phrase",
                        "A different arrangement built in phrases. Recreate it, then arrange your own."),
        "core.u8.l3": n("Subtract by ear",
                        "No instructions this time. Hear what's been taken away in each section and recreate it.",
                        "Your own subtraction",
                        "A different track to recreate, then strip back a full loop into your own arrangement."),
        "core.u8.l4": n("Hear the curve",
                        "New pairs of loops, and a new energy curve to recreate by ear.",
                        "Shape it yourself",
                        "A different curve to map, then arrange one with a clear build, peak and dip."),
        "core.u8.l5": n("A new fill",
                        "A different fill to copy by ear, then a filter setting to match into the drop.",
                        "Fills and filters",
                        "Rebuild a busier fill with every drum, match a filter by ear, then write your own transition."),
    ]

    // MARK: Production units

    static let production: [String: LevelNote] = [
        "house.mel.l1": n("Directions in new keys",
                          "Up-or-down phrases moved to new notes, then a longer doodle in the scale.",
                          "Move freely",
                          "More phrases in more keys, then write a melody of at least seven notes that stays in the scale."),
        "house.mel.l2": n("A new motif",
                          "A different three-note idea to copy by ear. Catch it once and the repeat is free.",
                          "A longer motif",
                          "A longer motif with more notes to rebuild, then write one of your own."),
        "house.mel.l3": n("Twist by ear",
                          "New endings to judge in new keys, and a fresh twist to copy.",
                          "Your own twist",
                          "More endings to judge and a longer twist to copy, then twist a motif your way."),
        "house.mel.l4": n("A new answer",
                          "A different call to answer and a new call-and-response line to copy by ear.",
                          "The whole conversation",
                          "Longer calls with more notes to rebuild, then write both the question and the answer."),
        "house.mel.l5": n("Hooks that move",
                          "The hooks shift to new steps. Listen for which notes dodge the kick.",
                          "A hook of your own",
                          "Longer hooks to rebuild by ear, then write one with more notes between the kicks."),
        "deep.vl.l1": n("Inversions from new roots",
                        "Build inversions of new chords, and judge same-or-new from fresh keys.",
                        "Any chord, any order",
                        "More chords to invert with no starting notes, and more rounds in more keys."),
        "deep.vl.l2": n("Glide from new chords",
                        "New chord pairs to connect. Keep the shared notes still and move the rest as little as you can.",
                        "Glide by ear",
                        "More pairs from new roots, and a longer smooth-or-jumpy quiz."),
        "deep.vl.l3": n("Follow the top",
                        "Top notes in new keys. Listen to the highest voice only.",
                        "Voice it yourself",
                        "More rounds and a new chord to voice with a chosen top note."),
        "deep.vl.l4": n("A new glide",
                        "The progression changes order. Hear which chord comes first and rebuild it.",
                        "Your own late-night glide",
                        "A longer progression to recreate, then write a glide of your own with more chords."),
        "techno.riff.l1": n("A new rhythm",
                            "Same single note, different rhythm. Count where each hit lands.",
                            "Busier riffs",
                            "A riff with more hits to rebuild, then write a one-note riff that hooks."),
        "techno.riff.l2": n("Arps that move",
                            "A different arpeggio pattern to copy by ear. Listen for when it turns around.",
                            "Roll it yourself",
                            "A longer arp to rebuild, then write your own rolling pattern."),
        "techno.riff.l3": n("Dark notes in new keys",
                            "The dark-or-bright quiz in new keys, and a different riff with that half step.",
                            "All the tension",
                            "More rounds, a longer dark riff to rebuild, then write your own."),
        "techno.riff.l4": n("New gaps",
                            "The bass moves, so the gaps move. Find where the lead fits now.",
                            "Fill every gap",
                            "A busier lead to rebuild, then write a riff with more notes in the gaps."),
        "tech.key.l1": n("Another key",
                         "The same bassline, moved to a different key. Keep the shape, change the start.",
                         "Any key, by ear",
                         "A longer line to move and rebuild, then write one of your own."),
        "tech.key.l2": n("Up or down, new music",
                         "Key changes on new material. Listen for whether everything lifts or drops.",
                         "Bigger and smaller moves",
                         "More rounds, with some small key changes that are harder to hear."),
        "tech.key.l3": n("A new order",
                         "The moved progression changes order. Hear which chord comes first.",
                         "A whole new progression",
                         "A longer progression in the new key to rebuild, then write your own."),
        "tech.key.l4": n("Bass and chords, by ear",
                         "A different bass line to fit the chords in the new key.",
                         "Write in the key",
                         "A longer line to rebuild, then write a bass that agrees with every chord."),
        "ukg.talk.l1": n("New gaps",
                         "The bass rests in different places. Put the stabs where it leaves space.",
                         "Stabs by ear",
                         "A busier gap pattern to recreate, then write stabs of your own around the bass."),
        "ukg.talk.l2": n("Answer by ear",
                         "A different answer line to copy. Listen for the bass replying after each chord.",
                         "Longer answers",
                         "More notes to rebuild, then write a bass that answers every chord."),
        "ukg.talk.l3": n("Hit together again",
                         "The accents move. Find the steps where bass and stabs land together.",
                         "Unison by ear",
                         "More shared hits to find, then write a part that locks to the bass."),
        "ukg.talk.l4": n("A new conversation",
                         "Write the bass with more notes this time, then stabs that answer it.",
                         "Both parts, bigger",
                         "A longer bass to rebuild by ear, then write a full conversation of your own."),
        "house.a2.tops": n("New tops",
                           "A different hat, open hat and rim pattern to copy, with the beat guide off.",
                           "Every drum",
                           "All five drums are yours to rebuild by ear, then design tops with more hits."),
        "house.a2.swing": n("How much, by ear",
                            "New sounds on the swing quiz, and a shuffle that leans a little further.",
                            "Find the pocket",
                            "Heavier swing to dial in. Feel where it stops leaning and starts limping."),
    ]

    // MARK: Academies

    static let academy: [String: LevelNote] = {
        var out: [String: LevelNote] = [:]
        let genres: [(String, String, String)] = [
            ("house", "House", "the four-on-the-floor kick and offbeat hats"),
            ("deep", "Deep House", "the soft kick, rims and lazy swing"),
            ("techno", "Techno", "the relentless kick and rolling sixteenths"),
            ("tech", "Tech House", "the fat kick and rolling bass"),
            ("ukg", "UK Garage", "the skipping two-step kick and heavy swing"),
        ]
        for (id, name, sig) in genres {
            out["\(id).acad.what"] = n(
                "Spot \(name) by ear",
                "The genres come in a new order, and you'll find a new tempo by ear. Listen for \(sig).",
                "\(name) against the rest",
                "Another order and a tighter tempo to find. Name each genre before the loop comes round.")
            out["\(id).acad.anatomy"] = n(
                "A different \(name) track",
                "New sounds on the section quiz, and a different track to map by ear.",
                "Map it, then build it",
                "A different track to map with more changes, then arrange one the \(name) way.")
            out["\(id).acad.chops"] = n(
                "New chop rhythms",
                "The chops move to new steps. Listen for which vowel lands where.",
                "Chops by ear",
                "Busier chop patterns to rebuild, then place a vocal hook of your own.")
            out["\(id).acad.chopRhythm"] = n(
                "A new vocal rhythm",
                "A different pattern to copy, and more chops to place off the beat.",
                "Every chop counts",
                "A busier rhythm to rebuild, with more chops needed in your own pattern.")
            out["\(id).acad.hook"] = n(
                "A new hook",
                "Different chops in a different order. Get the rhythm, then the notes.",
                "A bigger hook",
                "A longer hook to rebuild, then write one with more hits and more notes.")
            out["\(id).acad.finish"] = n(
                "Subtract by ear",
                "No instructions: hear what's missing in each section and recreate it.",
                "Your own \(name) track",
                "A different arrangement to rebuild, then strip back the full loop your way.")
            out["\(id).acad.mix"] = n(
                "A new \(name) balance",
                "The parts swap levels, and the sound goes the opposite way. Match both by ear.",
                "Mix the whole loop",
                "More channels and an extra knob, all by ear. Then mix it your way.")
            out["\(id).acad.pump"] = n(
                "A different pump",
                "New pump amounts to match. Listen to how hard the bass dips under the kick.",
                "Pump the full mix",
                "More channels to balance around the pump, then set your own.")
            out["\(id).acad.space"] = n(
                "A different filter",
                "Match the opposite filter, then a new balance with every part.",
                "Polish by ear",
                "A new filter and a new balance with more channels. Then make the final mix yours.")
        }
        return out
    }()
}
