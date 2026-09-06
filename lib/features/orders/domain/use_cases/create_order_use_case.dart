import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateOrderUseCase {
  final OrdersRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required String centerId,
    required String deviceType,
    required String brand,
    required String model,
    required String problemType,
    required String problemDescription,
    required List<String> imagePaths,
    required String address,
    required String city,
    String? couponCode,
  }) {
    return repository.createOrder(
      centerId: centerId,
      deviceType: deviceType,
      brand: brand,
      model: model,
      problemType: problemType,
      problemDescription: problemDescription,
      imagePaths: imagePaths,
      address: address,
      city: city,
      couponCode: couponCode,
    );
  }
}
