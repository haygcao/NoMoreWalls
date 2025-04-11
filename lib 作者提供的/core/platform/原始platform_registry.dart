import 'package:spotube/core/di/service_registry.dart';
import 'package:spotube/core/base/services/auth_service.dart';
import 'package:spotube/core/base/services/track_service.dart';
import 'package:spotube/core/base/services/album_service.dart';
import 'package:spotube/core/base/services/artist_service.dart';
import 'package:spotube/core/base/services/playlist_service.dart';
import 'package:spotube/core/base/services/search_service.dart';
import 'package:spotube/core/base/services/player_service.dart';

/// 平台注册表，负责发现和管理所有平台
class PlatformRegistry {
  // 单例实例
  static final PlatformRegistry _instance = PlatformRegistry._internal();
  
  // 获取单例实例
  static PlatformRegistry get instance => _instance;
  
  // 私有构造函数
  PlatformRegistry._internal();
  
  // 存储已发现的平台ID
  final Set<String> _discoveredPlatforms = {};
  
  // 获取所有已发现的平台ID
  List<String> get availablePlatforms => _discoveredPlatforms.toList();
  
  // 初始化并发现所有平台
  Future<void> discoverPlatforms() async {
    // 从各种服务实现中提取平台ID
    _discoverPlatformsFromServices<AuthService>();
    _discoverPlatformsFromServices<TrackService>();
    _discoverPlatformsFromServices<AlbumService>();
    _discoverPlatformsFromServices<ArtistService>();
    _discoverPlatformsFromServices<PlaylistService>();
    _discoverPlatformsFromServices<SearchService>();
    _discoverPlatformsFromServices<PlayerService>();
    
    print('已发现平台: $_discoveredPlatforms');
  }
  
  // 从特定类型的服务中发现平台
  void _discoverPlatformsFromServices<T extends BaseService>() {
    final services = ServiceRegistry.instance.getAllServicesOfType<T>();
    for (final platformId in services.keys) {
      _discoveredPlatforms.add(platformId);
    }
  }
  
  // 获取特定类型和平台的服务
  T? getServiceForPlatform<T extends BaseService>(String platformId) {
    return ServiceRegistry.instance.getServiceForPlatform<T>(platformId);
  }
  
  // 获取特定类型的所有服务
  Map<String, T> getAllServicesOfType<T extends BaseService>() {
    return ServiceRegistry.instance.getAllServicesOfType<T>();
  }
  
  // 注册平台服务
  void registerPlatformService<T extends BaseService>(T implementation) {
    ServiceRegistry.instance.register<T>(implementation);
    _discoveredPlatforms.add(implementation.platformId);
  }
}