import '../../domain/entities/available_coupon_entity.dart';

class AvailableCouponsResponseModel {
  final bool success;
  final String message;
  final List<AvailableCouponModel> coupons;

  AvailableCouponsResponseModel({
    required this.success,
    required this.message,
    required this.coupons,
  });

  factory AvailableCouponsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final list = data['coupons'] as List<dynamic>? ?? [];

    return AvailableCouponsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      coupons: list
          .map((e) => AvailableCouponModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AvailableCouponModel {
  final String id;
  final String code;
  final String discountType;
  final num discountValue;
  final DateTime expiresAt;
  final int remainingUses;

  AvailableCouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.expiresAt,
    required this.remainingUses,
  });

  factory AvailableCouponModel.fromJson(Map<String, dynamic> json) {
    return AvailableCouponModel(
      id: json['id'] ?? json['_id'] ?? '',
      code: json['code'] ?? '',
      discountType: json['discountType'] ?? 'fixed',
      discountValue: json['discountValue'] ?? 0,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now(),
      remainingUses: json['remainingUses'] ?? 0,
    );
  }

  AvailableCouponEntity toEntity() {
    return AvailableCouponEntity(
      id: id,
      code: code,
      discountType: discountType,
      discountValue: discountValue,
      expiresAt: expiresAt,
      remainingUses: remainingUses,
    );
  }
}
