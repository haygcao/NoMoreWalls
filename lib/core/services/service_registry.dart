import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../base/services/base_service.dart';

/// 服务注册表 - 负责管理所有服务的注册和发现
///
/// 提供服务工厂注册和自动发现机制，是整个架构的核心组件
class ServiceRegistry {
  /// 单例实例
  static final ServiceRegistry _instance = ServiceRegistry._internal();

  /// 获取单例实例
  factory ServiceRegistry() => _instance;

  /// 私有构造函数
  ServiceRegistry._internal();

  /// GetIt实例
  final GetIt _getIt = GetIt.instance;

  /// 服务工厂映射表 - 存储服务类型和工厂函数的映射
  final Map<Type, Map<String, ServiceFactory>> _serviceFactories = {};

  /// 已注册的服务实例 - 存储服务类型和实例的映射
  final Map<Type, Map<String, BaseService>> _registeredServices = {};

  /// 服务状态映射表 - 存储服务类型和状态的映射
  final Map<Type, Map<String, ServiceStatus>> _serviceStatus = {};

  /// 注册服务工厂
  ///
  /// [serviceType] 服务类型
  /// [platform] 平台标识
  /// [factory] 服务工厂函数
  void registerServiceFactory<T extends BaseService>(
    String platform,
    T Function() factory,
  ) {
    final type = T;
    _serviceFactories[type] ??= {};
    _serviceFactories[type]![platform] = ServiceFactory<T>(factory);

    // 更新服务状态
    _serviceStatus[type] ??= {};
    _serviceStatus[type]![platform] = ServiceStatus.initializing;

    debugPrint('已注册服务工厂: $type - $platform');
  }

  /// 获取指定类型和平台的服务
  ///
  /// [serviceType] 服务类型
  /// [platform] 平台标识
  T? getService<T extends BaseService>(String platform) {
    // 检查服务是否已注册
    if (_registeredServices.containsKey(T) &&
        _registeredServices[T]!.containsKey(platform)) {
      return _registeredServices[T]![platform] as T;
    }

    // 检查是否有对应的工厂
    if (!_serviceFactories.containsKey(T) ||
        !_serviceFactories[T]!.containsKey(platform)) {
      debugPrint('未找到服务工厂: $T - $platform');
      return null;
    }

    // 创建服务实例
    try {
      final factory = _serviceFactories[T]![platform]!;
      final service = factory.create() as T;

      // 注册到GetIt
      if (!_getIt.isRegistered<T>(instanceName: platform)) {
        _getIt.registerSingleton<T>(service, instanceName: platform);
      }

      // 存储服务实例
      _registeredServices[T] ??= {};
      _registeredServices[T]![platform] = service;

      // 更新服务状态
      _serviceStatus[T] ??= {};
      _serviceStatus[T]![platform] = ServiceStatus.available;

      debugPrint('已创建服务实例: $T - $platform');
      return service;
    } catch (e) {
      debugPrint('创建服务实例失败: $T - $platform - $e');
      _serviceStatus[T] ??= {};
      _serviceStatus[T]![platform] = ServiceStatus.error;
      return null;
    }
  }

  /// 自动发现并注册所有服务
  ///
  /// 遍历所有注册的服务工厂，创建服务实例并初始化
  Future<void> autoDiscoverAndRegister() async {
    debugPrint('开始自动发现并注册服务...');

    for (final type in _serviceFactories.keys) {
      for (final platform in _serviceFactories[type]!.keys) {
        try {
          final factory = _serviceFactories[type]![platform]!;
          final service = factory.create();

          // 初始化服务
          await service.initialize();

          // 检查服务是否可用
          final isAvailable = await service.isAvailable();
          if (!isAvailable) {
            debugPrint('服务不可用: $type - $platform');
            _serviceStatus[type] ??= {};
            _serviceStatus[type]![platform] = ServiceStatus.notConfigured;
            continue;
          }

          // 注册到GetIt
          if (!_getIt.isRegistered(instanceName: '${type}_$platform')) {
            _getIt.registerSingleton(service,
                instanceName: '${type}_$platform');
          }

          // 存储服务实例
          _registeredServices[type] ??= {};
          _registeredServices[type]![platform] = service;

          // 更新服务状态
          _serviceStatus[type] ??= {};
          _serviceStatus[type]![platform] = ServiceStatus.available;

          debugPrint('已自动注册服务: $type - $platform');
        } catch (e) {
          debugPrint('自动注册服务失败: $type - $platform - $e');
          _serviceStatus[type] ??= {};
          _serviceStatus[type]![platform] = ServiceStatus.error;
        }
      }
    }

    debugPrint('自动发现并注册服务完成');
  }

  /// 获取指定类型的所有可用平台
  List<String> getAvailablePlatforms<T extends BaseService>() {
    if (!_serviceFactories.containsKey(T)) {
      return [];
    }

    return _serviceFactories[T]!.keys.toList();
  }

  /// 获取指定类型和平台的服务状态
  ServiceStatus getServiceStatus<T extends BaseService>(String platform) {
    if (!_serviceStatus.containsKey(T) ||
        !_serviceStatus[T]!.containsKey(platform)) {
      return ServiceStatus.notConfigured;
    }

    return _serviceStatus[T]![platform]!;
  }

  /// 获取所有已注册的服务类型
  List<Type> getRegisteredServiceTypes() {
    return _serviceFactories.keys.toList();
  }

  /// 清理所有服务
  Future<void> dispose() async {
    debugPrint('开始清理所有服务...');

    for (final type in _registeredServices.keys) {
      for (final platform in _registeredServices[type]!.keys) {
        try {
          final service = _registeredServices[type]![platform]!;
          await service.dispose();

          // 从GetIt中注销
          if (_getIt.isRegistered(instanceName: '${type}_$platform')) {
            _getIt.unregister(instanceName: '${type}_$platform');
          }

          debugPrint('已清理服务: $type - $platform');
        } catch (e) {
          debugPrint('清理服务失败: $type - $platform - $e');
        }
      }
    }

    _registeredServices.clear();
    _serviceStatus.clear();

    debugPrint('清理所有服务完成');
  }
}

/// 服务工厂类 - 用于创建服务实例
class ServiceFactory<T extends BaseService> {
  /// 工厂函数
  final T Function() _factory;

  /// 创建一个服务工厂
  ServiceFactory(this._factory);

  /// 创建服务实例
  T create() => _factory();
}
