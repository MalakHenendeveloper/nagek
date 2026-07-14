import '../../../orders/domain/entities/order_entity.dart';

abstract class AdminOrderDetailsState {
  const AdminOrderDetailsState();
}

class AdminOrderDetailsInitial extends AdminOrderDetailsState {
  const AdminOrderDetailsInitial();
}

class AdminOrderDetailsLoading extends AdminOrderDetailsState {
  const AdminOrderDetailsLoading();
}

class AdminOrderDetailsLoaded extends AdminOrderDetailsState {
  final OrderEntity order;

  const AdminOrderDetailsLoaded(this.order);
}

class AdminOrderDetailsError extends AdminOrderDetailsState {
  final String message;

  const AdminOrderDetailsError(this.message);
}
