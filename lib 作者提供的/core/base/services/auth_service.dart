import 'package:spotube/core/base/services/base_service.dart';
import 'package:spotube/core/base/interfaces/auth/user_interface.dart';

/// 认证服务接口
abstract class AuthService extends BaseService {
  /// 执行认证
  Future<bool> authenticate();
  
  /// 登出
  Future<void> logout();
  
  /// 检查是否已认证
  Future<bool> isAuthenticated();
  
  /// 获取当前用户
  Future<UserInterface?> getCurrentUser();
  
  /// 刷新访问令牌
  Future<String?> refreshToken();
  
  /// 获取访问令牌
  String? get accessToken;
  
  /// 令牌过期时间
  DateTime? get expirationTime;
}