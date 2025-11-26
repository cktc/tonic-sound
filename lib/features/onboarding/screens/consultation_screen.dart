import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Consultation intro screen - explains the quiz process.
/// Third onboarding slide before starting the quiz.
class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({
    super.key,
    required this.onStartQuiz,
    required this.onSkip,
  });

  final VoidCallback onStartQuiz;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.onboardingConsultation,
      backgroundColor: TonicColors.base,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: TonicColors.textMuted,
                        ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: TonicColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment,
                    size: 48,
                    color: TonicColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                'Your Consultation',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'Answer 5 quick questions and we\'ll prescribe the '
                'perfect tonic for your needs.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TonicColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Time estimate
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: TonicColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 18,
                      color: TonicColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Takes about 1 minute',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TonicColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // Start quiz button
              ElevatedButton(
                onPressed: onStartQuiz,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Begin Consultation'),
                ),
              ),
              const SizedBox(height: 12),
              // Skip text
              TextButton(
                onPressed: onSkip,
                child: Text(
                  'Skip and explore on your own',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: TonicColors.textMuted,
                      ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
