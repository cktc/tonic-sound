# Tasks: Tonic MVP - Sleep & Focus Sound App

**Input**: Design documents from `/specs/001-tonic-mvp/`
**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/, research.md, quickstart.md

**Tests**: Tests are NOT explicitly requested in the specification. Test tasks are NOT included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile Flutter**: `lib/` at repository root
- Paths follow plan.md structure

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create Flutter project structure per plan.md at repository root
- [ ] T002 Update pubspec.yaml with dependencies: flutter_pcm_sound, audio_service, audio_session, provider, hive, hive_flutter, google_fonts
- [ ] T003 [P] Configure iOS platform in ios/Runner/Info.plist (background audio, audio session)
- [ ] T004 [P] Configure Android platform in android/app/src/main/AndroidManifest.xml (foreground service, permissions)
- [ ] T005 [P] Update android/app/build.gradle (compileSdkVersion 34, minSdkVersion 21)
- [ ] T006 [P] Create directory structure: lib/core/, lib/features/, lib/shared/, test/, assets/
- [ ] T007 [P] Create assets directories: assets/audio/botanicals/, assets/images/bottles/, assets/images/botanicals/

**Checkpoint**: Project initialized with all dependencies and platform configuration

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

### Theme & Constants

- [ ] T008 [P] Create TonicColors class with dark mode palette in lib/shared/theme/tonic_colors.dart
- [ ] T009 [P] Create TonicTheme with ThemeData in lib/shared/theme/tonic_theme.dart
- [ ] T010 [P] Create TonicTestKeys semantic keys for E2E testing in lib/shared/constants/test_keys.dart

### Static Catalog

- [ ] T011 [P] Create NoiseType, SoundType, PlaybackStatus, SafetyLevel enums in lib/shared/constants/enums.dart
- [ ] T012 [P] Create Tonic model class with static definitions in lib/shared/constants/tonic_catalog.dart
- [ ] T013 [P] Create Botanical model class with static definitions in lib/shared/constants/tonic_catalog.dart

### Storage Models (Hive)

- [ ] T014 [P] Create UserPreferences model with @HiveType(0) in lib/core/storage/models/user_preferences.dart
- [ ] T015 [P] Create QuizResponse model with @HiveType(1) in lib/core/storage/models/quiz_response.dart
- [ ] T016 [P] Create PlaybackSession model with @HiveType(2) in lib/core/storage/models/playback_session.dart
- [ ] T017 Run build_runner to generate Hive adapters: flutter pub run build_runner build

### Storage Service

- [ ] T018 Create StorageService interface and implementation in lib/core/storage/storage_service.dart

### Noise Generators

- [ ] T019 [P] Create NoiseGenerator abstract interface in lib/core/audio/generators/noise_generator.dart
- [ ] T020 [P] Create WhiteNoiseGenerator (random values) in lib/core/audio/generators/white_noise_generator.dart
- [ ] T021 [P] Create PinkNoiseGenerator (IIR filter) in lib/core/audio/generators/pink_noise_generator.dart
- [ ] T022 [P] Create BrownNoiseGenerator (leaky integrator) in lib/core/audio/generators/brown_noise_generator.dart

### Audio Service Core

- [ ] T023 Create PlaybackState class in lib/core/audio/services/playback_state.dart
- [ ] T024 Create AudioService interface in lib/core/audio/services/audio_service.dart
- [ ] T025 Create TonicAudioHandler extending AudioHandler (audio_service) in lib/core/audio/services/audio_service_handler.dart
- [ ] T026 Create TonicAudioService implementation in lib/core/audio/services/tonic_audio_service.dart

### Providers

- [ ] T027 [P] Create PlaybackProvider in lib/features/counter/counter_provider.dart
- [ ] T028 [P] Create PreferencesProvider in lib/shared/providers/preferences_provider.dart

### Main Entry Point

- [ ] T029 Create main.dart with Hive init, audio_service init, provider setup in lib/main.dart

**Checkpoint**: Foundation ready - user story implementation can begin

---

## Phase 3: User Story 1 - Play a Sound Tonic for Sleep (Priority: P1)

**Goal**: User can open app, see tonic on Counter screen, tap to play, sound continues when device locked

**Independent Test**: Open app → tap bottle → lock device → verify sound plays for full duration

### Implementation for User Story 1

- [ ] T030 [P] [US1] Create TonicBottle widget (tap to dispense) in lib/features/counter/widgets/tonic_bottle.dart
- [ ] T031 [P] [US1] Create basic TimerDisplay widget (shows remaining time) in lib/features/counter/widgets/timer_display.dart
- [ ] T032 [US1] Create CounterScreen with bottle and timer in lib/features/counter/counter_screen.dart
- [ ] T033 [US1] Integrate CounterScreen as home in lib/main.dart
- [ ] T034 [US1] Wire PlaybackProvider to TonicBottle tap action
- [ ] T035 [US1] Implement dispense/cap actions in PlaybackProvider calling AudioService
- [ ] T036 [US1] Test background playback on physical device (manual)

