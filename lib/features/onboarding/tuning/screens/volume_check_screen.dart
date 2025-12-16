import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/tonic_colors.dart';

/// Step 3: Volume check
/// "How's this volume?"
/// User can tap to adjust, then confirm when it feels right.
class VolumeCheckScreen extends StatelessWidget {
  const VolumeCheckScreen({
    super.key,
    required this.currentStrength,
    required this.onAdjusted,
    required this.onConfirmed,
  });

  final double currentStrength;
  final void Function(double newStrength) onAdjusted;
  final void Function(double finalStrength) onConfirmed;

  void _adjustVolume(String direction) {
    double newStrength;
    if (direction == 'up') {
      // Increase by 15%, max 80%
      newStrength = (currentStrength + 0.15).clamp(0.1, 0.8);
    } else {
      // Decrease by 12%, min 15%
      newStrength = (currentStrength - 0.12).clamp(0.15, 0.8);
    }
    onAdjusted(newStrength);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TonicColors.base,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Title
              Text(
                'How\'s this volume?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: TonicColors.textPrimary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Volume options
              _VolumeOptionCard(
                icon: Icons.volume_down_rounded,
                label: 'Too quiet',
                onTap: () => _adjustVolume('up'),
              ),
              const SizedBox(height: 16),
              _VolumeOptionCard(
                icon: Icons.check_rounded,
                label: 'Just right',
                isConfirm: true,
                onTap: () => onConfirmed(currentStrength),
              ),
              const SizedBox(height: 16),
              _VolumeOptionCard(
                icon: Icons.volume_up_rounded,
                label: 'Too loud',
                onTap: () => _adjustVolume('down'),
              ),
              const SizedBox(height: 24),
              // Current level indicator
              Center(
                child: Text(
                  'Current: ${(currentStrength * 100).round()}%',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: TonicColors.textMuted,
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual volume option card
class _VolumeOptionCard extends StatefulWidget {
  const _VolumeOptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isConfirm = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isConfirm;

  @override
  State<_VolumeOptionCard> createState() => _VolumeOptionCardState();
}

class _VolumeOptionCardState extends State<_VolumeOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isConfirm ? TonicColors.accent : TonicColors.textSecondary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.isConfirm
                  ? TonicColors.accent.withValues(alpha: 0.2)
                  : TonicColors.surfaceLight)
              : TonicColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed
                ? (widget.isConfirm
                    ? TonicColors.accent.withValues(alpha: 0.5)
                    : TonicColors.textMuted.withValues(alpha: 0.5))
                : (widget.isConfirm
                    ? TonicColors.accent.withValues(alpha: 0.3)
                    : TonicColors.border),
            width: widget.isConfirm ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: _isPressed || widget.isConfirm ? baseColor : TonicColors.textMuted,
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                fontWeight: widget.isConfirm ? FontWeight.w600 : FontWeight.w400,
                color: _isPressed || widget.isConfirm
                    ? (widget.isConfirm ? TonicColors.accent : TonicColors.textPrimary)
                    : TonicColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
