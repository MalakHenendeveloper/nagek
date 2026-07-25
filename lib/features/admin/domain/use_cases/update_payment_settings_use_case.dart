import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_payment_settings_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class UpdatePaymentSettingsUseCase {
  final AdminRepository repository;

  UpdatePaymentSettingsUseCase(this.repository);

  Future<Either<Failure, AdminPaymentSettingsEntity>> call({
    required String walletOwnerName,
    required Map<String, String> walletNumbers,
    required List<String> activePaymentMethods,
    required String paymentInstructions,
  }) {
    return repository.updatePaymentSettings(
      walletOwnerName: walletOwnerName,
      walletNumbers: walletNumbers,
      activePaymentMethods: activePaymentMethods,
      paymentInstructions: paymentInstructions,
    );
  }
}
