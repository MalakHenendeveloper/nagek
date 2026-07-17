import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAvailableDeliveryOrdersUseCase {
  final OrdersRepository repository;

  GetAvailableDeliveryOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() {
    return repository.getAvailableDeliveryOrders();
  }
}
