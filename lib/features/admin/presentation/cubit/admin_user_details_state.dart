import '../../domain/entities/admin_user_entity.dart';

abstract class AdminUserDetailsState {
  const AdminUserDetailsState();
}

class AdminUserDetailsInitial extends AdminUserDetailsState {
  const AdminUserDetailsInitial();
}

class AdminUserDetailsLoading extends AdminUserDetailsState {
  const AdminUserDetailsLoading();
}

class AdminUserDetailsLoaded extends AdminUserDetailsState {
  final AdminUserEntity user;
  const AdminUserDetailsLoaded(this.user);
}

class AdminUserDetailsError extends AdminUserDetailsState {
  final String message;
  const AdminUserDetailsError(this.message);
}

class AdminUserDeleting extends AdminUserDetailsState {
  final AdminUserEntity user;
  const AdminUserDeleting(this.user);
}

class AdminUserDeleted extends AdminUserDetailsState {
  final String message;
  const AdminUserDeleted(this.message);
}

class AdminUserDeleteError extends AdminUserDetailsState {
  final AdminUserEntity user;
  final String message;
  const AdminUserDeleteError(this.user, this.message);
}

class AdminUserStatusUpdating extends AdminUserDetailsState {
  final AdminUserEntity user;
  const AdminUserStatusUpdating(this.user);
}

class AdminUserStatusUpdateSuccess extends AdminUserDetailsState {
  final AdminUserEntity user;
  final String message;
  const AdminUserStatusUpdateSuccess(this.user, this.message);
}

class AdminUserStatusUpdateError extends AdminUserDetailsState {
  final AdminUserEntity user;
  final String message;
  const AdminUserStatusUpdateError(this.user, this.message);
}


