import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApi {
  static const String baseUrl = 'http://192.168.1.225:4200'; // เปลี่ยนเป็น URL จริงของคุณ
  static const String loginEndpoint = '/api/auth/v1.0/fnGetLogin';
  static const String logoutEndpoint = '/api/auth/v1.0/fnLogout'; // สำหรับอนาคต
  
  // Login API call
  static Future<http.Response> login({
    required String username,
    required String password,
    required String changeSource,
    required String deviceInfo,
    required String deviceToken,
  }) async {
    // Debug Log
    print('=== LOGIN API DEBUG ===');
    print('URL: $baseUrl$loginEndpoint');
    
    final requestBody = {
      'username': username,
      'password': password,
      'changesource': changeSource,
      'deviceinfo': deviceInfo,
      'devicetoken': deviceToken,
    };
    
    print('Request Body: ${jsonEncode(requestBody)}');
    print('=======================');

    final response = await http.post(
      Uri.parse('$baseUrl$loginEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // Response Log
    print('=== LOGIN RESPONSE DEBUG ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('============================');

    return response;
  }

  // Logout API call (สำหรับอนาคต)
  static Future<http.Response> logout({
    required String token,
    required String deviceToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$logoutEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'devicetoken': deviceToken,
      }),
    );

    print('Logout API - Status: ${response.statusCode}');
    print('Logout API - Body: ${response.body}');
    
    return response;
  }

  // Refresh token API (สำหรับอนาคต)
  static Future<http.Response> refreshToken({
    required String refreshToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/v1.0/fnRefreshToken'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'refresh_token': refreshToken,
      }),
    );

    print('Refresh token API - Status: ${response.statusCode}');
    
    return response;
  }
}