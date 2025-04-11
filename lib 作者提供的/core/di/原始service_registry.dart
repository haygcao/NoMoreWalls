import 'package:get_it/get_it.dart';
import 'package:spotube/core/base/services/base_service.dart';

/// 服务注册表，负责管理所有服务实现
class ServiceRegistry {
  final GetIt _getIt;
  
  // 单例实例
  static final ServiceRegistry _instance = ServiceRegistry._internal(GetIt.instance);
  
  // 获取单例实例
  static ServiceRegistry get instance => _instance;
  
  // 私有构造函数
  ServiceRegistry._internal(this._getIt);
  
  /// 注册服务实现
  void register<T extends BaseService>(T implementation) {
    final platformId = implementation.platformId;
    final serviceType = T.toString();
    
    // 使用服务类型和平台ID作为唯一标识
    final instanceName = '${serviceType}_$platformId';
    
    if (!_getIt.isRegistered<T>(instanceName: instanceName)) {
      _getIt.registerSingleton<T>(
        implementation,
        instanceName: instanceName,
      );
      
      print('已注册服务: $serviceType, 平台: $platformId');
    }
  }
  
  /// 获取特定平台的服务实现
  T? getServiceForPlatform<T extends BaseService>(String platformId) {
    final serviceType = T.toString();
    final instanceName = '${serviceType}_$platformId';
    
    try {
      return _getIt.get<T>(instanceName: instanceName);
    } catch (e) {
      print('获取平台 $platformId 的服务 $serviceType 时出错: $e');
      return null;
    }
  }
  
  /// 获取特定类型的所有服务实现
  Map<String, T> getAllServicesOfType<T extends BaseService>() {
    final result = <String, T>{};
    final serviceType = T.toString();
    
    // 获取所有注册的实例名称
    final allInstanceNames = _getIt.allInstanceNames
        .where((name) => name.startsWith('${serviceType}_'))
        .toList();
    
    for (final instanceName in allInstanceNames) {
      try {
        final service = _getIt.get<T>(instanceName: instanceName);
        result[service.platformId] = service;
      } catch (e) {
        print('获取服务 $instanceName 时出错: $e');
      }
    }
    
    return result;
  }
}