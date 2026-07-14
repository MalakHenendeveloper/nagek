import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_paginated_result.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetAdminDelegateApplicationsUseCase {
  final AdminRepository repository;

  GetAdminDelegateApplicationsUseCase(this.repository);

  Future<Either<Failure, AdminDelegateApplicationsResult>> call({
    required int page,
    required int limit,
  }) {
    return repository.getDelegateApplications(page: page, limit: limit);
  }
}
