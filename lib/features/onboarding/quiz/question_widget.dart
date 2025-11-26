import 'package:flutter/material.dart';
import '../../../shared/constants/quiz_questions.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Single question widget for the quiz.
/// Displays a question with selectable options.
class QuestionWidget extends StatelessWidget {
  const QuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedIndex,
    required this.onOptionSelected,
  });

  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedIndex;
  final ValueChanged<int> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: TonicTestKeys.quizQuestion,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress indicator
        _buildProgressIndicator(context),
        const SizedBox(height: 32),
        // Question text
        Text(
          question.question,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (question.helpText != null) ...[
          const SizedBox(height: 8),
          Text(
            question.helpText!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TonicColors.textSecondary,
                ),
          ),
        ],
        const SizedBox(height: 32),
        // Options
        ...List.generate(question.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOption(context, index, question.options[index]),
          );
        }),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Column(
      key: TonicTestKeys.quizProgressIndicator,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $questionNumber of $totalQuestions',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TonicColors.textSecondary,
                  ),
            ),
            Text(
              '${((questionNumber / totalQuestions) * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TonicColors.accent,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: questionNumber / totalQuestions,
          backgroundColor: TonicColors.surface,
          valueColor: const AlwaysStoppedAnimation<Color>(TonicColors.accent),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, int index, QuizOption option) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      key: TonicTestKeys.indexed('quiz_option', index),
      onTap: () => onOptionSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TonicColors.accent.withValues(alpha: 0.15) : TonicColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? TonicColors.accent : TonicColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? TonicColors.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? TonicColors.accent : TonicColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: TonicColors.base,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Option text
            Expanded(
              child: Text(
                option.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? TonicColors.textPrimary
                          : TonicColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
