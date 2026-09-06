import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_available_coupons_use_case.dart';
import 'available_coupons_state.dart';

@injectable
class AvailableCouponsCubit extends Cubit<AvailableCouponsState> {
  final GetAvailableCouponsUseCase _getAvailableCouponsUseCase;

  AvailableCouponsCubit(this._getAvailableCouponsUseCase)
      : super(AvailableCouponsInitial());

  Future<void> fetchAvailableCoupons() async {
    emit(AvailableCouponsLoading());

    final result = await _getAvailableCouponsUseCase();

    result.fold(
      (failure) => emit(AvailableCouponsError(failure.message)),
      (coupons) => emit(AvailableCouponsLoaded(coupons)),
    );
  }
}
