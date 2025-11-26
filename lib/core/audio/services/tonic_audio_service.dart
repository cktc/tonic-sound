import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:audio_session/audio_session.dart';
import '../../../shared/constants/enums.dart';
import '../../../shared/constants/tonic_catalog.dart';
import '../../storage/storage_service.dart';
import '../generators/noise_generator.dart';
import '../generators/white_noise_generator.dart';
import '../generators/pink_noise_generator.dart';
import '../generators/brown_noise_generator.dart';
import 'audio_service.dart';
import 'audio_service_handler.dart';
import 'playback_state.dart';

/// Implementation of the Tonic audio service.
/// Handles real-time PCM noise generation and background audio playback.
class TonicAudioService implements TonicAudioServiceInterface {
  TonicAudioService({
    required this.audioHandler,
    required this.storageService,
  }) {
    // Wire up system media control callbacks
    audioHandler.onPlayPressed = resume;
    audioHandler.onPausePressed = pause;
    audioHandler.onStopPressed = cap;
  }

  final TonicAudioHandler audioHandler;
  final StorageService storageService;

  final _stateController = StreamController<PlaybackState>.broadcast();
  PlaybackState _state = PlaybackState.initial;

  NoiseGenerator? _currentGenerator;
  Timer? _countdownTimer;
  Timer? _feedTimer;
  DateTime? _sessionStartTime;

  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  Stream<PlaybackState> get stateStream => _stateController.stream;

  @override
  PlaybackState get currentState => _state;

  /// Initialize the audio system
  Future<void> _initializeAudio() async {
    if (_isInitialized) return;

    // Disable PCM sound package logging
    await FlutterPcmSound.setLogLevel(LogLevel.none);

    // Configure audio session for playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));

    // Initialize PCM sound
    await FlutterPcmSound.setup(
      sampleRate: NoiseGenerator.sampleRate,
      channelCount: 1,
    );

    // Set up feed callback for buffer management
    FlutterPcmSound.setFeedThreshold(NoiseGenerator.recommendedBufferSize);

    _isInitialized = true;
  }

  @override
  Future<void> dispenseTonic(
    Tonic tonic, {
    int dosageMinutes = 30,
    double strength = 0.5,
  }) async {
    if (_isDisposed) {
      throw StateError('TonicAudioService has been disposed');
    }

    // Stop any current playback first
    await _stopPlayback();

    // Initialize audio AFTER stopping (since _stopPlayback releases PCM)
    await _initializeAudio();

    // Create appropriate noise generator
    _currentGenerator = _createGenerator(tonic.noiseType);
    _currentGenerator!.reset();

    // Update state
    _sessionStartTime = DateTime.now();
    _updateState(_state.copyWith(
      status: PlaybackStatus.dispensing,
      currentTonic: tonic,
      currentBotanical: null,
      strength: strength,
      dosageMinutes: dosageMinutes,
      remainingSeconds: dosageMinutes * 60,
      safetyLevel: getSafetyLevel(strength),
      isFadingOut: false,
      clearBotanical: true,
    ));

    // Notify audio handler for lock screen controls
    audioHandler.onPlaybackStarted(
      title: tonic.name,
      subtitle: tonic.tagline,
      duration: Duration(minutes: dosageMinutes),
    );

    // Start audio generation
    await _startPcmFeed(strength);

    // Start countdown timer
    _startCountdownTimer();
  }

  @override
  Future<void> dispenseBotanical(
    Botanical botanical, {
    int dosageMinutes = 30,
    double strength = 0.5,
  }) async {
    if (_isDisposed) {
      throw StateError('TonicAudioService has been disposed');
    }

    // TODO: Implement botanical playback using audio file

    // Update state to show intent
    _sessionStartTime = DateTime.now();
    _updateState(_state.copyWith(
      status: PlaybackStatus.dispensing,
      currentTonic: null,
      currentBotanical: botanical,
      strength: strength,
      dosageMinutes: dosageMinutes,
      remainingSeconds: dosageMinutes * 60,
      safetyLevel: getSafetyLevel(strength),
      isFadingOut: false,
      clearTonic: true,
    ));

    audioHandler.onPlaybackStarted(
      title: botanical.name,
      subtitle: botanical.tagline,
      duration: Duration(minutes: dosageMinutes),
    );

    _startCountdownTimer();
  }

