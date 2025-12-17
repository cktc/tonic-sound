import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/constants/tonic_catalog.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Elegant apothecary-style botanical card for the Dispensary.
/// Single tap selects the botanical and navigates to Counter.
class BotanicalCard extends StatelessWidget {
  const BotanicalCard({
    super.key,
    required this.botanical,
    required this.isSelected,
    required this.onTap,
  });

  final Botanical botanical;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: TonicTestKeys.dispensaryBotanicalCard,
      onTap: () {
        Haptics.vibrate(HapticsType.success);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isSelected
                  ? botanical.color.withValues(alpha: 0.15)
                  : TonicColors.surfaceLight,
              TonicColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? botanical.color.withValues(alpha: 0.6)
                : TonicColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: botanical.color.withValues(alpha: 0.25),
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
                        ? botanical.color.withValues(alpha: 0.6)
                        : TonicColors.border,
                  ),
                  const SizedBox(height: 12),
                  // Botanical icon with organic styling
                  _buildBotanicalIcon(),
                  const SizedBox(height: 12),
                  // Botanical name
                  Text(
                    botanical.name,
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
                  // Botanical tagline
                  Text(
                    botanical.tagline,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotanicalIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            botanical.color.withValues(alpha: isSelected ? 0.35 : 0.2),
            botanical.color.withValues(alpha: isSelected ? 0.15 : 0.08),
          ],
        ),
        border: Border.all(
          color: botanical.color.withValues(alpha: isSelected ? 0.5 : 0.3),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: botanical.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Icon(
        _getIconForBotanical(botanical.id),
        size: 26,
        color: botanical.color,
      ),
    );
  }

  IconData _getIconForBotanical(String id) {
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
}
