class LoginRequest {
  final String username;
  final String password;
  final String changeSource;
  final String deviceInfo;
  final String deviceToken;

  LoginRequest({
    required this.username,
    required this.password,
    required this.changeSource,
    required this.deviceInfo,
    required this.deviceToken,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'changesource': changeSource,
      'deviceinfo': deviceInfo,
      'devicetoken': deviceToken,
    };
  }

  // Create from Map (useful for testing)
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      changeSource: json['changesource'] ?? '',
      deviceInfo: json['deviceinfo'] ?? '',
      deviceToken: json['devicetoken'] ?? '',
    );
  }

  @override
  String toString() {
    return 'LoginRequest(username: $username, changesource: $changeSource, deviceinfo: $deviceInfo, devicetoken: $deviceToken)';
  }
}