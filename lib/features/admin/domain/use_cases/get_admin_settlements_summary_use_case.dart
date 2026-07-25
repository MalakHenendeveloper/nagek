import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_settlements_summary_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetAdminSettlementsSummaryUseCase {
  final AdminRepository repository;

  GetAdminSettlementsSummaryUseCase(this.repository);

  Future<Either<Failure, AdminSettlementsSummaryResultEntity>> call({
    required int page,
    required int limit,
    String? recipientType,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    return await repository.getAdminSettlementsSummary(
      page: page,
      limit: limit,
      recipientType: recipientType,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }
}
