class AvailableCouponEntity {
  final String id;
  final String code;
  final String discountType;
  final num discountValue;
  final DateTime expiresAt;
  final int remainingUses;

  AvailableCouponEntity({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.expiresAt,
    required this.remainingUses,
  });
}
