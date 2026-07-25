import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../entities/inspection_entity.dart';
import '../entities/price_offer_entity.dart';
import '../entities/order_payment_entity.dart';
import '../entities/delegate_dashboard_entity.dart';
import '../entities/delegate_settlement_entity.dart';

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

  Future<Either<Failure, OrderPaymentEntity>> getOrderPaymentDetails(String orderId);

  Future<Either<Failure, bool>> submitPaymentProof({
    required String orderId,
    required String senderWalletNumber,
    required String transferReference,
    required String paymentMethod,
    String? screenshotPath,
  });

  Future<Either<Failure, List<OrderEntity>>> getAvailablePickupOrders();

  Future<Either<Failure, List<OrderEntity>>> getAvailableDeliveryOrders();

  Future<Either<Failure, List<OrderEntity>>> getDelegateOrders();

  Future<Either<Failure, OrderEntity>> acceptPickup(String orderId);

  Future<Either<Failure, OrderEntity>> acceptDelivery(String orderId);

  Future<Either<Failure, List<String>>> uploadPickupPhotos(String orderId, List<String> imagePaths);

  Future<Either<Failure, OrderEntity>> confirmPickup(String orderId);

  Future<Either<Failure, OrderEntity>> confirmDropCenter(String orderId, List<String> imagePaths);

  Future<Either<Failure, OrderEntity>> confirmPickupCenter(String orderId, List<String> imagePaths);

  Future<Either<Failure, OrderEntity>> confirmDelivery(String orderId, List<String> imagePaths);

  Future<Either<Failure, DelegateDashboardEntity>> getDelegateDashboard();

  Future<Either<Failure, DelegateSettlementsResultEntity>> getDelegateSettlements({
    int page = 1,
    int limit = 10,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  });
}
