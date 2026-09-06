import '../../domain/entities/validate_coupon_entity.dart';

abstract class ValidateCouponState {}

class ValidateCouponInitial extends ValidateCouponState {}

class ValidateCouponLoading extends ValidateCouponState {}

class ValidateCouponSuccess extends ValidateCouponState {
  final ValidateCouponEntity couponResult;
  final String code;

  ValidateCouponSuccess({
    required this.couponResult,
    required this.code,
  });
}

class ValidateCouponError extends ValidateCouponState {
  final String message;

  ValidateCouponError(this.message);
}
