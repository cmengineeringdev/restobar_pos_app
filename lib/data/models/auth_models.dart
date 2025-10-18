import '../../domain/entities/user.dart';

/// Login Request Model
class LoginRequest {
  final String username;
  final String password;
  final String companyCode;

  LoginRequest({
    required this.username,
    required this.password,
    required this.companyCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'companyCode': companyCode,
    };
  }
}

/// Login Response Model
class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Login Data Model
class LoginData {
  final String accessToken;
  final DateTime expiresAt;
  final String refreshToken;
  final String firstName;
  final String lastName;

  LoginData({
    required this.accessToken,
    required this.expiresAt,
    required this.refreshToken,
    required this.firstName,
    required this.lastName,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      refreshToken: json['refreshToken'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }

  /// Convert to User entity
  User toUser(String username, String companyCode, String userId) {
    return User(
      userId: userId,
      username: username,
      companyCode: companyCode,
      firstName: firstName,
      lastName: lastName,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }
}

/// User Model for storage
class UserModel extends User {
  UserModel({
    required super.userId,
    required super.username,
    required super.companyCode,
    required super.firstName,
    required super.lastName,
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.userId,
      username: user.username,
      companyCode: user.companyCode,
      firstName: user.firstName,
      lastName: user.lastName,
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
      expiresAt: user.expiresAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      companyCode: json['companyCode'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'companyCode': companyCode,
      'firstName': firstName,
      'lastName': lastName,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      userId: userId,
      username: username,
      companyCode: companyCode,
      firstName: firstName,
      lastName: lastName,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }
}
