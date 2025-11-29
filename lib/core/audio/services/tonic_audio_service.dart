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
import '../generators/rain_generator.dart';
import '../generators/ocean_generator.dart';
import '../generators/wind_generator.dart';
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
  DateTime? _lastCountdownUpdate;  // Track when we last updated countdown

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
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));

    // Initialize PCM sound with background audio enabled
    await FlutterPcmSound.setup(
      sampleRate: NoiseGenerator.sampleRate,
      channelCount: 1,
      iosAllowBackgroundAudio: true,  // Enable background audio on iOS
    );

    // Set up native feed callback for background-safe audio feeding
    // This callback is triggered by the native audio system when more samples are needed
    FlutterPcmSound.setFeedCallback(_onNativeFeedRequest);

    // Set threshold for when to request more audio (larger buffer for background resilience)
    // ~500ms buffer ensures smooth playback during app state transitions
    FlutterPcmSound.setFeedThreshold(NoiseGenerator.sampleRate ~/ 2);

    _isInitialized = true;
  }

  /// Native callback when audio system needs more samples
  /// This is called by the native layer and works even when app is backgrounded
  void _onNativeFeedRequest(int remainingFrames) {
    if (_currentGenerator == null ||
        _state.status != PlaybackStatus.dispensing ||
        !_isInitialized) {
      return;
    }

    // Feed a larger buffer for background resilience (~200ms)
    _feedBuffer(_state.strength, sampleCount: NoiseGenerator.sampleRate ~/ 5);
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

    // Stop any current playback first
    await _stopPlayback();

    // Initialize audio AFTER stopping (since _stopPlayback releases PCM)
    await _initializeAudio();

    // Create appropriate botanical generator
    _currentGenerator = _createBotanicalGenerator(botanical.botanicalType);
    _currentGenerator!.reset();

    // Update state
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

    // Notify audio handler for lock screen controls
    audioHandler.onPlaybackStarted(
      title: botanical.name,
      subtitle: botanical.tagline,
      duration: Duration(minutes: dosageMinutes),
    );

    // Start audio generation
    await _startPcmFeed(strength);

    // Start countdown timer
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

    // Resume audio feed if tonic or botanical
    if (_currentGenerator != null) {
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
  void setStrengthImmediate(double strength) {
    final clampedStrength = strength.clamp(0.0, 1.0);

    // Update state directly without stream notification to avoid double rebuilds
    // This is used during real-time slider dragging for responsive volume changes
    _state = _state.copyWith(
      strength: clampedStrength,
      safetyLevel: getSafetyLevel(clampedStrength),
    );

    // Volume will be applied on next buffer generation (within 25ms)
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

  NoiseGenerator _createBotanicalGenerator(BotanicalType type) {
    switch (type) {
      case BotanicalType.rain:
        return RainGenerator();
      case BotanicalType.ocean:
        return OceanGenerator();
      case BotanicalType.wind:
        return WindGenerator();
    }
  }

  Future<void> _startPcmFeed(double strength) async {
    // Feed a large initial buffer (~1 second) for smooth startup and background resilience
    await _feedBuffer(strength, sampleCount: NoiseGenerator.sampleRate);

    // Also set up a backup timer for foreground feeding (supplements native callback)
    // This ensures continuous audio even if native callbacks are delayed
    _feedTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _feedBuffer(_state.strength, sampleCount: NoiseGenerator.sampleRate ~/ 10),
    );
  }

  Future<void> _feedBuffer(double strength, {int? sampleCount}) async {
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

    // Generate samples (use provided count or default)
    final count = sampleCount ?? NoiseGenerator.recommendedBufferSize;
    final rawSamples = _currentGenerator!.generate(count);

    // Apply volume
    final scaledSamples = Int16List(rawSamples.length);
    for (var i = 0; i < rawSamples.length; i++) {
      scaledSamples[i] = (rawSamples[i] * effectiveStrength).round();
    }

    // Feed to audio output
    await FlutterPcmSound.feed(PcmArrayInt16.fromList(scaledSamples.toList()));
  }

  void _startCountdownTimer() {
    _lastCountdownUpdate = DateTime.now();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Calculate actual elapsed time (handles background suspension)
      final now = DateTime.now();
      final actualElapsed = now.difference(_lastCountdownUpdate!).inSeconds;
      _lastCountdownUpdate = now;

      // Subtract actual elapsed time (usually 1 second, but more if app was backgrounded)
      final newRemaining = (_state.remainingSeconds - actualElapsed).clamp(0, _state.dosageMinutes * 60);

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
