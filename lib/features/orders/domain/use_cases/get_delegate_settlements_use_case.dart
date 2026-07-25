import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/delegate_settlement_entity.dart';
import '../repositories/orders_repository.dart';

@lazySingleton
class GetDelegateSettlementsUseCase {
  final OrdersRepository repository;

  GetDelegateSettlementsUseCase(this.repository);

  Future<Either<Failure, DelegateSettlementsResultEntity>> call({
    int page = 1,
    int limit = 10,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) async {
    return await repository.getDelegateSettlements(
      page: page,
      limit: limit,
      status: status,
      dateFrom: dateFrom,
      dateTo: dateTo,
      sort: sort,
    );
  }
}
