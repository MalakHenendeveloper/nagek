import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/di.dart';
import '../../domain/entities/map_location_entity.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/custom_flutter_map.dart';
import '../widgets/map_search_bar.dart';

class MapPickerScreen extends StatefulWidget {
  final MapLocationEntity? initialLocation;
  final String title;

  const MapPickerScreen({
    super.key,
    this.initialLocation,
    this.title = 'تحديد الموقع على الخريطة',
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapCubit _mapCubit;
  late final MapController _mapController;
  LatLng _currentCenter = const LatLng(30.0444, 31.2357); // Default Cairo
  MapLocationEntity? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _mapCubit = getIt<MapCubit>();
    _mapController = MapController();

    if (widget.initialLocation != null) {
      _currentCenter = widget.initialLocation!.toLatLng;
      _selectedLocation = widget.initialLocation;
    } else {
      _mapCubit.fetchCurrentLocation();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _mapCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mapCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocConsumer<MapCubit, MapState>(
          listener: (context, state) {
            if (state is MapLocationSelected) {
              setState(() {
                _selectedLocation = state.selectedLocation;
                _currentCenter = state.selectedLocation.toLatLng;
              });
              _mapController.move(_currentCenter, 15.0);
            } else if (state is MapError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: state.isQuotaError ? Colors.purple : Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final searchResults =
                state is MapSearchResultsLoaded ? state.results : <MapLocationEntity>[];

            return Stack(
              children: [
                CustomFlutterMap(
                  mapController: _mapController,
                  initialCenter: _currentCenter,
                  selectedMarkerPosition: _selectedLocation?.toLatLng,
                  onTap: (latLng) {
                    _mapCubit.selectLocationOnMap(latLng.latitude, latLng.longitude);
                  },
                ),

                // Top Search Bar
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: MapSearchBar(
                    searchResults: searchResults,
                    onChanged: (query) {
                      _mapCubit.searchAddressWithDebounce(query);
                    },
                    onLocationSelected: (location) {
                      setState(() {
                        _selectedLocation = location;
                        _currentCenter = location.toLatLng;
                      });
                      _mapController.move(_currentCenter, 15.0);
                    },
                  ),
                ),

                // My Location FAB
                Positioned(
                  bottom: 110,
                  left: 16,
                  child: FloatingActionButton(
                    heroTag: 'fab_my_location',
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Color(0xFF1E88E5)),
                    onPressed: () {
                      _mapCubit.fetchCurrentLocation();
                    },
                  ),
                ),

                // Bottom Selected Address & Confirm Card
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),

                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الموقع المحدد:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedLocation?.address ?? 'اضغط على الخريطة لاختيار الموقع',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _selectedLocation != null
                                ? () {
                                    Navigator.pop(context, _selectedLocation);
                                  }
                                : null,
                            child: const Text(
                              'تأكيد هذا الموقع',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
