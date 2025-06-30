import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_image.dart';

class ImageService {
  // สร้าง hash จากไฟล์รูป
  static Future<String> generateFileHash(String filePath) async {
    final File file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // แปลงรูปเป็น base64
  static Future<String> convertImageToBase64(String imagePath) async {
    final File imageFile = File(imagePath);
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  // ตรวจสอบรูปซ้ำ
  static Future<bool> checkDuplicateImage(String hash, int employeeId) async {
    try {
      final response = await ImageApi.checkDuplicateImage(
        fileHash: hash,
        employeeId: employeeId,
        // TODO: เพิ่ม authToken จาก user session
        // authToken: await _getAuthToken(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // TODO: ปรับ JSON structure ตาม API ที่น้อง backend เขียน
        return responseData['is_duplicate'] ?? false;
      } else {
        print('Check duplicate failed: ${response.statusCode}');
        return false; // ถ้า API error ให้ผ่านไปก่อน
      }
    } catch (e) {
      print('Error checking duplicate: $e');
      return false; // ถ้า network error ให้ผ่านไปก่อน
    }
  }

  // อัพโหลดรูปไปยัง server
  static Future<ImageUploadResult> uploadImageToServer(
    String imagePath, 
    String hash, 
    int employeeId
  ) async {
    try {
      // Convert image to base64
      final String base64Image = await convertImageToBase64(imagePath);
      final int fileSize = await File(imagePath).length();
      final String fileName = imagePath.split('/').last;
      
      final response = await ImageApi.uploadImage(
        fileHash: hash,
        imageData: base64Image,
        fileName: fileName,
        fileSize: fileSize,
        employeeId: employeeId,
        // TODO: เพิ่ม authToken จาก user session
        // authToken: await _getAuthToken(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // TODO: ปรับตาม JSON structure ที่น้อง backend เขียน
        if (responseData['status'] == 'success') {
          return ImageUploadResult(
            success: true,
            message: responseData['message'] ?? 'อัพโหลดสำเร็จ',
            imageId: responseData['image_id'],
          );
        } else {
          return ImageUploadResult(
            success: false,
            message: responseData['message'] ?? 'อัพโหลดไม่สำเร็จ',
          );
        }
      } else {
        return ImageUploadResult(
          success: false,
          message: 'เกิดข้อผิดพลาดในการเชื่อมต่อ (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      return ImageUploadResult(
        success: false,
        message: 'เกิดข้อผิดพลาด: ${e.toString()}',
      );
    }
  }

  // เก็บรูปไว้ local สำหรับอัพโหลดภายหลัง
  static Future<void> saveImageForLaterUpload(String hash, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUploads = prefs.getStringList('pending_uploads') ?? [];
    
    final uploadData = {
      'hash': hash,
      'path': imagePath,
      'timestamp': DateTime.now().toIso8601String(),
      'uploaded': false,
    };
    
    pendingUploads.add(jsonEncode(uploadData));
    await prefs.setStringList('pending_uploads', pendingUploads);
    
    print('บันทึกรูปไว้สำหรับอัพโหลดภายหลัง: $hash');
  }

  // อัพโหลดรูปที่ค้างอยู่ (สำหรับใช้ภายหลัง)
  static Future<void> uploadPendingImages() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUploads = prefs.getStringList('pending_uploads') ?? [];
    
    if (pendingUploads.isEmpty) return;

    final List<String> remainingUploads = [];
    
    for (String uploadJson in pendingUploads) {
      try {
        final uploadData = jsonDecode(uploadJson);
        
        if (uploadData['uploaded'] == true) continue;
        
        final result = await uploadImageToServer(
          uploadData['path'],
          uploadData['hash'],
          // TODO: ใส่ employee_id จริง
          123,
        );
        
        if (!result.success) {
          remainingUploads.add(uploadJson);
        }
      } catch (e) {
        remainingUploads.add(uploadJson);
      }
    }
    
    await prefs.setStringList('pending_uploads', remainingUploads);
  }

  // TODO: ฟังก์ชันสำหรับดึง auth token
  // static Future<String?> _getAuthToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('auth_token');
  // }
}

// Class สำหรับผลลัพธ์การอัพโหลด
class ImageUploadResult {
  final bool success;
  final String message;
  final int? imageId;

  ImageUploadResult({
    required this.success,
    required this.message,
    this.imageId,
  });
}