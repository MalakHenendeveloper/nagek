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

    // delegateFeeValue may be at data level or inside each order
    final dataLevelFee = (data['delegateFeeValue'] is num)
        ? (data['delegateFeeValue'] as num).toDouble()
        : null;

    return AvailablePickupOrdersResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      orders: ordersList.map((e) {
        final orderMap = e as Map?;
        return OrderModel.fromJson(orderMap, rootDelegateFeeValue: dataLevelFee);
      }).toList(),
    );
  }
}
