import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_order_details_use_case.dart';
import 'admin_order_details_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminOrderDetailsCubit extends Cubit<AdminOrderDetailsState> {
  final GetAdminOrderDetailsUseCase _getOrderDetailsUseCase;

  AdminOrderDetailsCubit(this._getOrderDetailsUseCase)
      : super(const AdminOrderDetailsInitial());

  Future<void> fetchOrderDetails(String orderId) async {
    emit(const AdminOrderDetailsLoading());

    final result = await _getOrderDetailsUseCase.call(orderId);

    result.fold(
      (failure) => emit(AdminOrderDetailsError(failure.message)),
      (order) => emit(AdminOrderDetailsLoaded(order)),
    );
  }
}
