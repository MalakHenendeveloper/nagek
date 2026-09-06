import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/use_cases/create_coupon_use_case.dart';
import '../../domain/use_cases/get_coupons_use_case.dart';
import '../../domain/use_cases/update_coupon_use_case.dart';

part 'admin_coupons_state.dart';

@injectable
class AdminCouponsCubit extends Cubit<AdminCouponsState> {
  final CreateCouponUseCase _createCouponUseCase;
  final GetCouponsUseCase _getCouponsUseCase;
  final UpdateCouponUseCase _updateCouponUseCase;

  AdminCouponsCubit(
    this._createCouponUseCase,
    this._getCouponsUseCase,
    this._updateCouponUseCase,
  ) : super(AdminCouponsInitial());

  Future<void> fetchCoupons() async {
    emit(AdminCouponsListLoading());

    final result = await _getCouponsUseCase();

    result.fold(
      (failure) => emit(AdminCouponsListError(failure.message)),
      (coupons) => emit(AdminCouponsListLoaded(coupons)),
    );
  }

  Future<void> createCoupon({
    required String code,
    required num discountValue,
  }) async {
    emit(AdminCouponsLoading());

    final result = await _createCouponUseCase(
      code: code,
      discountValue: discountValue,
    );

    result.fold(
      (failure) => emit(AdminCouponsError(failure.message)),
      (coupon) => emit(AdminCouponsSuccess(coupon)),
    );
  }

  Future<void> updateCoupon({
    required String id,
    num? discountValue,
    bool? isActive,
  }) async {
    emit(AdminCouponUpdateLoading());

    final result = await _updateCouponUseCase(
      id: id,
      discountValue: discountValue,
      isActive: isActive,
    );

    result.fold(
      (failure) => emit(AdminCouponUpdateError(failure.message)),
      (coupon) => emit(AdminCouponUpdateSuccess(coupon)),
    );
  }
}
