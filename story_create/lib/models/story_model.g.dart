// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryModelAdapter extends TypeAdapter<StoryModel> {
  @override
  final int typeId = 0;

  @override
  StoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      mood: fields[3] as String,
      place: fields[4] as String,
      date: fields[5] as DateTime,
      imagePaths: (fields[6] as List).cast<String>(),
      musicPath: fields[7] as String?,
      videoOutputPath: fields[8] as String?,
      captions: (fields[9] as List?)?.cast<String>(),
      templateId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StoryModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.place)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.imagePaths)
      ..writeByte(7)
      ..write(obj.musicPath)
      ..writeByte(8)
      ..write(obj.videoOutputPath)
      ..writeByte(9)
      ..write(obj.captions)
      ..writeByte(10)
      ..write(obj.templateId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
