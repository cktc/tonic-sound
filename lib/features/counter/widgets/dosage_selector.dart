import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/constants/enums.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Elegant dosage selector with refined pill buttons.
/// Uses apothecary terminology (dosage = session duration).
class DosageSelector extends StatelessWidget {
  const DosageSelector({
    super.key,
    required this.selectedMinutes,
    required this.onChanged,
    this.enabled = true,
  });

  final int selectedMinutes;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: TonicTestKeys.counterDosageSelector,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Simple label
        Text(
          'DOSAGE',
          style: GoogleFonts.sourceSans3(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            color: TonicColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        // Dosage options in a centered layout
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
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
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? TonicColors.accent
              : TonicColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? TonicColors.accentLight
                : TonicColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TonicColors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.5,
            color: isSelected
                ? TonicColors.base
                : (enabled ? TonicColors.textPrimary : TonicColors.textMuted),
          ),
        ),
      ),
    );
  }
}
