import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static final instance = CacheService._();
  CacheService._();

  late final DefaultCacheManager _cacheManager;
  late final String _cacheDir;

  Future<void> init() async {
    _cacheManager = DefaultCacheManager();
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = '${appDir.path}/cache';
    await Directory(_cacheDir).create(recursive: true);
  }

  Future<File> cacheFile(String url, {String? key}) async {
    final fileInfo = await _cacheManager.downloadFile(
      url,
      key: key ?? url,
    );
    return fileInfo.file;
  }

  Future<bool> hasValidCache(String key) async {
    final fileInfo = await _cacheManager.getFileFromCache(key);
    return fileInfo?.validTill.isAfter(DateTime.now()) ?? false;
  }

  Future<void> removeFile(String key) async {
    await _cacheManager.removeFile(key);
  }

  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    final cacheDir = Directory(_cacheDir);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create();
    }
  }

  Future<int> getCacheSize() async {
    var size = 0;
    final cacheDir = Directory(_cacheDir);
    if (await cacheDir.exists()) {
      await for (final file in cacheDir.list(recursive: true)) {
        if (file is File) {
          size += await file.length();
        }
      }
    }
    return size;
  }

  Future<void> pruneCache({Duration? maxAge}) async {
    await _cacheManager.emptyCache();
    final cacheDir = Directory(_cacheDir);
    if (await cacheDir.exists()) {
      await for (final file in cacheDir.list(recursive: true)) {
        if (file is File) {
          final stat = await file.stat();
          final age = DateTime.now().difference(stat.modified);
          if (maxAge != null && age > maxAge) {
            await file.delete();
          }
        }
      }
    }
  }
}

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.instance;
});
