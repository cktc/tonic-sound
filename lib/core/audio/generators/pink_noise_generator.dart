import 'dart:math';
import 'dart:typed_data';
import 'noise_generator.dart';

/// Pink noise generator using Voss-McCartney algorithm.
///
/// Algorithm: Uses multiple octave-band generators combined to produce
/// noise with power spectral density inversely proportional to frequency
/// (1/f noise). Energy decreases by 3dB per octave.
///
/// Implementation: Voss-McCartney algorithm with 16 octave generators.
/// Each generator updates at a different rate (powers of 2), creating
/// the characteristic pink spectrum through summation.
///
/// Characteristics:
/// - Power decreases 3dB per octave (-10 dB/decade)
/// - More balanced/natural sound than white noise
/// - Often described as "waterfall" or "wind" sound
///
/// Reference: Gardner, M. "Efficient Convolution without Input-Output Delay"
///
/// Best for: Sleep, concentration, general sound masking
class PinkNoiseGenerator implements NoiseGenerator {
  PinkNoiseGenerator({int? seed}) : _random = Random(seed) {
    reset();
  }

  final Random _random;

  /// Number of octave generators (more = smoother spectrum)
  static const int _numOctaves = 16;

  /// Running sum values for each octave
  late List<double> _octaveValues;

  /// Current sample counter for determining which octaves to update
  int _sampleCounter = 0;

  /// Running total for output normalization
  double _runningSum = 0.0;

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      // Determine which octaves to update based on counter bits
      // Octave k updates when bit k of counter changes (every 2^k samples)
      var k = _sampleCounter;
      _sampleCounter++;

      // Update octaves where the corresponding bit changed
      for (var octave = 0; octave < _numOctaves; octave++) {
        if ((k & 1) == 1) {
          // Remove old value from running sum
          _runningSum -= _octaveValues[octave];
          // Generate new random value for this octave
          _octaveValues[octave] = (_random.nextDouble() * 2.0) - 1.0;
          // Add new value to running sum
          _runningSum += _octaveValues[octave];
          break; // Only update one octave per sample
        }
        k >>= 1;
      }

      // Add white noise component for high-frequency content
      final whiteNoise = (_random.nextDouble() * 2.0) - 1.0;

      // Combine running sum with white noise, normalize
      // Division by (_numOctaves + 1) keeps output roughly in -1 to 1 range
      final value = (_runningSum + whiteNoise) / (_numOctaves + 1);

      samples[i] = NoiseGenerator.scaleToInt16(value, 1.0);
    }

    return samples;
  }

  @override
  void reset() {
    _octaveValues = List.filled(_numOctaves, 0.0);
    _sampleCounter = 0;
    _runningSum = 0.0;
  }
}
