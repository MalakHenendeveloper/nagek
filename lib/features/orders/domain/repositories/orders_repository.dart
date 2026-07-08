import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../entities/inspection_entity.dart';
import '../entities/price_offer_entity.dart';

abstract class OrdersRepository {
  Future<Either<Failure, OrdersResultEntity>> getOrders({
    required int page,
    required int limit,
  });

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
  });

  Future<Either<Failure, OrderEntity>> getOrderDetails(String id);

  Future<Either<Failure, OrderTrackingEntity>> getOrderTracking(String id);

  Future<Either<Failure, InspectionEntity>> getInspectionReport(String orderId);

  Future<Either<Failure, PriceOfferEntity>> getPriceOffer(String orderId);

  Future<Either<Failure, OrderEntity>> approvePriceOffer(String orderId);
}
