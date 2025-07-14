// lib/screens/work_main_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'brand_detail_screen.dart';
import '../models/task_models.dart';
import '../services/task_service.dart';
import '../models/user.dart';
import '../models/employee_data.dart';

class WorkMainScreen extends StatefulWidget {
  final User? user;
  final EmployeeData? employeeData;
  final DateTime? initialDate; // 🔥 เพิ่มบรรทัดนี้

  const WorkMainScreen({
    super.key,
    this.user,
    this.employeeData,
    this.initialDate, // 🔥 เพิ่มบรรทัดนี้
  });

  @override
  State<WorkMainScreen> createState() => _WorkMainScreenState();
}

class _WorkMainScreenState extends State<WorkMainScreen> {
  // Date selection state
  DateTime _selectedDate = DateTime.now();
  bool _isLoadingData = false;
  bool _isInitialLoading = true;

  // API Data
  TaskData? _taskData;
  String? _errorMessage;
  List<Branch> _branchesForSelectedDate = [];
  
  // Track completed tasks locally (sync กับ brand_detail_screen)
  Set<String> _localCompletedTasks = {};

  @override
  void initState() {
    super.initState();
    
    // 🔥 เพิ่มส่วนนี้ - Set initial date if provided from calendar
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    await _loadTaskData();

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadTaskData() async {
    final employeeCode = _getEmployeeCode();
    
    if (employeeCode == null) {
      setState(() {
        _errorMessage = 'ไม่พบข้อมูลพนักงาน กรุณาเข้าสู่ระบบใหม่';
      });
      return;
    }

    try {
      print('🔄 Loading task data for: $employeeCode');
      
      final result = await TaskService.getTasks(
        employeeCode: employeeCode,
        // TODO: ใส่ authToken ถ้ามี
        // authToken: await _getAuthToken(),
      );

      if (result.isSuccess && result.data != null) {
        setState(() {
          _taskData = result.data;
          _errorMessage = null;
        });
        
        // Load data for selected date
        await _loadDataForSelectedDate();
        
      } else {
        setState(() {
          _errorMessage = result.message;
          _taskData = null;
        });
      }
    } catch (e) {
      print('❌ Error loading task data: $e');
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      });
    }
  }

  Future<void> _loadDataForSelectedDate() async {
    if (_taskData == null) return;

    setState(() {
      _isLoadingData = true;
    });

    try {
      // Get tasks for selected date from cached data
      final groupedData = _taskData!.getGroupedByDate();
      final selectedDateKey = _formatDateKey(_selectedDate);
      final locationsForDate = groupedData[selectedDateKey] ?? [];
      
      // Convert to Branch objects และ update completion count ตาม local state
      final branches = locationsForDate.asMap().entries.map((entry) {
        final index = entry.key;
        final location = entry.value;
        
        // นับ completed tasks รวม API + local state
        int completedCount = 0;
        for (var task in location.tasks) {
          final taskKey = '${task.brandName}_${task.quotationShareSubNo}';
          if (task.isCompleted || _localCompletedTasks.contains(taskKey)) {
            completedCount++;
          }
        }
        
        // สร้าง Branch พร้อม updated completion count
        final originalBranch = Branch.fromTaskLocation(location, index + 1, _selectedDate);
        return Branch(
          id: originalBranch.id,
          name: originalBranch.name,
          code: originalBranch.code,
          address: originalBranch.address,
          status: completedCount == location.totalTasks ? 'completed' : 
                  completedCount > 0 ? 'in_progress' : 'pending',
          totalBrands: originalBranch.totalBrands,
          completedBrands: completedCount, // ใช้ค่าที่คำนวณใหม่
          lastVisit: originalBranch.lastVisit,
          selectedDate: originalBranch.selectedDate,
        );
      }).toList();
      
      setState(() {
        _branchesForSelectedDate = branches;
        _isLoadingData = false;
      });
      
      print('📅 Loaded ${branches.length} branches for ${_formatDateThai(_selectedDate)}');
      
    } catch (e) {
      print('❌ Error loading data for selected date: $e');
      setState(() {
        _isLoadingData = false;
        _errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูลวันที่เลือก';
      });
    }
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
              _buildHeader(context),
              
              // Content
              Expanded(
                child: _isInitialLoading
                    ? _buildInitialLoading()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _buildContent(),
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
          Expanded(
            child: Text(
              'งานของฉัน',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: _refreshData,
            icon: Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            'กำลังโหลดข้อมูลงาน...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'เกิดข้อผิดพลาด',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Show detailed error message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 8),
              // Show employee code being used
              if (_getEmployeeCode() != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    'Employee Code: ${_getEmployeeCode()}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: Icon(Icons.refresh),
                label: Text('ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(),
          
          const SizedBox(height: 20),
          
          // Branch tasks list
          _buildBranchTasksList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Calculate summary from current branches
    final totalBranches = _branchesForSelectedDate.length;
    final completedBranches = _branchesForSelectedDate.where((b) => b.status == 'completed').length;
    final inProgressBranches = _branchesForSelectedDate.where((b) => b.status == 'in_progress').length;
    final pendingBranches = totalBranches - completedBranches - inProgressBranches;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.store,
            title: 'สาขาทั้งหมด',
            count: '$totalBranches',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.pending_actions,
            title: 'กำลังทำ',
            count: '$inProgressBranches',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.check_circle,
            title: 'เสร็จแล้ว',
            count: '$completedBranches',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
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
          if (_branchesForSelectedDate.isNotEmpty) ...[
            ..._branchesForSelectedDate.map((branch) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBranchCard(branch),
            )).toList(),
          ] else ...[
            // No data message
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
                    'ไม่มีงานในวันที่เลือก',
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
                    ],
                  ),
                ),
              ),
              
              // ปุ่มถัดไป
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
        ],
      ),
    );
  }

  Widget _buildBranchCard(Branch branch) {
    final completionRate = branch.completionRate;
    
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        branch.code,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(branch.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${branch.completedBrands}/${branch.totalBrands}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(branch.status),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: completionRate / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(branch.status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Text(
                  '${completionRate.toStringAsFixed(0)}% เสร็จแล้ว',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                if (branch.lastVisit != null) ...[
                  Text(
                    'เยี่ยมล่าสุด: ${_formatDateThai(branch.lastVisit!)}',
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

  void _onBranchTap(Branch branch) async {
    // Get the original tasks for this branch from API data
    List<Task> tasks = [];
    
    if (_taskData != null) {
      final groupedData = _taskData!.getGroupedByDate();
      final selectedDateKey = _formatDateKey(_selectedDate);
      final locationsForDate = groupedData[selectedDateKey] ?? [];
      
      // Find the location that matches this branch
      for (var location in locationsForDate) {
        if (location.storeNameThai == branch.name && 
            location.accountNameEnglish == branch.code) {
          tasks = location.tasks;
          break;
        }
      }
    }

    // Navigate และรอรับผลลัพธ์กลับมา
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandDetailScreen(
          branchInfo: BranchInfo(
            id: branch.id,
            name: branch.name,
            code: branch.code,
            selectedDate: _selectedDate,
            tasks: tasks, // ส่ง tasks จริงจาก API
          ),
          user: widget.user,
          employeeData: widget.employeeData,
        ),
      ),
    );
    
    // ถ้ามีการอัพเดทข้อมูล ให้ sync local state
    if (result is Map<String, dynamic> && result['hasChanges'] == true) {
      final completedTaskKeys = result['completedTasks'] as Set<String>? ?? {};
      setState(() {
        _localCompletedTasks.addAll(completedTaskKeys);
      });
      
      // Refresh the current date data
      await _loadDataForSelectedDate();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadDataForSelectedDate();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDataForSelectedDate();
    }
  }

  Future<void> _refreshData() async {
    // Show loading snackbar
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
            Text('กำลังรีเฟรชข้อมูล...'),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: Duration(seconds: 2),
      ),
    );

    // Clear cache and reload
    TaskService.clearCache();
    await _loadTaskData();

    // Show success message
    if (mounted && _errorMessage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('รีเฟรชข้อมูลเสร็จสิ้น'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper methods
  String? _getEmployeeCode() {
    return widget.employeeData?.employeeCode ?? 
           widget.user?.username;
  }

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

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateThai(DateTime date) {
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }
}