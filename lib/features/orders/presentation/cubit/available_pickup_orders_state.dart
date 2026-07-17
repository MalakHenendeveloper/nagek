import '../../domain/entities/order_entity.dart';

abstract class AvailablePickupOrdersState {}

class AvailablePickupOrdersInitial extends AvailablePickupOrdersState {}

class AvailablePickupOrdersLoading extends AvailablePickupOrdersState {}

class AvailablePickupOrdersLoaded extends AvailablePickupOrdersState {
  final List<OrderEntity> pickupOrders;
  final List<OrderEntity> deliveryOrders;

  AvailablePickupOrdersLoaded({
    required this.pickupOrders,
    required this.deliveryOrders,
  });
}

class AvailablePickupOrdersError extends AvailablePickupOrdersState {
  final String message;

  AvailablePickupOrdersError(this.message);
}

class AvailablePickupOrdersAcceptLoading extends AvailablePickupOrdersState {
  final String orderId;

  AvailablePickupOrdersAcceptLoading(this.orderId);
}

class AvailablePickupOrdersAcceptSuccess extends AvailablePickupOrdersState {
  final OrderEntity order;

  AvailablePickupOrdersAcceptSuccess(this.order);
}

class AvailablePickupOrdersAcceptError extends AvailablePickupOrdersState {
  final String message;

  AvailablePickupOrdersAcceptError(this.message);
}

class AvailablePickupOrdersUploadLoading extends AvailablePickupOrdersState {
  final String orderId;

  AvailablePickupOrdersUploadLoading(this.orderId);
}

class AvailablePickupOrdersUploadSuccess extends AvailablePickupOrdersState {
  final List<String> photoUrls;

  AvailablePickupOrdersUploadSuccess(this.photoUrls);
}

class AvailablePickupOrdersUploadError extends AvailablePickupOrdersState {
  final String message;

  AvailablePickupOrdersUploadError(this.message);
}

class AvailablePickupOrdersConfirmLoading extends AvailablePickupOrdersState {
  final String orderId;

  AvailablePickupOrdersConfirmLoading(this.orderId);
}

class AvailablePickupOrdersConfirmSuccess extends AvailablePickupOrdersState {
  final OrderEntity order;

  AvailablePickupOrdersConfirmSuccess(this.order);
}

class AvailablePickupOrdersConfirmError extends AvailablePickupOrdersState {
  final String message;

  AvailablePickupOrdersConfirmError(this.message);
}
