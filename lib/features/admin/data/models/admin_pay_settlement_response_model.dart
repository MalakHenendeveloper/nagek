import 'admin_settlements_response_model.dart';
import '../../domain/entities/admin_settlement_entity.dart';

class AdminPaySettlementResponseModel {
  final bool success;
  final String message;
  final AdminSettlementModel? settlement;

  AdminPaySettlementResponseModel({
    required this.success,
    required this.message,
    this.settlement,
  });

  factory AdminPaySettlementResponseModel.fromJson(Map<String, dynamic> json) {
    AdminSettlementModel? s;
    if (json['data'] != null && json['data']['settlement'] != null) {
      s = AdminSettlementModel.fromJson(json['data']['settlement']);
    }
    return AdminPaySettlementResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      settlement: s,
    );
  }

  AdminSettlementEntity? toEntity() {
    return settlement?.toEntity();
  }
}
