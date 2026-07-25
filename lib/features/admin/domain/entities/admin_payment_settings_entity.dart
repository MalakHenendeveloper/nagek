class WalletNumbersEntity {
  final String zainCash;
  final String westernUnion;
  final String visa;
  final String mastercard;

  WalletNumbersEntity({
    required this.zainCash,
    required this.westernUnion,
    required this.visa,
    required this.mastercard,
  });
}

class AdminPaymentSettingsEntity {
  final String walletOwnerName;
  final WalletNumbersEntity walletNumbers;
  final List<String> activePaymentMethods;
  final String paymentInstructions;

  AdminPaymentSettingsEntity({
    required this.walletOwnerName,
    required this.walletNumbers,
    required this.activePaymentMethods,
    required this.paymentInstructions,
  });
}
