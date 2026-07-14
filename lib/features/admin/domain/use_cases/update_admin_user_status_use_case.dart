import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateAdminUserStatusUseCase {
  final AdminRepository _repository;

  UpdateAdminUserStatusUseCase(this._repository);

  Future<Either<Failure, AdminUserEntity>> call({
    required String userId,
    required bool isActive,
  }) {
    return _repository.updateUserStatus(userId, isActive);
  }
}
