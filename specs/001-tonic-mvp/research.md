# Research: Tonic MVP Technical Decisions

**Feature Branch**: `001-tonic-mvp`
**Date**: 2025-11-25
**Status**: Complete

## Summary

This document captures research findings and technical decisions for the Tonic MVP implementation using Flutter.

---

## Decision 1: Real-Time Audio Library

### Decision
**flutter_pcm_sound + audio_service**

### Rationale
- `flutter_pcm_sound` is purpose-built for real-time PCM audio generation with event-based callbacks
- `audio_service` provides production-grade background audio, lock screen controls, and interruption handling
- Clean separation of concerns: PCM generation vs. system integration
- Minimal overhead compared to file-streaming libraries

### Alternatives Considered

| Library | PCM Generation | Background | Lock Screen | Verdict |
|---------|---------------|------------|-------------|---------|
| flutter_soloud | YES | Partial | NO | Designed for games; overkill |
| just_audio | NO | YES | YES | File streaming only, not real-time |
| audioplayers | NO | NO | NO | Requires audio_service anyway |
| flutter_pcm_sound | YES | Partial | NO | Needs audio_service complement |

### Implementation Notes
- `flutter_pcm_sound.setFeedCallback()` for PCM streaming at 44100 Hz, 16-bit
- `audio_service` AudioHandler wraps the PCM player for system integration
- iOS: Configure `iosAudioCategory: IosAudioCategory.playback`
- Android: Add `FOREGROUND_SERVICE_MEDIA_PLAYBACK` permission (SDK 34+)

---

## Decision 2: State Management

### Decision
**Provider** (with Riverpod as Phase 2 migration option)

### Rationale
- Simplest solution that meets MVP needs (KISS principle)
- Official Flutter team endorsement
- Minimal boilerplate (70-80% less than BLoC)
- Clean integration with audio_service isolate pattern
- Easy testing with provider isolation

### Alternatives Considered

| Approach | Learning Curve | Boilerplate | Audio Fit | KISS Alignment |
|----------|---------------|-------------|-----------|----------------|
| Provider | Very Easy | Minimal | Excellent | Perfect |
| Riverpod | Moderate | Very Minimal | Excellent | Good |
| BLoC/Cubit | Steep | High | Good | Poor |
| GetX | Easiest | Minimal | Risky | Risky |
| setState | Mixed | High | Poor | Poor |

### Implementation Notes
Three core providers:
1. `PlaybackProvider` - Audio state (playing, paused, current tonic, strength, timer)
2. `UserPreferencesProvider` - Persisted settings loaded from storage
3. `PrescriptionProvider` - Quiz responses and recommendation

---

## Decision 3: Local Storage

### Decision
**Hive** (NoSQL local database)

### Rationale
- Simple API matching KISS principle (get/put/delete/watch)
- Native support for structured data (quiz responses, preferences)
- Fast performance (800ms writes, 500ms reads - 16x faster than shared_preferences)
- No SQL or complex migrations required
- Built-in AES-256 encryption for user data privacy
- Active community maintenance

### Alternatives Considered

| Solution | Structured Data | Simplicity | Performance | Risk |
|----------|----------------|------------|-------------|------|
| shared_preferences | NO | Excellent | Slow | Stable |
| Hive | YES | Excellent | Fast | Stable |
| sqflite | YES | Poor | Moderate | Stable |
| Drift | YES | Good | Moderate | Stable |
| Isar | YES | Good | Fastest | Abandoned |

### Implementation Notes
Three Hive boxes:
1. `preferences` - UserPreferences (single record)
2. `quiz` - QuizResponse (latest response)
3. `playback` - PlaybackSession (last session for restore)

---

## Decision 4: Noise Generation Algorithms

### Decision
**Pure Dart implementation** per constitution requirements

### Rationale
Constitution Principle I mandates specific algorithms:
- White noise: Random values, normalized
- Pink noise: IIR filter with coefficients B=[0.049922035, -0.095993537, 0.050612699, -0.004408786], A=[1, -2.494956002, 2.017265875, -0.522189400]
- Brown noise: Leaky integrator with ~0.02 coefficient on white noise

