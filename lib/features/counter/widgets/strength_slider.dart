import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Strength (volume) slider with apothecary styling.
/// Controls the intensity/volume of the sound therapy.
class StrengthSlider extends StatelessWidget {
  const StrengthSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Current strength value (0.0 to 1.0)
  final double value;

  /// Callback when value changes
  final ValueChanged<double> onChanged;

  /// Whether the slider is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: TonicTestKeys.counterStrengthSlider,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STRENGTH',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TonicColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: TonicColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor:
                enabled ? TonicColors.accent : TonicColors.textMuted,
            inactiveTrackColor: TonicColors.surfaceLight,
            thumbColor: enabled ? TonicColors.accent : TonicColors.textMuted,
            overlayColor: TonicColors.accent.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: enabled ? onChanged : null,
          ),
        ),
        // Min/Max labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gentle',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TonicColors.textMuted,
                  ),
            ),
            Text(
              'Potent',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TonicColors.textMuted,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
