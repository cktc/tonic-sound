# Implementation Plan: Tonic MVP

**Branch**: `001-tonic-mvp` | **Date**: 2025-11-25 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-tonic-mvp/spec.md`

## Summary

Build the Tonic MVP, a sleep and focus sound app with apothecary theme. Core features include real-time noise generation (white/pink/brown), background audio playback with lock screen controls, personalization quiz, and tonic/botanical browsing. Uses Flutter with flutter_pcm_sound for audio generation and Provider for state management.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x (stable)
**Primary Dependencies**: flutter_pcm_sound, audio_service, audio_session, provider, hive
**Storage**: Hive (local NoSQL)
**Testing**: flutter_test (unit, widget, integration)
**Target Platform**: iOS 15+, Android 8.0+ (API 26+)
**Project Type**: Mobile (cross-platform Flutter)
**Performance Goals**: <2s app launch, 8+ hour continuous playback, <500ms lock screen response
**Constraints**: Offline-only, no backend, real-time PCM generation at 44100Hz
**Scale/Scope**: 5 screens (Counter, Dispensary, Onboarding x3, Settings), 6 entities

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Real-Time Audio Generation (NON-NEGOTIABLE) | PASS | Using flutter_pcm_sound for real-time PCM at 44100Hz, 16-bit, ~50ms buffers. No pre-recorded loops for tonics. |
| II. Brand Consistency | PASS | All naming uses apothecary metaphor (Dispense, Strength, Dosage, Counter, Dispensary). No technical terminology in UI. |
| III. Background Audio Reliability | PASS | Using audio_service for background playback + lock screen controls. iOS AVAudioSession and Android foreground service configured. |
| IV. User Safety First | PASS | Three-level safety indicator (safe/moderate/high). Warning displayed at high volume. Default strength in safe range (0.5). |
| V. Phased Delivery | PASS | MVP scope matches constitution exactly: 3 tonics, 3 botanicals, quiz, timer, strength control, dark mode, lock screen controls. |
| VI. Simplicity Over Abstraction | PASS | Provider (simplest state management), Hive (simple storage), feature-first architecture. No over-engineering. |

**Result**: All gates PASS. Proceeding with implementation.

## Project Structure

### Documentation (this feature)

```text
specs/001-tonic-mvp/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 research decisions
├── data-model.md        # Entity definitions
├── quickstart.md        # Setup guide
├── contracts/           # Service interfaces
│   └── service-contracts.md
├── checklists/          # Quality checklists
│   └── requirements.md
└── tasks.md             # Implementation tasks (Phase 2 - /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── audio/
│   │   ├── generators/
│   │   │   ├── noise_generator.dart        # Base interface
│   │   │   ├── white_noise_generator.dart  # Random values
│   │   │   ├── pink_noise_generator.dart   # IIR filtered
│   │   │   └── brown_noise_generator.dart  # Leaky integrator
│   │   └── services/
│   │       ├── audio_service_handler.dart  # audio_service integration
│   │       └── tonic_audio_service.dart    # High-level audio API
│   └── storage/
│       ├── storage_service.dart            # Hive wrapper
│       ├── models/
│       │   ├── user_preferences.dart       # @HiveType(0)
│       │   ├── quiz_response.dart          # @HiveType(1)
│       │   └── playback_session.dart       # @HiveType(2)
│       └── adapters/                       # Generated adapters
│
├── features/
│   ├── counter/
│   │   ├── counter_screen.dart             # Main playback screen
│   │   ├── widgets/
│   │   │   ├── tonic_bottle.dart           # Animated bottle
│   │   │   ├── strength_slider.dart        # Volume control
│   │   │   ├── dosage_selector.dart        # Timer picker
│   │   │   ├── safety_indicator.dart       # Volume warning
│   │   │   └── timer_display.dart          # Countdown
│   │   └── counter_provider.dart           # Screen state
│   │
│   ├── dispensary/
│   │   ├── dispensary_screen.dart          # Browse tonics/botanicals
│   │   ├── widgets/
│   │   │   ├── tonic_card.dart             # Tonic selection card
│   │   │   └── botanical_card.dart         # Botanical selection card
│   │   └── dispensary_provider.dart        # Screen state
│   │
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── welcome_screen.dart         # Onboarding slide 1
│   │   │   ├── differentiation_screen.dart # Onboarding slide 2
│   │   │   └── consultation_screen.dart    # Quiz intro
│   │   ├── quiz/
│   │   │   ├── quiz_screen.dart            # 5-question flow
│   │   │   ├── question_widget.dart        # Single question UI
│   │   │   └── prescription_card.dart      # Result display
│   │   ├── onboarding_provider.dart        # Flow state
│   │   └── prescription_service.dart       # Quiz logic
│   │
│   └── settings/
│       └── settings_screen.dart            # Lab Notes
│
├── shared/
│   ├── theme/
│   │   ├── tonic_theme.dart                # ThemeData
│   │   └── tonic_colors.dart               # Color constants
│   ├── widgets/
│   │   ├── tonic_button.dart               # Styled button
│   │   └── tonic_card.dart                 # Styled card
│   ├── constants/
│   │   ├── tonic_catalog.dart              # Static tonic/botanical defs
│   │   └── quiz_questions.dart             # Quiz content
│   └── navigation/
│       └── app_router.dart                 # Navigation setup
│
└── main.dart                               # Entry point

