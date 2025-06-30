import 'employee_data.dart';

class User {
  final int? userId;
  final String? username;
  final String? email;
  final String? fullName;
  final String? role;
  final int? roleId;
  final String? department;
  final String? position;
  final bool isActive;

  User({
    this.userId,
    this.username,
    this.email,
    this.fullName,
    this.role,
    this.roleId,
    this.department,
    this.position,
    this.isActive = true,
  });

  // Create User from EmployeeData
  factory User.fromEmployee(EmployeeData employee) {
    return User(
      userId: employee.employeeID,
      username: employee.employeeCode,
      email: null, // ไม่มี email ใน JSON ปัจจุบัน
      fullName: employee.fullName,
      role: employee.roleName,
      roleId: employee.roleID,
      department: employee.departmentName,
      position: null, // ไม่มีข้อมูลตำแหน่งใน JSON ปัจจุบัน
      isActive: employee.employeeStatus == 1,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? json['employeeID'],
      username: json['username'] ?? json['employeeCode'],
      email: json['email'],
      fullName: json['fullName'] ?? json['employeeName'],
      role: json['role'] ?? json['roleName'],
      roleId: json['roleId'] ?? json['roleID'],
      department: json['department'] ?? json['departmentName'],
      position: json['position'] ?? json['positionName'],
      isActive: json['isActive'] ?? (json['employeeStatus'] == 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'role': role,
      'roleId': roleId,
      'department': department,
      'position': position,
      'isActive': isActive,
    };
  }

  bool hasPermission(String permission) {
    // Implement based on roleId or other logic
    if (roleId == 1) return true; // Admin has all permissions
    return false;
  }
  
  bool get isAdmin => roleId == 1;
}
