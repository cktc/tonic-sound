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
    String? onboardingMethod,
    bool? contextualQuizPromptShown,
    bool? firstPlaybackCompleted,
    bool? notificationPermissionRequested,
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
    if (onboardingMethod != null) {
      prefs.onboardingMethod = onboardingMethod;
    }
    if (contextualQuizPromptShown != null) {
      prefs.contextualQuizPromptShown = contextualQuizPromptShown;
    }
    if (firstPlaybackCompleted != null) {
      prefs.firstPlaybackCompleted = firstPlaybackCompleted;
    }
    if (notificationPermissionRequested != null) {
      prefs.notificationPermissionRequested = notificationPermissionRequested;
    }

    await prefs.save();
  }

  /// Record a new session and return session metadata for analytics
  /// Returns: {sessionNumber, daysSinceInstall, daysSinceLastSession, isFirstSession}
  Future<Map<String, dynamic>> recordNewSession() async {
    _ensureInitialized();
    final prefs = getPreferences();
    final now = DateTime.now();

    // Initialize install date if first session
    final isFirstSession = prefs.installDate == null;
    if (isFirstSession) {
      prefs.installDate = now;
    }

    // Calculate days since install
    final daysSinceInstall = prefs.installDate != null
        ? now.difference(prefs.installDate!).inDays
        : 0;

    // Calculate days since last session
    final daysSinceLastSession = prefs.lastSessionDate != null
        ? now.difference(prefs.lastSessionDate!).inDays
        : 0;

    // Increment session count
    prefs.sessionCount += 1;
    prefs.lastSessionDate = now;

    await prefs.save();

    return {
      'sessionNumber': prefs.sessionCount,
      'daysSinceInstall': daysSinceInstall,
      'daysSinceLastSession': daysSinceLastSession,
      'isFirstSession': isFirstSession,
    };
  }

  /// Get current session number
  int getSessionCount() {
    _ensureInitialized();
    return getPreferences().sessionCount;
  }

  /// Get days since install
  int getDaysSinceInstall() {
    _ensureInitialized();
    final prefs = getPreferences();
    if (prefs.installDate == null) return 0;
    return DateTime.now().difference(prefs.installDate!).inDays;
  }

  /// Check if first playback has been completed
  bool isFirstPlaybackCompleted() {
    _ensureInitialized();
    return getPreferences().firstPlaybackCompleted;
  }

  /// Mark first playback as completed
  Future<void> markFirstPlaybackCompleted() async {
    _ensureInitialized();
    final prefs = getPreferences();
    prefs.firstPlaybackCompleted = true;
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
