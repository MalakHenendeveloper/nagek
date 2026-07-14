import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/delegate_application_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetDelegateApplicationDetailsUseCase {
  final AdminRepository repository;

  GetDelegateApplicationDetailsUseCase(this.repository);

  Future<Either<Failure, DelegateApplicationEntity>> call(String applicationId) {
    return repository.getDelegateApplicationDetails(applicationId);
  }
}
