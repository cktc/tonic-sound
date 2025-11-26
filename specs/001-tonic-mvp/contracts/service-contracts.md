# Service Contracts: Tonic MVP

**Feature Branch**: `001-tonic-mvp`
**Date**: 2025-11-25
**Type**: Internal Service Interfaces (no REST API for MVP)

---

## Overview

Tonic MVP is a fully offline mobile app with no backend API. This document defines the internal service contracts between app layers to ensure clear boundaries and testable interfaces.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SERVICE ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                         UI LAYER                                │ │
│  │  (Screens: Counter, Dispensary, Onboarding, Settings)          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                      PROVIDER LAYER                             │ │
│  │  (PlaybackProvider, PreferencesProvider, PrescriptionProvider) │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────┬──────────────────┬─────────────────────┐  │
│  │   AudioService      │  StorageService  │  PrescriptionService│  │
│  │   (Core Audio)      │  (Hive)          │  (Quiz Logic)       │  │
│  └─────────────────────┴──────────────────┴─────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## AudioService Contract

**Purpose**: Manages real-time audio generation, playback control, and system integration.

### Interface

```dart
/// Contract for audio playback operations.
/// Implementation uses flutter_pcm_sound + audio_service.
abstract class AudioService {
  /// Current playback state stream for reactive UI updates.
  Stream<PlaybackState> get playbackStateStream;

  /// Current playback state snapshot.
  PlaybackState get currentState;

  /// Start playing a tonic (generated noise).
  ///
  /// [tonicType]: The noise type to generate (white, pink, brown).
  /// [strength]: Volume level 0.0-1.0.
  /// [dosageMinutes]: Timer duration (-1 for continuous).
  ///
  /// Throws [AudioInitializationException] if audio system fails to initialize.
  /// Throws [InvalidParameterException] if parameters out of range.
  Future<void> dispenseTonic({
    required NoiseType tonicType,
    required double strength,
    required int dosageMinutes,
  });

  /// Start playing a botanical (audio asset).
  ///
  /// [assetPath]: Path to the audio asset file.
  /// [strength]: Volume level 0.0-1.0.
  /// [dosageMinutes]: Timer duration (-1 for continuous).
  ///
  /// Throws [AssetNotFoundException] if audio file not found.
  Future<void> dispenseBotanical({
    required String assetPath,
    required double strength,
    required int dosageMinutes,
  });

  /// Stop playback immediately.
  Future<void> cap();

  /// Pause playback (preserves position for botanicals).
  Future<void> pause();

  /// Resume paused playback.
  Future<void> resume();

  /// Update volume during playback.
  ///
  /// [strength]: New volume level 0.0-1.0.
  Future<void> setStrength(double strength);

  /// Get estimated dB level for safety indicator.
  ///
  /// Returns approximate dB based on strength and system volume.
  /// Note: This is an estimation; actual dB depends on headphone impedance.
  SafetyLevel getSafetyLevel(double strength);

  /// Clean up resources when app terminates.
  Future<void> dispose();
}
```

### PlaybackState

```dart
/// Immutable snapshot of current playback state.
class PlaybackState {
  final PlaybackStatus status;
  final String? activeSoundId;
  final SoundType? soundType;
  final double strength;
  final int dosageMinutes;
  final Duration elapsed;
  final Duration remaining;
  final bool isFadingOut;

  const PlaybackState({
    required this.status,
    this.activeSoundId,
    this.soundType,
    this.strength = 0.5,
    this.dosageMinutes = 120,
    this.elapsed = Duration.zero,
    this.remaining = Duration.zero,
    this.isFadingOut = false,
  });

  factory PlaybackState.stopped() => const PlaybackState(
    status: PlaybackStatus.stopped,
  );

  PlaybackState copyWith({...});
}
```

### Error Types

```dart
class AudioInitializationException implements Exception {
  final String message;
  final Object? cause;
  AudioInitializationException(this.message, [this.cause]);
}

class AssetNotFoundException implements Exception {
  final String assetPath;
  AssetNotFoundException(this.assetPath);
}

class InvalidParameterException implements Exception {
  final String parameter;
  final String reason;
  InvalidParameterException(this.parameter, this.reason);
}
```

---

## StorageService Contract

**Purpose**: Manages local data persistence using Hive.

### Interface