**Checkpoint**: User Story 1 complete - app plays tonic sound and continues in background

---

## Phase 4: User Story 2 - Adjust Strength and Dosage (Priority: P2)

**Goal**: User can adjust volume slider with safety indicator, set timer duration with fade-out

**Independent Test**: Adjust slider → verify indicator color changes → set 30min timer → verify fade-out

### Implementation for User Story 2

- [ ] T037 [P] [US2] Create StrengthSlider widget with volume control in lib/features/counter/widgets/strength_slider.dart
- [ ] T038 [P] [US2] Create SafetyIndicator widget (green/amber/red) in lib/features/counter/widgets/safety_indicator.dart
- [ ] T039 [P] [US2] Create DosageSelector widget (preset options) in lib/features/counter/widgets/dosage_selector.dart
- [ ] T040 [US2] Add getSafetyLevel() logic to AudioService in lib/core/audio/services/tonic_audio_service.dart
- [ ] T041 [US2] Implement fade-out logic in AudioService (last 5 minutes) in lib/core/audio/services/tonic_audio_service.dart
- [ ] T042 [US2] Integrate StrengthSlider, SafetyIndicator, DosageSelector into CounterScreen
- [ ] T043 [US2] Add setStrength() to PlaybackProvider for real-time volume updates
- [ ] T044 [US2] Add warning dialog when safety level is high in lib/features/counter/counter_screen.dart

**Checkpoint**: User Story 2 complete - strength and dosage controls work with safety warnings

---

## Phase 5: User Story 3 - Complete Personalization Consultation (Priority: P3)

**Goal**: First-time user sees onboarding, completes 5-question quiz, receives prescription

**Independent Test**: Fresh install → see onboarding → answer 5 questions → see prescription card

### Implementation for User Story 3

- [ ] T045 [P] [US3] Create quiz questions content in lib/shared/constants/quiz_questions.dart
- [ ] T046 [P] [US3] Create Prescription model class in lib/features/onboarding/prescription_service.dart
- [ ] T047 [US3] Create PrescriptionService with recommendation logic in lib/features/onboarding/prescription_service.dart
- [ ] T048 [P] [US3] Create WelcomeScreen (onboarding slide 1) in lib/features/onboarding/screens/welcome_screen.dart
- [ ] T049 [P] [US3] Create DifferentiationScreen (onboarding slide 2) in lib/features/onboarding/screens/differentiation_screen.dart
- [ ] T050 [P] [US3] Create ConsultationScreen (quiz intro) in lib/features/onboarding/screens/consultation_screen.dart
- [ ] T051 [P] [US3] Create QuestionWidget (single question UI) in lib/features/onboarding/quiz/question_widget.dart
- [ ] T052 [US3] Create QuizScreen (5-question flow) in lib/features/onboarding/quiz/quiz_screen.dart
- [ ] T053 [US3] Create PrescriptionCard widget in lib/features/onboarding/quiz/prescription_card.dart
- [ ] T054 [US3] Create OnboardingProvider for flow state in lib/features/onboarding/onboarding_provider.dart
- [ ] T055 [US3] Create PrescriptionProvider for quiz/prescription state in lib/shared/providers/prescription_provider.dart
- [ ] T056 [US3] Add onboarding routing logic to main.dart (check onboardingComplete)
- [ ] T057 [US3] Implement skip quiz functionality (proceed with defaults)

**Checkpoint**: User Story 3 complete - onboarding and quiz flow works, prescription generated

---

## Phase 6: User Story 4 - Browse and Select Different Tonics (Priority: P4)

**Goal**: User navigates to Dispensary, sees all tonics/botanicals, selects one to use on Counter

**Independent Test**: Navigate to Dispensary → see 3 tonics + 3 botanicals → tap one → return to Counter with selection

### Implementation for User Story 4

- [ ] T058 [P] [US4] Create TonicCard widget for tonic selection in lib/features/dispensary/widgets/tonic_card.dart
- [ ] T059 [P] [US4] Create BotanicalCard widget for botanical selection in lib/features/dispensary/widgets/botanical_card.dart
- [ ] T060 [US4] Create DispensaryProvider for screen state in lib/features/dispensary/dispensary_provider.dart
- [ ] T061 [US4] Create DispensaryScreen with tonic/botanical grids in lib/features/dispensary/dispensary_screen.dart
- [ ] T062 [US4] Add bottom navigation (Counter, Dispensary) in lib/shared/navigation/app_router.dart
- [ ] T063 [US4] Wire selection to update lastSelectedTonic in PreferencesProvider
- [ ] T064 [US4] Implement botanical playback (audio asset) in AudioService
- [ ] T065 [US4] Add botanical audio assets (rain.mp3, ocean.mp3, forest.mp3) to assets/audio/botanicals/

