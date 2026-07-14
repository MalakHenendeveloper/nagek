import '../../domain/entities/user_entity.dart';

abstract class DelegateLoginState {}

class DelegateLoginInitial extends DelegateLoginState {}

class DelegateLoginLoading extends DelegateLoginState {}

class DelegateLoginSuccessState extends DelegateLoginState {
  final UserEntity user;
  DelegateLoginSuccessState(this.user);
}

class DelegateLoginPendingState extends DelegateLoginState {}

class DelegateLoginRejectedState extends DelegateLoginState {
  final String rejectReason;
  DelegateLoginRejectedState(this.rejectReason);
}

class DelegateLoginError extends DelegateLoginState {
  final String message;
  DelegateLoginError(this.message);
}
