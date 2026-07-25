import '../../domain/entities/admin_settlements_summary_entity.dart';

class AdminSettlementsSummaryResponseModel {
  final bool success;
  final String message;
  final AdminSettlementsSummaryDataModel data;
  final AdminSettlementsSummaryPaginationModel pagination;

  AdminSettlementsSummaryResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory AdminSettlementsSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsSummaryResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AdminSettlementsSummaryDataModel.fromJson(json['data'])
          : AdminSettlementsSummaryDataModel.empty(),
      pagination: json['pagination'] != null
          ? AdminSettlementsSummaryPaginationModel.fromJson(json['pagination'])
          : AdminSettlementsSummaryPaginationModel.empty(),
    );
  }

  AdminSettlementsSummaryResultEntity toEntity() {
    return AdminSettlementsSummaryResultEntity(
      summaries: data.summaries.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class AdminSettlementsSummaryDataModel {
  final List<AdminSettlementRecipientSummaryModel> summaries;

  AdminSettlementsSummaryDataModel({required this.summaries});

  factory AdminSettlementsSummaryDataModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsSummaryDataModel(
      summaries: (json['summaries'] as List<dynamic>?)
              ?.map((e) => AdminSettlementRecipientSummaryModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory AdminSettlementsSummaryDataModel.empty() {
    return AdminSettlementsSummaryDataModel(summaries: []);
  }
}

class AdminSettlementRecipientSummaryModel {
  final String recipientId;
  final String recipientType;
  final String recipientName;
  final double pendingAmount;
  final double paidAmount;
  final int pendingSettlementsCount;
  final int paidSettlementsCount;
  final double totalEarnings;

  AdminSettlementRecipientSummaryModel({
    required this.recipientId,
    required this.recipientType,
    required this.recipientName,
    required this.pendingAmount,
    required this.paidAmount,
    required this.pendingSettlementsCount,
    required this.paidSettlementsCount,
    required this.totalEarnings,
  });

  factory AdminSettlementRecipientSummaryModel.fromJson(Map<String, dynamic> json) {
    String rName = json['recipientName'] ?? json['name'] ?? '';
    if (rName.isEmpty && json['recipient'] != null && json['recipient'] is Map) {
      rName = json['recipient']['name'] ?? '';
    }

    return AdminSettlementRecipientSummaryModel(
      recipientId: json['recipientId'] ?? json['id'] ?? json['_id'] ?? '',
      recipientType: json['recipientType'] ?? '',
      recipientName: rName,
      pendingAmount: (json['pendingAmount'] ?? json['pendingRevenue'] ?? json['pending'] ?? 0.0 as num).toDouble(),
      paidAmount: (json['paidAmount'] ?? json['paidRevenue'] ?? json['paid'] ?? 0.0 as num).toDouble(),
      pendingSettlementsCount:
          (json['pendingSettlementsCount'] ?? json['pendingCount'] ?? 0 as num).toInt(),
      paidSettlementsCount: (json['paidSettlementsCount'] ?? json['paidCount'] ?? 0 as num).toInt(),
      totalEarnings: (json['totalEarnings'] ?? json['totalRevenue'] ?? json['total'] ?? 0.0 as num).toDouble(),
    );
  }

  AdminSettlementRecipientSummaryEntity toEntity() {
    return AdminSettlementRecipientSummaryEntity(
      recipientId: recipientId,
      recipientType: recipientType,
      recipientName: recipientName,
      pendingAmount: pendingAmount,
      paidAmount: paidAmount,
      pendingSettlementsCount: pendingSettlementsCount,
      paidSettlementsCount: paidSettlementsCount,
      totalEarnings: totalEarnings,
    );
  }
}

class AdminSettlementsSummaryPaginationModel {
  final int total;
  final int page;
  final int limit;
  final int pages;

  AdminSettlementsSummaryPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory AdminSettlementsSummaryPaginationModel.fromJson(Map<String, dynamic> json) {
    return AdminSettlementsSummaryPaginationModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
    );
  }

  factory AdminSettlementsSummaryPaginationModel.empty() {
    return AdminSettlementsSummaryPaginationModel(
      total: 0,
      page: 1,
      limit: 10,
      pages: 1,
    );
  }

  AdminSettlementsSummaryPaginationEntity toEntity() {
    return AdminSettlementsSummaryPaginationEntity(
      total: total,
      page: page,
      limit: limit,
      pages: pages,
    );
  }
}
