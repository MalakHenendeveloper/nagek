import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/price_offer_entity.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetPriceOfferUseCase {
  final OrdersRepository repository;

  GetPriceOfferUseCase(this.repository);

  Future<Either<Failure, PriceOfferEntity>> call(String orderId) {
    return repository.getPriceOffer(orderId);
  }
}
