import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SubmitPaymentProofUseCase {
  final OrdersRepository repository;

  SubmitPaymentProofUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String orderId,
    required String senderWalletNumber,
    required String transferReference,
    required String paymentMethod,
    String? screenshotPath,
  }) {
    return repository.submitPaymentProof(
      orderId: orderId,
      senderWalletNumber: senderWalletNumber,
      transferReference: transferReference,
      paymentMethod: paymentMethod,
      screenshotPath: screenshotPath,
    );
  }
}
