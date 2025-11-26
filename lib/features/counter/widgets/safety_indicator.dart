import 'package:flutter/material.dart';
import '../../../shared/constants/enums.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Safety indicator showing volume level safety status.
/// Displays green (safe), amber (moderate), or red (high) based on strength.
class SafetyIndicator extends StatelessWidget {
  const SafetyIndicator({
    super.key,
    required this.safetyLevel,
    this.showLabel = true,
  });

  final SafetyLevel safetyLevel;
  final bool showLabel;

  Color get _color {
    switch (safetyLevel) {
      case SafetyLevel.safe:
        return TonicColors.safe;
      case SafetyLevel.moderate:
        return TonicColors.moderate;
      case SafetyLevel.high:
        return TonicColors.warning;
    }
  }

  String get _label {
    switch (safetyLevel) {
      case SafetyLevel.safe:
        return 'Safe for extended listening';
      case SafetyLevel.moderate:
        return 'Moderate - use with awareness';
      case SafetyLevel.high:
        return 'High - may cause hearing fatigue';
    }
  }

  IconData get _icon {
    switch (safetyLevel) {
      case SafetyLevel.safe:
        return Icons.check_circle;
      case SafetyLevel.moderate:
        return Icons.info;
      case SafetyLevel.high:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: TonicTestKeys.counterSafetyIndicator,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 18,
            color: _color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _color,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
