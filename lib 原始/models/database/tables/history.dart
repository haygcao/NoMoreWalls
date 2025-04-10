part of '../database.dart';

enum HistoryEntryType {
  playlist,
  album,
  track,
}

class HistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get type => textEnum<HistoryEntryType>()();
  TextColumn get itemId => text()();
  TextColumn get data =>
      text().map(const MapTypeConverter<String, dynamic>())();
}

extension HistoryItemParseExtension on HistoryTableData {
  // 将 PlaylistSimple 替换为 Playlist
  Playlist? get playlist =>
      type == HistoryEntryType.playlist ? Playlist.fromJson(data) : null;
  // 使用 Album 替换 AlbumSimple
  Album? get album =>
      type == HistoryEntryType.album ? Album.fromJson(data) : null;
  // 使用 SourceableTrack 替换 Track
  SourceableTrack? get track =>
      type == HistoryEntryType.track ? SourcedTrack.fromJson(data) : null;
}
