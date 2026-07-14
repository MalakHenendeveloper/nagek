class AdminUserAddressEntity {
  final String id;
  final String label;
  final String address;
  final String city;
  final double lat;
  final double lng;

  AdminUserAddressEntity({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
  });
}

class AdminUserEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isActive;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final List<AdminUserAddressEntity> addresses;

  AdminUserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.addresses,
  });

  AdminUserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    bool? isActive,
    bool? isVerified,
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    List<AdminUserAddressEntity>? addresses,
  }) {
    return AdminUserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      addresses: addresses ?? this.addresses,
    );
  }
}

