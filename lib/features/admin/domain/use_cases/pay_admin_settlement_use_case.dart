import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_settlement_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class PayAdminSettlementUseCase {
  final AdminRepository repository;

  PayAdminSettlementUseCase(this.repository);

  Future<Either<Failure, AdminSettlementEntity>> call(
    String settlementId, {
    String? paymentMethod,
    String? notes,
  }) async {
    return await repository.payAdminSettlement(
      settlementId,
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }
}
