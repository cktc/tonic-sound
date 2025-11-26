import 'dart:typed_data';

/// Abstract interface for noise generators.
/// All generators produce PCM audio samples at 44100Hz, 16-bit signed integer format.
///
/// Implementation Notes:
/// - Sample rate: 44100 Hz (CD quality)
/// - Bit depth: 16-bit signed integer (-32768 to 32767)
/// - Buffer size: ~50ms (2205 samples) recommended for low latency
/// - Generators are stateful - maintain internal state between calls
abstract class NoiseGenerator {
  /// Sample rate in Hz
  static const int sampleRate = 44100;

  /// Recommended buffer size in samples (~50ms at 44100Hz)
  static const int recommendedBufferSize = 2205;

  /// Maximum sample value for 16-bit signed audio
  static const int maxSampleValue = 32767;

  /// Minimum sample value for 16-bit signed audio
  static const int minSampleValue = -32768;

  /// Generate [sampleCount] samples of noise.
  /// Returns Int16List of PCM samples.
  Int16List generate(int sampleCount);

  /// Reset the generator to its initial state.
  /// Call this when starting a new playback session.
  void reset();

  /// Apply amplitude scaling to a sample value.
  /// [sample] is the raw generated value (typically -1.0 to 1.0)
  /// [amplitude] is the volume multiplier (0.0 to 1.0)
  /// Returns clamped 16-bit signed integer.
  static int scaleToInt16(double sample, double amplitude) {
    final scaled = (sample * amplitude * maxSampleValue).round();
    return scaled.clamp(minSampleValue, maxSampleValue);
  }
}
