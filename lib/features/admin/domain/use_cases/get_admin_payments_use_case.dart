import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_payment_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdminPaymentsUseCase {
  final AdminRepository _repository;

  GetAdminPaymentsUseCase(this._repository);

  Future<Either<Failure, AdminPaymentsResult>> call({required int page, required int limit}) {
    return _repository.getAdminPayments(page: page, limit: limit);
  }
}
