import 'package:http/http.dart' as http;
import 'dart:convert';

// File location: lib/api/task_api.dart

class TaskApi {
  static const String baseUrl = 'http://192.168.1.225:4200'; // เดียวกับ AuthApi
  static const String taskEndpoint = '/api/keydata/v1.0/fnTaskKeyDataGet';
  static const String updateKeyDataEndpoint = '/api/keydata/v1.0/fnKeyDataStatusUpdate'; // API ใหม่
  
  // Get tasks for employee
  static Future<http.Response> getTasks({
    required String employeeCode,
    String? authToken,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // สร้าง request body
    final requestBody = <String, dynamic>{
      'employeeCode': employeeCode,
    };
    
    // เพิ่ม date range ถ้ามี (สำหรับอนาคต)
    if (startDate != null) {
      requestBody['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      requestBody['endDate'] = endDate.toIso8601String();
    }
    
    // Debug Log
    print('=== TASK API DEBUG ===');
    print('URL: $baseUrl$taskEndpoint');
    print('Employee Code: $employeeCode');
    print('Request Body: ${jsonEncode(requestBody)}');
    print('Has Auth Token: ${authToken != null}');
    print('======================');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$taskEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      // Response Log
      print('=== TASK RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body Length: ${response.body.length}');
      
      // แสดง response บางส่วน (ไม่แสดงทั้งหมดเพราะอาจยาวมาก)
      if (response.body.length > 500) {
        print('Response Body (first 500 chars): ${response.body.substring(0, 500)}...');
      } else {
        print('Response Body: ${response.body}');
      }
      
      if (response.statusCode >= 400) {
        print('❌ ERROR: HTTP ${response.statusCode}');
      } else {
        print('✅ SUCCESS: HTTP ${response.statusCode}');
      }
      print('===========================');

      return response;
      
    } catch (e) {
      print('❌ Task API Exception: $e');
      rethrow;
    }
  }
  
  // Update key data status (API ใหม่)
  static Future<http.Response> updateKeyDataStatus({
    required String employeeCode,
    required String quotationShareSubNo,
    required String brandName,
    required String workType,
    required int checkInOutID,
    String? authToken,
  }) async {
    final requestBody = {
      'employeeCode': employeeCode,
      'quotationShareSubNo': quotationShareSubNo,
      'brandName': brandName,
      'workType': workType,
      'actionType': 1, // Fix 1 คือคีย์ยอดแล้ว
      'updatedBy': employeeCode, // รหัสพนักงานที่คีย์ยอด
      'checkInOutID': checkInOutID,
    };
    
    print('=== UPDATE KEY DATA STATUS DEBUG ===');
    print('URL: $baseUrl$updateKeyDataEndpoint');
    print('Employee Code: $employeeCode');
    print('Brand: $brandName');
    print('Work Type: $workType');
    print('CheckInOutID: $checkInOutID');
    print('Quotation: $quotationShareSubNo');
    print('Request Body: ${jsonEncode(requestBody)}');
    print('Has Auth Token: ${authToken != null}');
    print('====================================');

    try {
      final response = await http.put( // เปลี่ยนจาก POST เป็น PUT
        Uri.parse('$baseUrl$updateKeyDataEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      print('=== UPDATE KEY DATA RESPONSE DEBUG ===');
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
      
    } catch (e) {
      print('❌ Update Key Data Status Exception: $e');
      rethrow;
    }
  }
  
  // Submit key data (สำหรับเมื่อเสร็จสิ้นการคีย์ยอด)
  static Future<http.Response> submitKeyData({
    required String employeeCode,
    required String quotationShareSubNo,
    required String brandName,
    required Map<String, dynamic> keyDataPayload,
    String? authToken,
  }) async {
    final requestBody = {
      'employeeCode': employeeCode,
      'quotationShareSubNo': quotationShareSubNo,
      'brandName': brandName,
      'keyData': keyDataPayload,
      'submittedAt': DateTime.now().toIso8601String(),
    };
    
    print('=== SUBMIT KEY DATA DEBUG ===');
    print('URL: $baseUrl/api/keydata/v1.0/fnSubmitKeyData'); // สมมติ endpoint
    print('Employee Code: $employeeCode');
    print('Brand: $brandName');
    print('Quotation: $quotationShareSubNo');
    print('Key Data Keys: ${keyDataPayload.keys.toList()}');
    print('=============================');

    final response = await http.post(
      Uri.parse('$baseUrl/api/keydata/v1.0/fnSubmitKeyData'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(requestBody),
    );

    print('=== SUBMIT KEY DATA RESPONSE DEBUG ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('======================================');

    return response;
  }
  
  // Helper method: Get employee code from current session
  static String? getCurrentEmployeeCode() {
    // TODO: Implement getting employee code from user session
    // This should get from SharedPreferences or secure storage
    // For now, return null to force passing from calling code
    return null;
  }
  
  // Helper method: Get auth token from current session
  static String? getCurrentAuthToken() {
    // TODO: Implement getting auth token from user session
    // This should get from SharedPreferences or secure storage
    return null;
  }
  
  // Validate employee code format
  static bool isValidEmployeeCode(String? employeeCode) {
    if (employeeCode == null || employeeCode.isEmpty) return false;
    
    // ตาม format ที่เห็นใน API: KAF-2026060007
    final regex = RegExp(r'^[A-Z]{2,3}-\d{10}$');
    return regex.hasMatch(employeeCode);
  }
}