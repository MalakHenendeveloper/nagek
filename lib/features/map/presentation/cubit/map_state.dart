import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/route_info_entity.dart';

abstract class MapState {
  const MapState();
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLocationSelected extends MapState {
  final MapLocationEntity selectedLocation;

  const MapLocationSelected(this.selectedLocation);
}

class MapSearchResultsLoaded extends MapState {
  final List<MapLocationEntity> results;

  const MapSearchResultsLoaded(this.results);
}

class MapRouteLoaded extends MapState {
  final RouteInfoEntity routeInfo;
  final MapLocationEntity origin;
  final MapLocationEntity destination;

  const MapRouteLoaded({
    required this.routeInfo,
    required this.origin,
    required this.destination,
  });
}

class MapRouteRefreshing extends MapState {
  final RouteInfoEntity currentRouteInfo;
  final MapLocationEntity origin;
  final MapLocationEntity destination;

  const MapRouteRefreshing({
    required this.currentRouteInfo,
    required this.origin,
    required this.destination,
  });
}

class MapError extends MapState {
  final String message;
  final bool isQuotaError;
  final bool isNetworkError;

  const MapError({
    required this.message,
    this.isQuotaError = false,
    this.isNetworkError = false,
  });
}
