import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/tonic_colors.dart';
import '../tuning_onboarding_flow.dart';

/// Step 1: Goal selection
/// "What brings you here?"
/// Selecting an option immediately crossfades to the appropriate sound.
class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({
    super.key,
    required this.onGoalSelected,
    required this.onSkip,
  });

  final void Function(TuningGoal goal) onGoalSelected;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TonicColors.base,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Question
              Text(
                'What brings you here?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: TonicColors.textPrimary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Goal options
              _GoalOptionCard(
                icon: Icons.bedtime_outlined,
                label: 'Help me sleep',
                onTap: () => onGoalSelected(TuningGoal.sleep),
              ),
              const SizedBox(height: 16),
              _GoalOptionCard(
                icon: Icons.center_focus_strong_outlined,
                label: 'Help me focus',
                onTap: () => onGoalSelected(TuningGoal.focus),
              ),
              const SizedBox(height: 16),
              _GoalOptionCard(
                icon: Icons.spa_outlined,
                label: 'Help me unwind',
                onTap: () => onGoalSelected(TuningGoal.unwind),
              ),
              const Spacer(flex: 3),
              // Skip link
              Center(
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: TonicColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual goal option card
class _GoalOptionCard extends StatefulWidget {
  const _GoalOptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_GoalOptionCard> createState() => _GoalOptionCardState();
}

class _GoalOptionCardState extends State<_GoalOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: _isPressed
              ? TonicColors.accent.withValues(alpha: 0.15)
              : TonicColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed
                ? TonicColors.accent.withValues(alpha: 0.5)
                : TonicColors.border,
            width: _isPressed ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 28,
              color: _isPressed ? TonicColors.accent : TonicColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Text(
              widget.label,
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                fontWeight: _isPressed ? FontWeight.w600 : FontWeight.w400,
                color: _isPressed ? TonicColors.textPrimary : TonicColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
