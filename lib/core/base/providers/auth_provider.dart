import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../interfaces/auth/user_interface.dart';
import 'base_provider.dart';

/// Provider for authentication services
///
/// Manages state and operations related to user authentication
abstract class AuthProvider extends BaseProvider<AuthService> {
  /// Create a new auth provider
  AuthProvider() : super();

  /// Get the current user
  UserInterface? get currentUser => service.currentUser;

  /// Check if a user is logged in
  bool get isLoggedIn => service.isLoggedIn;

  /// Login with credentials
  Future<AsyncValue<UserInterface>> login(
      String username, String password) async {
    try {
      final user = await service.login(username, password);
      return AsyncValue.data(user);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Login with token
  Future<AsyncValue<UserInterface>> loginWithToken(String token) async {
    try {
      final user = await service.loginWithToken(token);
      return AsyncValue.data(user);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Login with OAuth
  Future<AsyncValue<UserInterface>> loginWithOAuth() async {
    try {
      final user = await service.loginWithOAuth();
      return AsyncValue.data(user);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    await service.logout();
  }

  /// Refresh the authentication token
  Future<AsyncValue<bool>> refreshToken() async {
    try {
      final bool token = await service.refreshToken();
      return AsyncValue.data(token);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get the user profile
  Future<AsyncValue<UserInterface>> getUserProfile() async {
    try {
      final profile = await service.getUserProfile();
      return AsyncValue.data(profile);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Update the user profile
  Future<AsyncValue<UserInterface>> updateUserProfile(
      Map<String, dynamic> data) async {
    try {
      final profile = await service.updateUserProfile(data);
      return AsyncValue.data(profile);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }
}
