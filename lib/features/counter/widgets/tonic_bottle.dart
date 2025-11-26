import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/constants/tonic_catalog.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Interactive tonic bottle widget.
/// Displays the selected tonic with tap-to-dispense functionality.
class TonicBottle extends StatelessWidget {
  const TonicBottle({
    super.key,
    required this.tonic,
    required this.isDispensing,
    required this.onTap,
  });

  final Tonic tonic;
  final bool isDispensing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: TonicTestKeys.counterTonicBottle,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 200,
        height: 260,
        decoration: BoxDecoration(
          color: TonicColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDispensing ? tonic.color : TonicColors.surfaceLight,
            width: isDispensing ? 3 : 1,
          ),
          boxShadow: isDispensing
              ? [
                  BoxShadow(
                    color: tonic.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bottle image placeholder
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: tonic.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tonic.color.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  isDispensing ? Icons.waves : Icons.water_drop,
                  size: 48,
                  color: tonic.color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tonic name
            Text(
              tonic.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: TonicColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            // Tonic tagline
            Text(
              tonic.tagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TonicColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            // Action hint
            Text(
              isDispensing ? 'Tap to cap' : 'Tap to dispense',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TonicColors.accent,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
