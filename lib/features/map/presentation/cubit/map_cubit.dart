import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/here_config.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/usecases/geocode_address_usecase.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_route_usecase.dart';
import '../../domain/usecases/reverse_geocode_usecase.dart';
import 'map_state.dart';

@injectable
class MapCubit extends Cubit<MapState> {
  final GetCurrentLocationUseCase getCurrentLocationUseCase;
  final ReverseGeocodeUseCase reverseGeocodeUseCase;
  final GeocodeAddressUseCase geocodeAddressUseCase;
  final GetRouteUseCase getRouteUseCase;

  Timer? _pollingTimer;
  Timer? _debounceTimer;
  DateTime? _lastManualRefreshTime;

  MapCubit({
    required this.getCurrentLocationUseCase,
    required this.reverseGeocodeUseCase,
    required this.geocodeAddressUseCase,
    required this.getRouteUseCase,
  }) : super(const MapInitial());

  /// Fetch user's current GPS location
  Future<void> fetchCurrentLocation() async {
    emit(const MapLoading());
    final result = await getCurrentLocationUseCase();
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (location) => emit(MapLocationSelected(location)),
    );
  }

  /// User taps on map to select coordinates
  Future<void> selectLocationOnMap(double lat, double lng) async {
    emit(MapLocationSelected(MapLocationEntity(
      latitude: lat,
      longitude: lng,
      address: 'جاري استخراج العنوان...',
    )));

    final result = await reverseGeocodeUseCase(lat, lng);
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (location) => emit(MapLocationSelected(location)),
    );
  }

  /// Search addresses with 500ms Debounce
  void searchAddressWithDebounce(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (query.trim().isEmpty) {
      emit(const MapSearchResultsLoaded([]));
      return;
    }

    _debounceTimer = Timer(Duration(milliseconds: HereConfig.searchDebounceMs), () async {
      final result = await geocodeAddressUseCase(query);
      result.fold(
        (failure) => emit(_mapFailureToState(failure)),
        (results) => emit(MapSearchResultsLoaded(results)),
      );
    });
  }

  /// Load initial route for Delegate Navigation
  Future<void> fetchRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? destAddress,
  }) async {
    emit(const MapLoading());
    await _fetchRouteInternal(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      destAddress: destAddress,
    );
  }

  /// Refresh route (Manual button or Periodic Polling)
  Future<void> refreshRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? destAddress,
    bool isManual = false,
  }) async {
    if (isManual) {
      final now = DateTime.now();
      if (_lastManualRefreshTime != null) {
        final elapsed = now.difference(_lastManualRefreshTime!).inSeconds;
        if (elapsed < HereConfig.manualRefreshCooldownSeconds) {
          log('[MapCubit Throttling] Manual refresh ignored. Wait ${HereConfig.manualRefreshCooldownSeconds - elapsed} seconds.');
          return;
        }
      }
      _lastManualRefreshTime = now;
    }

    if (state is MapRouteLoaded) {
      final currentState = state as MapRouteLoaded;
      emit(MapRouteRefreshing(
        currentRouteInfo: currentState.routeInfo,
        origin: currentState.origin,
        destination: currentState.destination,
      ));
    }

    await _fetchRouteInternal(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      destAddress: destAddress,
    );
  }

  Future<void> _fetchRouteInternal({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? destAddress,
  }) async {
    final routeResult = await getRouteUseCase(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );

    routeResult.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (routeInfo) {
        final origin = MapLocationEntity(latitude: originLat, longitude: originLng);
        final dest = MapLocationEntity(
          latitude: destLat,
          longitude: destLng,
          address: destAddress,
        );
        emit(MapRouteLoaded(
          routeInfo: routeInfo,
          origin: origin,
          destination: dest,
        ));

        // Auto-refresh every 5 minutes ONLY if estimated duration > 10 minutes
        if (routeInfo.durationMinutes > 10) {
          startPeriodicPolling(
            originLat: originLat,
            originLng: originLng,
            destLat: destLat,
            destLng: destLng,
            destAddress: destAddress,
          );
        } else {
          stopPeriodicPolling();
        }
      },
    );
  }

  /// Start periodic polling timer (5 mins)
  void startPeriodicPolling({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? destAddress,
  }) {
    if (!HereConfig.enableAutoRefresh) return;
    stopPeriodicPolling();

    _pollingTimer = Timer.periodic(
      Duration(minutes: HereConfig.pollingIntervalMinutes),
      (_) {
        log('[MapCubit Polling] Periodic 5-minute refresh triggered.');
        refreshRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          destAddress: destAddress,
        );
      },
    );
  }

  void pausePeriodicPolling() {
    log('[MapCubit Polling] Paused periodic polling due to app background state.');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void stopPeriodicPolling() {
    log('[MapCubit Polling] Stopped periodic polling timer.');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  MapState _mapFailureToState(Failure failure) {
    if (failure is QuotaFailure) {
      return MapError(
        message: failure.message,
        isQuotaError: true,
      );
    }
    if (failure is NetworkFailure) {
      return MapError(
        message: failure.message,
        isNetworkError: true,
      );
    }
    return MapError(message: failure.message);
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
