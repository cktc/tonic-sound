import '../../shared/constants/quiz_questions.dart';
import '../../shared/constants/tonic_catalog.dart';

/// Prescription generated from quiz responses.
class Prescription {
  const Prescription({
    required this.recommendedTonic,
    required this.recommendedStrength,
    required this.recommendedDosage,
    required this.reasoning,
  });

  final Tonic recommendedTonic;
  final double recommendedStrength;
  final int recommendedDosage;
  final String reasoning;
}

/// Service for generating personalized prescriptions from quiz responses.
class PrescriptionService {
  PrescriptionService._();

  /// Generate a prescription from quiz responses.
  /// [responses] is a map of question ID to selected option index.
  static Prescription generatePrescription(Map<String, int> responses) {
    // Calculate scores for each tonic
    final scores = <String, int>{
      'bright': 0,
      'rest': 0,
      'focus': 0,
    };

    for (final entry in responses.entries) {
      final questionId = entry.key;
      final optionIndex = entry.value;

      // Find the question
      final question = QuizQuestions.questions.firstWhere(
        (q) => q.id == questionId,
        orElse: () => throw StateError('Question not found: $questionId'),
      );

      // Get the selected option's scores
      if (optionIndex >= 0 && optionIndex < question.options.length) {
        final option = question.options[optionIndex];
        for (final scoreEntry in option.scores.entries) {
          scores[scoreEntry.key] = scores[scoreEntry.key]! + scoreEntry.value;
        }
      }
    }

    // Find the tonic with highest score
    String winningTonicId = 'rest'; // Default
    int highestScore = 0;

    for (final entry in scores.entries) {
      if (entry.value > highestScore) {
        highestScore = entry.value;
        winningTonicId = entry.key;
      }
    }

    final recommendedTonic = Tonic.byId(winningTonicId) ?? Tonic.defaultTonic;

    // Determine recommended settings based on tonic type and scores
    final recommendedStrength = _calculateRecommendedStrength(winningTonicId, scores);
    final recommendedDosage = _calculateRecommendedDosage(responses);
    final reasoning = _generateReasoning(recommendedTonic, responses);

    return Prescription(
      recommendedTonic: recommendedTonic,
      recommendedStrength: recommendedStrength,
      recommendedDosage: recommendedDosage,
      reasoning: reasoning,
    );
  }

  /// Generate a default prescription for users who skip the quiz.
  static Prescription defaultPrescription() {
    return Prescription(
      recommendedTonic: Tonic.byId('rest')!,
      recommendedStrength: 0.5,
      recommendedDosage: 30,
      reasoning: 'Rest is our most popular tonic, perfect for getting started '
          'with sound therapy. It provides a balanced, soothing sound that '
          'works well for both sleep and relaxation.',
    );
  }

  static double _calculateRecommendedStrength(String tonicId, Map<String, int> scores) {
    // Base strength on tonic type
    switch (tonicId) {
      case 'bright':
        return 0.4; // White noise can be intense, start lower
      case 'rest':
        return 0.5; // Pink noise is balanced
      case 'focus':
        return 0.55; // Brown noise often needs slightly more volume
      default:
        return 0.5;
    }
  }

  static int _calculateRecommendedDosage(Map<String, int> responses) {
    // Check timing response
    final timingResponse = responses['timing'];

    if (timingResponse == 0) {
      // Night/sleep use - longer dosage
      return 60;
    } else if (timingResponse == 1) {
      // Work/study - medium dosage
      return 30;
    } else {
      // Other - standard
      return 30;
    }
  }

  static String _generateReasoning(Tonic tonic, Map<String, int> responses) {
    // Note: responses can be used for more personalized reasoning in the future

    switch (tonic.id) {
      case 'bright':
        return 'Based on your responses, Bright tonic\'s crisp white noise '
            'will help mask distracting sounds and sharpen your focus. '
            'It\'s ideal for work sessions and environments with sudden noises.';
      case 'rest':
        return 'Your answers suggest Rest tonic\'s warm pink noise is perfect '
            'for you. It provides a balanced, natural sound that promotes '
            'relaxation and quality sleep without being too intense.';
      case 'focus':
        return 'Focus tonic\'s deep brown noise matches your need for a '
            'grounding, rumbling foundation. It\'s excellent for blocking '
            'low-frequency distractions and promoting calm concentration.';
      default:
        return 'This tonic was selected based on your quiz responses.';
    }
  }
}
