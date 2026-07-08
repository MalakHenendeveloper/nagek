import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorageService;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorageService);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final responseModel = await _remoteDataSource.login(
        phone: phone,
        password: password,
      );

      if (responseModel.success && responseModel.data != null) {
        final entity = responseModel.data!.toEntity();

        // Save to secure storage
        await _secureStorageService.saveAuthData(
          accessToken: entity.accessToken,
          refreshToken: entity.refreshToken,
          role: entity.role,
          name: entity.name,
          phone: entity.phone,
          id: entity.id,
        );

        return Right(entity);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'اسم المستخدم أو كلمة المرور غير صحيحة'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final responseModel = await _remoteDataSource.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );

      if (responseModel.success && responseModel.data != null) {
        final entity = responseModel.data!.toEntity();

        // Save to secure storage
        await _secureStorageService.saveAuthData(
          accessToken: entity.accessToken,
          refreshToken: entity.refreshToken,
          role: entity.role,
          name: entity.name,
          phone: entity.phone,
          id: entity.id,
        );

        return Right(entity);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء إنشاء الحساب، يرجى المحاولة لاحقاً'));
    }
  }
}
