import '../../domain/entities/admin_center_details_entity.dart';

abstract class AdminCenterDetailsState {
  const AdminCenterDetailsState();
}

class AdminCenterDetailsInitial extends AdminCenterDetailsState {
  const AdminCenterDetailsInitial();
}

class AdminCenterDetailsLoading extends AdminCenterDetailsState {
  const AdminCenterDetailsLoading();
}

class AdminCenterDetailsLoaded extends AdminCenterDetailsState {
  final AdminCenterDetailsEntity details;

  const AdminCenterDetailsLoaded(this.details);
}

class AdminCenterDetailsError extends AdminCenterDetailsState {
  final String message;

  const AdminCenterDetailsError(this.message);
}

class AdminCenterDetailsLoadingStatus extends AdminCenterDetailsState {
  final AdminCenterDetailsEntity details;

  const AdminCenterDetailsLoadingStatus(this.details);
}

class AdminCenterStatusUpdateError extends AdminCenterDetailsState {
  final AdminCenterDetailsEntity details;
  final String message;

  const AdminCenterStatusUpdateError(this.details, this.message);
}

