import '../../domain/entities/map_location_entity.dart';

class HereGeocodeModel extends MapLocationEntity {
  const HereGeocodeModel({
    required super.latitude,
    required super.longitude,
    super.address,
    super.city,
    super.district,
  });

  factory HereGeocodeModel.fromHereItemJson(Map<String, dynamic> item) {
    final position = item['position'] as Map<String, dynamic>? ?? {};
    final addressObj = item['address'] as Map<String, dynamic>? ?? {};

    final lat = (position['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (position['lng'] as num?)?.toDouble() ?? 0.0;
    final label = (addressObj['label'] as String?) ?? (item['title'] as String?) ?? '';
    final city = addressObj['city'] as String?;
    final district = addressObj['district'] as String? ?? addressObj['subdistrict'] as String?;

    return HereGeocodeModel(
      latitude: lat,
      longitude: lng,
      address: label,
      city: city,
      district: district,
    );
  }
}
