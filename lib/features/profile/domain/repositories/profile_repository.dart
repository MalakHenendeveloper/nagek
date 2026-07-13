import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileUserEntity>> getProfile();
  Future<Either<Failure, List<AddressEntity>>> addAddress({
    required String label,
    required String address,
    required String city,
    required double lat,
    required double lng,
  });
}
