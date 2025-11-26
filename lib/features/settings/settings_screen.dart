import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/test_keys.dart';
import '../../shared/providers/preferences_provider.dart';
import '../../shared/theme/tonic_colors.dart';
import '../onboarding/onboarding_provider.dart';

/// Settings screen (Lab Notes) - app configuration and information.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.settingsScreen,
      backgroundColor: TonicColors.base,
      appBar: AppBar(
        backgroundColor: TonicColors.base,
        elevation: 0,
        title: Text(
          'Lab Notes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App info section
          _SectionHeader(title: 'ABOUT TONIC'),
          const SizedBox(height: 8),
          _InfoTile(
            title: 'Version',
            value: '1.0.0',
          ),
          _InfoTile(
            title: 'App',
            value: 'Sound Therapy for Sleep & Focus',
          ),
          const SizedBox(height: 32),
          // Actions section
          _SectionHeader(title: 'ACTIONS'),
          const SizedBox(height: 8),
          Consumer2<PreferencesProvider, OnboardingProvider>(
            builder: (context, prefs, onboarding, child) {
              return Column(
                children: [
                  _ActionTile(
                    icon: Icons.refresh,
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
                          // Navigate to onboarding
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                  _ActionTile(
                    icon: Icons.delete_outline,
                    title: 'Reset All Data',
                    subtitle: 'Clear all saved preferences and sessions',
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
                            const SnackBar(
                              content: Text('All data has been reset'),
                              backgroundColor: TonicColors.surface,
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
          const SizedBox(height: 32),
          // Credits
          _SectionHeader(title: 'CREDITS'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TonicColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tonic uses real-time noise generation algorithms to create unique '
              'soundscapes for each listening session. No two sessions are exactly alike.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TonicColors.textSecondary,
                  ),
            ),
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
      builder: (context) => AlertDialog(
        backgroundColor: TonicColors.surface,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TonicColors.textPrimary,
              ),
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TonicColors.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TonicColors.warning,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: TonicColors.textMuted,
            letterSpacing: 1.5,
          ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TonicColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TonicColors.textPrimary,
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TonicColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TonicColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: TonicColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: TonicColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TonicColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: TonicColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
