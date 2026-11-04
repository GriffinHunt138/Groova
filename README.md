# Groova — SwiftUI MVP

Duolingo-style lessons for electronic music production. Every sound is synthesized live on the device.

## Build & run

1. Open `Groova/Groova.xcodeproj` in Xcode.
2. Pick an iPhone simulator (or your iPhone) and press **⌘R**.
3. Turn the sound up. On a real iPhone the app plays even with the silent switch on.

The project uses folder-synced groups, so every file in `Groova/Groova/` is already part of the app target. No need to add files by hand.

If the audio crackles in a Debug build on an older device, switch the scheme to Release (Product ▸ Scheme ▸ Edit Scheme ▸ Run ▸ Build Configuration). Debug Swift is much slower at real-time DSP.

Run the scoring tests with **⌘U**.

## What's in it

- **Onboarding**: pick from five genres and hear each one's signature groove first.
- **Home**: level, daily XP goal, streak, and a winding learning path with mastery gates.
- **House Unit 1** (fully playable): four-on-the-floor kicks, claps on 2 and 4, offbeat hats, a syncopated bassline in the piano roll, a filter sweep with sound matching, and reverb.
- **Mastery challenge**: rebuild a groove (kick, clap, hats and bass) by ear, with solo/mute, a per-instrument accuracy breakdown, hints, and an 80% pass mark that unlocks Unit 2.
- **Techno** and **UK Garage**: one playable lesson each, with their own kits, tempos and swing.
- **Deep House** and **Tech House**: an honest "in the studio" preview with a playable demo groove.
- **Profile**: XP for each genre, skill levels, achievements, and a reset button.

## Code map

| Folder | What it does |
|---|---|
| `Audio/DSP.swift` | Synth voices (kick, clap, hats, rim, subtractive synth), sample-accurate 16-step sequencer with swing, resonant master low-pass |
| `Audio/AudioEngine.swift` | AVAudioEngine graph (source → reverb → mixer), audio session, interruptions, spectrum analyser |
| `Audio/Transport.swift` | Main-actor playback state and playhead; haptics |
| `Model/Music.swift` | Patterns, notes, and deterministic scoring for rhythm, melody and filter matching |
| `Model/Curriculum.swift` | All lesson content as data. Add lessons here |
| `Model/AppState.swift` | XP, levels, streaks and achievements, saved to UserDefaults |
| `Views/Lesson/*` | Lesson player and one view per step type |
| `Views/Instruments/*` | Step sequencer, keyboard, piano roll |
| `Design/*` | Colors, type and tactile components |

## How grading works

- **Rhythm**: every step is compared with the reference. Steps that hold a hit count 3× as much as empty steps, so the notes themselves matter most.
- **Melody**: each reference note looks for a note that starts on the same step. Timing is worth 40%, pitch 45% (the right note in the wrong octave earns about half), and length 15%. Each extra note takes off half a note.
- **Sound matching**: compares the knob positions with the reference settings (cutoff distance in octaves, plus resonance). It's parameter-based, and the app says so.
- **Rule steps** ("kick on every beat") need 100%. **Listen-and-recreate** steps and the mastery challenge need 80%. **Creative** steps pass once you've made something.