```dart
/// Contract for local storage operations.
/// Implementation uses Hive NoSQL database.
abstract class StorageService {
  /// Initialize storage (call once at app startup).
  ///
  /// Throws [StorageInitializationException] if Hive fails to initialize.
  Future<void> initialize();

  // === User Preferences ===

  /// Get current user preferences.
  /// Returns default preferences if none saved.
  UserPreferences getPreferences();

  /// Save user preferences.
  ///
  /// Automatically updates `updatedAt` timestamp.
  Future<void> savePreferences(UserPreferences preferences);

  /// Watch preferences for changes (reactive).
  Stream<UserPreferences> watchPreferences();

  // === Quiz Responses ===

  /// Get latest quiz response, or null if not completed.
  QuizResponse? getQuizResponse();

  /// Save quiz response (replaces any existing).
  Future<void> saveQuizResponse(QuizResponse response);

  /// Check if quiz has been completed.
  bool get isQuizCompleted;

  // === Playback Session ===

  /// Get last playback session for restore on app launch.
  PlaybackSession? getLastSession();

  /// Save current playback session.
  Future<void> savePlaybackSession(PlaybackSession session);

  /// Clear playback session (on clean stop).
  Future<void> clearPlaybackSession();

  // === Lifecycle ===

  /// Close all storage boxes.
  Future<void> close();

  /// Clear all stored data (for testing/reset).
  Future<void> clearAll();
}
```

### Error Types

```dart
class StorageInitializationException implements Exception {
  final String message;
  final Object? cause;
  StorageInitializationException(this.message, [this.cause]);
}

class StorageWriteException implements Exception {
  final String operation;
  final Object? cause;
  StorageWriteException(this.operation, [this.cause]);
}
```

---

## PrescriptionService Contract

**Purpose**: Generates tonic recommendations based on quiz responses.

### Interface

```dart
/// Contract for prescription generation from quiz data.
/// Pure logic service with no side effects.
abstract class PrescriptionService {
  /// Generate a prescription from quiz responses.
  ///
  /// [responses]: User's answers to the 5 consultation questions.
  ///
  /// Returns computed prescription with recommended tonic and rationale.
  /// Throws [InvalidQuizResponseException] if responses malformed.
  Prescription generatePrescription(QuizResponse responses);

  /// Get question definitions for building quiz UI.
  List<QuizQuestion> getQuestions();

  /// Validate quiz response format before processing.
  bool validateResponses(List<int> answers);
}
```

### QuizQuestion

```dart
/// Definition of a single quiz question.
class QuizQuestion {
  final int index;
  final String text;
  final List<QuizOption> options;
  final bool isMultiSelect;

  const QuizQuestion({
    required this.index,
    required this.text,
    required this.options,
    this.isMultiSelect = false,
  });
}

class QuizOption {
  final int value;
  final String text;

  const QuizOption({required this.value, required this.text});
}
```

### Prescription

```dart
/// Computed recommendation from quiz responses.
class Prescription {
  final String recommendedTonicId;
  final double recommendedStrength;
  final String rationale;
  final DateTime generatedAt;

  const Prescription({
    required this.recommendedTonicId,
    required this.recommendedStrength,
    required this.rationale,
    required this.generatedAt,
  });
}
```

### Error Types

```dart
class InvalidQuizResponseException implements Exception {
  final String reason;
  InvalidQuizResponseException(this.reason);
}
```

---

## TonicCatalog Contract

**Purpose**: Provides static definitions of tonics and botanicals.

### Interface

```dart
/// Contract for accessing tonic and botanical definitions.
/// Read-only catalog with no persistence.
abstract class TonicCatalog {
  /// Get all available tonics.
  List<Tonic> getAllTonics();

  /// Get a specific tonic by ID.
  /// Throws [TonicNotFoundException] if ID invalid.
  Tonic getTonicById(String id);

  /// Get all available botanicals.
  List<Botanical> getAllBotanicals();

  /// Get a specific botanical by ID.
  /// Throws [BotanicalNotFoundException] if ID invalid.
  Botanical getBotanicalById(String id);

  /// Get tonic by noise type.
  Tonic getTonicByType(NoiseType type);
}
```

### Static Definitions

