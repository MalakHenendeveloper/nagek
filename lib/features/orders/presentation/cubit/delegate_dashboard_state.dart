import '../../domain/entities/delegate_dashboard_entity.dart';

abstract class DelegateDashboardState {}

class DelegateDashboardInitial extends DelegateDashboardState {}

class DelegateDashboardLoading extends DelegateDashboardState {}

class DelegateDashboardLoaded extends DelegateDashboardState {
  final DelegateDashboardEntity dashboard;

  DelegateDashboardLoaded(this.dashboard);
}

class DelegateDashboardError extends DelegateDashboardState {
  final String message;

  DelegateDashboardError(this.message);
}
