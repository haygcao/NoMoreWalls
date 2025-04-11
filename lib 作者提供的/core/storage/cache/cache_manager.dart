import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:spotube/core/storage/cache/cache_config.dart';
import 'package:spotube/core/storage/cache/cache_keys.dart';

/// 缓存管理器
class CacheManager {
  /// 默认缓存管理器
  static final CacheManager _instance = CacheManager._internal();
  
  /// 获取单例实例
  static CacheManager get instance => _instance;
  
  /// 缓存配置
  late CacheConfig _config;
  
  /// 文件缓存管理器
  late DefaultCacheManager _fileCacheManager;
  
  /// 私有构造函数
  CacheManager._internal();
  
  /// 初始化缓存管理器
  Future<void> initialize(CacheConfig config) async {
    _config = config;
    _fileCacheManager = DefaultCacheManager();
    
    // 确保缓存目录存在
    final directory = Directory(_config.cacheDir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // 清理过期缓存
    await _cleanExpiredCache();
  }
  
  /// 将对象存储到缓存
  Future<void> putObject(String key, dynamic object) async {
    final jsonString = jsonEncode(object);
    await _fileCacheManager.putFile(
      key,
      utf8.encode(jsonString) as List<int>,
      maxAge: Duration(seconds: _config.stalePeriod),
    );
  }
  
  /// 从缓存获取对象
  Future<dynamic> getObject(String key) async {
    try {
      final fileInfo = await _fileCacheManager.getFileFromCache(key);
      if (fileInfo == null) {
        return null;
      }
      
      final file = fileInfo.file;
      final jsonString = await file.readAsString();
      return jsonDecode(jsonString);
    } catch (e) {
      print('从缓存获取对象时出错: $e');
      return null;
    }
  }
  
  /// 将文件存储到缓存
  Future<File> putFile(String key, List<int> bytes) async {
    return await _fileCacheManager.putFile(
      key,
      bytes,
      maxAge: Duration(seconds: _config.stalePeriod),
    );
  }
  
  /// 从缓存获取文件
  Future<File?> getFile(String key) async {
    try {
      final fileInfo = await _fileCacheManager.getFileFromCache(key);
      return fileInfo?.file;
    } catch (e) {
      print('从缓存获取文件时出错: $e');
      return null;
    }
  }
  
  /// 从缓存移除对象
  Future<void> removeObject(String key) async {
    await _fileCacheManager.removeFile(key);
  }
  
  /// 清空缓存
  Future<void> clearCache() async {
    await _fileCacheManager.emptyCache();
  }
  
  /// 清理过期缓存
  Future<void> _cleanExpiredCache() async {
    await _fileCacheManager.emptyCache();
  }
  
  /// 获取缓存大小
  Future<int> getCacheSize() async {
    int size = 0;
    try {
      final directory = Directory(_config.cacheDir);
      await for (final file in directory.list(recursive: true, followLinks: false)) {
        if (file is File) {
          size += await file.length();
        }
      }
    } catch (e) {
      print('获取缓存大小时出错: $e');
    }
    return size;
  }
}