// lib/screens/calendar_work_widgets.dart
// ⚠️ แทนที่ไฟล์เดิมทั้งหมด

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../widgets/calendar/smart_calendar.dart';
import '../widgets/calendar/calendar_models.dart';
import '../widgets/common/floating_quick_actions.dart';
import '../models/task_models.dart';
import '../models/user.dart';
import '../models/employee_data.dart';
import '../services/task_service.dart';
import 'work_main_screen.dart';

class CalendarPageWidget extends StatefulWidget {
  final User? user;
  final EmployeeData? employeeData;

  const CalendarPageWidget({
    super.key,
    this.user,
    this.employeeData,
  });

  @override
  State<CalendarPageWidget> createState() => _CalendarPageWidgetState();
}

class _CalendarPageWidgetState extends State<CalendarPageWidget> {
  CalendarViewMode _currentViewMode = CalendarViewMode.month;
  TaskData? _taskData;
  Map<DateTime, CalendarDayData> _calendarData = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> _loadTaskData() async {
    final employeeCode = _getEmployeeCode();
    
    if (employeeCode == null) {
      setState(() {
        _errorMessage = 'ไม่พบข้อมูลพนักงาน กรุณาเข้าสู่ระบบใหม่';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading task data for calendar: $employeeCode');
      
      final result = await TaskService.getTasks(
        employeeCode: employeeCode,
      );

      if (result.isSuccess && result.data != null) {
        setState(() {
          _taskData = result.data;
          _calendarData = _convertTaskDataToCalendarData(result.data!);
          _errorMessage = null;
          _isLoading = false;
        });
        
        print('✅ Calendar data loaded: ${_calendarData.length} days');
        
      } else {
        setState(() {
          _errorMessage = result.message;
          _taskData = null;
          _calendarData = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading calendar data: $e');
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Map<DateTime, CalendarDayData> _convertTaskDataToCalendarData(TaskData taskData) {
    Map<DateTime, CalendarDayData> result = {};
    
    for (var workType in taskData.workTypes) {
      for (var workingDate in workType.dates) {
        final date = DateTime(
          workingDate.workingDate.year,
          workingDate.workingDate.month,
          workingDate.workingDate.day,
        );
        
        // Aggregate data for this date
        int totalTasks = 0;
        int completedTasks = 0;
        List<String> highlights = [];
        
        for (var location in workingDate.locations) {
          totalTasks += location.totalTasks;
          // 🔥 แก้ไขการนับ completed tasks
          for (var task in location.tasks) {
            if (task.isCompleted) {
              completedTasks++;
            }
          }
          
          // Add location name as highlight if has work
          if (location.totalTasks > 0) {
            highlights.add(location.storeNameThai);
          }
        }
        
        // Determine status color
        Color statusColor;
        if (completedTasks == totalTasks && totalTasks > 0) {
          statusColor = Colors.green; // All completed
        } else if (completedTasks > 0) {
          statusColor = Colors.orange; // In progress
        } else if (totalTasks > 0) {
          statusColor = Colors.red; // Not started
        } else {
          statusColor = Colors.grey; // No work
        }
        
        result[date] = CalendarDayData(
          date: date,
          totalTasks: totalTasks,
          completedTasks: completedTasks,
          hasWork: totalTasks > 0,
          highlights: highlights,
          statusColor: statusColor,
        );
      }
    }
    
    return result;
  }

  void _handleDateSelected(DateTime date) {
    // Navigate to work screen for selected date
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkMainScreen(
          user: widget.user,
          employeeData: widget.employeeData,
          initialDate: date, // Pass selected date
        ),
      ),
    );
  }

  void _handleQuickAction(DateTime date, QuickActionType action) {
    switch (action) {
      case QuickActionType.doubleTap:
        _handleDateSelected(date);
        break;
      case QuickActionType.longPress:
        // Note dialog is handled automatically by SmartCalendar
        break;
      default:
        break;
    }
  }

  void _handleNoteSaved(DateTime date, String note) {
    // TODO: Save to SharedPreferences or backend
    print('📝 Note saved for ${date.toIso8601String()}: $note');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text('บันทึกโน้ตเรียบร้อย'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleRefresh() {
    _loadTaskData();
  }

  void _jumpToToday() {
    // Calendar will handle jumping to today
  }

  void _changeViewMode() {
    setState(() {
      switch (_currentViewMode) {
        case CalendarViewMode.month:
          _currentViewMode = CalendarViewMode.week;
          break;
        case CalendarViewMode.week:
          _currentViewMode = CalendarViewMode.year;
          break;
        case CalendarViewMode.year:
          _currentViewMode = CalendarViewMode.month;
          break;
      }
    });
  }

  String? _getEmployeeCode() {
    return widget.employeeData?.employeeCode ?? 
           widget.user?.username;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'ปฏิทินงาน',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Error message
            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadTaskData,
                        child: Text('ลองใหม่'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
            
            // Loading indicator
            if (_isLoading) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'กำลังโหลดข้อมูลปฏิทิน...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
            // Calendar
            else ...[
              Expanded(
                child: SmartCalendar(
                  initialDate: DateTime.now(),
                  initialViewMode: _currentViewMode,
                  calendarData: _calendarData,
                  config: CalendarConfig(
                    enableQuickActions: true,
                    enableHeatMap: true,
                    enablePersonalNotes: true,
                    enableSwipeGestures: true,
                    enablePinchZoom: false, // 🔥 ปิด pinch zoom
                    primaryColor: Colors.orange.shade600,
                    completedColor: Colors.green,
                    pendingColor: Colors.orange,
                    todayColor: Colors.blue.shade600,
                  ),
                  onDateSelected: _handleDateSelected,
                  onQuickAction: _handleQuickAction,
                  onNoteSaved: _handleNoteSaved,
                  onRefreshRequested: _handleRefresh,
                  showHeader: true,
                  enableInteractions: true,
                ),
              ),
            ],
            
            // Summary footer
            if (!_isLoading && _errorMessage == null) ...[
              _buildSummaryFooter(),
            ],
          ],
        ),
        
        // Floating Actions - ปิดใช้งาน
        // Positioned(
        //   bottom: 20,
        //   right: 20,
        //   child: FloatingQuickActions(
        //     onTodayPressed: _jumpToToday,
        //     onRefreshPressed: _handleRefresh,
        //     onCalendarMode: _changeViewMode,
        //     primaryColor: Colors.orange.shade600,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildSummaryFooter() {
    // Calculate summary stats
    int totalDaysWithWork = 0;
    int totalTasks = 0;
    int completedTasks = 0;
    
    for (var dayData in _calendarData.values) {
      if (dayData.hasWork) {
        totalDaysWithWork++;
        totalTasks += dayData.totalTasks;
        completedTasks += dayData.completedTasks;
      }
    }
    
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.calendar_today,
                label: 'วันที่มีงาน',
                value: '$totalDaysWithWork วัน',
                color: Colors.blue.shade600,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.task_alt,
                label: 'ความคืบหน้า',
                value: '${completionRate.toStringAsFixed(0)}%',
                color: completionRate > 80 ? Colors.green : Colors.orange,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.assignment,
                label: 'งานทั้งหมด',
                value: '$totalTasks งาน',
                color: Colors.purple.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getViewModeLabel() {
    switch (_currentViewMode) {
      case CalendarViewMode.week:
        return 'มุมมองสัปดาห์';
      case CalendarViewMode.month:
        return 'มุมมองเดือน';
      case CalendarViewMode.year:
        return 'มุมมองปี';
    }
  }
}