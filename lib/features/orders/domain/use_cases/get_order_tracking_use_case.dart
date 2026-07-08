import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetOrderTrackingUseCase {
  final OrdersRepository repository;

  GetOrderTrackingUseCase(this.repository);

  Future<Either<Failure, OrderTrackingEntity>> call(String id) {
    return repository.getOrderTracking(id);
  }
}
