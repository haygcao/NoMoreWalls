import 'package:drift/drift.dart';

/// Database table definition for albums
///
/// Defines the schema for storing album information
class AlbumTable extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Album ID from the platform
  TextColumn get albumId => text()();

  /// Album name
  TextColumn get name => text()();

  /// Album image URL
  TextColumn get imageUrl => text().nullable()();

  /// Album release date
  DateTimeColumn get releaseDate => dateTime().nullable()();

  /// Album type (e.g., "album", "single", "compilation")
  TextColumn get albumType => text().nullable()();

  /// Total number of tracks
  IntColumn get totalTracks => integer().withDefault(const Constant(0))();

  /// Album artist IDs (comma-separated)
  TextColumn get artistIds => text()();

  /// Album artist names (comma-separated)
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
        'UNIQUE(albumId, platform)',
      ];
}
