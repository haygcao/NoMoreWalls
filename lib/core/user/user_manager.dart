import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// UserManager负责管理用户相关的功能
class UserManager extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  Map<String, dynamic>? _userData;
  bool _isAuthenticated = false;
  Map<String, dynamic> _preferences = {};

  UserManager() : _storage = const FlutterSecureStorage() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    // 从安全存储中加载用户数据
    final userDataStr = await _storage.read(key: 'user_data');
    if (userDataStr != null) {
      _userData = json.decode(userDataStr);
      _isAuthenticated = true;
    }

    // 加载用户偏好设置
    final prefsStr = await _storage.read(key: 'user_preferences');
    if (prefsStr != null) {
      _preferences = json.decode(prefsStr);
    }

    notifyListeners();
  }

  // 用户认证
  Future<void> login(Map<String, dynamic> userData) async {
    _userData = userData;
    _isAuthenticated = true;
    await _storage.write(
      key: 'user_data',
      value: json.encode(userData),
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'user_data');
    _userData = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // 用户偏好设置管理
  Future<void> updatePreference(String key, dynamic value) async {
    _preferences[key] = value;
    await _storage.write(
      key: 'user_preferences',
      value: json.encode(_preferences),
    );
    notifyListeners();
  }

  Future<void> clearPreferences() async {
    await _storage.delete(key: 'user_preferences');
    _preferences = {};
    notifyListeners();
  }

  // 权限控制
  bool hasPermission(String permission) {
    if (!_isAuthenticated) return false;
    final permissions = _userData?['permissions'] as List?;
    return permissions?.contains(permission) ?? false;
  }

  // 状态获取
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic> get preferences => _preferences;

  // 用户数据管理
  Future<void> updateUserData(Map<String, dynamic> newData) async {
    _userData = {...?_userData, ...newData};
    await _storage.write(
      key: 'user_data',
      value: json.encode(_userData),
    );
    notifyListeners();
  }
}

// Provider定义
final userManagerProvider = ChangeNotifierProvider<UserManager>((ref) {
  return UserManager();
});
