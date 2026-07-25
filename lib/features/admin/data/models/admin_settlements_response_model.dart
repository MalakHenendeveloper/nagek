import '../../domain/entities/admin_settlement_entity.dart';

class AdminSettlementsResponseModel {
  final bool success;
  final String message;
  final AdminSettlementsDataModel data;
  final AdminSettlementsPaginationModel pagination;

  AdminSettlementsResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory AdminSettlementsResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AdminSettlementsDataModel.fromJson(json['data'])
          : AdminSettlementsDataModel.empty(),
      pagination: json['pagination'] != null
          ? AdminSettlementsPaginationModel.fromJson(json['pagination'])
          : AdminSettlementsPaginationModel.empty(),
    );
  }

  AdminSettlementsResultEntity toEntity() {
    return AdminSettlementsResultEntity(
      settlements: data.settlements.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class AdminSettlementsDataModel {
  final List<AdminSettlementModel> settlements;

  AdminSettlementsDataModel({required this.settlements});

  factory AdminSettlementsDataModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsDataModel(
      settlements: (json['settlements'] as List<dynamic>?)
              ?.map((e) => AdminSettlementModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory AdminSettlementsDataModel.empty() {
    return AdminSettlementsDataModel(settlements: []);
  }
}

class AdminSettlementModel {
  final String id;
  final String? paymentMethod;
  final AdminSettlementOrderModel? order;
  final String recipientId;
  final String recipientName;
  final String recipientEmail;
  final String recipientType;
  final String orderNumber;
  final double amount;
  final String stage;
  final String paymentStatus;
  final String status;
  final String? paidAt;
  final String? paidBy;
  final String notes;
  final String createdAt;
  final String updatedAt;

  AdminSettlementModel({
    required this.id,
    this.paymentMethod,
    this.order,
    required this.recipientId,
    required this.recipientName,
    required this.recipientEmail,
    required this.recipientType,
    required this.orderNumber,
    required this.amount,
    required this.stage,
    required this.paymentStatus,
    required this.status,
    this.paidAt,
    this.paidBy,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminSettlementModel.fromJson(Map<String, dynamic> json) {
    String rId = '';
    String rName = json['recipientName'] ?? '';
    String rEmail = '';

    if (json['recipient'] != null) {
      if (json['recipient'] is Map<String, dynamic>) {
        final rMap = json['recipient'] as Map<String, dynamic>;
        rId = rMap['_id'] ?? rMap['id'] ?? '';
        if (rName.isEmpty) rName = rMap['name'] ?? '';
        rEmail = rMap['email'] ?? '';
      } else if (json['recipient'] is String) {
        rId = json['recipient'];
      }
    }

    return AdminSettlementModel(
      id: json['id'] ?? json['_id'] ?? '',
      paymentMethod: json['paymentMethod'] as String?,
      order: json['order'] != null && json['order'] is Map<String, dynamic>
          ? AdminSettlementOrderModel.fromJson(json['order'])
          : null,
      recipientId: rId,
      recipientName: rName,
      recipientEmail: rEmail,
      recipientType: json['recipientType'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      stage: json['stage'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      status: json['status'] ?? '',
      paidAt: json['paidAt'] as String?,
      paidBy: json['paidBy'] as String?,
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  AdminSettlementEntity toEntity() {
    return AdminSettlementEntity(
      id: id,
      paymentMethod: paymentMethod,
      order: order?.toEntity(),
      recipientId: recipientId,
      recipientName: recipientName,
      recipientEmail: recipientEmail,
      recipientType: recipientType,
      orderNumber: orderNumber,
      amount: amount,
      stage: stage,
      paymentStatus: paymentStatus,
      status: status,
      paidAt: paidAt,
      paidBy: paidBy,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AdminSettlementOrderModel {
  final String id;
  final String status;
  final String orderNumber;

  AdminSettlementOrderModel({
    required this.id,
    required this.status,
    required this.orderNumber,
  });

  factory AdminSettlementOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementOrderModel(
      id: json['id'] ?? json['_id'] ?? '',
      status: json['status'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
    );
  }

  AdminSettlementOrderEntity toEntity() {
    return AdminSettlementOrderEntity(
      id: id,
      status: status,
      orderNumber: orderNumber,
    );
  }
}

class AdminSettlementsPaginationModel {
  final int total;
  final int page;
  final int limit;
  final int pages;

  AdminSettlementsPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory AdminSettlementsPaginationModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsPaginationModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
    );
  }

  factory AdminSettlementsPaginationModel.empty() {
    return AdminSettlementsPaginationModel(
      total: 0,
      page: 1,
      limit: 10,
      pages: 1,
    );
  }

  AdminSettlementsPaginationEntity toEntity() {
    return AdminSettlementsPaginationEntity(
      total: total,
      page: page,
      limit: limit,
      pages: pages,
    );
  }
}
