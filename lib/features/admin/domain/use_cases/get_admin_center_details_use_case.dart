import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_center_details_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdminCenterDetailsUseCase {
  final AdminRepository _repository;

  GetAdminCenterDetailsUseCase(this._repository);

  Future<Either<Failure, AdminCenterDetailsEntity>> call(String centerId) {
    return _repository.getCenterDetails(centerId);
  }
}
