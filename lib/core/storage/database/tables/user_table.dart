import 'package:drift/drift.dart';

/// Database table definition for users
///
/// Defines the schema for storing user information
class UserTable extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// User ID from the platform
  TextColumn get userId => text()();

  /// User display name
  TextColumn get displayName => text()();

  /// User email
  TextColumn get email => text().nullable()();

  /// User country
  TextColumn get country => text().nullable()();

  /// User image URL
  TextColumn get imageUrl => text().nullable()();

  /// User followers count
  IntColumn get followersCount => integer().nullable()();

  /// User subscription type
  TextColumn get subscriptionType => text().nullable()();

  /// User birthdate
  DateTimeColumn get birthdate => dateTime().nullable()();

  /// Platform source (e.g., "spotify", "youtube_music")
  TextColumn get platform => text()();

  /// Authentication token
  TextColumn get authToken => text().nullable()();

  /// Refresh token
  TextColumn get refreshToken => text().nullable()();

  /// Token expiration date
  DateTimeColumn get tokenExpiration => dateTime().nullable()();

  /// Last updated timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Platform-specific metadata (JSON string)
  TextColumn get platformMetadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(userId, platform)',
      ];
}
