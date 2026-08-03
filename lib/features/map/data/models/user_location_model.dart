import '../../domain/entities/map_location_entity.dart';

class UserLocationModel extends MapLocationEntity {
  const UserLocationModel({
    required super.latitude,
    required super.longitude,
    super.address,
    super.city,
    super.district,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      latitude: (json['lat'] ?? json['latitude'] as num).toDouble(),
      longitude: (json['lng'] ?? json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'district': district,
    };
  }
}
