import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../../../../shared/theme/tonic_colors.dart';

/// Intro screen shown while sound fades in.
/// Shows "Finding your frequency..." with a pulsing dot.
/// Auto-advances after 2.5 seconds (matching the sound fade-in).
class TuningIntroScreen extends StatefulWidget {
  const TuningIntroScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<TuningIntroScreen> createState() => _TuningIntroScreenState();
}

class _TuningIntroScreenState extends State<TuningIntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();

    // Pulsing animation for the dot
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Haptic when sound becomes audible (~1 second into fade-in)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && !_hasTriggeredHaptic) {
        _hasTriggeredHaptic = true;
        Haptics.vibrate(HapticsType.soft);
      }
    });

    // Auto-advance after 2.5 seconds (sound fully faded in)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TonicColors.base,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing dot
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TonicColors.accent.withValues(alpha: _pulseAnimation.value),
                      boxShadow: [
                        BoxShadow(
                          color: TonicColors.accent.withValues(alpha: _pulseAnimation.value * 0.5),
                          blurRadius: 20 * _pulseAnimation.value,
                          spreadRadius: 4 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Text
              Text(
                'Finding your frequency...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TonicColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
