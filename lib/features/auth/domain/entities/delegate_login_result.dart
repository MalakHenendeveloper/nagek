import 'user_entity.dart';

abstract class DelegateLoginResult {}

class DelegateLoginSuccess extends DelegateLoginResult {
  final UserEntity user;
  DelegateLoginSuccess(this.user);
}

class DelegateLoginPending extends DelegateLoginResult {}

class DelegateLoginRejected extends DelegateLoginResult {
  final String rejectReason;
  DelegateLoginRejected(this.rejectReason);
}
