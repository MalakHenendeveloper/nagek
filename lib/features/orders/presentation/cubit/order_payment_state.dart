import '../../domain/entities/order_payment_entity.dart';

abstract class OrderPaymentState {}

class OrderPaymentInitial extends OrderPaymentState {}

class OrderPaymentLoading extends OrderPaymentState {}

class OrderPaymentLoaded extends OrderPaymentState {
  final OrderPaymentEntity details;
  final bool isSubmitting;
  final bool isSubmitted;

  OrderPaymentLoaded(
    this.details, {
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  OrderPaymentLoaded copyWith({bool? isSubmitting, bool? isSubmitted}) {
    return OrderPaymentLoaded(
      details,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class OrderPaymentError extends OrderPaymentState {
  final String message;
  OrderPaymentError(this.message);
}
