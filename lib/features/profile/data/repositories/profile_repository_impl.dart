import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../data_sources/profile_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ProfileUserEntity>> getProfile() async {
    try {
      final responseModel = await _remoteDataSource.getProfile();

      if (responseModel.success && responseModel.data != null) {
        final entity = responseModel.data!.toEntity();
        return Right(entity);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب بيانات الملف الشخصي'));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> addAddress({
    required String label,
    required String address,
    required String city,
    required double lat,
    required double lng,
  }) async {
    try {
      final responseModel = await _remoteDataSource.addAddress(
        label: label,
        address: address,
        city: city,
        lat: lat,
        lng: lng,
      );

      if (responseModel.success) {
        final entities = responseModel.addresses.map((a) => a.toEntity()).toList();
        return Right(entities);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء إضافة العنوان'));
    }
  }
}
