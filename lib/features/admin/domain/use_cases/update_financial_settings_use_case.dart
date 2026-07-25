import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_financial_settings_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class UpdateFinancialSettingsUseCase {
  final AdminRepository repository;

  UpdateFinancialSettingsUseCase(this.repository);

  Future<Either<Failure, AdminFinancialSettingsEntity>> call({
    required String commissionType,
    required double commissionValue,
    required String delegateFeeType,
    required double delegateFeeValue,
    required String currency,
    required bool isActive,
  }) {
    return repository.updateFinancialSettings(
      commissionType: commissionType,
      commissionValue: commissionValue,
      delegateFeeType: delegateFeeType,
      delegateFeeValue: delegateFeeValue,
      currency: currency,
      isActive: isActive,
    );
  }
}
