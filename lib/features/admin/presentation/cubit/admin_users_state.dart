import '../../domain/entities/admin_user_entity.dart';

abstract class AdminUsersState {
  const AdminUsersState();
}

class AdminUsersInitial extends AdminUsersState {
  const AdminUsersInitial();
}

class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUserEntity> users;
  final bool hasReachedMax;

  const AdminUsersLoaded(this.users, {required this.hasReachedMax});
}

class AdminUsersError extends AdminUsersState {
  final String message;
  const AdminUsersError(this.message);
}
