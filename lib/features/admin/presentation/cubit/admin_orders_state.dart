import '../../../orders/domain/entities/order_entity.dart';

abstract class AdminOrdersState {
  const AdminOrdersState();
}

class AdminOrdersInitial extends AdminOrdersState {
  const AdminOrdersInitial();
}

class AdminOrdersLoading extends AdminOrdersState {
  const AdminOrdersLoading();
}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<OrderEntity> orders;
  final OrdersPaginationEntity pagination;

  const AdminOrdersLoaded({required this.orders, required this.pagination});
}

class AdminOrdersLoadingMore extends AdminOrdersState {
  final List<OrderEntity> orders;
  final OrdersPaginationEntity pagination;

  const AdminOrdersLoadingMore({required this.orders, required this.pagination});
}

class AdminOrdersError extends AdminOrdersState {
  final String message;

  const AdminOrdersError(this.message);
}
