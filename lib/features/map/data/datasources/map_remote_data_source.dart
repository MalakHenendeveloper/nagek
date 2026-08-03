import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/here_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/here_geocode_model.dart';
import '../models/here_route_model.dart';

abstract class MapRemoteDataSource {
  Future<HereGeocodeModel> reverseGeocode(double lat, double lng);
  Future<List<HereGeocodeModel>> geocodeAddress(String query);
  Future<HereRouteModel> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}

class _RouteCacheItem {
  final HereRouteModel route;
  final DateTime timestamp;

  _RouteCacheItem(this.route, this.timestamp);

  bool get isValid =>
      DateTime.now().difference(timestamp).inMinutes < HereConfig.routeCacheDurationMinutes;
}

@LazySingleton(as: MapRemoteDataSource)
class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final Dio dio;
  final Map<String, _RouteCacheItem> _routeCache = {};

  MapRemoteDataSourceImpl(this.dio);

  @override
  Future<HereGeocodeModel> reverseGeocode(double lat, double lng) async {
    // Try HERE API first
    try {
      final url =
          '${HereConfig.reverseGeocodeBaseUrl}?at=$lat,$lng&apiKey=${HereConfig.apiKey}&lang=ar-SA';
      final responseData = await _executeWithRetry(() => dio.get(url));

      final items = responseData['items'] as List<dynamic>?;
      if (items != null && items.isNotEmpty) {
        return HereGeocodeModel.fromHereItemJson(items.first as Map<String, dynamic>);
      }
    } catch (e) {
      log('[MapRemoteDataSource] HERE API reverseGeocode failed ($e). Falling back to OpenStreetMap Nominatim.');
    }

    // Fallback: OpenStreetMap Nominatim (100% Free, No Key / Visa Required)
    return await _reverseGeocodeNominatim(lat, lng);
  }

  Future<HereGeocodeModel> _reverseGeocodeNominatim(double lat, double lng) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&addressdetails=1&accept-language=ar';
      final response = await dio.get(
        url,
        options: Options(headers: {'User-Agent': 'NagekApp/1.0'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final displayName = data['display_name'] as String? ?? 'موقع على الخريطة';
        final addressObj = data['address'] as Map<String, dynamic>?;

        final city = addressObj?['city'] as String? ??
            addressObj?['state'] as String? ??
            addressObj?['town'] as String? ??
            'القاهرة';

        return HereGeocodeModel(
          latitude: lat,
          longitude: lng,
          address: displayName,
          city: city,
        );
      }
    } catch (e) {
      log('[Nominatim Error] $e');
    }

    return HereGeocodeModel(
      latitude: lat,
      longitude: lng,
      address: 'موقع محدد على الخريطة ($lat, $lng)',
    );
  }

  @override
  Future<List<HereGeocodeModel>> geocodeAddress(String query) async {
    // Try HERE API first
    try {
      final url =
          '${HereConfig.geocodeBaseUrl}?q=${Uri.encodeComponent(query)}&apiKey=${HereConfig.apiKey}&lang=ar-SA';
      final responseData = await _executeWithRetry(() => dio.get(url));

      final items = responseData['items'] as List<dynamic>?;
      if (items != null && items.isNotEmpty) {
        return items
            .map((item) => HereGeocodeModel.fromHereItemJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('[MapRemoteDataSource] HERE API geocodeAddress failed ($e). Falling back to OpenStreetMap Nominatim.');
    }

    // Fallback: OpenStreetMap Nominatim (100% Free, No Key / Visa Required)
    return await _geocodeAddressNominatim(query);
  }

  String _cleanGeocodeQuery(String query) {
    final parts = query
        .split(RegExp(r'[,،]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final seen = <String>{};
    final cleanedParts = <String>[];

    for (final part in parts) {
      // Skip pure numbers (e.g. house number "21", postal code "11848")
      if (RegExp(r'^\d+$').hasMatch(part)) {
        continue;
      }
      final lower = part.toLowerCase();
      if (seen.contains(lower)) {
        continue;
      }
      seen.add(lower);
      cleanedParts.add(part);
    }

    return cleanedParts.isNotEmpty ? cleanedParts.join(', ') : query;
  }

  Future<List<HereGeocodeModel>> _geocodeAddressNominatim(String rawQuery) async {
    final cleanedQuery = _cleanGeocodeQuery(rawQuery);

    final queriesToTry = <String>{
      rawQuery,
      if (cleanedQuery != rawQuery) cleanedQuery,
    };

    final parts = cleanedQuery
        .split(RegExp(r'[,،]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.length > 2) {
      // Try omitting the first element (e.g., street number/name if over-specific)
      queriesToTry.add(parts.sublist(1).join(', '));
    }
    if (parts.length >= 2) {
      // Try city & governorate/area
      queriesToTry.add('${parts[parts.length - 2]}, ${parts.last}');
    }

    for (final q in queriesToTry) {
      try {
        final url =
            'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(q)}&addressdetails=1&accept-language=ar';
        final response = await dio.get(
          url,
          options: Options(headers: {'User-Agent': 'NagekApp/1.0'}),
        );

        if (response.statusCode == 200 && response.data is List) {
          final list = response.data as List<dynamic>;
          if (list.isNotEmpty) {
            return list.map((item) {
              final map = item as Map<String, dynamic>;
              final lat = double.tryParse(map['lat']?.toString() ?? '0') ?? 0.0;
              final lng = double.tryParse(map['lon']?.toString() ?? '0') ?? 0.0;
              final displayName = map['display_name'] as String? ?? q;
              final addressObj = map['address'] as Map<String, dynamic>?;
              final city = addressObj?['city'] as String? ?? addressObj?['state'] as String?;

              return HereGeocodeModel(
                latitude: lat,
                longitude: lng,
                address: displayName,
                city: city,
              );
            }).toList();
          }
        }
      } catch (e) {
        log('[Nominatim Search Error for "$q"] $e');
      }
    }
    return [];
  }

  @override
  Future<HereRouteModel> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final cacheKey =
        '${originLat.toStringAsFixed(4)},${originLng.toStringAsFixed(4)}->${destLat.toStringAsFixed(4)},${destLng.toStringAsFixed(4)}';

    if (_routeCache.containsKey(cacheKey) && _routeCache[cacheKey]!.isValid) {
      log('[MapRemoteDataSource] Returning route from In-Memory Cache (Key: $cacheKey)');
      return _routeCache[cacheKey]!.route;
    }

    // Try HERE API first
    try {
      final url =
          '${HereConfig.routingBaseUrl}?transportMode=car&origin=$originLat,$originLng&destination=$destLat,$destLng&return=polyline,summary&apiKey=${HereConfig.apiKey}';

      final responseData = await _executeWithRetry(() => dio.get(url));
      final routeModel = HereRouteModel.fromHereJson(responseData as Map<String, dynamic>);

      if (routeModel.polylinePoints.isNotEmpty) {
        _routeCache[cacheKey] = _RouteCacheItem(routeModel, DateTime.now());
      }
      return routeModel;
    } catch (e) {
      log('[MapRemoteDataSource] HERE API getRoute failed ($e). Falling back to OpenStreetMap OSRM.');
    }

    // Fallback: OpenStreetMap OSRM (100% Free, No Key / Visa Required)
    final osrmRoute = await _getRouteOsrm(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );

    if (osrmRoute.polylinePoints.isNotEmpty) {
      _routeCache[cacheKey] = _RouteCacheItem(osrmRoute, DateTime.now());
    }

    return osrmRoute;
  }

  Future<HereRouteModel> _getRouteOsrm({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/$originLng,$originLat;$destLng,$destLat?overview=full&geometries=geojson';
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final firstRoute = routes.first as Map<String, dynamic>;
          final double distanceMeters = (firstRoute['distance'] as num?)?.toDouble() ?? 0.0;
          final double durationSeconds = (firstRoute['duration'] as num?)?.toDouble() ?? 0.0;

          final geometry = firstRoute['geometry'] as Map<String, dynamic>?;
          final coordinates = geometry?['coordinates'] as List<dynamic>?;

          List<LatLng> points = [];
          if (coordinates != null) {
            for (var coord in coordinates) {
              final cList = coord as List<dynamic>;
              if (cList.length >= 2) {
                final lng = (cList[0] as num).toDouble();
                final lat = (cList[1] as num).toDouble();
                points.add(LatLng(lat, lng));
              }
            }
          }

          return HereRouteModel(
            distanceKm: distanceMeters / 1000.0,
            durationMinutes: (durationSeconds / 60).round(),
            polylinePoints: points,
          );
        }
      }
    } catch (e) {
      log('[OSRM Error] $e');
    }

    throw const ServerException('تعذر جلب المسار من خدمة الخرائط المفتوحة حالياً.');
  }

  Future<dynamic> _executeWithRetry(
    Future<Response> Function() request, {
    int maxAttempts = 1,
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      attempts++;
      try {
        final response = await request();
        if (response.statusCode == 200) {
          return response.data;
        }
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        log('[HERE API Exception] Attempt $attempts/$maxAttempts, Status: $statusCode, Error: ${e.message}');
        throw ServerException('HERE API returned status code $statusCode');
      } catch (e) {
        throw ServerException('HERE API call error: $e');
      }
    }
    throw const ServerException('فشل تنفيذ الطلب.');
  }
}
