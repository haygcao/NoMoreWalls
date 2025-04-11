import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'database_config.dart';
import 'tables/track_table.dart';
import 'tables/album_table.dart';
import 'tables/artist_table.dart';
import 'tables/playlist_table.dart';
import 'tables/user_table.dart';
import 'tables/collection_table.dart';

part 'app_database.g.dart';

/// Main database class for the application
///
/// Manages all database operations and provides access to DAOs
@DriftDatabase(
  tables: [
    TrackTable,
    AlbumTable,
    ArtistTable,
    PlaylistTable,
    UserTable,
    CollectionTable,
  ],
  daos: [],
)
class AppDatabase extends _$AppDatabase {
  /// Create a new database instance
  AppDatabase() : super(_openConnection());

  /// The current schema version
  @override
  int get schemaVersion => 1;

  /// Perform migration when schema version changes
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration logic will be added here as needed
      },
    );
  }

  /// Close the database connection
  @override
  Future<void> close() async {
    await super.close();
  }
}

/// Open a database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spotube.sqlite'));
    return NativeDatabase(file, logStatements: kDebugMode);
  });
}
