import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/test_keys.dart';
import '../../shared/providers/preferences_provider.dart';
import '../../shared/theme/tonic_colors.dart';
import '../onboarding/onboarding_provider.dart';

/// Lab Notes screen - elegant apothecary-style settings and information.
/// Features Victorian design elements and refined interactions.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.settingsScreen,
      backgroundColor: TonicColors.base,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            // Elegant header
            _buildHeader(context),
            const SizedBox(height: 28),
            // About section
            _SectionHeader(title: 'ABOUT TONIC'),
            const SizedBox(height: 12),
            _buildAboutCard(context),
            const SizedBox(height: 28),
            // Actions section
            _SectionHeader(title: 'APOTHECARY ACTIONS'),
            const SizedBox(height: 12),
            Consumer2<PreferencesProvider, OnboardingProvider>(
              builder: (context, prefs, onboarding, child) {
                return Column(
                  children: [
                    _ActionTile(
                      icon: Icons.auto_fix_high_rounded,
                      title: 'Retake Consultation',
                      subtitle: 'Answer the quiz again for a new prescription',
                      onTap: () async {
                        final confirm = await _showConfirmDialog(
                          context,
                          'Retake Consultation',
                          'This will reset your quiz responses and show the onboarding flow again.',
                        );
                        if (confirm == true) {
                          await onboarding.resetOnboarding();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/',
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.delete_sweep_rounded,
                      title: 'Reset All Data',
                      subtitle: 'Clear all saved preferences and sessions',
                      isDestructive: true,
                      onTap: () async {
                        final confirm = await _showConfirmDialog(
                          context,
                          'Reset All Data',
                          'This will delete all your preferences, quiz responses, and listening history. This cannot be undone.',
                        );
                        if (confirm == true) {
                          await prefs.resetPreferences();
                          await onboarding.resetOnboarding();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'All data has been reset',
                                  style: GoogleFonts.sourceSans3(
                                    color: TonicColors.textPrimary,
                                  ),
                                ),
                                backgroundColor: TonicColors.surface,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            // Philosophy section
            _SectionHeader(title: 'OUR PHILOSOPHY'),
            const SizedBox(height: 12),
            _buildPhilosophyCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Decorative ornament
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 1,
              color: TonicColors.accent.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TonicColors.accent.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 1,
              color: TonicColors.accent.withValues(alpha: 0.4),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Title
        Text(
          'Lab Notes',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: TonicColors.textPrimary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle
        Text(
          'Formulary & Configurations',
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: TonicColors.textMuted,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TonicColors.surfaceLight,
            TonicColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TonicColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // App icon area
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  TonicColors.accent.withValues(alpha: 0.25),
                  TonicColors.accent.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: TonicColors.accent.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              size: 28,
              color: TonicColors.accent,
            ),
          ),
          const SizedBox(height: 14),
          // App name
          Text(
            'Tonic',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: TonicColors.textPrimary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sound Therapy for Sleep & Focus',
            style: GoogleFonts.sourceSans3(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: TonicColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          Container(
            width: 60,
            height: 1,
            color: TonicColors.border,
          ),
          const SizedBox(height: 16),
          // Version info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoPill(label: 'Version', value: '1.0.0'),
              const SizedBox(width: 12),
              _InfoPill(label: 'Build', value: '2024.1'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TonicColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TonicColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Quote icon
          Icon(
            Icons.format_quote_rounded,
            size: 24,
            color: TonicColors.accent.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Tonic uses real-time noise generation algorithms to create unique '
            'soundscapes for each listening session. No two sessions are exactly alike, '
            'much like the natural world that inspires our sonic remedies.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: TonicColors.textSecondary,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          // Signature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 1,
                color: TonicColors.accent.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 10),
              Text(
                'The Apothecary',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TonicColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 20,
                height: 1,
                color: TonicColors.accent.withValues(alpha: 0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                TonicColors.surfaceLight,
                TonicColors.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: TonicColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TonicColors.warning.withValues(alpha: 0.15),
                  border: Border.all(
                    color: TonicColors.warning.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 24,
                  color: TonicColors.warning,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: TonicColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TonicColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: TonicColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TonicColors.border,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TonicColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: TonicColors.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TonicColors.base,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 1,
          color: TonicColors.accent.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.sourceSans3(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            color: TonicColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: TonicColors.border.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: TonicColors.base.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TonicColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.sourceSans3(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: TonicColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.sourceSans3(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TonicColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? TonicColors.warning : TonicColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TonicColors.surfaceLight,
              TonicColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TonicColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: TonicColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: TonicColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: TonicColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