  @override
  Future<void> cap() async {
    await _stopPlayback();

    // Record session if one was in progress
    if (_sessionStartTime != null) {
      final session = _state.toSession(
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        completedFullDosage: _state.remainingSeconds == 0,
      );
      // Save session to storage
      await storageService.recordSession(session);
    }

    _sessionStartTime = null;
    _updateState(PlaybackState.initial);
    audioHandler.onPlaybackStopped();
  }

  @override
  Future<void> pause() async {
    if (_state.status != PlaybackStatus.dispensing) {
      return;
    }

    _countdownTimer?.cancel();
    _feedTimer?.cancel();

    _updateState(_state.copyWith(status: PlaybackStatus.paused));
    audioHandler.onPlaybackPaused();
  }

  @override
  Future<void> resume() async {
    if (_state.status != PlaybackStatus.paused) {
      return;
    }

    // Ensure audio is initialized (in case it was released during background)
    await _initializeAudio();

    // Resume audio feed if tonic
    if (_state.currentTonic != null && _currentGenerator != null) {
      await _startPcmFeed(_state.strength);
    }

    _startCountdownTimer();
    _updateState(_state.copyWith(status: PlaybackStatus.dispensing));
    audioHandler.onPlaybackResumed();
  }

  @override
  Future<void> setStrength(double strength) async {
    final clampedStrength = strength.clamp(0.0, 1.0);

    _updateState(_state.copyWith(
      strength: clampedStrength,
      safetyLevel: getSafetyLevel(clampedStrength),
    ));

    // Volume will be applied on next buffer generation
  }

  @override
  SafetyLevel getSafetyLevel(double strength) {
    if (strength <= 0.6) return SafetyLevel.safe;
    if (strength <= 0.8) return SafetyLevel.moderate;
    return SafetyLevel.high;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    await _stopPlayback();
    await _stateController.close();
  }

  // Private methods

  NoiseGenerator _createGenerator(NoiseType type) {
    switch (type) {
      case NoiseType.white:
        return WhiteNoiseGenerator();
      case NoiseType.pink:
        return PinkNoiseGenerator();
      case NoiseType.brown:
        return BrownNoiseGenerator();
    }
  }

  Future<void> _startPcmFeed(double strength) async {
    // Generate and feed initial buffer
    await _feedBuffer(strength);

    // Set up periodic feed (every ~25ms to stay ahead of playback)
    _feedTimer = Timer.periodic(
      const Duration(milliseconds: 25),
      (_) => _feedBuffer(_state.strength),
    );
  }

  Future<void> _feedBuffer(double strength) async {
    if (_currentGenerator == null ||
        _state.status != PlaybackStatus.dispensing ||
        !_isInitialized) {
      return;
    }

    // Apply fade-out if in last 5 minutes
    var effectiveStrength = strength;
    if (_state.isFadingOut) {
      final fadeProgress = _state.remainingSeconds / (5 * 60);
      effectiveStrength = strength * fadeProgress;
    }

    // Generate samples
    final rawSamples = _currentGenerator!.generate(
      NoiseGenerator.recommendedBufferSize,
    );

    // Apply volume
    final scaledSamples = Int16List(rawSamples.length);
    for (var i = 0; i < rawSamples.length; i++) {
      scaledSamples[i] = (rawSamples[i] * effectiveStrength).round();
    }

    // Feed to audio output
    await FlutterPcmSound.feed(PcmArrayInt16.fromList(scaledSamples.toList()));
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newRemaining = _state.remainingSeconds - 1;

      if (newRemaining <= 0) {
        cap();
        return;
      }

      // Check for fade-out (last 5 minutes = 300 seconds)
      final shouldFadeOut = newRemaining <= 300 && !_state.isFadingOut;

      _updateState(_state.copyWith(
        remainingSeconds: newRemaining,
        isFadingOut: _state.isFadingOut || shouldFadeOut,
      ));

      // Update lock screen position
      final elapsed = (_state.dosageMinutes * 60) - newRemaining;
      audioHandler.updatePosition(Duration(seconds: elapsed));
    });
  }

  Future<void> _stopPlayback() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;

    _feedTimer?.cancel();
    _feedTimer = null;

    _currentGenerator = null;

    if (_isInitialized) {
      await FlutterPcmSound.release();
      _isInitialized = false;
    }
  }

  void _updateState(PlaybackState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }
}
