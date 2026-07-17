import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class ReviewAdminPaymentUseCase {
  final AdminRepository repository;

  ReviewAdminPaymentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String paymentId,
    required String status,
    String? rejectionReason,
  }) {
    return repository.reviewPayment(
      paymentId,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}
