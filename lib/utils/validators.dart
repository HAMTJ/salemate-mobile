class Validators {
  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกชื่อผู้ใช้';
    }
    if (value.length < 3) {
      return 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร';
    }
    if (!RegExp(r'^[a-zA-Z0-9._@]+$').hasMatch(value)) {
      return 'ชื่อผู้ใช้ใช้ได้เฉพาะ A-Z, a-z, 0-9, ., _, @';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#_\-!*])[A-Za-z\d@#_\-!*]{8,}$',
    ).hasMatch(value)) {
      return 'รหัสผ่านต้องมีตัวพิมพ์เล็ก, ใหญ่, ตัวเลข และอักขระพิเศษ (@#_-!*) อย่างน้อย 8 ตัว';
    }
    return null;
  }

  // Email validation (สำหรับใช้ในอนาคต)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    return null;
  }

  // Phone validation (สำหรับใช้ในอนาคต)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกเบอร์โทรศัพท์';
    }
    // Thai phone number format
    if (!RegExp(r'^[0][0-9]{9}$').hasMatch(value)) {
      return 'เบอร์โทรศัพท์ไม่ถูกต้อง (0XXXXXXXXX)';
    }
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    if (value.length < minLength) {
      return '$fieldNameต้องมีอย่างน้อย $minLength ตัวอักษร';
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    if (value.length > maxLength) {
      return '$fieldNameต้องไม่เกิน $maxLength ตัวอักษร';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก${fieldName ?? 'ตัวเลข'}';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลข';
    }
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกราคา';
    }
    if (!RegExp(r'^\d+\.?\d{0,2}$').hasMatch(value)) {
      return 'รูปแบบราคาไม่ถูกต้อง';
    }
    return null;
  }
}