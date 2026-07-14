// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:injectable/injectable.dart';
import '../storage/secure_storage_service.dart';
import 'endpoints.dart';
import 'auth_interceptor.dart';

@lazySingleton
class ApiManager {
  final Dio dio;
  final SecureStorageService _secureStorageService;

  ApiManager(this.dio, this._secureStorageService) {
    
    // Add custom JWT Auth Interceptor with Refresh Token Rotation
    dio.interceptors.add(AuthInterceptor(dio, _secureStorageService));

    // Add Logger Interceptor for debugging network requests
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  Future<Response> getDate(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return dio.get(
      Endpoints.Url + endpoint,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
        validateStatus: (status) => true,
      ),
    );
  }

  Future<Response> PostDate(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) {
    return dio.post(
      Endpoints.Url + endpoint,
      data: body,
      options: Options(
        headers: headers,
        validateStatus: (status) => true,
      ),
    );
  }

  Future<Response> PostFormData(
    String endpoint, {
    required FormData formData,
    Map<String, dynamic>? headers,
  }) {
    return dio.post(
      Endpoints.Url + endpoint,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          ...?headers,
        },
        validateStatus: (status) => true,
      ),
    );
  }

  Future<Response> Deletedata(
    String endpoint, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
  }) {
    return dio.delete(
      Endpoints.Url + endpoint,
      data: body,
      options: Options(
        headers: headers,
        validateStatus: (status) => true,
      ),
    );
  }

  Future<Response> UpdateData(
    String endpoints, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
  }) {
    return dio.put(
      Endpoints.Url + endpoints,
      data: body,
      options: Options(
        headers: headers,
        validateStatus: (status) => true,
      ),
    );
  }
}
