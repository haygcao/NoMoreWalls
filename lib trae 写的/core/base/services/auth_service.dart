import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/service_registry.dart';

class AuthService {
  static final instance = AuthService._();
  final _registry = ServiceRegistry();

  AuthService._();

  bool get isLoggedIn => _registry.currentManager?.isAuthenticated ?? false;

  Future<void> initializePlatform(String platform) async {
    final manager = _registry.getAuthManager(platform);
    if (manager == null) {
      throw Exception('No auth manager found for platform: $platform');
    }
  }

  Future<void> login(String accessToken) async {
    final manager = _registry.currentManager;
    if (manager == null) {
      throw Exception('No platform initialized');
    }
    await manager.login({'accessToken': accessToken});
  }

  Future<void> logout() async {
    await _registry.currentManager?.logout();
    _registry.clearCurrentManager();
  }

  Future<void> refreshToken(String newAccessToken) async {
    await _registry.currentManager?.refreshToken(newAccessToken);
  }

  List<String> get availablePlatforms => _registry.availablePlatforms;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});
