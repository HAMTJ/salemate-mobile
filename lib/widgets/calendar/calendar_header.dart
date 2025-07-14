// lib/widgets/calendar/calendar_header.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendar_models.dart';

class CalendarHeader extends StatefulWidget {
  final DateTime currentDate;
  final CalendarViewMode viewMode;
  final CalendarConfig config;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onTodayPressed;
  final ViewModeChangeCallback? onViewModeChanged;
  final bool showViewModeToggle;
  final bool showTodayButton;

  const CalendarHeader({
    Key? key,
    required this.currentDate,
    required this.viewMode,
    required this.config,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onTodayPressed,
    this.onViewModeChanged,
    this.showViewModeToggle = true,
    this.showTodayButton = true,
  }) : super(key: key);

  @override
  State<CalendarHeader> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateMonthChange() {
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * -20),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  _buildMainHeader(),
                  const SizedBox(height: 6),
                  _buildDaysOfWeekHeader(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isNarrowScreen = screenWidth < 350;
        
        return Row(
          children: [
            // Previous month button - ปรับขนาดตามหน้าจอ
            _buildNavigationButton(
              icon: Icons.chevron_left,
              onPressed: () {
                _animateMonthChange();
                widget.onPreviousMonth?.call();
              },
              compact: isNarrowScreen,
            ),
            
            const SizedBox(width: 8),
            
            // Month/Year display - ใช้ Expanded และปรับ padding
            Expanded(
              child: GestureDetector(
                onTap: widget.onTodayPressed,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isNarrowScreen ? 8 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Center(
                    child: Text(
                      _getHeaderTitle(),
                      style: GoogleFonts.inter(
                        fontSize: isNarrowScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Next month button
            _buildNavigationButton(
              icon: Icons.chevron_right,
              onPressed: () {
                _animateMonthChange();
                widget.onNextMonth?.call();
              },
              compact: isNarrowScreen,
            ),
            
            // Today button - แยกออกมาและปรับขนาด
            if (widget.showTodayButton) ...[
              const SizedBox(width: 6),
              _buildTodayButton(compact: isNarrowScreen),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool compact = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(compact ? 8 : 10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade700,
            size: compact ? 18 : 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayButton({bool compact = false}) {
    final isToday = ThaiCalendarUtils.isToday(widget.currentDate);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTodayPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 8,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isToday 
                ? Colors.green.shade100 
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isToday 
                  ? Colors.green.shade300 
                  : Colors.grey.shade300,
            ),
          ),
          child: compact 
              ? Icon(
                  isToday ? Icons.today : Icons.calendar_today,
                  size: 16,
                  color: isToday 
                      ? Colors.green.shade700 
                      : Colors.grey.shade600,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isToday ? Icons.today : Icons.calendar_today,
                      size: 14,
                      color: isToday 
                          ? Colors.green.shade700 
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'วันนี้',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday 
                            ? Colors.green.shade700 
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    if (widget.viewMode == CalendarViewMode.year) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ThaiCalendarUtils.thaiDayNames.map((day) {
          return Container(
            width: 40,
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (widget.viewMode) {
      case CalendarViewMode.week:
        return ThaiCalendarUtils.formatThaiMonthYear(widget.currentDate);
      case CalendarViewMode.month:
        return ThaiCalendarUtils.formatThaiMonthYear(widget.currentDate);
      case CalendarViewMode.year:
        return '${widget.currentDate.year + 543}';
    }
  }

  String _getSubtitle() {
    return ''; // 🔥 ลบคำว่า "มุมมองเดือน" ออก
  }
}