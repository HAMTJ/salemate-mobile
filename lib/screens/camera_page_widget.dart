import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../widgets/glass_container.dart';
import '../services/image_service.dart';

class CameraPageWidget extends StatefulWidget {
  const CameraPageWidget({super.key});

  @override
  State<CameraPageWidget> createState() => _CameraPageWidgetState();
}

class _CameraPageWidgetState extends State<CameraPageWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (photo != null) {
        // แสดง loading
        _showLoadingSnackBar('กำลังตรวจสอบและอัพโหลด...');

        // สร้าง hash จากไฟล์
        final String fileHash = await ImageService.generateFileHash(photo.path);
        
        // TODO: ใส่ employee_id จริงจาก user login data
        const int employeeId = 123;
        
        // ตรวจสอบรูปซ้ำใน server
        final bool isDuplicate = await ImageService.checkDuplicateImage(fileHash, employeeId);
        
        if (isDuplicate) {
          _showSnackBar(
            'รูปนี้เคยอัพโหลดในระบบแล้ว',
            Colors.orange,
            Icons.warning,
          );
          return;
        }
        
        // บันทึกลงอัลบั้ม
        await _saveToGallery(photo.path);
        
        // อัพโหลดไปยัง server
        final result = await ImageService.uploadImageToServer(photo.path, fileHash, employeeId);
        
        if (result.success) {
          _showSuccessSnackBar(
            'อัพโหลดสำเร็จ',
            'ID: ${fileHash.substring(0, 8)}...',
          );
        } else {
          // ถ้าอัพโหลดไม่สำเร็จ เก็บไว้ local ก่อน
          await ImageService.saveImageForLaterUpload(fileHash, photo.path);
          
          _showSnackBar(
            'บันทึกไว้ในเครื่องแล้ว',
            Colors.amber,
            Icons.save,
            subtitle: 'จะอัพโหลดใหม่เมื่อมีอินเทอร์เน็ต',
          );
        }
      }
    } catch (e) {
      _showSnackBar(
        'เกิดข้อผิดพลาด: $e',
        Colors.red,
        Icons.error,
      );
    }
  }

  Future<void> _saveToGallery(String imagePath) async {
    try {
      // ลอง permission หลายแบบ
      PermissionStatus status;
      
      if (Platform.isAndroid) {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request();
      }
      
      if (status.isGranted) {
        await Gal.putImage(imagePath);
        print('บันทึกภาพสำเร็จ');
      } else {
        throw 'ไม่ได้รับอนุญาตให้เข้าถึงอัลบั้ม กรุณาอนุญาตในการตั้งค่า';
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการบันทึก: $e');
      rethrow;
    }
  }

  // Helper methods สำหรับแสดง SnackBar
  void _showLoadingSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text(message),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 30),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message, String subtitle) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_done, color: Colors.white),
                  SizedBox(width: 8),
                  Text(message),
                ],
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSnackBar(String message, Color color, IconData icon, {String? subtitle}) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: subtitle != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(child: Text(message)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
          backgroundColor: color,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ถ่ายภาพงาน',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Camera Actions
          _buildCameraActions(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCameraActions() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            'ถ่ายภาพเพื่อบันทึกงาน',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'บันทึกภาพกิจกรรมการทำงาน สถานที่ หรือหลักฐานต่างๆ\nภาพจะถูกอัพโหลดไปยังระบบทันที',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Action Button - ปุ่มถ่ายภาพ
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt, size: 24),
              label: const Text('ถ่ายภาพ', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}