import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/audio/services/tonic_audio_service.dart';
import '../../core/audio/services/playback_state.dart';
import '../../shared/constants/enums.dart';
import '../../shared/constants/tonic_catalog.dart';

/// Provider managing the Counter screen state and playback actions.
/// Acts as a bridge between the UI and the audio service.
class PlaybackProvider extends ChangeNotifier {
  PlaybackProvider({required TonicAudioService audioService})
      : _audioService = audioService {
    // Subscribe to audio service state changes
    _subscription = _audioService.stateStream.listen(_onStateChanged);
  }

  final TonicAudioService _audioService;
  StreamSubscription<PlaybackState>? _subscription;

  /// Current playback state
  PlaybackState get state => _audioService.currentState;

  /// Currently selected Tonic (for display before dispensing)
  Tonic _selectedTonic = Tonic.defaultTonic;
  Tonic get selectedTonic => _selectedTonic;

  /// Currently selected Botanical (null if tonic mode)
  Botanical? _selectedBotanical;
  Botanical? get selectedBotanical => _selectedBotanical;

  /// Current dosage setting in minutes
  int _dosageMinutes = 30;
  int get dosageMinutes => _dosageMinutes;

  /// Current strength setting (0.0 to 1.0)
  double _strength = 0.5;
  double get strength => _strength;

  /// Whether we're in tonic or botanical mode
  SoundType _soundType = SoundType.tonic;
  SoundType get soundType => _soundType;

  /// Safety level for current strength
  SafetyLevel get safetyLevel => _audioService.getSafetyLevel(_strength);

  /// Whether playback is currently active
  bool get isPlaying => state.isPlaying;

  /// Whether playback is paused
  bool get isPaused => state.isPaused;

  /// Whether idle (nothing playing)
  bool get isIdle => state.isIdle;

  /// Formatted remaining time
  String get remainingTimeFormatted => state.remainingTimeFormatted;

  /// Progress percentage
  double get progress => state.progress;

  void _onStateChanged(PlaybackState newState) {
    notifyListeners();
  }

  /// Select a Tonic for the counter
  void selectTonic(Tonic tonic) {
    _selectedTonic = tonic;
    _selectedBotanical = null;
    _soundType = SoundType.tonic;
    notifyListeners();
  }

  /// Select a Botanical for the counter
  void selectBotanical(Botanical botanical) {
    _selectedBotanical = botanical;
    _soundType = SoundType.botanical;
    notifyListeners();
  }

  /// Set the dosage duration
  void setDosage(int minutes) {
    _dosageMinutes = minutes;
    notifyListeners();
  }

  /// Set the strength (volume)
  /// Updates immediately for responsive UI, syncs to audio service for playback.
  void setStrength(double value) {
    final clampedValue = value.clamp(0.0, 1.0);

    // Skip if no change (prevents unnecessary rebuilds during fast dragging)
    if (_strength == clampedValue) return;

    _strength = clampedValue;

    // Update audio service directly (sync call, no stream notification needed)
    // This updates the audio volume without triggering a second rebuild
    _audioService.setStrengthImmediate(clampedValue);

    notifyListeners();
  }

  /// Dispense the currently selected sound (start playback)
  Future<void> dispense() async {
    if (_soundType == SoundType.tonic) {
      await _audioService.dispenseTonic(
        _selectedTonic,
        dosageMinutes: _dosageMinutes,
        strength: _strength,
      );
    } else if (_selectedBotanical != null) {
      await _audioService.dispenseBotanical(
        _selectedBotanical!,
        dosageMinutes: _dosageMinutes,
        strength: _strength,
      );
    }
  }

  /// Cap the bottle (stop playback)
  Future<void> cap() async {
    await _audioService.cap();
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioService.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioService.resume();
  }

  /// Toggle between play and pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else if (isPaused) {
      await resume();
    } else {
      await dispense();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
