// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizResponseAdapter extends TypeAdapter<QuizResponse> {
  @override
  final int typeId = 1;

  @override
  QuizResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizResponse(
      questionId: fields[0] as String,
      selectedOptionIndex: fields[1] as int,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuizResponse obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.selectedOptionIndex)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
