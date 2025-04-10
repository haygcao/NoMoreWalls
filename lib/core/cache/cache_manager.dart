import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

/// CacheManager负责管理应用的缓存功能
class CacheManager extends ChangeNotifier {
  late final String _cacheDir;
  final Map<String, String> _musicCache = {};
  final DefaultCacheManager _imageCacheManager = DefaultCacheManager();
  final Map<String, dynamic> _dataCache = {};

  CacheManager() {
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = '${appDir.path}/cache';
    await Directory(_cacheDir).create(recursive: true);
  }

  // 音乐文件缓存
  Future<String?> getCachedMusic(String musicId) async {
    return _musicCache[musicId];
  }

  Future<void> cacheMusic(String musicId, String filePath) async {
    final cacheFilePath = '$_cacheDir/music/$musicId';
    await File(filePath).copy(cacheFilePath);
    _musicCache[musicId] = cacheFilePath;
    notifyListeners();
  }

  Future<void> removeMusicCache(String musicId) async {
    final cachePath = _musicCache[musicId];
    if (cachePath != null) {
      await File(cachePath).delete();
      _musicCache.remove(musicId);
      notifyListeners();
    }
  }

  // 图片缓存
  Future<File?> getCachedImage(String url) async {
    try {
      final fileInfo = await _imageCacheManager.getFileFromCache(url);
      return fileInfo?.file;
    } catch (e) {
      return null;
    }
  }

  Future<File> cacheImage(String url) async {
    final fileInfo = await _imageCacheManager.downloadFile(url);
    return fileInfo.file;
  }

  Future<void> removeImageCache(String url) async {
    await _imageCacheManager.removeFile(url);
  }

  // 用户数据缓存
  T? getCachedData<T>(String key) {
    return _dataCache[key] as T?;
  }

  void cacheData<T>(String key, T data) {
    _dataCache[key] = data;
    notifyListeners();
  }

  void removeCachedData(String key) {
    _dataCache.remove(key);
    notifyListeners();
  }

  // 缓存清理
  Future<void> clearMusicCache() async {
    final musicDir = Directory('$_cacheDir/music');
    if (await musicDir.exists()) {
      await musicDir.delete(recursive: true);
    }
    _musicCache.clear();
    notifyListeners();
  }

  Future<void> clearImageCache() async {
    await _imageCacheManager.emptyCache();
  }

  void clearDataCache() {
    _dataCache.clear();
    notifyListeners();
  }

  Future<void> clearAllCache() async {
    await clearMusicCache();
    await clearImageCache();
    clearDataCache();
  }

  // 缓存状态
  bool isMusicCached(String musicId) => _musicCache.containsKey(musicId);

  Future<int> getCacheSize() async {
    int totalSize = 0;
    final cacheDir = Directory(_cacheDir);
    if (await cacheDir.exists()) {
      await for (final file in cacheDir.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }
    return totalSize;
  }
}

// Provider定义
final cacheManagerProvider = ChangeNotifierProvider<CacheManager>((ref) {
  return CacheManager();
});
