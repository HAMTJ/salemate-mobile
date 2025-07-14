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
              widget.onTap?.call();
            },
            onDoubleTap: widget.onDoubleTap,
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
              fontSize: 16, // 🔥 เพิ่มขนาดจาก 14 เป็น 16
              fontWeight: widget.isToday ? FontWeight.bold : FontWeight.w600, // 🔥 เพิ่ม weight
              color: _getTextColor(dayData),
            ),
          ),
        ),

        // Task indicators - ลดขนาดลง
        if (dayData != null && dayData.hasWork) ...[
          // Progress indicator (top right) - ทำให้เล็กลง
          if (dayData.totalTasks > 0)
            Positioned(
              top: 1, // 🔥 ลดจาก 2 เป็น 1
              right: 1, // 🔥 ลดจาก 2 เป็น 1
              child: _buildProgressIndicator(dayData),
            ),

          // Personal note indicator (bottom left) - ทำให้เล็กลง
          if (dayData.personalNote != null && dayData.personalNote!.isNotEmpty)
            Positioned(
              bottom: 1, // 🔥 ลดจาก 2 เป็น 1
              left: 1, // 🔥 ลดจาก 2 เป็น 1
              child: Container(
                width: 4, // 🔥 ลดจาก 6 เป็น 4
                height: 4, // 🔥 ลดจาก 6 เป็น 4
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // Highlight indicator (bottom right) - ทำให้เล็กลง
          if (dayData.highlights.isNotEmpty)
            Positioned(
              bottom: 1, // 🔥 ลดจาก 2 เป็น 1
              right: 1, // 🔥 ลดจาก 2 เป็น 1
              child: Container(
                width: 4, // 🔥 ลดจาก 6 เป็น 4
                height: 4, // 🔥 ลดจาก 6 เป็น 4
                decoration: BoxDecoration(
                  color: Colors.purple.shade600,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator(CalendarDayData dayData) {
    final completionRate = dayData.completionRate;
    
    // For small cells, show smaller colored dot
    if ((widget.size ?? 40) < 50) {
      return Container(
        width: 6, // 🔥 ลดจาก 8 เป็น 6
        height: 6, // 🔥 ลดจาก 8 เป็น 6
        decoration: BoxDecoration(
          color: dayData.getStatusColor(),
          shape: BoxShape.circle,
        ),
      );
    }

    // For larger cells, show mini progress bar
    return Container(
      width: 10, // 🔥 ลดจาก 12 เป็น 10
      height: 2, // 🔥 ลดจาก 3 เป็น 2
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: completionRate / 100,
        child: Container(
          decoration: BoxDecoration(
            color: dayData.getStatusColor(),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(CalendarDayData? dayData) {
    if (widget.isToday) {
      return Colors.white;
    }
    
    if (!widget.isCurrentMonth) {
      return Colors.grey.shade400;
    }

    // 🔥 ปรับปรุงการเลือกสี - ให้เห็นเลขชัดเจนขึ้น
    return Colors.black87; // ใช้สีเดียวเพื่อให้เห็นชัดเจน
  }
}