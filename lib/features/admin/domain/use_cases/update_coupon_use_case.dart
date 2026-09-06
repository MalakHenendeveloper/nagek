import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/coupon_entity.dart';
import '../repositories/admin_repository.dart';

@injectable
class UpdateCouponUseCase {
  final AdminRepository repository;

  UpdateCouponUseCase(this.repository);

  Future<Either<Failure, CouponEntity>> call({
    required String id,
    num? discountValue,
    bool? isActive,
  }) {
    return repository.updateCoupon(
      id: id,
      discountValue: discountValue,
      isActive: isActive,
    );
  }
}
