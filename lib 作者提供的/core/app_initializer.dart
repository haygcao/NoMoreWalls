import 'package:spotube/core/platform/platform_registry.dart';
import 'package:spotube/core/storage/cache/cache_manager.dart';
import 'package:spotube/core/storage/cache/cache_config.dart';
import 'package:spotube/core/storage/database/app_database.dart';
import 'package:spotube/core/storage/database/database_config.dart';
import 'package:spotube/core/di/service_locator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 应用初始化器
class AppInitializer {
  // 单例实例
  static final AppInitializer _instance = AppInitializer._internal();
  
  // 获取单例实例
  static AppInitializer get instance => _instance;
  
  // 私有构造函数
  AppInitializer._internal();
  
  // 数据库实例
  AppDatabase? _database;
  
  // 获取数据库实例
  AppDatabase get database {
    if (_database == null) {
      throw Exception('数据库未初始化，请先调用 initialize() 方法');
    }
    return _database!;
  }
  
  /// 初始化应用
  Future<void> initialize() async {
    // 初始化依赖注入
    await ServiceLocator.setupDependencies();
    
    // 初始化缓存
    await _initializeCache();
    
    // 初始化数据库
    await _initializeDatabase();
    
    // 发现平台
    await PlatformRegistry.instance.discoverPlatforms();
    
    print('应用初始化完成');
  }
  
  /// 初始化缓存
  Future<void> _initializeCache() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = path.join(appDir.path, 'cache');
    
    final cacheConfig = CacheConfig(
      cacheDir: cacheDir,
      maxCacheSize: 200 * 1024 * 1024, // 200MB
      stalePeriod: 7 * 24 * 60 * 60, // 7天
    );
    
    await CacheManager.instance.initialize(cacheConfig);
    
    print('缓存初始化完成');
  }
  
  /// 初始化数据库
  Future<void> _initializeDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(appDir.path, 'database');
    
    final dbConfig = DatabaseConfig(
      databaseName: 'spotube.db',
      version: 1,
      logStatements: false,
    );
    
    _database = AppDatabase(dbConfig);
    
    print('数据库初始化完成');
  }
  
  /// 释放资源
  Future<void> dispose() async {
    // 关闭数据库
    if (_database != null) {
      await _database!.closeDatabase();
      _database = null;
    }
    
    print('应用资源已释放');
  }
}