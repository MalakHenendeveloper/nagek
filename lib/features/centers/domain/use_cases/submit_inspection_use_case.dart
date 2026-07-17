import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/inspection_entity.dart';
import '../repositories/centers_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SubmitInspectionUseCase {
  final CentersRepository repository;

  SubmitInspectionUseCase(this.repository);

  Future<Either<Failure, InspectionEntity>> call({
    required String orderId,
    required String technician,
    required String notes,
    required List<Map<String, String>> findings,
    required List<String> imagePaths,
  }) {
    return repository.submitInspectionReport(
      orderId: orderId,
      technician: technician,
      notes: notes,
      findings: findings,
      imagePaths: imagePaths,
    );
  }
}
