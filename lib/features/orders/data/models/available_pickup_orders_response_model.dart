import 'order_model.dart';

class AvailablePickupOrdersResponseModel {
  final bool success;
  final String message;
  final List<OrderModel> orders;

  AvailablePickupOrdersResponseModel({
    required this.success,
    required this.message,
    required this.orders,
  });

  factory AvailablePickupOrdersResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    final ordersList = data['orders'] as List<dynamic>? ?? [];

    return AvailablePickupOrdersResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      orders: ordersList.map((e) => OrderModel.fromJson(e as Map?)).toList(),
    );
  }
}
