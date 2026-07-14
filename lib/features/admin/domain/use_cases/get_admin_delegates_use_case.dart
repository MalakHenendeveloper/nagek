import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_paginated_result.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdminDelegatesUseCase {
  final AdminRepository _repository;

  GetAdminDelegatesUseCase(this._repository);

  Future<Either<Failure, AdminDelegatesResult>> call({required int page, required int limit}) {
    return _repository.getDelegates(page: page, limit: limit);
  }
}
