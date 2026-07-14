import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_center_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateAdminCenterStatusUseCase {
  final AdminRepository _repository;

  UpdateAdminCenterStatusUseCase(this._repository);

  Future<Either<Failure, AdminCenterEntity>> call({
    required String centerId,
    required String status,
  }) {
    return _repository.updateCenterStatus(centerId, status);
  }
}
