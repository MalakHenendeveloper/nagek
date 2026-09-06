class CouponEntity {
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

  CouponEntity({
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
}
