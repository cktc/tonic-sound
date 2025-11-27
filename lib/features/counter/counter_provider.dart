import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../core/audio/services/tonic_audio_service.dart';
import '../../core/audio/services/playback_state.dart';
import '../../shared/constants/enums.dart';
import '../../shared/constants/tonic_catalog.dart';

/// Provider managing the Counter screen state and playback actions.
/// Acts as a bridge between the UI and the audio service.
/// Syncs the strength slider with iOS system volume for hardware button control.
class PlaybackProvider extends ChangeNotifier {
  PlaybackProvider({required TonicAudioService audioService})
      : _audioService = audioService {
    // Subscribe to audio service state changes
    _subscription = _audioService.stateStream.listen(_onStateChanged);

    // Initialize volume sync with system
    _initVolumeSync();
  }

  final TonicAudioService _audioService;
  StreamSubscription<PlaybackState>? _subscription;
  StreamSubscription<double>? _volumeSubscription;
  bool _isUpdatingVolume = false;  // Prevent feedback loops

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

  /// Initialize bidirectional volume sync with iOS system volume
  Future<void> _initVolumeSync() async {
    try {
      // Don't show system volume UI when we change volume programmatically
      VolumeController().showSystemUI = false;

      // Get current system volume and sync our strength to it
      final currentVolume = await VolumeController().getVolume();
      _strength = currentVolume.clamp(0.0, 1.0);

      // Listen for hardware volume button changes
      _volumeSubscription = VolumeController().listener((volume) {
        if (!_isUpdatingVolume) {
          _strength = volume.clamp(0.0, 1.0);
          _audioService.setStrengthImmediate(_strength);
          notifyListeners();
        }
      });

      notifyListeners();
    } catch (e) {
      debugPrint('[PlaybackProvider] Volume sync init failed: $e');
    }
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
  /// Updates immediately for responsive UI, syncs to both audio service and system volume.
  void setStrength(double value) {
    final clampedValue = value.clamp(0.0, 1.0);

    // Skip if no change (prevents unnecessary rebuilds during fast dragging)
    if (_strength == clampedValue) return;

    _strength = clampedValue;

    // Update audio service directly (sync call, no stream notification needed)
    _audioService.setStrengthImmediate(clampedValue);

    // Sync to iOS system volume (allows hardware buttons to reflect our slider)
    _updateSystemVolume(clampedValue);

    notifyListeners();
  }

  /// Update system volume without triggering our listener callback
  void _updateSystemVolume(double volume) {
    _isUpdatingVolume = true;
    try {
      VolumeController().setVolume(volume, showSystemUI: false);
    } catch (e) {
      debugPrint('[PlaybackProvider] Failed to set system volume: $e');
    }
    // Small delay to ensure listener doesn't pick up our own change
    Future.delayed(const Duration(milliseconds: 100), () {
      _isUpdatingVolume = false;
    });
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
    _volumeSubscription?.cancel();
    VolumeController().removeListener();
    super.dispose();
  }
}
