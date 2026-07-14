import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteAdminDelegateUseCase {
  final AdminRepository _repository;

  DeleteAdminDelegateUseCase(this._repository);

  Future<Either<Failure, AdminUserEntity>> call(String delegateId) {
    return _repository.deleteDelegate(delegateId);
  }
}
