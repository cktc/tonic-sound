import 'package:hive/hive.dart';

part 'quiz_response.g.dart';

/// Stores user's responses to the personalization quiz.
/// Used to generate prescription recommendations.
@HiveType(typeId: 1)
class QuizResponse extends HiveObject {
  QuizResponse({
    required this.questionId,
    required this.selectedOptionIndex,
    required this.timestamp,
  });

  /// Unique identifier for the question
  @HiveField(0)
  String questionId;

  /// Index of the selected option (0-based)
  @HiveField(1)
  int selectedOptionIndex;

  /// When the response was recorded
  @HiveField(2)
  DateTime timestamp;

  /// Box name for Hive storage
  static const String boxName = 'quiz_responses';
}
