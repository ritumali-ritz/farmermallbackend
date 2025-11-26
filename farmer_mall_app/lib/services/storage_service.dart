import 'dart:convert';

import 'shared_prefs_provider.dart';

class StorageService {
  static const _tokenKey = 'token';
  static final SharedPrefsProvider _provider = SharedPrefsProvider();

  static Future<void> setToken(String token) async {
    final prefs = await _provider.instance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _provider.instance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await _provider.instance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await _provider.instance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _provider.instance();
    return prefs.getString(key);
  }

  static Future<void> setMap(String key, Map<String, dynamic> value) async {
    final prefs = await _provider.instance();
    await prefs.setString(key, jsonEncode(value));
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    final prefs = await _provider.instance();
    final s = await prefs.getString(key);
    if (s == null) return null;
    final decoded = jsonDecode(s);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  static Future<void> remove(String key) async {
    final prefs = await _provider.instance();
    await prefs.remove(key);
  }
}