import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../counter/counter_provider.dart';
import 'onboarding_provider.dart';
import 'prescription_service.dart';
import 'quiz/quiz_screen.dart';
import 'screens/consultation_screen.dart';
import 'screens/differentiation_screen.dart';
import 'screens/welcome_screen.dart';

/// Main onboarding flow controller.
/// Manages navigation between welcome screens and quiz.
class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboarding, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreen(context, onboarding),
        );
      },
    );
  }

  Widget _buildScreen(BuildContext context, OnboardingProvider onboarding) {
    switch (onboarding.currentPage) {
      case 0:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onNext: () => onboarding.nextPage(),
          onSkip: () => _skipOnboarding(context, onboarding),
        );
      case 1:
        return DifferentiationScreen(
          key: const ValueKey('differentiation'),
          onNext: () => onboarding.nextPage(),
          onSkip: () => _skipOnboarding(context, onboarding),
        );
      case 2:
        return ConsultationScreen(
          key: const ValueKey('consultation'),
          onStartQuiz: () => onboarding.nextPage(),
          onSkip: () => _skipOnboarding(context, onboarding),
        );
      default:
        return QuizScreen(
          key: const ValueKey('quiz'),
          onComplete: (prescription) =>
              _completeWithPrescription(context, onboarding, prescription),
          onSkip: () => _skipOnboarding(context, onboarding),
        );
    }
  }

  void _skipOnboarding(BuildContext context, OnboardingProvider onboarding) async {
    await onboarding.skipOnboarding();
    onComplete();
  }

  void _completeWithPrescription(
    BuildContext context,
    OnboardingProvider onboarding,
    Prescription prescription,
  ) async {
    // Apply prescription to playback provider
    final playbackProvider = context.read<PlaybackProvider>();
    final tonic = prescription.recommendedTonic;

    playbackProvider.selectTonic(tonic);
    playbackProvider.setStrength(prescription.recommendedStrength);
    playbackProvider.setDosage(prescription.recommendedDosage);

    await onboarding.completeWithPrescription(prescription);
    onComplete();
  }
}
