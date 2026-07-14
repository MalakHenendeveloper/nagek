class AdminCenterOwnerEntity {
  final String id;
  final String name;
  final String phone;
  final String email;

  AdminCenterOwnerEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });
}

class AdminCenterEntity {
  final String id;
  final String name;
  final AdminCenterOwnerEntity? owner;
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

  AdminCenterEntity({
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

  AdminCenterEntity copyWith({
    String? id,
    String? name,
    AdminCenterOwnerEntity? owner,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? logo,
    String? status,
    List<String>? supportedBrands,
    List<String>? supportedDeviceTypes,
    double? inspectionFee,
    double? rating,
    int? totalRatings,
    String? createdAt,
  }) {
    return AdminCenterEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      logo: logo ?? this.logo,
      status: status ?? this.status,
      supportedBrands: supportedBrands ?? this.supportedBrands,
      supportedDeviceTypes: supportedDeviceTypes ?? this.supportedDeviceTypes,
      inspectionFee: inspectionFee ?? this.inspectionFee,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
