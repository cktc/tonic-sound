/// Quiz questions for the personalization consultation.
/// Each question helps determine the ideal tonic prescription.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.helpText,
  });

  final String id;
  final String question;
  final List<QuizOption> options;
  final String? helpText;
}

class QuizOption {
  const QuizOption({
    required this.text,
    required this.scores,
  });

  final String text;
  /// Map of tonic ID to score contribution
  final Map<String, int> scores;
}

/// The streamlined 3-question personalization quiz (v2)
/// Reduced from 5 questions based on analytics showing these 3 have highest signal
class QuizQuestions {
  QuizQuestions._();

  static const List<QuizQuestion> questions = [
    // Question 1: Primary goal - strongest predictor of tonic choice
    QuizQuestion(
      id: 'goal',
      question: 'What brings you to Tonic today?',
      options: [
        QuizOption(
          text: 'I need help falling asleep',
          scores: {'rest': 3, 'focus': 1, 'bright': 0},
        ),
        QuizOption(
          text: 'I want to improve my focus',
          scores: {'rest': 0, 'focus': 2, 'bright': 3},
        ),
        QuizOption(
          text: 'I\'m looking for relaxation',
          scores: {'rest': 2, 'focus': 2, 'bright': 1},
        ),
        QuizOption(
          text: 'I need to block distractions',
          scores: {'rest': 1, 'focus': 2, 'bright': 2},
        ),
      ],
    ),
    // Question 2: Time of use - determines dosage
    QuizQuestion(
      id: 'timing',
      question: 'When will you use Tonic most?',
      options: [
        QuizOption(
          text: 'At night for sleep',
          scores: {'rest': 3, 'focus': 0, 'bright': 0},
        ),
        QuizOption(
          text: 'During the day for work',
          scores: {'rest': 0, 'focus': 2, 'bright': 3},
        ),
        QuizOption(
          text: 'Anytime I need it',
          scores: {'rest': 1, 'focus': 2, 'bright': 2},
        ),
        QuizOption(
          text: 'For meditation or relaxation',
          scores: {'rest': 2, 'focus': 3, 'bright': 0},
        ),
      ],
    ),
    // Question 3: Sensitivity - safety-critical, affects strength
    QuizQuestion(
      id: 'sensitivity',
      question: 'How sensitive are you to sound?',
      options: [
        QuizOption(
          text: 'Very sensitive',
          scores: {'rest': 2, 'focus': 3, 'bright': 0},
        ),
        QuizOption(
          text: 'Somewhat sensitive',
          scores: {'rest': 2, 'focus': 2, 'bright': 1},
        ),
        QuizOption(
          text: 'Not very sensitive',
          scores: {'rest': 1, 'focus': 1, 'bright': 2},
        ),
        QuizOption(
          text: 'It depends on my mood',
          scores: {'rest': 2, 'focus': 2, 'bright': 2},
        ),
      ],
    ),
  ];

  // Removed in v2 (kept for reference):
  // - environment: Low signal from analytics, answers spread evenly
  // - preference: Can be inferred from goal, or discovered through exploration
}
