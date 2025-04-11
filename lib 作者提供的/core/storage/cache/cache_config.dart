/// 缓存配置
class CacheConfig {
  /// 缓存目录
  final String cacheDir;
  
  /// 最大缓存大小（字节）
  final int maxCacheSize;
  
  /// 缓存有效期（秒）
  final int stalePeriod;
  
  /// 构造函数
  CacheConfig({
    required this.cacheDir,
    this.maxCacheSize = 100 * 1024 * 1024, // 默认100MB
    this.stalePeriod = 7 * 24 * 60 * 60, // 默认7天
  });
}