import '../../domain/entities/admin_settlement_entity.dart';

abstract class AdminSettlementsState {}

class AdminSettlementsInitial extends AdminSettlementsState {}

class AdminSettlementsLoading extends AdminSettlementsState {}

class AdminSettlementsLoaded extends AdminSettlementsState {
  final List<AdminSettlementEntity> settlements;
  final AdminSettlementsPaginationEntity pagination;

  AdminSettlementsLoaded({
    required this.settlements,
    required this.pagination,
  });
}

class AdminSettlementsError extends AdminSettlementsState {
  final String message;

  AdminSettlementsError(this.message);
}

class AdminSettlementPayLoading extends AdminSettlementsState {}

class AdminSettlementPaySuccess extends AdminSettlementsState {
  final String message;
  final AdminSettlementEntity settlement;

  AdminSettlementPaySuccess({
    required this.message,
    required this.settlement,
  });
}

class AdminSettlementPayError extends AdminSettlementsState {
  final String message;

  AdminSettlementPayError(this.message);
}
