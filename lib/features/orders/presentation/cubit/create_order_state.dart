import '../../domain/entities/order_entity.dart';

abstract class CreateOrderState {}

class CreateOrderInitial extends CreateOrderState {}

class CreateOrderLoading extends CreateOrderState {}

class CreateOrderSuccess extends CreateOrderState {
  final OrderEntity order;

  CreateOrderSuccess(this.order);
}

class CreateOrderError extends CreateOrderState {
  final String message;

  CreateOrderError(this.message);
}
