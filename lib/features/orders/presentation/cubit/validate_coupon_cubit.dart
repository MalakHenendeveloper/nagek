import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/validate_coupon_use_case.dart';
import 'validate_coupon_state.dart';

@injectable
class ValidateCouponCubit extends Cubit<ValidateCouponState> {
  final ValidateCouponUseCase _validateCouponUseCase;

  ValidateCouponCubit(this._validateCouponUseCase)
      : super(ValidateCouponInitial());

  Future<void> validateCoupon({
    required String code,
    required num amount,
  }) async {
    emit(ValidateCouponLoading());

    final result = await _validateCouponUseCase(
      code: code,
      amount: amount,
    );

    result.fold(
      (failure) => emit(ValidateCouponError(failure.message)),
      (couponData) => emit(
        ValidateCouponSuccess(
          couponResult: couponData,
          code: code,
        ),
      ),
    );
  }

  void reset() {
    emit(ValidateCouponInitial());
  }
}
