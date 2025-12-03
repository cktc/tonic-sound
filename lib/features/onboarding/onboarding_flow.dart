import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/analytics/analytics_service.dart';
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
    final analytics = AnalyticsService.instance;

    switch (onboarding.currentPage) {
      case 0:
        analytics.trackOnboardingScreenViewed('welcome');
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onNext: () => onboarding.nextPage(),
          onSkip: () => _skipOnboarding(context, onboarding, 'welcome'),
        );
      case 1:
        analytics.trackOnboardingScreenViewed('differentiation');
        return DifferentiationScreen(
          key: const ValueKey('differentiation'),
          onNext: () => onboarding.nextPage(),
          onSkip: () => _skipOnboarding(context, onboarding, 'differentiation'),
        );
      case 2:
        analytics.trackOnboardingScreenViewed('consultation');
        return ConsultationScreen(
          key: const ValueKey('consultation'),
          onStartQuiz: () {
            analytics.trackQuizStarted();
            onboarding.nextPage();
          },
          onSkip: () => _skipOnboarding(context, onboarding, 'consultation'),
        );
      default:
        analytics.trackOnboardingScreenViewed('quiz');
        return QuizScreen(
          key: const ValueKey('quiz'),
          onComplete: (prescription) =>
              _completeWithPrescription(context, onboarding, prescription),
          onSkip: () => _skipOnboarding(context, onboarding, 'quiz', quizStarted: true),
        );
    }
  }

  void _skipOnboarding(
    BuildContext context,
    OnboardingProvider onboarding,
    String atScreen, {
    bool quizStarted = false,
  }) async {
    final analytics = AnalyticsService.instance;

    // Track skip event
    analytics.trackOnboardingSkipped(
      atScreen: atScreen,
      quizStarted: quizStarted,
    );
    analytics.trackOnboardingCompleted(method: 'skipped');

    // Update super properties
    analytics.registerSuperProperties(onboardingComplete: true);

    await onboarding.skipOnboarding();
    onComplete();
  }

  void _completeWithPrescription(
    BuildContext context,
    OnboardingProvider onboarding,
    Prescription prescription,
  ) async {
    final analytics = AnalyticsService.instance;

    // Track quiz completion
    analytics.trackQuizCompleted(
      recommendedTonicId: prescription.recommendedTonic.id,
      recommendedStrength: prescription.recommendedStrength,
      recommendedDosageMinutes: prescription.recommendedDosage,
    );

    // Track onboarding completed
    analytics.trackOnboardingCompleted(method: 'quiz_completed');

    // Set user properties based on prescription
    analytics.setUserProperties(
      recommendedTonicId: prescription.recommendedTonic.id,
      recommendedStrength: prescription.recommendedStrength,
      recommendedDosageMinutes: prescription.recommendedDosage,
    );

    // Update super properties
    analytics.registerSuperProperties(onboardingComplete: true);

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
