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
    required List<Map<String, dynamic>> spareParts,
    required double laborCost,
    required double inspectionFee,
    required double deliveryFee,
    required int estimatedDays,
    required String notes,
  }) {
    return repository.submitPriceOffer(
      orderId: orderId,
      spareParts: spareParts,
      laborCost: laborCost,
      inspectionFee: inspectionFee,
      deliveryFee: deliveryFee,
      estimatedDays: estimatedDays,
      notes: notes,
    );
  }
}
