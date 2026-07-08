import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetOrdersUseCase {
  final OrdersRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, OrdersResultEntity>> call({
    required int page,
    required int limit,
  }) {
    return repository.getOrders(page: page, limit: limit);
  }
}
