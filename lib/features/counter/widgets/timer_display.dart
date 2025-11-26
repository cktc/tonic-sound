import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Timer display widget showing remaining playback time.
/// Shows countdown in MM:SS format with optional progress indicator.
class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.remainingTime,
    required this.progress,
    required this.isActive,
  });

  /// Formatted remaining time string (e.g., "29:45")
  final String remainingTime;

  /// Progress percentage (0.0 to 1.0)
  final double progress;

  /// Whether playback is currently active
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: TonicTestKeys.counterTimerDisplay,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress ring with time display
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  backgroundColor: TonicColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    TonicColors.surfaceLight,
                  ),
                ),
              ),
              // Progress indicator
              if (isActive)
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      TonicColors.accent,
                    ),
                  ),
                ),
              // Time text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    remainingTime,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: isActive
                              ? TonicColors.textPrimary
                              : TonicColors.textMuted,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                  if (isActive)
                    Text(
                      'remaining',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: TonicColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
