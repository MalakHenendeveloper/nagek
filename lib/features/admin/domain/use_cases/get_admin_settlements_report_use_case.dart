import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_settlements_report_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetAdminSettlementsReportUseCase {
  final AdminRepository _repository;

  GetAdminSettlementsReportUseCase(this._repository);

  Future<Either<Failure, AdminSettlementsReportEntity>> call() async {
    return await _repository.getAdminSettlementsReport();
  }
}
