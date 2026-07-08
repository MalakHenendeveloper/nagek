import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inspection_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetInspectionReportUseCase {
  final OrdersRepository repository;

  GetInspectionReportUseCase(this.repository);

  Future<Either<Failure, InspectionEntity>> call(String orderId) {
    return repository.getInspectionReport(orderId);
  }
}
