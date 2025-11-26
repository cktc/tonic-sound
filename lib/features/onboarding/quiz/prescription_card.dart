import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';
import '../prescription_service.dart';

/// Prescription result card displayed after quiz completion.
/// Shows the recommended tonic with reasoning.
class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({
    super.key,
    required this.prescription,
  });

  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    final tonic = prescription.recommendedTonic;

    return Container(
      key: TonicTestKeys.quizPrescriptionCard,
      decoration: BoxDecoration(
        color: TonicColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TonicColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with tonic color
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: tonic.color.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Tonic icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: tonic.color.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop,
                    size: 40,
                    color: tonic.color,
                  ),
                ),
                const SizedBox(height: 16),
                // Prescription label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: TonicColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'PRESCRIBED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: TonicColors.base,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tonic name
                Text(
                  tonic.name,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: TonicColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  tonic.tagline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TonicColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Details section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reasoning
                Text(
                  prescription.reasoning,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TonicColors.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),
                // Recommended settings
                Text(
                  'RECOMMENDED SETTINGS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TonicColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSettingChip(
                      context,
                      Icons.volume_up,
                      '${(prescription.recommendedStrength * 100).round()}%',
                      'Strength',
                    ),
                    const SizedBox(width: 12),
                    _buildSettingChip(
                      context,
                      Icons.schedule,
                      '${prescription.recommendedDosage}min',
                      'Dosage',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TonicColors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: TonicColors.accent,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TonicColors.textPrimary,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TonicColors.textMuted,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
