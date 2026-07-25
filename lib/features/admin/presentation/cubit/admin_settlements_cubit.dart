import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_admin_settlements_use_case.dart';
import '../../domain/use_cases/pay_admin_settlement_use_case.dart';
import 'admin_settlements_state.dart';

@injectable
class AdminSettlementsCubit extends Cubit<AdminSettlementsState> {
  final GetAdminSettlementsUseCase _getAdminSettlementsUseCase;
  final PayAdminSettlementUseCase _payAdminSettlementUseCase;

  String _status = 'all';
  String _recipientType = 'all';
  String? _recipientId;
  String? _order;
  String _paymentMethod = 'all';
  String? _dateFrom;
  String? _dateTo;
  String _sort = 'newest';
  int _page = 1;

  AdminSettlementsCubit(
    this._getAdminSettlementsUseCase,
    this._payAdminSettlementUseCase,
  ) : super(AdminSettlementsInitial());

  String get currentStatus => _status;
  String get currentRecipientType => _recipientType;
  String? get currentRecipientId => _recipientId;
  String? get currentOrder => _order;
  String get currentPaymentMethod => _paymentMethod;
  String? get currentDateFrom => _dateFrom;
  String? get currentDateTo => _dateTo;
  String get currentSort => _sort;
  int get currentPage => _page;

  Future<void> fetchSettlements({
    int? page,
    String? status,
    String? recipientType,
    String? recipientId,
    String? order,
    String? paymentMethod,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) async {
    emit(AdminSettlementsLoading());

    if (page != null) _page = page;
    if (status != null) _status = status;
    if (recipientType != null) _recipientType = recipientType;
    if (recipientId != null) _recipientId = recipientId.isEmpty ? null : recipientId;
    if (order != null) _order = order.isEmpty ? null : order;
    if (paymentMethod != null) _paymentMethod = paymentMethod;
    if (dateFrom != null) _dateFrom = dateFrom.isEmpty ? null : dateFrom;
    if (dateTo != null) _dateTo = dateTo.isEmpty ? null : dateTo;
    if (sort != null) _sort = sort;

    final result = await _getAdminSettlementsUseCase.call(
      page: _page,
      limit: 10,
      status: _status,
      recipientType: _recipientType,
      recipientId: _recipientId,
      order: _order,
      paymentMethod: _paymentMethod,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      sort: _sort,
    );

    result.fold(
      (failure) => emit(AdminSettlementsError(failure.message)),
      (resultEntity) => emit(
        AdminSettlementsLoaded(
          settlements: resultEntity.settlements,
          pagination: resultEntity.pagination,
        ),
      ),
    );
  }

  Future<void> paySettlement(
    String settlementId, {
    String? paymentMethod,
    String? notes,
  }) async {
    emit(AdminSettlementPayLoading());

    final result = await _payAdminSettlementUseCase.call(
      settlementId,
      paymentMethod: paymentMethod,
      notes: notes,
    );

    result.fold(
      (failure) => emit(AdminSettlementPayError(failure.message)),
      (updatedSettlement) {
        emit(
          AdminSettlementPaySuccess(
            message: 'تم دفع التسوية بنجاح',
            settlement: updatedSettlement,
          ),
        );
        fetchSettlements();
      },
    );
  }

  void resetFilters() {
    _status = 'all';
    _recipientType = 'all';
    _recipientId = null;
    _order = null;
    _paymentMethod = 'all';
    _dateFrom = null;
    _dateTo = null;
    _sort = 'newest';
    _page = 1;
    fetchSettlements();
  }
}
