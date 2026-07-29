import '../../domain/entities/admin_dashboard_entity.dart';

class AdminDashboardResponseModel {
  final bool success;
  final String message;
  final AdminDashboardDataModel data;

  AdminDashboardResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdminDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AdminDashboardDataModel.fromJson(json['data'])
          : AdminDashboardDataModel.empty(),
    );
  }

  AdminDashboardEntity toEntity() {
    return data.toEntity();
  }
}

class AdminDashboardDataModel {
  final AdminOrdersSummaryModel orders;
  final AdminFinancialSummaryModel financial;
  final AdminUsersSummaryModel users;
  final AdminRecentActivityModel recentActivity;

  AdminDashboardDataModel({
    required this.orders,
    required this.financial,
    required this.users,
    required this.recentActivity,
  });

  factory AdminDashboardDataModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardDataModel(
      orders: json['orders'] != null
          ? AdminOrdersSummaryModel.fromJson(json['orders'])
          : AdminOrdersSummaryModel.empty(),
      financial: json['financial'] != null
          ? AdminFinancialSummaryModel.fromJson(json['financial'])
          : AdminFinancialSummaryModel.empty(),
      users: json['users'] != null
          ? AdminUsersSummaryModel.fromJson(json['users'])
          : AdminUsersSummaryModel.empty(),
      recentActivity: json['recentActivity'] != null
          ? AdminRecentActivityModel.fromJson(json['recentActivity'])
          : AdminRecentActivityModel.empty(),
    );
  }

  factory AdminDashboardDataModel.empty() {
    return AdminDashboardDataModel(
      orders: AdminOrdersSummaryModel.empty(),
      financial: AdminFinancialSummaryModel.empty(),
      users: AdminUsersSummaryModel.empty(),
      recentActivity: AdminRecentActivityModel.empty(),
    );
  }

  AdminDashboardEntity toEntity() {
    return AdminDashboardEntity(
      orders: orders.toEntity(),
      financial: financial.toEntity(),
      users: users.toEntity(),
      recentActivity: recentActivity.toEntity(),
    );
  }
}

class AdminOrdersSummaryModel {
  final int totalOrders;
  final int pendingOrders;
  final int inProgressOrders;
  final int completedOrders;
  final int cancelledOrders;

  AdminOrdersSummaryModel({
    required this.totalOrders,
    required this.pendingOrders,
    required this.inProgressOrders,
    required this.completedOrders,
    required this.cancelledOrders,
  });

  factory AdminOrdersSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminOrdersSummaryModel(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      inProgressOrders: (json['inProgressOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
    );
  }

  factory AdminOrdersSummaryModel.empty() {
    return AdminOrdersSummaryModel(
      totalOrders: 0,
      pendingOrders: 0,
      inProgressOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
    );
  }

  AdminOrdersSummaryEntity toEntity() {
    return AdminOrdersSummaryEntity(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      inProgressOrders: inProgressOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
    );
  }
}

class AdminCenterBreakdownModel {
  final String centerId;
  final String centerName;
  final double revenue;
  final int completedOrders;

  AdminCenterBreakdownModel({
    required this.centerId,
    required this.centerName,
    required this.revenue,
    required this.completedOrders,
  });

  factory AdminCenterBreakdownModel.fromJson(Map<String, dynamic> json) {
    return AdminCenterBreakdownModel(
      centerId: json['centerId'] ?? json['id'] ?? '',
      centerName: json['centerName'] ?? json['name'] ?? 'غير معروف',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
    );
  }

  AdminCenterBreakdownEntity toEntity() {
    return AdminCenterBreakdownEntity(
      centerId: centerId,
      centerName: centerName,
      revenue: revenue,
      completedOrders: completedOrders,
    );
  }
}

class AdminDelegateBreakdownModel {
  final String delegateId;
  final String name;
  final double earnings;
  final int completedTrips;

  AdminDelegateBreakdownModel({
    required this.delegateId,
    required this.name,
    required this.earnings,
    required this.completedTrips,
  });

  factory AdminDelegateBreakdownModel.fromJson(Map<String, dynamic> json) {
    return AdminDelegateBreakdownModel(
      delegateId: json['delegateId'] ?? json['id'] ?? '',
      name: json['name'] ?? json['delegateName'] ?? 'مندوب',
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
    );
  }

  AdminDelegateBreakdownEntity toEntity() {
    return AdminDelegateBreakdownEntity(
      delegateId: delegateId,
      name: name,
      earnings: earnings,
      completedTrips: completedTrips,
    );
  }
}

class AdminFinancialSummaryModel {
  final double totalClientPayments;
  final double pendingClientPayments;
  final double confirmedClientPayments;
  final double totalCenterRevenue;
  final double totalDelegateEarnings;
  final double totalAdminCommission;
  final List<AdminCenterBreakdownModel> centerBreakdown;
  final List<AdminDelegateBreakdownModel> delegateBreakdown;

