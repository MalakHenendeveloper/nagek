import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/map_location_entity.dart';
import '../repositories/map_repository.dart';

@lazySingleton
class GetCurrentLocationUseCase {
  final MapRepository repository;

  GetCurrentLocationUseCase(this.repository);

  Future<Either<Failure, MapLocationEntity>> call() {
    return repository.getCurrentLocation();
  }
}
