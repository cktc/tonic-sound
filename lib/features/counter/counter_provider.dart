import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/audio/services/tonic_audio_service.dart';
import '../../core/audio/services/playback_state.dart';
import '../../core/storage/storage_service.dart';
import '../../shared/constants/enums.dart';
import '../../shared/constants/tonic_catalog.dart';

/// Provider managing the Counter screen state and playback actions.
/// Acts as a bridge between the UI and the audio service.
/// Syncs the strength slider with iOS system volume for hardware button control.
class PlaybackProvider extends ChangeNotifier {
  PlaybackProvider({
    required TonicAudioService audioService,
    StorageService? storageService,
  })  : _audioService = audioService,
        _storageService = storageService {
    // Subscribe to audio service state changes
    _subscription = _audioService.stateStream.listen(_onStateChanged);

    // Initialize volume sync with system
    _initVolumeSync();
  }

  final TonicAudioService _audioService;
  final StorageService? _storageService;
  final AnalyticsService _analytics = AnalyticsService.instance;
  StreamSubscription<PlaybackState>? _subscription;
  StreamSubscription<double>? _volumeSubscription;
  bool _isUpdatingVolume = false;  // Prevent feedback loops
  DateTime? _playbackStartTime;  // Track session start for elapsed time

  /// Current playback state
  PlaybackState get state => _audioService.currentState;

  /// Currently selected Tonic (for display before dispensing)
  Tonic _selectedTonic = Tonic.defaultTonic;
  Tonic get selectedTonic => _selectedTonic;

  /// Currently selected Botanical (null if tonic mode)
  Botanical? _selectedBotanical;
  Botanical? get selectedBotanical => _selectedBotanical;

  /// Current dosage setting in minutes (default: 8 hours)
  int _dosageMinutes = 480;
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
  /// If playback is active, switches to the new sound immediately
  void selectTonic(Tonic tonic) {
    final wasPlaying = isPlaying || isPaused;
    final previousSoundId = _currentSoundId;

    _selectedTonic = tonic;
    _selectedBotanical = null;
    _soundType = SoundType.tonic;
    notifyListeners();

    // If playback was active, switch to the new sound
    if (wasPlaying && previousSoundId != tonic.id) {
      _switchToCurrentSound();
    }
  }

  /// Select a Botanical for the counter
  /// If playback is active, switches to the new sound immediately
  void selectBotanical(Botanical botanical) {
    final wasPlaying = isPlaying || isPaused;
    final previousSoundId = _currentSoundId;

    _selectedBotanical = botanical;
    _soundType = SoundType.botanical;
    notifyListeners();

    // If playback was active, switch to the new sound
    if (wasPlaying && previousSoundId != botanical.id) {
      _switchToCurrentSound();
    }
  }

  /// Switch audio to the currently selected sound (used when changing sounds mid-playback)
  Future<void> _switchToCurrentSound() async {
    // Track the sound switch
    _analytics.trackPlaybackStopped(
      soundId: _currentSoundId,
      soundType: _soundType,
      elapsedMinutes: _elapsedMinutes,
      intendedDosageMinutes: _dosageMinutes,
      completedDosage: false,
      stopReason: 'sound_switched',
    );

    // Get remaining time from current state to continue the session
    final remainingSeconds = state.remainingSeconds;
    final remainingMinutes = (remainingSeconds / 60).ceil();

    // Start the new sound with the remaining time
    _playbackStartTime = DateTime.now();

    _analytics.trackPlaybackStarted(
      soundId: _currentSoundId,
      soundType: _soundType,
      dosageMinutes: remainingMinutes,
      strength: _strength,
    );

    if (_soundType == SoundType.tonic) {
      await _audioService.dispenseTonic(
        _selectedTonic,
        dosageMinutes: remainingMinutes,
        strength: _strength,
      );
    } else if (_selectedBotanical != null) {
      await _audioService.dispenseBotanical(
        _selectedBotanical!,
        dosageMinutes: remainingMinutes,
        strength: _strength,
      );
    }
  }

  /// Set the dosage duration
  void setDosage(int minutes) {
    final previousDosage = _dosageMinutes;
    _dosageMinutes = minutes;

    // Track dosage change
    if (previousDosage != minutes) {
      _analytics.trackDosageChanged(
        newDosageMinutes: minutes,
        previousDosageMinutes: previousDosage,
      );
    }

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

  /// Get current sound ID for analytics
  String get _currentSoundId => _soundType == SoundType.tonic
      ? _selectedTonic.id
      : _selectedBotanical?.id ?? '';

  /// Get elapsed minutes since playback started
  double get _elapsedMinutes {
    if (_playbackStartTime == null) return 0;
    return DateTime.now().difference(_playbackStartTime!).inSeconds / 60.0;
  }

  /// Dispense the currently selected sound (start playback)
  Future<void> dispense() async {
    _playbackStartTime = DateTime.now();

    // Track playback started
    _analytics.trackPlaybackStarted(
      soundId: _currentSoundId,
      soundType: _soundType,
      dosageMinutes: _dosageMinutes,
      strength: _strength,
    );

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
    final elapsed = _elapsedMinutes;
    final completedDosage = elapsed >= _dosageMinutes * 0.9; // 90% threshold

    // Track playback stopped
    _analytics.trackPlaybackStopped(
      soundId: _currentSoundId,
      soundType: _soundType,
      elapsedMinutes: elapsed,
      intendedDosageMinutes: _dosageMinutes,
      completedDosage: completedDosage,
      stopReason: 'manual',
    );

    // Track first playback completed (one-time activation event)
    // Fires when user completes at least 1 minute of playback for the first time
    final storage = _storageService;
    if (storage != null &&
        !storage.isFirstPlaybackCompleted() &&
        elapsed >= 1.0) {
      _analytics.trackFirstPlaybackCompleted(
        soundId: _currentSoundId,
        soundType: _soundType,
        elapsedMinutes: elapsed,
        daysSinceInstall: storage.getDaysSinceInstall(),
        sessionNumber: storage.getSessionCount(),
      );
      await storage.markFirstPlaybackCompleted();
      // Flush immediately - this is a critical one-time activation event
      _analytics.flush();
    }

    _playbackStartTime = null;
    await _audioService.cap();
  }

  /// Pause playback
  Future<void> pause() async {
    _analytics.trackPlaybackPaused(
      soundId: _currentSoundId,
      elapsedMinutes: _elapsedMinutes,
    );
    await _audioService.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    _analytics.trackPlaybackResumed(
      soundId: _currentSoundId,
      elapsedMinutes: _elapsedMinutes,
    );
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
