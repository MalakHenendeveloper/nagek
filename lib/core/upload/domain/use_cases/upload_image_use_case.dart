import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../errors/failures.dart';
import '../../data/models/image_upload_response.dart';
import '../repositories/upload_repository.dart';

@lazySingleton
class UploadImageUseCase {
  final UploadRepository _repository;

  UploadImageUseCase(this._repository);

  Future<Either<Failure, ImageUploadResponse>> call({
    required String filePath,
    required String cloudName,
    required Map<String, dynamic> uploadParams,
    void Function(int sent, int total)? onSendProgress,
  }) {
    return _repository.uploadImage(
      filePath: filePath,
      cloudName: cloudName,
      uploadParams: uploadParams,
      onSendProgress: onSendProgress,
    );
  }
}
