import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAvailablePickupOrdersUseCase {
  final OrdersRepository repository;

  GetAvailablePickupOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() {
    return repository.getAvailablePickupOrders();
  }
}
