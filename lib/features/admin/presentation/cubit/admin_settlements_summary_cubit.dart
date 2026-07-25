import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_admin_settlements_summary_use_case.dart';
import 'admin_settlements_summary_state.dart';

@injectable
class AdminSettlementsSummaryCubit extends Cubit<AdminSettlementsSummaryState> {
  final GetAdminSettlementsSummaryUseCase _getAdminSettlementsSummaryUseCase;

  String _recipientType = 'all';
  String? _search;
  String _sortBy = 'totalEarnings';
  String _sortOrder = 'desc';
  int _page = 1;

  AdminSettlementsSummaryCubit(this._getAdminSettlementsSummaryUseCase)
      : super(AdminSettlementsSummaryInitial());

  String get currentRecipientType => _recipientType;
  String? get currentSearch => _search;
  String get currentSortBy => _sortBy;
  String get currentSortOrder => _sortOrder;
  int get currentPage => _page;

  Future<void> fetchSummary({
    int? page,
    String? recipientType,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    emit(AdminSettlementsSummaryLoading());

    if (page != null) _page = page;
    if (recipientType != null) _recipientType = recipientType;
    if (search != null) _search = search.isEmpty ? null : search;
    if (sortBy != null) _sortBy = sortBy;
    if (sortOrder != null) _sortOrder = sortOrder;

    final result = await _getAdminSettlementsSummaryUseCase.call(
      page: _page,
      limit: 10,
      recipientType: _recipientType,
      search: _search,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    result.fold(
      (failure) => emit(AdminSettlementsSummaryError(failure.message)),
      (resultEntity) => emit(
        AdminSettlementsSummaryLoaded(
          summaries: resultEntity.summaries,
          pagination: resultEntity.pagination,
        ),
      ),
    );
  }

  void resetFilters() {
    _recipientType = 'all';
    _search = null;
    _sortBy = 'totalEarnings';
    _sortOrder = 'desc';
    _page = 1;
    fetchSummary();
  }
}
