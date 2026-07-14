import 'dart:async';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/secure_storage_service.dart';
import '../routes_manager/routes.dart';
import '../routes_manager/route_generator.dart';
import 'endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService _secureStorageService;

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshCompleters = [];

  AuthInterceptor(this.dio, this._secureStorageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    // Only intercept requests directed to our backend API
    if (path.startsWith(Endpoints.Url)) {
      if (!path.contains('/auth/login') &&
          !path.contains('/auth/register') &&
          !path.contains('/auth/refresh-token')) {
        final token = await _secureStorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final path = response.requestOptions.path;
    if (response.statusCode == 401 && path.startsWith(Endpoints.Url)) {
      try {
        final newResponse = await _handle401(response.requestOptions);
        return handler.resolve(newResponse);
      } catch (e) {
        // If handling 401 failed, return the original response
        return handler.next(response);
      }
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    if (err.response?.statusCode == 401 && path.startsWith(Endpoints.Url)) {
      try {
        final newResponse = await _handle401(err.requestOptions);
        return handler.resolve(newResponse);
      } catch (e) {
        // If handling 401 failed, propagate the original error
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  Future<Response> _handle401(RequestOptions options) async {
    // If the 401 occurs on the refresh-token endpoint itself, do not retry
    if (options.path.contains('/auth/refresh-token')) {
      throw DioException(
        requestOptions: options,
        error: 'Refresh token expired or invalid',
      );
    }

    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshCompleters.add(completer);
      final newAccessToken = await completer.future;
      if (newAccessToken != null) {
        options.headers['Authorization'] = 'Bearer $newAccessToken';
        return await dio.fetch(options);
      } else {
        throw DioException(
          requestOptions: options,
          error: 'Session expired',
        );
      }
    }

    _isRefreshing = true;
    try {
      final currentRefreshToken = await _secureStorageService.getRefreshToken();
      if (currentRefreshToken == null) {
        throw Exception('No refresh token found');
      }

      final refreshDio = Dio();
      refreshDio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );

      final response = await refreshDio.post(
        '${Endpoints.Url}${Endpoints.refreshToken}',
        data: {
          'refreshToken': currentRefreshToken,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final newAccessToken = data['data']['accessToken'];
          final newRefreshToken = data['data']['refreshToken'];
          if (newAccessToken != null && newRefreshToken != null) {
            // Save new tokens to storage
            await _secureStorageService.updateTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Complete all enqueued requests
            for (final completer in _refreshCompleters) {
              completer.complete(newAccessToken);
            }
            _refreshCompleters.clear();
            _isRefreshing = false;

            // Retry the original request
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            return await dio.fetch(options);
          }
        }
      }
      throw Exception('Invalid refresh token response structure');
    } catch (e) {
      // Invalidate all enqueued completers
      for (final completer in _refreshCompleters) {
        completer.complete(null);
      }
      _refreshCompleters.clear();
      _isRefreshing = false;

      // Log out user and redirect to login screen
      await _logout();

      throw DioException(
        requestOptions: options,
        error: 'Session expired',
        type: DioExceptionType.badResponse,
      );
    }
  }

  Future<void> _logout() async {
    await _secureStorageService.clearAuth();
    RouteGenerator.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.loginRoute,
      (route) => false,
    );
  }
}
