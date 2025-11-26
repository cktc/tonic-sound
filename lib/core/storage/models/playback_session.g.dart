// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaybackSessionAdapter extends TypeAdapter<PlaybackSession> {
  @override
  final int typeId = 2;

  @override
  PlaybackSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaybackSession(
      soundId: fields[0] as String,
      soundType: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime,
      durationMinutes: fields[4] as int,
      strength: fields[5] as double,
      completedFullDosage: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlaybackSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.soundId)
      ..writeByte(1)
      ..write(obj.soundType)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.strength)
      ..writeByte(6)
      ..write(obj.completedFullDosage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
