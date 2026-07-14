import '../../domain/entities/admin_center_entity.dart';

abstract class AdminCreateCenterState {
  const AdminCreateCenterState();
}

class AdminCreateCenterInitial extends AdminCreateCenterState {
  const AdminCreateCenterInitial();
}

class AdminCreateCenterLoading extends AdminCreateCenterState {
  const AdminCreateCenterLoading();
}

class AdminCreateCenterSuccess extends AdminCreateCenterState {
  final AdminCenterEntity center;
  final String message;

  const AdminCreateCenterSuccess(this.center, this.message);
}

class AdminCreateCenterError extends AdminCreateCenterState {
  final String message;

  const AdminCreateCenterError(this.message);
}
