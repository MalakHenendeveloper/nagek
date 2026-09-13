import '../../domain/entities/admin_settlements_report_entity.dart';

abstract class AdminSettlementsReportState {}

class AdminSettlementsReportInitial extends AdminSettlementsReportState {}

class AdminSettlementsReportLoading extends AdminSettlementsReportState {}

class AdminSettlementsReportLoaded extends AdminSettlementsReportState {
  final AdminSettlementsReportEntity report;
  final String? updatingKey;
  final String? actionSuccessMessage;
  final String? actionErrorMessage;

  AdminSettlementsReportLoaded(
    this.report, {
    this.updatingKey,
    this.actionSuccessMessage,
    this.actionErrorMessage,
  });

  AdminSettlementsReportLoaded copyWith({
    AdminSettlementsReportEntity? report,
    String? updatingKey,
    bool clearUpdatingKey = false,
    String? actionSuccessMessage,
    String? actionErrorMessage,
  }) {
    return AdminSettlementsReportLoaded(
      report ?? this.report,
      updatingKey: clearUpdatingKey ? null : (updatingKey ?? this.updatingKey),
      actionSuccessMessage: actionSuccessMessage,
      actionErrorMessage: actionErrorMessage,
    );
  }
}

class AdminSettlementsReportError extends AdminSettlementsReportState {
  final String message;

  AdminSettlementsReportError(this.message);
}
