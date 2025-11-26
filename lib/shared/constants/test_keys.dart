import 'package:flutter/foundation.dart';

/// Semantic test keys for E2E testing.
/// Keys follow the pattern: screen_widget_variant
/// Use these keys with [Key] widget parameter for reliable test element selection.
class TonicTestKeys {
  TonicTestKeys._();

  // Counter Screen
  static const counterScreen = Key('counter_screen');
  static const counterTonicBottle = Key('counter_tonic_bottle');
  static const counterTimerDisplay = Key('counter_timer_display');
  static const counterStrengthSlider = Key('counter_strength_slider');
  static const counterSafetyIndicator = Key('counter_safety_indicator');
  static const counterDosageSelector = Key('counter_dosage_selector');
  static const counterDispenseButton = Key('counter_dispense_button');
  static const counterCapButton = Key('counter_cap_button');

  // Dispensary Screen
  static const dispensaryScreen = Key('dispensary_screen');
  static const dispensaryTonicGrid = Key('dispensary_tonic_grid');
  static const dispensaryBotanicalGrid = Key('dispensary_botanical_grid');
  static const dispensaryTonicCard = Key('dispensary_tonic_card');
  static const dispensaryBotanicalCard = Key('dispensary_botanical_card');

  // Onboarding Screens
  static const onboardingWelcome = Key('onboarding_welcome');
  static const onboardingDifferentiation = Key('onboarding_differentiation');
  static const onboardingConsultation = Key('onboarding_consultation');
  static const onboardingSkipButton = Key('onboarding_skip_button');
  static const onboardingNextButton = Key('onboarding_next_button');

  // Quiz Screen
  static const quizScreen = Key('quiz_screen');
  static const quizQuestion = Key('quiz_question');
  static const quizOption = Key('quiz_option');
  static const quizProgressIndicator = Key('quiz_progress_indicator');
  static const quizPrescriptionCard = Key('quiz_prescription_card');

  // Settings Screen
  static const settingsScreen = Key('settings_screen');

  // Navigation
  static const navCounter = Key('nav_counter');
  static const navDispensary = Key('nav_dispensary');
  static const navSettings = Key('nav_settings');

  /// Creates a unique key for indexed items (e.g., quiz options, tonic cards)
  static Key indexed(String base, int index) => Key('${base}_$index');
}
