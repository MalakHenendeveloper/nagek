import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/centers_repository.dart';
import '../data_sources/centers_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CentersRepository)
class CentersRepositoryImpl implements CentersRepository {
  final CentersRemoteDataSource _remoteDataSource;

  CentersRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, CentersResultEntity>> getCenters({
    required int page,
    required int limit,
  }) async {
    try {
      final responseModel = await _remoteDataSource.getCenters(
        page: page,
        limit: limit,
      );

      if (responseModel.success) {
        final resultEntity = CentersResultEntity(
          centers: responseModel.centers.map((m) => m.toEntity()).toList(),
          pagination: responseModel.pagination.toEntity(),
        );
        return Right(resultEntity);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب المراكز'));
    }
  }

  @override
  Future<Either<Failure, CenterEntity>> getCenterDetails(String id) async {
    try {
      final responseModel = await _remoteDataSource.getCenterDetails(id);

      if (responseModel.success) {
        return Right(responseModel.center.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب تفاصيل المركز'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getCenterServices(String centerId) async {
    try {
      final responseModel = await _remoteDataSource.getCenterServices(centerId);

      if (responseModel.success) {
        return Right(responseModel.services.map((m) => m.toEntity()).toList());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب خدمات المركز'));
    }
  }
}