```dart
/// Tonic definition (immutable).
class Tonic {
  final String id;
  final String name;
  final NoiseType type;
  final String description;
  final Color bottleColor;
  final String iconAsset;

  const Tonic({...});

  static const bright = Tonic(
    id: 'bright',
    name: 'Bright Tonic',
    type: NoiseType.white,
    description: 'Light and alert. The broadest frequency range for masking distractions.',
    bottleColor: Color(0xFFF5F0E6),
    iconAsset: 'assets/images/bottles/bright.png',
  );

  static const rest = Tonic(
    id: 'rest',
    name: 'Rest Tonic',
    type: NoiseType.pink,
    description: 'Balanced and soothing. Clinically shown to enhance deep sleep.',
    bottleColor: Color(0xFFD4899A),
    iconAsset: 'assets/images/bottles/rest.png',
  );

  static const focus = Tonic(
    id: 'focus',
    name: 'Focus Tonic',
    type: NoiseType.brown,
    description: 'Deep and grounding. Helps quiet racing thoughts and improve concentration.',
    bottleColor: Color(0xFF8B6914),
    iconAsset: 'assets/images/bottles/focus.png',
  );
}

/// Botanical definition (immutable).
class Botanical {
  final String id;
  final String name;
  final String description;
  final String assetPath;
  final String iconAsset;

  const Botanical({...});

  static const rain = Botanical(
    id: 'rain',
    name: 'Rainfall Extract',
    description: 'Gentle rain on leaves. A natural remedy for restless minds.',
    assetPath: 'assets/audio/botanicals/rain.mp3',
    iconAsset: 'assets/images/botanicals/rain.png',
  );

  static const ocean = Botanical(
    id: 'ocean',
    name: 'Sea Salt Tincture',
    description: 'Rhythmic ocean waves. Let the tide wash your worries away.',
    assetPath: 'assets/audio/botanicals/ocean.mp3',
    iconAsset: 'assets/images/botanicals/ocean.png',
  );

  static const forest = Botanical(
    id: 'forest',
    name: 'Woodland Blend',
    description: 'Forest ambience with birdsong. Reconnect with nature.',
    assetPath: 'assets/audio/botanicals/forest.mp3',
    iconAsset: 'assets/images/botanicals/forest.png',
  );
}
```

---

## Provider Contracts

### PlaybackProvider

```dart
/// Provider for playback state management.
/// Bridges AudioService to UI.
class PlaybackProvider extends ChangeNotifier {
  final AudioService _audioService;
  final StorageService _storageService;

  PlaybackState get state;

  /// Start dispensing a tonic.
  Future<void> dispenseTonic(String tonicId, double strength, int dosageMinutes);

  /// Start dispensing a botanical.
  Future<void> dispenseBotanical(String botanicalId, double strength, int dosageMinutes);

  /// Stop playback.
  Future<void> cap();

  /// Pause playback.
  Future<void> pause();

  /// Resume playback.
  Future<void> resume();

  /// Update strength during playback.
  Future<void> setStrength(double strength);

  /// Get safety level for current or proposed strength.
  SafetyLevel getSafetyLevel(double strength);
}
```

### PreferencesProvider

```dart
/// Provider for user preferences.
/// Manages persistence automatically.
class PreferencesProvider extends ChangeNotifier {
  final StorageService _storageService;

  UserPreferences get preferences;
  bool get isOnboardingComplete;
  bool get isQuizComplete;

  /// Update a single preference.
  Future<void> setLastSelectedTonic(String tonicId);
  Future<void> setDefaultStrength(double strength);
  Future<void> setDefaultDosage(int minutes);
  Future<void> completeOnboarding();
}
```

### PrescriptionProvider

```dart
/// Provider for quiz and prescription state.
class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionService _prescriptionService;
  final StorageService _storageService;

  QuizResponse? get quizResponse;
  Prescription? get prescription;
  List<QuizQuestion> get questions;

  /// Submit quiz answers and generate prescription.
  Future<Prescription> submitQuiz(List<int> answers);

  /// Skip quiz (user opts out).
  void skipQuiz();

  /// Reset quiz (retake).
  Future<void> resetQuiz();
}
```

---

## Noise Generator Contract

**Purpose**: Low-level interface for noise generation algorithms.

### Interface

```dart
/// Contract for noise generation algorithms.
/// Implementations are stateless and produce PCM samples.
abstract class NoiseGenerator {
  /// Generate a buffer of PCM samples.
  ///
  /// [sampleCount]: Number of samples to generate.
  /// Returns Int16List of PCM samples at 44100 Hz, 16-bit.
  Int16List generate(int sampleCount);

  /// Reset generator state (for pink/brown noise filters).
  void reset();
}
```

