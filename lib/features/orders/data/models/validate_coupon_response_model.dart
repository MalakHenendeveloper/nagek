import '../../domain/entities/validate_coupon_entity.dart';

class ValidateCouponResponseModel {
  final bool success;
  final String message;
  final ValidateCouponDataModel? data;

  ValidateCouponResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ValidateCouponResponseModel.fromJson(Map<String, dynamic> json) {
    return ValidateCouponResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ValidateCouponDataModel.fromJson(json['data']) : null,
    );
  }
}

class ValidateCouponDataModel {
  final bool valid;
  final num discountAmount;
  final num finalAmount;
  final int remainingUses;
  final DateTime expiresAt;

  ValidateCouponDataModel({
    required this.valid,
    required this.discountAmount,
    required this.finalAmount,
    required this.remainingUses,
    required this.expiresAt,
  });

  factory ValidateCouponDataModel.fromJson(Map<String, dynamic> json) {
    return ValidateCouponDataModel(
      valid: json['valid'] ?? false,
      discountAmount: json['discountAmount'] ?? 0,
      finalAmount: json['finalAmount'] ?? 0,
      remainingUses: json['remainingUses'] ?? 0,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : DateTime.now(),
    );
  }

  ValidateCouponEntity toEntity() {
    return ValidateCouponEntity(
      valid: valid,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      remainingUses: remainingUses,
      expiresAt: expiresAt,
    );
  }
}
