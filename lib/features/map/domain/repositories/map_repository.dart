import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/map_location_entity.dart';
import '../entities/route_info_entity.dart';

abstract class MapRepository {
  Future<Either<Failure, MapLocationEntity>> getCurrentLocation();
  Future<Either<Failure, MapLocationEntity>> reverseGeocode(double lat, double lng);
  Future<Either<Failure, List<MapLocationEntity>>> geocodeAddress(String query);
  Future<Either<Failure, RouteInfoEntity>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}
