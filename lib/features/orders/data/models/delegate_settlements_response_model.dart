import '../../domain/entities/delegate_settlement_entity.dart';

class DelegateSettlementsResponseModel {
  final bool success;
  final String message;
  final DelegateSettlementsDataModel data;
  final DelegateSettlementsPaginationModel pagination;

  DelegateSettlementsResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory DelegateSettlementsResponseModel.fromJson(Map<String, dynamic> json) {
    return DelegateSettlementsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DelegateSettlementsDataModel.fromJson(json['data'])
          : DelegateSettlementsDataModel.empty(),
      pagination: json['pagination'] != null
          ? DelegateSettlementsPaginationModel.fromJson(json['pagination'])
          : DelegateSettlementsPaginationModel.empty(),
    );
  }

  DelegateSettlementsResultEntity toEntity() {
    return DelegateSettlementsResultEntity(
      settlements: data.settlements.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class DelegateSettlementsDataModel {
  final List<DelegateSettlementModel> settlements;

  DelegateSettlementsDataModel({required this.settlements});

  factory DelegateSettlementsDataModel.fromJson(Map<String, dynamic> json) {
    return DelegateSettlementsDataModel(
      settlements: (json['settlements'] as List<dynamic>?)
              ?.map((e) => DelegateSettlementModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory DelegateSettlementsDataModel.empty() {
    return DelegateSettlementsDataModel(settlements: []);
  }
}

class DelegateSettlementModel {
  final String id;
  final String? paymentMethod;
  final DelegateSettlementOrderModel? order;
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

  DelegateSettlementModel({
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

  factory DelegateSettlementModel.fromJson(Map<String, dynamic> json) {
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

    return DelegateSettlementModel(
      id: json['id'] ?? json['_id'] ?? '',
      paymentMethod: json['paymentMethod'] as String?,
      order: json['order'] != null && json['order'] is Map<String, dynamic>
          ? DelegateSettlementOrderModel.fromJson(json['order'])
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

  DelegateSettlementEntity toEntity() {
    return DelegateSettlementEntity(
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

class DelegateSettlementOrderModel {
  final String id;
  final String status;
  final String orderNumber;

  DelegateSettlementOrderModel({
    required this.id,
    required this.status,
    required this.orderNumber,
  });

  factory DelegateSettlementOrderModel.fromJson(Map<String, dynamic> json) {
    return DelegateSettlementOrderModel(
      id: json['id'] ?? json['_id'] ?? '',
      status: json['status'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
    );
  }

  DelegateSettlementOrderEntity toEntity() {
    return DelegateSettlementOrderEntity(
      id: id,
      status: status,
      orderNumber: orderNumber,
    );
  }
}

class DelegateSettlementsPaginationModel {
  final int total;
  final int page;
  final int limit;
  final int pages;

  DelegateSettlementsPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory DelegateSettlementsPaginationModel.fromJson(Map<String, dynamic> json) {
    return DelegateSettlementsPaginationModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
    );
  }

  factory DelegateSettlementsPaginationModel.empty() {
    return DelegateSettlementsPaginationModel(
      total: 0,
      page: 1,
      limit: 10,
      pages: 1,
    );
  }

  DelegateSettlementsPaginationEntity toEntity() {
    return DelegateSettlementsPaginationEntity(
      total: total,
      page: page,
      limit: limit,
      pages: pages,
    );
  }
}
