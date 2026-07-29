class CenterDashboardEntity {
  final CenterDashboardSummaryEntity summary;
  final List<CenterRecentOrderEntity> recentOrders;

  CenterDashboardEntity({
    required this.summary,
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
