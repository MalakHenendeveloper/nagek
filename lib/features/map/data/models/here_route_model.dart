import 'package:latlong2/latlong.dart';
import '../../../../core/utils/polyline_decoder.dart';
import '../../domain/entities/route_info_entity.dart';

class HereRouteModel extends RouteInfoEntity {
  const HereRouteModel({
    required super.polylinePoints,
    required super.distanceKm,
    required super.durationMinutes,
  });

  factory HereRouteModel.fromHereJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      return const HereRouteModel(
        polylinePoints: [],
        distanceKm: 0.0,
        durationMinutes: 0,
      );
    }

    final sections = (routes.first as Map<String, dynamic>)['sections'] as List<dynamic>?;
    if (sections == null || sections.isEmpty) {
      return const HereRouteModel(
        polylinePoints: [],
        distanceKm: 0.0,
        durationMinutes: 0,
      );
    }

    final List<LatLng> allPoints = [];
    double totalDistanceMeters = 0;
    int totalDurationSeconds = 0;

    for (final section in sections) {
      final sectionMap = section as Map<String, dynamic>;
      final polylineStr = sectionMap['polyline'] as String?;
      if (polylineStr != null) {
        allPoints.addAll(PolylineDecoder.decodePolyline(polylineStr));
      }

      final summary = sectionMap['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        totalDistanceMeters += (summary['length'] as num?)?.toDouble() ?? 0.0;
        totalDurationSeconds += (summary['duration'] as num?)?.toInt() ?? 0;
      }
    }

    return HereRouteModel(
      polylinePoints: allPoints,
      distanceKm: totalDistanceMeters / 1000.0,
      durationMinutes: (totalDurationSeconds / 60).ceil(),
    );
  }
}
