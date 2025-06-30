import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// App Colors
class AppColors {
  static const Color primaryBackground = Color(0xFF1e1e2c);
  static const Color glassWhite = Colors.white;
  static const Color textDark = Colors.black87;
  static const Color textLight = Colors.white;
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  
  // Gradient colors
  static const List<Color> backgroundGradientColors = [
    Color(0xFFFEFEFE),
    Color(0xFFF3F4F6),
    Color.fromARGB(255, 231, 188, 255),
  ];
}

// App Gradients
class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.backgroundGradientColors,
    stops: [0.0, 0.8, 1.0],
  );
}

// Input Decorations
class AppInputDecorations {
  static InputDecoration textFieldDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      prefixIcon: Icon(prefixIcon, color: Colors.grey[700]),
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      errorStyle: const TextStyle(
        fontSize: 11,
        height: 0.8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}

// Button Styles
class AppButtonStyles {
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    shadowColor: Colors.white.withOpacity(0.3),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.grey.shade300),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
  );

  static final ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

// Text Styles
class AppTextStyles {
  static TextStyle logoStyle = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    letterSpacing: 1.8,
  );

  static TextStyle buttonTextStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 1.1,
    color: Colors.black87,
  );

  static const TextStyle dashboardTitle = TextStyle(
    color: Colors.white,
    fontSize: 24,
  );

  static TextStyle dashboardSubtitle = TextStyle(
    color: Colors.grey[400],
    fontSize: 16,
  );

  static TextStyle errorTextStyle = TextStyle(
    color: Colors.red.shade700,
    fontSize: 13,
  );

  static TextStyle hintTextStyle = TextStyle(
    fontSize: 11,
    color: Colors.grey[600],
    fontStyle: FontStyle.italic,
  );
}

// Spacing
class AppSpacing {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

// Animation Durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration normal = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration verySlow = Duration(seconds: 2);
}