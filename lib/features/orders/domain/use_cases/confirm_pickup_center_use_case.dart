import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ConfirmPickupCenterUseCase {
  final OrdersRepository repository;

  ConfirmPickupCenterUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId, List<String> imagePaths) {
    return repository.confirmPickupCenter(orderId, imagePaths);
  }
}
