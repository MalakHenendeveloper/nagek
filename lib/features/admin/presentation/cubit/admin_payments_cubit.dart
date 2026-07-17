import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_payments_use_case.dart';
import '../../domain/use_cases/review_admin_payment_use_case.dart';
import '../../domain/entities/admin_payment_entity.dart';
import 'admin_payments_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminPaymentsCubit extends Cubit<AdminPaymentsState> {
  final GetAdminPaymentsUseCase _getPaymentsUseCase;
  final ReviewAdminPaymentUseCase _reviewPaymentUseCase;
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasReachedMax = false;

  AdminPaymentsCubit(
    this._getPaymentsUseCase,
    this._reviewPaymentUseCase,
  ) : super(const AdminPaymentsInitial());

  Future<void> fetchPayments({bool isRefresh = false, int limit = 10}) async {
    if (_isFetching) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      emit(const AdminPaymentsInitial());
    }

    if (_hasReachedMax) return;

    _isFetching = true;
    if (state is! AdminPaymentsLoaded) {
      emit(const AdminPaymentsLoading());
    }

    final result = await _getPaymentsUseCase.call(
      page: _currentPage,
      limit: limit,
    );

    result.fold(
      (failure) {
        _isFetching = false;
        emit(AdminPaymentsError(failure.message));
      },
      (resultEntity) {
        _isFetching = false;
        _hasReachedMax = _currentPage >= resultEntity.pagination.pages;

        final currentPayments = state is AdminPaymentsLoaded
            ? (state as AdminPaymentsLoaded).payments
            : <AdminPaymentEntity>[];

        final updatedPayments = isRefresh
            ? resultEntity.payments
            : [...currentPayments, ...resultEntity.payments];

        _currentPage++;
        emit(AdminPaymentsLoaded(updatedPayments, hasReachedMax: _hasReachedMax));
      },
    );
  }

  Future<void> reviewPayment({
    required String paymentId,
    required String status,
    String? rejectionReason,
  }) async {
    final currentState = state;
    if (currentState is AdminPaymentsLoaded) {
      emit(currentState.copyWith(
        isReviewLoading: true,
        reviewError: null,
        reviewSuccessMessage: null,
      ));

      final result = await _reviewPaymentUseCase.call(
        paymentId: paymentId,
        status: status,
        rejectionReason: rejectionReason,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(
            isReviewLoading: false,
            reviewError: failure.message,
          ));
        },
        (_) {
          emit(currentState.copyWith(
            isReviewLoading: false,
            reviewSuccessMessage: status == 'confirmed'
                ? 'تم تأكيد الدفع بنجاح'
                : 'تم رفض الدفع بنجاح',
          ));
        },
      );
    }
  }
}
