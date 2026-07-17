import '../../../orders/domain/entities/order_entity.dart';

class CenterFinancialViewEntity {
  final double repairIncome;
  final String paymentStatus;
  final String currency;
  final String? paymentDetails;

  CenterFinancialViewEntity({
    required this.repairIncome,
    required this.paymentStatus,
    required this.currency,
    this.paymentDetails,
  });
}

class CenterOrderDetailsEntity {
  final OrderEntity order;
  final CenterFinancialViewEntity financialView;

  CenterOrderDetailsEntity({
    required this.order,
    required this.financialView,
  });
}
