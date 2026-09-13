import '../../domain/entities/admin_settlements_report_entity.dart';

class AdminSettlementsReportResponseModel {
  final bool success;
  final String message;
  final AdminSettlementsReportDataModel data;

  AdminSettlementsReportResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdminSettlementsReportResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsReportResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AdminSettlementsReportDataModel.fromJson(json['data'])
          : AdminSettlementsReportDataModel.empty(),
    );
  }

  AdminSettlementsReportEntity toEntity() => data.toEntity();
}

class AdminSettlementsReportDataModel {
  final AdminSettlementsSummaryReportModel summary;
  final List<AdminCenterSettlementReportModel> centers;
  final List<AdminDelegateSettlementReportModel> delegates;

  AdminSettlementsReportDataModel({
    required this.summary,
    required this.centers,
    required this.delegates,
  });

  factory AdminSettlementsReportDataModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsReportDataModel(
      summary: json['summary'] != null
          ? AdminSettlementsSummaryReportModel.fromJson(json['summary'])
          : AdminSettlementsSummaryReportModel.empty(),
      centers: (json['centers'] as List<dynamic>?)
              ?.map((e) => AdminCenterSettlementReportModel.fromJson(e))
              .toList() ??
          [],
      delegates: (json['delegates'] as List<dynamic>?)
              ?.map((e) => AdminDelegateSettlementReportModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory AdminSettlementsReportDataModel.empty() {
    return AdminSettlementsReportDataModel(
      summary: AdminSettlementsSummaryReportModel.empty(),
      centers: [],
      delegates: [],
    );
  }

  AdminSettlementsReportEntity toEntity() {
    return AdminSettlementsReportEntity(
      summary: summary.toEntity(),
      centers: centers.map((e) => e.toEntity()).toList(),
      delegates: delegates.map((e) => e.toEntity()).toList(),
    );
  }
}

class AdminSettlementsSummaryReportModel {
  final double centersTotalDue;
  final double centersTotalSettled;
  final double delegatesTotalDue;
  final double delegatesTotalSettled;
  final double centersRemaining;
  final double delegatesRemaining;

  AdminSettlementsSummaryReportModel({
    required this.centersTotalDue,
    required this.centersTotalSettled,
    required this.delegatesTotalDue,
    required this.delegatesTotalSettled,
    required this.centersRemaining,
    required this.delegatesRemaining,
  });

  factory AdminSettlementsSummaryReportModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsSummaryReportModel(
      centersTotalDue: (json['centersTotalDue'] as num?)?.toDouble() ?? 0.0,
      centersTotalSettled: (json['centersTotalSettled'] as num?)?.toDouble() ?? 0.0,
      delegatesTotalDue: (json['delegatesTotalDue'] as num?)?.toDouble() ?? 0.0,
      delegatesTotalSettled: (json['delegatesTotalSettled'] as num?)?.toDouble() ?? 0.0,
      centersRemaining: (json['centersRemaining'] as num?)?.toDouble() ?? 0.0,
      delegatesRemaining: (json['delegatesRemaining'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory AdminSettlementsSummaryReportModel.empty() {
    return AdminSettlementsSummaryReportModel(
      centersTotalDue: 0.0,
      centersTotalSettled: 0.0,
      delegatesTotalDue: 0.0,
      delegatesTotalSettled: 0.0,
      centersRemaining: 0.0,
      delegatesRemaining: 0.0,
    );
  }

  AdminSettlementsSummaryReportEntity toEntity() {
    return AdminSettlementsSummaryReportEntity(
      centersTotalDue: centersTotalDue,
      centersTotalSettled: centersTotalSettled,
      delegatesTotalDue: delegatesTotalDue,
      delegatesTotalSettled: delegatesTotalSettled,
      centersRemaining: centersRemaining,
      delegatesRemaining: delegatesRemaining,
    );
  }
}

class AdminCenterSettlementReportModel {
  final String centerId;
  final String centerName;
  final String phone;
  final int totalOrders;
  final double totalDue;
  final double totalSettled;
  final double remaining;
  final List<AdminCenterOrderReportModel> orders;

  AdminCenterSettlementReportModel({
    required this.centerId,
    required this.centerName,
    required this.phone,
    required this.totalOrders,
    required this.totalDue,
    required this.totalSettled,
    required this.remaining,
    required this.orders,
  });

  factory AdminCenterSettlementReportModel.fromJson(Map<String, dynamic> json) {
    return AdminCenterSettlementReportModel(
      centerId: json['centerId']?.toString() ?? '',
      centerName: json['centerName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0.0,
      totalSettled: (json['totalSettled'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => AdminCenterOrderReportModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  AdminCenterSettlementReportEntity toEntity() {
    return AdminCenterSettlementReportEntity(
      centerId: centerId,
      centerName: centerName,
      phone: phone,
      totalOrders: totalOrders,
      totalDue: totalDue,
      totalSettled: totalSettled,
      remaining: remaining,
      orders: orders.map((e) => e.toEntity()).toList(),
    );
  }
}

class AdminCenterOrderReportModel {
  final String orderId;
  final String orderNumber;
  final double amount;
  final bool settled;
  final String? settledAt;
  final String? recordedAt;

  AdminCenterOrderReportModel({
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.settled,
    this.settledAt,
    this.recordedAt,
  });

  factory AdminCenterOrderReportModel.fromJson(Map<String, dynamic> json) {
    return AdminCenterOrderReportModel(
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      settled: json['settled'] == true,
      settledAt: json['settledAt']?.toString(),
      recordedAt: json['recordedAt']?.toString(),
    );
  }

  AdminCenterOrderReportEntity toEntity() {
    return AdminCenterOrderReportEntity(
      orderId: orderId,
      orderNumber: orderNumber,
      amount: amount,
      settled: settled,
      settledAt: settledAt,
      recordedAt: recordedAt,
    );
  }
}

class AdminDelegateSettlementReportModel {
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
  final List<AdminDelegateTripReportModel> trips;

  AdminDelegateSettlementReportModel({
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

  factory AdminDelegateSettlementReportModel.fromJson(Map<String, dynamic> json) {
    return AdminDelegateSettlementReportModel(
      delegateId: json['delegateId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      pickupDue: (json['pickupDue'] as num?)?.toDouble() ?? 0.0,
      deliveryDue: (json['deliveryDue'] as num?)?.toDouble() ?? 0.0,
      totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0.0,
      totalSettled: (json['totalSettled'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      pickupTrips: (json['pickupTrips'] as num?)?.toInt() ?? 0,
      deliveryTrips: (json['deliveryTrips'] as num?)?.toInt() ?? 0,
      trips: (json['trips'] as List<dynamic>?)
              ?.map((e) => AdminDelegateTripReportModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  AdminDelegateSettlementReportEntity toEntity() {
    return AdminDelegateSettlementReportEntity(
      delegateId: delegateId,
      name: name,
      phone: phone,
      pickupDue: pickupDue,
      deliveryDue: deliveryDue,
      totalDue: totalDue,
      totalSettled: totalSettled,
      remaining: remaining,
      pickupTrips: pickupTrips,
      deliveryTrips: deliveryTrips,
      trips: trips.map((e) => e.toEntity()).toList(),
    );
  }
}

class AdminDelegateTripReportModel {
  final String orderId;
  final String orderNumber;
  final String tripType;
  final double amount;
  final bool settled;
  final String? settledAt;
  final String? recordedAt;

  AdminDelegateTripReportModel({
    required this.orderId,
    required this.orderNumber,
    required this.tripType,
    required this.amount,
    required this.settled,
    this.settledAt,
    this.recordedAt,
  });

  factory AdminDelegateTripReportModel.fromJson(Map<String, dynamic> json) {
    return AdminDelegateTripReportModel(
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      tripType: json['tripType']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      settled: json['settled'] == true,
      settledAt: json['settledAt']?.toString(),
      recordedAt: json['recordedAt']?.toString(),
    );
  }

  AdminDelegateTripReportEntity toEntity() {
    return AdminDelegateTripReportEntity(
      orderId: orderId,
      orderNumber: orderNumber,
      tripType: tripType,
      amount: amount,
      settled: settled,
      settledAt: settledAt,
      recordedAt: recordedAt,
    );
  }
}
