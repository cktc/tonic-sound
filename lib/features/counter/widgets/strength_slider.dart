import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Recommended strength level - slightly below middle for safe default
const double _recommendedStrength = 0.4;

/// Elegant strength slider with custom track design.
/// Controls the intensity/volume of the sound therapy.
/// Features a recommended level marker and tap-to-reset functionality.
class StrengthSlider extends StatefulWidget {
  const StrengthSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  State<StrengthSlider> createState() => _StrengthSliderState();
}

class _StrengthSliderState extends State<StrengthSlider> {
  bool _isDragging = false;
  Offset? _tapDownPosition;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: TonicTestKeys.counterStrengthSlider,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Custom slider with tap-to-reset
        GestureDetector(
          onTapDown: (details) {
            _tapDownPosition = details.localPosition;
          },
          onTapUp: (details) {
            // Only reset if we didn't drag and tapped near the thumb
            if (!_isDragging && _tapDownPosition != null && widget.enabled) {
              // Check if tap was on the thumb area (within reasonable distance)
              final thumbX = _getThumbPosition(context);
              final tapX = details.localPosition.dx;
              if ((tapX - thumbX).abs() < 24) {
                // Tapped on thumb - reset to recommended
                Vibrate.feedback(FeedbackType.medium);
                widget.onChanged(_recommendedStrength);
              }
            }
            _tapDownPosition = null;
          },
          child: _CustomSliderTrack(
            value: widget.value,
            onChanged: widget.enabled ? (value) {
              _isDragging = true;
              widget.onChanged(value);
            } : null,
            onChangeStart: (_) {
              _isDragging = false;
              Vibrate.feedback(FeedbackType.light);
            },
            onChangeEnd: (_) {
              _isDragging = false;
            },
          ),
        ),
        const SizedBox(height: 8),
        // Evocative endpoint labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gentle',
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: TonicColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Potent',
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: TonicColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getThumbPosition(BuildContext context) {
    // Estimate thumb position based on slider width
    final width = MediaQuery.of(context).size.width - 48 - 16; // padding
    return 8 + (width * widget.value);
  }
}

class _CustomSliderTrack extends StatelessWidget {
  const _CustomSliderTrack({
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: TonicColors.accent,
        inactiveTrackColor: TonicColors.surfaceLight,
        thumbColor: TonicColors.accentLight,
        overlayColor: TonicColors.accent.withValues(alpha: 0.12),
        thumbShape: const _CustomThumbShape(),
        trackShape: const _CustomTrackShape(),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      child: Slider(
        value: value,
        min: 0.0,
        max: 1.0,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  const _CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer glow
    final glowPaint = Paint()
      ..color = TonicColors.accent.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, 10, glowPaint);

    // Main thumb
    final thumbPaint = Paint()
      ..color = TonicColors.accentLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, thumbPaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = TonicColors.cream.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(-2, -2), 3, highlightPaint);

    // Border
    final borderPaint = Paint()
      ..color = TonicColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 8, borderPaint);
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  const _CustomTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final canvas = context.canvas;
    final trackHeight = sliderTheme.trackHeight ?? 6;
    final trackLeft = offset.dx + 8;
    final trackRight = offset.dx + parentBox.size.width - 8;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = trackRight - trackLeft;

    // Inactive track (background)
    final inactiveRect = RRect.fromLTRBR(
      trackLeft,
      trackTop,
      trackRight,
      trackTop + trackHeight,
      const Radius.circular(3),
    );
    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? TonicColors.surfaceLight;
    canvas.drawRRect(inactiveRect, inactivePaint);

    // Recommended level marker - subtle vertical line
    final recommendedX = trackLeft + (trackWidth * _recommendedStrength);
    final markerPaint = Paint()
      ..color = TonicColors.textMuted.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(recommendedX, trackTop - 2),
      Offset(recommendedX, trackTop + trackHeight + 2),
      markerPaint,
    );

    // Active track with gradient
    final activeRect = RRect.fromLTRBR(
      trackLeft,
      trackTop,
      thumbCenter.dx,
      trackTop + trackHeight,
      const Radius.circular(3),
    );
    final activeGradient = LinearGradient(
      colors: [
        TonicColors.accentDark,
        TonicColors.accent,
      ],
    );
    final activePaint = Paint()
      ..shader = activeGradient.createShader(
        Rect.fromLTRB(trackLeft, trackTop, trackRight, trackTop + trackHeight),
      );
    canvas.drawRRect(activeRect, activePaint);
  }
}
