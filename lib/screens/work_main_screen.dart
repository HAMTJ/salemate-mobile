import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'brand_detail_screen.dart';

// Branch Model
class Branch {
  final int id;
  final String name;
  final String code;
  final String address;
  final String status;
  final int totalBrands;
  final int completedBrands;
  final DateTime? lastVisit;

  Branch({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.status,
    required this.totalBrands,
    required this.completedBrands,
    this.lastVisit,
  });

  double get completionRate => totalBrands > 0 ? (completedBrands / totalBrands) * 100 : 0;
}

// Work Main Screen
class WorkMainScreen extends StatefulWidget {
  const WorkMainScreen({super.key});

  @override
  State<WorkMainScreen> createState() => _WorkMainScreenState();
}

class _WorkMainScreenState extends State<WorkMainScreen> {
  // Date selection state
  DateTime _selectedDate = DateTime.now();
  bool _isLoadingData = false;

  // Mock data สำหรับสาขาต่างๆ
  List<Branch> get _mockBranches => [
    Branch(
      id: 1,
      name: 'WATSONS 890 สยามเซ็นเตอร์',
      code: 'WT890',
      address: 'ชั้น B1 สยามเซ็นเตอร์',
      status: 'pending',
      totalBrands: 3,
      completedBrands: 1,
      lastVisit: DateTime.now().subtract(Duration(days: 2)),
    ),
    Branch(
      id: 2,
      name: 'WATSONS 234 เซ็นทรัลเวิลด์',
      code: 'WT234',
      address: 'ชั้น G เซ็นทรัลเวิลด์',
      status: 'in_progress',
      totalBrands: 4,
      completedBrands: 2,
      lastVisit: DateTime.now().subtract(Duration(days: 1)),
    ),
    Branch(
      id: 3,
      name: 'WATSONS 156 เทอร์มินอล 21',
      code: 'WT156',
      address: 'ชั้น M เทอร์มินอล 21',
      status: 'completed',
      totalBrands: 2,
      completedBrands: 2,
      lastVisit: DateTime.now().subtract(Duration(hours: 6)),
    ),
    Branch(
      id: 4,
      name: 'WATSONS 445 เอ็มโพเรียม',
      code: 'WT445',
      address: 'ชั้น 1 เอ็มโพเรียม',
      status: 'pending',
      totalBrands: 5,
      completedBrands: 0,
      lastVisit: null,
    ),
    Branch(
      id: 5,
      name: 'WATSONS 178 ดิ เอ็มควอเทียร์',
      code: 'WT178',
      address: 'ชั้น G ดิ เอ็มควอเทียร์',
      status: 'pending',
      totalBrands: 3,
      completedBrands: 0,
      lastVisit: null,
    ),
  ];

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
              _buildHeader(context),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Work Status Summary
                      _buildWorkStatusSummary(),
                      
                      const SizedBox(height: 20),
                      
                      // Branch Tasks List with Date Selector
                      _buildBranchTasksList(),
                      
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'งานของฉัน',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
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

