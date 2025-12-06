import 'package:flutter/material.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Bottom sheet prompting users who skipped onboarding to take the quiz.
/// Shown after first playback session ends.
class QuizPromptSheet extends StatelessWidget {
  const QuizPromptSheet({
    super.key,
    required this.onTakeQuiz,
    required this.onDismiss,
  });

  final VoidCallback onTakeQuiz;
  final VoidCallback onDismiss;

  /// Show the quiz prompt as a modal bottom sheet
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuizPromptSheet(
        onTakeQuiz: () => Navigator.of(context).pop(true),
        onDismiss: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TonicColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TonicColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: TonicColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: TonicColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Get a Personalized Tonic',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                'Answer 3 quick questions and we\'ll recommend the perfect sound for your needs.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TonicColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Time estimate
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: TonicColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '30 seconds',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TonicColors.textMuted,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Take quiz button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTakeQuiz,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Take the Quiz'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Dismiss button
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Maybe Later',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: TonicColors.textMuted,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
