import '../../domain/entities/center_dashboard_entity.dart';

class CenterDashboardResponseModel {
  final bool success;
  final String message;
  final CenterDashboardDataModel data;

  CenterDashboardResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CenterDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return CenterDashboardResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CenterDashboardDataModel.fromJson(json['data'])
          : CenterDashboardDataModel.empty(),
    );
  }

  CenterDashboardEntity toEntity() {
    return data.toEntity();
  }
}

class CenterDashboardDataModel {
  final CenterDashboardSummaryModel summary;
  final List<CenterRecentOrderModel> recentOrders;

  CenterDashboardDataModel({
    required this.summary,
    required this.recentOrders,
  });

  factory CenterDashboardDataModel.fromJson(Map<String, dynamic> json) {
    final summaryObj = json['summary'] as Map<String, dynamic>? ?? json;
    return CenterDashboardDataModel(
      summary: CenterDashboardSummaryModel.fromJson(summaryObj),
      recentOrders: (json['recentOrders'] as List<dynamic>?)
              ?.map((e) => CenterRecentOrderModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory CenterDashboardDataModel.empty() {
    return CenterDashboardDataModel(
      summary: CenterDashboardSummaryModel.empty(),
      recentOrders: [],
    );
  }

  CenterDashboardEntity toEntity() {
    return CenterDashboardEntity(
      summary: summary.toEntity(),
      recentOrders: recentOrders.map((e) => e.toEntity()).toList(),
    );
  }
}

class CenterDashboardSummaryModel {
  final double totalRevenue;
  final double pendingRevenue;
  final double paidRevenue;
  final int completedOrdersCount;
  final int currentCenterOrdersCount;

  CenterDashboardSummaryModel({
    required this.totalRevenue,
    required this.pendingRevenue,
    required this.paidRevenue,
    required this.completedOrdersCount,
    required this.currentCenterOrdersCount,
  });

  factory CenterDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return CenterDashboardSummaryModel(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      pendingRevenue: (json['pendingRevenue'] as num?)?.toDouble() ?? 0.0,
      paidRevenue: (json['paidRevenue'] as num?)?.toDouble() ?? 0.0,
      completedOrdersCount: (json['completedOrdersCount'] as num?)?.toInt() ?? 0,
      currentCenterOrdersCount:
          (json['currentCenterOrdersCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory CenterDashboardSummaryModel.empty() {
    return CenterDashboardSummaryModel(
      totalRevenue: 0.0,
      pendingRevenue: 0.0,
      paidRevenue: 0.0,
      completedOrdersCount: 0,
      currentCenterOrdersCount: 0,
    );
  }

  CenterDashboardSummaryEntity toEntity() {
    return CenterDashboardSummaryEntity(
      totalRevenue: totalRevenue,
      pendingRevenue: pendingRevenue,
      paidRevenue: paidRevenue,
      completedOrdersCount: completedOrdersCount,
      currentCenterOrdersCount: currentCenterOrdersCount,
    );
  }
}

class CenterRecentOrderModel {
  final String id;
  final String orderNumber;
  final String clientName;
  final String status;
  final String createdAt;
  final String? repairCenterName;

  CenterRecentOrderModel({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.status,
    required this.createdAt,
    this.repairCenterName,
  });

  factory CenterRecentOrderModel.fromJson(Map<String, dynamic> json) {
    return CenterRecentOrderModel(
      id: json['id'] ?? json['_id'] ?? json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      clientName: json['clientName'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      repairCenterName: json['repairCenterName'] as String?,
    );
  }

  CenterRecentOrderEntity toEntity() {
    return CenterRecentOrderEntity(
      id: id,
      orderNumber: orderNumber,
      clientName: clientName,
      status: status,
      createdAt: createdAt,
      repairCenterName: repairCenterName,
    );
  }
}
