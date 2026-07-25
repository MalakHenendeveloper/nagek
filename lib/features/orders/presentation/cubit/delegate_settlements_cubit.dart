import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_delegate_settlements_use_case.dart';
import 'delegate_settlements_state.dart';

@injectable
class DelegateSettlementsCubit extends Cubit<DelegateSettlementsState> {
  final GetDelegateSettlementsUseCase _getDelegateSettlementsUseCase;

  String _status = 'all';
  String? _dateFrom;
  String? _dateTo;
  String _sort = 'newest';
  int _page = 1;

  DelegateSettlementsCubit(this._getDelegateSettlementsUseCase)
      : super(DelegateSettlementsInitial());

  String get currentStatus => _status;
  String? get currentDateFrom => _dateFrom;
  String? get currentDateTo => _dateTo;
  String get currentSort => _sort;
  int get currentPage => _page;

  Future<void> fetchSettlements({
    int? page,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) async {
    emit(DelegateSettlementsLoading());

    if (page != null) _page = page;
    if (status != null) _status = status;
    if (dateFrom != null) _dateFrom = dateFrom.isEmpty ? null : dateFrom;
    if (dateTo != null) _dateTo = dateTo.isEmpty ? null : dateTo;
    if (sort != null) _sort = sort;

    final result = await _getDelegateSettlementsUseCase.call(
      page: _page,
      limit: 10,
      status: _status,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      sort: _sort,
    );

    result.fold(
      (failure) => emit(DelegateSettlementsError(failure.message)),
      (resultEntity) => emit(
        DelegateSettlementsLoaded(
          settlements: resultEntity.settlements,
          pagination: resultEntity.pagination,
        ),
      ),
    );
  }

  void resetFilters() {
    _status = 'all';
    _dateFrom = null;
    _dateTo = null;
    _sort = 'newest';
    _page = 1;
    fetchSettlements();
  }
}
