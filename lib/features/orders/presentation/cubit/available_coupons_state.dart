import '../../domain/entities/available_coupon_entity.dart';

abstract class AvailableCouponsState {}

class AvailableCouponsInitial extends AvailableCouponsState {}

class AvailableCouponsLoading extends AvailableCouponsState {}

class AvailableCouponsLoaded extends AvailableCouponsState {
  final List<AvailableCouponEntity> coupons;

  AvailableCouponsLoaded(this.coupons);
}

class AvailableCouponsError extends AvailableCouponsState {
  final String message;

  AvailableCouponsError(this.message);
}
