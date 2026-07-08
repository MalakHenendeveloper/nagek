import '../../domain/entities/user_entity.dart';

class LoginResponseModel {
  final bool success;
  final String message;
  final LoginDataModel? data;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginDataModel.fromJson(json['data']) : null,
    );
  }
}

class LoginDataModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  LoginDataModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      user: UserModel.fromJson(json['user']),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: user.id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      role: user.role,
      isVerified: user.isVerified,
      isActive: user.isActive,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isVerified;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? false,
    );
  }
}
