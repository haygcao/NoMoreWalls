import 'package:flutter/foundation.dart';

/// Cache configuration class
///
/// Contains constants and configuration for the cache system
class CacheConfig {
  /// Default cache expiration duration
  final Duration defaultExpiry;

  /// Maximum cache size in bytes
  final int maxCacheSize;

  /// Whether to enable cache logging
  final bool enableLogging;

  /// Create a new cache configuration
  CacheConfig({
    Duration? defaultExpiry,
    int? maxCacheSize,
    bool? enableLogging,
  })  : this.defaultExpiry = defaultExpiry ?? const Duration(hours: 24),
        this.maxCacheSize = maxCacheSize ?? 100 * 1024 * 1024, // 100 MB
        this.enableLogging = enableLogging ?? kDebugMode;

  /// Create a cache configuration with default values
  factory CacheConfig.defaultConfig() => CacheConfig();

  /// Create a cache configuration with no expiration
  factory CacheConfig.noExpiry() => CacheConfig(
        defaultExpiry: const Duration(days: 365),
      );

  /// Create a cache configuration with short expiration
  factory CacheConfig.shortLived() => CacheConfig(
        defaultExpiry: const Duration(minutes: 30),
      );

  /// Create a cache configuration with logging disabled
  factory CacheConfig.noLogging() => CacheConfig(
        enableLogging: false,
      );
}
