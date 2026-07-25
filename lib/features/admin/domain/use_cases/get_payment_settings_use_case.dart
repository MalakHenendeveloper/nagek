import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_payment_settings_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetPaymentSettingsUseCase {
  final AdminRepository repository;

  GetPaymentSettingsUseCase(this.repository);

  Future<Either<Failure, AdminPaymentSettingsEntity>> call() {
    return repository.getPaymentSettings();
  }
}
