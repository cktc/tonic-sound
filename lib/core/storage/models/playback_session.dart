import 'package:hive/hive.dart';

part 'playback_session.g.dart';

/// Records a completed playback session for analytics.
/// Tracks what was played, for how long, and at what strength.
@HiveType(typeId: 2)
class PlaybackSession extends HiveObject {
  PlaybackSession({
    required this.soundId,
    required this.soundType,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.strength,
    this.completedFullDosage = false,
  });

  /// ID of the Tonic or Botanical played
  @HiveField(0)
  String soundId;

  /// Type: 'tonic' or 'botanical'
  @HiveField(1)
  String soundType;

  /// When playback started
  @HiveField(2)
  DateTime startTime;

  /// When playback ended
  @HiveField(3)
  DateTime endTime;

  /// Actual duration played in minutes
  @HiveField(4)
  int durationMinutes;

  /// Volume strength used (0.0 to 1.0)
  @HiveField(5)
  double strength;

  /// Whether the user completed the full dosage without stopping early
  @HiveField(6)
  bool completedFullDosage;

  /// Box name for Hive storage
  static const String boxName = 'playback_sessions';
}
