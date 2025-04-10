import 'auth_manager.dart';

/// 服务注册表 - 用于管理不同平台的认证实现
class ServiceRegistry {
  static final ServiceRegistry _instance = ServiceRegistry._internal();
  factory ServiceRegistry() => _instance;
  ServiceRegistry._internal();

  final Map<String, AuthManager Function()> _authManagers = {};
  AuthManager? _currentManager;

  /// 注册认证管理器
  void registerAuthManager(String platform, AuthManager Function() factory) {
    _authManagers[platform] = factory;
  }

  /// 获取指定平台的认证管理器
  AuthManager getAuthManager(String platform) {
    if (!_authManagers.containsKey(platform)) {
      throw Exception('No auth manager registered for platform: $platform');
    }

    _currentManager?.dispose();
    _currentManager = _authManagers[platform]!();
    return _currentManager!;
  }

  /// 获取当前活跃的认证管理器
  AuthManager? get currentManager => _currentManager;

  /// 获取所有可用的平台
  List<String> get availablePlatforms => _authManagers.keys.toList();

  /// 清理当前管理器
  void clearCurrentManager() {
    _currentManager?.dispose();
    _currentManager = null;
  }

  /// 清理所有注册的服务
  void dispose() {
    clearCurrentManager();
    _authManagers.clear();
  }
}
