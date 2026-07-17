import '../../domain/entities/price_offer_entity.dart';

abstract class SubmitPriceOfferState {}

class SubmitPriceOfferInitial extends SubmitPriceOfferState {}

class SubmitPriceOfferLoading extends SubmitPriceOfferState {}

class SubmitPriceOfferSuccess extends SubmitPriceOfferState {
  final PriceOfferEntity offer;
  SubmitPriceOfferSuccess(this.offer);
}

class SubmitPriceOfferError extends SubmitPriceOfferState {
  final String message;
  SubmitPriceOfferError(this.message);
}
