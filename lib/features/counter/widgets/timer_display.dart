import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/constants/enums.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Interactive timer display with integrated dosage selector.
/// Tapping the timer reveals duration options in an elegant inline picker.
/// Features pendulum-swing animations on digit changes for a clockwork feel.
class TimerDisplay extends StatefulWidget {
  const TimerDisplay({
    super.key,
    required this.remainingTime,
    required this.progress,
    required this.isActive,
    required this.selectedMinutes,
    required this.onDosageChanged,
    this.enabled = true,
  });

  final String remainingTime;
  final double progress;
  final bool isActive;
  final int selectedMinutes;
  final ValueChanged<int> onDosageChanged;
  final bool enabled;

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Collapse when playback starts
    if (widget.isActive && !oldWidget.isActive && _isExpanded) {
      _collapse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.isActive || !widget.enabled) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _collapse() {
    setState(() {
      _isExpanded = false;
      _animationController.reverse();
    });
  }

  void _selectDuration(int minutes) {
    widget.onDosageChanged(minutes);
    // Small delay before collapsing for visual feedback
    Future.delayed(const Duration(milliseconds: 150), _collapse);
  }

  @override
  Widget build(BuildContext context) {
    final canInteract = !widget.isActive && widget.enabled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tappable timer
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            key: TonicTestKeys.counterTimerDisplay,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated timer digits with pendulum effect
                _AnimatedTimeDisplay(
                  time: widget.remainingTime,
                  isActive: widget.isActive,
                ),
                // Tap indicator (subtle chevron)
                if (canInteract) ...[
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: TonicColors.textMuted.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Expandable dosage selector
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: _buildDosagePills(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDosagePills() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: DosageDuration.values.map((duration) {
        final isSelected = duration.minutes == widget.selectedMinutes;
        final isLast = duration == DosageDuration.values.last;

        return Padding(
          padding: EdgeInsets.only(right: isLast ? 0 : 8),
          child: _DosagePill(
            label: _getCompactLabel(duration),
            isSelected: isSelected,
            onTap: () => _selectDuration(duration.minutes),
          ),
        );
      }).toList(),
    );
  }

  /// Returns a more compact label for the pills
  String _getCompactLabel(DosageDuration duration) {
    switch (duration) {
      case DosageDuration.quick:
        return '15m';
      case DosageDuration.standard:
        return '30m';
      case DosageDuration.extended:
        return '1h';
      case DosageDuration.full:
        return '2h';
      case DosageDuration.overnight:
        return '8h';
    }
  }
}

/// Individual dosage pill with elegant styling
class _DosagePill extends StatelessWidget {
  const _DosagePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TonicColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? TonicColors.accentLight
                : TonicColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TonicColors.accent.withValues(alpha: 0.25),
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
            letterSpacing: 0.3,
            color: isSelected ? TonicColors.base : TonicColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Displays time string with animated pendulum transitions on digit changes.
class _AnimatedTimeDisplay extends StatelessWidget {
  const _AnimatedTimeDisplay({
    required this.time,
    required this.isActive,
  });

  final String time;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final characters = time.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: characters.asMap().entries.map((entry) {
        final index = entry.key;
        final char = entry.value;

        // Colons don't animate - just display them statically
        if (char == ':') {
          return Text(
            ':',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 48,
              fontWeight: FontWeight.w400,
              color: isActive ? TonicColors.textPrimary : TonicColors.textMuted,
              letterSpacing: 3,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          );
        }

        return _PendulumDigit(
          key: ValueKey('digit_$index'),
          digit: char,
          isActive: isActive,
        );
      }).toList(),
    );
  }
}

/// A single digit that animates with a pendulum swing when its value changes.
class _PendulumDigit extends StatefulWidget {
  const _PendulumDigit({
    super.key,
    required this.digit,
    required this.isActive,
  });

  final String digit;
  final bool isActive;

  @override
  State<_PendulumDigit> createState() => _PendulumDigitState();
}

class _PendulumDigitState extends State<_PendulumDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityOutAnimation;
  late Animation<double> _opacityInAnimation;

  String _currentDigit = '';
  String _previousDigit = '';

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _previousDigit = widget.digit;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Pendulum swing: starts tilted, swings through center, slight overshoot, settles
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.03)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.03, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    // Old digit fades out quickly
    _opacityOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // New digit fades in
    _opacityInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void didUpdateWidget(_PendulumDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit) {
      _previousDigit = oldWidget.digit;
      _currentDigit = widget.digit;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.cormorantGaramond(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: widget.isActive ? TonicColors.textPrimary : TonicColors.textMuted,
      letterSpacing: 3,
      fontFeatures: [const FontFeature.tabularFigures()],
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          // Fixed width to prevent layout shifts
          width: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Previous digit (swinging out)
              if (_controller.isAnimating)
                Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002) // Perspective
                    ..rotateX(_rotationAnimation.value * math.pi * 0.5),
                  child: Opacity(
                    opacity: _opacityOutAnimation.value,
                    child: Text(_previousDigit, style: textStyle),
                  ),
                ),
              // Current digit (swinging in)
              Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // Perspective
                  ..rotateX(_controller.isAnimating
                      ? (-0.15 + _rotationAnimation.value) * math.pi * 0.5
                      : 0.0),
                child: Opacity(
                  opacity:
                      _controller.isAnimating ? _opacityInAnimation.value : 1.0,
                  child: Text(_currentDigit, style: textStyle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
