import 'package:drift/drift.dart';

/// Database table definition for artists
///
/// Defines the schema for storing artist information
class ArtistTable extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Artist ID from the platform
  TextColumn get artistId => text()();

  /// Artist name
  TextColumn get name => text()();

  /// Artist image URL
  TextColumn get imageUrl => text().nullable()();

  /// Artist description/biography
  TextColumn get description => text().nullable()();

  /// Artist popularity (0-100)
  IntColumn get popularity => integer().withDefault(const Constant(0))();

  /// Artist followers count
  IntColumn get followersCount => integer().withDefault(const Constant(0))();

  /// Artist genres (comma-separated)
  TextColumn get genres => text().nullable()();

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
        'UNIQUE(artistId, platform)',
      ];
}
