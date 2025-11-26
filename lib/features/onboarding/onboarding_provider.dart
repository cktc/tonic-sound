import 'package:flutter/foundation.dart';
import '../../core/storage/storage_service.dart';
import 'prescription_service.dart';

/// Provider managing onboarding flow state.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  /// Current page in the onboarding flow (0-2 for intro screens, 3+ for quiz)
  int _currentPage = 0;
  int get currentPage => _currentPage;

  /// Whether onboarding has been completed
  bool get isComplete => _storageService.getPreferences().onboardingComplete;

  /// Move to the next onboarding page
  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  /// Move to the previous onboarding page
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// Go directly to quiz (page 3)
  void goToQuiz() {
    _currentPage = 3;
    notifyListeners();
  }

  /// Skip onboarding and mark as complete
  Future<void> skipOnboarding() async {
    await _storageService.updatePreferences(onboardingComplete: true);
    notifyListeners();
  }

  /// Complete onboarding with a prescription
  Future<void> completeWithPrescription(Prescription prescription) async {
    // Save the prescription settings as defaults
    await _storageService.updatePreferences(
      onboardingComplete: true,
      lastSelectedTonicId: prescription.recommendedTonic.id,
      defaultStrength: prescription.recommendedStrength,
      defaultDosageMinutes: prescription.recommendedDosage,
    );

    notifyListeners();
  }

  /// Reset onboarding for retaking the quiz
  Future<void> resetOnboarding() async {
    _currentPage = 0;
    await _storageService.updatePreferences(onboardingComplete: false);
    await _storageService.clearQuizResponses();
    notifyListeners();
  }
}
