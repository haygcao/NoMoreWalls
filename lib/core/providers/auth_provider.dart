import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get accessToken => _authService.accessToken;

  // Authentication methods
  Future<void> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.login(username, password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshToken() async {
    _clearError();

    try {
      await _authService.refreshAccessToken();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
