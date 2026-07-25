class AdminDashboardEntity {
  final AdminOrdersSummaryEntity orders;
  final AdminFinancialSummaryEntity financial;
  final AdminUsersSummaryEntity users;
  final AdminRecentActivityEntity recentActivity;

  AdminDashboardEntity({
    required this.orders,
    required this.financial,
    required this.users,
    required this.recentActivity,
  });
}

class AdminOrdersSummaryEntity {
  final int totalOrders;
  final int pendingOrders;
  final int inProgressOrders;
  final int completedOrders;
  final int cancelledOrders;

  AdminOrdersSummaryEntity({
    required this.totalOrders,
    required this.pendingOrders,
    required this.inProgressOrders,
    required this.completedOrders,
    required this.cancelledOrders,
  });
}

class AdminCenterBreakdownEntity {
  final String centerId;
  final String centerName;
  final double revenue;
  final int completedOrders;

  AdminCenterBreakdownEntity({
    required this.centerId,
    required this.centerName,
    required this.revenue,
    required this.completedOrders,
  });
}

class AdminDelegateBreakdownEntity {
  final String delegateId;
  final String name;
  final double earnings;
  final int completedTrips;

  AdminDelegateBreakdownEntity({
    required this.delegateId,
    required this.name,
    required this.earnings,
    required this.completedTrips,
  });
}

class AdminFinancialSummaryEntity {
  final double totalClientPayments;
  final double pendingClientPayments;
  final double confirmedClientPayments;
  final double totalCenterRevenue;
  final double totalDelegateEarnings;
  final double totalAdminCommission;
  final double pendingSettlementsAmount;
  final double paidSettlementsAmount;
  final List<AdminCenterBreakdownEntity> centerBreakdown;
  final List<AdminDelegateBreakdownEntity> delegateBreakdown;

  AdminFinancialSummaryEntity({
    required this.totalClientPayments,
    required this.pendingClientPayments,
    required this.confirmedClientPayments,
    required this.totalCenterRevenue,
    required this.totalDelegateEarnings,
    required this.totalAdminCommission,
    required this.pendingSettlementsAmount,
    required this.paidSettlementsAmount,
    required this.centerBreakdown,
    required this.delegateBreakdown,
  });
}

class AdminUsersSummaryEntity {
  final int totalClients;
  final int totalDelegates;
  final int totalCenters;

  AdminUsersSummaryEntity({
    required this.totalClients,
    required this.totalDelegates,
    required this.totalCenters,
  });
}

class AdminRecentActivityEntity {
  final List<AdminRecentOrderEntity> recentOrders;
  final List<AdminRecentSettlementEntity> recentSettlements;

  AdminRecentActivityEntity({
    required this.recentOrders,
    required this.recentSettlements,
  });
}

class AdminRecentOrderEntity {
  final String id;
  final String orderNumber;
  final String clientName;
  final String status;
  final String createdAt;
  final String? repairCenterName;

  AdminRecentOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.status,
    required this.createdAt,
    this.repairCenterName,
  });
}

class AdminRecentSettlementEntity {
  final String id;
  final double amount;
  final String stage;
  final String status;
  final String recipientName;
  final String orderNumber;
  final String createdAt;

  AdminRecentSettlementEntity({
    required this.id,
    required this.amount,
    required this.stage,
    required this.status,
    required this.recipientName,
    required this.orderNumber,
    required this.createdAt,
  });
}
