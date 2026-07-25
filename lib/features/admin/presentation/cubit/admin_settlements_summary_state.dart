import '../../domain/entities/admin_settlements_summary_entity.dart';

abstract class AdminSettlementsSummaryState {}

class AdminSettlementsSummaryInitial extends AdminSettlementsSummaryState {}

class AdminSettlementsSummaryLoading extends AdminSettlementsSummaryState {}

class AdminSettlementsSummaryLoaded extends AdminSettlementsSummaryState {
  final List<AdminSettlementRecipientSummaryEntity> summaries;
  final AdminSettlementsSummaryPaginationEntity pagination;

  AdminSettlementsSummaryLoaded({
    required this.summaries,
    required this.pagination,
  });
}

class AdminSettlementsSummaryError extends AdminSettlementsSummaryState {
  final String message;

  AdminSettlementsSummaryError(this.message);
}
