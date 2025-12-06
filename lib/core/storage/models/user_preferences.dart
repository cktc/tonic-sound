import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

/// User preferences persisted across app sessions.
/// Stores onboarding state, selected tonic/botanical, and default settings.
@HiveType(typeId: 0)
class UserPreferences extends HiveObject {
  UserPreferences({
    this.onboardingComplete = false,
    this.lastSelectedTonicId = 'rest',
    this.lastSelectedBotanicalId,
    this.lastUsedSoundType = 'tonic',
    this.defaultStrength = 0.5,
    this.defaultDosageMinutes = 30,
    this.onboardingMethod,
    this.contextualQuizPromptShown = false,
  });

  /// Whether the user has completed onboarding
  @HiveField(0)
  bool onboardingComplete;

  /// ID of the last selected Tonic (defaults to 'rest')
  @HiveField(1)
  String lastSelectedTonicId;

  /// ID of the last selected Botanical (null if never used)
  @HiveField(2)
  String? lastSelectedBotanicalId;

  /// Last used sound type: 'tonic' or 'botanical'
  @HiveField(3)
  String lastUsedSoundType;

  /// Default volume strength (0.0 to 1.0)
  @HiveField(4)
  double defaultStrength;

  /// Default dosage duration in minutes
  @HiveField(5)
  int defaultDosageMinutes;

  /// How user completed onboarding: 'quiz_completed' or 'skipped'
  @HiveField(6)
  String? onboardingMethod;

  /// Whether we've shown the contextual quiz prompt to skippers
  @HiveField(7)
  bool contextualQuizPromptShown;

  /// Box name for Hive storage
  static const String boxName = 'user_preferences';

  /// Key for the single preferences object
  static const String storageKey = 'preferences';

  /// Whether user skipped onboarding and hasn't seen quiz prompt yet
  bool get shouldShowQuizPrompt =>
      onboardingComplete &&
      onboardingMethod == 'skipped' &&
      !contextualQuizPromptShown;
}
