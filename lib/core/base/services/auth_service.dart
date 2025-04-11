import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../interfaces/auth/auth_interface.dart';
import '../interfaces/auth/user_interface.dart';

/// Base class for authentication services
///
/// Provides methods for user authentication across platforms
abstract class AuthService extends BaseService implements AuthInterface {
  /// Current authenticated user
  UserInterface? get currentUser;

  /// Check if a user is logged in
  bool get isLoggedIn;

  /// Login with username and password
  Future<UserInterface> login(String username, String password);

  /// Login with a token
  Future<UserInterface> loginWithToken(String token);

  /// Login with OAuth
  Future<UserInterface> loginWithOAuth();

  /// Logout the current user
  Future<void> logout();

  /// Get the user profile
  Future<UserInterface> getUserProfile();

  /// Update the user profile
  Future<UserInterface> updateUserProfile(Map<String, dynamic> data);

  /// Get the current authentication token
  @override
  Future<String?> getToken();

  /// Get the current user information
  @override
  Future<UserInterface?> getCurrentUser();

  /// Check if the user is currently authenticated
  @override
  Future<bool> isAuthenticated();

  /// Authenticate the user
  @override
  Future<bool> authenticate();

  /// Refresh the authentication token
  @override
  Future<bool> refreshToken();

  /// Sign out the current user
  @override
  Future<void> signOut();

  /// Get the expiration time of the current token
  @override
  Future<DateTime?> getTokenExpiration();

  /// Check if the current token is expired
  @override
  Future<bool> isTokenExpired();

  /// Get the platform name this auth is for
  @override
  String get platformName;

  /// Stream of authentication state changes
  @override
  Stream<bool> get authStateStream;

  /// Stream of current user changes
  @override
  Stream<UserInterface?> get userStream;
}
