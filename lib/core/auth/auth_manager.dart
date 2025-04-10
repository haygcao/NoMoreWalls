import 'package:flutter/foundation.dart';

/// 认证状态枚举
enum AuthenticationStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// 认证状态类
class AuthState {
  final AuthenticationStatus status;
  final String? error;
  final String? accessToken;
  final Map<String, dynamic>? credentials;

  const AuthState({
    this.status = AuthenticationStatus.initial,
    this.error,
    this.accessToken,
    this.credentials,
  });

  AuthState copyWith({
    AuthenticationStatus? status,
    String? error,
    String? accessToken,
    Map<String, dynamic>? credentials,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
      credentials: credentials ?? this.credentials,
    );
  }
}

/// 认证管理器基类
abstract class AuthManager extends ChangeNotifier {
  AuthState _state = const AuthState();

  AuthState get state => _state;
  bool get isAuthenticated =>
      _state.status == AuthenticationStatus.authenticated;
  String? get accessToken => _state.accessToken;

  @protected
  void updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> login(Map<String, dynamic> credentials);
  Future<void> logout();
  Future<void> refreshToken(String newAccessToken);
}
