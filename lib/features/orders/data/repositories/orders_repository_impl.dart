import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/inspection_entity.dart';
import '../../domain/entities/price_offer_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../data_sources/orders_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;

  OrdersRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, OrdersResultEntity>> getOrders({
    required int page,
    required int limit,
  }) async {
    try {
      final responseModel = await _remoteDataSource.getOrders(
        page: page,
        limit: limit,
      );

      if (responseModel.success) {
        final resultEntity = OrdersResultEntity(
          orders: responseModel.orders.map((m) => m.toEntity()).toList(),
          pagination: responseModel.pagination.toEntity(),
        );
        return Right(resultEntity);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب طلبات الصيانة'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required String centerId,
    required String deviceType,
    required String brand,
    required String model,
    required String problemType,
    required String problemDescription,
    required List<String> imagePaths,
    required String address,
    required String city,
  }) async {
    try {
      final responseModel = await _remoteDataSource.createOrder(
        centerId: centerId,
        deviceType: deviceType,
        brand: brand,
        model: model,
        problemType: problemType,
        problemDescription: problemDescription,
        imagePaths: imagePaths,
        address: address,
        city: city,
      );

      if (responseModel.success && responseModel.order != null) {
        return Right(responseModel.order!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء إنشاء طلب الصيانة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String id) async {
    try {
      final responseModel = await _remoteDataSource.getOrderDetails(id);
      if (responseModel.success && responseModel.order != null) {
        return Right(responseModel.order!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء جلب تفاصيل الطلب: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OrderTrackingEntity>> getOrderTracking(String id) async {
    try {
      final responseModel = await _remoteDataSource.getOrderTracking(id);
      if (responseModel.success && responseModel.tracking != null) {
        return Right(responseModel.tracking!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء جلب تتبع حالة الطلب: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InspectionEntity>> getInspectionReport(String orderId) async {
    try {
      final responseModel = await _remoteDataSource.getInspectionReport(orderId);
      if (responseModel.success && responseModel.inspection != null) {
        return Right(responseModel.inspection!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء جلب تقرير الفحص: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PriceOfferEntity>> getPriceOffer(String orderId) async {
    try {
      final responseModel = await _remoteDataSource.getPriceOffer(orderId);
      if (responseModel.success && responseModel.offer != null) {
        return Right(responseModel.offer!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء جلب عرض السعر: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> approvePriceOffer(String orderId) async {
    try {
      final responseModel = await _remoteDataSource.approvePriceOffer(orderId);
      if (responseModel.success && responseModel.order != null) {
        return Right(responseModel.order!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء الموافقة على عرض السعر: ${e.toString()}'));
    }
  }
}