  Widget _buildWorkStatusSummary() {
    final totalBranches = _mockBranches.length;
    final completedBranches = _mockBranches.where((b) => b.status == 'completed').length;
    final inProgressBranches = _mockBranches.where((b) => b.status == 'in_progress').length;
    final pendingBranches = _mockBranches.where((b) => b.status == 'pending').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'สรุปภาพรวม',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                title: 'สาขาทั้งหมด',
                count: '$totalBranches',
                color: Colors.blue,
                icon: Icons.store,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusCard(
                title: 'กำลังดำเนินการ',
                count: '$inProgressBranches',
                color: Colors.orange,
                icon: Icons.pending_actions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                title: 'รอดำเนินการ',
                count: '$pendingBranches',
                color: Colors.red,
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusCard(
                title: 'เสร็จแล้ว',
                count: '$completedBranches',
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBranchTasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selector
        _buildDateSelector(),
        
        const SizedBox(height: 16),
        
        // Loading indicator
        if (_isLoadingData)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          // Branch cards
          ..._mockBranches.map((branch) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBranchCard(branch),
          )).toList(),
          
          // No data message for other dates (example)
          if (!_isToday() && _mockBranches.length < 3)
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'งานน้อยกว่าปกติ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'วันที่ ${_formatDateThai(_selectedDate)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildDateSelector() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'งานที่ต้องทำ',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ปุ่มย้อนกลับ
              IconButton(
                onPressed: () => _changeDate(-1),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
              ),
              
              // วันที่ปัจจุบัน
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isToday() 
                        ? Colors.orange.shade100
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isToday() 
                          ? Colors.orange.shade300
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: _isToday() 
                            ? Colors.orange.shade700
                            : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatSelectedDate(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isToday() 
                              ? Colors.orange.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                      if (_isToday()) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'วันนี้',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // ปุ่มไปข้างหน้า
              IconButton(
                onPressed: () => _changeDate(1),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          // Quick date buttons
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickDateButton('เมื่อวาน', -1),
              _buildQuickDateButton('วันนี้', 0),
              _buildQuickDateButton('พรุ่งนี้', 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateButton(String label, int dayOffset) {
    final targetDate = DateTime.now().add(Duration(days: dayOffset));
    final isSelected = _isSameDay(_selectedDate, targetDate);
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = targetDate;
          _isLoadingData = true;
        });
        
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isLoadingData = false;
            });
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.orange.shade200
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected 
                ? Colors.orange.shade800
                : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCard(Branch branch) {
    Color statusColor = _getStatusColor(branch.status);
    String statusText = _getStatusText(branch.status);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _onBranchTap(branch),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'รหัส: ${branch.code}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress section
            Row(
              children: [
                Text(
                  'ความคืบหน้า:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: branch.completionRate / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${branch.completedBrands}/${branch.totalBrands}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Text(
                  'แบรนด์: ${branch.totalBrands} แบรนด์',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                const Spacer(),
                if (branch.lastVisit != null) ...[
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatLastVisit(branch.lastVisit!),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ] else ...[
                  Text(
                    'ยังไม่เคยเข้า',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.black54,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onBranchTap(Branch branch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandDetailScreen(
          branchInfo: BranchInfo(
            id: branch.id,
            name: branch.name,
            code: branch.code,
            selectedDate: _selectedDate,
          ),
        ),
      ),
    );
  }

  // Date methods
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _isLoadingData = true;
    });
    
    // Simulate API call
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    });
  }

void _selectDate() async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                ),
                Text(
                  'เลือกวันที่',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isLoadingData = true;
                    });
                    Future.delayed(Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() {
                          _isLoadingData = false;
                        });
                      }
                    });
                  },
                  child: Text('เสร็จ', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          // Date picker
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate,
              minimumDate: DateTime.now().subtract(Duration(days: 30)),
              maximumDate: DateTime.now().add(Duration(days: 30)),
              onDateTimeChanged: (DateTime date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  // Helper methods
  bool _isToday() {
    final now = DateTime.now();
    return _isSameDay(_selectedDate, now);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _formatSelectedDate() {
    final now = DateTime.now();
    final difference = _selectedDate.difference(now).inDays;
    
    if (difference == 0) {
      return 'วันนี้ ${_formatDateThai(_selectedDate)}';
    } else if (difference == 1) {
      return 'พรุ่งนี้ ${_formatDateThai(_selectedDate)}';
    } else if (difference == -1) {
      return 'เมื่อวาน ${_formatDateThai(_selectedDate)}';
    } else {
      return _formatDateThai(_selectedDate);
    }
  }

  String _formatDateThai(DateTime date) {
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'เสร็จแล้ว';
      case 'in_progress':
        return 'กำลังดำเนินการ';
      case 'pending':
      default:
        return 'รอดำเนินการ';
    }
  }

  String _formatLastVisit(DateTime lastVisit) {
    final now = DateTime.now();
    final difference = now.difference(lastVisit);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else {
      return '${difference.inMinutes} นาทีที่แล้ว';
    }
  }
}