class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;
  final int? statusCode;
  final String? loginErrorCode;

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  ApiResponse({
    required this.status,
    this.message,
    this.data,
    this.statusCode,
    this.loginErrorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] ?? '',
      message: json['message'],
      statusCode: json['statuscode'],
      loginErrorCode: json['loginErrorCode'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value)? toJsonT) => {
        'status': status,
        'message': message,
        'statuscode': statusCode,
        'loginErrorCode': loginErrorCode,
        'data': data != null && toJsonT != null ? toJsonT(data as T) : null,
      };
}