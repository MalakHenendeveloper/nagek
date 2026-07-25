import '../../domain/entities/center_settlement_entity.dart';

class CenterSettlementsResponseModel {
  final bool success;
  final String message;
  final CenterSettlementsDataModel data;
  final CenterSettlementsPaginationModel pagination;

  CenterSettlementsResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory CenterSettlementsResponseModel.fromJson(Map<String, dynamic> json) {
    return CenterSettlementsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CenterSettlementsDataModel.fromJson(json['data'])
          : CenterSettlementsDataModel.empty(),
      pagination: json['pagination'] != null
          ? CenterSettlementsPaginationModel.fromJson(json['pagination'])
          : CenterSettlementsPaginationModel.empty(),
    );
  }

  CenterSettlementsResultEntity toEntity() {
    return CenterSettlementsResultEntity(
      settlements: data.settlements.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class CenterSettlementsDataModel {
  final List<CenterSettlementModel> settlements;

  CenterSettlementsDataModel({required this.settlements});

  factory CenterSettlementsDataModel.fromJson(Map<String, dynamic> json) {
    return CenterSettlementsDataModel(
      settlements: (json['settlements'] as List<dynamic>?)
              ?.map((e) => CenterSettlementModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory CenterSettlementsDataModel.empty() {
    return CenterSettlementsDataModel(settlements: []);
  }
}

class CenterSettlementModel {
  final String id;
  final String? paymentMethod;
  final CenterSettlementOrderModel? order;
  final String recipient;
  final String recipientName;
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

  CenterSettlementModel({
    required this.id,
    this.paymentMethod,
    this.order,
    required this.recipient,
    required this.recipientName,
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

  factory CenterSettlementModel.fromJson(Map<String, dynamic> json) {
    String rId = '';
    String rName = json['recipientName'] ?? '';
    if (json['recipient'] != null) {
      if (json['recipient'] is Map<String, dynamic>) {
        final rMap = json['recipient'] as Map<String, dynamic>;
        rId = rMap['_id'] ?? rMap['id'] ?? '';
        if (rName.isEmpty) rName = rMap['name'] ?? '';
      } else if (json['recipient'] is String) {
        rId = json['recipient'];
      }
    }

    return CenterSettlementModel(
      id: json['id'] ?? json['_id'] ?? '',
      paymentMethod: json['paymentMethod'] as String?,
      order: json['order'] != null && json['order'] is Map<String, dynamic>
          ? CenterSettlementOrderModel.fromJson(json['order'])
          : null,
      recipient: rId,
      recipientName: rName,
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

  CenterSettlementEntity toEntity() {
    return CenterSettlementEntity(
      id: id,
      paymentMethod: paymentMethod,
      order: order?.toEntity(),
      recipient: recipient,
      recipientName: recipientName,
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

class CenterSettlementOrderModel {
  final String id;
  final String status;
  final String orderNumber;

  CenterSettlementOrderModel({
    required this.id,
    required this.status,
    required this.orderNumber,
  });

  factory CenterSettlementOrderModel.fromJson(Map<String, dynamic> json) {
    return CenterSettlementOrderModel(
      id: json['id'] ?? json['_id'] ?? '',
      status: json['status'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
    );
  }

  CenterSettlementOrderEntity toEntity() {
    return CenterSettlementOrderEntity(
      id: id,
      status: status,
      orderNumber: orderNumber,
    );
  }
}

class CenterSettlementsPaginationModel {
  final int total;
  final int page;
  final int limit;
  final int pages;

  CenterSettlementsPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory CenterSettlementsPaginationModel.fromJson(Map<String, dynamic> json) {
    return CenterSettlementsPaginationModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
    );
  }

  factory CenterSettlementsPaginationModel.empty() {
    return CenterSettlementsPaginationModel(
      total: 0,
      page: 1,
      limit: 10,
      pages: 1,
    );
  }

  CenterSettlementsPaginationEntity toEntity() {
    return CenterSettlementsPaginationEntity(
      total: total,
      page: page,
      limit: limit,
      pages: pages,
    );
  }
}
