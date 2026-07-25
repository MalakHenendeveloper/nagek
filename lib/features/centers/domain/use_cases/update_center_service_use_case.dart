import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class UpdateCenterServiceUseCase {
  final CentersRepository repository;

  UpdateCenterServiceUseCase(this.repository);

  Future<Either<Failure, ServiceEntity>> call({
    required String serviceId,
    required String serviceName,
    required String description,
    required double price,
    required String estimatedTime,
    required bool isAvailable,
  }) async {
    return await repository.updateCenterService(
      serviceId: serviceId,
      serviceName: serviceName,
      description: description,
      price: price,
      estimatedTime: estimatedTime,
      isAvailable: isAvailable,
    );
  }
}
