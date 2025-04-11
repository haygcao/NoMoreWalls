import 'package:drift/drift.dart';

/// Database table definition for collections
///
/// Defines the schema for storing collection information
class CollectionTable extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Collection ID from the platform
  TextColumn get collectionId => text()();

  /// Collection name
  TextColumn get name => text()();

  /// Collection description
  TextColumn get description => text().nullable()();

  /// Collection image URL
  TextColumn get imageUrl => text().nullable()();

  /// Collection owner ID
  TextColumn get ownerId => text().nullable()();

  /// Collection owner name
  TextColumn get ownerName => text().nullable()();

  /// Collection item count
  IntColumn get itemCount => integer().withDefault(const Constant(0))();

  /// Collection item type (e.g., "track", "album", "artist")
  TextColumn get itemType => text()();

  /// Collection is public flag
  BoolColumn get isPublic => boolean().withDefault(const Constant(true))();

  /// Collection is collaborative flag
  BoolColumn get isCollaborative =>
      boolean().withDefault(const Constant(false))();

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
        'UNIQUE(collectionId, platform)',
      ];
}
