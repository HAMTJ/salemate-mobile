import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageApi {
  // TODO: ให้น้อง backend เปลี่ยน URL และ endpoints เหล่านี้
  static const String baseUrl = 'http://192.168.1.225:4200';
  static const String checkDuplicateEndpoint = '/api/images/check-duplicate';
  static const String uploadImageEndpoint = '/api/images/upload';

  // ตรวจสอบรูปซ้ำ
  static Future<http.Response> checkDuplicateImage({
    required String fileHash,
    required int employeeId,
    String? authToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$checkDuplicateEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'file_hash': fileHash,
        'employee_id': employeeId,
      }),
    );

    print('Check duplicate API - Status: ${response.statusCode}');
    print('Check duplicate API - Body: ${response.body}');
    
    return response;
  }

  // อัพโหลดรูปภาพ
  static Future<http.Response> uploadImage({
    required String fileHash,
    required String imageData,
    required String fileName,
    required int fileSize,
    required int employeeId,
    String? authToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$uploadImageEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'file_hash': fileHash,
        'image_data': imageData,
        'file_name': fileName,
        'file_size': fileSize,
        'timestamp': DateTime.now().toIso8601String(),
        'employee_id': employeeId,
        'upload_source': 'MOBILE_CAMERA',
      }),
    );

    print('Upload image API - Status: ${response.statusCode}');
    print('Upload image API - Body: ${response.body}');
    
    return response;
  }
}