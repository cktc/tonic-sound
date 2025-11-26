import 'package:audio_service/audio_service.dart';

/// Audio handler for background playback integration with audio_service package.
/// Manages media controls, notifications, and system audio session.
///
/// This handler connects to the OS media controls (lock screen, notification,
/// Control Center on iOS) and forwards commands to the Tonic audio service.
class TonicAudioHandler extends BaseAudioHandler with SeekHandler {
  TonicAudioHandler() {
    // Set up initial playback state
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.pause,
        MediaAction.stop,
      },
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  /// Callback for when Tonic playback starts
  /// Call this from TonicAudioService when dispensing begins
  void onPlaybackStarted({
    required String title,
    required String subtitle,
    Duration? duration,
  }) {
    // Update media item (shown in notifications/lock screen)
    mediaItem.add(MediaItem(
      id: 'tonic_playback',
      title: title,
      artist: 'Tonic',
      album: subtitle,
      duration: duration,
      artUri: null, // TODO: Add artwork URI
    ));

    // Update playback state to playing
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.pause,
        MediaAction.stop,
      },
      processingState: AudioProcessingState.ready,
      playing: true,
      updatePosition: Duration.zero,
      bufferedPosition: duration ?? Duration.zero,
    ));
  }

  /// Callback for when playback pauses
  void onPlaybackPaused() {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.stop,
      },
      playing: false,
    ));
  }

  /// Callback for when playback resumes
  void onPlaybackResumed() {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.pause,
        MediaAction.stop,
      },
      playing: true,
    ));
  }

  /// Callback for when playback stops
  void onPlaybackStopped() {
    playbackState.add(PlaybackState(
      controls: [],
      systemActions: const {},
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    mediaItem.add(null);
  }

  /// Callback to update position (for timer display on lock screen)
  void updatePosition(Duration position) {
    playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
    ));
  }

  // MediaControl callbacks - these will be wired to TonicAudioService

  /// Called when user taps play on lock screen/notification
  /// Override in TonicAudioService wrapper to handle
  Function? onPlayPressed;

  /// Called when user taps pause on lock screen/notification
  Function? onPausePressed;

  /// Called when user taps stop on lock screen/notification
  Function? onStopPressed;

  @override
  Future<void> play() async {
    onPlayPressed?.call();
  }

  @override
  Future<void> pause() async {
    onPausePressed?.call();
  }

  @override
  Future<void> stop() async {
    onStopPressed?.call();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    // Tonic doesn't support seeking (timer-based playback)
  }
}
