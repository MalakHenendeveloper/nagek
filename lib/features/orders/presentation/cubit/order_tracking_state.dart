import '../../domain/entities/order_entity.dart';
import '../../domain/entities/inspection_entity.dart';
import '../../domain/entities/price_offer_entity.dart';

abstract class OrderTrackingState {}

class OrderTrackingInitial extends OrderTrackingState {}

class OrderTrackingLoading extends OrderTrackingState {}

class OrderTrackingLoaded extends OrderTrackingState {
  final OrderEntity order;
  final OrderTrackingEntity tracking;
  final InspectionEntity? inspection;
  final PriceOfferEntity? priceOffer;
  final bool isApproving;

  OrderTrackingLoaded({
    required this.order,
    required this.tracking,
    this.inspection,
    this.priceOffer,
    this.isApproving = false,
  });

  OrderTrackingLoaded copyWith({
    OrderEntity? order,
    OrderTrackingEntity? tracking,
    InspectionEntity? inspection,
    PriceOfferEntity? priceOffer,
    bool? isApproving,
  }) {
    return OrderTrackingLoaded(
      order: order ?? this.order,
      tracking: tracking ?? this.tracking,
      inspection: inspection ?? this.inspection,
      priceOffer: priceOffer ?? this.priceOffer,
      isApproving: isApproving ?? this.isApproving,
    );
  }
}

class OrderTrackingError extends OrderTrackingState {
  final String message;

  OrderTrackingError(this.message);
}

