import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_center_dashboard_order_details_use_case.dart';
import '../../domain/use_cases/update_center_order_status_use_case.dart';
import 'center_order_details_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CenterOrderDetailsCubit extends Cubit<CenterOrderDetailsState> {
  final GetCenterDashboardOrderDetailsUseCase _getDetailsUseCase;
  final UpdateCenterOrderStatusUseCase _updateStatusUseCase;

  CenterOrderDetailsCubit(
    this._getDetailsUseCase,
    this._updateStatusUseCase,
  ) : super(CenterOrderDetailsInitial());

  Future<void> fetchOrderDetails(String orderId) async {
    emit(CenterOrderDetailsLoading());

    final result = await _getDetailsUseCase(orderId);

    result.fold(
      (failure) => emit(CenterOrderDetailsError(failure.message)),
      (details) => emit(CenterOrderDetailsLoaded(details)),
    );
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required String note,
  }) async {
    emit(CenterOrderStatusUpdateLoading());

    final result = await _updateStatusUseCase(
      orderId: orderId,
      status: status,
      note: note,
    );

    result.fold(
      (failure) => emit(CenterOrderStatusUpdateError(failure.message)),
      (_) => emit(CenterOrderStatusUpdateSuccess()),
    );
  }
}
