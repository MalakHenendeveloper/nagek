import '../../domain/entities/order_payment_entity.dart';
import 'order_model.dart';

class OrderPaymentResponseModel {
  final bool success;
  final String message;
  final OrderPaymentModel? data;

  OrderPaymentResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OrderPaymentResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final dataMap = map['data'] as Map?;

    return OrderPaymentResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: dataMap != null ? OrderPaymentModel.fromJson(dataMap) : null,
    );
  }
}

class OrderPaymentModel {
  final OrderModel order;
  final dynamic payment;
  final OrderPaymentFinancialViewModel financialView;

  OrderPaymentModel({
    required this.order,
    this.payment,
    required this.financialView,
  });

  factory OrderPaymentModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return OrderPaymentModel(
      order: OrderModel.fromJson(map['order'] as Map?),
      payment: map['payment'],
      financialView: OrderPaymentFinancialViewModel.fromJson(map['financialView'] as Map?),
    );
  }

  OrderPaymentEntity toEntity() {
    return OrderPaymentEntity(
      order: order.toEntity(),
      payment: payment,
      financialView: financialView.toEntity(),
    );
  }
}

class OrderPaymentFinancialViewModel {
  final double clientTotal;
  final String paymentStatus;
  final String currency;
  final dynamic walletInfo;
  final dynamic paymentDetails;

  OrderPaymentFinancialViewModel({
    required this.clientTotal,
    required this.paymentStatus,
    required this.currency,
    this.walletInfo,
    this.paymentDetails,
  });

  factory OrderPaymentFinancialViewModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return OrderPaymentFinancialViewModel(
      clientTotal: (map['clientTotal'] ?? 0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? '',
      currency: map['currency'] ?? '',
      walletInfo: map['walletInfo'],
      paymentDetails: map['paymentDetails'],
    );
  }

  OrderPaymentFinancialViewEntity toEntity() {
    return OrderPaymentFinancialViewEntity(
      clientTotal: clientTotal,
      paymentStatus: paymentStatus,
      currency: currency,
      walletInfo: walletInfo,
      paymentDetails: paymentDetails,
    );
  }
}
