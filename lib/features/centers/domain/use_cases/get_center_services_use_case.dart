import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class GetCenterServicesUseCase {
  final CentersRepository repository;

  GetCenterServicesUseCase(this.repository);

  Future<Either<Failure, List<ServiceEntity>>> call(String centerId) {
    return repository.getCenterServices(centerId);
  }
}
