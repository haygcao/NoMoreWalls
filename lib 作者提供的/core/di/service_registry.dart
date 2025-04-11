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
    final serviceType = T;
    
    // 使用服务类型和平台ID作为唯一标识
    final instanceName = '${serviceType.toString()}_$platformId';
    
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
    final serviceType = T;
    final instanceName = '${serviceType.toString()}_$platformId';
    
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
    final serviceType = T;
    final prefix = '${serviceType.toString()}_';
    
    // 获取所有注册的实例名称
    final allInstanceNames = _getIt.allInstanceNames
        .where((name) => name.toString().startsWith(prefix))
        .toList();
    
    for (final instanceName in allInstanceNames) {
      try {
        final service = _getIt.get<T>(instanceName: instanceName.toString());
        result[service.platformId] = service;
      } catch (e) {
        print('获取服务 $instanceName 时出错: $e');
      }
    }
    
    return result;
  }
  
  /// 获取所有已注册的平台ID
  List<String> getRegisteredPlatforms() {
    final platforms = <String>{};
    final allInstanceNames = _getIt.allInstanceNames;
    
    for (final instanceName in allInstanceNames) {
      final name = instanceName.toString();
      if (name.contains('_')) {
        try {
          final parts = name.split('_');
          if (parts.length > 1) {
            final platformId = parts.last;
            platforms.add(platformId);
          }
        } catch (e) {
          print('解析实例名称 $name 时出错: $e');
        }
      }
    }
    
    return platforms.toList();
  }
  
  /// 清除所有注册的服务
  void clear() {
    // 获取所有BaseService类型的实例名称
    final allInstanceNames = _getIt.allInstanceNames.toList();
    
    for (final instanceName in allInstanceNames) {
      try {
        if (_getIt.isRegistered(instanceName: instanceName.toString())) {
          _getIt.unregister(instanceName: instanceName.toString());
        }
      } catch (e) {
        print('注销服务 $instanceName 时出错: $e');
      }
    }
  }
}