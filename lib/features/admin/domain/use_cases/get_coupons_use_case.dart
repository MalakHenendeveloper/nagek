import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/coupon_entity.dart';
import '../repositories/admin_repository.dart';

@injectable
class GetCouponsUseCase {
  final AdminRepository repository;

  GetCouponsUseCase(this.repository);

  Future<Either<Failure, List<CouponEntity>>> call() {
    return repository.getCoupons();
  }
}
