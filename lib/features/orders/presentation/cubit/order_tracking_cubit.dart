import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/inspection_entity.dart';
import '../../domain/entities/price_offer_entity.dart';
import '../../domain/use_cases/get_order_details_use_case.dart';
import '../../domain/use_cases/get_order_tracking_use_case.dart';
import '../../domain/use_cases/get_inspection_report_use_case.dart';
import '../../domain/use_cases/get_price_offer_use_case.dart';
import '../../domain/use_cases/approve_price_offer_use_case.dart';
import '../../domain/entities/order_entity.dart';
import 'order_tracking_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final GetOrderDetailsUseCase _getOrderDetailsUseCase;
  final GetOrderTrackingUseCase _getOrderTrackingUseCase;
  final GetInspectionReportUseCase _getInspectionReportUseCase;
  final GetPriceOfferUseCase _getPriceOfferUseCase;
  final ApprovePriceOfferUseCase _approvePriceOfferUseCase;

  OrderTrackingCubit(
    this._getOrderDetailsUseCase,
    this._getOrderTrackingUseCase,
    this._getInspectionReportUseCase,
    this._getPriceOfferUseCase,
    this._approvePriceOfferUseCase,
  ) : super(OrderTrackingInitial());

  Future<void> fetchOrderTracking(String orderId) async {
    emit(OrderTrackingLoading());

    final detailsResult = await _getOrderDetailsUseCase.call(orderId);

    detailsResult.fold(
      (failure) => emit(OrderTrackingError(failure.message)),
      (orderEntity) async {
        final trackingResult = await _getOrderTrackingUseCase.call(orderId);

        // Fetch inspection report (nullable)
        InspectionEntity? inspectionEntity;
        final inspectionResult = await _getInspectionReportUseCase.call(orderId);
        inspectionResult.fold(
          (failure) => inspectionEntity = null,
          (inspection) => inspectionEntity = inspection,
        );

        // Fetch price offer (nullable)
        PriceOfferEntity? priceOfferEntity;
        final priceOfferResult = await _getPriceOfferUseCase.call(orderId);
        priceOfferResult.fold(
          (failure) => priceOfferEntity = null,
          (offer) => priceOfferEntity = offer,
        );

        trackingResult.fold(
          (failure) {
            // Fallback: Construct tracking entity from the order details response
            final fallbackTracking = OrderTrackingEntity(
              orderNumber: orderEntity.orderNumber,
              status: orderEntity.status,
              statusHistory: orderEntity.statusHistory,
            );
            emit(OrderTrackingLoaded(
              order: orderEntity,
              tracking: fallbackTracking,
              inspection: inspectionEntity,
              priceOffer: priceOfferEntity,
            ));
          },
          (trackingEntity) {
            emit(OrderTrackingLoaded(
              order: orderEntity,
              tracking: trackingEntity,
              inspection: inspectionEntity,
              priceOffer: priceOfferEntity,
            ));
          },
        );
      },
    );
  }

  Future<bool> approvePriceOffer(String orderId) async {
    final currentState = state;
    if (currentState is OrderTrackingLoaded) {
      emit(currentState.copyWith(isApproving: true));
      
      final result = await _approvePriceOfferUseCase.call(orderId);
      
      return await result.fold(
        (failure) {
          emit(currentState.copyWith(isApproving: false));
          return false;
        },
        (updatedOrder) async {
          // Refresh the data to reflect approval state in UI
          await fetchOrderTracking(orderId);
          return true;
        },
      );
    }
    return false;
  }
}
