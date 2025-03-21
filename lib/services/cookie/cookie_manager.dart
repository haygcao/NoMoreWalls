import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class CookieManager {
  static final CookieManager _instance = CookieManager._internal();
  final FlutterSecureStorage _storage;

  factory CookieManager() => _instance;

  CookieManager._internal() : _storage = const FlutterSecureStorage();

  Future<void> saveCookies(String service, Map<String, String> cookies) async {
    await _storage.write(
      key: '${service}_cookies',
      value: json.encode(cookies),
    );
  }

  Future<Map<String, String>?> getCookies(String service) async {
    final cookiesStr = await _storage.read(key: '${service}_cookies');
    if (cookiesStr == null) return null;
    return Map<String, String>.from(json.decode(cookiesStr));
  }

  Future<void> clearCookies(String service) async {
    await _storage.delete(key: '${service}_cookies');
  }
}