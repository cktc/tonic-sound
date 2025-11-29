import 'dart:math';
import 'dart:typed_data';
import 'noise_generator.dart';

/// Rain sound generator using layered synthesis.
///
/// Algorithm: Combines pink noise base with random droplet impulses
/// and LFO-modulated filtering to create realistic rain ambience.
///
/// Layers:
/// 1. Pink noise base - continuous rainfall texture
/// 2. Filtered impulses - individual droplet sounds
/// 3. LFO-modulated low-pass filter - "boiling" texture variation
///
/// Reference: Audiokinetic "Generating Rain With Pure Synthesis"
///
/// Best for: Sleep, relaxation, focus, masking distractions
class RainGenerator implements NoiseGenerator {
  RainGenerator({int? seed}) : _random = Random(seed) {
    reset();
  }

  final Random _random;

  // Pink noise state (Voss-McCartney)
  static const int _numOctaves = 16;
  late List<double> _octaveValues;
  int _pinkCounter = 0;
  double _pinkSum = 0.0;

  // Droplet state
  double _dropletEnvelope = 0.0;
  int _nextDropletIn = 0;
  double _dropletFreq = 0.0;
  double _dropletPhase = 0.0;

  // LFO state for filter modulation
  double _lfoPhase = 0.0;
  static const double _lfoFreq = 0.3; // Hz - slow modulation

  // Filter state (simple one-pole low-pass)
  double _filterState = 0.0;

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      // Generate pink noise base
      final pinkNoise = _generatePinkNoiseSample();

      // Generate droplet sounds
      final droplet = _generateDropletSample();

      // Calculate LFO for filter cutoff modulation
      _lfoPhase += (_lfoFreq * 2 * pi) / NoiseGenerator.sampleRate;
      if (_lfoPhase > 2 * pi) _lfoPhase -= 2 * pi;
      final lfoValue = (sin(_lfoPhase) + 1) / 2; // 0 to 1

      // Dynamic filter cutoff based on LFO (creates texture variation)
      // Range: 0.02 (darker) to 0.15 (brighter)
      final filterCutoff = 0.02 + (lfoValue * 0.13);

      // Combine layers
      final combined = (pinkNoise * 0.6) + (droplet * 0.4);

      // Apply low-pass filter
      _filterState += filterCutoff * (combined - _filterState);

      // Add slight high-frequency content for "crispness"
      final whiteNoise = (_random.nextDouble() * 2.0 - 1.0) * 0.05;
      final output = _filterState + whiteNoise;

      samples[i] = NoiseGenerator.scaleToInt16(output.clamp(-1.0, 1.0), 0.85);
    }

    return samples;
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

  double _generateDropletSample() {
    // Check if it's time for a new droplet
    _nextDropletIn--;
    if (_nextDropletIn <= 0) {
      // Start new droplet
      _dropletEnvelope = 0.8 + (_random.nextDouble() * 0.2); // Random intensity
      _dropletFreq = 2000 + (_random.nextDouble() * 4000); // 2-6kHz
      _dropletPhase = 0.0;
      // Random interval: 20-150ms between droplets
      _nextDropletIn =
          (NoiseGenerator.sampleRate * (0.02 + _random.nextDouble() * 0.13))
              .toInt();
    }

    // Generate droplet if envelope is active
    if (_dropletEnvelope > 0.001) {
      _dropletPhase += (_dropletFreq * 2 * pi) / NoiseGenerator.sampleRate;
      if (_dropletPhase > 2 * pi) _dropletPhase -= 2 * pi;

      // Sine wave with noise for texture
      final dropletTone = sin(_dropletPhase) * 0.3;
      final dropletNoise = (_random.nextDouble() * 2.0 - 1.0) * 0.7;
      final droplet = (dropletTone + dropletNoise) * _dropletEnvelope;

      // Fast exponential decay
      _dropletEnvelope *= 0.9985;

      return droplet;
    }

    return 0.0;
  }

  @override
  void reset() {
    _octaveValues = List.filled(_numOctaves, 0.0);
    _pinkCounter = 0;
    _pinkSum = 0.0;
    _dropletEnvelope = 0.0;
    _nextDropletIn = 0;
    _dropletFreq = 0.0;
    _dropletPhase = 0.0;
    _lfoPhase = 0.0;
    _filterState = 0.0;
  }
}
