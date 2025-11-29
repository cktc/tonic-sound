import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/constants/tonic_catalog.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Elegant apothecary-style tonic card for the Dispensary.
/// Features glass-like effects and refined Victorian aesthetics.
class TonicCard extends StatelessWidget {
  const TonicCard({
    super.key,
    required this.tonic,
    required this.isSelected,
    required this.onTap,
  });

  final Tonic tonic;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: TonicTestKeys.dispensaryTonicCard,
      onTap: () {
        Haptics.vibrate(HapticsType.selection);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isSelected
                  ? tonic.color.withValues(alpha: 0.15)
                  : TonicColors.surfaceLight,
              TonicColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? tonic.color.withValues(alpha: 0.6)
                : TonicColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tonic.color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glass highlight effect
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Decorative top line
                  Container(
                    width: 24,
                    height: 1,
                    color: isSelected
                        ? tonic.color.withValues(alpha: 0.6)
                        : TonicColors.border,
                  ),
                  const SizedBox(height: 12),
                  // Tonic icon with glow
                  _buildTonicIcon(),
                  const SizedBox(height: 12),
                  // Tonic name
                  Text(
                    tonic.name,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? TonicColors.textPrimary
                          : TonicColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tonic tagline
                  Text(
                    tonic.tagline,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: TonicColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Selection indicator
                  _buildSelectionIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTonicIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            tonic.color.withValues(alpha: isSelected ? 0.35 : 0.2),
            tonic.color.withValues(alpha: isSelected ? 0.15 : 0.08),
          ],
        ),
        border: Border.all(
          color: tonic.color.withValues(alpha: isSelected ? 0.5 : 0.3),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: tonic.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.water_drop_rounded,
        size: 26,
        color: tonic.color,
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 20,
      padding: EdgeInsets.symmetric(
        horizontal: isSelected ? 10 : 0,
        vertical: isSelected ? 3 : 0,
      ),
      decoration: BoxDecoration(
        color: isSelected ? TonicColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(
                color: TonicColors.accentLight.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isSelected ? 1.0 : 0.0,
        child: Text(
          'SELECTED',
          style: GoogleFonts.sourceSans3(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: TonicColors.base,
          ),
        ),
      ),
    );
  }
}
