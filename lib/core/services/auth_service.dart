import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // User state
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;

  // Authentication methods
  Future<void> login(String username, String password) async {
    try {
      // TODO: Implement login logic with API
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      // TODO: Implement logout logic
      _isAuthenticated = false;
      _accessToken = null;
      _refreshToken = null;
      _tokenExpiry = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<void> refreshAccessToken() async {
    try {
      if (_refreshToken == null) {
        throw Exception('No refresh token available');
      }
      // TODO: Implement token refresh logic
      notifyListeners();
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Token management
  void _updateTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenExpiry = expiry;
    notifyListeners();
  }

  bool get isTokenExpired {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!);
  }
}