### Implementations

```dart
/// White noise generator (random values).
class WhiteNoiseGenerator implements NoiseGenerator {
  final Random _random;

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);
    for (int i = 0; i < sampleCount; i++) {
      // Random value in 16-bit signed range, normalized
      samples[i] = ((_random.nextDouble() * 2 - 1) * 32767).toInt();
    }
    return samples;
  }

  @override
  void reset() {} // Stateless
}

/// Pink noise generator (IIR filtered white noise).
class PinkNoiseGenerator implements NoiseGenerator {
  // Filter coefficients per constitution
  static const List<double> _b = [0.049922035, -0.095993537, 0.050612699, -0.004408786];
  static const List<double> _a = [1, -2.494956002, 2.017265875, -0.522189400];

  // Filter state
  final List<double> _xHistory = [0, 0, 0, 0];
  final List<double> _yHistory = [0, 0, 0, 0];

  @override
  Int16List generate(int sampleCount) { /* IIR filter implementation */ }

  @override
  void reset() {
    _xHistory.fillRange(0, 4, 0);
    _yHistory.fillRange(0, 4, 0);
  }
}

/// Brown noise generator (leaky integrator).
class BrownNoiseGenerator implements NoiseGenerator {
  static const double _coefficient = 0.02;
  double _lastSample = 0;

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);
    final random = Random();
    for (int i = 0; i < sampleCount; i++) {
      final white = random.nextDouble() * 2 - 1;
      _lastSample = (_lastSample + _coefficient * white).clamp(-1.0, 1.0);
      samples[i] = (_lastSample * 32767).toInt();
    }
    return samples;
  }

  @override
  void reset() {
    _lastSample = 0;
  }
}
```

---

## Testing Contracts

### Test Doubles

```dart
/// Mock AudioService for widget tests.
class MockAudioService implements AudioService {
  final _stateController = StreamController<PlaybackState>.broadcast();
  PlaybackState _state = PlaybackState.stopped();

  @override
  Stream<PlaybackState> get playbackStateStream => _stateController.stream;

  @override
  PlaybackState get currentState => _state;

  void simulateState(PlaybackState state) {
    _state = state;
    _stateController.add(state);
  }

  // ... stub implementations
}

/// Mock StorageService for unit tests.
class MockStorageService implements StorageService {
  final Map<String, dynamic> _store = {};

  @override
  UserPreferences getPreferences() {
    return _store['preferences'] ?? UserPreferences.defaults();
  }

  // ... stub implementations
}
```

---

## Semantic Keys for E2E Testing

Per coding guidelines, UI components should be tagged semantically:

```dart
/// Semantic keys for E2E testing.
class TonicTestKeys {
  // Counter Screen
  static const counterScreen = Key('counter_screen');
  static const tonicBottle = Key('tonic_bottle');
  static const dispenseButton = Key('dispense_button');
  static const capButton = Key('cap_button');
  static const strengthSlider = Key('strength_slider');
  static const safetyIndicator = Key('safety_indicator');
  static const dosageSelector = Key('dosage_selector');
  static const timerDisplay = Key('timer_display');

  // Dispensary Screen
  static const dispensaryScreen = Key('dispensary_screen');
  static const tonicGrid = Key('tonic_grid');
  static const botanicalGrid = Key('botanical_grid');
  static const tonicCard = ValueKey<String>; // tonicCard('rest')
  static const botanicalCard = ValueKey<String>; // botanicalCard('rain')

  // Onboarding
  static const onboardingScreen = Key('onboarding_screen');
  static const consultationQuiz = Key('consultation_quiz');
  static const quizQuestion = ValueKey<int>; // quizQuestion(0)
  static const quizOption = ValueKey<String>; // quizOption('0_1') = Q0, Option 1
  static const skipButton = Key('skip_button');
  static const nextButton = Key('next_button');
  static const prescriptionCard = Key('prescription_card');

  // Navigation
  static const bottomNav = Key('bottom_nav');
  static const counterNavItem = Key('nav_counter');
  static const dispensaryNavItem = Key('nav_dispensary');
  static const settingsNavItem = Key('nav_settings');
}
```
