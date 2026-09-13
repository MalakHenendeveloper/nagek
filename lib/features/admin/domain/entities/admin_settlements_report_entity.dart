class AdminSettlementsReportEntity {
  final AdminSettlementsSummaryReportEntity summary;
  final List<AdminCenterSettlementReportEntity> centers;
  final List<AdminDelegateSettlementReportEntity> delegates;

  const AdminSettlementsReportEntity({
    required this.summary,
    required this.centers,
    required this.delegates,
  });
}

class AdminSettlementsSummaryReportEntity {
  final double centersTotalDue;
  final double centersTotalSettled;
  final double delegatesTotalDue;
  final double delegatesTotalSettled;
  final double centersRemaining;
  final double delegatesRemaining;

  const AdminSettlementsSummaryReportEntity({
    required this.centersTotalDue,
    required this.centersTotalSettled,
    required this.delegatesTotalDue,
    required this.delegatesTotalSettled,
    required this.centersRemaining,
    required this.delegatesRemaining,
  });

  double get totalDue => centersTotalDue + delegatesTotalDue;
  double get totalSettled => centersTotalSettled + delegatesTotalSettled;
  double get totalRemaining => centersRemaining + delegatesRemaining;
}

class AdminCenterSettlementReportEntity {
  final String centerId;
  final String centerName;
  final String phone;
  final int totalOrders;
  final double totalDue;
  final double totalSettled;
  final double remaining;
  final List<AdminCenterOrderReportEntity> orders;

  const AdminCenterSettlementReportEntity({
    required this.centerId,
    required this.centerName,
    required this.phone,
    required this.totalOrders,
    required this.totalDue,
    required this.totalSettled,
    required this.remaining,
    required this.orders,
  });
}

class AdminCenterOrderReportEntity {
  final String orderId;
  final String orderNumber;
  final double amount;
  final bool settled;
  final String? settledAt;
  final String? recordedAt;

  const AdminCenterOrderReportEntity({
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.settled,
    this.settledAt,
    this.recordedAt,
  });
}

class AdminDelegateSettlementReportEntity {
  final String delegateId;
  final String name;
  final String phone;
  final double pickupDue;
  final double deliveryDue;
  final double totalDue;
  final double totalSettled;
  final double remaining;
  final int pickupTrips;
  final int deliveryTrips;
  final List<AdminDelegateTripReportEntity> trips;

  const AdminDelegateSettlementReportEntity({
    required this.delegateId,
    required this.name,
    required this.phone,
    required this.pickupDue,
    required this.deliveryDue,
    required this.totalDue,
    required this.totalSettled,
    required this.remaining,
    required this.pickupTrips,
    required this.deliveryTrips,
    required this.trips,
  });
}

class AdminDelegateTripReportEntity {
  final String orderId;
  final String orderNumber;
  final String tripType; // pickup or delivery
  final double amount;
  final bool settled;
  final String? settledAt;
  final String? recordedAt;

  const AdminDelegateTripReportEntity({
    required this.orderId,
    required this.orderNumber,
    required this.tripType,
    required this.amount,
    required this.settled,
    this.settledAt,
    this.recordedAt,
  });
}
