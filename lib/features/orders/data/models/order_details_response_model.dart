import 'order_model.dart';


class OrderDetailsResponseModel {
  final bool success;
  final String message;
  final OrderModel? order;

  OrderDetailsResponseModel({
    required this.success,
    required this.message,
    this.order,
  });

  factory OrderDetailsResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    final orderJson = data['order'] as Map?;
    
    return OrderDetailsResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      order: orderJson != null ? OrderModel.fromJson(orderJson) : null,
    );
  }
}
