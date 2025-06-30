import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingCirclesBackground extends StatelessWidget {
  const FloatingCirclesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(6, (i) => _buildFloatingCircle(context, i)),
    );
  }

  Widget _buildFloatingCircle(BuildContext context, int index) {
    final random = math.Random(index);
    final size = 60.0 + random.nextDouble() * 80;
    
    // ใช้ MediaQuery เพื่อ responsive
    final screenSize = MediaQuery.of(context).size;
    final left = random.nextDouble() * screenSize.width;
    final top = random.nextDouble() * screenSize.height;

    final List<List<Color>> subtleGradients = [
      [const Color.fromARGB(255, 167, 217, 253), const Color.fromARGB(255, 229, 161, 240)],
      [const Color.fromARGB(255, 255, 189, 202), const Color.fromARGB(255, 174, 255, 174)],
      [const Color.fromARGB(255, 242, 161, 255), const Color.fromARGB(255, 178, 223, 255)],
      [const Color.fromARGB(255, 164, 255, 164), const Color.fromARGB(255, 255, 177, 193)],
    ];

    final gradientColors = subtleGradients[random.nextInt(subtleGradients.length)];

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              gradientColors[0].withOpacity(0.7),
              gradientColors[1].withOpacity(0.5)
            ],
            center: Alignment.center,
            radius: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}