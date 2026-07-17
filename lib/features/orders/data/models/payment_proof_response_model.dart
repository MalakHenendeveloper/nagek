import 'order_model.dart';

class PaymentProofResponseModel {
  final bool success;
  final String message;
  final PaymentProofModel? payment;
  final OrderModel? order;

  PaymentProofResponseModel({
    required this.success,
    required this.message,
    this.payment,
    this.order,
  });

  factory PaymentProofResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};

    return PaymentProofResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      payment: data['payment'] != null
          ? PaymentProofModel.fromJson(data['payment'] as Map?)
          : null,
      order: data['order'] != null
          ? OrderModel.fromJson(data['order'] as Map?)
          : null,
    );
  }
}

class PaymentProofModel {
  final String id;
  final String order;
  final String client;
  final double amount;
  final String paymentMethod;
  final String senderWalletNumber;
  final String? transferReference;
  final String? screenshot;
  final String status;
  final String createdAt;

  PaymentProofModel({
    required this.id,
    required this.order,
    required this.client,
    required this.amount,
    required this.paymentMethod,
    required this.senderWalletNumber,
    this.transferReference,
    this.screenshot,
    required this.status,
    required this.createdAt,
  });

  factory PaymentProofModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return PaymentProofModel(
      id: map['_id'] ?? '',
      order: map['order'] ?? '',
      client: map['client'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      senderWalletNumber: map['senderWalletNumber'] ?? '',
      transferReference: map['transferReference'],
      screenshot: map['screenshot'],
      status: map['status'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
