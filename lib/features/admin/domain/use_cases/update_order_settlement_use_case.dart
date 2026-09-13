import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class UpdateOrderSettlementUseCase {
  final AdminRepository _repository;

  UpdateOrderSettlementUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String orderId,
    required String party,
    required bool settled,
  }) async {
    return await _repository.updateOrderSettlement(
      orderId: orderId,
      party: party,
      settled: settled,
    );
  }
}
