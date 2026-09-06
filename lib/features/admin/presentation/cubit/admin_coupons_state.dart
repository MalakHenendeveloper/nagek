part of 'admin_coupons_cubit.dart';

abstract class AdminCouponsState {}

class AdminCouponsInitial extends AdminCouponsState {}

// Create coupon states
class AdminCouponsLoading extends AdminCouponsState {}

class AdminCouponsSuccess extends AdminCouponsState {
  final CouponEntity coupon;

  AdminCouponsSuccess(this.coupon);
}

class AdminCouponsError extends AdminCouponsState {
  final String message;

  AdminCouponsError(this.message);
}

// Fetch coupons list states
class AdminCouponsListLoading extends AdminCouponsState {}

class AdminCouponsListLoaded extends AdminCouponsState {
  final List<CouponEntity> coupons;

  AdminCouponsListLoaded(this.coupons);
}

class AdminCouponsListError extends AdminCouponsState {
  final String message;

  AdminCouponsListError(this.message);
}

// Update coupon states
class AdminCouponUpdateLoading extends AdminCouponsState {}

class AdminCouponUpdateSuccess extends AdminCouponsState {
  final CouponEntity coupon;

  AdminCouponUpdateSuccess(this.coupon);
}

class AdminCouponUpdateError extends AdminCouponsState {
  final String message;

  AdminCouponUpdateError(this.message);
}
