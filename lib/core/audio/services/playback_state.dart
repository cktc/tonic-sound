import '../../storage/models/playback_session.dart';
import '../../../shared/constants/enums.dart';
import '../../../shared/constants/tonic_catalog.dart';

/// Current state of audio playback.
/// Immutable class representing the complete playback state at a point in time.
class PlaybackState {
  const PlaybackState({
    this.status = PlaybackStatus.idle,
    this.currentTonic,
    this.currentBotanical,
    this.strength = 0.5,
    this.dosageMinutes = 30,
    this.remainingSeconds = 0,
    this.safetyLevel = SafetyLevel.safe,
    this.isFadingOut = false,
  });

  /// Current playback status
  final PlaybackStatus status;

  /// Currently playing Tonic (null if playing Botanical or idle)
  final Tonic? currentTonic;

  /// Currently playing Botanical (null if playing Tonic or idle)
  final Botanical? currentBotanical;

  /// Current volume strength (0.0 to 1.0)
  final double strength;

  /// Total dosage duration in minutes
  final int dosageMinutes;

  /// Remaining time in seconds
  final int remainingSeconds;

  /// Current safety level based on strength
  final SafetyLevel safetyLevel;

  /// Whether currently in fade-out period (last 5 minutes)
  final bool isFadingOut;

  /// Whether any sound is currently active
  bool get isPlaying => status == PlaybackStatus.dispensing;

  /// Whether playback is paused
  bool get isPaused => status == PlaybackStatus.paused;

  /// Whether idle (no sound playing)
  bool get isIdle => status == PlaybackStatus.idle;

  /// Whether a Tonic is playing
  bool get isPlayingTonic => currentTonic != null && isPlaying;

  /// Whether a Botanical is playing
  bool get isPlayingBotanical => currentBotanical != null && isPlaying;

  /// Formatted remaining time string (MM:SS)
  String get remainingTimeFormatted {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Progress percentage (0.0 to 1.0)
  double get progress {
    if (dosageMinutes == 0) return 0.0;
    final totalSeconds = dosageMinutes * 60;
    final elapsedSeconds = totalSeconds - remainingSeconds;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// Create a copy with updated fields
  PlaybackState copyWith({
    PlaybackStatus? status,
    Tonic? currentTonic,
    Botanical? currentBotanical,
    double? strength,
    int? dosageMinutes,
    int? remainingSeconds,
    SafetyLevel? safetyLevel,
    bool? isFadingOut,
    bool clearTonic = false,
    bool clearBotanical = false,
  }) {
    return PlaybackState(
      status: status ?? this.status,
      currentTonic: clearTonic ? null : (currentTonic ?? this.currentTonic),
      currentBotanical:
          clearBotanical ? null : (currentBotanical ?? this.currentBotanical),
      strength: strength ?? this.strength,
      dosageMinutes: dosageMinutes ?? this.dosageMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      safetyLevel: safetyLevel ?? this.safetyLevel,
      isFadingOut: isFadingOut ?? this.isFadingOut,
    );
  }

  /// Create initial idle state
  static const PlaybackState initial = PlaybackState();

  /// Convert to PlaybackSession for recording
  PlaybackSession toSession({
    required DateTime startTime,
    required DateTime endTime,
    required bool completedFullDosage,
  }) {
    final soundId = currentTonic?.id ?? currentBotanical?.id ?? 'unknown';
    final soundType = currentTonic != null ? 'tonic' : 'botanical';
    final durationMinutes = endTime.difference(startTime).inMinutes;

    return PlaybackSession(
      soundId: soundId,
      soundType: soundType,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      strength: strength,
      completedFullDosage: completedFullDosage,
    );
  }

  @override
  String toString() {
    return 'PlaybackState(status: $status, tonic: ${currentTonic?.id}, botanical: ${currentBotanical?.id}, strength: $strength, remaining: $remainingSeconds)';
  }
}
