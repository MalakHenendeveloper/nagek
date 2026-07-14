import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class RejectDelegateApplicationUseCase {
  final AdminRepository repository;

  RejectDelegateApplicationUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String rejectReason) {
    return repository.rejectDelegateApplication(id, rejectReason);
  }
}
