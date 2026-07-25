import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class GetCenterServiceDetailsUseCase {
  final CentersRepository repository;

  GetCenterServiceDetailsUseCase(this.repository);

  Future<Either<Failure, ServiceEntity>> call(String serviceId) async {
    return await repository.getCenterServiceDetails(serviceId);
  }
}
