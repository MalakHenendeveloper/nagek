import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/delegate_register_request_model.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterDelegateUseCase {
  final AuthRepository repository;

  RegisterDelegateUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required DelegateRegisterRequestModel request,
  }) {
    return repository.registerDelegate(request: request);
  }
}
