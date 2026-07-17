import '../entities/order_entity.dart';

class OrderPaymentEntity {
  final OrderEntity order;
  final dynamic payment; // Can be null or any payment details object
  final OrderPaymentFinancialViewEntity financialView;

  OrderPaymentEntity({
    required this.order,
    this.payment,
    required this.financialView,
  });
}

class OrderPaymentFinancialViewEntity {
  final double clientTotal;
  final String paymentStatus;
  final String currency;
  final dynamic walletInfo;
  final dynamic paymentDetails;

  OrderPaymentFinancialViewEntity({
    required this.clientTotal,
    required this.paymentStatus,
    required this.currency,
    this.walletInfo,
    this.paymentDetails,
  });
}
