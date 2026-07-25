import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/submit_price_offer_use_case.dart';
import 'submit_price_offer_state.dart';

@injectable
class SubmitPriceOfferCubit extends Cubit<SubmitPriceOfferState> {
  final SubmitPriceOfferUseCase _useCase;

  SubmitPriceOfferCubit(this._useCase) : super(SubmitPriceOfferInitial());

  Future<void> submitPriceOffer({
    required String orderId,
    required double totalCost,
    required String notes,
  }) async {
    emit(SubmitPriceOfferLoading());

    final result = await _useCase(
      orderId: orderId,
      totalCost: totalCost,
      notes: notes,
    );

    result.fold(
      (failure) => emit(SubmitPriceOfferError(failure.message)),
      (offer) => emit(SubmitPriceOfferSuccess(offer)),
    );
  }
}
