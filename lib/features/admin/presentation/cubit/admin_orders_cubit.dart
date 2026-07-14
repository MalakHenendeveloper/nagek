import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_orders_use_case.dart';
import 'admin_orders_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  final GetAdminOrdersUseCase _getOrdersUseCase;

  int _currentPage = 1;
  static const int _limit = 10;

  AdminOrdersCubit(this._getOrdersUseCase) : super(const AdminOrdersInitial());

  Future<void> fetchOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    if (_currentPage == 1) {
      emit(const AdminOrdersLoading());
    } else {
      final currentState = state;
      if (currentState is AdminOrdersLoaded) {
        emit(AdminOrdersLoadingMore(
          orders: currentState.orders,
          pagination: currentState.pagination,
        ));
      }
    }

    final result = await _getOrdersUseCase.call(page: _currentPage, limit: _limit);

    result.fold(
      (failure) => emit(AdminOrdersError(failure.message)),
      (ordersResult) {
        if (_currentPage == 1) {
          emit(AdminOrdersLoaded(
            orders: ordersResult.orders,
            pagination: ordersResult.pagination,
          ));
        } else {
          final currentState = state;
          List<dynamic> existingOrders = [];
          if (currentState is AdminOrdersLoadingMore) {
            existingOrders = currentState.orders;
          }
          emit(AdminOrdersLoaded(
            orders: [...existingOrders, ...ordersResult.orders],
            pagination: ordersResult.pagination,
          ));
        }
      },
    );
  }

  void loadMore() {
    final currentState = state;
    if (currentState is AdminOrdersLoaded) {
      if (currentState.pagination.page < currentState.pagination.pages) {
        _currentPage++;
        fetchOrders();
      }
    }
  }
}
