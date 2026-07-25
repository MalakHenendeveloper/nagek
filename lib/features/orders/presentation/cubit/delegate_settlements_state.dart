import '../../domain/entities/delegate_settlement_entity.dart';

abstract class DelegateSettlementsState {}

class DelegateSettlementsInitial extends DelegateSettlementsState {}

class DelegateSettlementsLoading extends DelegateSettlementsState {}

class DelegateSettlementsLoaded extends DelegateSettlementsState {
  final List<DelegateSettlementEntity> settlements;
  final DelegateSettlementsPaginationEntity pagination;

  DelegateSettlementsLoaded({
    required this.settlements,
    required this.pagination,
  });
}

class DelegateSettlementsError extends DelegateSettlementsState {
  final String message;

  DelegateSettlementsError(this.message);
}
