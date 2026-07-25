import '../../../orders/data/models/order_model.dart';
import '../../domain/entities/center_order_details_entity.dart';

class CenterFinancialViewModel {
  final double repairCost;
  final double repairIncome;
  final String paymentStatus;
  final String currency;
  final String? paymentDetails;

  CenterFinancialViewModel({
    required this.repairCost,
    required this.repairIncome,
    required this.paymentStatus,
    required this.currency,
    this.paymentDetails,
  });

  factory CenterFinancialViewModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final repair = (map['repairCost'] ?? map['repairIncome'] ?? map['centerPayout'] ?? map['centerAmount'] ?? 0.0).toDouble();
    return CenterFinancialViewModel(
      repairCost: repair,
      repairIncome: repair,
      paymentStatus: map['paymentStatus'] ?? '',
      currency: (map['currency'] != null && map['currency'].toString().isNotEmpty) ? map['currency'].toString() : 'IQD',
      paymentDetails: map['paymentDetails']?.toString(),
    );
  }

  CenterFinancialViewEntity toEntity() {
    return CenterFinancialViewEntity(
      repairCost: repairCost,
      repairIncome: repairIncome,
      paymentStatus: paymentStatus,
      currency: currency,
      paymentDetails: paymentDetails,
    );
  }
}

class CenterOrderDetailsResponseModel {
  final bool success;
  final String message;
  final OrderModel? order;
  final CenterFinancialViewModel? financialView;

  CenterOrderDetailsResponseModel({
    required this.success,
    required this.message,
    this.order,
    this.financialView,
  });

  factory CenterOrderDetailsResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    final orderJson = data['order'] as Map?;
    final finJson = data['financialView'] as Map?;

    return CenterOrderDetailsResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      order: orderJson != null ? OrderModel.fromJson(orderJson) : null,
      financialView: finJson != null ? CenterFinancialViewModel.fromJson(finJson) : null,
    );
  }

  CenterOrderDetailsEntity toEntity() {
    return CenterOrderDetailsEntity(
      order: order!.toEntity(),
      financialView: financialView!.toEntity(),
    );
  }
}
