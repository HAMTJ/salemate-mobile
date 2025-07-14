// lib/widgets/common/animated_transitions.dart

import 'package:flutter/material.dart';

// Slide page transition
class SlidePageTransition extends PageRouteBuilder {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;

  SlidePageTransition({
    required this.child,
    this.direction = SlideDirection.leftToRight,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      Offset end = Offset.zero;

      switch (direction) {
        case SlideDirection.leftToRight:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.rightToLeft:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.topToBottom:
          begin = const Offset(0.0, -1.0);
          break;
        case SlideDirection.bottomToTop:
          begin = const Offset(0.0, 1.0);
          break;
      }

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

enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

// Fade page transition
class FadePageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  final Curve curve;

  FadePageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: curve,
        ),
        child: child,
      );
    },
  );
}

// Scale page transition
class ScalePageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  ScalePageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: curve,
        ),
        alignment: alignment,
        child: child,
      );
    },
  );
}

// Fade and scale combined transition
class FadeScaleTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool animate;
  final VoidCallback? onAnimationComplete;

  const FadeScaleTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.animate = true,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<FadeScaleTransition> createState() => _FadeScaleTransitionState();
}

class _FadeScaleTransitionState extends State<FadeScaleTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    if (widget.animate) {
      _controller.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(FadeScaleTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    } else if (!widget.animate && oldWidget.animate) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Staggered list animation
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final Curve curve;
  final bool animate;

  const StaggeredListAnimation({
    Key? key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.animate = true,
  }) : super(key: key);

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  List<Animation<Offset>> _animations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers.clear();
    _animations.clear();

    for (int i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        duration: widget.itemDuration,
        vsync: this,
      );
      _controllers.add(controller);

      final animation = Tween<Offset>(
        begin: const Offset(0.0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
      _animations.add(animation);

      if (widget.animate) {
        Future.delayed(widget.itemDelay * i, () {
          if (mounted) {
            controller.forward();
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(StaggeredListAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        if (index >= _animations.length) return widget.children[index];
        
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return FadeTransition(
              opacity: _controllers[index],
              child: SlideTransition(
                position: _animations[index],
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

// Bounce animation widget
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool animate;

  const BounceAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.animate = true,
  }) : super(key: key);

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BounceAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward();
    } else if (!widget.animate && oldWidget.animate) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Rotation animation
class RotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool repeat;
  final double rotations;

  const RotationAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.repeat = true,
    this.rotations = 1.0,
  }) : super(key: key);

  @override
  State<RotationAnimation> createState() => _RotationAnimationState();
}

class _RotationAnimationState extends State<RotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.rotations,
    ).animate(_controller);

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: widget.child,
        );
      },
    );
  }
}

// Loading animation with dots
class LoadingDotsAnimation extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const LoadingDotsAnimation({
    Key? key,
    this.color = Colors.blue,
    this.size = 8.0,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<LoadingDotsAnimation> createState() => _LoadingDotsAnimationState();
}

class _LoadingDotsAnimationState extends State<LoadingDotsAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: widget.duration,
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.size * 0.25),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: 0.5 + (_animations[index].value * 0.5),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.5 + (_animations[index].value * 0.5)),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}