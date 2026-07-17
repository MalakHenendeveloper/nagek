import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/centers_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UpdateCenterOrderStatusUseCase {
  final CentersRepository repository;

  UpdateCenterOrderStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String orderId,
    required String status,
    required String note,
  }) {
    return repository.updateOrderStatus(
      orderId: orderId,
      status: status,
      note: note,
    );
  }
}
