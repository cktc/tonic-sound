import 'dart:math';
import 'dart:typed_data';
import 'noise_generator.dart';

/// White noise generator using random values.
///
/// Algorithm: Each sample is an independent random value uniformly distributed
/// between -1.0 and 1.0. This produces equal energy across all frequencies,
/// resulting in a "hissy" sound similar to TV static.
///
/// Characteristics:
/// - Flat frequency spectrum (equal energy at all frequencies)
/// - No correlation between successive samples
/// - Perceived as bright/sharp due to high-frequency content
///
/// Best for: Masking sudden noises, tinnitus relief, focus work
class WhiteNoiseGenerator implements NoiseGenerator {
  WhiteNoiseGenerator({int? seed}) : _random = Random(seed);

  final Random _random;

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      // Generate random value between -1.0 and 1.0
      final value = (_random.nextDouble() * 2.0) - 1.0;
      samples[i] = NoiseGenerator.scaleToInt16(value, 1.0);
    }

    return samples;
  }

  @override
  void reset() {
    // White noise is stateless, nothing to reset
  }
}
