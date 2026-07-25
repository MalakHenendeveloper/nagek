class AdminFinancialSettingsEntity {
  final String commissionType;
  final double commissionValue;
  final String delegateFeeType;
  final double delegateFeeValue;
  final String currency;
  final bool isActive;

  AdminFinancialSettingsEntity({
    required this.commissionType,
    required this.commissionValue,
    required this.delegateFeeType,
    required this.delegateFeeValue,
    required this.currency,
    required this.isActive,
  });
}
