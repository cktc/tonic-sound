import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/constants/tonic_catalog.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Elegant apothecary-style bottle widget for both Tonics and Botanicals.
/// Features glass-like effects and progress border when dispensing.
/// The bottle is the sole control - tap to play/pause, long-press to stop.
class TonicBottle extends StatefulWidget {
  const TonicBottle({
    super.key,
    this.tonic,
    this.botanical,
    required this.isDispensing,
    required this.onTap,
    this.isPaused = false,
    this.onLongPress,
    this.progress = 0.0,
  }) : assert(tonic != null || botanical != null,
            'Either tonic or botanical must be provided');

  final Tonic? tonic;
  final Botanical? botanical;
  final bool isDispensing;
  final bool isPaused;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double progress;

  /// Get the display name
  String get name => tonic?.name ?? botanical?.name ?? '';

  /// Get the tagline
  String get tagline => tonic?.tagline ?? botanical?.tagline ?? '';

  /// Get the color
  Color get color => tonic?.color ?? botanical?.color ?? TonicColors.accent;

  /// Whether this is a botanical
  bool get isBotanical => botanical != null;

  @override
  State<TonicBottle> createState() => _TonicBottleState();
}

class _TonicBottleState extends State<TonicBottle>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _sparkController;
  late Animation<double> _sparkAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Spark pulse animation - faster for that alchemical energy feel
    _sparkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sparkAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _sparkController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(TonicBottle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDispensing && !oldWidget.isDispensing) {
      _glowController.repeat(reverse: true);
      _sparkController.repeat(reverse: true);
    } else if (!widget.isDispensing && oldWidget.isDispensing) {
      _glowController.stop();
      _glowController.reset();
      _sparkController.stop();
      _sparkController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The bottle itself
        GestureDetector(
          key: TonicTestKeys.counterTonicBottle,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: widget.isDispensing
                      ? [
                          BoxShadow(
                            color: widget.color
                                .withValues(alpha: _glowAnimation.value * 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: child,
              );
            },
            child: Stack(
              children: [
                _buildBottleContent(),
                // Progress border overlay when dispensing - Alchemical Spark effect
                if (widget.isDispensing)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_sparkAnimation]),
                      builder: (context, child) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: widget.progress),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return CustomPaint(
                              painter: _AlchemicalSparkPainter(
                                progress: value,
                                color: widget.color,
                                borderRadius: 24,
                                strokeWidth: 3,
                                sparkIntensity: _sparkAnimation.value,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Subtle hint below the bottle
        const SizedBox(height: 16),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.sourceSans3(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
            color: TonicColors.textMuted,
          ),
          child: Text(
            _getBottleLabel(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottleContent() {
    return Stack(
      children: [
        // Background with gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TonicColors.surfaceLight,
                  TonicColors.surface,
                ],
              ),
              border: Border.all(
                color: widget.isDispensing
                    ? widget.color.withValues(alpha: 0.2)
                    : TonicColors.border,
                width: 1,
              ),
            ),
          ),
        ),
        // Glass highlight effect
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TonicColors.glassHighlight,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildBottleIcon(),
                const SizedBox(height: 16),
                _buildLabel(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottleIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            widget.color.withValues(alpha: 0.3),
            widget.color.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            _getBottleIcon(),
            key: ValueKey('${widget.isDispensing}_${widget.isBotanical}'),
            size: 40,
            color: widget.color,
          ),
        ),
      ),
    );
  }

  IconData _getBottleIcon() {
    if (widget.isBotanical) {
      // Use nature-themed icons for botanicals
      final id = widget.botanical?.id ?? '';
      switch (id) {
        case 'rain':
          return Icons.water_drop_rounded;
        case 'ocean':
          return Icons.waves_rounded;
        case 'wind':
          return Icons.air_rounded;
        default:
          return Icons.eco_rounded;
      }
    }
    // Tonic icon (water drop for noise generators)
    return Icons.water_drop_rounded;
  }

  Widget _buildLabel() {
    return Text(
      widget.tagline,
      textAlign: TextAlign.center,
      style: GoogleFonts.sourceSans3(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: TonicColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Returns the appropriate label based on playback state
  String _getBottleLabel() {
    if (widget.isPaused) {
      return 'paused · hold to reset';
    } else if (widget.isDispensing) {
      return 'tap to pause';
    } else {
      return 'tap to dispense';
    }
  }
}

/// Alchemical Spark painter - draws an enchanted progress border with:
/// - Soft outer glow halo
/// - Bright core stroke in tonic color
/// - Pulsing spark/bloom at the leading edge
class _AlchemicalSparkPainter extends CustomPainter {
  _AlchemicalSparkPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
    required this.strokeWidth,
    required this.sparkIntensity,
  });

  final double progress;
  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double sparkIntensity; // 0.0 to 1.0, for pulsing effect

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final rect = Rect.fromLTWH(
      strokeWidth * 2,
      strokeWidth * 2,
      size.width - strokeWidth * 4,
      size.height - strokeWidth * 4,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Create the full path
    final fullPath = Path()..addRRect(rrect);
    final pathMetrics = fullPath.computeMetrics().first;
    final totalLength = pathMetrics.length;

    // Calculate offset to start from top-center (12 o'clock position)
    // Flutter's addRRect starts at the TOP of the LEFT edge and goes clockwise
    // Through experimentation: using (totalLength - arc - halfTopEdge) lands at
    // bottom-center. To get to top-center, we use half that distance.
    const pi = 3.14159265359;
    final arcLength = (pi / 2) * borderRadius; // quarter circle arc
    final topEdgeWidth = size.width - strokeWidth * 4 - 2 * borderRadius;
    final halfPerimeter = totalLength / 2;
    final startOffset = halfPerimeter - arcLength - (topEdgeWidth / 2);

    // Calculate the progress length
    final progressLength = totalLength * progress;

    // Extract path starting from top-center, wrapping around if needed
    final endOffset = startOffset + progressLength;
    Path extractedPath;
    if (endOffset <= totalLength) {
      // Simple case: doesn't wrap around
      extractedPath = pathMetrics.extractPath(startOffset, endOffset);
    } else {
      // Wraps around: extract from start to end, then from 0 to remainder
      extractedPath = pathMetrics.extractPath(startOffset, totalLength);
      extractedPath.addPath(
        pathMetrics.extractPath(0, endOffset - totalLength),
        Offset.zero,
      );
    }

    // Layer 1: Outer glow (wide, blurred, faint)
    final outerGlowPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * sparkIntensity)
      ..strokeWidth = strokeWidth * 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(extractedPath, outerGlowPaint);

    // Layer 2: Middle glow (medium width, softer)
    final middleGlowPaint = Paint()
      ..color = color.withValues(alpha: 0.5 * sparkIntensity)
      ..strokeWidth = strokeWidth * 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(extractedPath, middleGlowPaint);

    // Layer 3: Bright core stroke
    final corePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(extractedPath, corePaint);

    // Layer 4: Inner bright highlight (thin, white-ish)
    final highlightPaint = Paint()
      ..color = Color.lerp(color, Colors.white, 0.6)!.withValues(alpha: 0.8)
      ..strokeWidth = strokeWidth * 0.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(extractedPath, highlightPaint);

    // Layer 5: Traveling spark at the leading edge
    if (progressLength > 0) {
      // Calculate spark position at the end of progress (from top-center start)
      var sparkOffset = startOffset + progressLength;
      if (sparkOffset > totalLength) {
        sparkOffset = sparkOffset - totalLength;
      }
      final tangent = pathMetrics.getTangentForOffset(sparkOffset);
      if (tangent != null) {
        final sparkPosition = tangent.position;

        // Spark outer bloom
        final sparkBloomPaint = Paint()
          ..color = color.withValues(alpha: 0.6 * sparkIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(
          sparkPosition,
          8 + (4 * sparkIntensity),
          sparkBloomPaint,
        );

        // Spark middle glow
        final sparkGlowPaint = Paint()
          ..color = color.withValues(alpha: 0.8 * sparkIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(
          sparkPosition,
          5 + (2 * sparkIntensity),
          sparkGlowPaint,
        );

        // Spark bright core
        final sparkCorePaint = Paint()
          ..color = Color.lerp(color, Colors.white, 0.5 + (0.3 * sparkIntensity))!;
        canvas.drawCircle(sparkPosition, 3, sparkCorePaint);

        // Spark center highlight (pure white dot)
        final sparkCenterPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.9 * sparkIntensity);
        canvas.drawCircle(sparkPosition, 1.5, sparkCenterPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_AlchemicalSparkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.sparkIntensity != sparkIntensity;
  }
}
