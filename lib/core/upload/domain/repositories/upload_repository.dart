import 'package:dartz/dartz.dart';
import '../../../errors/failures.dart';
import '../../data/models/image_upload_response.dart';

abstract class UploadRepository {
  Future<Either<Failure, ImageUploadResponse>> uploadImage({
    required String filePath,
    required String cloudName,
    required Map<String, dynamic> uploadParams,
    void Function(int sent, int total)? onSendProgress,
  });
}
