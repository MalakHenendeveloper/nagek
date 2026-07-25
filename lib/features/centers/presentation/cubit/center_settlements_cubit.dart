import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_center_settlements_use_case.dart';
import 'center_settlements_state.dart';

@injectable
class CenterSettlementsCubit extends Cubit<CenterSettlementsState> {
  final GetCenterSettlementsUseCase _getCenterSettlementsUseCase;

  String _status = 'all';
  String? _dateFrom;
  String? _dateTo;
  String _sort = 'newest';
  int _page = 1;

  CenterSettlementsCubit(this._getCenterSettlementsUseCase)
      : super(CenterSettlementsInitial());

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
    emit(CenterSettlementsLoading());

    if (page != null) _page = page;
    if (status != null) _status = status;
    if (dateFrom != null) _dateFrom = dateFrom.isEmpty ? null : dateFrom;
    if (dateTo != null) _dateTo = dateTo.isEmpty ? null : dateTo;
    if (sort != null) _sort = sort;

    final result = await _getCenterSettlementsUseCase.call(
      page: _page,
      limit: 10,
      status: _status,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      sort: _sort,
    );

    result.fold(
      (failure) => emit(CenterSettlementsError(failure.message)),
      (resultEntity) => emit(
        CenterSettlementsLoaded(
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
