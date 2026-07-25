class AdminSettlementsSummaryResultEntity {
  final List<AdminSettlementRecipientSummaryEntity> summaries;
  final AdminSettlementsSummaryPaginationEntity pagination;

  AdminSettlementsSummaryResultEntity({
    required this.summaries,
    required this.pagination,
  });
}

class AdminSettlementRecipientSummaryEntity {
  final String recipientId;
  final String recipientType;
  final String recipientName;
  final double pendingAmount;
  final double paidAmount;
  final int pendingSettlementsCount;
  final int paidSettlementsCount;
  final double totalEarnings;

  AdminSettlementRecipientSummaryEntity({
    required this.recipientId,
    required this.recipientType,
    required this.recipientName,
    required this.pendingAmount,
    required this.paidAmount,
    required this.pendingSettlementsCount,
    required this.paidSettlementsCount,
    required this.totalEarnings,
  });
}

class AdminSettlementsSummaryPaginationEntity {
  final int total;
  final int page;
  final int limit;
  final int pages;

  AdminSettlementsSummaryPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
}
