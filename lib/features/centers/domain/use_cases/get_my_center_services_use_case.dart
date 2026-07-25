import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class GetMyCenterServicesUseCase {
  final CentersRepository repository;

  GetMyCenterServicesUseCase(this.repository);

  Future<Either<Failure, List<ServiceEntity>>> call() async {
    return await repository.getMyCenterServices();
  }
}
