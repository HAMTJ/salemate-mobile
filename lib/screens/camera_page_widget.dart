import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../widgets/glass_container.dart';
import '../services/image_service.dart';
import '../models/user.dart';
import '../models/employee_data.dart';

class CameraPageWidget extends StatefulWidget {
  final User? user;
  final EmployeeData? employeeData;
  
  const CameraPageWidget({
    super.key,
    this.user,
    this.employeeData,
  });

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
        
        // บันทึกรูปใน app directory และได้ path ใหม่
        final String savedImagePath = await ImageService.saveImageToAppDirectory(photo.path);
        
        // ดึง employeeCode จาก user data
        final String employeeCode = widget.employeeData?.employeeCode ?? 
                                   widget.user?.username ?? 
                                   'unknown';
        
        if (employeeCode == 'unknown') {
          _showSnackBar(
            'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่',
            Colors.red,
            Icons.error,
          );
          return;
        }
        
        // บันทึกลงอัลบั้ม (ใช้ path เดิม)
        await _saveToGallery(photo.path);
        
        // อัพโหลดไปยัง server (ใช้ saved path และ employeeCode)
        final result = await ImageService.uploadImageToServer(
          savedImagePath, 
          fileHash, 
          employeeCode, // ใช้ employeeCode แทน employeeId
        );
        
        if (result.success) {
          // ทำความสะอาดรูปเก่า (เก็บไว้แค่ 10 รูป)
          await ImageService.cleanupOldImages();
          
          _showSuccessSnackBar(
            'อัพโหลดสำเร็จ',
            'Employee: $employeeCode | Hash: ${fileHash.substring(0, 8)}... | File: ${savedImagePath.split('/').last}',
          );
        } else {
          // ถ้าอัพโหลดไม่สำเร็จ เก็บไว้ local ก่อน (ใช้ saved path)
          await ImageService.saveImageForLaterUpload(fileHash, savedImagePath, employeeCode);
          
          // ทำความสะอาดรูปเก่าอยู่ดี
          await ImageService.cleanupOldImages();
          
          _showSnackBar(
            'บันทึกไว้ในเครื่องแล้ว',
            Colors.amber,
            Icons.save,
            subtitle: 'Employee: $employeeCode | Path: ${savedImagePath.split('/').last} | จะอัพโหลดใหม่เมื่อมีอินเทอร์เน็ต',
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

  Future<void> _showSavedImages() async {
    try {
      final List<File> savedImages = await ImageService.getAllSavedImages();
      
      if (savedImages.isEmpty) {
        _showSnackBar(
          'ยังไม่มีรูปที่บันทึกไว้',
          Colors.grey,
          Icons.info,
        );
        return;
      }

      // แสดงรายการรูปใน Dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _buildImageListDialog(savedImages),
        );
      }
    } catch (e) {
      _showSnackBar(
        'เกิดข้อผิดพลาดในการโหลดรูป: $e',
        Colors.red,
        Icons.error,
      );
    }
  }

  Widget _buildImageListDialog(List<File> images) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รูปที่บันทึกไว้ (${images.length}/10)',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Image Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final File image = images[index];
                    final String fileName = image.path.split('/').last;
                    
                    return GestureDetector(
                      onTap: () => _showImageDetail(image),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Image.file(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    fileName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDetail(File image) {
    final String fileName = image.path.split('/').last;
    final DateTime? fileDate = DateTime.tryParse(
      fileName.replaceAll('IMG_', '').replaceAll('.jpg', '')
    );
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                  height: 300,
                ),
              ),
              const SizedBox(height: 16),
              
              // Info
              Text(
                fileName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (fileDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'ถ่ายเมื่อ: ${fileDate.day}/${fileDate.month}/${fileDate.year} ${fileDate.hour.toString().padLeft(2, '0')}:${fileDate.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              
              // Actions - แค่ปุ่มปิด
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('ปิด'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          // Header with view saved images button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ถ่ายภาพงาน',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _showSavedImages,
                icon: Icon(Icons.photo_library, size: 16),
                label: Text('ดูรูป 10 รูปล่าสุด', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User Info Display
          if (widget.employeeData != null || widget.user != null)
            GlassContainer(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ผู้ใช้: ${widget.employeeData?.employeeCode ?? widget.user?.username ?? 'ไม่ระบุ'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
            'บันทึกภาพกิจกรรมการทำงาน สถานที่ หรือหลักฐานต่างๆ\nภาพจะถูกอัพโหลดไปยังระบบและบันทึกไว้ในเครื่อง',
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