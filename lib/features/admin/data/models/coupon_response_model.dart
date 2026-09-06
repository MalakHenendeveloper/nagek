import 'coupon_model.dart';

class CouponResponseModel {
  final bool success;
  final String message;
  final CouponModel? coupon;

  CouponResponseModel({
    required this.success,
    required this.message,
    this.coupon,
  });

  factory CouponResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final couponJson = data['coupon'] as Map<String, dynamic>?;

    return CouponResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      coupon: couponJson != null ? CouponModel.fromJson(couponJson) : null,
    );
  }
}
