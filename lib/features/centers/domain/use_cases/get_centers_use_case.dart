import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/center_entity.dart';
import '../repositories/centers_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetCentersUseCase {
  final CentersRepository repository;

  GetCentersUseCase(this.repository);

  Future<Either<Failure, CentersResultEntity>> call({
    required int page,
    required int limit,
  }) {
    return repository.getCenters(page: page, limit: limit);
  }
}
