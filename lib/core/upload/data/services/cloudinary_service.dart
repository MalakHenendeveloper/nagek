import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:http_parser/http_parser.dart' show MediaType;
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
    
    final MultipartFile file;
    if (kIsWeb) {
      final bytes = await XFile(filePath).readAsBytes();
      final filename = filePath.split('/').last;
      String webFilename = filename;
      MediaType mediaType = MediaType('image', 'jpeg');
      
      if (filename.contains('.')) {
        final ext = filename.split('.').last.toLowerCase();
        if (ext == 'png') {
          mediaType = MediaType('image', 'png');
        } else if (ext == 'gif') {
          mediaType = MediaType('image', 'gif');
        } else if (ext == 'webp') {
          mediaType = MediaType('image', 'webp');
        }
      } else {
        webFilename = '$filename.jpg';
      }
      
      file = MultipartFile.fromBytes(
        bytes,
        filename: webFilename,
        contentType: mediaType,
      );
    } else {
      file = await MultipartFile.fromFile(filePath);
    }

    final formData = FormData.fromMap({
      'file': file,
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
