import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdminOrdersUseCase {
  final AdminRepository _repository;

  GetAdminOrdersUseCase(this._repository);

  Future<Either<Failure, OrdersResultEntity>> call({
    required int page,
    required int limit,
  }) {
    return _repository.getOrders(page: page, limit: limit);
  }
}
