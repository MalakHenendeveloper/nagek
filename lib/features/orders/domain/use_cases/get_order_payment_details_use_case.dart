import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_payment_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetOrderPaymentDetailsUseCase {
  final OrdersRepository repository;

  GetOrderPaymentDetailsUseCase(this.repository);

  Future<Either<Failure, OrderPaymentEntity>> call(String orderId) {
    return repository.getOrderPaymentDetails(orderId);
  }
}
