import 'dart:math';
import 'dart:typed_data';
import 'noise_generator.dart';

/// Wind sound generator using layered synthesis.
///
/// Algorithm: Combines multiple layers for realistic wind ambience:
/// - Base wind: Filtered pink noise with slow LFO modulation
/// - Gusts: Amplitude-enveloped noise bursts with probabilistic triggering
/// - Whistling: Resonant bandpass filtered noise for howling character
///
/// Uses incommensurable LFO frequencies for organic, non-repetitive variation.
///
/// Reference: Andy Farnell "Designing Sound", procedural audio techniques
///
/// Best for: Relaxation, focus, sleep, atmospheric ambience
class WindGenerator implements NoiseGenerator {
  WindGenerator({int? seed}) : _random = Random(seed) {
    reset();
  }

  final Random _random;

  // Pink noise state (Voss-McCartney algorithm)
  static const int _numOctaves = 16;
  late List<double> _octaveValues;
  int _pinkCounter = 0;
  double _pinkSum = 0.0;

  // Brown noise state for gusts (leaky integrator)
  double _brownState = 0.0;
  static const double _brownLeak = 0.998;
  static const double _brownInput = 1.0 - _brownLeak;

  // Base wind LFOs - incommensurable frequencies for natural variation
  double _windLfoPhase1 = 0.0;
  double _windLfoPhase2 = 0.0;
  double _windLfoPhase3 = 0.0;
  static const double _windLfoFreq1 = 0.067; // ~15 sec cycle
  static const double _windLfoFreq2 = 0.041; // ~24 sec cycle
  static const double _windLfoFreq3 = 0.023; // ~43 sec cycle

  // Base wind filter state (two-pole for smoother rolloff)
  double _baseFilterState1 = 0.0;
  double _baseFilterState2 = 0.0;

  // Gust state
  double _gustEnvelope = 0.0;
  double _gustTarget = 0.0;
  int _nextGustCheck = 0;
  double _gustFilterState = 0.0;

  // Whistling state - resonant bandpass filter
  double _whistleBandpass = 0.0;
  double _whistleLowpass = 0.0;
  double _whistleLfoPhase = 0.0;
  static const double _whistleLfoFreq = 0.037; // ~27 sec cycle
  double _whistleIntensity = 0.0;
  double _whistleTargetIntensity = 0.0;

  @override
  Int16List generate(int sampleCount) {
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      // === Base Wind Layer ===
      final baseWind = _generateBaseWindSample();

      // === Gust Layer ===
      final gust = _generateGustSample();

      // === Whistling Layer ===
      final whistle = _generateWhistleSample();

      // Mix layers with appropriate balance
      // Base wind is foundation, gusts add dynamics, whistling adds character
      final output = (baseWind * 0.55) + (gust * 0.30) + (whistle * 0.15);

      samples[i] = NoiseGenerator.scaleToInt16(output.clamp(-1.0, 1.0), 0.88);
    }

