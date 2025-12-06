import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/analytics/analytics_service.dart';
import '../../shared/constants/enums.dart';
import '../../shared/constants/test_keys.dart';
import '../../shared/theme/tonic_colors.dart';
import '../onboarding/onboarding_provider.dart';
import '../onboarding/widgets/quiz_prompt_sheet.dart';
import 'counter_provider.dart';
import 'widgets/strength_slider.dart';
import 'widgets/timer_display.dart';
import 'widgets/tonic_bottle.dart';

/// Main Counter screen - the primary interface for playing tonics.
/// Features elegant Victorian apothecary design with the tonic bottle,
/// strength controls, and dosage selection.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  bool _wasPlaying = false;
  PlaybackProvider? _playbackProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Remove old listener if provider changed
    _playbackProvider?.removeListener(_onPlaybackStateChanged);

    // Add listener to current provider
    _playbackProvider = context.read<PlaybackProvider>();
    _playbackProvider?.addListener(_onPlaybackStateChanged);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    _playbackProvider?.removeListener(_onPlaybackStateChanged);
    super.dispose();
  }

  void _onPlaybackStateChanged() {
    final playback = context.read<PlaybackProvider>();
    final isNowIdle = playback.isIdle;

    // Detect transition from playing/paused to idle
    if (_wasPlaying && isNowIdle) {
      _maybeShowQuizPrompt();
    }

    _wasPlaying = playback.isPlaying || playback.isPaused;
  }

  Future<void> _maybeShowQuizPrompt() async {
    final onboarding = context.read<OnboardingProvider>();

    if (onboarding.shouldShowQuizPrompt) {
      // Track that we're showing the prompt
      AnalyticsService.instance.trackContextualQuizPromptShown();

      // Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final accepted = await QuizPromptSheet.show(context);

      // Track response
      AnalyticsService.instance.trackContextualQuizPromptResponse(
        accepted: accepted ?? false,
      );

      // Mark as shown so we don't show again
      await onboarding.markQuizPromptShown();

      if (accepted == true && mounted) {
        // Navigate to quiz - reset onboarding to go to quiz
        await onboarding.resetOnboarding();
        onboarding.goToQuiz();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.counterScreen,
      backgroundColor: TonicColors.base,
      body: Consumer<PlaybackProvider>(
        builder: (context, playback, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Clean header - just tonic name
                  _buildHeader(context, playback),
                  const SizedBox(height: 32),
                  // Timer display with integrated dosage selector
                  TimerDisplay(
                    remainingTime: playback.isIdle
                        ? _formatDuration(playback.dosageMinutes)
                        : playback.remainingTimeFormatted,
                    progress: playback.progress,
                    isActive: playback.isPlaying || playback.isPaused,
                    selectedMinutes: playback.dosageMinutes,
                    onDosageChanged: (minutes) => playback.setDosage(minutes),
                    enabled: playback.isIdle,
                  ),
                  const SizedBox(height: 32),
                  // Bottle - the sole control
                  // Tap to play/pause, long-press to stop
                  TonicBottle(
                    tonic: playback.soundType == SoundType.tonic
                        ? playback.selectedTonic
                        : null,
                    botanical: playback.soundType == SoundType.botanical
                        ? playback.selectedBotanical
                        : null,
                    isDispensing: playback.isPlaying,
                    isPaused: playback.isPaused,
                    progress: playback.progress,
                    onTap: () => _handleBottleTap(context, playback),
                    onLongPress: (playback.isPlaying || playback.isPaused)
                        ? () => playback.cap()
                        : null,
                  ),
                  const SizedBox(height: 32),
                  // Strength slider - minimal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: StrengthSlider(
                      value: playback.strength,
                      onChanged: (value) => playback.setStrength(value),
                      enabled: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Warning only for high volume
                  if (playback.safetyLevel == SafetyLevel.high && !playback.isPlaying)
                    _buildVolumeWarning(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PlaybackProvider playback) {
    // Clean, minimal header - show tonic or botanical name
    final name = playback.soundType == SoundType.botanical
        ? playback.selectedBotanical?.name ?? ''
        : playback.selectedTonic.name;

    return Text(
      name,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: TonicColors.textPrimary,
        letterSpacing: 2.0,
      ),
    );
  }

  String _formatDuration(int minutes) {
    return '${minutes.toString().padLeft(2, '0')}:00';
  }

  void _handleBottleTap(BuildContext context, PlaybackProvider playback) {
    if (playback.isPlaying) {
      // Tap while playing = pause
      playback.pause();
    } else if (playback.isPaused) {
      // Tap while paused = resume
      playback.resume();
    } else {
      // Tap while idle = dispense (with volume warning check)
      if (playback.safetyLevel == SafetyLevel.high) {
        _showVolumeWarningDialog(context, playback);
      } else {
        playback.dispense();
      }
    }
  }

  void _showVolumeWarningDialog(BuildContext context, PlaybackProvider playback) {
    showDialog(
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
              color: TonicColors.warning.withValues(alpha: 0.4),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TonicColors.warning.withValues(alpha: 0.15),
                  border: Border.all(
                    color: TonicColors.warning.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  size: 28,
                  color: TonicColors.warning,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'High Volume',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: TonicColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'You\'ve selected a high strength level. Extended listening at this volume may cause hearing fatigue. Are you sure you want to continue?',
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TonicColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: TonicColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
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
                      onTap: () {
                        Navigator.of(context).pop();
                        playback.dispense();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TonicColors.warning,
                              TonicColors.warning.withValues(alpha: 0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: TonicColors.warning.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Continue',
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

  Widget _buildVolumeWarning(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TonicColors.warning.withValues(alpha: 0.12),
              TonicColors.warning.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TonicColors.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TonicColors.warning.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: TonicColors.warning,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'High volume selected. Consider lowering for longer sessions.',
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: TonicColors.warning,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
