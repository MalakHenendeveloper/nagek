import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/center_entity.dart';
import '../repositories/centers_repository.dart';

@lazySingleton
class UpdateCenterProfileUseCase {
  final CentersRepository repository;

  UpdateCenterProfileUseCase(this.repository);

  Future<Either<Failure, CenterEntity>> call({
    required String name,
    required String phone,
    required String email,
    required String address,
    String? logoPath,
  }) async {
    return await repository.updateCenterProfile(
      name: name,
      phone: phone,
      email: email,
      address: address,
      logoPath: logoPath,
    );
  }
}
