import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Welcome screen - first onboarding slide.
/// Introduces the app with an apothecary-themed welcome.
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
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  key: TonicTestKeys.onboardingSkipButton,
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: TonicColors.textMuted,
                        ),
                  ),
                ),
              ),
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
              const SizedBox(height: 48),
              // Title
              Text(
                'Welcome to Tonic',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Your personal sound apothecary for sleep and focus',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TonicColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // Next button
              ElevatedButton(
                key: TonicTestKeys.onboardingNextButton,
                onPressed: onNext,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Begin'),
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
