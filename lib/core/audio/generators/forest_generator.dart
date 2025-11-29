import 'dart:math';
import 'dart:typed_data';
import 'noise_generator.dart';

/// Forest ambience sound generator using layered synthesis.
///
/// Algorithm: Combines multiple layers of naturalistic sounds:
/// - Wind through leaves (filtered, modulated pink noise)
/// - Bird calls (randomized sine-based chirps with harmonics)
/// - Occasional rustling (filtered noise bursts)
///
/// Uses probabilistic triggering for organic, non-repetitive ambience.
///
/// Best for: Relaxation, meditation, focus, nature connection
class ForestGenerator implements NoiseGenerator {
  ForestGenerator({int? seed}) : _random = Random(seed) {
    reset();
  }

  final Random _random;

  // Pink noise state for wind
  static const int _numOctaves = 16;
  late List<double> _octaveValues;
  int _pinkCounter = 0;
  double _pinkSum = 0.0;

  // Wind LFOs for natural variation
  double _windLfoPhase1 = 0.0;
  double _windLfoPhase2 = 0.0;
  static const double _windLfoFreq1 = 0.07; // ~14 sec cycle
  static const double _windLfoFreq2 = 0.023; // ~43 sec cycle

  // Wind filter state
  double _windFilterState = 0.0;

  // Bird chirp state - support multiple simultaneous birds
  static const int _maxBirds = 3;
  late List<_BirdState> _birds;
  int _nextBirdCheck = 0;

  // Rustling state
  double _rustleEnvelope = 0.0;
  int _nextRustleCheck = 0;
  double _rustleFilterState = 0.0;

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      // === Wind Layer ===
      final wind = _generateWindSample();

      // === Bird Layer ===
      final birds = _generateBirdsSample();

      // === Rustle Layer ===
      final rustle = _generateRustleSample();

      // Mix layers
      // Wind is the base, birds and rustles are accents
      final output = (wind * 0.5) + (birds * 0.35) + (rustle * 0.15);

