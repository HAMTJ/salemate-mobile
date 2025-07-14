// lib/widgets/calendar/calendar_day_cell.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendar_models.dart';

class CalendarDayCell extends StatefulWidget {
  final DateTime? date;
  final CalendarDayData? dayData;
  final bool isToday;
  final bool isSelected;
  final bool isCurrentMonth;
  final CalendarConfig config;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final double? size;

  const CalendarDayCell({
    Key? key,
    this.date,
    this.dayData,
    this.isToday = false,
    this.isSelected = false,
    this.isCurrentMonth = true,
    required this.config,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.size,
  }) : super(key: key);

  @override
  State<CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<CalendarDayCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.date == null) {
      return SizedBox(
        width: widget.size ?? 40,
        height: widget.size ?? 40,
      );
    }

    final date = widget.date!;
    final dayData = widget.dayData;
    final cellSize = widget.size ?? 40.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _handleTapDown(),
            onTapUp: (_) => _handleTapUp(),
            onTapCancel: _handleTapCancel,
            onTap: () {
              _handleTapUp();
              // 🔥 ลบ widget.onTap?.call(); ออก - ไม่ให้ single tap ทำอะไร
            },
            onDoubleTap: () {
              // 🔥 เฉพาะ double tap เท่านั้นที่จะทำงาน
              widget.onDoubleTap?.call();
            },
            onLongPress: () {
              // Add haptic feedback for long press
              if (widget.config.enablePersonalNotes) {
                // HapticFeedback.mediumImpact(); // Uncomment if needed
                widget.onLongPress?.call();
              }
            },
            child: Container(
              width: cellSize,
              height: cellSize,
              margin: const EdgeInsets.all(1),
              decoration: _buildCellDecoration(dayData),
              child: _buildCellContent(date, dayData),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildCellDecoration(CalendarDayData? dayData) {
    Color backgroundColor = Colors.transparent;
    Color? borderColor;
    double borderWidth = 0;

    // Today styling
    if (widget.isToday) {
      backgroundColor = widget.config.todayColor;
      borderColor = widget.config.todayColor.withOpacity(0.3);
      borderWidth = 2;
    }
    // Selected styling
    else if (widget.isSelected) {
      backgroundColor = widget.config.primaryColor.withOpacity(0.2);
      borderColor = widget.config.primaryColor;
      borderWidth = 2;
    }
    // Heat map styling
    else if (widget.config.enableHeatMap && dayData != null && dayData.hasWork) {
      final intensity = dayData.heatMapIntensity;
      backgroundColor = dayData.getStatusColor().withOpacity(intensity * 0.3);
    }

    // Dim if not current month
    if (!widget.isCurrentMonth) {
      backgroundColor = backgroundColor.withOpacity(0.3);
    }

    return BoxDecoration(
      color: backgroundColor,
      border: borderColor != null 
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildCellContent(DateTime date, CalendarDayData? dayData) {
    return Stack(
      children: [
        // Main day number
        Center(
          child: Text(
            '${date.day}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: widget.isToday ? FontWeight.bold : FontWeight.w600,
              color: _getTextColor(dayData),
            ),
          ),
        ),

        // 🔥 แสดงเฉพาะจุดสถานะงานหลักที่สวยขึ้น
        if (dayData != null && dayData.hasWork) ...[
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: getImprovedStatusColor(dayData),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: getImprovedStatusColor(dayData).withOpacity(0.4),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        // Personal note indicator - ย้ายมาข้างล่าง
        if (dayData != null && dayData.personalNote != null && dayData.personalNote!.isNotEmpty)
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Color getImprovedStatusColor(CalendarDayData dayData) {
    if (!dayData.hasWork) return Colors.grey.shade400;
    
    final completionRate = dayData.completionRate;
    
    if (completionRate >= 100) {
      return Colors.green.shade500; // ✅ เสร็จสิ้น
    } else if (completionRate >= 50) {
      return Colors.amber.shade500; // 🔄 กำลังดำเนินการ (มากกว่าครึ่ง)
    } else if (completionRate > 0) {
      return Colors.orange.shade500; // 🟠 เริ่มแล้ว (น้อยกว่าครึ่ง)
    } else {
      return Colors.red.shade400; // ❌ ยังไม่เริ่ม
    }
  }

  Color _getTextColor(CalendarDayData? dayData) {
    if (widget.isToday) {
      return Colors.white;
    }
    
    if (!widget.isCurrentMonth) {
      return Colors.grey.shade400;
    }

    return Colors.black87;
  }
}