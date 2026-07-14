import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/delegate_register_request_model.dart';
import '../entities/user_entity.dart';
import '../entities/delegate_login_result.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  });
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> registerDelegate({
    required DelegateRegisterRequestModel request,
  });
  Future<Either<Failure, DelegateLoginResult>> delegateLogin({
    required String phone,
    required String password,
  });
}
