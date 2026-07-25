import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/price_offer_entity.dart';
import '../repositories/centers_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SubmitPriceOfferUseCase {
  final CentersRepository repository;

  SubmitPriceOfferUseCase(this.repository);

  Future<Either<Failure, PriceOfferEntity>> call({
    required String orderId,
    required double totalCost,
    required String notes,
  }) {
    return repository.submitPriceOffer(
      orderId: orderId,
      totalCost: totalCost,
      notes: notes,
    );
  }
}
