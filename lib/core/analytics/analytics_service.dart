import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../../shared/constants/enums.dart';

/// Centralized analytics service for Mixpanel tracking.
/// Tracks key user behaviors throughout the app lifecycle.
class AnalyticsService {
  AnalyticsService._();

  static AnalyticsService? _instance;
  static Mixpanel? _mixpanel;

  /// Singleton instance
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }

  /// Mixpanel project token
  static const String _projectToken = '6034ae71ef33911b0306007351b008e1';

  /// Whether analytics is initialized
  bool get isInitialized => _mixpanel != null;

  /// Initialize Mixpanel SDK
  Future<void> initialize() async {
    try {
      _mixpanel = await Mixpanel.init(
        _projectToken,
        trackAutomaticEvents: true,
      );
      debugPrint('[AnalyticsService] Mixpanel initialized');
    } catch (e) {
      debugPrint('[AnalyticsService] Failed to initialize Mixpanel: $e');
    }
  }

  /// Track a custom event with optional properties
  void track(String eventName, [Map<String, dynamic>? properties]) {
    if (_mixpanel == null) {
      debugPrint('[AnalyticsService] Mixpanel not initialized, skipping: $eventName');
      return;
    }
    try {
      _mixpanel!.track(eventName, properties: properties);
      debugPrint('[AnalyticsService] Tracked: $eventName');
    } catch (e) {
      debugPrint('[AnalyticsService] Failed to track $eventName: $e');
    }
  }

  /// Start timing an event (call track with same name to complete)
  void timeEvent(String eventName) {
    _mixpanel?.timeEvent(eventName);
  }

  /// Flush events to Mixpanel immediately
  void flush() {
    _mixpanel?.flush();
  }

  // ============================================================
  // App Lifecycle Events
  // ============================================================

  /// Track app opened
  void trackAppOpened({
    required String version,
    required bool isFirstLaunch,
    required bool onboardingComplete,
  }) {
    track('app_opened', {
      'version': version,
      'is_first_launch': isFirstLaunch,
      'onboarding_complete': onboardingComplete,
    });
  }

  // ============================================================
  // Onboarding Events
  // ============================================================

  /// Track onboarding started
  void trackOnboardingStarted({String source = 'app_launch'}) {
    timeEvent('onboarding_flow');
    track('onboarding_started', {'source': source});
  }

  /// Track onboarding screen viewed
  void trackOnboardingScreenViewed(String screenName) {
    track('onboarding_screen_viewed', {'screen_name': screenName});
  }

  /// Track quiz started
  void trackQuizStarted() {
    timeEvent('quiz_completion');
    track('quiz_started');
  }

  /// Track quiz question answered
  void trackQuizQuestionAnswered({
    required int questionNumber,
    required String questionId,
    required int selectedOptionIndex,
  }) {
    track('quiz_question_answered', {
      'question_number': questionNumber,
      'question_id': questionId,
      'selected_option_index': selectedOptionIndex,
    });
  }

  /// Track quiz completed with prescription
  void trackQuizCompleted({
    required String recommendedTonicId,
    required double recommendedStrength,
    required int recommendedDosageMinutes,
  }) {
    track('quiz_completed', {
      'recommended_tonic_id': recommendedTonicId,
      'recommended_strength': recommendedStrength,
      'recommended_dosage_minutes': recommendedDosageMinutes,
    });
  }

  /// Track onboarding skipped
  void trackOnboardingSkipped({
    required String atScreen,
    required bool quizStarted,
  }) {
    track('onboarding_skipped', {
      'at_screen': atScreen,
      'quiz_started': quizStarted,
    });
  }

  /// Track onboarding completed
  void trackOnboardingCompleted({required String method}) {
    track('onboarding_completed', {'method': method});
    track('onboarding_flow'); // Ends the timed event
  }

  // ============================================================
  // Playback Events
  // ============================================================

  /// Track playback started
  void trackPlaybackStarted({
    required String soundId,
    required SoundType soundType,
    required int dosageMinutes,
    required double strength,
  }) {
    timeEvent('playback_session');
    track('playback_started', {
      'sound_id': soundId,
      'sound_type': soundType.name,
      'dosage_minutes': dosageMinutes,
      'strength': strength,
      'safety_level': _getSafetyLevelName(strength),
    });
  }

  /// Track playback paused
  void trackPlaybackPaused({
    required String soundId,
    required double elapsedMinutes,
  }) {
    track('playback_paused', {
      'sound_id': soundId,
      'elapsed_minutes': elapsedMinutes,
    });
  }

  /// Track playback resumed
  void trackPlaybackResumed({
    required String soundId,
    required double elapsedMinutes,
  }) {
    track('playback_resumed', {
      'sound_id': soundId,
      'elapsed_minutes': elapsedMinutes,
    });
  }

  /// Track playback stopped (capped)
  void trackPlaybackStopped({
    required String soundId,
    required SoundType soundType,
    required double elapsedMinutes,
    required int intendedDosageMinutes,
    required bool completedDosage,
    required String stopReason,
  }) {
    track('playback_stopped', {
      'sound_id': soundId,
      'sound_type': soundType.name,
      'elapsed_minutes': elapsedMinutes,
      'intended_dosage_minutes': intendedDosageMinutes,
      'completed_dosage': completedDosage,
      'stop_reason': stopReason,
    });
    track('playback_session'); // Ends the timed event
  }

  // ============================================================
  // Sound Selection Events
  // ============================================================

  /// Track sound browsed (card tapped in dispensary)
  void trackSoundBrowsed({
    required String soundId,
    required SoundType soundType,
    required String soundName,
  }) {
    track('sound_browsed', {
      'sound_id': soundId,
      'sound_type': soundType.name,
      'sound_name': soundName,
    });
  }

  /// Track sound selected (Use This Remedy button)
  void trackSoundSelected({
    required String soundId,
    required SoundType soundType,
    required String soundName,
    String? previousSoundId,
  }) {
    track('sound_selected', {
      'sound_id': soundId,
      'sound_type': soundType.name,
      'sound_name': soundName,
      'previous_sound_id': previousSoundId,
    });
  }

  /// Track tab switched in dispensary
  void trackDispensaryTabSwitched({
    required int fromTabIndex,
    required int toTabIndex,
  }) {
    track('dispensary_tab_switched', {
      'from_tab': fromTabIndex == 0 ? 'tonics' : 'botanicals',
      'to_tab': toTabIndex == 0 ? 'tonics' : 'botanicals',
    });
  }

  // ============================================================
  // Settings & Control Events
  // ============================================================

  /// Track strength/volume adjusted
  void trackStrengthAdjusted({
    required double newStrength,
    required double previousStrength,
    required String source,
  }) {
    track('strength_adjusted', {
      'new_strength': newStrength,
      'previous_strength': previousStrength,
      'source': source,
      'safety_level': _getSafetyLevelName(newStrength),
    });
  }

  /// Track dosage changed
  void trackDosageChanged({
    required int newDosageMinutes,
    required int previousDosageMinutes,
  }) {
    track('dosage_changed', {
      'new_dosage_minutes': newDosageMinutes,
      'previous_dosage_minutes': previousDosageMinutes,
    });
  }

  /// Track high volume warning shown
  void trackVolumeWarningShown({required double strengthLevel}) {
    track('volume_warning_shown', {
      'strength_level': strengthLevel,
    });
  }

  /// Track high volume warning response
  void trackVolumeWarningResponse({required bool continued}) {
    track('volume_warning_response', {
      'action': continued ? 'continued' : 'cancelled',
    });
  }

  // ============================================================
  // Navigation Events
  // ============================================================

  /// Track bottom navigation tap
  void trackBottomNavTapped({
    required int fromTabIndex,
    required int toTabIndex,
    required bool wasPlaying,
  }) {
    track('bottom_nav_tapped', {
      'from_tab': _getTabName(fromTabIndex),
      'to_tab': _getTabName(toTabIndex),
      'was_playing': wasPlaying,
    });
  }

  // ============================================================
  // Settings Actions
  // ============================================================

  /// Track settings action triggered
  void trackSettingsAction({
    required String action,
    required bool confirmed,
  }) {
    track('settings_action', {
      'action': action,
      'confirmed': confirmed,
    });
  }

  // ============================================================
  // User Properties
  // ============================================================

  /// Set user properties after onboarding
  void setUserProperties({
    String? recommendedTonicId,
    double? recommendedStrength,
    int? recommendedDosageMinutes,
  }) {
    if (_mixpanel == null) return;

    final people = _mixpanel!.getPeople();
    if (recommendedTonicId != null) {
      people.set('recommended_tonic', recommendedTonicId);
    }
    if (recommendedStrength != null) {
      people.set('recommended_strength', recommendedStrength);
    }
    if (recommendedDosageMinutes != null) {
      people.set('recommended_dosage_minutes', recommendedDosageMinutes);
    }
    people.set('last_seen', DateTime.now().toIso8601String());
  }

  /// Register super properties that persist across all events
  void registerSuperProperties({
    bool? onboardingComplete,
    String? preferredSoundType,
  }) {
    if (_mixpanel == null) return;

    final props = <String, dynamic>{};
    if (onboardingComplete != null) {
      props['onboarding_complete'] = onboardingComplete;
    }
    if (preferredSoundType != null) {
      props['preferred_sound_type'] = preferredSoundType;
    }
    if (props.isNotEmpty) {
      _mixpanel!.registerSuperProperties(props);
    }
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  String _getSafetyLevelName(double strength) {
    if (strength <= 0.6) return 'safe';
    if (strength <= 0.8) return 'moderate';
    return 'high';
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'counter';
      case 1:
        return 'dispensary';
      case 2:
        return 'settings';
      default:
        return 'unknown';
    }
  }
}
