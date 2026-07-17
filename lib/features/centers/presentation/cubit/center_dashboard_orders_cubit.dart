import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_center_dashboard_orders_use_case.dart';
import 'center_dashboard_orders_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CenterDashboardOrdersCubit extends Cubit<CenterDashboardOrdersState> {
  final GetCenterDashboardOrdersUseCase _getOrdersUseCase;

  int _currentPage = 1;
  bool _isFetching = false;

  CenterDashboardOrdersCubit(this._getOrdersUseCase) : super(CenterDashboardOrdersInitial());

  Future<void> fetchOrders({int limit = 20, bool isRefresh = false}) async {
    if (_isFetching) return;

    if (isRefresh) {
      _currentPage = 1;
    }

    final currentState = state;
    if (currentState is CenterDashboardOrdersLoaded && currentState.hasReachedMax && !isRefresh) return;

    _isFetching = true;

    if (currentState is! CenterDashboardOrdersLoaded || isRefresh) {
      emit(CenterDashboardOrdersLoading());
    }

    final result = await _getOrdersUseCase(page: _currentPage, limit: limit);

    result.fold(
      (failure) {
        if (currentState is CenterDashboardOrdersLoaded && !isRefresh) {
          emit(CenterDashboardOrdersError(failure.message));
          emit(currentState); // fallback to previous state
        } else {
          emit(CenterDashboardOrdersError(failure.message));
        }
      },
      (data) {
        _currentPage++;
        final isMax = data.pagination.page >= data.pagination.pages;

        final newOrders = isRefresh
            ? data.orders
            : (currentState is CenterDashboardOrdersLoaded
                ? currentState.orders + data.orders
                : data.orders);

        // Calculate counts based on orders list
        int pending = 0;
        int inProgress = 0;
        int completed = 0;

        for (final order in newOrders) {
          final status = order.status.toLowerCase();
          if (status == 'pending') {
            pending++;
          } else if (status == 'completed' || status == 'delivered' || status == 'done') {
            completed++;
          } else {
            inProgress++;
          }
        }

        emit(CenterDashboardOrdersLoaded(
          orders: newOrders,
          hasReachedMax: isMax,
          totalCount: isRefresh ? data.pagination.total : (currentState is CenterDashboardOrdersLoaded ? currentState.totalCount : data.pagination.total),
          pendingCount: pending,
          inProgressCount: inProgress,
          completedCount: completed,
        ));
      },
    );
    _isFetching = false;
  }
}
