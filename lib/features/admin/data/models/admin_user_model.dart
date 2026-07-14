import '../../domain/entities/admin_user_entity.dart';

class AdminUserAddressModel {
  final String id;
  final String label;
  final String address;
  final String city;
  final double lat;
  final double lng;

  AdminUserAddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
  });

  factory AdminUserAddressModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>? ?? {};
    return AdminUserAddressModel(
      id: json['_id'] ?? '',
      label: json['label'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      lat: (coordinates['lat'] ?? 0.0).toDouble(),
      lng: (coordinates['lng'] ?? 0.0).toDouble(),
    );
  }

  AdminUserAddressEntity toEntity() {
    return AdminUserAddressEntity(
      id: id,
      label: label,
      address: address,
      city: city,
      lat: lat,
      lng: lng,
    );
  }
}

class AdminUserModel {
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
  final List<AdminUserAddressModel> addresses;

  AdminUserModel({
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

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final addressesList = json['addresses'] as List<dynamic>? ?? [];
    return AdminUserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      addresses: addressesList.map((e) => AdminUserAddressModel.fromJson(e)).toList(),
    );
  }

  AdminUserEntity toEntity() {
    return AdminUserEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
      role: role,
      isActive: isActive,
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      addresses: addresses.map((e) => e.toEntity()).toList(),
    );
  }
}
