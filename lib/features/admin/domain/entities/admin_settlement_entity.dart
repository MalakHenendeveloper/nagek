class AdminSettlementsResultEntity {
  final List<AdminSettlementEntity> settlements;
  final AdminSettlementsPaginationEntity pagination;

  AdminSettlementsResultEntity({
    required this.settlements,
    required this.pagination,
  });
}

class AdminSettlementEntity {
  final String id;
  final String? paymentMethod;
  final AdminSettlementOrderEntity? order;
  final String recipientId;
  final String recipientName;
  final String recipientEmail;
  final String recipientType;
  final String orderNumber;
  final double amount;
  final String stage;
  final String paymentStatus;
  final String status;
  final String? paidAt;
  final String? paidBy;
  final String notes;
  final String createdAt;
  final String updatedAt;

  AdminSettlementEntity({
    required this.id,
    this.paymentMethod,
    this.order,
    required this.recipientId,
    required this.recipientName,
    required this.recipientEmail,
    required this.recipientType,
    required this.orderNumber,
    required this.amount,
    required this.stage,
    required this.paymentStatus,
    required this.status,
    this.paidAt,
    this.paidBy,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}

class AdminSettlementOrderEntity {
  final String id;
  final String status;
  final String orderNumber;

  AdminSettlementOrderEntity({
    required this.id,
    required this.status,
    required this.orderNumber,
  });
}

class AdminSettlementsPaginationEntity {
  final int total;
  final int page;
  final int limit;
  final int pages;

  AdminSettlementsPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
}
