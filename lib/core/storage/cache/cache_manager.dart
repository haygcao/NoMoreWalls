import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cache_config.dart';
import 'cache_keys.dart';

/// Cache manager for the application
///
/// Provides methods for storing and retrieving cached data
class CacheManager {
  /// Singleton instance
  static final CacheManager _instance = CacheManager._internal();

  /// Factory constructor
  factory CacheManager() => _instance;

  /// Private constructor
  CacheManager._internal();

  /// Shared preferences instance
  late SharedPreferences _prefs;

  /// Cache directory
  late Directory _cacheDir;

  /// Cache configuration
  late CacheConfig _config;

  /// Initialize the cache manager
  Future<void> initialize({
    CacheConfig? config,
  }) async {
    _config = config ?? CacheConfig();
    _prefs = await SharedPreferences.getInstance();
    _cacheDir = await _getCacheDirectory();

    // Create cache directory if it doesn't exist
    if (!_cacheDir.existsSync()) {
      _cacheDir.createSync(recursive: true);
    }

    debugPrint('Cache initialized at: ${_cacheDir.path}');
  }

  /// Get the cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/cache');
  }

  /// Store data in the cache
  Future<void> put(
    String key,
    dynamic data, {
    Duration? expiry,
  }) async {
    final expiryDuration = expiry ?? _config.defaultExpiry;
    final expiryTime = DateTime.now().add(expiryDuration);

    final cacheData = {
      'data': data,
      'expiry': expiryTime.millisecondsSinceEpoch,
    };

    if (data is String || data is num || data is bool) {
      // Store simple data in SharedPreferences
      await _prefs.setString(key, jsonEncode(cacheData));
    } else {
      // Store complex data in file system
      final file = File('${_cacheDir.path}/$key');
      await file.writeAsString(jsonEncode(cacheData));
    }
  }

  /// Get data from the cache
  Future<T?> get<T>(String key) async {
    try {
      // Try to get from SharedPreferences first
      String? jsonData = _prefs.getString(key);

      // If not found in SharedPreferences, try file system
      if (jsonData == null) {
        final file = File('${_cacheDir.path}/$key');
        if (!file.existsSync()) {
          return null;
        }
        jsonData = await file.readAsString();
      }

      final cacheData = jsonDecode(jsonData!);
      final expiryTime =
          DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);

      // Check if cache has expired
      if (DateTime.now().isAfter(expiryTime)) {
        await remove(key);
        return null;
      }

      return cacheData['data'] as T;
    } catch (e) {
      debugPrint('Error retrieving from cache: $e');
      return null;
    }
  }

  /// Remove data from the cache
  Future<void> remove(String key) async {
    // Remove from SharedPreferences
    await _prefs.remove(key);

    // Remove from file system
    final file = File('${_cacheDir.path}/$key');
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Clear all cache data
  Future<void> clear() async {
    // Clear SharedPreferences
    await _prefs.clear();

    // Clear file system cache
    if (_cacheDir.existsSync()) {
      final files = _cacheDir.listSync();
      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }
    }
  }

  /// Check if a key exists in the cache
  Future<bool> exists(String key) async {
    // Check in SharedPreferences
    if (_prefs.containsKey(key)) {
      return true;
    }

    // Check in file system
    final file = File('${_cacheDir.path}/$key');
    return file.existsSync();
  }

  /// Get the size of the cache in bytes
  Future<int> getSize() async {
    int size = 0;

    // Calculate file system cache size
    if (_cacheDir.existsSync()) {
      final files = _cacheDir.listSync();
      for (final file in files) {
        if (file is File) {
          size += await file.length();
        }
      }
    }

    return size;
  }
}
