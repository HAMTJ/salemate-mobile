// lib/widgets/calendar/smart_calendar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../glass_container.dart';
import 'calendar_models.dart';
import 'calendar_header.dart';
import 'calendar_day_cell.dart';
import 'calendar_gestures.dart';
import 'quick_note_dialog.dart';

class SmartCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final CalendarViewMode initialViewMode;
  final CalendarConfig config;
  final Map<DateTime, CalendarDayData>? calendarData;
  final DateSelectionCallback? onDateSelected;
  final QuickActionCallback? onQuickAction;
  final NoteSaveCallback? onNoteSaved;
  final VoidCallback? onRefreshRequested;
  final double? height;
  final bool showHeader;
  final bool enableInteractions;

  const SmartCalendar({
    Key? key,
    this.initialDate,
    this.initialViewMode = CalendarViewMode.month,
    this.config = const CalendarConfig(),
    this.calendarData,
    this.onDateSelected,
    this.onQuickAction,
    this.onNoteSaved,
    this.onRefreshRequested,
    this.height,
    this.showHeader = true,
    this.enableInteractions = true,
  }) : super(key: key);

  @override
  State<SmartCalendar> createState() => _SmartCalendarState();
}

class _SmartCalendarState extends State<SmartCalendar>
    with TickerProviderStateMixin {
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late CalendarViewMode _viewMode;
  late PageController _pageController;
  late AnimationController _transitionController;
  
  // Local storage for personal notes
  Map<String, String> _personalNotes = {};

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
    _selectedDate = _currentDate;
    _viewMode = widget.initialViewMode;
    _pageController = PageController(initialPage: 1000); // Start in middle for infinite scroll
    
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _loadPersonalNotes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _loadPersonalNotes() {
    // TODO: Load from SharedPreferences or local storage
    // For now, use empty map
    _personalNotes = {};
  }

  void _savePersonalNote(DateTime date, String note) {
    final key = _formatDateKey(date);
    setState(() {
      if (note.isEmpty) {
        _personalNotes.remove(key);
      } else {
        _personalNotes[key] = note;
      }
    });
    
    // TODO: Save to SharedPreferences or local storage
    widget.onNoteSaved?.call(date, note);
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  CalendarDayData? _getCalendarDayData(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    final apiData = widget.calendarData?[key];
    final personalNote = _personalNotes[_formatDateKey(date)];
    
    if (apiData != null) {
      return apiData.copyWith(personalNote: personalNote);
    } else if (personalNote != null) {
      return CalendarDayData(
        date: date,
        personalNote: personalNote,
      );
    }
    
    return null;
  }

  void _handleDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    
    widget.onDateSelected?.call(date);
    widget.onQuickAction?.call(date, QuickActionType.doubleTap);
  }

  void _handleDateDoubleTap(DateTime date) {
    widget.onQuickAction?.call(date, QuickActionType.doubleTap);
  }

  void _handleDateLongPress(DateTime date) {
    if (!widget.config.enablePersonalNotes) return;
    
    final existingNote = _personalNotes[_formatDateKey(date)];
    
    showQuickNoteDialog(
      context: context,
      date: date,
      existingNote: existingNote,
      onSave: _savePersonalNote,
      onDelete: () => _savePersonalNote(date, ''),
    );
    
    widget.onQuickAction?.call(date, QuickActionType.longPress);
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month + direction,
        1,
      );
    });
    
    _transitionController.forward().then((_) {
      _transitionController.reset();
    });
  }

  void _changeViewMode(CalendarViewMode newMode) {
    setState(() {
      _viewMode = newMode;
    });
  }

  void _jumpToToday() {
    setState(() {
      _currentDate = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Container(
        height: widget.height,
        child: Column(
          children: [
            if (widget.showHeader) ...[
              CalendarHeader(
                currentDate: _currentDate,
                viewMode: _viewMode,
                config: widget.config,
                onPreviousMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
                onTodayPressed: _jumpToToday,
                onViewModeChanged: _changeViewMode,
              ),
            ],
            
            Expanded(
              child: CalendarGestureWrapper(
                config: widget.config,
                currentViewMode: _viewMode,
                onMonthChanged: _changeMonth,
                onViewModeChanged: _changeViewMode,
                onRefreshRequested: widget.onRefreshRequested,
                child: _buildCalendarContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    switch (_viewMode) {
      case CalendarViewMode.week:
        return _buildWeekView();
      case CalendarViewMode.month:
        return _buildMonthView();
      case CalendarViewMode.year:
        return _buildYearView();
    }
  }

  Widget _buildMonthView() {
    final monthGrid = ThaiCalendarUtils.generateMonthGrid(_currentDate);
    
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _transitionController.value,
          child: Transform.translate(
            offset: Offset(_transitionController.value * 50, 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: monthGrid.map((week) {
                  return Expanded(
                    child: Row(
                      children: week.map((date) {
                        if (date == null) {
                          return Expanded(child: SizedBox());
                        }
                        
                        final dayData = _getCalendarDayData(date);
                        final isToday = ThaiCalendarUtils.isToday(date);
                        final isSelected = _isSameDay(date, _selectedDate);
                        final isCurrentMonth = ThaiCalendarUtils.isSameMonth(date, _currentDate);
                        
                        return Expanded(
                          child: CalendarDayCell(
                            date: date,
                            dayData: dayData,
                            isToday: isToday,
                            isSelected: isSelected,
                            isCurrentMonth: isCurrentMonth,
                            config: widget.config,
                            onTap: widget.enableInteractions 
                                ? () => _handleDateTap(date)
                                : null,
                            onDoubleTap: widget.enableInteractions 
                                ? () => _handleDateDoubleTap(date)
                                : null,
                            onLongPress: widget.enableInteractions 
                                ? () => _handleDateLongPress(date)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekView() {
    final startOfWeek = ThaiCalendarUtils.getFirstDayOfWeek(_selectedDate);
    final weekDays = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Week navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'สัปดาห์ที่ ${_getWeekOfYear(_selectedDate)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(Duration(days: 7));
                        _currentDate = _selectedDate;
                      });
                    },
                    icon: Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(Duration(days: 7));
                        _currentDate = _selectedDate;
                      });
                    },
                    icon: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Week days
          Expanded(
            child: Row(
              children: weekDays.map((date) {
                final dayData = _getCalendarDayData(date);
                final isToday = ThaiCalendarUtils.isToday(date);
                final isSelected = _isSameDay(date, _selectedDate);
                
                return Expanded(
                  child: Column(
                    children: [
                      // Day header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Text(
                              ThaiCalendarUtils.getThaiDayName(date),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isToday 
                                    ? widget.config.todayColor
                                    : isSelected 
                                        ? widget.config.primaryColor.withOpacity(0.2)
                                        : Colors.transparent,
                                shape: BoxShape.circle,
                                border: isSelected 
                                    ? Border.all(color: widget.config.primaryColor)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                    color: isToday ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Day content
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.enableInteractions 
                              ? () => _handleDateTap(date)
                              : null,
                          onDoubleTap: widget.enableInteractions 
                              ? () => _handleDateDoubleTap(date)
                              : null,
                          onLongPress: widget.enableInteractions 
                              ? () => _handleDateLongPress(date)
                              : null,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: dayData?.hasWork == true 
                                  ? dayData!.getStatusColor().withOpacity(0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: _buildWeekDayContent(date, dayData),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDayContent(DateTime date, CalendarDayData? dayData) {
    if (dayData == null || !dayData.hasWork) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          'ไม่มีงาน',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: dayData.completionRate / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: dayData.getStatusColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Task count
          Text(
            '${dayData.completedTasks}/${dayData.totalTasks}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dayData.getStatusColor(),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Status text
          Text(
            dayData.isCompleted ? 'เสร็จแล้ว' : 'รอดำเนินการ',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          
          // Personal note indicator
          if (dayData.personalNote != null && dayData.personalNote!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.note,
              size: 12,
              color: Colors.blue.shade600,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildYearView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = DateTime(_currentDate.year, index + 1, 1);
          return _buildMiniMonthView(month);
        },
      ),
    );
  }

  Widget _buildMiniMonthView(DateTime month) {
    final monthGrid = ThaiCalendarUtils.generateMonthGrid(month);
    final monthData = _getMonthSummary(month);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentDate = month;
          _viewMode = CalendarViewMode.month;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThaiCalendarUtils.isSameMonth(month, DateTime.now())
                ? widget.config.todayColor
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            // Month header
            Text(
              ThaiCalendarUtils.thaiMonths[month.month - 1],
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Mini calendar grid
            Expanded(
              child: Column(
                children: monthGrid.take(5).map((week) {
                  return Expanded(
                    child: Row(
                      children: week.map((date) {
                        if (date == null) {
                          return Expanded(child: SizedBox());
                        }
                        
                        final dayData = _getCalendarDayData(date);
                        final isToday = ThaiCalendarUtils.isToday(date);
                        
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: isToday 
                                  ? widget.config.todayColor
                                  : dayData?.hasWork == true
                                      ? dayData!.getStatusColor().withOpacity(0.3)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isToday ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Month summary
            if (monthData.totalTasks > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${monthData.completedTasks}/${monthData.totalTasks}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  CalendarDayData _getMonthSummary(DateTime month) {
    int totalTasks = 0;
    int completedTasks = 0;
    
    final firstDay = ThaiCalendarUtils.getFirstDayOfMonth(month);
    final lastDay = ThaiCalendarUtils.getLastDayOfMonth(month);
    
    for (int day = firstDay.day; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final dayData = _getCalendarDayData(date);
      
      if (dayData != null && dayData.hasWork) {
        totalTasks += dayData.totalTasks;
        completedTasks += dayData.completedTasks;
      }
    }
    
    return CalendarDayData(
      date: month,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      hasWork: totalTasks > 0,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear - 1) / 7).floor() + 1;
  }
}