import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/center_entity.dart';
import '../entities/service_entity.dart';

abstract class CentersRepository {
  Future<Either<Failure, CentersResultEntity>> getCenters({
    required int page,
    required int limit,
  });

  Future<Either<Failure, CenterEntity>> getCenterDetails(String id);

  Future<Either<Failure, List<ServiceEntity>>> getCenterServices(String centerId);
}
