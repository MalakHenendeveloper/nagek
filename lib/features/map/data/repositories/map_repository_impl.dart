import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/route_info_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_data_source.dart';

@LazySingleton(as: MapRepository)
class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, MapLocationEntity>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(NetworkFailure('خدمة تحديد الموقع (GPS) غير مفعلة على جهازك.'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(NetworkFailure('يرجى السماح بصلاحيات الموقع لاستخدام الخريطة.'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(NetworkFailure(
            'تم رفض صلاحية الموقع بشكل دائم. يرجى تفعيلها من إعدادات الهاتف.'));
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final geocodeResult = await remoteDataSource.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      return Right(geocodeResult);
    } catch (e) {
      if (e is QuotaException) return Left(QuotaFailure(e.message));
      if (e is NetworkException) return Left(NetworkFailure(e.message));
      if (e is ServerException) return Left(ServerFailure(e.message));
      return Left(ServerFailure('تعذر جلب موقعك الحالي: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MapLocationEntity>> reverseGeocode(double lat, double lng) async {
    try {
      final location = await remoteDataSource.reverseGeocode(lat, lng);
      return Right(location);
    } on QuotaException catch (e) {
      return Left(QuotaFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('تعذر استخراج اسم العنوان: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MapLocationEntity>>> geocodeAddress(String query) async {
    try {
      final results = await remoteDataSource.geocodeAddress(query);
      return Right(results);
    } on QuotaException catch (e) {
      return Left(QuotaFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('تعذر البحث عن العنوان: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, RouteInfoEntity>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final routeModel = await remoteDataSource.getRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
      return Right(routeModel);
    } on QuotaException catch (e) {
      return Left(QuotaFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('تعذر رسم المسار: ${e.toString()}'));
    }
  }
}
