import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../base/services/base_service.dart';
import '../services/service_registry.dart';

/// 平台注册表 - 负责管理所有平台服务的注册和发现
///
/// 提供平台服务工厂注册和自动发现机制，是平台服务架构的核心组件
class PlatformRegistry {
  /// 获取单例实例
  factory PlatformRegistry() => _instance;

  /// 私有构造函数
  PlatformRegistry._internal();

  /// 单例实例
  static final PlatformRegistry _instance = PlatformRegistry._internal();

  /// 当前活跃平台ID
  String _activePlatformId = '';

  /// GetIt实例
  final GetIt _getIt = GetIt.instance;

  /// 平台工厂映射表 - 存储平台ID和工厂函数的映射
  final Map<String, PlatformServiceFactory> _platformFactories = {};

  /// 平台状态映射表 - 存储平台ID和状态的映射
  final Map<String, ServiceStatus> _platformStatus = {};

  /// 已注册的平台实例 - 存储平台ID和实例的映射
  final Map<String, PlatformService> _registeredPlatforms = {};

  /// 服务注册表实例
  final ServiceRegistry _serviceRegistry = ServiceRegistry();

  /// 获取当前活跃平台ID
  String get activePlatformId => _activePlatformId;

  /// 设置当前活跃平台ID
  set activePlatformId(String platformId) {
    final platforms = availablePlatforms;
    if (platforms.contains(platformId)) {
      _activePlatformId = platformId;
      debugPrint('已设置活跃平台: $platformId');
    } else {
      debugPrint('平台 $platformId 不可用');
    }
  }

  /// 注册平台服务工厂
  ///
  /// [platformId] 平台标识
  /// [factory] 平台服务工厂函数
  void registerPlatformFactory(
    String platformId,
    PlatformService Function() factory,
  ) {
    _platformFactories[platformId] = PlatformServiceFactory(factory);

    // 更新平台状态
    _platformStatus[platformId] = ServiceStatus.initializing;

    debugPrint('已注册平台工厂: $platformId');
  }

  /// 获取指定平台的服务实例
  ///
  /// [platformId] 平台标识
  /// [serviceType] 服务类型
  T? getServiceForPlatform<T extends BaseService>(String platformId) {
    // 检查平台是否已注册
    if (!_registeredPlatforms.containsKey(platformId)) {
      debugPrint('未找到平台: $platformId');
      return null;
    }

    // 使用ServiceRegistry获取服务
    return _serviceRegistry.getService<T>(platformId);
  }

  /// 获取当前活跃平台的服务
  ///
  /// [serviceType] 服务类型
  T? getActiveService<T extends BaseService>() {
    if (_activePlatformId.isEmpty) {
      debugPrint('未设置活跃平台');
      return null;
    }
    return getServiceForPlatform<T>(_activePlatformId);
  }

  /// 获取特定类型的所有服务
  ///
  /// [serviceType] 服务类型
  Map<String, T> getAllServicesOfType<T extends BaseService>() {
    final result = <String, T>{};
    
    for (final platformId in _registeredPlatforms.keys) {
      final service = getServiceForPlatform<T>(platformId);
      if (service != null) {
        result[platformId] = service;
      }
    }
    
    return result;
  }

  /// 获取所有可用平台
  List<String> get availablePlatforms => _registeredPlatforms.keys.toList();

  /// 获取所有已注册的平台工厂
  List<String> get registeredPlatformFactories => _platformFactories.keys.toList();

  /// 获取指定平台的状态
  ServiceStatus getPlatformStatus(String platformId) {
    return _platformStatus[platformId] ?? ServiceStatus.notConfigured;
  }

