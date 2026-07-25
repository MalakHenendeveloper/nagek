import '../../domain/entities/delegate_dashboard_entity.dart';

class DelegateDashboardResponseModel {
  final bool success;
  final String message;
  final DelegateDashboardDataModel data;

  DelegateDashboardResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DelegateDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DelegateDashboardResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DelegateDashboardDataModel.fromJson(json['data'])
          : DelegateDashboardDataModel.empty(),
    );
  }

  DelegateDashboardEntity toEntity() {
    return data.toEntity();
  }
}

class DelegateDashboardDataModel {
  final DelegateDashboardSummaryModel summary;
  final List<DelegateEarningHistoryModel> earningHistory;

  DelegateDashboardDataModel({
    required this.summary,
    required this.earningHistory,
  });

  factory DelegateDashboardDataModel.fromJson(Map<String, dynamic> json) {
    final summaryObj = json['summary'] as Map<String, dynamic>? ?? json;
    return DelegateDashboardDataModel(
      summary: DelegateDashboardSummaryModel.fromJson(summaryObj),
      earningHistory: (json['earningHistory'] as List<dynamic>?)
              ?.map((e) => DelegateEarningHistoryModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory DelegateDashboardDataModel.empty() {
    return DelegateDashboardDataModel(
      summary: DelegateDashboardSummaryModel.empty(),
      earningHistory: [],
    );
  }

  DelegateDashboardEntity toEntity() {
    return DelegateDashboardEntity(
      summary: summary.toEntity(),
      earningHistory: earningHistory.map((e) => e.toEntity()).toList(),
    );
  }
}

class DelegateDashboardSummaryModel {
  final double totalEarnings;
  final int totalTripsCount;
  final int pickupTripsCount;
  final int deliveryTripsCount;

  DelegateDashboardSummaryModel({
    required this.totalEarnings,
    required this.totalTripsCount,
    required this.pickupTripsCount,
    required this.deliveryTripsCount,
  });

  factory DelegateDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DelegateDashboardSummaryModel(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalTripsCount: (json['totalTripsCount'] as num?)?.toInt() ?? 0,
      pickupTripsCount: (json['pickupTripsCount'] as num?)?.toInt() ?? 0,
      deliveryTripsCount: (json['deliveryTripsCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory DelegateDashboardSummaryModel.empty() {
    return DelegateDashboardSummaryModel(
      totalEarnings: 0.0,
      totalTripsCount: 0,
      pickupTripsCount: 0,
      deliveryTripsCount: 0,
    );
  }

  DelegateDashboardSummaryEntity toEntity() {
    return DelegateDashboardSummaryEntity(
      totalEarnings: totalEarnings,
      totalTripsCount: totalTripsCount,
      pickupTripsCount: pickupTripsCount,
      deliveryTripsCount: deliveryTripsCount,
    );
  }
}

class DelegateEarningHistoryModel {
  final String orderId;
  final String orderNumber;
  final String clientName;
  final String tripType;
  final String label;
  final double amount;
  final String completedAt;

  DelegateEarningHistoryModel({
    required this.orderId,
    required this.orderNumber,
    required this.clientName,
    required this.tripType,
    required this.label,
    required this.amount,
    required this.completedAt,
  });

  factory DelegateEarningHistoryModel.fromJson(Map<String, dynamic> json) {
    return DelegateEarningHistoryModel(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      clientName: json['clientName'] ?? '',
      tripType: json['tripType'] ?? '',
      label: json['label'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      completedAt: json['completedAt'] ?? '',
    );
  }

  DelegateEarningHistoryEntity toEntity() {
    return DelegateEarningHistoryEntity(
      orderId: orderId,
      orderNumber: orderNumber,
      clientName: clientName,
      tripType: tripType,
      label: label,
      amount: amount,
      completedAt: completedAt,

   );
  }
}
