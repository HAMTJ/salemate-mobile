import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import '../api/auth_api.dart';

class AuthService {
  
  // Get device information - Mock data version
  Future<Map<String, String>> _getDeviceInfo() async {
    // Temporary mock data
    return {
      'deviceInfo': 'Flutter Development App',
      'deviceToken': 'dev_token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Login method
  Future<LoginResponse> login(String username, String password) async {
    try {
      // Get device information
      final deviceData = await _getDeviceInfo();
      
      // Make API call using AuthApi
      final response = await AuthApi.login(
        username: username,
        password: password,
        changeSource: 'MOBILE_APP',
        deviceInfo: deviceData['deviceInfo']!,
        deviceToken: deviceData['deviceToken']!,
      );

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if response has 'result' wrapper
        final actualData = responseData['result'] ?? responseData;
        final loginResponse = LoginResponse.fromApiResponse(actualData);
        
        if (loginResponse.success) {
          // Save user data if needed
          await _saveUserData(loginResponse.data);
          return loginResponse;
        } else {
          // Check specific error codes
          final errorCode = loginResponse.loginErrorCode;
          String errorMessage = 'เข้าสู่ระบบไม่สำเร็จ';
          
          if (errorCode == 'null') {
            errorMessage = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
          } else if (errorCode != null) {
            errorMessage = 'รหัสข้อผิดพลาด: $errorCode';
          }
          
          throw AuthException(errorMessage);
        }
      } else if (response.statusCode == 401) {
        throw AuthException('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw AuthException(errorData['message'] ?? 'ข้อมูลไม่ถูกต้อง');
      } else if (response.statusCode == 406) {
        throw AuthException('ข้อมูลที่ส่งไม่ถูกต้อง (406)');
      } else {
        throw AuthException('เกิดข้อผิดพลาด (${response.statusCode})');
      }
    } on SocketException {
      throw AuthException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on http.ClientException {
      throw AuthException('เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      // Clear stored tokens/session
      // TODO: เรียก logout API ถ้าจำเป็น
      // await AuthApi.logout(token: token, deviceToken: deviceToken);
      
      // Clear local storage
      await _clearUserData();
    } catch (e) {
      print('Logout error: $e');
      // Clear local data แม้ API ล้มเหลว
      await _clearUserData();
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    // TODO: Check if token exists and is valid
    // final token = await SecureStorage.getToken();
    // return token != null && !isTokenExpired(token);
    return false; // Placeholder
  }

  // Refresh token method (if your API supports it)
  Future<String?> refreshToken(String refreshToken) async {
    try {
      final response = await AuthApi.refreshToken(refreshToken: refreshToken);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['access_token'];
      }
      return null;
    } catch (e) {
      print('Refresh token error: $e');
      return null;
    }
  }

  // Save user data locally
  Future<void> _saveUserData(dynamic userData) async {
    // TODO: Implement saving user data to secure storage
    // await SecureStorage.saveUserData(userData);
    print('User data saved: $userData');
  }

  // Clear user data
  Future<void> _clearUserData() async {
    // TODO: Clear user data from secure storage
    // await SecureStorage.clearAll();
    print('User data cleared');
  }

  // Get current user token (สำหรับใช้ใน API อื่นๆ)
  Future<String?> getCurrentToken() async {
    // TODO: Get token from secure storage
    // return await SecureStorage.getToken();
    return null;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    // TODO: Get user data from secure storage
    // return await SecureStorage.getUserData();
    return null;
  }
}

// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
  
  @override
  String toString() => message;
}