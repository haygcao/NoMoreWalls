import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/core/auth/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? error;
  final String? accessToken;

  const AuthState({
    required this.status,
    this.error,
    this.accessToken,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    String? accessToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService)
      : super(const AuthState(status: AuthStatus.unauthenticated));

  Future<void> login(String accessToken) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.login(accessToken);
      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: accessToken,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshToken(String newAccessToken) async {
    try {
      await _authService.refreshToken(newAccessToken);
      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: newAccessToken,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
