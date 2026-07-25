import 'order_model.dart';
import 'order_payment_response_model.dart';

class OrderDetailsResponseModel {
  final bool success;
  final String message;
  final OrderModel? order;
  final OrderPaymentFinancialViewModel? financialView;
  final double delegateFeeValue;

  OrderDetailsResponseModel({
    required this.success,
    required this.message,
    this.order,
    this.financialView,
    this.delegateFeeValue = 0.0,
  });

  factory OrderDetailsResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    final financialJson = data['financialView'] as Map?;

    final rawFee = data['delegateFeeValue'] ??
        (financialJson != null && financialJson['breakdown'] is Map
            ? financialJson['breakdown']['pickupFee']
            : null);
    final double? rootDelegateFeeValue = rawFee is num ? rawFee.toDouble() : null;

    final orderJson = data['order'] as Map? ?? (data.containsKey('device') ? data : null);

    return OrderDetailsResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      order: orderJson != null
          ? OrderModel.fromJson(orderJson, rootDelegateFeeValue: rootDelegateFeeValue)
          : null,
      financialView: financialJson != null
          ? OrderPaymentFinancialViewModel.fromJson(financialJson)
          : null,
      delegateFeeValue: rootDelegateFeeValue ?? 0.0,
    );
  }
}
