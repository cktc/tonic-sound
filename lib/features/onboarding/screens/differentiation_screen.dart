import 'package:flutter/material.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';

/// Differentiation screen - explains what makes Tonic unique.
/// Second onboarding slide highlighting key features.
class DifferentiationScreen extends StatelessWidget {
  const DifferentiationScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.onboardingDifferentiation,
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
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: TonicColors.textMuted,
                        ),
                  ),
                ),
              ),
              const Spacer(),
              // Title
              Text(
                'Sound Therapy,\nReimagined',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Features
              _buildFeature(
                context,
                Icons.auto_awesome,
                'Real-Time Generation',
                'Unique noise patterns created fresh each session',
              ),
              const SizedBox(height: 24),
              _buildFeature(
                context,
                Icons.bedtime,
                'Background Playback',
                'Sound continues even when your device is locked',
              ),
              const SizedBox(height: 24),
              _buildFeature(
                context,
                Icons.psychology,
                'Personalized Prescription',
                'Take a quick consultation to find your ideal tonic',
              ),
              const Spacer(flex: 2),
              // Next button
              ElevatedButton(
                onPressed: onNext,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: TonicColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: TonicColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TonicColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
