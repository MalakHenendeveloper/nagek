import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/center_settlement_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class GetCenterSettlementsUseCase {
  final CentersRepository repository;

  GetCenterSettlementsUseCase(this.repository);

  Future<Either<Failure, CenterSettlementsResultEntity>> call({
    required int page,
    required int limit,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) async {
    return await repository.getCenterSettlements(
      page: page,
      limit: limit,
      status: status,
      dateFrom: dateFrom,
      dateTo: dateTo,
      sort: sort,
    );
  }
}
