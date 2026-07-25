import '../entities/order_entity.dart';

class OrderPaymentEntity {
  final OrderEntity order;
  final PaymentInfoEntity? paymentInfo;
  final dynamic payment;
  final OrderPaymentFinancialViewEntity financialView;

  OrderPaymentEntity({
    required this.order,
    this.paymentInfo,
    this.payment,
    required this.financialView,
  });
}

class PaymentInfoEntity {
  final String walletOwnerName;
  final Map<String, String> walletNumbers;
  final List<String> availablePaymentMethods;
  final String paymentInstructions;

  PaymentInfoEntity({
    required this.walletOwnerName,
    required this.walletNumbers,
    required this.availablePaymentMethods,
    required this.paymentInstructions,
  });
}

class PaymentBreakdownEntity {
  final double repairCost;
  final double pickupFee;
  final double deliveryFee;
  final double adminFee;
  final double adminCommissionAmount;

  PaymentBreakdownEntity({
    required this.repairCost,
    required this.pickupFee,
    required this.deliveryFee,
    required this.adminFee,
    required this.adminCommissionAmount,
  });
}

class PaymentStageEntity {
  final String stage;
  final String description;
  final double amount;

  PaymentStageEntity({
    required this.stage,
    required this.description,
    required this.amount,
  });
}

class WalletInfoEntity {
  final String walletOwnerName;
  final Map<String, String> walletNumbers;
  final String paymentInstructions;

  WalletInfoEntity({
    required this.walletOwnerName,
    required this.walletNumbers,
    required this.paymentInstructions,
  });
}

class OrderPaymentFinancialViewEntity {
  final double orderTotal;
  final PaymentBreakdownEntity? breakdown;
  final List<PaymentStageEntity> payments;
  final String paymentStatus;
  final String currency;
  final WalletInfoEntity? walletInfo;
  final dynamic paymentDetails;

  OrderPaymentFinancialViewEntity({
    required this.orderTotal,
    this.breakdown,
    required this.payments,
    required this.paymentStatus,
    required this.currency,
    this.walletInfo,
    this.paymentDetails,
  });
}
