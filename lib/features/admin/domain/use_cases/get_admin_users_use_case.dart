import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_paginated_result.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdminUsersUseCase {
  final AdminRepository _repository;

  GetAdminUsersUseCase(this._repository);

  Future<Either<Failure, AdminUsersResult>> call({required int page, required int limit}) {
    return _repository.getUsers(page: page, limit: limit);
  }
}
