import '../../domain/entities/profile_entity.dart';

class ProfileResponseModel {
  final bool success;
  final String message;
  final ProfileDataModel? data;

  ProfileResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProfileDataModel.fromJson(json['data'])
          : null,
    );
  }
}

class ProfileDataModel {
  final ProfileUserModel user;

  ProfileDataModel({required this.user});

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      user: ProfileUserModel.fromJson(json['user']),
    );
  }

  ProfileUserEntity toEntity() {
    return ProfileUserEntity(
      id: user.id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      isVerified: user.isVerified,
      addresses: user.addresses.map((a) => a.toEntity()).toList(),
      createdAt: user.createdAt,
    );
  }
}

class ProfileUserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isActive;
  final bool isVerified;
  final List<AddressModel> addresses;
  final String createdAt;

  ProfileUserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.addresses,
    required this.createdAt,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class AddressModel {
  final String id;
  final String label;
  final String address;
  final String city;
  final double lat;
  final double lng;

  AddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>? ?? {};
    return AddressModel(
      id: json['_id'] ?? '',
      label: json['label'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      lat: (coordinates['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (coordinates['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      label: label,
      address: address,
      city: city,
      lat: lat,
      lng: lng,
    );
  }
}
