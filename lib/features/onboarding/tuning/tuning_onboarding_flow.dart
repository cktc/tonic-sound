import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../shared/constants/tonic_catalog.dart';
import '../../counter/counter_provider.dart';
import '../onboarding_provider.dart';
import 'screens/tuning_intro_screen.dart';
import 'screens/goal_selection_screen.dart';
import 'screens/sound_comparison_screen.dart';
import 'screens/volume_check_screen.dart';
import 'screens/tuning_transition_screen.dart';

/// User's goal selection from step 1
enum TuningGoal {
  sleep,
  focus,
  unwind,
}

/// Tuning onboarding state
class TuningState {
  const TuningState({
    this.goal,
    this.selectedSound,
    this.strength = 0.4,
    this.dosageMinutes = 30,
    this.soundSamplesCount = 0,
    this.volumeAdjustmentsCount = 0,
  });

  final TuningGoal? goal;
  final Tonic? selectedSound;
  final double strength;
  final int dosageMinutes;
  final int soundSamplesCount;
  final int volumeAdjustmentsCount;

  TuningState copyWith({
    TuningGoal? goal,
    Tonic? selectedSound,
    double? strength,
    int? dosageMinutes,
    int? soundSamplesCount,
    int? volumeAdjustmentsCount,
  }) {
    return TuningState(
      goal: goal ?? this.goal,
      selectedSound: selectedSound ?? this.selectedSound,
      strength: strength ?? this.strength,
      dosageMinutes: dosageMinutes ?? this.dosageMinutes,
      soundSamplesCount: soundSamplesCount ?? this.soundSamplesCount,
      volumeAdjustmentsCount: volumeAdjustmentsCount ?? this.volumeAdjustmentsCount,
    );
  }

  /// Get default dosage based on goal
  static int dosageForGoal(TuningGoal goal) {
    switch (goal) {
      case TuningGoal.sleep:
        return 480; // 8 hours
      case TuningGoal.focus:
        return 60; // 1 hour
      case TuningGoal.unwind:
        return 30; // 30 min
    }
  }

  /// Get initial sound based on goal
  static Tonic soundForGoal(TuningGoal goal) {
    switch (goal) {
      case TuningGoal.sleep:
        return Tonic.byId('rest')!; // Pink noise for sleep
      case TuningGoal.focus:
        return Tonic.byId('bright')!; // White noise for focus
      case TuningGoal.unwind:
        return Tonic.byId('focus')!; // Brown noise for relaxation
    }
  }
}

