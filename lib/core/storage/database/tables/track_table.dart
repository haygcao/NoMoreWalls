import 'package:drift/drift.dart';

/// Database table definition for tracks
///
/// Defines the schema for storing track information
class TrackTable extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Track ID from the platform
  TextColumn get trackId => text()();

  /// Track name
  TextColumn get name => text()();

  /// Track duration in milliseconds
  IntColumn get durationMs => integer()();

  /// Track image URL
  TextColumn get imageUrl => text().nullable()();

  /// Track preview URL
  TextColumn get previewUrl => text().nullable()();

  /// Track explicit flag
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();

  /// Track popularity (0-100)
  IntColumn get popularity => integer().withDefault(const Constant(0))();

  /// Track album ID
  TextColumn get albumId => text().nullable()();

  /// Track album name
  TextColumn get albumName => text().nullable()();

  /// Track artist IDs (comma-separated)
  TextColumn get artistIds => text()();

  /// Track artist names (comma-separated)
  TextColumn get artistNames => text()();

  /// Platform source (e.g., "spotify", "youtube_music")
  TextColumn get platform => text()();

  /// Last updated timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Platform-specific metadata (JSON string)
  TextColumn get platformMetadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(trackId, platform)',
      ];
}
