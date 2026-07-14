import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/delegate_login_result.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class DelegateLoginUseCase {
  final AuthRepository repository;

  DelegateLoginUseCase(this.repository);

  Future<Either<Failure, DelegateLoginResult>> call({
    required String phone,
    required String password,
  }) {
    return repository.delegateLogin(phone: phone, password: password);
  }
}
