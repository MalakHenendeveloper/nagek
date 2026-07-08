import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    return repository.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }
}
