import 'package:spotube/core/di/service_registry.dart';
import 'package:spotube/core/base/services/base_service.dart';

/// 平台注册表，负责发现和管理所有平台
class PlatformRegistry {
  // 单例实例
  static final PlatformRegistry _instance = PlatformRegistry._internal();
  
  // 获取单例实例
  static PlatformRegistry get instance => _instance;
  
  // 私有构造函数
  PlatformRegistry._internal();
  
  // 当前活跃平台ID
  String _activePlatformId = '';
  
  // 获取当前活跃平台ID
  String get activePlatformId => _activePlatformId;
  
  // 设置当前活跃平台ID
  set activePlatformId(String platformId) {
    final platforms = availablePlatforms;
    if (platforms.contains(platformId)) {
      _activePlatformId = platformId;
      print('已设置活跃平台: $platformId');
    } else {
      print('平台 $platformId 不可用');
    }
  }
  
  // 获取所有可用平台
  List<String> get availablePlatforms => ServiceRegistry.instance.getRegisteredPlatforms();
  
  // 初始化并发现所有平台
  Future<void> discoverPlatforms() async {
    // 平台发现逻辑已经在ServiceRegistry中实现
    // 这里可以添加额外的平台发现逻辑
    
    // 如果有可用平台，设置第一个为活跃平台
    final platforms = availablePlatforms;
    if (platforms.isNotEmpty && _activePlatformId.isEmpty) {
      _activePlatformId = platforms.first;
      print('已自动设置活跃平台: $_activePlatformId');
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
  
  // 获取当前活跃平台的服务
  T? getActiveService<T extends BaseService>() {
    return getServiceForPlatform<T>(_activePlatformId);
  }
  
  // 注册平台服务
  void registerPlatformService<T extends BaseService>(T implementation) {
    ServiceRegistry.instance.register<T>(implementation);
  }
}