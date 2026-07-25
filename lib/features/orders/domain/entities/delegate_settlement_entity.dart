class DelegateSettlementsResultEntity {
  final List<DelegateSettlementEntity> settlements;
  final DelegateSettlementsPaginationEntity pagination;

  DelegateSettlementsResultEntity({
    required this.settlements,
    required this.pagination,
  });
}

class DelegateSettlementEntity {
  final String id;
  final String? paymentMethod;
  final DelegateSettlementOrderEntity? order;
  final String recipient;
  final String recipientName;
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

  DelegateSettlementEntity({
    required this.id,
    this.paymentMethod,
    this.order,
    required this.recipient,
    required this.recipientName,
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

class DelegateSettlementOrderEntity {
  final String id;
  final String status;
  final String orderNumber;

  DelegateSettlementOrderEntity({
    required this.id,
    required this.status,
    required this.orderNumber,
  });
}

class DelegateSettlementsPaginationEntity {
  final int total;
  final int page;
  final int limit;
  final int pages;

  DelegateSettlementsPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
}
