import 'package:latlong2/latlong.dart';

class RouteInfoEntity {
  final List<LatLng> polylinePoints;
  final double distanceKm;
  final int durationMinutes;

  const RouteInfoEntity({
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMinutes,
  });

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} كم';
  String get formattedDuration => '$durationMinutes دقيقة';
}
