import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteAdminUserUseCase {
  final AdminRepository _repository;

  DeleteAdminUserUseCase(this._repository);

  Future<Either<Failure, AdminUserEntity>> call(String userId) {
    return _repository.deleteUser(userId);
  }
}
