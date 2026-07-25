import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/delegate_dashboard_entity.dart';
import '../repositories/orders_repository.dart';

@lazySingleton
class GetDelegateDashboardUseCase {
  final OrdersRepository repository;

  GetDelegateDashboardUseCase(this.repository);

  Future<Either<Failure, DelegateDashboardEntity>> call() async {
    return await repository.getDelegateDashboard();
  }
}
