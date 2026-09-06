import '../../domain/entities/coupon_entity.dart';

class CouponModel {
  final String id;
  final String code;
  final String discountType;
  final num discountValue;
  final bool isActive;
  final String createdBy;
  final int usageVersion;
  final int usageCount;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.isActive,
    required this.createdBy,
    required this.usageVersion,
    required this.usageCount,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      discountType: json['discountType'] ?? 'fixed',
      discountValue: json['discountValue'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? '',
      usageVersion: json['usageVersion'] ?? 0,
      usageCount: json['usageCount'] ?? 0,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  CouponEntity toEntity() {
    return CouponEntity(
      id: id,
      code: code,
      discountType: discountType,
      discountValue: discountValue,
      isActive: isActive,
      createdBy: createdBy,
      usageVersion: usageVersion,
      usageCount: usageCount,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
