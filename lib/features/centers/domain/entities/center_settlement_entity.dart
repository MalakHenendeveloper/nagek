class CenterSettlementsResultEntity {
  final List<CenterSettlementEntity> settlements;
  final CenterSettlementsPaginationEntity pagination;

  CenterSettlementsResultEntity({
    required this.settlements,
    required this.pagination,
  });
}

class CenterSettlementEntity {
  final String id;
  final String? paymentMethod;
  final CenterSettlementOrderEntity? order;
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

  CenterSettlementEntity({
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

class CenterSettlementOrderEntity {
  final String id;
  final String status;
  final String orderNumber;

  CenterSettlementOrderEntity({
    required this.id,
    required this.status,
    required this.orderNumber,
  });
}

class CenterSettlementsPaginationEntity {
  final int total;
  final int page;
  final int limit;
  final int pages;

  CenterSettlementsPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
}
