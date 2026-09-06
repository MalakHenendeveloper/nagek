class ValidateCouponEntity {
  final bool valid;
  final num discountAmount;
  final num finalAmount;
  final int remainingUses;
  final DateTime expiresAt;

  ValidateCouponEntity({
    required this.valid,
    required this.discountAmount,
    required this.finalAmount,
    required this.remainingUses,
    required this.expiresAt,
  });
}
