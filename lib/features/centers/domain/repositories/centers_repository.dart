import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/inspection_entity.dart';
import '../entities/center_entity.dart';
import '../entities/service_entity.dart';
import '../entities/center_order_details_entity.dart';
import '../entities/price_offer_entity.dart';

abstract class CentersRepository {
  Future<Either<Failure, CentersResultEntity>> getCenters({
    required int page,
    required int limit,
  });

  Future<Either<Failure, CenterEntity>> getCenterDetails(String id);

  Future<Either<Failure, List<ServiceEntity>>> getCenterServices(String centerId);

  Future<Either<Failure, OrdersResultEntity>> getCenterDashboardOrders({
    required int page,
    required int limit,
  });

  Future<Either<Failure, CenterOrderDetailsEntity>> getCenterDashboardOrderDetails(String orderId);

  Future<Either<Failure, InspectionEntity>> submitInspectionReport({
    required String orderId,
    required String technician,
    required String notes,
    required List<Map<String, String>> findings,
    required List<String> imagePaths,
  });

  Future<Either<Failure, PriceOfferEntity>> submitPriceOffer({
    required String orderId,
    required List<Map<String, dynamic>> spareParts,
    required double laborCost,
    required double inspectionFee,
    required double deliveryFee,
    required int estimatedDays,
    required String notes,
  });

  Future<Either<Failure, bool>> updateOrderStatus({
    required String orderId,
    required String status,
    required String note,
  });
}
