import 'coupon_model.dart';

class CouponsListResponseModel {
  final bool success;
  final String message;
  final List<CouponModel> coupons;

  CouponsListResponseModel({
    required this.success,
    required this.message,
    required this.coupons,
  });

  factory CouponsListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final couponsJson = data['coupons'] as List<dynamic>? ?? [];

    return CouponsListResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      coupons: couponsJson
          .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
