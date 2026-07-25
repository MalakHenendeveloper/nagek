import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_settlement_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetAdminSettlementsUseCase {
  final AdminRepository repository;

  GetAdminSettlementsUseCase(this.repository);

  Future<Either<Failure, AdminSettlementsResultEntity>> call({
    required int page,
    required int limit,
    String? status,
    String? recipientType,
    String? recipientId,
    String? order,
    String? paymentMethod,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) async {
    return await repository.getAdminSettlements(
      page: page,
      limit: limit,
      status: status,
      recipientType: recipientType,
      recipientId: recipientId,
      order: order,
      paymentMethod: paymentMethod,
      dateFrom: dateFrom,
      dateTo: dateTo,
      sort: sort,
    );
  }
}
