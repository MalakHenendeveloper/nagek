import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/map_location_entity.dart';
import '../repositories/map_repository.dart';

@lazySingleton
class ReverseGeocodeUseCase {
  final MapRepository repository;

  ReverseGeocodeUseCase(this.repository);

  Future<Either<Failure, MapLocationEntity>> call(double lat, double lng) {
    return repository.reverseGeocode(lat, lng);
  }
}
