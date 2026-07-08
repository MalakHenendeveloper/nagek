import 'order_model.dart';

class CreateOrderResponseModel {
  final bool success;
  final String message;
  final OrderModel? order;

  CreateOrderResponseModel({
    required this.success,
    required this.message,
    this.order,
  });

  factory CreateOrderResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    final orderJson = data['order'] as Map?;
    
    return CreateOrderResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      order: orderJson != null ? OrderModel.fromJson(orderJson) : null,
    );
  }
}
