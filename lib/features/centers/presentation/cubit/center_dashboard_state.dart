import '../../domain/entities/center_dashboard_entity.dart';

abstract class CenterDashboardState {}

class CenterDashboardInitial extends CenterDashboardState {}

class CenterDashboardLoading extends CenterDashboardState {}

class CenterDashboardLoaded extends CenterDashboardState {
  final CenterDashboardEntity dashboard;

  CenterDashboardLoaded(this.dashboard);
}

class CenterDashboardError extends CenterDashboardState {
  final String message;

  CenterDashboardError(this.message);
}