/// Sound-first onboarding flow.
/// Sound plays immediately. Questions tune it in real-time.
class TuningOnboardingFlow extends StatefulWidget {
  const TuningOnboardingFlow({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<TuningOnboardingFlow> createState() => _TuningOnboardingFlowState();
}

class _TuningOnboardingFlowState extends State<TuningOnboardingFlow> {
  int _currentStep = 0;
  TuningState _state = const TuningState();
  DateTime? _startTime;
  bool _soundStarted = false;

  final AnalyticsService _analytics = AnalyticsService.instance;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Start sound after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_soundStarted && mounted) {
        _soundStarted = true;
        _startInitialSound();
      }
    });
  }

  /// Start playing pink noise immediately at 40%
  Future<void> _startInitialSound() async {
    if (!mounted) return;

    try {
      final playback = context.read<PlaybackProvider>();

      // Select pink noise (Rest) as initial sound
      final initialTonic = Tonic.byId('rest')!;
      playback.selectTonic(initialTonic);
      playback.setStrength(0.4);
      playback.setDosage(480); // Long duration for preview

      // Start playback
      await playback.dispense();

      // Track tuning started
      _analytics.track('tuning_started', {
        'initial_sound': 'rest',
        'initial_strength': 0.4,
      });
    } catch (e) {
      debugPrint('[TuningOnboarding] Error starting sound: $e');
    }
  }

  /// Handle goal selection (Step 1)
  void _onGoalSelected(TuningGoal goal) {
    final playback = context.read<PlaybackProvider>();

    // Get sound and dosage for this goal
    final tonic = TuningState.soundForGoal(goal);
    final dosage = TuningState.dosageForGoal(goal);

    // Crossfade to the new sound
    playback.selectTonic(tonic);

    // Haptic feedback
    Haptics.vibrate(HapticsType.medium);

    // Update state
    setState(() {
      _state = _state.copyWith(
        goal: goal,
        selectedSound: tonic,
        dosageMinutes: dosage,
      );
    });

    // Track
    _analytics.track('tuning_goal_selected', {
      'goal': goal.name,
      'sound_after': tonic.id,
      'dosage_after': dosage,
      'time_to_select': DateTime.now().difference(_startTime!).inSeconds,
    });

    // Auto-advance after brief delay to let user hear the change
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _currentStep = 2);
      }
    });
  }

  /// Handle sound comparison tap (Step 2)
  void _onSoundSampled(Tonic tonic) {
    final playback = context.read<PlaybackProvider>();

    // Crossfade to the sampled sound
    playback.selectTonic(tonic);

    // Haptic feedback
    Haptics.vibrate(HapticsType.light);

    // Update state
    setState(() {
      _state = _state.copyWith(
        selectedSound: tonic,
        soundSamplesCount: _state.soundSamplesCount + 1,
      );
    });

    // Track
    _analytics.track('tuning_sound_sampled', {
      'sound_type': tonic.id,
      'sample_number': _state.soundSamplesCount + 1,
    });
  }

  /// Handle sound confirmed (Step 2 complete)
  void _onSoundConfirmed(Tonic tonic) {
    // Haptic feedback
    Haptics.vibrate(HapticsType.medium);

    // Update state with the confirmed sound
    setState(() {
      _state = _state.copyWith(selectedSound: tonic);
    });

    // Track
    _analytics.track('tuning_sound_confirmed', {
      'final_sound': tonic.id,
      'samples_before_confirm': _state.soundSamplesCount,
    });

    // Advance to volume check
    setState(() => _currentStep = 3);
  }

  /// Handle volume adjustment (Step 3)
  void _onVolumeAdjusted(double newStrength) {
    final playback = context.read<PlaybackProvider>();

    // Apply the new strength
    playback.setStrength(newStrength);

    // Haptic feedback
    Haptics.vibrate(HapticsType.light);

    // Update state
    setState(() {
      _state = _state.copyWith(
        strength: newStrength,
        volumeAdjustmentsCount: _state.volumeAdjustmentsCount + 1,
      );
    });

    // Track
    _analytics.track('tuning_volume_adjusted', {
      'direction': newStrength > _state.strength ? 'up' : 'down',
      'new_strength': newStrength,
      'adjustment_count': _state.volumeAdjustmentsCount + 1,
    });
  }

  /// Handle volume confirmed (Step 3 complete)
  void _onVolumeConfirmed(double finalStrength) {
    // Haptic feedback
    Haptics.vibrate(HapticsType.success);

    // Update state
    setState(() {
      _state = _state.copyWith(strength: finalStrength);
    });

    // Track
    _analytics.track('tuning_volume_confirmed', {
      'final_strength': finalStrength,
      'adjustments_made': _state.volumeAdjustmentsCount,
    });

    // Advance to transition
    setState(() => _currentStep = 4);
  }

  /// Handle skip
  void _onSkip() {
    final playback = context.read<PlaybackProvider>();

    // Track skip
    _analytics.track('tuning_skipped', {
      'at_step': _currentStep,
      'time_before_skip': DateTime.now().difference(_startTime!).inSeconds,
    });

    // Apply defaults: Pink, 40%, 30min
    final defaultTonic = Tonic.byId('rest')!;
    playback.selectTonic(defaultTonic);
    playback.setStrength(0.4);
    playback.setDosage(30);

    // Cap current preview and restart with correct settings
    playback.cap();
    playback.dispense();

    // Complete onboarding
    _completeOnboarding();
  }

  /// Complete the tuning flow
  void _onTransitionComplete() {
    final playback = context.read<PlaybackProvider>();

    // Apply final settings
    final finalTonic = _state.selectedSound ?? Tonic.byId('rest')!;
    final finalStrength = _state.strength;
    final finalDosage = _state.dosageMinutes;

    playback.selectTonic(finalTonic);
    playback.setStrength(finalStrength);
    playback.setDosage(finalDosage);

    // Cap preview session and start real session
    playback.cap();
    playback.dispense();

    // Track completion
    final totalDuration = DateTime.now().difference(_startTime!).inSeconds;
    _analytics.track('tuning_completed', {
      'total_duration': totalDuration,
      'final_sound': finalTonic.id,
      'final_strength': finalStrength,
      'final_dosage': finalDosage,
      'goal': _state.goal?.name ?? 'none',
    });

    // Haptic feedback
    Haptics.vibrate(HapticsType.success);

    // Complete onboarding
    _completeOnboarding();
  }

  /// Mark onboarding complete and transition to main app
  Future<void> _completeOnboarding() async {
    final onboarding = context.read<OnboardingProvider>();

    // Update analytics
    _analytics.trackOnboardingCompleted(method: 'tuning_completed');
    _analytics.registerSuperProperties(onboardingComplete: true);

    // Mark complete in storage
    await onboarding.completeOnboarding();

    // Notify parent
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Intro: "Finding your frequency..."
        return TuningIntroScreen(
          key: const ValueKey('intro'),
          onComplete: () => setState(() => _currentStep = 1),
        );
      case 1:
        // Step 1: Goal selection
        return GoalSelectionScreen(
          key: const ValueKey('goal'),
          onGoalSelected: _onGoalSelected,
          onSkip: _onSkip,
        );
      case 2:
        // Step 2: Sound comparison
        return SoundComparisonScreen(
          key: const ValueKey('sound'),
          currentSound: _state.selectedSound ?? Tonic.byId('rest')!,
          onSoundTapped: _onSoundSampled,
          onConfirmed: _onSoundConfirmed,
        );
      case 3:
        // Step 3: Volume check
        return VolumeCheckScreen(
          key: const ValueKey('volume'),
          currentStrength: _state.strength,
          onAdjusted: _onVolumeAdjusted,
          onConfirmed: _onVolumeConfirmed,
        );
      case 4:
        // Transition: "You're all set"
        return TuningTransitionScreen(
          key: const ValueKey('transition'),
          onComplete: _onTransitionComplete,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
