class EmployeeData {
  final String? statusLogin;
  final String? loginErrorCode;
  final int? employeeID;
  final String? employeeCode;
  final String? employeeCodeCustomer;
  final String? fullName;
  final int? departmentID;
  final String? departmentName;
  final int? roleID;
  final String? roleName;
  final String? employeeTypeCode;
  final String? employeeTypeName;
  final int? employeeTypeId;
  final int? employeeStatus;
  final String? personalId;
  final String? profilePicture;
  final int? isSupervisor;
  final String? udidNumber;

  EmployeeData({
    this.statusLogin,
    this.loginErrorCode,
    this.employeeID,
    this.employeeCode,
    this.employeeCodeCustomer,
    this.fullName,
    this.departmentID,
    this.departmentName,
    this.roleID,
    this.roleName,
    this.employeeTypeCode,
    this.employeeTypeName,
    this.employeeTypeId,
    this.employeeStatus,
    this.personalId,
    this.profilePicture,
    this.isSupervisor,
    this.udidNumber,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      statusLogin: json['statusLogin'],
      loginErrorCode: json['loginErrorCode'],
      employeeID: json['employeeID'],
      employeeCode: json['employeeCode'],
      employeeCodeCustomer: json['employeeCodeCustomer'],
      fullName: json['fullName'],
      departmentID: json['departmentID'],
      departmentName: json['departmentName'],
      roleID: json['roleID'],
      roleName: json['roleName'],
      employeeTypeCode: json['employeeTypeCode'],
      employeeTypeName: json['employeeTypeName'],
      employeeTypeId: json['employeeTypeId'],
      employeeStatus: json['employeeStatus'],
      personalId: json['personalId'],
      profilePicture: json['profilePicture'],
      isSupervisor: json['isSupervisor'],
      udidNumber: json['udidNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusLogin': statusLogin,
      'loginErrorCode': loginErrorCode,
      'employeeID': employeeID,
      'employeeCode': employeeCode,
      'employeeCodeCustomer': employeeCodeCustomer,
      'fullName': fullName,
      'departmentID': departmentID,
      'departmentName': departmentName,
      'roleID': roleID,
      'roleName': roleName,
      'employeeTypeCode': employeeTypeCode,
      'employeeTypeName': employeeTypeName,
      'employeeTypeId': employeeTypeId,
      'employeeStatus': employeeStatus,
      'personalId': personalId,
      'profilePicture': profilePicture,
      'isSupervisor': isSupervisor,
      'udidNumber': udidNumber,
    };
  }

  // Helper
  bool get isActive => employeeStatus == 1;
  bool get isAdmin => roleID == 1;
}
