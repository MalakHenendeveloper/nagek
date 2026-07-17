import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/inspection_entity.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/center_order_details_entity.dart';
import '../../domain/entities/price_offer_entity.dart';
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

  @override
  Future<Either<Failure, OrdersResultEntity>> getCenterDashboardOrders({
    required int page,
    required int limit,
  }) async {
    try {
      final responseModel = await _remoteDataSource.getCenterDashboardOrders(
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
          : 'حدث خطأ أثناء جلب طلبات مركز الصيانة'));
    }
  }

  @override
  Future<Either<Failure, CenterOrderDetailsEntity>> getCenterDashboardOrderDetails(String orderId) async {
    try {
      final responseModel = await _remoteDataSource.getCenterDashboardOrderDetails(orderId);

      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب تفاصيل طلب مركز الصيانة'));
    }
  }

  @override
  Future<Either<Failure, InspectionEntity>> submitInspectionReport({
    required String orderId,
    required String technician,
    required String notes,
    required List<Map<String, String>> findings,
    required List<String> imagePaths,
  }) async {
    try {
      final responseModel = await _remoteDataSource.submitInspectionReport(
        orderId: orderId,
        technician: technician,
        notes: notes,
        findings: findings,
        imagePaths: imagePaths,
      );

      if (responseModel.success && responseModel.inspection != null) {
        return Right(responseModel.inspection!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء تسجيل نتيجة الفحص'));
    }
  }

  @override
  Future<Either<Failure, PriceOfferEntity>> submitPriceOffer({
    required String orderId,
    required List<Map<String, dynamic>> spareParts,
    required double laborCost,
    required double inspectionFee,
    required double deliveryFee,
    required int estimatedDays,
    required String notes,
  }) async {
    try {
      final responseModel = await _remoteDataSource.submitPriceOffer(
        orderId: orderId,
        spareParts: spareParts,
        laborCost: laborCost,
        inspectionFee: inspectionFee,
        deliveryFee: deliveryFee,
        estimatedDays: estimatedDays,
        notes: notes,
      );

      if (responseModel.success && responseModel.offer != null) {
        return Right(responseModel.offer!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء إرسال عرض السعر'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateOrderStatus({
    required String orderId,
    required String status,
    required String note,
  }) async {
    try {
      final result = await _remoteDataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
        note: note,
      );
      if (result) {
        return const Right(true);
      } else {
        return Left(ServerFailure('فشل في تحديث حالة الطلب'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
