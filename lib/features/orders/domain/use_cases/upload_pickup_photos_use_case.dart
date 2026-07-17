import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UploadPickupPhotosUseCase {
  final OrdersRepository repository;

  UploadPickupPhotosUseCase(this.repository);

  Future<Either<Failure, List<String>>> call(String orderId, List<String> imagePaths) {
    return repository.uploadPickupPhotos(orderId, imagePaths);
  }
}
