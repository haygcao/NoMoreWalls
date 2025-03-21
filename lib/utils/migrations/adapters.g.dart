// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adapters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkipSegmentAdapter extends TypeAdapter<SkipSegment> {
  @override
  final int typeId = 2;

  @override
  SkipSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkipSegment(
      fields[0] as int,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SkipSegment obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkipSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SourceMatchAdapter extends TypeAdapter<SourceMatch> {
  @override
  final int typeId = 6;

  @override
  SourceMatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SourceMatch(
      id: fields[0] as String,
      sourceId: fields[1] as String,
      sourceType: fields[2] as SourceType,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SourceMatch obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sourceId)
      ..writeByte(2)
      ..write(obj.sourceType)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceMatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SourceTypeAdapter extends TypeAdapter<SourceType> {
  @override
  final int typeId = 5;

  @override
  SourceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SourceType.youtube;
      case 1:
        return SourceType.youtubeMusic;
      case 2:
        return SourceType.jiosaavn;
      default:
        return SourceType.youtube;
    }
  }

  @override
  void write(BinaryWriter writer, SourceType obj) {
    switch (obj) {
      case SourceType.youtube:
        writer.writeByte(0);
        break;
      case SourceType.youtubeMusic:
        writer.writeByte(1);
        break;
      case SourceType.jiosaavn:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
