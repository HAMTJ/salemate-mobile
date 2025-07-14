// lib/widgets/common/floating_quick_actions.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingQuickActions extends StatefulWidget {
  final VoidCallback? onTodayPressed;
  final VoidCallback? onRefreshPressed;
  final VoidCallback? onVoiceCommand;
  final VoidCallback? onCalendarMode;
  final VoidCallback? onSettings;
  final bool isExpanded;
  final Color? primaryColor;

  const FloatingQuickActions({
    Key? key,
    this.onTodayPressed,
    this.onRefreshPressed,
    this.onVoiceCommand,
    this.onCalendarMode,
    this.onSettings,
    this.isExpanded = false,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<FloatingQuickActions> createState() => _FloatingQuickActionsState();
}

class _FloatingQuickActionsState extends State<FloatingQuickActions>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.75, // 3/4 rotation
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _isExpanded = widget.isExpanded;
    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? Colors.orange.shade600;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick action buttons (shown when expanded)
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Today button
                _buildQuickActionButton(
                  icon: Icons.today,
                  label: 'วันนี้',
                  onPressed: widget.onTodayPressed,
                  color: Colors.green.shade600,
                  delay: 0,
                ),
                
                const SizedBox(height: 12),
                
                // Refresh button
                _buildQuickActionButton(
                  icon: Icons.refresh,
                  label: 'รีเฟรช',
                  onPressed: widget.onRefreshPressed,
                  color: Colors.blue.shade600,
                  delay: 50,
                ),
                
                const SizedBox(height: 12),
                
                // Calendar mode button
                _buildQuickActionButton(
                  icon: Icons.calendar_view_month,
                  label: 'เปลี่ยนมุมมอง',
                  onPressed: widget.onCalendarMode,
                  color: Colors.purple.shade600,
                  delay: 100,
                ),
                
                const SizedBox(height: 12),
                
                // Voice command button (if enabled)
                if (widget.onVoiceCommand != null) ...[
                  _buildQuickActionButton(
                    icon: Icons.mic,
                    label: 'คำสั่งเสียง',
                    onPressed: widget.onVoiceCommand,
                    color: Colors.red.shade600,
                    delay: 150,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Settings button
                _buildQuickActionButton(
                  icon: Icons.settings,
                  label: 'ตั้งค่า',
                  onPressed: widget.onSettings,
                  color: Colors.grey.shade600,
                  delay: 200,
                ),
                
                const SizedBox(height: 16),
              ],
            );
          },
        ),
        
        // Main FAB
        AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return FloatingActionButton(
              onPressed: _toggleExpanded,
              backgroundColor: primaryColor,
              child: Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.14159,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.add,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final delayedAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay / 300.0, // Convert delay to percentage
            1.0,
            curve: Curves.easeOut,
          ),
        ));
        
        return Transform.scale(
          scale: delayedAnimation.value,
          child: Opacity(
            opacity: delayedAnimation.value,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    
                    // Tooltip label
                    Positioned(
                      right: 64,
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Alternative simpler floating action button for basic use
class SimpleFloatingActions extends StatelessWidget {
  final VoidCallback? onTodayPressed;
  final VoidCallback? onRefreshPressed;
  final Color? primaryColor;

  const SimpleFloatingActions({
    Key? key,
    this.onTodayPressed,
    this.onRefreshPressed,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = this.primaryColor ?? Colors.orange.shade600;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Today button
        if (onTodayPressed != null) ...[
          FloatingActionButton.small(
            onPressed: onTodayPressed,
            backgroundColor: Colors.green.shade600,
            heroTag: "today",
            child: Icon(
              Icons.today,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Refresh button
        FloatingActionButton(
          onPressed: onRefreshPressed,
          backgroundColor: primaryColor,
          heroTag: "refresh",
          child: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Utility for showing quick action tooltip
class QuickActionTooltip extends StatelessWidget {
  final String text;
  final Widget child;
  final Color? backgroundColor;

  const QuickActionTooltip({
    Key? key,
    required this.text,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white,
      ),
      child: child,
    );
  }
}