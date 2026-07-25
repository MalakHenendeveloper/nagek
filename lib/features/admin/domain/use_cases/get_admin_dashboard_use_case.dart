import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_dashboard_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetAdminDashboardUseCase {
  final AdminRepository repository;

  GetAdminDashboardUseCase(this.repository);

  Future<Either<Failure, AdminDashboardEntity>> call() async {
    return await repository.getAdminDashboard();
  }
}
