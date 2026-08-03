import 'package:latlong2/latlong.dart';

class MapLocationEntity {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? district;

  const MapLocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.district,
  });

  LatLng get toLatLng => LatLng(latitude, longitude);
}
