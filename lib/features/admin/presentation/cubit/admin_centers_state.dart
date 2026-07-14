import '../../domain/entities/admin_center_entity.dart';

abstract class AdminCentersState {
  const AdminCentersState();
}

class AdminCentersInitial extends AdminCentersState {
  const AdminCentersInitial();
}

class AdminCentersLoading extends AdminCentersState {
  const AdminCentersLoading();
}

class AdminCentersLoaded extends AdminCentersState {
  final List<AdminCenterEntity> centers;
  final bool hasReachedMax;

  const AdminCentersLoaded(this.centers, {required this.hasReachedMax});
}

class AdminCentersError extends AdminCentersState {
  final String message;
  const AdminCentersError(this.message);
}
