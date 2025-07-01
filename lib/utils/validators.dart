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

  // Image validation for upload (ระบบป้องกัน 2 ชั้น)
  static Future<ImageValidationResult> validateImageForUpload(String hash, String employeeCode) async {
    try {
      // ชั้นที่ 1: เช็คว่า hash นี้มาจากระบบเราหรือไม่
      final prefs = await SharedPreferences.getInstance();
      final pendingUploads = prefs.getStringList('pending_uploads') ?? [];
      
      bool foundInPending = false;
      for (String uploadJson in pendingUploads) {
        try {
          final uploadData = jsonDecode(uploadJson);
          if (uploadData['hash'] == hash) {
            foundInPending = true;
            break;
          }
        } catch (e) {
          // ถ้า parse JSON ไม่ได้ ข้ามไป
          continue;
        }
      }
      
      if (!foundInPending) {
        return ImageValidationResult(
          canUpload: false,
          reason: 'รูปนี้ไม่ได้มาจากระบบถ่ายรูปของเรา',
          errorCode: 'NOT_FROM_CAMERA',
        );
      }
      
      // ชั้นที่ 2: เช็ค hash ซ้ำใน server
      final isDuplicate = await ImageService.checkDuplicateImage(hash, employeeCode);
      
      if (isDuplicate) {
        return ImageValidationResult(
          canUpload: false,
          reason: 'รูปนี้เคยอัพโหลดในระบบแล้ว',
          errorCode: 'DUPLICATE_HASH',
        );
      }
      
      return ImageValidationResult(
        canUpload: true,
        reason: 'พร้อมอัพโหลด',
        errorCode: null,
      );
      
    } catch (e) {
      return ImageValidationResult(
        canUpload: false,
        reason: 'เกิดข้อผิดพลาดในการตรวจสอบ: $e',
        errorCode: 'VALIDATION_ERROR',
      );
    }
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
}