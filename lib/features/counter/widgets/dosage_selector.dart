import 'package:flutter/material.dart';
import '../../../shared/constants/enums.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Dosage selector with preset duration options.
/// Uses apothecary terminology (dosage = session duration).
class DosageSelector extends StatelessWidget {
  const DosageSelector({
    super.key,
    required this.selectedMinutes,
    required this.onChanged,
    this.enabled = true,
  });

  /// Currently selected dosage in minutes
  final int selectedMinutes;

  /// Callback when dosage changes
  final ValueChanged<int> onChanged;

  /// Whether the selector is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: TonicTestKeys.counterDosageSelector,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'DOSAGE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TonicColors.textSecondary,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 12),
        // Dosage options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DosageDuration.values.map((duration) {
            final isSelected = duration.minutes == selectedMinutes;
            return _DosageChip(
              label: duration.displayLabel,
              isSelected: isSelected,
              enabled: enabled,
              onTap: () => onChanged(duration.minutes),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DosageChip extends StatelessWidget {
  const _DosageChip({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? TonicColors.accent : TonicColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TonicColors.accent
                : (enabled ? TonicColors.surfaceLight : TonicColors.surface),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? TonicColors.base
                    : (enabled ? TonicColors.textPrimary : TonicColors.textMuted),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
