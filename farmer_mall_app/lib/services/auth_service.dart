import 'package:farmer_mall_app/services/api_service.dart';
import 'package:farmer_mall_app/services/storage_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register(Map data) async {
    return await ApiService.post('/auth/register', data);
  }

  static Future<Map<String, dynamic>> login(Map data) async {
    final res = await ApiService.post('/auth/login', data);
    // If login returns token, save it
    if (res['statusCode'] == 200 || res['statusCode'] == 201) {
      final body = res['body'];
      if (body is Map && body['token'] != null) {
        await ApiService.saveToken(body['token']);
        if (body['user'] is Map) {
          await StorageService.setMap(
            'current_user',
            Map<String, dynamic>.from(body['user'] as Map),
          );
        }
      }
    }
    return res;
  }

  static Future<void> logout() async {
    // Clear token and user data
    await StorageService.clearToken();
    await StorageService.remove('current_user');
  }
}
