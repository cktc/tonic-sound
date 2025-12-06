import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Welcome screen - streamlined v2 onboarding.
/// Single screen with quiz CTA and skip option.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.onboardingWelcome,
      backgroundColor: TonicColors.base,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top spacing for balance
              const SizedBox(height: 16),
              const Spacer(flex: 2),
              // Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: TonicColors.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_pharmacy,
                    size: 64,
                    color: TonicColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                'Welcome to Tonic',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Your personal sound apothecary',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TonicColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Time estimate chip
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: TonicColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: TonicColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '3 quick questions • 30 seconds',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TonicColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Primary CTA - Get prescription
              ElevatedButton(
                key: TonicTestKeys.onboardingNextButton,
                onPressed: onNext,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Get My Prescription'),
                ),
              ),
              const SizedBox(height: 12),
              // Secondary CTA - Skip
              TextButton(
                key: TonicTestKeys.onboardingSkipButton,
                onPressed: onSkip,
                child: Text(
                  'Skip & Explore',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: TonicColors.textMuted,
                      ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
