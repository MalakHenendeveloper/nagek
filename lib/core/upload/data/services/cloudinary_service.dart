import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/image_upload_response.dart';

@lazySingleton
class CloudinaryService {
  final Dio _dio;

  CloudinaryService(this._dio);

  Future<ImageUploadResponse> uploadImage({
    required String filePath,
    required String cloudName,
    required Map<String, dynamic> uploadParams,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      ...uploadParams,
    });

    final response = await _dio.post(
      url,
      data: formData,
      onSendProgress: onSendProgress,
    );

    if (response.statusCode == 200 && response.data != null) {
      return ImageUploadResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to upload image to Cloudinary: ${response.statusMessage}');
    }
  }
}
