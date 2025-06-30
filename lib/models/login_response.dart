import 'employee_data.dart';

class LoginResponse {
  final bool success;
  final String? message;
  final EmployeeData? data;
  final String? loginErrorCode;
  final int? statusCode;

  LoginResponse({
    required this.success,
    this.message,
    this.data,
    this.loginErrorCode,
    this.statusCode,
  });

  factory LoginResponse.fromApiResponse(Map<String, dynamic> json) {
    // Debug logs
    print('=== LOGIN RESPONSE DEBUG ===');
    print('status: ${json['status']}');
    print('data exists: ${json['data'] != null}');
    print('data is List: ${json['data'] is List}');
    if (json['data'] != null && json['data'] is List) {
      print('data length: ${(json['data'] as List).length}');
      if ((json['data'] as List).isNotEmpty) {
        print('statusLogin: ${json['data'][0]['statusLogin']}');
        print('loginErrorCode: ${json['data'][0]['loginErrorCode']}');
      }
    }
    
    // Check if login was successful
    final isSuccess = json['status'] == 'success' && 
                     json['data'] != null && 
                     (json['data'] as List).isNotEmpty &&
                     json['data'][0]['statusLogin'] == 'Success';
    
    print('isSuccess result: $isSuccess');
    print('==========================');
    
    return LoginResponse(
      success: isSuccess,
      message: json['message'],
      statusCode: json['statuscode'],
      loginErrorCode: json['data'] != null && (json['data'] as List).isNotEmpty
          ? json['data'][0]['loginErrorCode']
          : null,
      data: isSuccess
          ? EmployeeData.fromJson(json['data'][0])
          : null,
    );
  }
}