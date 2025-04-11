import 'package:spotube/core/base/providers/base_provider.dart';
import 'package:spotube/core/base/interfaces/auth/user_interface.dart';

/// 认证提供者接口
abstract class AuthProvider extends BaseProvider<UserInterface?> {
  /// 执行认证
  Future<bool> authenticate();
  
  /// 登出
  Future<void> logout();
  
  /// 检查是否已认证
  Future<bool> isAuthenticated();
  
  /// 刷新访问令牌
  Future<String?> refreshToken();
  
  /// 获取访问令牌
  String? get accessToken;
  
  /// 令牌过期时间
  DateTime? get expirationTime;
  
  /// 是否已认证
  bool get isAuthenticated;
}