  AdminFinancialSummaryModel({
    required this.totalClientPayments,
    required this.pendingClientPayments,
    required this.confirmedClientPayments,
    required this.totalCenterRevenue,
    required this.totalDelegateEarnings,
    required this.totalAdminCommission,
    required this.centerBreakdown,
    required this.delegateBreakdown,
  });

  factory AdminFinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminFinancialSummaryModel(
      totalClientPayments: (json['totalClientPayments'] as num?)?.toDouble() ?? 0.0,
      pendingClientPayments: (json['pendingClientPayments'] as num?)?.toDouble() ?? 0.0,
      confirmedClientPayments: (json['confirmedClientPayments'] as num?)?.toDouble() ?? 0.0,
      totalCenterRevenue: (json['totalCenterRevenue'] as num?)?.toDouble() ?? 0.0,
      totalDelegateEarnings: (json['totalDelegateEarnings'] as num?)?.toDouble() ?? 0.0,
      totalAdminCommission: (json['totalAdminCommission'] as num?)?.toDouble() ?? 0.0,
      centerBreakdown: (json['centerBreakdown'] as List<dynamic>?)
              ?.map((e) => AdminCenterBreakdownModel.fromJson(e))
              .toList() ??
          [],
      delegateBreakdown: (json['delegateBreakdown'] as List<dynamic>?)
              ?.map((e) => AdminDelegateBreakdownModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory AdminFinancialSummaryModel.empty() {
    return AdminFinancialSummaryModel(
      totalClientPayments: 0.0,
      pendingClientPayments: 0.0,
      confirmedClientPayments: 0.0,
      totalCenterRevenue: 0.0,
      totalDelegateEarnings: 0.0,
      totalAdminCommission: 0.0,
      centerBreakdown: [],
      delegateBreakdown: [],
    );
  }

  AdminFinancialSummaryEntity toEntity() {
    return AdminFinancialSummaryEntity(
      totalClientPayments: totalClientPayments,
      pendingClientPayments: pendingClientPayments,
      confirmedClientPayments: confirmedClientPayments,
      totalCenterRevenue: totalCenterRevenue,
      totalDelegateEarnings: totalDelegateEarnings,
      totalAdminCommission: totalAdminCommission,
      centerBreakdown: centerBreakdown.map((e) => e.toEntity()).toList(),
      delegateBreakdown: delegateBreakdown.map((e) => e.toEntity()).toList(),
    );
  }
}

class AdminUsersSummaryModel {
  final int totalClients;
  final int totalDelegates;
  final int totalCenters;

  AdminUsersSummaryModel({
    required this.totalClients,
    required this.totalDelegates,
    required this.totalCenters,
  });

  factory AdminUsersSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminUsersSummaryModel(
      totalClients: (json['totalClients'] as num?)?.toInt() ?? 0,
      totalDelegates: (json['totalDelegates'] as num?)?.toInt() ?? 0,
      totalCenters: (json['totalCenters'] as num?)?.toInt() ?? 0,
    );
  }

  factory AdminUsersSummaryModel.empty() {
    return AdminUsersSummaryModel(
      totalClients: 0,
      totalDelegates: 0,
      totalCenters: 0,
    );
  }

  AdminUsersSummaryEntity toEntity() {
    return AdminUsersSummaryEntity(
      totalClients: totalClients,
      totalDelegates: totalDelegates,
      totalCenters: totalCenters,
    );
  }
}

class AdminRecentActivityModel {
  final List<AdminRecentOrderModel> recentOrders;

  AdminRecentActivityModel({
    required this.recentOrders,
  });

  factory AdminRecentActivityModel.fromJson(Map<String, dynamic> json) {
    return AdminRecentActivityModel(
      recentOrders: (json['recentOrders'] as List<dynamic>?)
              ?.map((e) => AdminRecentOrderModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory AdminRecentActivityModel.empty() {
    return AdminRecentActivityModel(
      recentOrders: [],
    );
  }

  AdminRecentActivityEntity toEntity() {
    return AdminRecentActivityEntity(
      recentOrders: recentOrders.map((e) => e.toEntity()).toList(),
    );
  }
}

class AdminRecentOrderModel {
  final String id;
  final String orderNumber;
  final String clientName;
  final String status;
  final String createdAt;
  final String? repairCenterName;

  AdminRecentOrderModel({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.status,
    required this.createdAt,
    this.repairCenterName,
  });

  factory AdminRecentOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminRecentOrderModel(
      id: json['id'] ?? json['_id'] ?? json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      clientName: json['clientName'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      repairCenterName: json['repairCenterName'] as String?,
    );
  }

  AdminRecentOrderEntity toEntity() {
    return AdminRecentOrderEntity(
      id: id,
      orderNumber: orderNumber,
      clientName: clientName,
      status: status,
      createdAt: createdAt,
      repairCenterName: repairCenterName,
    );
  }
}
