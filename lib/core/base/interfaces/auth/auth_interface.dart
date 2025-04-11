import 'package:flutter/foundation.dart';
import 'user_interface.dart';

/// Interface for authentication functionality
///
/// Defines the methods and properties for platform authentication
@immutable
abstract class AuthInterface {
  /// Check if the user is currently authenticated
  Future<bool> isAuthenticated();

  /// Authenticate the user
  ///
  /// This may open a web view or other authentication UI
  Future<bool> authenticate();

  /// Refresh the authentication token
  Future<bool> refreshToken();

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authentication token
  Future<String?> getToken();

  /// Get the current user information
  Future<UserInterface?> getCurrentUser();

  /// Get the expiration time of the current token
  Future<DateTime?> getTokenExpiration();

  /// Check if the current token is expired
  Future<bool> isTokenExpired();

  /// Get the platform name this auth is for
  String get platformName;

  /// Stream of authentication state changes
  Stream<bool> get authStateStream;

  /// Stream of current user changes
  Stream<UserInterface?> get userStream;
}
