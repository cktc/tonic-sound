import 'package:flutter/foundation.dart';
import '../../core/storage/storage_service.dart';
import '../../core/storage/models/quiz_response.dart';
import '../../features/onboarding/prescription_service.dart';
import '../../shared/constants/quiz_questions.dart';

/// Provider for quiz and prescription state.
class PrescriptionProvider extends ChangeNotifier {
  PrescriptionProvider({required StorageService storageService})
      : _storageService = storageService {
    _loadResponses();
  }

  final StorageService _storageService;

  /// Current quiz responses (question ID -> option index)
  final Map<String, int> _responses = {};
  Map<String, int> get responses => Map.unmodifiable(_responses);

  /// Current prescription (null until quiz is complete)
  Prescription? _prescription;
  Prescription? get prescription => _prescription;

  /// Whether the quiz has been completed
  bool get isQuizComplete =>
      _responses.length >= QuizQuestions.questions.length;

  void _loadResponses() {
    final storedResponses = _storageService.getQuizResponses();
    for (final response in storedResponses) {
      _responses[response.questionId] = response.selectedOptionIndex;
    }

    if (isQuizComplete) {
      _prescription = PrescriptionService.generatePrescription(_responses);
    }
  }

  /// Record a quiz response
  Future<void> recordResponse(String questionId, int optionIndex) async {
    _responses[questionId] = optionIndex;

    await _storageService.saveQuizResponse(QuizResponse(
      questionId: questionId,
      selectedOptionIndex: optionIndex,
      timestamp: DateTime.now(),
    ));

    // Check if quiz is complete
    if (isQuizComplete) {
      _prescription = PrescriptionService.generatePrescription(_responses);
    }

    notifyListeners();
  }

  /// Get a specific response
  int? getResponse(String questionId) => _responses[questionId];

  /// Clear all responses and start over
  Future<void> clearResponses() async {
    _responses.clear();
    _prescription = null;
    await _storageService.clearQuizResponses();
    notifyListeners();
  }

  /// Get the current prescription or generate a default one
  Prescription getOrDefaultPrescription() {
    return _prescription ?? PrescriptionService.defaultPrescription();
  }
}
