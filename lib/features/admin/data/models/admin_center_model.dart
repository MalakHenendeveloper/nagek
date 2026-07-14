import '../../domain/entities/admin_center_entity.dart';

class AdminCenterOwnerModel {
  final String id;
  final String name;
  final String phone;
  final String email;

  AdminCenterOwnerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory AdminCenterOwnerModel.fromJson(Map<String, dynamic> json) {
    return AdminCenterOwnerModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  AdminCenterOwnerEntity toEntity() {
    return AdminCenterOwnerEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
    );
  }
}

class AdminCenterModel {
  final String id;
  final String name;
  final AdminCenterOwnerModel? owner;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String logo;
  final String status;
  final List<String> supportedBrands;
  final List<String> supportedDeviceTypes;
  final double inspectionFee;
  final double rating;
  final int totalRatings;
  final String createdAt;

  AdminCenterModel({
    required this.id,
    required this.name,
    this.owner,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.logo,
    required this.status,
    required this.supportedBrands,
    required this.supportedDeviceTypes,
    required this.inspectionFee,
    required this.rating,
    required this.totalRatings,
    required this.createdAt,
  });

  factory AdminCenterModel.fromJson(Map<String, dynamic> json) {
    return AdminCenterModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      owner: json['owner'] != null
          ? (json['owner'] is Map<String, dynamic>
              ? AdminCenterOwnerModel.fromJson(json['owner'] as Map<String, dynamic>)
              : AdminCenterOwnerModel(
                  id: json['owner'].toString(),
                  name: '',
                  phone: '',
                  email: '',
                ))
          : null,
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      logo: json['logo'] ?? '',
      status: json['status'] ?? 'active',
      supportedBrands: List<String>.from(json['supportedBrands'] ?? []),
      supportedDeviceTypes: List<String>.from(json['supportedDeviceTypes'] ?? []),
      inspectionFee: (json['inspectionFee'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }

  AdminCenterEntity toEntity() {
    return AdminCenterEntity(
      id: id,
      name: name,
      owner: owner?.toEntity(),
      phone: phone,
      email: email,
      address: address,
      city: city,
      logo: logo,
      status: status,
      supportedBrands: supportedBrands,
      supportedDeviceTypes: supportedDeviceTypes,
      inspectionFee: inspectionFee,
      rating: rating,
      totalRatings: totalRatings,
      createdAt: createdAt,
    );
  }
}
