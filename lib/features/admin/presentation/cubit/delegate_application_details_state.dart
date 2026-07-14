import '../../domain/entities/delegate_application_entity.dart';

abstract class DelegateApplicationDetailsState {}

class DelegateApplicationDetailsInitial extends DelegateApplicationDetailsState {}

class DelegateApplicationDetailsLoading extends DelegateApplicationDetailsState {}

class DelegateApplicationDetailsSuccess extends DelegateApplicationDetailsState {
  final DelegateApplicationEntity application;
  final bool isActionLoading;
  final String? actionError;

  DelegateApplicationDetailsSuccess(
    this.application, {
    this.isActionLoading = false,
    this.actionError,
  });
}

class DelegateApplicationDetailsError extends DelegateApplicationDetailsState {
  final String message;
  DelegateApplicationDetailsError(this.message);
}

class DelegateApplicationApproveSuccess extends DelegateApplicationDetailsState {
  final String message;
  DelegateApplicationApproveSuccess(this.message);
}

class DelegateApplicationRejectSuccess extends DelegateApplicationDetailsState {
  final String message;
  DelegateApplicationRejectSuccess(this.message);
}
