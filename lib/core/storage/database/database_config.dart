import 'package:flutter/foundation.dart';

/// Database configuration class
///
/// Contains constants and configuration for the database
class DatabaseConfig {
  /// Database name
  static const String databaseName = 'spotube.sqlite';

  /// Database version
  static const int databaseVersion = 1;

  /// Whether to log database statements
  static final bool logStatements = kDebugMode;

  /// Maximum number of items to cache
  static const int maxCacheItems = 1000;

  /// Cache expiration time in hours
  static const int cacheExpirationHours = 24;

  /// Private constructor to prevent instantiation
  DatabaseConfig._();
}
