import 'package:spotube/core/platform/platform_registry.dart';

/// 平台服务，负责管理当前活跃平台
class PlatformService {
  // 单例实例
  static final PlatformService _instance = PlatformService._internal();
  
  // 获取单例实例
  static PlatformService get instance => _instance;
  
  // 私有构造函数
  PlatformService._internal();
  
  // 当前活跃平台ID
  String _activePlatformId = '';
  
  // 获取当前活跃平台ID
  String get activePlatformId => _activePlatformId;
  
  // 设置当前活跃平台ID
  set activePlatformId(String platformId) {
    if (PlatformRegistry.instance.availablePlatforms.contains(platformId)) {
      _activePlatformId = platformId;
      print('已设置活跃平台: $platformId');
    } else {
      print('平台 $platformId 不可用');
    }
  }
  
  // 获取所有可用平台
  List<String> get availablePlatforms => PlatformRegistry.instance.availablePlatforms;
  
  // 初始化平台服务
  Future<void> initialize() async {
    await PlatformRegistry.instance.discoverPlatforms();
    
    // 如果有可用平台，设置第一个为活跃平台
    final platforms = availablePlatforms;
    if (platforms.isNotEmpty && _activePlatformId.isEmpty) {
      _activePlatformId = platforms.first;
      print('已自动设置活跃平台: $_activePlatformId');
    }
  }
}