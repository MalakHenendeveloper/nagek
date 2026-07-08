import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_orders_use_case.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUseCase _getOrdersUseCase;
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasReachedMax = false;

  OrdersCubit(this._getOrdersUseCase) : super(OrdersInitial());

  Future<void> fetchOrders({bool isRefresh = false, int limit = 10}) async {
    if (_isFetching) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      emit(OrdersInitial());
    }

    if (_hasReachedMax) return;

    _isFetching = true;
    if (state is! OrdersLoaded) {
      emit(OrdersLoading());
    }

    final result = await _getOrdersUseCase.call(
      page: _currentPage,
      limit: limit,
    );

    result.fold(
      (failure) {
        _isFetching = false;
        emit(OrdersError(failure.message));
      },
      (resultEntity) {
        _isFetching = false;
        _hasReachedMax = _currentPage >= resultEntity.pagination.pages;
        
        final currentOrders = state is OrdersLoaded 
            ? (state as OrdersLoaded).orders 
            : <OrderEntity>[];
            
        final updatedOrders = isRefresh 
            ? resultEntity.orders 
            : [...currentOrders, ...resultEntity.orders];

        _currentPage++;
        emit(OrdersLoaded(updatedOrders, hasReachedMax: _hasReachedMax));
      },
    );
  }
}
