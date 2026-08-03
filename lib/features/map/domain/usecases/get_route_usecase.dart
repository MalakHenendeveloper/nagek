import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/route_info_entity.dart';
import '../repositories/map_repository.dart';

@lazySingleton
class GetRouteUseCase {
  final MapRepository repository;

  GetRouteUseCase(this.repository);

  Future<Either<Failure, RouteInfoEntity>> call({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return repository.getRoute(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }
}
