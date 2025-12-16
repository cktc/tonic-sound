import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/constants/tonic_catalog.dart';
import '../../../../shared/theme/tonic_colors.dart';

/// Step 2: Sound comparison
/// "Tap each to compare"
/// User can tap between Bright, Balanced, Deep to hear the difference.
class SoundComparisonScreen extends StatefulWidget {
  const SoundComparisonScreen({
    super.key,
    required this.currentSound,
    required this.onSoundTapped,
    required this.onConfirmed,
  });

  final Tonic currentSound;
  final void Function(Tonic tonic) onSoundTapped;
  final void Function(Tonic tonic) onConfirmed;

  @override
  State<SoundComparisonScreen> createState() => _SoundComparisonScreenState();
}

class _SoundComparisonScreenState extends State<SoundComparisonScreen> {
  late Tonic _selectedSound;

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.currentSound;
  }

  void _onSoundTapped(Tonic tonic) {
    setState(() {
      _selectedSound = tonic;
    });
    widget.onSoundTapped(tonic);
  }

  @override
  Widget build(BuildContext context) {
    final bright = Tonic.byId('bright')!;
    final rest = Tonic.byId('rest')!;
    final focus = Tonic.byId('focus')!;

    return Scaffold(
      backgroundColor: TonicColors.base,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Title
              Text(
                'Tap each to compare',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: TonicColors.textPrimary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Sound cards row
              Row(
                children: [
                  Expanded(
                    child: _SoundTypeCard(
                      tonic: bright,
                      label: 'Bright',
                      sublabel: 'crisp',
                      isSelected: _selectedSound.id == 'bright',
                      onTap: () => _onSoundTapped(bright),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SoundTypeCard(
                      tonic: rest,
                      label: 'Balanced',
                      sublabel: 'warm',
                      isSelected: _selectedSound.id == 'rest',
                      onTap: () => _onSoundTapped(rest),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SoundTypeCard(
                      tonic: focus,
                      label: 'Deep',
                      sublabel: 'rumble',
                      isSelected: _selectedSound.id == 'focus',
                      onTap: () => _onSoundTapped(focus),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Currently playing indicator
              Center(
                child: Text(
                  'currently playing',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: TonicColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Confirm button
              ElevatedButton(
                onPressed: () => widget.onConfirmed(_selectedSound),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(
                  'This one',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual sound type card for comparison
class _SoundTypeCard extends StatelessWidget {
  const _SoundTypeCard({
    required this.tonic,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  final Tonic tonic;
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? tonic.color.withValues(alpha: 0.15)
              : TonicColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? tonic.color.withValues(alpha: 0.6)
                : TonicColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tonic.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? tonic.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? tonic.color : TonicColors.textMuted,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Label
            Text(
              label,
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? TonicColors.textPrimary : TonicColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            // Sublabel
            Text(
              sublabel,
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: TonicColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
