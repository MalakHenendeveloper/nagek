import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomFlutterMap extends StatelessWidget {
  final MapController? mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final LatLng? selectedMarkerPosition;
  final LatLng? originPosition;
  final LatLng? destinationPosition;
  final List<LatLng> polylinePoints;
  final void Function(LatLng position)? onTap;

  const CustomFlutterMap({
    super.key,
    this.mapController,
    required this.initialCenter,
    this.initialZoom = 14.0,
    this.selectedMarkerPosition,
    this.originPosition,
    this.destinationPosition,
    this.polylinePoints = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        onTap: (tapPosition, point) {
          if (onTap != null) {
            onTap!(point);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.nagek.app',
        ),

        // Polyline layer for navigation routes
        if (polylinePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                strokeWidth: 5.0,
                color: const Color(0xFF1E88E5), // Premium vibrant primary blue
                borderStrokeWidth: 2.0,
                borderColor: const Color(0xFF0D47A1),
              ),
            ],
          ),

        // Markers layer
        MarkerLayer(
          markers: [
            // Single picker marker
            if (selectedMarkerPosition != null)
              Marker(
                point: selectedMarkerPosition!,
                width: 45,
                height: 45,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 45,
                ),
              ),

            // Origin marker (Delegate)
            if (originPosition != null)
              Marker(
                point: originPosition!,
                width: 48,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

            // Destination marker (Client or Maintenance Center)
            if (destinationPosition != null)
              Marker(
                point: destinationPosition!,
                width: 48,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
