// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 0;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      onboardingComplete: fields[0] as bool,
      lastSelectedTonicId: fields[1] as String,
      lastSelectedBotanicalId: fields[2] as String?,
      lastUsedSoundType: fields[3] as String,
      defaultStrength: fields[4] as double,
      defaultDosageMinutes: fields[5] as int,
      onboardingMethod: fields[6] as String?,
      contextualQuizPromptShown: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.onboardingComplete)
      ..writeByte(1)
      ..write(obj.lastSelectedTonicId)
      ..writeByte(2)
      ..write(obj.lastSelectedBotanicalId)
      ..writeByte(3)
      ..write(obj.lastUsedSoundType)
      ..writeByte(4)
      ..write(obj.defaultStrength)
      ..writeByte(5)
      ..write(obj.defaultDosageMinutes)
      ..writeByte(6)
      ..write(obj.onboardingMethod)
      ..writeByte(7)
      ..write(obj.contextualQuizPromptShown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
