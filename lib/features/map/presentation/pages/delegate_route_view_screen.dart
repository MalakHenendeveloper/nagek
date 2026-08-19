import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/di.dart';
import '../../domain/entities/route_info_entity.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/custom_flutter_map.dart';
import '../widgets/route_info_card.dart';

class DelegateRouteViewScreen extends StatefulWidget {
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final String destinationTitle;
  final String? destinationAddress;

  const DelegateRouteViewScreen({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.destinationTitle,
    this.destinationAddress,
  });

  @override
  State<DelegateRouteViewScreen> createState() => _DelegateRouteViewScreenState();
}

class _DelegateRouteViewScreenState extends State<DelegateRouteViewScreen>
    with WidgetsBindingObserver {
  late final MapCubit _mapCubit;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapCubit = getIt<MapCubit>();
    _mapController = MapController();

    // Initial fetch for delegate route (will auto-start 5-min polling if duration > 10 mins)
    _mapCubit.fetchRoute(
      originLat: widget.originLat,
      originLng: widget.originLng,
      destLat: widget.destLat,
      destLng: widget.destLng,
      destAddress: widget.destinationTitle,
    );
  }

  void _fitRouteBounds(LatLng origin, LatLng dest, List<LatLng> polyline) {
    try {
      final points = polyline.isNotEmpty ? polyline : [origin, dest];
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.only(top: 80, bottom: 210, left: 50, right: 50),
          maxZoom: 16.0,
        ),
      );
    } catch (_) {}
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom + 1.0).clamp(3.0, 18.0));
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom - 1.0).clamp(3.0, 18.0));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _mapCubit.pausePeriodicPolling();
    } else if (state == AppLifecycleState.resumed) {
      if (_mapCubit.state is MapRouteLoaded) {
        final loadedState = _mapCubit.state as MapRouteLoaded;
        if (loadedState.routeInfo.durationMinutes > 10) {
          _mapCubit.startPeriodicPolling(
            originLat: widget.originLat,
            originLng: widget.originLng,
            destLat: widget.destLat,
            destLng: widget.destLng,
            destAddress: widget.destinationTitle,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapCubit.stopPeriodicPolling();
    _mapController.dispose();
    _mapCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final originLatLng = LatLng(widget.originLat, widget.originLng);
    final destLatLng = LatLng(widget.destLat, widget.destLng);

    return BlocProvider.value(
      value: _mapCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('مسار المهمة: ${widget.destinationTitle}'),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocConsumer<MapCubit, MapState>(
          listener: (context, state) {
            if (state is MapRouteLoaded) {
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) {
                  _fitRouteBounds(originLatLng, destLatLng, state.routeInfo.polylinePoints);
                }
              });
            } else if (state is MapError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        state.isQuotaError
                            ? Icons.warning_amber_rounded
                            : Icons.wifi_off_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: state.isQuotaError
                      ? Colors.purple.shade700
                      : (state.isNetworkError ? Colors.orange.shade800 : Colors.red.shade700),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MapLoading) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFFFC107)),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تحضير المسار على الخريطة...',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            RouteInfoEntity? currentRouteInfo;
            bool isRefreshing = false;

            if (state is MapRouteLoaded) {
              currentRouteInfo = state.routeInfo;
            } else if (state is MapRouteRefreshing) {
              currentRouteInfo = state.currentRouteInfo;
              isRefreshing = true;
            }

            return Stack(
              children: [
                CustomFlutterMap(
                  mapController: _mapController,
                  initialCenter: originLatLng,
                  initialZoom: 13.0,
                  originPosition: originLatLng,
                  destinationPosition: destLatLng,
                  polylinePoints: currentRouteInfo?.polylinePoints ?? [],
                ),

                // Map Action Buttons (Fit Bounds, Current Location, Zoom In, Zoom Out)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'fab_fit_route',
                        backgroundColor: Colors.white,
                        tooltip: 'عرض المسار بالكامل',
                        child: const Icon(Icons.fit_screen_rounded, color: Color(0xFF1E88E5)),
                        onPressed: () {
                          _fitRouteBounds(
                            originLatLng,
                            destLatLng,
                            currentRouteInfo?.polylinePoints ?? [],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'fab_center_delegate',
                        backgroundColor: Colors.white,
                        tooltip: 'موقعي الحالي',
                        child: const Icon(Icons.my_location, color: Color(0xFF1E88E5)),
                        onPressed: () {
                          _mapController.move(originLatLng, 15.0);
                        },
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'fab_zoom_in',
                        backgroundColor: Colors.white,
                        tooltip: 'تكبير',
                        onPressed: _zoomIn,
                        child: const Icon(Icons.add, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'fab_zoom_out',
                        backgroundColor: Colors.white,
                        tooltip: 'تصغير',
                        onPressed: _zoomOut,
                        child: const Icon(Icons.remove, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                // Bottom Route Info Card
                if (currentRouteInfo != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: RouteInfoCard(
                      routeInfo: currentRouteInfo,
                      destinationTitle: widget.destinationTitle,
                      destinationAddress: widget.destinationAddress,
                      isRefreshing: isRefreshing,
                      onManualRefresh: () {
                        _mapCubit.refreshRoute(
                          originLat: widget.originLat,
                          originLng: widget.originLng,
                          destLat: widget.destLat,
                          destLng: widget.destLng,
                          destAddress: widget.destinationTitle,
                          isManual: true,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
