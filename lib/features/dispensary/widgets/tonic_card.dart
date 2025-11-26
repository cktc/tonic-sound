import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/constants/tonic_catalog.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Card widget for displaying a tonic in the Dispensary.
class TonicCard extends StatelessWidget {
  const TonicCard({
    super.key,
    required this.tonic,
    required this.isSelected,
    required this.onTap,
  });

  final Tonic tonic;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: TonicTestKeys.dispensaryTonicCard,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: TonicColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? tonic.color : TonicColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tonic.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tonic icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: tonic.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop,
                size: 32,
                color: tonic.color,
              ),
            ),
            const SizedBox(height: 12),
            // Tonic name
            Text(
              tonic.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? TonicColors.textPrimary
                        : TonicColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            // Tonic tagline
            Text(
              tonic.tagline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TonicColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            // Selection indicator
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TonicColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SELECTED',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TonicColors.base,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
