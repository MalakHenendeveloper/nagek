import '../../domain/entities/admin_user_entity.dart';

abstract class AdminDelegatesState {
  const AdminDelegatesState();
}

class AdminDelegatesInitial extends AdminDelegatesState {
  const AdminDelegatesInitial();
}

class AdminDelegatesLoading extends AdminDelegatesState {
  const AdminDelegatesLoading();
}

class AdminDelegatesLoaded extends AdminDelegatesState {
  final List<AdminUserEntity> delegates;
  final bool hasReachedMax;

  const AdminDelegatesLoaded(this.delegates, {required this.hasReachedMax});
}

class AdminDelegatesError extends AdminDelegatesState {
  final String message;
  const AdminDelegatesError(this.message);
}
