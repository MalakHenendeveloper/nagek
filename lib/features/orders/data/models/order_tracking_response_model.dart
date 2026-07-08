import '../../domain/entities/order_entity.dart';
import 'order_model.dart';

class OrderTrackingResponseModel {
  final bool success;
  final String message;
  final OrderTrackingModel? tracking;

  OrderTrackingResponseModel({
    required this.success,
    required this.message,
    this.tracking,
  });

  factory OrderTrackingResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    
    return OrderTrackingResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      tracking: map['data'] != null ? OrderTrackingModel.fromJson(data) : null,
    );
  }
}

class OrderTrackingModel {
  final String orderNumber;
  final String status;
  final List<StatusHistoryModel> statusHistory;

  OrderTrackingModel({
    required this.orderNumber,
    required this.status,
    required this.statusHistory,
  });

  factory OrderTrackingModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final historyList = map['statusHistory'] as List<dynamic>? ?? [];
    return OrderTrackingModel(
      orderNumber: map['orderNumber'] ?? '',
      status: map['status'] ?? '',
      statusHistory: historyList.map((e) => StatusHistoryModel.fromJson(e as Map?)).toList(),
    );
  }

  OrderTrackingEntity toEntity() {
    return OrderTrackingEntity(
      orderNumber: orderNumber,
      status: status,
      statusHistory: statusHistory.map((m) => m.toEntity()).toList(),
    );
  }
}
