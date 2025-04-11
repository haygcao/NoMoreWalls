import 'package:drift/drift.dart';

/// Database table definition for playlists
///
/// Defines the schema for storing playlist information
class PlaylistTable extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Playlist ID from the platform
  TextColumn get playlistId => text()();

  /// Playlist name
  TextColumn get name => text()();

  /// Playlist description
  TextColumn get description => text().nullable()();

  /// Playlist image URL
  TextColumn get imageUrl => text().nullable()();

  /// Playlist owner ID
  TextColumn get ownerId => text().nullable()();

  /// Playlist owner name
  TextColumn get ownerName => text().nullable()();

  /// Whether the playlist is public
  BoolColumn get isPublic => boolean().withDefault(const Constant(true))();

  /// Whether the playlist is collaborative
  BoolColumn get isCollaborative =>
      boolean().withDefault(const Constant(false))();

  /// Total number of tracks
  IntColumn get totalTracks => integer().withDefault(const Constant(0))();

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
        'UNIQUE(playlistId, platform)',
      ];
}
