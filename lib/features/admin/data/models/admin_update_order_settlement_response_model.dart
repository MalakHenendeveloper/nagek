class AdminUpdateOrderSettlementResponseModel {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AdminUpdateOrderSettlementResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AdminUpdateOrderSettlementResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminUpdateOrderSettlementResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
