import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AcceptDeliveryUseCase {
  final OrdersRepository repository;

  AcceptDeliveryUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.acceptDelivery(orderId);
  }
}