**Checkpoint**: User Story 4 complete - Dispensary browsing and selection works

---

## Phase 7: User Story 5 - Control Playback from Lock Screen (Priority: P5)

**Goal**: When device is locked during playback, user sees and can use media controls

**Independent Test**: Start playback → lock device → verify lock screen controls → tap pause → verify audio pauses

### Implementation for User Story 5

- [ ] T066 [US5] Configure mediaControls in TonicAudioHandler in lib/core/audio/services/audio_service_handler.dart
- [ ] T067 [US5] Implement play/pause/stop callbacks in TonicAudioHandler
- [ ] T068 [US5] Add notification channel configuration for Android in lib/main.dart
- [ ] T069 [US5] Test lock screen controls on iOS (Control Center)
- [ ] T070 [US5] Test lock screen controls on Android (notification + lock screen)
- [ ] T071 [US5] Implement audio interruption handling (phone calls, alarms) in TonicAudioHandler

**Checkpoint**: User Story 5 complete - lock screen controls fully functional

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements that affect multiple user stories

- [ ] T072 [P] Create Settings screen (Lab Notes) in lib/features/settings/settings_screen.dart
- [ ] T073 [P] Add Settings to navigation
- [ ] T074 [P] Add placeholder bottle images to assets/images/bottles/ (bright.png, rest.png, focus.png)
- [ ] T075 [P] Add placeholder botanical images to assets/images/botanicals/ (rain.png, ocean.png, forest.png)
- [ ] T076 Code cleanup: ensure all widgets have semantic test keys
- [ ] T077 Code cleanup: ensure aggressive logging in audio services
- [ ] T078 Run full app flow test on physical iOS device
- [ ] T079 Run full app flow test on physical Android device
- [ ] T080 Verify 8-hour continuous playback with device locked (overnight test)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US1 → US2 → US3 → US4 → US5 (sequential in priority order)
  - US2 extends US1 counter screen
  - US3 is independent (onboarding flow)
  - US4 adds new screen, depends on basic playback from US1
  - US5 extends audio_service from US1
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - Core playback
- **User Story 2 (P2)**: Depends on US1 (extends Counter screen with controls)
- **User Story 3 (P3)**: Can start after Foundational - Independent onboarding flow
- **User Story 4 (P4)**: Depends on US1 (needs basic playback to test selection)
- **User Story 5 (P5)**: Depends on US1 (extends audio_service)

### Within Each User Story

- Models before services
- Services before providers
- Providers before UI
- Core implementation before integration

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Within each story, tasks marked [P] can run in parallel
- US3 (onboarding) can potentially be developed in parallel with US2 after US1 completes

---

## Parallel Example: Foundational Phase

```bash
# Launch all theme/constants tasks together:
Task: "Create TonicColors class in lib/shared/theme/tonic_colors.dart"
Task: "Create TonicTheme in lib/shared/theme/tonic_theme.dart"
Task: "Create TonicTestKeys in lib/shared/constants/test_keys.dart"
Task: "Create enums in lib/shared/constants/enums.dart"
Task: "Create Tonic model in lib/shared/constants/tonic_catalog.dart"
Task: "Create Botanical model in lib/shared/constants/tonic_catalog.dart"

# Launch all Hive models together:
Task: "Create UserPreferences model in lib/core/storage/models/user_preferences.dart"
Task: "Create QuizResponse model in lib/core/storage/models/quiz_response.dart"
Task: "Create PlaybackSession model in lib/core/storage/models/playback_session.dart"

# Launch all noise generators together:
Task: "Create NoiseGenerator interface in lib/core/audio/generators/noise_generator.dart"
Task: "Create WhiteNoiseGenerator in lib/core/audio/generators/white_noise_generator.dart"
Task: "Create PinkNoiseGenerator in lib/core/audio/generators/pink_noise_generator.dart"
Task: "Create BrownNoiseGenerator in lib/core/audio/generators/brown_noise_generator.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: App plays sound and continues in background
5. Deploy/demo if ready - this is a working MVP!

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add User Story 1 → Test → Core playback works (MVP)
3. Add User Story 2 → Test → Controls and safety work
4. Add User Story 3 → Test → Onboarding and personalization work
5. Add User Story 4 → Test → Browsing and selection work
6. Add User Story 5 → Test → Lock screen controls work
7. Polish → Full MVP complete

---

## Task Summary

| Phase | Tasks | Parallel |
|-------|-------|----------|
| Setup | 7 | 5 |
| Foundational | 22 | 17 |
| US1 (P1) | 7 | 2 |
| US2 (P2) | 8 | 3 |
| US3 (P3) | 13 | 7 |
| US4 (P4) | 8 | 2 |
| US5 (P5) | 6 | 0 |
| Polish | 9 | 4 |
| **Total** | **80** | **40** |

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
