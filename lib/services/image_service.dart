import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../api/api_image.dart';
import '../utils/validators.dart';

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

  // บันทึกรูปใน app directory
  static Future<String> saveImageToAppDirectory(String originalPath) async {
    try {
      // หา directory สำหรับเก็บรูป
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'images');
      
      // สร้างโฟลเดอร์ถ้ายังไม่มี
      final Directory imageDirectory = Directory(imagesDir);
      if (!await imageDirectory.exists()) {
        await imageDirectory.create(recursive: true);
      }
      
      // สร้างชื่อไฟล์ใหม่ (ใช้ timestamp)
      final String fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = path.join(imagesDir, fileName);
      
      // Copy ไฟล์จาก temp path ไปยัง app directory
      final File originalFile = File(originalPath);
      final File newFile = await originalFile.copy(newPath);
      
      print('บันทึกรูปใน app directory: $newPath');
      return newFile.path;
    } catch (e) {
      print('Error saving image to app directory: $e');
      return originalPath; // fallback ใช้ path เดิม
    }
  }

  // ดูรายการรูป 10 รูปล่าสุด
  static Future<List<File>> getAllSavedImages({int limit = 10}) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'images');
      final Directory imageDirectory = Directory(imagesDir);
      
      if (!await imageDirectory.exists()) {
        return [];
      }
      
      final List<FileSystemEntity> files = await imageDirectory.list().toList();
      List<File> imageFiles = files.whereType<File>().where((file) => 
        file.path.toLowerCase().endsWith('.jpg') || 
        file.path.toLowerCase().endsWith('.png')
      ).toList();
      
      // เรียงตาม modified date ใหม่ไปเก่า
      imageFiles.sort((a, b) {
        try {
          return b.statSync().modified.compareTo(a.statSync().modified);
        } catch (e) {
          // ถ้า error ให้เรียงตามชื่อไฟล์ (timestamp)
          return b.path.compareTo(a.path);
        }
      });
      
      // จำกัดจำนวน
      return imageFiles.take(limit).toList();
    } catch (e) {
      print('Error getting saved images: $e');
      return [];
    }
  }

  // ดูรายการรูปทั้งหมด (ไม่จำกัดจำนวน) - สำหรับ internal use
  static Future<List<File>> _getAllImagesUnsorted() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'images');
      final Directory imageDirectory = Directory(imagesDir);
      
      if (!await imageDirectory.exists()) {
        return [];
      }
      
      final List<FileSystemEntity> files = await imageDirectory.list().toList();
      return files.whereType<File>().where((file) => 
        file.path.toLowerCase().endsWith('.jpg') || 
        file.path.toLowerCase().endsWith('.png')
      ).toList();
    } catch (e) {
      print('Error getting all images: $e');
      return [];
    }
  }

  // ตรวจสอบรูปซ้ำ
  static Future<bool> checkDuplicateImage(String hash, String employeeCode) async {
    try {
      final response = await ImageApi.checkDuplicateImage(
        fileHash: hash,
        employeeCode: employeeCode, // เปลี่ยนจาก employeeId เป็น employeeCode
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

  // อัพโหลดรูปไปยัง server (พร้อมการตรวจสอบ 2 ชั้น)
  static Future<ImageUploadResult> uploadImageToServer(
    String imagePath, 
    String hash, 
    String employeeCode // เปลี่ยนจาก int employeeId เป็น String employeeCode
  ) async {
    try {
      // ตรวจสอบก่อนอัพโหลด (ระบบป้องกัน 2 ชั้น)
      final validation = await Validators.validateImageForUpload(hash, employeeCode);
      
      if (!validation.canUpload) {
        return ImageUploadResult(
          success: false,
          message: validation.reason,
          errorCode: validation.errorCode,
        );
      }
      
      final response = await ImageApi.uploadImage(
        fileHash: hash,
        employeeCode: employeeCode, // ส่ง employeeCode
        // TODO: เพิ่ม authToken จาก user session
        // authToken: await _getAuthToken(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // ปรับตาม JSON structure ใหม่ที่มี result wrapper
        final result = responseData['result'];
        if (result != null && result['status'] == 'success') {
          // ลบ hash ออกจาก pending uploads เมื่ออัพโหลดสำเร็จ
          await _removePendingUpload(hash);
          
          return ImageUploadResult(
            success: true,
            message: 'อัพโหลดสำเร็จ',
            imageId: null, // API ใหม่ไม่ return imageId
          );
        } else {
          return ImageUploadResult(
            success: false,
            message: result?['message'] ?? 'อัพโหลดไม่สำเร็จ',
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
  static Future<void> saveImageForLaterUpload(String hash, String imagePath, String employeeCode) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUploads = prefs.getStringList('pending_uploads') ?? [];
    
    final uploadData = {
      'hash': hash,
      'path': imagePath,
      'employeeCode': employeeCode, // เพิ่ม employeeCode
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
          uploadData['employeeCode'] ?? 'unknown', // ใช้ employeeCode
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

  // ลบรูปจาก app directory
  static Future<bool> deleteImageFromAppDirectory(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('ลบรูปสำเร็จ: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // ทำความสะอาดรูปเก่า (เก็บไว้แค่ 10 รูปล่าสุด)
  static Future<void> cleanupOldImages({int keepCount = 10}) async {
    try {
      final List<File> allImages = await _getAllImagesUnsorted();
      
      if (allImages.length <= keepCount) {
        print('รูปทั้งหมด: ${allImages.length} ไม่เกิน $keepCount รูป ไม่ต้องลบ');
        return;
      }
      
      // เรียงตาม modified date ใหม่ไปเก่า
      allImages.sort((a, b) {
        try {
          return b.statSync().modified.compareTo(a.statSync().modified);
        } catch (e) {
          // ถ้า error ให้เรียงตามชื่อไฟล์ (timestamp)
          return b.path.compareTo(a.path);
        }
      });
      
      // ลบรูปที่เก่าเกินจำนวนที่กำหนด
      int deletedCount = 0;
      for (int i = keepCount; i < allImages.length; i++) {
        try {
          await allImages[i].delete();
          deletedCount++;
          print('ลบรูปเก่า: ${allImages[i].path.split('/').last}');
        } catch (e) {
          print('ไม่สามารถลบรูป: ${allImages[i].path} - $e');
        }
      }
      
      print('ทำความสะอาดเสร็จสิ้น: ลบ $deletedCount รูป เหลือ $keepCount รูป');
    } catch (e) {
      print('Error cleaning up old images: $e');
    }
  }

  // ลบ hash ออกจาก pending uploads เมื่ออัพโหลดสำเร็จ
  static Future<void> _removePendingUpload(String hash) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingUploads = prefs.getStringList('pending_uploads') ?? [];
      
      final List<String> remainingUploads = [];
      
      for (String uploadJson in pendingUploads) {
        try {
          final uploadData = jsonDecode(uploadJson);
          if (uploadData['hash'] != hash) {
            remainingUploads.add(uploadJson);
          }
        } catch (e) {
          // ถ้า parse ไม่ได้ ให้เก็บไว้
          remainingUploads.add(uploadJson);
        }
      }
      
      await prefs.setStringList('pending_uploads', remainingUploads);
      print('ลบ hash ออกจาก pending uploads: $hash');
    } catch (e) {
      print('Error removing pending upload: $e');
    }
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
  final String? errorCode;

  ImageUploadResult({
    required this.success,
    required this.message,
    this.imageId,
    this.errorCode,
  });
}