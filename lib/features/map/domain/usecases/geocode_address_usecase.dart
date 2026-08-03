import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/map_location_entity.dart';
import '../repositories/map_repository.dart';

@lazySingleton
class GeocodeAddressUseCase {
  final MapRepository repository;

  GeocodeAddressUseCase(this.repository);

  Future<Either<Failure, List<MapLocationEntity>>> call(String query) {
    return repository.geocodeAddress(query);
  }
}
