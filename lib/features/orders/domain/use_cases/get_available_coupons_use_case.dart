import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/available_coupon_entity.dart';
import '../repositories/orders_repository.dart';

@lazySingleton
class GetAvailableCouponsUseCase {
  final OrdersRepository _repository;

  GetAvailableCouponsUseCase(this._repository);

  Future<Either<Failure, List<AvailableCouponEntity>>> call() {
    return _repository.getAvailableCoupons();
  }
}
