import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/centers_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetCenterDashboardOrdersUseCase {
  final CentersRepository repository;

  GetCenterDashboardOrdersUseCase(this.repository);

  Future<Either<Failure, OrdersResultEntity>> call({
    required int page,
    required int limit,
  }) {
    return repository.getCenterDashboardOrders(page: page, limit: limit);
  }
}
