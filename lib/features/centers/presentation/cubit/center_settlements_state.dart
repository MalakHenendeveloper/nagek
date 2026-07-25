import '../../domain/entities/center_settlement_entity.dart';

abstract class CenterSettlementsState {}

class CenterSettlementsInitial extends CenterSettlementsState {}

class CenterSettlementsLoading extends CenterSettlementsState {}

class CenterSettlementsLoaded extends CenterSettlementsState {
  final List<CenterSettlementEntity> settlements;
  final CenterSettlementsPaginationEntity pagination;

  CenterSettlementsLoaded({
    required this.settlements,
    required this.pagination,
  });
}

class CenterSettlementsError extends CenterSettlementsState {
  final String message;

  CenterSettlementsError(this.message);
}
