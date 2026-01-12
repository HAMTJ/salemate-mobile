import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageApi {
  static const String baseUrl = 'http://192.168.1.225:4200';
  static const String checkDuplicateEndpoint = '/api/keydata/v1.0/fnCheckImagesHashCanUse';
  static const String uploadImageEndpoint = '/api/keydata/v1.0/fnInsertNewImageHash';

  // ตรวจสอบรูปซ้ำ (API ใหม่)
  static Future<http.Response> checkDuplicateImage({
    required String fileHash,
    required String employeeCode,
    String? authToken,
  }) async {
    // แก้ request body ให้ตรงกับ API ใหม่
    final requestBody = {
      'imageHash': fileHash,        // แก้จาก 'file_hash'
      'createHashBy': employeeCode, // แก้จาก 'employee_code'
    };
    
    print('=== CHECK DUPLICATE API DEBUG ===');
    print('URL: $baseUrl$checkDuplicateEndpoint');
    print('Employee Code: $employeeCode');
    print('Image Hash: ${fileHash.substring(0, 16)}...');
    print('Request Body: ${jsonEncode(requestBody)}');
    print('Has Auth Token: ${authToken != null}');
    print('==================================');

    final response = await http.post(
      Uri.parse('$baseUrl$checkDuplicateEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(requestBody),
    );

    print('=== CHECK DUPLICATE RESPONSE DEBUG ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode >= 400) {
      print('❌ ERROR: HTTP ${response.statusCode}');
    } else {
      print('✅ SUCCESS: HTTP ${response.statusCode}');
    }
    print('======================================');
    
    return response;
  }

  // อัพโหลดรูปภาพ (ส่ง hash เข้าระบบ)
  static Future<http.Response> uploadImage({
    required String fileHash,
    required String employeeCode,
    String? authToken,
  }) async {
    // Debug: แสดงข้อมูลที่ส่งไป
    final requestBody = {
      'createHashBy': employeeCode,
      'imageHash': fileHash,
      'upload_source': 'MOBILE_CAMERA', // เก็บไว้สำหรับอนาคต
    };
    
    print('=== UPLOAD IMAGE API DEBUG ===');
    print('URL: $baseUrl$uploadImageEndpoint');
    print('Employee Code: $employeeCode');
    print('Image Hash: ${fileHash.substring(0, 16)}...');
    print('Request Body: ${jsonEncode(requestBody)}');
    print('Has Auth Token: ${authToken != null}');
    print('===============================');

    final response = await http.post(
      Uri.parse('$baseUrl$uploadImageEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(requestBody),
    );

    print('=== UPLOAD RESPONSE DEBUG ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode >= 400) {
      print('❌ ERROR: HTTP ${response.statusCode}');
    } else {
      print('✅ SUCCESS: HTTP ${response.statusCode}');
    }
    print('==============================');
    
    return response;
  }
}