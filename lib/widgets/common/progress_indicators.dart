// lib/widgets/common/progress_indicators.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskProgressIndicator extends StatefulWidget {
  final int completed;
  final int total;
  final Color? color;
  final bool showPercentage;
  final bool showCount;
  final double height;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final String? label;

  const TaskProgressIndicator({
    Key? key,
    required this.completed,
    required this.total,
    this.color,
    this.showPercentage = true,
    this.showCount = false,
    this.height = 8.0,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 800),
    this.label,
  }) : super(key: key);

  @override
  State<TaskProgressIndicator> createState() => _TaskProgressIndicatorState();
}

class _TaskProgressIndicatorState extends State<TaskProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getProgressValue(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: _getProgressColor(),
    ).animate(_animationController);
    
    _animationController.forward();
  }

  @override
  void didUpdateWidget(TaskProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.completed != widget.completed || 
        oldWidget.total != widget.total) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _getProgressValue(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value,
        end: _getProgressColor(),
      ).animate(_animationController);
      
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getProgressValue() {
    if (widget.total == 0) return 0.0;
    return (widget.completed / widget.total).clamp(0.0, 1.0);
  }

  Color _getProgressColor() {
    if (widget.color != null) return widget.color!;
    
    final progress = _getProgressValue();
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.lightGreen;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
        ],
        
        Row(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: widget.borderRadius ?? 
                          BorderRadius.circular(widget.height / 2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _colorAnimation.value,
                          borderRadius: widget.borderRadius ?? 
                              BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            if (widget.showPercentage || widget.showCount) ...[
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  final percentage = (_progressAnimation.value * 100).round();
                  
                  return Text(
                    widget.showCount 
                        ? '${widget.completed}/${widget.total}'
                        : '$percentage%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _colorAnimation.value,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class CircularTaskProgress extends StatefulWidget {
  final int completed;
  final int total;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;
  final Duration animationDuration;

  const CircularTaskProgress({
    Key? key,
    required this.completed,
    required this.total,
    this.size = 60.0,
    this.strokeWidth = 6.0,
    this.color,
    this.backgroundColor,
    this.showPercentage = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<CircularTaskProgress> createState() => _CircularTaskProgressState();
}

class _CircularTaskProgressState extends State<CircularTaskProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getProgressValue(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CircularTaskProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.completed != widget.completed || 
        oldWidget.total != widget.total) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _getProgressValue(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getProgressValue() {
    if (widget.total == 0) return 0.0;
    return (widget.completed / widget.total).clamp(0.0, 1.0);
  }

  Color _getProgressColor() {
    if (widget.color != null) return widget.color!;
    
    final progress = _getProgressValue();
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.lightGreen;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          final percentage = (_progressAnimation.value * 100).round();
          
          return Stack(
            children: [
              // Background circle
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: widget.strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.backgroundColor ?? Colors.grey.shade200,
                ),
              ),
              
              // Progress circle
              CircularProgressIndicator(
                value: _progressAnimation.value,
                strokeWidth: widget.strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              ),
              
              // Center text
              if (widget.showPercentage)
                Center(
                  child: Text(
                    '$percentage%',
                    style: GoogleFonts.inter(
                      fontSize: widget.size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class TaskProgressBar extends StatelessWidget {
  final List<TaskProgress> tasks;
  final double height;
  final bool showLabels;

  const TaskProgressBar({
    Key? key,
    required this.tasks,
    this.height = 12.0,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalTasks = tasks.fold<int>(0, (sum, task) => sum + task.total);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Row(
            children: tasks.map((task) {
              final widthFactor = totalTasks > 0 ? task.total / totalTasks : 0.0;
              
              return Expanded(
                flex: (widthFactor * 100).round(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    color: task.color,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        if (showLabels) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: tasks.map((task) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: task.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.label} (${task.completed}/${task.total})',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class TaskProgress {
  final String label;
  final int completed;
  final int total;
  final Color color;

  TaskProgress({
    required this.label,
    required this.completed,
    required this.total,
    required this.color,
  });
}

// Utility widget for showing completion status with icon
class CompletionStatusIndicator extends StatelessWidget {
  final int completed;
  final int total;
  final double iconSize;

  const CompletionStatusIndicator({
    Key? key,
    required this.completed,
    required this.total,
    this.iconSize = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    if (total == 0) {
      icon = Icons.remove_circle_outline;
      color = Colors.grey;
    } else if (completed >= total) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (completed > 0) {
      icon = Icons.schedule;
      color = Colors.orange;
    } else {
      icon = Icons.radio_button_unchecked;
      color = Colors.red;
    }
    
    return Icon(
      icon,
      size: iconSize,
      color: color,
    );
  }
}