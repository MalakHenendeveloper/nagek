import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/center_order_details_entity.dart';
import '../repositories/centers_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetCenterDashboardOrderDetailsUseCase {
  final CentersRepository repository;

  GetCenterDashboardOrderDetailsUseCase(this.repository);

  Future<Either<Failure, CenterOrderDetailsEntity>> call(String orderId) {
    return repository.getCenterDashboardOrderDetails(orderId);
  }
}
