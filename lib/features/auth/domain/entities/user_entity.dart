class UserEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String accessToken;
  final String refreshToken;

  UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.accessToken,
    required this.refreshToken,
  });
}