### Implementation Notes
- Sample rate: 44100 Hz
- Buffer size: ~50ms chunks (2205 samples)
- Bit depth: 16-bit
- Implementation in `lib/core/audio/noise_generators/`

---

## Decision 5: Project Architecture

### Decision
**Feature-first structure** per constitution code organization

### Rationale
Constitution defines the structure:
```
lib/
├── core/           # Audio engine, noise generators
├── features/       # Feature modules (counter, dispensary, onboarding)
├── shared/         # Shared widgets, theme, constants
└── main.dart
```

This follows KISS by:
- Clear feature boundaries
- Minimal cross-dependencies
- Easy to navigate for new developers

---

## Decision 6: UI Framework

### Decision
**Standard Flutter widgets + custom theme**

### Rationale
- Constitution Principle VI: Prefer Flutter built-in solutions
- Dark mode apothecary theme implemented via `ThemeData`
- Custom bottle widgets for tonic visualization
- No external UI component library needed

### Implementation Notes
Color palette from constitution:
- Base: #1A1614 (Rich Brown-Black)
- Surfaces: #2C2420 (Dark Walnut)
- Accent: #C9A227 (Muted Gold)
- Text Primary: #EDE6D9 (Soft Cream)
- Text Secondary: #A69F92 (Dim Cream)

Typography:
- Headlines: Playfair Display (via google_fonts)
- Body/UI: Inter (via google_fonts)

---

## Decision 7: Testing Strategy

### Decision
**Unit + Widget + Manual device testing**

### Rationale
Per constitution testing strategy:
- Unit tests for noise generation algorithms (mathematical correctness)
- Widget tests for UI components
- Integration tests for audio session handling
- Manual testing on physical devices for audio quality and battery

### Implementation Notes
```
test/
├── unit/           # Noise algorithm tests
├── widget/         # UI component tests
└── integration/    # Audio session tests
```

---

## Decision 8: Nature Sound Assets (Botanicals)

### Decision
**Bundled audio assets** (not generated)

### Rationale
- Spec assumption: "Nature sounds (botanicals) are bundled audio assets, not generated algorithmically"
- High-quality nature recordings are more realistic than synthesized alternatives
- 3 assets for MVP: Rain, Ocean, Forest
- Assets stored in `assets/audio/botanicals/`

### Implementation Notes
- Format: MP3 or AAC for cross-platform compatibility
- Loop points edited for seamless playback
- File size optimization for app bundle (target <5MB total)

---

## Dependency Summary

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Audio
  flutter_pcm_sound: ^latest
  audio_service: ^0.18.x
  audio_session: ^0.1.x

  # State Management
  provider: ^6.x

  # Storage
  hive: ^2.x
  hive_flutter: ^1.x

  # UI
  google_fonts: ^6.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.x
  build_runner: ^2.x
  flutter_lints: ^latest
```

### Platform Configuration

**iOS (Info.plist)**
- `UIBackgroundModes`: audio
- Audio session category: playback

**Android (AndroidManifest.xml)**
- `FOREGROUND_SERVICE` permission
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK` permission (SDK 34+)
- Notification channel for playback controls

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| PCM library issues on specific devices | Test on multiple physical devices early |
| Background audio killed by OS | Follow platform best practices; test battery impact |
| Hive maintenance concerns | Monitor community; Drift migration path available |
| Audio quality issues | Profile and tune buffer sizes; test on headphones |

---

## References

- [flutter_pcm_sound GitHub](https://github.com/chipweinberger/flutter_pcm_sound)
- [audio_service documentation](https://pub.dev/packages/audio_service)
- [Hive documentation](https://docs.hivedb.dev/)
- [Provider documentation](https://pub.dev/packages/provider)
- [Flutter background audio guide](https://suragch.medium.com/background-audio-in-flutter-with-audio-service-and-just-audio-3cce17b4a7d)
