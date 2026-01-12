import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/image_service.dart';

class Validators {
  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกชื่อผู้ใช้';
    }
    if (value.length < 3) {
      return 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร';
    }
    if (!RegExp(r'^[a-zA-Z0-9._@]+$').hasMatch(value)) {
      return 'ชื่อผู้ใช้ใช้ได้เฉพาะ A-Z, a-z, 0-9, ., _, @';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#_\-!*])[A-Za-z\d@#_\-!*]{8,}$',
    ).hasMatch(value)) {
      return 'รหัสผ่านต้องมีตัวพิมพ์เล็ก, ใหญ่, ตัวเลข และอักขระพิเศษ (@#_-!*) อย่างน้อย 8 ตัว';
    }
    return null;
  }

  // Email validation (สำหรับใช้ในอนาคต)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    return null;
  }

  // Phone validation (สำหรับใช้ในอนาคต)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกเบอร์โทรศัพท์';
    }
    // Thai phone number format
    if (!RegExp(r'^[0][0-9]{9}$').hasMatch(value)) {
      return 'เบอร์โทรศัพท์ไม่ถูกต้อง (0XXXXXXXXX)';
    }
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    if (value.length < minLength) {
      return '$fieldNameต้องมีอย่างน้อย $minLength ตัวอักษร';
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    if (value.length > maxLength) {
      return '$fieldNameต้องไม่เกิน $maxLength ตัวอักษร';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก${fieldName ?? 'ตัวเลข'}';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลข';
    }
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกราคา';
    }
    if (!RegExp(r'^\d+\.?\d{0,2}$').hasMatch(value)) {
      return 'รูปแบบราคาไม่ถูกต้อง';
    }
    return null;
  }

  // Image validation for upload (ระบบป้องกัน 3 ชั้น)
  static Future<ImageValidationResult> validateImageForUpload(String hash, String employeeCode) async {
    try {
      print('=== IMAGE VALIDATION START ===');
      print('Hash: ${hash.substring(0, 16)}...');
      print('Employee Code: $employeeCode');

      // ข้าม validation ถ้าเป็น test hash
      if (hash.startsWith('test_hash_')) {
        print('🧪 Test hash detected - ข้าม validation');
        return ImageValidationResult(
          canUpload: true,
          reason: 'ทดสอบ API - ข้าม validation',
          errorCode: null,
        );
      }

      // ชั้นที่ 1: เช็คว่า hash นี้มาจากระบบเราหรือไม่ (Local validation)
      print('🔍 Step 1: ตรวจสอบ hash ใน local storage...');
      final prefs = await SharedPreferences.getInstance();
      final pendingUploads = prefs.getStringList('pending_uploads') ?? [];
      
      bool foundInPending = false;
      for (String uploadJson in pendingUploads) {
        try {
          final uploadData = jsonDecode(uploadJson);
          if (uploadData['hash'] == hash) {
            foundInPending = true;
            print('✅ Step 1: พบ hash ใน local storage');
            break;
          }
        } catch (e) {
          // ถ้า parse JSON ไม่ได้ ข้ามไป
          continue;
        }
      }
      
      if (!foundInPending) {
        print('❌ Step 1: ไม่พบ hash ใน local storage');
        return ImageValidationResult(
          canUpload: false,
          reason: 'รูปนี้ไม่ได้มาจากระบบถ่ายรูปของเรา',
          errorCode: 'NOT_FROM_CAMERA',
        );
      }

      // ชั้นที่ 2: เช็คใน server ว่า hash นี้มีในระบบหรือไม่
      print('🔍 Step 2: ตรวจสอบ hash ใน server...');
      final serverCheckResult = await ImageService.checkDuplicateImage(hash, employeeCode);
      
      print('📊 Step 2 Result: $serverCheckResult');
      
      // ชั้นที่ 3: ตีความผลลัพธ์จาก server
      print('🔍 Step 3: ตีความผลลัพธ์...');
      
      if (serverCheckResult == null) {
        print('❌ Step 3: ไม่สามารถตรวจสอบ server ได้');
        return ImageValidationResult(
          canUpload: false,
          reason: 'ไม่สามารถตรวจสอบสถานะ hash ในระบบได้',
          errorCode: 'SERVER_CHECK_FAILED',
        );
      }
      
      final validationResult = _interpretServerResponse(serverCheckResult);
      print('📝 Step 3 Result: ${validationResult.reason}');
      print('=== IMAGE VALIDATION END ===');
      
      return validationResult;
      
    } catch (e) {
      print('❌ Image validation error: $e');
      return ImageValidationResult(
        canUpload: false,
        reason: 'เกิดข้อผิดพลาดในการตรวจสอบ: $e',
        errorCode: 'VALIDATION_ERROR',
      );
    }
  }

  // ตีความผลลัพธ์จาก server response
  static ImageValidationResult _interpretServerResponse(dynamic serverResult) {
    print('🔍 Interpreting server result: $serverResult');
    
    if (serverResult == null) {
      return ImageValidationResult(
        canUpload: false,
        reason: 'ไม่สามารถตรวจสอบ server ได้',
        errorCode: 'SERVER_CHECK_FAILED',
      );
    }
    
    if (serverResult is Map<String, dynamic>) {
      final success = serverResult['success'] ?? false;
      final message = serverResult['message']?.toString() ?? '';
      final status = serverResult['status'];
      
      print('📊 Server response - Success: $success, Message: $message, Status: $status');
      
      if (!success) {
        // API call ไม่สำเร็จ
        return ImageValidationResult(
          canUpload: false,
          reason: 'ตรวจสอบ server ไม่สำเร็จ: $message',
          errorCode: 'API_ERROR',
        );
      }
      
      // ตีความจาก ResultMessage และ ResultStatus
      if (message.contains('ไม่มีในระบบ') || message.contains('not found')) {
        // Hash ไม่มีในระบบ (ไม่สามารถอัพโหลดได้)
        return ImageValidationResult(
          canUpload: false,
          reason: 'Hash นี้ไม่มีในระบบ (ต้องถ่ายรูปจากแอปเท่านั้น)',
          errorCode: 'HASH_NOT_IN_SYSTEM',
        );
      } else if (message.contains('ถูกใช้งานไปแล้ว') || message.contains('ใช้ไปแล้ว') || 
                 message.contains('duplicate') || message.contains('used')) {
        // Hash มีในระบบแต่เคยใช้แล้ว
        return ImageValidationResult(
          canUpload: false,
          reason: 'รูปนี้เคยอัพโหลดในระบบแล้ว (Hash ใช้ไปแล้ว)',
          errorCode: 'HASH_ALREADY_USED',
        );
      } else if (message.contains('ใช้ได้') || message.contains('available') || 
                 message.contains('ยังไม่ถูกใช้') || message.contains('ยังไม่ใช้')) {
        // Hash มีในระบบและยังไม่เคยใช้
        return ImageValidationResult(
          canUpload: true,
          reason: 'Hash มีในระบบและยังไม่เคยใช้ - พร้อมอัพโหลด',
          errorCode: null,
        );
      }
      
      // ตีความจาก ResultStatus (ถ้า message ไม่ชัดเจน)
      if (status != null) {
        if (status == 0) {
          // Status 0 = ใช้แล้ว (ตาม response ที่ได้)
          return ImageValidationResult(
            canUpload: false,
            reason: 'รูปนี้เคยอัพโหลดในระบบแล้ว (Status: 0)',
            errorCode: 'HASH_ALREADY_USED',
          );
        } else if (status == 1) {
          // Status 1 = ใช้ได้ (สมมติฐาน)
          return ImageValidationResult(
            canUpload: true,
            reason: 'Hash มีในระบบและยังไม่เคยใช้ - พร้อมอัพโหลด (Status: 1)',
            errorCode: null,
          );
        }
      }
    }
    
    // Default: ไม่แน่ใจ ห้ามอัพโหลด
    return ImageValidationResult(
      canUpload: false,
      reason: 'ไม่สามารถตีความผลลัพธ์จาก server ได้',
      errorCode: 'UNKNOWN_SERVER_RESPONSE',
    );
  }
}

// Class สำหรับผลลัพธ์การตรวจสอบรูปภาพ
class ImageValidationResult {
  final bool canUpload;
  final String reason;
  final String? errorCode;
  
  ImageValidationResult({
    required this.canUpload,
    required this.reason,
    this.errorCode,
  });

  @override
  String toString() {
    return 'ImageValidationResult(canUpload: $canUpload, reason: $reason, errorCode: $errorCode)';
  }
}