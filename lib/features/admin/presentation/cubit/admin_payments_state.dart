import '../../domain/entities/admin_payment_entity.dart';

abstract class AdminPaymentsState {
  const AdminPaymentsState();
}

class AdminPaymentsInitial extends AdminPaymentsState {
  const AdminPaymentsInitial();
}

class AdminPaymentsLoading extends AdminPaymentsState {
  const AdminPaymentsLoading();
}

class AdminPaymentsLoaded extends AdminPaymentsState {
  final List<AdminPaymentEntity> payments;
  final bool hasReachedMax;
  final bool isReviewLoading;
  final String? reviewError;
  final String? reviewSuccessMessage;

  const AdminPaymentsLoaded(
    this.payments, {
    required this.hasReachedMax,
    this.isReviewLoading = false,
    this.reviewError,
    this.reviewSuccessMessage,
  });

  AdminPaymentsLoaded copyWith({
    List<AdminPaymentEntity>? payments,
    bool? hasReachedMax,
    bool? isReviewLoading,
    String? reviewError,
    String? reviewSuccessMessage,
  }) {
    return AdminPaymentsLoaded(
      payments ?? this.payments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isReviewLoading: isReviewLoading ?? this.isReviewLoading,
      reviewError: reviewError,
      reviewSuccessMessage: reviewSuccessMessage,
    );
  }
}

class AdminPaymentsError extends AdminPaymentsState {
  final String message;
  const AdminPaymentsError(this.message);
}
