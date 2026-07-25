import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/center_dashboard_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class GetCenterDashboardUseCase {
  final CentersRepository repository;

  GetCenterDashboardUseCase(this.repository);

  Future<Either<Failure, CenterDashboardEntity>> call() async {
    return await repository.getCenterDashboard();
  }
}
