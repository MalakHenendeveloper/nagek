import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/validate_coupon_entity.dart';
import '../repositories/orders_repository.dart';

@lazySingleton
class ValidateCouponUseCase {
  final OrdersRepository _repository;

  ValidateCouponUseCase(this._repository);

  Future<Either<Failure, ValidateCouponEntity>> call({
    required String code,
    required num amount,
  }) {
    return _repository.validateCoupon(
      code: code,
      amount: amount,
    );
  }
}
