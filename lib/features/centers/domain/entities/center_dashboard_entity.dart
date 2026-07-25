class CenterDashboardEntity {
  final CenterDashboardSummaryEntity summary;
  final List<CenterRecentSettlementEntity> recentSettlements;
  final List<CenterRecentOrderEntity> recentOrders;

  CenterDashboardEntity({
    required this.summary,
    required this.recentSettlements,
    required this.recentOrders,
  });
}

class CenterDashboardSummaryEntity {
  final double totalRevenue;
  final double pendingRevenue;
  final double paidRevenue;
  final int completedOrdersCount;
  final int currentCenterOrdersCount;

  CenterDashboardSummaryEntity({
    required this.totalRevenue,
    required this.pendingRevenue,
    required this.paidRevenue,
    required this.completedOrdersCount,
    required this.currentCenterOrdersCount,
  });
}

class CenterRecentSettlementEntity {
  final String id;
  final double amount;
  final String stage;
  final String status;
  final String recipientName;
  final String orderNumber;
  final String createdAt;

  CenterRecentSettlementEntity({
    required this.id,
    required this.amount,
    required this.stage,
    required this.status,
    required this.recipientName,
    required this.orderNumber,
    required this.createdAt,
  });
}

class CenterRecentOrderEntity {
  final String id;
  final String orderNumber;
  final String clientName;
  final String status;
  final String createdAt;
  final String? repairCenterName;

  CenterRecentOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.status,
    required this.createdAt,
    this.repairCenterName,
  });
}
