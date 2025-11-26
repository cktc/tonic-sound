# Data Model: Tonic MVP

**Feature Branch**: `001-tonic-mvp`
**Date**: 2025-11-25
**Storage**: Hive (local NoSQL)

---

## Entity Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          DATA MODEL                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────┐     ┌──────────────────┐                      │
│  │      Tonic       │     │    Botanical     │                      │
│  │  (Static Data)   │     │  (Static Data)   │                      │
│  └────────┬─────────┘     └────────┬─────────┘                      │
│           │                        │                                 │
│           └──────────┬─────────────┘                                │
│                      │                                               │
│                      ▼                                               │
│           ┌──────────────────┐                                      │
│           │  PlaybackSession │◄────────┐                            │
│           │   (Runtime)      │         │                            │
│           └──────────────────┘         │                            │
│                      │                 │                            │
│                      ▼                 │                            │
│           ┌──────────────────┐         │                            │
│           │ UserPreferences  │─────────┘                            │
│           │   (Persisted)    │                                      │
│           └────────┬─────────┘                                      │
│                    │                                                 │
│                    │ references                                      │
│                    ▼                                                 │
│           ┌──────────────────┐                                      │
│           │  QuizResponse    │───────┐                              │
│           │   (Persisted)    │       │                              │
│           └──────────────────┘       │                              │
│                                      ▼                              │
│                            ┌──────────────────┐                     │
│                            │  Prescription    │                     │
│                            │   (Computed)     │                     │
│                            └──────────────────┘                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Entities

### Tonic

**Description**: A generated noise type representing one of the three core sound formulas.

**Type**: Static/Immutable (defined in code, not stored in database)

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| id | String | Unique identifier | `bright`, `rest`, `focus` |
| name | String | Display name (apothecary style) | Non-empty |
| type | NoiseType | Algorithm type | Enum: white, pink, brown |
| description | String | User-facing description | Non-empty |
| bottleColor | Color | Visual representation color | Valid hex |
| iconAsset | String | Path to bottle icon asset | Valid asset path |

**Validation Rules**:
- ID must be unique and lowercase
- Name must follow apothecary naming convention (no technical terms)

**Predefined Values**:
```
Bright Tonic: id=bright, type=white, color=#F5F0E6
Rest Tonic:   id=rest, type=pink, color=#D4899A
Focus Tonic:  id=focus, type=brown, color=#8B6914
```

---

### Botanical

**Description**: A nature sound that can be layered with tonics.

**Type**: Static/Immutable (defined in code, not stored in database)

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| id | String | Unique identifier | `rain`, `ocean`, `forest` |
| name | String | Display name (apothecary style) | Non-empty |
| description | String | User-facing description | Non-empty |
| assetPath | String | Path to audio asset file | Valid asset path |
| iconAsset | String | Path to bottle icon asset | Valid asset path |

**Validation Rules**:
- ID must be unique and lowercase
- Asset file must exist and be playable

**Predefined Values (MVP)**:
```
Rainfall Extract:   id=rain, asset=assets/audio/botanicals/rain.mp3
Sea Salt Tincture:  id=ocean, asset=assets/audio/botanicals/ocean.mp3
Woodland Blend:     id=forest, asset=assets/audio/botanicals/forest.mp3
```

---

### PlaybackSession

**Description**: Current or last playback state, used for UI display and session restore.

**Type**: Persisted (Hive box: `playback`)

**Hive Type ID**: 2

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| soundId | String | ID of active tonic or botanical | Valid tonic/botanical ID |
| soundType | SoundType | Whether tonic or botanical | Enum: tonic, botanical |
| strengthLevel | double | Volume/strength 0.0-1.0 | 0.0 <= x <= 1.0 |
| dosageMinutes | int | Timer duration in minutes | -1 (continuous), 30, 60, 120, 240, 480 |
| startTime | DateTime | When playback started | Non-null when playing |
| status | PlaybackStatus | Current state | Enum: playing, paused, stopped |
| pausedAt | DateTime? | When paused (for resume calculation) | Null if not paused |
| remainingSeconds | int? | Cached remaining time on pause | For accurate resume |

**Validation Rules**:
- strengthLevel must be within [0.0, 1.0]
- dosageMinutes must be -1 or one of preset values
- startTime required when status is playing
- pausedAt required when status is paused

**State Transitions**:
```
stopped ──dispense()──▶ playing
playing ──cap()──▶ stopped
playing ──pause()──▶ paused
paused ──resume()──▶ playing
paused ──cap()──▶ stopped
playing ──timerExpired()──▶ stopped (with fadeout)
```

---

### UserPreferences

**Description**: Persisted user settings restored on app launch.

**Type**: Persisted (Hive box: `preferences`, key: `current`)

**Hive Type ID**: 0

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| lastSelectedTonic | String | Most recently selected tonic ID | Valid tonic ID |
| defaultStrength | double | Default strength setting | 0.0 <= x <= 1.0, default 0.5 |
| defaultDosageMinutes | int | Default timer setting | -1, 30, 60, 120, 240, 480, default 120 |
| quizCompleted | bool | Whether consultation was completed | Default false |
| onboardingComplete | bool | Whether onboarding flow finished | Default false |
| createdAt | DateTime | First app launch timestamp | Auto-set |
| updatedAt | DateTime | Last preference change | Auto-updated |

**Validation Rules**:
- defaultStrength must start in safe range (<=0.6)
- defaultDosageMinutes must be valid preset value
- lastSelectedTonic must exist in Tonic definitions

**Default Values**:
```
lastSelectedTonic: 'rest' (most common use case: sleep)
defaultStrength: 0.5 (safe range)
defaultDosageMinutes: 120 (2 hours - typical sleep onset time)
quizCompleted: false
onboardingComplete: false
```

