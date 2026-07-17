import '../../../centers/domain/entities/center_entity.dart';

class AdminPaymentOrderEntity {
  final String id;
  final String status;
  final String orderNumber;

  AdminPaymentOrderEntity({
    required this.id,
    required this.status,
    required this.orderNumber,
  });
}

class AdminPaymentClientEntity {
  final String id;
  final String name;
  final String phone;

  AdminPaymentClientEntity({
    required this.id,
    required this.name,
    required this.phone,
  });
}

class AdminPaymentEntity {
  final String id;
  final AdminPaymentOrderEntity order;
  final AdminPaymentClientEntity client;
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

  AdminPaymentEntity({
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
}

class AdminPaymentsResult {
  final List<AdminPaymentEntity> payments;
  final PaginationEntity pagination;

  AdminPaymentsResult({
    required this.payments,
    required this.pagination,
  });
}
