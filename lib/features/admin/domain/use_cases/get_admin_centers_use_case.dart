import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_paginated_result.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdminCentersUseCase {
  final AdminRepository _repository;

  GetAdminCentersUseCase(this._repository);

  Future<Either<Failure, AdminCentersResult>> call({required int page, required int limit}) {
    return _repository.getCenters(page: page, limit: limit);
  }
}
