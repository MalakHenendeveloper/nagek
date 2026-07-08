import '../../domain/entities/user_entity.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}
