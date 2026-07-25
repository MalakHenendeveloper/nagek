import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_financial_settings_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetFinancialSettingsUseCase {
  final AdminRepository repository;

  GetFinancialSettingsUseCase(this.repository);

  Future<Either<Failure, AdminFinancialSettingsEntity>> call() {
    return repository.getFinancialSettings();
  }
}
