import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/coupon_entity.dart';
import '../repositories/admin_repository.dart';

@injectable
class CreateCouponUseCase {
  final AdminRepository repository;

  CreateCouponUseCase(this.repository);

  Future<Either<Failure, CouponEntity>> call({
    required String code,
    required num discountValue,
  }) {
    return repository.createCoupon(
      code: code,
      discountValue: discountValue,
    );
  }
}
