import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/enums.dart';
import '../../shared/constants/test_keys.dart';
import '../../shared/theme/tonic_colors.dart';
import 'counter_provider.dart';
import 'widgets/dosage_selector.dart';
import 'widgets/safety_indicator.dart';
import 'widgets/strength_slider.dart';
import 'widgets/timer_display.dart';
import 'widgets/tonic_bottle.dart';

/// Main Counter screen - the primary interface for playing tonics.
/// Displays the selected tonic bottle with tap-to-dispense functionality,
/// along with strength and dosage controls.
class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.counterScreen,
      backgroundColor: TonicColors.base,
      appBar: AppBar(
        backgroundColor: TonicColors.base,
        elevation: 0,
        title: Text(
          'Tonic',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Consumer<PlaybackProvider>(
        builder: (context, playback, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Timer display
                  TimerDisplay(
                    remainingTime: playback.isIdle
                        ? _formatDuration(playback.dosageMinutes)
                        : playback.remainingTimeFormatted,
                    progress: playback.progress,
                    isActive: playback.isPlaying || playback.isPaused,
                  ),
                  const SizedBox(height: 16),
                  // Tonic bottle
                  TonicBottle(
                    tonic: playback.selectedTonic,
                    isDispensing: playback.isPlaying,
                    onTap: () => _handleBottleTap(context, playback),
                  ),
                  const SizedBox(height: 16),
                  // Safety indicator
                  SafetyIndicator(
                    safetyLevel: playback.safetyLevel,
                  ),
                  const SizedBox(height: 16),
                  // Strength slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StrengthSlider(
                      value: playback.strength,
                      onChanged: (value) => playback.setStrength(value),
                      enabled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dosage selector
                  DosageSelector(
                    selectedMinutes: playback.dosageMinutes,
                    onChanged: (minutes) => playback.setDosage(minutes),
                    enabled: playback.isIdle,
                  ),
                  const SizedBox(height: 16),
                  // Playback controls (when active)
                  if (playback.isPlaying || playback.isPaused)
                    _buildPlaybackControls(context, playback),
                  // Status text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _getStatusText(playback),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TonicColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Warning dialog trigger for high volume
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

  String _formatDuration(int minutes) {
    return '${minutes.toString().padLeft(2, '0')}:00';
  }

  String _getStatusText(PlaybackProvider playback) {
    if (playback.isPlaying) {
      return 'Your ${playback.selectedTonic.name} tonic is dispensing. '
          'Tap the bottle to cap it.';
    } else if (playback.isPaused) {
      return 'Playback paused. Tap play to resume.';
    } else {
      return 'Tap the bottle to begin your ${playback.selectedTonic.name} '
          'sound therapy session.';
    }
  }

  void _handleBottleTap(BuildContext context, PlaybackProvider playback) {
    if (playback.isPlaying) {
      playback.cap();
    } else if (playback.isPaused) {
      playback.resume();
    } else {
      // Check for high volume warning before dispensing
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
      builder: (context) => AlertDialog(
        backgroundColor: TonicColors.surface,
        title: Row(
          children: [
            const Icon(Icons.warning, color: TonicColors.warning),
            const SizedBox(width: 8),
            Text(
              'High Volume',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: TonicColors.textPrimary,
                  ),
            ),
          ],
        ),
        content: Text(
          'You\'ve selected a high strength level. Extended listening at this '
          'volume may cause hearing fatigue. Are you sure you want to continue?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TonicColors.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              playback.dispense();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TonicColors.warning,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeWarning(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TonicColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TonicColors.warning.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber,
              color: TonicColors.warning,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'High volume selected. Consider lowering for longer sessions.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TonicColors.warning,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(
    BuildContext context,
    PlaybackProvider playback,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play/Pause button
        IconButton(
          icon: Icon(
            playback.isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 56,
            color: TonicColors.accent,
          ),
          onPressed: () {
            if (playback.isPlaying) {
              playback.pause();
            } else {
              playback.resume();
            }
          },
        ),
        const SizedBox(width: 24),
        // Stop button
        IconButton(
          key: TonicTestKeys.counterCapButton,
          icon: const Icon(
            Icons.stop_circle,
            size: 56,
            color: TonicColors.textSecondary,
          ),
          onPressed: () => playback.cap(),
        ),
      ],
    );
  }
}
