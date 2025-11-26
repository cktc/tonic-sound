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

/// The 5-question personalization quiz
class QuizQuestions {
  QuizQuestions._();

  static const List<QuizQuestion> questions = [
    // Question 1: Primary goal
    QuizQuestion(
      id: 'goal',
      question: 'What brings you to Tonic today?',
      helpText: 'Select your primary reason for seeking sound therapy',
      options: [
        QuizOption(
          text: 'I need help falling asleep',
          scores: {'rest': 3, 'focus': 1, 'bright': 0},
        ),
        QuizOption(
          text: 'I want to improve my focus while working',
          scores: {'rest': 0, 'focus': 2, 'bright': 3},
        ),
        QuizOption(
          text: 'I\'m looking for general relaxation',
          scores: {'rest': 2, 'focus': 2, 'bright': 1},
        ),
        QuizOption(
          text: 'I need to block distracting noises',
          scores: {'rest': 1, 'focus': 2, 'bright': 2},
        ),
      ],
    ),
    // Question 2: Environment
    QuizQuestion(
      id: 'environment',
      question: 'What does your typical environment sound like?',
      options: [
        QuizOption(
          text: 'Very quiet, almost silent',
          scores: {'rest': 2, 'focus': 1, 'bright': 0},
        ),
        QuizOption(
          text: 'Some background noise (traffic, AC)',
          scores: {'rest': 1, 'focus': 2, 'bright': 2},
        ),
        QuizOption(
          text: 'Frequently interrupted by sudden sounds',
          scores: {'rest': 0, 'focus': 1, 'bright': 3},
        ),
        QuizOption(
          text: 'Chaotic with many overlapping sounds',
          scores: {'rest': 0, 'focus': 3, 'bright': 2},
        ),
      ],
    ),
    // Question 3: Sound preference
    QuizQuestion(
      id: 'preference',
      question: 'What type of sounds do you naturally find calming?',
      options: [
        QuizOption(
          text: 'Deep, rumbling sounds like thunder',
          scores: {'rest': 1, 'focus': 3, 'bright': 0},
        ),
        QuizOption(
          text: 'Consistent, steady sounds like rain',
          scores: {'rest': 3, 'focus': 1, 'bright': 1},
        ),
        QuizOption(
          text: 'Crisp, even sounds like static',
          scores: {'rest': 0, 'focus': 1, 'bright': 3},
        ),
        QuizOption(
          text: 'I\'m not sure / haven\'t tried many',
          scores: {'rest': 2, 'focus': 1, 'bright': 1},
        ),
      ],
    ),
    // Question 4: Time of use
    QuizQuestion(
      id: 'timing',
      question: 'When do you plan to use Tonic most often?',
      options: [
        QuizOption(
          text: 'At night, before or during sleep',
          scores: {'rest': 3, 'focus': 0, 'bright': 0},
        ),
        QuizOption(
          text: 'During the day for work or study',
          scores: {'rest': 0, 'focus': 2, 'bright': 3},
        ),
        QuizOption(
          text: 'Throughout the day as needed',
          scores: {'rest': 1, 'focus': 2, 'bright': 2},
        ),
        QuizOption(
          text: 'Mainly for meditation or relaxation',
          scores: {'rest': 2, 'focus': 3, 'bright': 0},
        ),
      ],
    ),
    // Question 5: Sensitivity
    QuizQuestion(
      id: 'sensitivity',
      question: 'How would you describe your sensitivity to sound?',
      options: [
        QuizOption(
          text: 'High - sounds easily bother me',
          scores: {'rest': 2, 'focus': 3, 'bright': 0},
        ),
        QuizOption(
          text: 'Moderate - some sounds are distracting',
          scores: {'rest': 2, 'focus': 2, 'bright': 1},
        ),
        QuizOption(
          text: 'Low - I can work through most noise',
          scores: {'rest': 1, 'focus': 1, 'bright': 2},
        ),
        QuizOption(
          text: 'Variable - depends on my mood',
          scores: {'rest': 2, 'focus': 2, 'bright': 2},
        ),
      ],
    ),
  ];
}
