import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../errors/failures.dart';
import '../../domain/repositories/upload_repository.dart';
import '../models/image_upload_response.dart';
import '../services/cloudinary_service.dart';

@LazySingleton(as: UploadRepository)
class UploadRepositoryImpl implements UploadRepository {
  final CloudinaryService _cloudinaryService;

  UploadRepositoryImpl(this._cloudinaryService);

  @override
  Future<Either<Failure, ImageUploadResponse>> uploadImage({
    required String filePath,
    required String cloudName,
    required Map<String, dynamic> uploadParams,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _cloudinaryService.uploadImage(
        filePath: filePath,
        cloudName: cloudName,
        uploadParams: uploadParams,
        onSendProgress: onSendProgress,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
