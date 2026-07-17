import '../../../../features/centers/data/models/center_model.dart'; // for PaginationModel
import '../../domain/entities/admin_payment_entity.dart';

class AdminPaymentsResponseModel {
  final bool success;
  final String message;
  final List<AdminPaymentModel> payments;
  final PaginationModel pagination;

  AdminPaymentsResponseModel({
    required this.success,
    required this.message,
    required this.payments,
    required this.pagination,
  });

  factory AdminPaymentsResponseModel.fromJson(Map<dynamic, dynamic> json) {
    final data = json['data'] as Map? ?? {};
    final paymentsList = data['payments'] as List? ?? [];

    return AdminPaymentsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      payments: paymentsList.map((e) => AdminPaymentModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  AdminPaymentsResult toEntity() {
    return AdminPaymentsResult(
      payments: payments.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class AdminPaymentOrderModel {
  final String id;
  final String status;
  final String orderNumber;

  AdminPaymentOrderModel({
    required this.id,
    required this.status,
    required this.orderNumber,
  });

  factory AdminPaymentOrderModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return AdminPaymentOrderModel(
      id: map['_id'] ?? '',
      status: map['status'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
    );
  }

  AdminPaymentOrderEntity toEntity() {
    return AdminPaymentOrderEntity(
      id: id,
      status: status,
      orderNumber: orderNumber,
    );
  }
}

class AdminPaymentClientModel {
  final String id;
  final String name;
  final String phone;

  AdminPaymentClientModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory AdminPaymentClientModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return AdminPaymentClientModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  AdminPaymentClientEntity toEntity() {
    return AdminPaymentClientEntity(
      id: id,
      name: name,
      phone: phone,
    );
  }
}

class AdminPaymentModel {
  final String id;
  final AdminPaymentOrderModel order;
  final AdminPaymentClientModel client;
  final double amount;
  final String paymentMethod;
  final String senderWalletNumber;
  final String? transferReference;
  final String? screenshot;
  final String status;
  final String? reviewedBy;
  final String? reviewedAt;
  final String? rejectionReason;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  AdminPaymentModel({
    required this.id,
    required this.order,
    required this.client,
    required this.amount,
    required this.paymentMethod,
    required this.senderWalletNumber,
    this.transferReference,
    this.screenshot,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminPaymentModel.fromJson(Map<dynamic, dynamic> json) {
    return AdminPaymentModel(
      id: json['_id'] ?? '',
      order: AdminPaymentOrderModel.fromJson(json['order'] as Map?),
      client: AdminPaymentClientModel.fromJson(json['client'] as Map?),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      senderWalletNumber: json['senderWalletNumber'] ?? '',
      transferReference: json['transferReference'],
      screenshot: json['screenshot'],
      status: json['status'] ?? '',
      reviewedBy: json['reviewedBy'],
      reviewedAt: json['reviewedAt'],
      rejectionReason: json['rejectionReason'],
      notes: json['notes'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  AdminPaymentEntity toEntity() {
    return AdminPaymentEntity(
      id: id,
      order: order.toEntity(),
      client: client.toEntity(),
      amount: amount,
      paymentMethod: paymentMethod,
      senderWalletNumber: senderWalletNumber,
      transferReference: transferReference,
      screenshot: screenshot,
      status: status,
      reviewedBy: reviewedBy,
      reviewedAt: reviewedAt,
      rejectionReason: rejectionReason,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AdminReviewPaymentResponseModel {
  final bool success;
  final String message;

  AdminReviewPaymentResponseModel({
    required this.success,
    required this.message,
  });

  factory AdminReviewPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminReviewPaymentResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
