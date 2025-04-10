part of '../database.dart';

class AudioPlayerStateTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get playing => boolean()();
  TextColumn get loopMode => textEnum<PlaylistMode>()();
  BoolColumn get shuffled => boolean()();
  TextColumn get collections => text().map(const StringListConverter())();
}

// 重命名为 PlayQueueTable 以避免冲突
class PlayQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get audioPlayerStateId =>
      integer().references(AudioPlayerStateTable, #id)();
  IntColumn get index => integer()();
}

// 相应地更新引用
class PlaylistMediaTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId => integer().references(PlayQueueTable, #id)();

  TextColumn get uri => text()();
  TextColumn get extras =>
      text().nullable().map(const MapTypeConverter<String, dynamic>())();
  TextColumn get httpHeaders =>
      text().nullable().map(const MapTypeConverter<String, String>())();
}
