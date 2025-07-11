import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../models/task_models.dart';
import '../services/task_service.dart';
import '../models/user.dart';
import '../models/employee_data.dart';

// Brand Detail Screen
class BrandDetailScreen extends StatefulWidget {
  final BranchInfo branchInfo;
  final User? user;
  final EmployeeData? employeeData;
  
  const BrandDetailScreen({
    super.key,
    required this.branchInfo,
    this.user,
    this.employeeData,
  });

  @override
  State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends State<BrandDetailScreen> {
  // Track which tasks have been completed (for UI state management)
  Set<String> _completedTaskKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeCompletedTasks();
  }

  void _initializeCompletedTasks() {
    // Initialize completed tasks from API data
    for (var task in widget.branchInfo.tasks) {
      if (task.isCompleted) {
        _completedTaskKeys.add(_getTaskKey(task));
      }
    }
  }

  String _getTaskKey(Task task) {
    return '${task.brandName}_${task.quotationShareSubNo}';
  }

  bool _isTaskCompleted(Task task) {
    return _completedTaskKeys.contains(_getTaskKey(task)) || task.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFEFEFE),
              Color(0xFFF3F4F6),
              Color.fromARGB(255, 231, 188, 255),
            ],
            stops: [0.0, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branch Info
                      _buildBranchInfo(),
                      
                      const SizedBox(height: 20),
                      
                      // Brand List
                      _buildBrandList(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context, true), // ส่งสัญญาณกลับว่ามีการเปลี่ยนแปลง
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'คีย์ข้อมูลแบรนด์',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.white),
                      SizedBox(width: 8),
                      Text('รีเฟรชข้อมูลแล้ว'),
                    ],
                  ),
                  backgroundColor: Colors.blue.shade600,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchInfo() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.branchInfo.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'รหัส: ${widget.branchInfo.code}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'วันที่: ${_formatDateThai(widget.branchInfo.selectedDate)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandList() {
    if (widget.branchInfo.tasks.isEmpty) {
      return _buildEmptyState();
    }

    final completedCount = widget.branchInfo.tasks.where((task) => _isTaskCompleted(task)).length;
    final totalCount = widget.branchInfo.tasks.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'แบรนด์ที่ต้องคีย์ข้อมูล',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$completedCount/$totalCount',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Brand Cards
        ...widget.branchInfo.tasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBrandCard(task, index),
          );
        }).toList(),
        
        // Summary at bottom
        if (widget.branchInfo.tasks.isNotEmpty)
          _buildSummaryCard(completedCount, totalCount),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่มีแบรนด์ที่ต้องคีย์ยอด',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ในสาขานี้วันที่เลือก',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(Task task, int index) {
    final isCompleted = _isTaskCompleted(task);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              task.brandName,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green.shade100
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isCompleted ? '✓ สำเร็จแล้ว' : 'รอดำเนินการ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isCompleted 
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isCompleted 
                ? null 
                : () => _startBrandInput(task),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted 
                  ? Colors.green
                  : const Color.fromARGB(255, 255, 69, 69),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isCompleted ? 'คีย์แล้ว' : 'คีย์ข้อมูล',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int completedCount, int totalCount) {
    final double completionRate = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                size: 20,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'สรุปความคืบหน้า',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '${completionRate.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: completionRate == 100 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          LinearProgressIndicator(
            value: completionRate / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              completionRate == 100 ? Colors.green : Colors.orange,
            ),
            minHeight: 8,
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เสร็จแล้ว $completedCount จาก $totalCount แบรนด์',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              if (completionRate == 100)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'สำเร็จ!',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _startBrandInput(Task task) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // ไม่มีสีทึบข้างหลังเลย
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เริ่มคีย์ข้อมูล',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'คุณต้องการเริ่มคีย์ข้อมูลสำหรับ:',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 245, 227, 253),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.branding_watermark,
                          size: 16,
                          color: const Color.fromARGB(255, 183, 0, 255),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'แบรนด์: ${task.brandName}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 183, 0, 255),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: const Color.fromARGB(255, 183, 0, 255),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'สาขา: ${widget.branchInfo.name}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color.fromARGB(255, 183, 0, 255),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: const Color.fromARGB(255, 183, 0, 255),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'วันที่: ${_formatDateThai(widget.branchInfo.selectedDate)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 183, 0, 255),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 16,
                          color: const Color.fromARGB(255, 183, 0, 255),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'รหัส: ${task.quotationShareSubNo}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color.fromARGB(255, 183, 0, 255),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'ยกเลิก',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToInputForm(task);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 145, 62, 255),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'เริ่มคีย์',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToInputForm(Task task) async {
    // เรียก API อัพเดทสถานะการคีย์ยอด
    final employeeCode = widget.user?.username ?? widget.employeeData?.employeeCode;
    
    if (employeeCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่พบข้อมูลพนักงาน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      print('🔄 Updating key data status...');
      
      final result = await TaskService.updateKeyDataStatus(
        employeeCode: employeeCode,
        quotationShareSubNo: task.quotationShareSubNo,
        brandName: task.brandName,
        // TODO: เพิ่ม authToken ถ้าจำเป็น
      );

      // ปิด loading dialog
      Navigator.of(context).pop();

      if (result.isSuccess) {
        // อัพเดท local state
        setState(() {
          _completedTaskKeys.add(_getTaskKey(task));
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('คีย์ข้อมูลสำเร็จ!'),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'แบรนด์: ${task.brandName}',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ปิด loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _simulateTaskCompletion(Task task) {
    // Simulate task completion for demo purposes
    setState(() {
      _completedTaskKeys.add(_getTaskKey(task));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('คีย์ข้อมูลเสร็จสิ้น'),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'แบรนด์: ${task.brandName} | สาขา: ${widget.branchInfo.name}',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // เพิ่ม method สำหรับกลับไปหน้าก่อนหน้าพร้อมส่งสัญญาณ
  void _popWithResult() {
    Navigator.pop(context, true); // ส่งค่า true กลับไป
  }

  // Helper methods
  Color _getVisitStatusColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'amber':
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'gray':
      case 'grey':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _formatDateThai(DateTime date) {
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }
}