      samples[i] = NoiseGenerator.scaleToInt16(output.clamp(-1.0, 1.0), 0.85);
    }

    return samples;
  }

  double _generateWindSample() {
    // Update wind LFOs
    _windLfoPhase1 += (_windLfoFreq1 * 2 * pi) / NoiseGenerator.sampleRate;
    _windLfoPhase2 += (_windLfoFreq2 * 2 * pi) / NoiseGenerator.sampleRate;
    if (_windLfoPhase1 > 2 * pi) _windLfoPhase1 -= 2 * pi;
    if (_windLfoPhase2 > 2 * pi) _windLfoPhase2 -= 2 * pi;

    // Combined wind intensity (gentle breeze to moderate wind)
    final windIntensity =
        0.3 + (sin(_windLfoPhase1) * 0.25) + (sin(_windLfoPhase2) * 0.15);

    // Generate pink noise
    final pinkNoise = _generatePinkNoiseSample();

    // Dynamic filter based on wind intensity
    // Higher intensity = brighter sound (more leaf rustle)
    final cutoff = 0.02 + (windIntensity * 0.08);
    _windFilterState += cutoff * (pinkNoise - _windFilterState);

    return _windFilterState * windIntensity;
  }

  double _generateBirdsSample() {
    // Periodically check if we should spawn a new bird
    _nextBirdCheck--;
    if (_nextBirdCheck <= 0) {
      _nextBirdCheck = (NoiseGenerator.sampleRate * 0.1).toInt(); // Check every 100ms

      // Random chance to spawn a bird (if slot available)
      if (_random.nextDouble() < 0.03) {
        // 3% chance per check
        for (var bird in _birds) {
          if (!bird.active) {
            _initBird(bird);
            break;
          }
        }
      }
    }

    // Generate bird sounds
    double birdSum = 0.0;
    for (var bird in _birds) {
      if (bird.active) {
        birdSum += _generateBirdChirp(bird);
      }
    }

    return birdSum;
  }

  void _initBird(_BirdState bird) {
    bird.active = true;
    // Bird call parameters - varied for different "species"
    bird.baseFreq = 1500 + (_random.nextDouble() * 3000); // 1.5-4.5 kHz
    bird.freqVariation = 200 + (_random.nextDouble() * 800);
    bird.chirpRate = 3 + (_random.nextDouble() * 8); // chirps per second
    bird.chirpsRemaining = 2 + _random.nextInt(6); // 2-7 chirps
    bird.phase = 0.0;
    bird.chirpEnvelope = 0.0;
    bird.nextChirpIn = 0;
    bird.amplitude = 0.3 + (_random.nextDouble() * 0.4);
  }

  double _generateBirdChirp(_BirdState bird) {
    // Check if time for next chirp in sequence
    bird.nextChirpIn--;
    if (bird.nextChirpIn <= 0 && bird.chirpsRemaining > 0) {
      bird.chirpEnvelope = 1.0;
      bird.chirpsRemaining--;
      // Interval between chirps in a call (50-150ms)
      bird.nextChirpIn =
          (NoiseGenerator.sampleRate * (0.05 + _random.nextDouble() * 0.1))
              .toInt();
    }

    if (bird.chirpEnvelope < 0.001) {
      if (bird.chirpsRemaining <= 0) {
        bird.active = false;
      }
      return 0.0;
    }

    // Frequency modulation for warble effect
    final freqMod = sin(bird.phase * 0.1) * bird.freqVariation;
    final freq = bird.baseFreq + freqMod;

    // Update phase
    bird.phase += (freq * 2 * pi) / NoiseGenerator.sampleRate;
    if (bird.phase > 2 * pi) bird.phase -= 2 * pi;

    // Generate chirp with harmonics
    final fundamental = sin(bird.phase);
    final harmonic2 = sin(bird.phase * 2) * 0.3;
    final harmonic3 = sin(bird.phase * 3) * 0.1;
    final chirp = (fundamental + harmonic2 + harmonic3) / 1.4;

    // Apply envelope with fast attack, medium decay
    final output = chirp * bird.chirpEnvelope * bird.amplitude;
    bird.chirpEnvelope *= 0.9992; // Decay

    return output;
  }

  double _generateRustleSample() {
    // Periodically check if we should trigger a rustle
    _nextRustleCheck--;
    if (_nextRustleCheck <= 0) {
      _nextRustleCheck =
          (NoiseGenerator.sampleRate * 0.2).toInt(); // Check every 200ms

      // Random chance to trigger rustle
      if (_random.nextDouble() < 0.05 && _rustleEnvelope < 0.01) {
        _rustleEnvelope = 0.5 + (_random.nextDouble() * 0.5);
      }
    }

    if (_rustleEnvelope < 0.001) {
      return 0.0;
    }

    // Generate filtered noise burst
    final noise = (_random.nextDouble() * 2.0) - 1.0;

    // Bandpass-ish filter for rustle character
    _rustleFilterState += 0.15 * (noise - _rustleFilterState);

    final output = _rustleFilterState * _rustleEnvelope;

    // Medium decay for rustle
    _rustleEnvelope *= 0.9997;

    return output;
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
    _octaveValues = List.filled(_numOctaves, 0.0);
    _pinkCounter = 0;
    _pinkSum = 0.0;
    _windLfoPhase1 = 0.0;
    _windLfoPhase2 = _random.nextDouble() * 2 * pi;
    _windFilterState = 0.0;
    _birds = List.generate(_maxBirds, (_) => _BirdState());
    _nextBirdCheck = NoiseGenerator.sampleRate; // Start after 1 sec
    _rustleEnvelope = 0.0;
    _nextRustleCheck = 0;
    _rustleFilterState = 0.0;
  }
}

/// Internal state for a single bird voice
class _BirdState {
  bool active = false;
  double baseFreq = 0.0;
  double freqVariation = 0.0;
  double chirpRate = 0.0;
  int chirpsRemaining = 0;
  double phase = 0.0;
  double chirpEnvelope = 0.0;
  int nextChirpIn = 0;
  double amplitude = 0.0;
}
