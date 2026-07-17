import '../../domain/entities/order_entity.dart';

abstract class DelegateOrdersState {}

class DelegateOrdersInitial extends DelegateOrdersState {}

class DelegateOrdersLoading extends DelegateOrdersState {}

class DelegateOrdersLoaded extends DelegateOrdersState {
  final List<OrderEntity> orders;
  final int completedOrdersCount;
  final double totalEarnings;

  DelegateOrdersLoaded(this.orders, this.completedOrdersCount, this.totalEarnings);
}

class DelegateOrdersError extends DelegateOrdersState {
  final String message;

  DelegateOrdersError(this.message);
}

// Upload & Confirm states
class DelegateOrdersUploadLoading extends DelegateOrdersState {
  final String orderId;

  DelegateOrdersUploadLoading(this.orderId);
}

class DelegateOrdersUploadSuccess extends DelegateOrdersState {
  final List<String> photoUrls;

  DelegateOrdersUploadSuccess(this.photoUrls);
}

class DelegateOrdersUploadError extends DelegateOrdersState {
  final String message;

  DelegateOrdersUploadError(this.message);
}

class DelegateOrdersConfirmLoading extends DelegateOrdersState {
  final String orderId;

  DelegateOrdersConfirmLoading(this.orderId);
}

class DelegateOrdersConfirmSuccess extends DelegateOrdersState {
  final OrderEntity order;

  DelegateOrdersConfirmSuccess(this.order);
}

class DelegateOrdersConfirmError extends DelegateOrdersState {
  final String message;

  DelegateOrdersConfirmError(this.message);
}

// Drop Center states
class DelegateOrdersDropCenterLoading extends DelegateOrdersState {
  final String orderId;

  DelegateOrdersDropCenterLoading(this.orderId);
}

class DelegateOrdersDropCenterSuccess extends DelegateOrdersState {
  final OrderEntity order;

  DelegateOrdersDropCenterSuccess(this.order);
}

class DelegateOrdersDropCenterError extends DelegateOrdersState {
  final String message;

  DelegateOrdersDropCenterError(this.message);
}