  /// 自动发现并注册所有平台
  ///
  /// 遍历所有注册的平台工厂，创建平台实例并初始化
  Future<void> autoDiscoverAndRegister() async {
    debugPrint('开始自动发现并注册平台...');

    for (final platformId in _platformFactories.keys) {
      try {
        final factory = _platformFactories[platformId]!;
        final platform = factory.create();

        // 初始化平台
        await platform.initialize();

        // 检查平台是否可用
        final isAvailable = await platform.isAvailable();
        if (!isAvailable) {
          debugPrint('平台不可用: $platformId');
          _platformStatus[platformId] = ServiceStatus.notConfigured;
          continue;
        }

        // 注册到GetIt
        if (!_getIt.isRegistered(instanceName: 'platform_$platformId')) {
          _getIt.registerSingleton(platform,
              instanceName: 'platform_$platformId');
        }

        // 存储平台实例
        _registeredPlatforms[platformId] = platform;

        // 更新平台状态
        _platformStatus[platformId] = ServiceStatus.available;

        // 注册平台提供的服务
        await _registerPlatformServices(platform);

        debugPrint('已自动注册平台: $platformId');
      } catch (e) {
        debugPrint('自动注册平台失败: $platformId - $e');
        _platformStatus[platformId] = ServiceStatus.error;
      }
    }

    // 如果有可用平台，设置第一个为活跃平台
    if (_registeredPlatforms.isNotEmpty && _activePlatformId.isEmpty) {
      _activePlatformId = _registeredPlatforms.keys.first;
      debugPrint('已自动设置活跃平台: $_activePlatformId');
    }

    debugPrint('自动发现并注册平台完成');
  }

  /// 清理所有平台
  Future<void> dispose() async {
    debugPrint('开始清理所有平台...');

    // 清理ServiceRegistry
    await _serviceRegistry.dispose();

    // 清理平台实例
    for (final platformId in _registeredPlatforms.keys) {
      try {
        final platform = _registeredPlatforms[platformId]!;
        await platform.dispose();

        // 从GetIt中注销
        if (_getIt.isRegistered(instanceName: 'platform_$platformId')) {
          _getIt.unregister(instanceName: 'platform_$platformId');
        }

        debugPrint('已清理平台: $platformId');
      } catch (e) {
        debugPrint('清理平台失败: $platformId - $e');
      }
    }

    _registeredPlatforms.clear();
    _platformStatus.clear();
    _activePlatformId = '';

    debugPrint('清理所有平台完成');
  }

  /// 注册平台提供的服务
  ///
  /// [platform] 平台实例
  Future<void> _registerPlatformServices(PlatformService platform) async {
    final platformId = platform.platformId;
    final services = platform.getServices();

    for (final serviceFactory in services) {
      try {
        final service = serviceFactory.create();
        final serviceType = service.runtimeType;

        // 注册服务到ServiceRegistry
        _serviceRegistry.registerServiceFactory(
          platformId,
          () => service,
        );

        debugPrint('已注册服务: $serviceType - $platformId');
      } catch (e) {
        debugPrint('注册服务失败: $platformId - $e');
      }
    }
  }
}

/// 平台服务接口 - 定义平台服务的基本接口
abstract class PlatformService {
  /// 平台标识
  String get platformId;

  /// 平台名称
  String get platformName;

  /// 平台版本
  String get platformVersion => '1.0.0';

  /// 平台描述
  String get platformDescription => '';

  /// 初始化平台
  Future<void> initialize() async {};

  /// 检查平台是否可用
  Future<bool> isAvailable() async => true;

  /// 获取平台配置
  Map<String, dynamic> getPlatformConfig() => {};

  /// 更新平台配置
  Future<void> updatePlatformConfig(Map<String, dynamic> config) async {};

  /// 获取平台提供的服务工厂列表
  List<ServiceFactory> getServices() => [];

  /// 清理平台资源
  Future<void> dispose() async {};
}

/// 平台服务工厂类 - 用于创建平台服务实例
class PlatformServiceFactory {
  /// 创建一个平台服务工厂
  PlatformServiceFactory(this._factory);

  /// 工厂函数
  final PlatformService Function() _factory;

  /// 创建平台服务实例
  PlatformService create() => _factory();
}