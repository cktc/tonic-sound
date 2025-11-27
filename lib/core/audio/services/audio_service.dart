import '../../../shared/constants/enums.dart';
import '../../../shared/constants/tonic_catalog.dart';
import 'playback_state.dart';

/// Abstract interface for the Tonic audio service.
/// Defines the contract for audio playback operations using apothecary terminology.
abstract class TonicAudioServiceInterface {
  /// Stream of playback state changes
  Stream<PlaybackState> get stateStream;

  /// Current playback state
  PlaybackState get currentState;

  /// Start playing a Tonic with real-time noise generation.
  /// [tonic] - The Tonic to dispense
  /// [dosageMinutes] - Duration in minutes (default: 30)
  /// [strength] - Volume level 0.0-1.0 (default: 0.5)
  Future<void> dispenseTonic(
    Tonic tonic, {
    int dosageMinutes = 30,
    double strength = 0.5,
  });

  /// Start playing a Botanical from pre-recorded audio.
  /// [botanical] - The Botanical to dispense
  /// [dosageMinutes] - Duration in minutes (default: 30)
  /// [strength] - Volume level 0.0-1.0 (default: 0.5)
  Future<void> dispenseBotanical(
    Botanical botanical, {
    int dosageMinutes = 30,
    double strength = 0.5,
  });

  /// Stop playback and cap the bottle.
  /// Records the session and resets to idle state.
  Future<void> cap();

  /// Pause the current playback.
  /// Maintains timer state for resume.
  Future<void> pause();

  /// Resume paused playback.
  Future<void> resume();

  /// Adjust the strength (volume) during playback.
  /// [strength] - New volume level 0.0-1.0
  Future<void> setStrength(double strength);

  /// Adjust the strength immediately without notifying stream listeners.
  /// Use this for real-time slider updates to avoid double rebuilds.
  /// [strength] - New volume level 0.0-1.0
  void setStrengthImmediate(double strength);

  /// Get the safety level for a given strength value.
  /// Returns SafetyLevel.safe (<= 0.6), moderate (<= 0.8), or high (> 0.8)
  SafetyLevel getSafetyLevel(double strength);

  /// Dispose of resources when service is no longer needed.
  Future<void> dispose();
}
