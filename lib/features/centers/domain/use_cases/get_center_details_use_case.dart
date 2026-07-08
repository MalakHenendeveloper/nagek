import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/center_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class GetCenterDetailsUseCase {
  final CentersRepository repository;

  GetCenterDetailsUseCase(this.repository);

  Future<Either<Failure, CenterEntity>> call(String id) {
    return repository.getCenterDetails(id);
  }
}
