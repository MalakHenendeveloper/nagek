import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_order_payment_details_use_case.dart';
import '../../domain/use_cases/submit_payment_proof_use_case.dart';
import 'order_payment_state.dart';

@injectable
class OrderPaymentCubit extends Cubit<OrderPaymentState> {
  final GetOrderPaymentDetailsUseCase _getDetailsUseCase;
  final SubmitPaymentProofUseCase _submitProofUseCase;

  OrderPaymentCubit(this._getDetailsUseCase, this._submitProofUseCase)
      : super(OrderPaymentInitial());

  Future<void> fetchPaymentDetails(String orderId) async {
    emit(OrderPaymentLoading());

    final result = await _getDetailsUseCase(orderId);

    result.fold(
      (failure) => emit(OrderPaymentError(failure.message)),
      (details) => emit(OrderPaymentLoaded(details)),
    );
  }

  Future<bool> submitPaymentProof({
    required String orderId,
    required String senderWalletNumber,
  }) async {
    final currentState = state;
    if (currentState is! OrderPaymentLoaded) return false;

    emit(currentState.copyWith(isSubmitting: true));

    final result = await _submitProofUseCase(
      orderId: orderId,
      senderWalletNumber: senderWalletNumber,
    );

    return result.fold(
      (failure) {
        emit(currentState.copyWith(isSubmitting: false));
        return false;
      },
      (success) {
        emit(currentState.copyWith(isSubmitting: false, isSubmitted: true));
        return true;
      },
    );
  }
}
