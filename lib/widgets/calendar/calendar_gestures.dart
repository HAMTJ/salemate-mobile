// lib/widgets/calendar/calendar_gestures.dart

import 'package:flutter/material.dart';
import 'calendar_models.dart';

class CalendarGestureWrapper extends StatefulWidget {
  final Widget child;
  final CalendarConfig config;
  final CalendarViewMode currentViewMode;
  final Function(int)? onMonthChanged;
  final Function(CalendarViewMode)? onViewModeChanged;
  final VoidCallback? onRefreshRequested;

  const CalendarGestureWrapper({
    Key? key,
    required this.child,
    required this.config,
    required this.currentViewMode,
    this.onMonthChanged,
    this.onViewModeChanged,
    this.onRefreshRequested,
  }) : super(key: key);

  @override
  State<CalendarGestureWrapper> createState() => _CalendarGestureWrapperState();
}

class _CalendarGestureWrapperState extends State<CalendarGestureWrapper>
    with TickerProviderStateMixin {
  
  // Scale gesture variables
  double _initialScale = 1.0;
  double _currentScale = 1.0;
  bool _isScaling = false;
  
  // Swipe gesture variables
  bool _isHorizontalSwipe = false;
  double _swipeThreshold = 100.0;
  
  // Animation controllers
  late AnimationController _scaleAnimationController;
  late AnimationController _swipeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _swipeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeOut,
    ));
    
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget gestureChild = widget.child;

    // Add pull-to-refresh if enabled
    if (widget.onRefreshRequested != null) {
      gestureChild = RefreshIndicator(
        onRefresh: () async {
          widget.onRefreshRequested?.call();
          // Add delay for better UX
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: gestureChild,
      );
    }

    // Add scale gesture if pinch zoom is enabled
    if (widget.config.enablePinchZoom) {
      gestureChild = GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: gestureChild,
      );
    }

    // Add swipe gesture if enabled
    if (widget.config.enableSwipeGestures) {
      gestureChild = GestureDetector(
        onHorizontalDragStart: _handleHorizontalDragStart,
        onHorizontalDragUpdate: _handleHorizontalDragUpdate,
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: gestureChild,
      );
    }

    // Wrap with animations
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _swipeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: _swipeAnimation.value,
            child: gestureChild,
          ),
        );
      },
    );
  }

  // Scale gesture handlers
  void _handleScaleStart(ScaleStartDetails details) {
    if (!widget.config.enablePinchZoom) return;
    
    _initialScale = _currentScale;
    _isScaling = true;
    _scaleAnimationController.stop();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!widget.config.enablePinchZoom || !_isScaling) return;

    setState(() {
      _currentScale = (_initialScale * details.scale).clamp(0.5, 2.0);
    });

    // Update animation value
    _scaleAnimation = Tween<double>(
      begin: _scaleAnimation.value,
      end: _currentScale,
    ).animate(_scaleAnimationController);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (!widget.config.enablePinchZoom || !_isScaling) return;
    
    _isScaling = false;
    
    // Determine view mode based on scale
    CalendarViewMode newViewMode = widget.currentViewMode;
    
    if (_currentScale < 0.8) {
      newViewMode = CalendarViewMode.year;
      _currentScale = 0.7;
    } else if (_currentScale > 1.3) {
      newViewMode = CalendarViewMode.week;
      _currentScale = 1.2;
    } else {
      newViewMode = CalendarViewMode.month;
      _currentScale = 1.0;
    }

    // Animate to final scale
    _scaleAnimation = Tween<double>(
      begin: _scaleAnimation.value,
      end: _currentScale,
    ).animate(_scaleAnimationController);
    
    _scaleAnimationController.forward();

    // Notify view mode change
    if (newViewMode != widget.currentViewMode) {
      widget.onViewModeChanged?.call(newViewMode);
    }
  }

  // Swipe gesture handlers
  void _handleHorizontalDragStart(DragStartDetails details) {
    if (!widget.config.enableSwipeGestures) return;
    
    _isHorizontalSwipe = true;
    _swipeAnimationController.stop();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.config.enableSwipeGestures || !_isHorizontalSwipe) return;

    // Update swipe animation
    final screenWidth = MediaQuery.of(context).size.width;
    final progress = (details.primaryDelta ?? 0) / screenWidth;
    
    _swipeAnimation = Tween<Offset>(
      begin: _swipeAnimation.value,
      end: Offset(progress, 0),
    ).animate(_swipeAnimationController);
    
    setState(() {});
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!widget.config.enableSwipeGestures || !_isHorizontalSwipe) return;
    
    _isHorizontalSwipe = false;
    
    final velocity = details.primaryVelocity ?? 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final currentOffset = _swipeAnimation.value.dx * screenWidth;
    
    // Determine if swipe is significant enough
    bool shouldChangePage = false;
    int direction = 0; // -1 for previous, 1 for next
    
    if (velocity.abs() > 500) {
      // Fast swipe
      shouldChangePage = true;
      direction = velocity > 0 ? -1 : 1;
    } else if (currentOffset.abs() > _swipeThreshold) {
      // Slow but far swipe
      shouldChangePage = true;
      direction = currentOffset > 0 ? -1 : 1;
    }

    if (shouldChangePage) {
      // Animate out
      _swipeAnimation = Tween<Offset>(
        begin: _swipeAnimation.value,
        end: Offset(direction * 1.5, 0),
      ).animate(_swipeAnimationController);
      
      _swipeAnimationController.forward().then((_) {
        // Change month/page
        widget.onMonthChanged?.call(direction);
        
        // Reset position
        _swipeAnimation = Tween<Offset>(
          begin: Offset(-direction * 1.5, 0),
          end: Offset.zero,
        ).animate(_swipeAnimationController);
        
        _swipeAnimationController.forward();
      });
    } else {
      // Snap back to center
      _swipeAnimation = Tween<Offset>(
        begin: _swipeAnimation.value,
        end: Offset.zero,
      ).animate(_swipeAnimationController);
      
      _swipeAnimationController.forward();
    }
  }
}

// Helper widget for smooth page transitions
class CalendarPageTransition extends PageRouteBuilder {
  final Widget child;
  final SlideDirection direction;

  CalendarPageTransition({
    required this.child,
    this.direction = SlideDirection.left,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      switch (direction) {
        case SlideDirection.left:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.right:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.up:
          begin = const Offset(0.0, 1.0);
          break;
        case SlideDirection.down:
          begin = const Offset(0.0, -1.0);
          break;
      }

      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end);
      var curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );

      return SlideTransition(
        position: tween.animate(curvedAnimation),
        child: child,
      );
    },
  );
}

enum SlideDirection { left, right, up, down }

// Gesture feedback helper
class GestureFeedback {
  static void lightImpact() {
    // HapticFeedback.lightImpact(); // Uncomment if haptic feedback is needed
  }

  static void mediumImpact() {
    // HapticFeedback.mediumImpact(); // Uncomment if haptic feedback is needed
  }

  static void heavyImpact() {
    // HapticFeedback.heavyImpact(); // Uncomment if haptic feedback is needed
  }

  static void selectionClick() {
    // HapticFeedback.selectionClick(); // Uncomment if haptic feedback is needed
  }
}