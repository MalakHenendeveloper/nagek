abstract class AdminDashboardState {
  const AdminDashboardState();
}

class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

class AdminDashboardLoaded extends AdminDashboardState {
  final int totalUsers;
  final int totalDelegates;
  final int totalCenters;

  const AdminDashboardLoaded({
    required this.totalUsers,
    required this.totalDelegates,
    required this.totalCenters,
  });
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  const AdminDashboardError(this.message);
}
