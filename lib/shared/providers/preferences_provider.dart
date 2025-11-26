import 'package:flutter/foundation.dart';
import '../../core/storage/storage_service.dart';
import '../../core/storage/models/user_preferences.dart';

/// Provider for user preferences.
/// Handles loading, saving, and notifying of preference changes.
class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider({required StorageService storageService})
      : _storageService = storageService {
    _loadPreferences();
  }

  final StorageService _storageService;
  UserPreferences? _preferences;

  /// Current user preferences
  UserPreferences get preferences => _preferences ?? UserPreferences();

  /// Whether onboarding has been completed
  bool get onboardingComplete => _preferences?.onboardingComplete ?? false;

  /// Last selected tonic ID
  String get lastSelectedTonicId =>
      _preferences?.lastSelectedTonicId ?? 'rest';

  /// Last selected botanical ID (null if never used)
  String? get lastSelectedBotanicalId => _preferences?.lastSelectedBotanicalId;

  /// Last used sound type
  String get lastUsedSoundType => _preferences?.lastUsedSoundType ?? 'tonic';

  /// Default strength setting
  double get defaultStrength => _preferences?.defaultStrength ?? 0.5;

  /// Default dosage in minutes
  int get defaultDosageMinutes => _preferences?.defaultDosageMinutes ?? 30;

  void _loadPreferences() {
    _preferences = _storageService.getPreferences();
    notifyListeners();
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await _storageService.updatePreferences(onboardingComplete: true);
    _loadPreferences();
  }

  /// Update the last selected tonic
  Future<void> setLastSelectedTonic(String tonicId) async {
    await _storageService.updatePreferences(
      lastSelectedTonicId: tonicId,
      lastUsedSoundType: 'tonic',
    );
    _loadPreferences();
  }

  /// Update the last selected botanical
  Future<void> setLastSelectedBotanical(String botanicalId) async {
    await _storageService.updatePreferences(
      lastSelectedBotanicalId: botanicalId,
      lastUsedSoundType: 'botanical',
    );
    _loadPreferences();
  }

  /// Update default strength
  Future<void> setDefaultStrength(double strength) async {
    await _storageService.updatePreferences(defaultStrength: strength);
    _loadPreferences();
  }

  /// Update default dosage
  Future<void> setDefaultDosage(int minutes) async {
    await _storageService.updatePreferences(defaultDosageMinutes: minutes);
    _loadPreferences();
  }

  /// Reset all preferences to defaults
  Future<void> resetPreferences() async {
    await _storageService.savePreferences(UserPreferences());
    _loadPreferences();
  }
}