test/
├── unit/
│   ├── generators/
│   │   ├── white_noise_generator_test.dart
│   │   ├── pink_noise_generator_test.dart
│   │   └── brown_noise_generator_test.dart
│   └── services/
│       ├── prescription_service_test.dart
│       └── storage_service_test.dart
│
├── widget/
│   ├── counter/
│   │   ├── tonic_bottle_test.dart
│   │   ├── strength_slider_test.dart
│   │   └── safety_indicator_test.dart
│   └── onboarding/
│       └── quiz_screen_test.dart
│
└── integration/
    └── audio_playback_test.dart            # Manual device testing

assets/
├── audio/
│   └── botanicals/
│       ├── rain.mp3
│       ├── ocean.mp3
│       └── forest.mp3
│
└── images/
    ├── bottles/
    │   ├── bright.png
    │   ├── rest.png
    │   └── focus.png
    └── botanicals/
        ├── rain.png
        ├── ocean.png
        └── forest.png
```

**Structure Decision**: Feature-first mobile architecture per constitution. Core audio and storage services are isolated in `lib/core/`. Each feature is self-contained with its own screen, widgets, and provider. Shared components in `lib/shared/`.

## Complexity Tracking

> No violations. All constitution principles satisfied with chosen architecture.

| Principle | Implementation | Alignment |
|-----------|---------------|-----------|
| Real-Time Generation | flutter_pcm_sound with Dart noise algorithms | Direct implementation of constitution specs |
| Brand Consistency | Apothecary naming throughout UI | All copy reviewed against naming requirements |
| Background Audio | audio_service + platform config | Production-grade solution |
| User Safety | Three-level indicator, warnings, safe defaults | Meets all safety requirements |
| Phased Delivery | MVP scope only, no scope creep | Exact match to constitution MVP list |
| Simplicity | Provider + Hive, no over-engineering | Simplest tools for requirements |

## Coding Guidelines Integration

Per user requirements, implementation will follow:

**Principles**:
- **DRY**: Extract noise generation base class; reuse widgets across screens
- **KISS**: Provider over BLoC; Hive over Drift; no unnecessary abstractions
- **Fail Fast**: Throw exceptions on invalid parameters; loud logging; no silent fallbacks

**Guidelines**:
- Aggressive logging in audio service (state changes, errors, buffer underruns)
- Document intent in noise generator comments (algorithm source, coefficients rationale)
- Follow Flutter best practices (const constructors, keys for testing)
- Semantic test keys on all interactive widgets (TonicTestKeys class)
- Single-purpose functions (generate() only generates; no side effects)

## Phase Outputs

| Phase | Output | Status |
|-------|--------|--------|
| Phase 0 | research.md | Complete |
| Phase 1 | data-model.md | Complete |
| Phase 1 | contracts/service-contracts.md | Complete |
| Phase 1 | quickstart.md | Complete |
| Phase 1 | plan.md (this file) | Complete |
| Phase 2 | tasks.md | Pending (/speckit.tasks) |

## Next Steps

Run `/speckit.tasks` to generate implementation task list from this plan.

Implementation order:
1. **Setup** - Project structure, dependencies, platform config
2. **Foundational** - Storage service, audio engine, noise generators
3. **US1 (P1)** - Counter screen with basic playback
4. **US2 (P2)** - Strength/dosage controls with safety indicator
5. **US3 (P3)** - Onboarding quiz and prescription
6. **US4 (P4)** - Dispensary browser
7. **US5 (P5)** - Lock screen controls polish
8. **Polish** - Testing, assets, final UI refinements
