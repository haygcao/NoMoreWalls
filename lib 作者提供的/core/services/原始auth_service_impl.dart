import 'package:spotube/core/base/services/auth_service.dart';
import 'package:spotube/core/base/models/user_model.dart';
import 'package:spotube/core/platform/platform_registry.dart';
import 'package:spotube/core/services/platform_service.dart';

/// 核心认证服务实现
class AuthServiceImpl {
  // 单例实例
  static final AuthServiceImpl _instance = AuthServiceImpl._internal();
  
  // 获取单例实例
  static AuthServiceImpl get instance => _instance;
  
  // 私有构造函数
  AuthServiceImpl._internal();
  
  /// 获取所有平台的认证服务
  Map<String, AuthService> getAllAuthServices() {
    return PlatformRegistry.instance.getAllServicesOfType<AuthService>();
  }
  
  /// 获取特定平台的认证服务
  AuthService? getAuthServiceForPlatform(String platformId) {
    return PlatformRegistry.instance.getServiceForPlatform<AuthService>(platformId);
  }
  
  /// 获取当前活跃平台的认证服务
  AuthService? getActiveAuthService() {
    final platformId = PlatformService.instance.activePlatformId;
    return getAuthServiceForPlatform(platformId);
  }
  
  /// 使用当前活跃平台的认证服务进行认证
  Future<bool> authenticate() async {
    final authService = getActiveAuthService();
    
    if (authService != null) {
      return await authService.authenticate();
    } else {
      throw Exception('未找到活跃平台的认证服务');
    }
  }
  
  /// 使用当前活跃平台的认证服务登出
  Future<void> logout() async {
    final authService = getActiveAuthService();
    
    if (authService != null) {
      await authService.logout();
    } else {
      throw Exception('未找到活跃平台的认证服务');
    }
  }
  
  /// 检查当前活跃平台是否已认证
  Future<bool> isAuthenticated() async {
    final authService = getActiveAuthService();
    
    if (authService != null) {
      return await authService.isAuthenticated();
    } else {
      return false;
    }
  }
  
  /// 获取当前活跃平台的用户
  Future<UserModel?> getCurrentUser() async {
    final authService = getActiveAuthService();
    
    if (authService != null) {
      return await authService.getCurrentUser();
    } else {
      return null;
    }
  }
}