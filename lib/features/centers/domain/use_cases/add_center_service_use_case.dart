import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class AddCenterServiceUseCase {
  final CentersRepository repository;

  AddCenterServiceUseCase(this.repository);

  Future<Either<Failure, ServiceEntity>> call({
    required String serviceName,
    required String description,
    required double price,
    required String estimatedTime,
    bool isAvailable = true,
  }) async {
    return await repository.addCenterService(
      serviceName: serviceName,
      description: description,
      price: price,
      estimatedTime: estimatedTime,
      isAvailable: isAvailable,
    );
  }
}
