import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class ApproveDelegateApplicationUseCase {
  final AdminRepository repository;

  ApproveDelegateApplicationUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.approveDelegateApplication(id);
  }
}
