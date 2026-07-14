import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_center_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateCenterUseCase {
  final AdminRepository _repository;

  CreateCenterUseCase(this._repository);

  Future<Either<Failure, AdminCenterEntity>> call({
    required String ownerName,
    required String phone,
    required String email,
    required String password,
    required String name,
    required String address,
    required String city,
    required List<String> supportedBrands,
    required List<String> supportedDeviceTypes,
    required String? logoPath,
    required Map<String, double> coordinates,
  }) {
    return _repository.createCenter(
      ownerName: ownerName,
      phone: phone,
      email: email,
      password: password,
      name: name,
      address: address,
      city: city,
      supportedBrands: supportedBrands,
      supportedDeviceTypes: supportedDeviceTypes,
      logoPath: logoPath,
      coordinates: coordinates,
    );
  }
}
