import 'dart:math';
import 'dart:typed_data';
import 'noise_generator.dart';

/// Brown (Brownian/Red) noise generator using leaky integrator.
///
/// Algorithm: Integrates white noise with a leak factor to prevent
/// DC drift. This produces noise with power spectral density inversely
/// proportional to frequency squared (1/f² noise). Energy decreases
/// by 6dB per octave.
///
/// Implementation: Leaky integrator with coefficient 0.995.
/// y[n] = leak * y[n-1] + (1 - leak) * x[n]
/// where x[n] is white noise input.
///
/// Characteristics:
/// - Power decreases 6dB per octave (-20 dB/decade)
/// - Deep, rumbling sound with prominent bass
/// - Named after Brownian motion (random walk), not the color
///
/// Reference: Brownian motion / random walk process
///
/// Best for: Deep relaxation, meditation, blocking low-frequency noise
class BrownNoiseGenerator implements NoiseGenerator {
  BrownNoiseGenerator({int? seed}) : _random = Random(seed) {
    reset();
  }

  final Random _random;

  /// Leak factor - higher values = more bass, slower changes
  /// 0.995 provides good balance between deep bass and responsiveness
  static const double _leakFactor = 0.995;

  /// Inverse leak factor for efficiency
  static const double _inputScale = 1.0 - _leakFactor;

  /// Previous output value (integrator state)
  double _lastOutput = 0.0;

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      // Generate white noise input
      final whiteNoise = (_random.nextDouble() * 2.0) - 1.0;

      // Apply leaky integrator
      // y[n] = leak * y[n-1] + (1-leak) * x[n]
      _lastOutput = (_leakFactor * _lastOutput) + (_inputScale * whiteNoise);

      // Clamp output to prevent extreme values (shouldn't happen with leak, but safety)
      final clampedOutput = _lastOutput.clamp(-1.0, 1.0);

      samples[i] = NoiseGenerator.scaleToInt16(clampedOutput, 1.0);
    }

    return samples;
  }

  @override
  void reset() {
    _lastOutput = 0.0;
  }
}
