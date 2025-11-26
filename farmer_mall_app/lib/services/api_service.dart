import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:farmer_mall_app/services/storage_service.dart';
import 'package:farmer_mall_app/config.dart';

class ApiService {
  // Base URL is now managed in config.dart
  // Update AppConfig.serverIP when you change networks!
  static String get baseUrl => AppConfig.baseUrl;

  // Helpers to access token
  static Future<void> saveToken(String token) async {
    await StorageService.setToken(token);
  }

  static Future<String?> getToken() async {
    return await StorageService.getToken();
  }

  static Map<String, String> defaultHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map body, {
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final t = token ?? await getToken();
    try {
      final res = await http
          .post(url, body: jsonEncode(body), headers: defaultHeaders(t))
          .timeout(const Duration(seconds: 10));
      return _parseResponse(res);
    } catch (e) {
      return {'statusCode': 0, 'body': {'message': e.toString()}};
    }
  }

  static Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final url = Uri.parse('$baseUrl$path');
    final t = token ?? await getToken();
    try {
      final res = await http
          .get(url, headers: defaultHeaders(t))
          .timeout(const Duration(seconds: 10));
      return _parseResponse(res);
    } catch (e) {
      return {'statusCode': 0, 'body': {'message': e.toString()}};
    }
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map body, {
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final t = token ?? await getToken();
    try {
      final res = await http
          .put(url, body: jsonEncode(body), headers: defaultHeaders(t))
          .timeout(const Duration(seconds: 10));
      return _parseResponse(res);
    } catch (e) {
      return {'statusCode': 0, 'body': {'message': e.toString()}};
    }
  }

  static Future<Map<String, dynamic>> delete(String path, {String? token}) async {
    final url = Uri.parse('$baseUrl$path');
    final t = token ?? await getToken();
    try {
      final res = await http
          .delete(url, headers: defaultHeaders(t))
          .timeout(const Duration(seconds: 10));
      return _parseResponse(res);
    } catch (e) {
      return {'statusCode': 0, 'body': {'message': e.toString()}};
    }
  }


  // Upload image file
  static Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    final url = Uri.parse('$baseUrl/upload/product');
    final t = await getToken();
    
    try {
      var request = http.MultipartRequest('POST', url);
      if (t != null && t.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $t';
      }
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _parseResponse(response);
    } catch (e) {
      return {'statusCode': 0, 'body': {'message': e.toString()}};
    }
  }

  static String? resolveMediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final trimmed = path.trim();
    if (trimmed.startsWith('http')) return trimmed;
    final normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseUrl$normalized';
  }

  static Map<String, dynamic> _parseResponse(http.Response res) {
    if (res.body.isEmpty) return {'statusCode': res.statusCode, 'body': null};
    try {
      return {'statusCode': res.statusCode, 'body': jsonDecode(res.body)};
    } catch (e) {
      return {'statusCode': res.statusCode, 'body': res.body};
    }
  }
}
