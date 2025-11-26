import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_preferences.dart';
import 'models/quiz_response.dart';
import 'models/playback_session.dart';

/// Storage service providing Hive-based local persistence.
/// Handles initialization, CRUD operations, and cleanup for all stored data.
class StorageService {
  Box<UserPreferences>? _preferencesBox;
  Box<QuizResponse>? _quizBox;
  Box<PlaybackSession>? _sessionsBox;

  bool _initialized = false;

  /// Whether the storage service has been initialized
  bool get isInitialized => _initialized;

  /// Initialize Hive and open all boxes.
  /// Must be called before any other operations.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(QuizResponseAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PlaybackSessionAdapter());
    }

    // Open boxes
    _preferencesBox = await Hive.openBox<UserPreferences>(
      UserPreferences.boxName,
    );
    _quizBox = await Hive.openBox<QuizResponse>(QuizResponse.boxName);
    _sessionsBox = await Hive.openBox<PlaybackSession>(
      PlaybackSession.boxName,
    );

    _initialized = true;
  }

  /// Get user preferences, creating defaults if not exists
  UserPreferences getPreferences() {
    _ensureInitialized();
    var prefs = _preferencesBox!.get(UserPreferences.storageKey);
    if (prefs == null) {
      prefs = UserPreferences();
      _preferencesBox!.put(UserPreferences.storageKey, prefs);
    }
    return prefs;
  }

  /// Save user preferences
  Future<void> savePreferences(UserPreferences preferences) async {
    _ensureInitialized();
    await _preferencesBox!.put(UserPreferences.storageKey, preferences);
  }

  /// Update specific preference fields
  Future<void> updatePreferences({
    bool? onboardingComplete,
    String? lastSelectedTonicId,
    String? lastSelectedBotanicalId,
    String? lastUsedSoundType,
    double? defaultStrength,
    int? defaultDosageMinutes,
  }) async {
    final prefs = getPreferences();

    if (onboardingComplete != null) {
      prefs.onboardingComplete = onboardingComplete;
    }
    if (lastSelectedTonicId != null) {
      prefs.lastSelectedTonicId = lastSelectedTonicId;
    }
    if (lastSelectedBotanicalId != null) {
      prefs.lastSelectedBotanicalId = lastSelectedBotanicalId;
    }
    if (lastUsedSoundType != null) prefs.lastUsedSoundType = lastUsedSoundType;
    if (defaultStrength != null) prefs.defaultStrength = defaultStrength;
    if (defaultDosageMinutes != null) {
      prefs.defaultDosageMinutes = defaultDosageMinutes;
    }

    await prefs.save();
  }

  /// Save a quiz response
  Future<void> saveQuizResponse(QuizResponse response) async {
    _ensureInitialized();
    await _quizBox!.put(response.questionId, response);
  }

  /// Get all quiz responses
  List<QuizResponse> getQuizResponses() {
    _ensureInitialized();
    return _quizBox!.values.toList();
  }

  /// Get a specific quiz response by question ID
  QuizResponse? getQuizResponse(String questionId) {
    _ensureInitialized();
    return _quizBox!.get(questionId);
  }

  /// Clear all quiz responses (for retaking quiz)
  Future<void> clearQuizResponses() async {
    _ensureInitialized();
    await _quizBox!.clear();
  }

  /// Record a playback session
  Future<void> recordSession(PlaybackSession session) async {
    _ensureInitialized();
    await _sessionsBox!.add(session);
  }

  /// Get all playback sessions
  List<PlaybackSession> getSessions() {
    _ensureInitialized();
    return _sessionsBox!.values.toList();
  }

  /// Get sessions within a date range
  List<PlaybackSession> getSessionsInRange(DateTime start, DateTime end) {
    _ensureInitialized();
    return _sessionsBox!.values.where((s) {
      return s.startTime.isAfter(start) && s.startTime.isBefore(end);
    }).toList();
  }

  /// Get total listening time in minutes
  int getTotalListeningMinutes() {
    _ensureInitialized();
    return _sessionsBox!.values.fold(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Clear all stored data (for testing/reset)
  Future<void> clearAll() async {
    _ensureInitialized();
    await _preferencesBox!.clear();
    await _quizBox!.clear();
    await _sessionsBox!.clear();
  }

  /// Close all boxes (call on app termination)
  Future<void> close() async {
    if (!_initialized) return;
    await _preferencesBox?.close();
    await _quizBox?.close();
    await _sessionsBox?.close();
    _initialized = false;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'StorageService not initialized. Call initialize() first.',
      );
    }
  }
}
