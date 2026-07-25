class DelegateDashboardEntity {
  final DelegateDashboardSummaryEntity summary;
  final List<DelegateEarningHistoryEntity> earningHistory;

  DelegateDashboardEntity({
    required this.summary,
    required this.earningHistory,
  });
}

class DelegateDashboardSummaryEntity {
  final double totalEarnings;
  final int totalTripsCount;
  final int pickupTripsCount;
  final int deliveryTripsCount;

  DelegateDashboardSummaryEntity({
    required this.totalEarnings,
    required this.totalTripsCount,
    required this.pickupTripsCount,
    required this.deliveryTripsCount,
  });
}

class DelegateEarningHistoryEntity {
  final String orderId;
  final String orderNumber;
  final String clientName;
  final String tripType;
  final String label;
  final double amount;
  final String completedAt;

  DelegateEarningHistoryEntity({
    required this.orderId,
    required this.orderNumber,
    required this.clientName,
    required this.tripType,
    required this.label,
    required this.amount,
    required this.completedAt,
  });
}
