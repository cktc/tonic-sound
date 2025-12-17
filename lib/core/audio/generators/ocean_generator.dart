import 'dart:math';
import 'dart:typed_data';
import 'noise_generator.dart';

/// Ocean waves sound generator using layered noise and modulation.
///
/// Algorithm: Combines brown noise (deep rumble) with pink noise (wash),
/// modulated by multiple slow LFOs for realistic wave patterns.
/// Uses incommensurable frequencies (Eno technique) for non-repetition.
///
/// Layers:
/// 1. Brown noise - deep ocean rumble
/// 2. Pink noise - wave wash/foam texture
/// 3. Amplitude LFOs - wave surge and retreat
/// 4. Filter LFO - tonal variation as waves approach/recede
///
/// Reference: SyntherJack Ocean Noise Generator, Brian Eno ambient techniques
///
/// Best for: Deep relaxation, sleep, meditation, focus
class OceanGenerator implements NoiseGenerator {
  OceanGenerator({int? seed}) : _random = Random(seed) {
    reset();
  }

  final Random _random;

  // Brown noise state (leaky integrator)
  double _brownState = 0.0;
  static const double _brownLeak = 0.997;
  static const double _brownInput = 1.0 - _brownLeak;

  // Pink noise state (Voss-McCartney)
  static const int _numOctaves = 16;
  late List<double> _octaveValues;
  int _pinkCounter = 0;
  double _pinkSum = 0.0;

  // Wave LFOs - incommensurable frequencies for natural variation
  // These ratios ensure patterns don't align predictably
  double _waveLfoPhase1 = 0.0;
  double _waveLfoPhase2 = 0.0;
  double _waveLfoPhase3 = 0.0;
  static const double _waveLfoFreq1 = 0.08; // Main wave cycle (~12.5 sec)
  static const double _waveLfoFreq2 = 0.053; // Secondary (~19 sec)
  static const double _waveLfoFreq3 = 0.031; // Slow swell (~32 sec)

  // Filter state
  double _filterState = 0.0;
  double _filterState2 = 0.0; // Second pole for steeper rolloff

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      // Update LFO phases
      _waveLfoPhase1 += (_waveLfoFreq1 * 2 * pi) / NoiseGenerator.sampleRate;
      _waveLfoPhase2 += (_waveLfoFreq2 * 2 * pi) / NoiseGenerator.sampleRate;
      _waveLfoPhase3 += (_waveLfoFreq3 * 2 * pi) / NoiseGenerator.sampleRate;

      if (_waveLfoPhase1 > 2 * pi) _waveLfoPhase1 -= 2 * pi;
      if (_waveLfoPhase2 > 2 * pi) _waveLfoPhase2 -= 2 * pi;
      if (_waveLfoPhase3 > 2 * pi) _waveLfoPhase3 -= 2 * pi;

      // Calculate wave envelope (asymmetric - faster crash, slower retreat)
      // Using shaped sine waves for natural wave motion
      final wave1 = _shapeWave(sin(_waveLfoPhase1));
      final wave2 = _shapeWave(sin(_waveLfoPhase2)) * 0.6;
      final wave3 = (sin(_waveLfoPhase3) + 1) / 2 * 0.3; // Slow swell

      // Combined amplitude envelope (0.35 to 1.0 range)
      // Higher floor ensures sound is immediately audible
      final ampEnvelope = 0.35 + ((wave1 + wave2 + wave3) / 1.9) * 0.65;

      // Generate brown noise (deep rumble)
      final whiteForBrown = (_random.nextDouble() * 2.0) - 1.0;
      _brownState = (_brownLeak * _brownState) + (_brownInput * whiteForBrown);
      final brownNoise = _brownState.clamp(-1.0, 1.0);

      // Generate pink noise (wash texture)
      final pinkNoise = _generatePinkNoiseSample();

      // Mix brown and pink based on wave phase
      // More pink (higher frequencies) at wave peak, more brown in troughs
      final pinkMix = 0.3 + (ampEnvelope * 0.4);
      final brownMix = 1.0 - pinkMix;
      final mixed = (brownNoise * brownMix) + (pinkNoise * pinkMix);

      // Dynamic filter - opens up at wave peaks
      // Higher base cutoff (0.05) ensures immediate texture is audible
      final filterCutoff = 0.05 + (ampEnvelope * 0.12);
      _filterState += filterCutoff * (mixed - _filterState);
      _filterState2 += filterCutoff * (_filterState - _filterState2);

      // Apply amplitude envelope
      final output = _filterState2 * ampEnvelope;

      samples[i] = NoiseGenerator.scaleToInt16(output.clamp(-1.0, 1.0), 0.9);
    }

    return samples;
  }

  /// Shape sine wave for more natural wave motion.
  /// Positive values (wave approach) are emphasized, negative (retreat) softened.
  double _shapeWave(double x) {
    // Asymmetric shaping: sharper peaks, gentler troughs
    if (x > 0) {
      return pow(x, 0.7).toDouble(); // Sharper wave crest
    } else {
      return -pow(-x, 1.3).toDouble() * 0.5; // Gentler retreat
    }
  }

  double _generatePinkNoiseSample() {
    var k = _pinkCounter;
    _pinkCounter++;

    for (var octave = 0; octave < _numOctaves; octave++) {
      if ((k & 1) == 1) {
        _pinkSum -= _octaveValues[octave];
        _octaveValues[octave] = (_random.nextDouble() * 2.0) - 1.0;
        _pinkSum += _octaveValues[octave];
        break;
      }
      k >>= 1;
    }

    final whiteNoise = (_random.nextDouble() * 2.0) - 1.0;
    return (_pinkSum + whiteNoise) / (_numOctaves + 1);
  }

  @override
  void reset() {
    _brownState = 0.0;
    _octaveValues = List.filled(_numOctaves, 0.0);
    _pinkCounter = 0;
    _pinkSum = 0.0;
    // Start main wave at peak (π/2) so users hear wave crash immediately
    _waveLfoPhase1 = pi / 2;
    _waveLfoPhase2 = _random.nextDouble() * 2 * pi; // Random start
    _waveLfoPhase3 = _random.nextDouble() * 2 * pi; // Random start
    _filterState = 0.0;
    _filterState2 = 0.0;
  }
}