    return samples;
  }

  double _generateBaseWindSample() {
    // Update LFO phases
    _windLfoPhase1 += (_windLfoFreq1 * 2 * pi) / NoiseGenerator.sampleRate;
    _windLfoPhase2 += (_windLfoFreq2 * 2 * pi) / NoiseGenerator.sampleRate;
    _windLfoPhase3 += (_windLfoFreq3 * 2 * pi) / NoiseGenerator.sampleRate;

    if (_windLfoPhase1 > 2 * pi) _windLfoPhase1 -= 2 * pi;
    if (_windLfoPhase2 > 2 * pi) _windLfoPhase2 -= 2 * pi;
    if (_windLfoPhase3 > 2 * pi) _windLfoPhase3 -= 2 * pi;

    // Combined wind intensity envelope (gentle breeze to moderate wind)
    // Using multiple LFOs creates natural, non-repeating variation
    final lfo1 = sin(_windLfoPhase1);
    final lfo2 = sin(_windLfoPhase2) * 0.6;
    final lfo3 = sin(_windLfoPhase3) * 0.3;

    // Intensity ranges from 0.25 to 0.85
    final windIntensity = 0.55 + ((lfo1 + lfo2 + lfo3) / 1.9) * 0.30;

    // Generate pink noise for wind texture
    final pinkNoise = _generatePinkNoiseSample();

    // Dynamic low-pass filter - cutoff follows intensity
    // Higher intensity = brighter sound (more high frequencies)
    // Cutoff coefficient: 0.03 (dark) to 0.12 (bright)
    final cutoff = 0.03 + (windIntensity * 0.09);

    // Two-pole filter for smoother rolloff
    _baseFilterState1 += cutoff * (pinkNoise - _baseFilterState1);
    _baseFilterState2 += cutoff * (_baseFilterState1 - _baseFilterState2);

    return _baseFilterState2 * windIntensity;
  }

  double _generateGustSample() {
    // Periodically check for new gusts
    _nextGustCheck--;
    if (_nextGustCheck <= 0) {
      _nextGustCheck =
          (NoiseGenerator.sampleRate * 0.15).toInt(); // Check every 150ms

      // Random chance to trigger a gust (5% per check)
      if (_random.nextDouble() < 0.05 && _gustEnvelope < 0.1) {
        // Set gust target - random intensity
        _gustTarget = 0.5 + (_random.nextDouble() * 0.5);
      }
    }

    // Smooth envelope follower for gust intensity
    // Fast attack, slow decay for natural gust shape
    if (_gustEnvelope < _gustTarget) {
      // Attack phase - relatively quick rise
      _gustEnvelope += (_gustTarget - _gustEnvelope) * 0.0008;
      if (_gustEnvelope >= _gustTarget * 0.95) {
        _gustTarget = 0.0; // Start decay
      }
    } else {
      // Decay phase - slower falloff
      _gustEnvelope *= 0.99985;
    }

    if (_gustEnvelope < 0.001) {
      return 0.0;
    }

    // Generate brown noise for deep gust rumble
    final whiteForBrown = (_random.nextDouble() * 2.0) - 1.0;
    _brownState = (_brownLeak * _brownState) + (_brownInput * whiteForBrown);

    // Add pink noise for texture
    final pinkNoise = _generatePinkNoiseSample();

    // Mix brown (low rumble) with pink (texture)
    final gustNoise = (_brownState * 0.6) + (pinkNoise * 0.4);

    // Low-pass filter the gust
    final gustCutoff = 0.04 + (_gustEnvelope * 0.06);
    _gustFilterState += gustCutoff * (gustNoise - _gustFilterState);

    return _gustFilterState * _gustEnvelope;
  }

  double _generateWhistleSample() {
    // Update whistle LFO for frequency drift
    _whistleLfoPhase += (_whistleLfoFreq * 2 * pi) / NoiseGenerator.sampleRate;
    if (_whistleLfoPhase > 2 * pi) _whistleLfoPhase -= 2 * pi;

    // Whistle intensity correlates loosely with overall wind intensity
    // but has its own random variation
    if (_random.nextDouble() < 0.0001) {
      // Occasionally change whistle intensity
      _whistleTargetIntensity = _random.nextDouble() * 0.8;
    }

    // Smooth intensity changes
    _whistleIntensity +=
        (_whistleTargetIntensity - _whistleIntensity) * 0.0001;

    if (_whistleIntensity < 0.01) {
      return 0.0;
    }

    // Generate white noise for whistle source (needs high frequencies)
    final whiteNoise = (_random.nextDouble() * 2.0) - 1.0;

    // Resonant bandpass filter for whistling character
    // Center frequency drifts between ~500-1000 Hz based on LFO
    final lfoValue = (sin(_whistleLfoPhase) + 1) / 2; // 0 to 1
    final centerFreq = 500 + (lfoValue * 500); // 500-1000 Hz

    // State variable filter implementation for bandpass with resonance
    // f = 2 * sin(pi * fc / fs) - normalized frequency coefficient
    final f = 2 * sin(pi * centerFreq / NoiseGenerator.sampleRate);
    const q = 0.75; // Resonance (higher = more whistling, 0.5-0.9 range)

    // SVF update equations
    _whistleLowpass += f * _whistleBandpass;
    final highpass = whiteNoise - _whistleLowpass - (q * _whistleBandpass);
    _whistleBandpass += f * highpass;

    // Soft clip to tame resonance peaks
    final clippedBandpass = _softClip(_whistleBandpass);

    return clippedBandpass * _whistleIntensity * 0.4;
  }

  /// Soft clipping function to tame resonance peaks
  double _softClip(double x) {
    // tanh-like soft clipper: x / sqrt(1 + x^2)
    return x / sqrt(1 + x * x);
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
    // Pink noise state
    _octaveValues = List.filled(_numOctaves, 0.0);
    _pinkCounter = 0;
    _pinkSum = 0.0;

    // Brown noise state
    _brownState = 0.0;

    // Base wind LFOs - randomize start phases for variety
    _windLfoPhase1 = 0.0;
    _windLfoPhase2 = _random.nextDouble() * 2 * pi;
    _windLfoPhase3 = _random.nextDouble() * 2 * pi;

    // Base wind filter
    _baseFilterState1 = 0.0;
    _baseFilterState2 = 0.0;

    // Gust state
    _gustEnvelope = 0.0;
    _gustTarget = 0.0;
    _nextGustCheck = (NoiseGenerator.sampleRate * 2).toInt(); // Start after 2s
    _gustFilterState = 0.0;

    // Whistle state
    _whistleBandpass = 0.0;
    _whistleLowpass = 0.0;
    _whistleLfoPhase = _random.nextDouble() * 2 * pi;
    _whistleIntensity = 0.0;
    _whistleTargetIntensity = 0.3; // Start with some whistle
  }
}
