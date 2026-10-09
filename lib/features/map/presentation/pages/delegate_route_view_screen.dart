import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String? destinationPhone;

  const DelegateRouteViewScreen({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.destinationTitle,
    this.destinationAddress,
    this.destinationPhone,
  });

  @override
  State<DelegateRouteViewScreen> createState() =>
      _DelegateRouteViewScreenState();
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
          padding: const EdgeInsets.only(
            top: 80,
            bottom: 210,
            left: 50,
            right: 50,
          ),
          maxZoom: 16.0,
        ),
      );
    } catch (_) {}
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom + 1.0).clamp(3.0, 18.0),
    );
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom - 1.0).clamp(3.0, 18.0),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
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
                  _fitRouteBounds(
                    originLatLng,
                    destLatLng,
                    state.routeInfo.polylinePoints,
                  );
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
                      : (state.isNetworkError
                            ? Colors.orange.shade800
                            : Colors.red.shade700),
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
                        child: const Icon(
                          Icons.fit_screen_rounded,
                          color: Color(0xFF1E88E5),
                        ),
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
                        child: const Icon(
                          Icons.my_location,
                          color: Color(0xFF1E88E5),
                        ),
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

                // Bottom Route Info Card or Fallback Card if route failed to load
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
                  )
                else if (state is! MapLoading)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildFallbackDestinationCard(context),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackDestinationCard(BuildContext context) {
    final addressText =
        (widget.destinationAddress != null &&
            widget.destinationAddress!.isNotEmpty)
        ? widget.destinationAddress!
        : widget.destinationTitle;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orangeAccent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تعذر رسم مسار القيادة التلقائي على الخريطة',
                  style: GoogleFonts.cairo(
                    color: Colors.orangeAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'إعادة محاولة جلب المسار',
                onPressed: () {
                  _mapCubit.fetchRoute(
                    originLat: widget.originLat,
                    originLng: widget.originLng,
                    destLat: widget.destLat,
                    destLng: widget.destLng,
                    destAddress: widget.destinationTitle,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Instruction banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.orangeAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يرجى التواصل عن طريق الهاتف مع المركز لمعرفة العنوان بدقة.',
                    style: GoogleFonts.cairo(
                      color: Colors.orangeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 20),
          Text(
            widget.destinationTitle,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: SelectableText(
                  addressText,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: Color(0xFFFFC107),
                ),
                tooltip: 'نسخ العنوان',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: addressText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.teal.shade800,
                      content: Text(
                        'تم نسخ العنوان للحافظة بنجاح',
                        style: GoogleFonts.cairo(color: Colors.white),
                        textAlign: TextAlign.right,
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          if (widget.destinationPhone != null &&
              widget.destinationPhone!.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.phone_in_talk, size: 18),
                label: Text(
                  'اتصال بالمركز لمعرفة العنوان بدقة (${widget.destinationPhone})',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () =>
                    _makePhoneCall(context, widget.destinationPhone),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade800,
          content: Text(
            'رقم الهاتف غير متوفر لهذا المركز',
            style: GoogleFonts.cairo(color: Colors.white),
            textAlign: TextAlign.right,
          ),
        ),
      );
      return;
    }

    final cleanPhone = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      bool launched = false;
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri);
      }
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!launched && context.mounted) {
        Clipboard.setData(ClipboardData(text: cleanPhone));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal.shade800,
            content: Text(
              'تعذر فتح لوحة الاتصال تلقائياً. تم نسخ الرقم للحافظة: $cleanPhone',
              style: GoogleFonts.cairo(color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: cleanPhone));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal.shade800,
            content: Text(
              'تم نسخ رقم الهاتف للحافظة: $cleanPhone',
              style: GoogleFonts.cairo(color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        );
      }
    }
  }
}
