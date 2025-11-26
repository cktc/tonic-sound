import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/constants/tonic_catalog.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Card widget for displaying a botanical in the Dispensary.
class BotanicalCard extends StatelessWidget {
  const BotanicalCard({
    super.key,
    required this.botanical,
    required this.isSelected,
    required this.onTap,
  });

  final Botanical botanical;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: TonicTestKeys.dispensaryBotanicalCard,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: TonicColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? botanical.color : TonicColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: botanical.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botanical icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: botanical.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForBotanical(botanical.id),
                size: 32,
                color: botanical.color,
              ),
            ),
            const SizedBox(height: 12),
            // Botanical name
            Text(
              botanical.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? TonicColors.textPrimary
                        : TonicColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            // Botanical tagline
            Text(
              botanical.tagline,
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

  IconData _getIconForBotanical(String id) {
    switch (id) {
      case 'rain':
        return Icons.water;
      case 'ocean':
        return Icons.waves;
      case 'forest':
        return Icons.forest;
      default:
        return Icons.nature;
    }
  }
}