---

### QuizResponse

**Description**: User's answers to the 5 consultation questions.

**Type**: Persisted (Hive box: `quiz`, key: `latest`)

**Hive Type ID**: 1

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| answers | List<int> | Answer indices for each question | Length == 5, each 0-3 |
| completedAt | DateTime | When quiz was finished | Non-null |

**Question Mapping**:
```
Q1: "What brings you to the apothecary today?"
    0: I need better sleep
    1: I need help focusing
    2: Both, please

Q2: "How noisy is your environment?"
    0: Quiet — I can hear a pin drop
    1: Moderate — Some background noise
    2: Noisy — City sounds, snoring partner, chaos

Q3: "Do any of these sound familiar?" (multi-select encoded as bitmask)
    Bit 0: Racing thoughts at bedtime
    Bit 1: Difficulty concentrating
    Bit 2: ADHD (diagnosed or suspected)
    Bit 3: Sensitivity to certain sounds
    Bit 4: None of these

Q4: "What's your age range?"
    0: Under 30
    1: 30-50
    2: 50-65
    3: 65+

Q5: "Have you tried sound for sleep or focus before?"
    0: Yes, and it helped
    1: Yes, but it didn't work for me
    2: No, I'm new to this
```

**Validation Rules**:
- answers must have exactly 5 elements
- Each answer must be valid for its question (varies by question)

---

### Prescription

**Description**: Computed recommendation based on quiz responses.

**Type**: Computed (derived from QuizResponse, not directly stored)

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| recommendedTonicId | String | Primary tonic recommendation | Valid tonic ID |
| recommendedStrength | double | Suggested starting strength | 0.0 <= x <= 1.0 |
| rationale | String | User-facing explanation | Non-empty |
| quizResponseRef | QuizResponse | Source quiz data | Non-null |

**Recommendation Logic**:
```
IF Q1 == sleep (0) OR Q1 == both (2):
    IF Q3 includes ADHD (bit 2):
        recommendedTonic = 'rest' (pink noise - clinically shown for deep sleep)
    ELSE:
        recommendedTonic = 'rest'
ELSE IF Q1 == focus (1):
    recommendedTonic = 'focus' (brown noise - grounding, concentration)

IF Q2 == noisy (2):
    recommendedStrength = 0.65 (higher to mask environment)
ELSE:
    recommendedStrength = 0.5 (safe default)

IF Q4 >= 50 (2 or 3):
    recommendedStrength = min(recommendedStrength, 0.55) (hearing protection)
```

---

## Enumerations

### NoiseType
```dart
enum NoiseType {
  white,  // Bright Tonic - broadest frequency range
  pink,   // Rest Tonic - balanced for sleep
  brown,  // Focus Tonic - deep, grounding
}
```

### SoundType
```dart
enum SoundType {
  tonic,     // Generated noise
  botanical, // Nature sound asset
}
```

### PlaybackStatus
```dart
enum PlaybackStatus {
  stopped,
  playing,
  paused,
}
```

### SafetyLevel
```dart
enum SafetyLevel {
  safe,     // Green - <60dB equivalent
  moderate, // Amber - 60-70dB equivalent
  high,     // Red - >70dB equivalent
}
```

---

## Hive Configuration

### Box Structure
```dart
// Box names and type IDs
const String preferencesBoxName = 'preferences';  // TypeId: 0
const String quizBoxName = 'quiz';                // TypeId: 1
const String playbackBoxName = 'playback';        // TypeId: 2
```

### Initialization Order
```dart
Future<void> initializeStorage() async {
  await Hive.initFlutter();

  // Register adapters in TypeId order
  Hive.registerAdapter(UserPreferencesAdapter());  // 0
  Hive.registerAdapter(QuizResponseAdapter());     // 1
  Hive.registerAdapter(PlaybackSessionAdapter());  // 2
  Hive.registerAdapter(SoundTypeAdapter());        // 3
  Hive.registerAdapter(PlaybackStatusAdapter());   // 4

  // Open boxes
  await Hive.openBox<UserPreferences>(preferencesBoxName);
  await Hive.openBox<QuizResponse>(quizBoxName);
  await Hive.openBox<PlaybackSession>(playbackBoxName);
}
```

---

## Data Flow

### App Launch
```
1. Initialize Hive
2. Load UserPreferences from 'preferences' box
3. Load QuizResponse from 'quiz' box (if exists)
4. Load PlaybackSession from 'playback' box (restore last state)
5. Compute Prescription if quiz completed
6. Navigate to appropriate screen (onboarding vs counter)
```

### Playback Start
```
1. User taps tonic bottle
2. Create PlaybackSession with current settings
3. Save PlaybackSession to 'playback' box
4. Start audio engine with tonic parameters
5. Update UserPreferences.lastSelectedTonic
6. Save UserPreferences to 'preferences' box
```

### Quiz Completion
```
1. User completes all 5 questions
2. Create QuizResponse with answers and timestamp
3. Save QuizResponse to 'quiz' box
4. Compute Prescription from responses
5. Update UserPreferences.quizCompleted = true
6. Save UserPreferences to 'preferences' box
7. Display Prescription to user
```

---

## Migration Strategy

### Future Phases
If data model needs to expand (e.g., custom remedies, treatment log):
1. Add new Hive TypeIds starting from 5
2. Add new boxes for new entity types
3. Existing data remains compatible (Hive handles missing fields gracefully)

### Drift Migration (if needed)
If complex queries required:
1. Export Hive data to JSON
2. Create Drift schema with equivalent tables
3. Import data to Drift
4. Remove Hive dependency
