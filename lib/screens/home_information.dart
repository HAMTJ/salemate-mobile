import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../models/user.dart';
import '../models/employee_data.dart';
import '../models/task_models.dart';
import '../services/task_service.dart';
import 'work_main_screen.dart';

class HomeInformationWidget extends StatefulWidget {
  final User? user;
  final EmployeeData? employeeData;
  
  const HomeInformationWidget({
    super.key,
    this.user,
    this.employeeData,
  });

  @override
  State<HomeInformationWidget> createState() => _HomeInformationWidgetState();
}

class _HomeInformationWidgetState extends State<HomeInformationWidget> {
  List<RecentReportItem> _recentReports = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecentReports();
  }

  Future<void> _loadRecentReports() async {
    if (widget.employeeData?.employeeCode == null) {
      setState(() {
        _errorMessage = 'ไม่พบรหัสพนักงาน';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await TaskService.getTasks(
        employeeCode: widget.employeeData!.employeeCode!,
      );

      if (result.isSuccess && result.data != null) {
        final recentReports = _convertToRecentReports(result.data!);
        setState(() {
          _recentReports = recentReports;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<RecentReportItem> _convertToRecentReports(TaskData taskData) {
    List<RecentReportItem> reports = [];
    
    // รวบรวมข้อมูลจากทุกสาขาและเรียงตามวันที่ล่าสุด
    for (var workType in taskData.workTypes) {
      for (var date in workType.dates) {
        for (var location in date.locations) {
          for (var task in location.tasks) {
            reports.add(RecentReportItem(
              branchName: location.storeNameThai,
              brandName: location.accountNameEnglish,
              reportTime: _formatTime(date.workingDate),
              reportDate: _formatDate(date.workingDate),
              status: task.isCompleted ? 'completed' : 'in_progress',
              workType: workType.workType,
              originalDate: date.workingDate,
              quotationShareSubNo: task.quotationShareSubNo,
            ));
          }
        }
      }
    }
    
    // เรียงตามวันที่ล่าสุดและเอา 5 อันดับแรก
    reports.sort((a, b) => b.originalDate.compareTo(a.originalDate));
    return reports.take(5).toList();
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (targetDate == today) {
      return 'วันนี้';
    } else if (targetDate == yesterday) {
      return 'เมื่อวาน';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Recent Reports - รายงานที่คีย์ไปล่าสุด
          _buildRecentReportsSection(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecentReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'รายงานล่าสุด',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // นำทางไปหน้างาน
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkMainScreen(
                      user: widget.user,
                      employeeData: widget.employeeData,
                    ),
                  ),
                );
              },
              child: Text(
                'ดูทั้งหมด',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // แสดงเนื้อหาตามสถานะ
        _buildReportsContent(),
      ],
    );
  }

  Widget _buildReportsContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_recentReports.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildReportsList();
    }
  }

  Widget _buildLoadingState() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              'กำลังโหลดรายงานล่าสุด...',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'เกิดข้อผิดพลาด',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRecentReports,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'ไม่มีรายงานล่าสุด',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ยังไม่มีการคีย์รายงานใดๆ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _recentReports.asMap().entries.map((entry) {
          final index = entry.key;
          final report = entry.value;
          return Column(
            children: [
              _buildReportItem(report),
              if (index < _recentReports.length - 1) const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportItem(RecentReportItem report) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (report.status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'เสร็จแล้ว';
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'กำลังทำ';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.radio_button_unchecked;
        statusText = 'รอดำเนินการ';
    }

    return InkWell(
      onTap: () {
        // นำทางไปหน้ารายละเอียดรายงาน
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkMainScreen(
              user: widget.user,
              employeeData: widget.employeeData,
              initialDate: report.originalDate, // ส่งวันที่ไปด้วย
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Store Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.store,
                color: Colors.blue.shade600,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Branch & Brand Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.branchName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    report.brandName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // แสดง Work Type เพิ่มเติม
                  Text(
                    report.workType,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.black45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Time & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${report.reportTime} • ${report.reportDate}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Model สำหรับรายงานล่าสุด
class RecentReportItem {
  final String branchName;
  final String brandName;
  final String reportTime;
  final String reportDate;
  final String status;
  final String workType;
  final DateTime originalDate;
  final String quotationShareSubNo;

  RecentReportItem({
    required this.branchName,
    required this.brandName,
    required this.reportTime,
    required this.reportDate,
    required this.status,
    required this.workType,
    required this.originalDate,
    required this.quotationShareSubNo,
  });
}