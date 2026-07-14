import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdminOrderDetailsUseCase {
  final AdminRepository _repository;

  GetAdminOrderDetailsUseCase(this._repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return _repository.getOrderDetails(orderId);
  }
}
