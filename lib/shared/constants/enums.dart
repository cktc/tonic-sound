/// Types of generated noise for Tonics.
/// Each type has distinct frequency characteristics suitable for different use cases.
enum NoiseType {
  /// Equal energy across all frequencies. Sharp, hissy sound.
  /// Best for: masking sudden noises, tinnitus relief
  white,

  /// Energy decreases at higher frequencies (-3dB per octave).
  /// Sounds more balanced and natural than white noise.
  /// Best for: sleep, concentration, general masking
  pink,

  /// Energy concentrated in low frequencies (-6dB per octave).
  /// Deep, rumbling sound like distant thunder.
  /// Best for: deep relaxation, meditation, blocking low-frequency noise
  brown,
}

/// Types of sounds available in the app.
/// Tonics are generated; Botanicals are pre-recorded.
enum SoundType {
  /// Real-time generated noise (white, pink, brown)
  tonic,

  /// Pre-recorded ambient sounds (rain, ocean, forest)
  botanical,
}

/// Current playback state of the audio service.
enum PlaybackStatus {
  /// No sound is playing, ready to dispense
  idle,

  /// Sound is currently playing
  dispensing,

  /// Sound is paused (can be resumed)
  paused,

  /// Fading out before stopping (last 5 minutes of dosage)
  fadingOut,
}

/// Volume safety levels based on listening guidelines.
/// Thresholds: safe <= 0.6, moderate <= 0.8, high > 0.8
enum SafetyLevel {
  /// Volume at or below 60% - safe for extended listening
  safe,

  /// Volume between 60-80% - moderate, use with awareness
  moderate,

  /// Volume above 80% - high, may cause hearing fatigue
  high,
}

/// Preset dosage durations in minutes.
/// Uses apothecary terminology (dose = duration of sound therapy).
enum DosageDuration {
  /// 15 minutes - quick session
  quick(15),

  /// 30 minutes - standard session
  standard(30),

  /// 60 minutes - extended session
  extended(60),

  /// 120 minutes - full treatment
  full(120),

  /// 480 minutes (8 hours) - overnight
  overnight(480);

  const DosageDuration(this.minutes);

  final int minutes;

  String get displayLabel {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hr';
      }
      return '$hours hr $remainingMinutes min';
    }
    return '$minutes min';
  }
}
