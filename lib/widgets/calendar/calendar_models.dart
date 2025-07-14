// lib/widgets/calendar/calendar_models.dart

import 'package:flutter/material.dart';

/// Calendar view modes
enum CalendarViewMode { 
  week, 
  month, 
  year 
}

/// Data for each day in the calendar
class CalendarDayData {
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final String? personalNote;
  final List<String> highlights;
  final bool hasWork;
  final Color? statusColor;

  CalendarDayData({
    required this.date,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.personalNote,
    this.highlights = const [],
    this.hasWork = false,
    this.statusColor,
  });

  /// Calculate completion percentage
  double get completionRate => totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  /// Check if all tasks are completed
  bool get isCompleted => totalTasks > 0 && completedTasks >= totalTasks;

  /// Check if has pending tasks
  bool get hasPendingTasks => totalTasks > completedTasks;

  /// Get status color based on completion
  Color getStatusColor() {
    if (statusColor != null) return statusColor!;
    
    if (!hasWork) return Colors.grey.shade300;
    if (isCompleted) return Colors.green;
    if (hasPendingTasks) return Colors.orange;
    return Colors.red;
  }

  /// Get intensity for heat map (0.0 to 1.0)
  double get heatMapIntensity {
    if (!hasWork) return 0.0;
    return (completionRate / 100).clamp(0.2, 1.0); // Min 0.2 for visibility
  }

  CalendarDayData copyWith({
    DateTime? date,
    int? totalTasks,
    int? completedTasks,
    String? personalNote,
    List<String>? highlights,
    bool? hasWork,
    Color? statusColor,
  }) {
    return CalendarDayData(
      date: date ?? this.date,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      personalNote: personalNote ?? this.personalNote,
      highlights: highlights ?? this.highlights,
      hasWork: hasWork ?? this.hasWork,
      statusColor: statusColor ?? this.statusColor,
    );
  }

  @override
  String toString() {
    return 'CalendarDayData(date: $date, tasks: $completedTasks/$totalTasks, hasWork: $hasWork)';
  }
}

/// Calendar configuration and settings
class CalendarConfig {
  final bool enableQuickActions;
  final bool enableHeatMap;
  final bool enablePersonalNotes;
  final bool enableSwipeGestures;
  final bool enablePinchZoom;
  final Color primaryColor;
  final Color completedColor;
  final Color pendingColor;
  final Color todayColor;

  const CalendarConfig({
    this.enableQuickActions = true,
    this.enableHeatMap = true,
    this.enablePersonalNotes = true,
    this.enableSwipeGestures = true,
    this.enablePinchZoom = true,
    this.primaryColor = Colors.orange,
    this.completedColor = Colors.green,
    this.pendingColor = Colors.orange,
    this.todayColor = Colors.blue,
  });

  CalendarConfig copyWith({
    bool? enableQuickActions,
    bool? enableHeatMap,
    bool? enablePersonalNotes,
    bool? enableSwipeGestures,
    bool? enablePinchZoom,
    Color? primaryColor,
    Color? completedColor,
    Color? pendingColor,
    Color? todayColor,
  }) {
    return CalendarConfig(
      enableQuickActions: enableQuickActions ?? this.enableQuickActions,
      enableHeatMap: enableHeatMap ?? this.enableHeatMap,
      enablePersonalNotes: enablePersonalNotes ?? this.enablePersonalNotes,
      enableSwipeGestures: enableSwipeGestures ?? this.enableSwipeGestures,
      enablePinchZoom: enablePinchZoom ?? this.enablePinchZoom,
      primaryColor: primaryColor ?? this.primaryColor,
      completedColor: completedColor ?? this.completedColor,
      pendingColor: pendingColor ?? this.pendingColor,
      todayColor: todayColor ?? this.todayColor,
    );
  }
}

/// Quick action types
enum QuickActionType {
  doubleTap,
  longPress,
  swipeLeft,
  swipeRight,
  pinchIn,
  pinchOut,
}

/// Quick action callback definition
typedef QuickActionCallback = void Function(DateTime date, QuickActionType action);

/// Note save callback definition
typedef NoteSaveCallback = void Function(DateTime date, String note);

/// Date selection callback definition
typedef DateSelectionCallback = void Function(DateTime date);

/// View mode change callback definition
typedef ViewModeChangeCallback = void Function(CalendarViewMode mode);

/// Thai month names
class ThaiCalendarUtils {
  static const List<String> thaiMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
  ];

  static const List<String> thaiMonthsFull = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];

  static const List<String> thaiDayNames = [
    'อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'
  ];

  static const List<String> thaiDayNamesFull = [
    'อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์'
  ];

  /// Format date to Thai format
  static String formatThaiDate(DateTime date) {
    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year + 543}';
  }

  /// Format month year to Thai format
  static String formatThaiMonthYear(DateTime date) {
    return '${thaiMonthsFull[date.month - 1]} ${date.year + 543}';
  }

  /// Get Thai day name
  static String getThaiDayName(DateTime date, {bool short = true}) {
    final names = short ? thaiDayNames : thaiDayNamesFull;
    return names[date.weekday % 7]; // Sunday = 0, Monday = 1, etc.
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if date is same month
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  /// Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get first day of week (Sunday)
  static DateTime getFirstDayOfWeek(DateTime date) {
    final weekday = date.weekday % 7; // Convert to Sunday = 0
    return date.subtract(Duration(days: weekday));
  }

  /// Generate calendar grid for month view
  static List<List<DateTime?>> generateMonthGrid(DateTime month) {
    final firstDay = getFirstDayOfMonth(month);
    final lastDay = getLastDayOfMonth(month);
    final startDate = getFirstDayOfWeek(firstDay);
    
    List<List<DateTime?>> weeks = [];
    DateTime currentDate = startDate;
    
    while (weeks.length < 6) { // Max 6 weeks
      List<DateTime?> week = [];
      
      for (int i = 0; i < 7; i++) {
        if (currentDate.month == month.month) {
          week.add(currentDate);
        } else {
          week.add(null); // Outside current month
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      weeks.add(week);
      
      // Stop if we've passed the last day and have at least 4 weeks
      if (currentDate.isAfter(lastDay) && weeks.length >= 4) {
        break;
      }
    }
    
    return weeks;
  }
}