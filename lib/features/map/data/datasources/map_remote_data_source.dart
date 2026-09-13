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
    // 1. Try HERE API first
    try {
      final url =
          '${HereConfig.reverseGeocodeBaseUrl}?at=$lat,$lng&apiKey=${HereConfig.apiKey}&lang=ar-SA';
      final responseData = await _executeWithRetry(() => dio.get(url));

      final items = responseData['items'] as List<dynamic>?;
      if (items != null && items.isNotEmpty) {
        return HereGeocodeModel.fromHereItemJson(items.first as Map<String, dynamic>);
      }
    } catch (e) {
      log('[MapRemoteDataSource] HERE API reverseGeocode failed ($e). Falling back to OpenStreetMap / BigDataCloud.');
    }

    // 2. Fallback: Photon Komoot (Detailed Street, House Number, Suburb, OSM native, 0 rate limit)
    try {
      final photonResult = await _reverseGeocodePhoton(lat, lng);
      if (photonResult != null) {
        return photonResult;
      }
    } catch (e) {
      log('[MapRemoteDataSource] Photon reverse geocode error: $e');
    }

    // 3. Fallback: BigDataCloud (Detailed localityInfo, informative sub-areas, fast)
    try {
      final bigDataResult = await _reverseGeocodeBigDataCloud(lat, lng);
      if (bigDataResult != null) {
        return bigDataResult;
      }
    } catch (e) {
      log('[MapRemoteDataSource] BigDataCloud reverse geocode error: $e');
    }

    // 4. Fallback: OpenStreetMap Nominatim
    return await _reverseGeocodeNominatim(lat, lng);
  }

  Future<HereGeocodeModel?> _reverseGeocodePhoton(double lat, double lng) async {
    try {
      final url = 'https://photon.komoot.io/reverse?lat=$lat&lon=$lng&lang=default';
      final response = await dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>?;
        if (features != null && features.isNotEmpty) {
          final first = features.first as Map<String, dynamic>;
          final props = first['properties'] as Map<String, dynamic>?;

          if (props != null) {
            final name = props['name'] as String? ?? '';
            final street = props['street'] as String? ?? '';
            final housenumber = props['housenumber']?.toString() ?? '';
            final district = props['district'] as String? ?? props['suburb'] as String? ?? '';
            final city = props['city'] as String? ?? '';
            final state = props['state'] as String? ?? '';
            final country = props['country'] as String? ?? '';

            final parts = <String>[];
            final seen = <String>{};

            void addPart(String val) {
              final trimmed = val.trim();
              if (trimmed.isNotEmpty && !seen.contains(trimmed.toLowerCase())) {
                seen.add(trimmed.toLowerCase());
                parts.add(trimmed);
              }
            }

            // Street & house number
            if (street.isNotEmpty) {
              if (housenumber.isNotEmpty) {
                addPart('$street، مبنى $housenumber');
              } else {
                addPart(street);
              }
            }

            // Place / POI / Landmark name
            if (name.isNotEmpty && name != street && name != city && name != state) {
              addPart(name);
            }

            // District / Neighbourhood
            if (district.isNotEmpty) addPart(district);

            // City / Municipality
            if (city.isNotEmpty) addPart(city);

            // Governorate / State
            if (state.isNotEmpty) addPart(state);

            // Country
            if (country.isNotEmpty) addPart(country);

            if (parts.isNotEmpty) {
              final finalCity = city.isNotEmpty
                  ? city
                  : (state.isNotEmpty ? state : (country.isNotEmpty ? country : 'بغداد'));

              return HereGeocodeModel(
                latitude: lat,
                longitude: lng,
                address: parts.join(', '),
                city: finalCity,
              );
            }
          }
        }
      }
    } catch (e) {
      log('[Photon Reverse Geocode Error] $e');
    }
    return null;
  }

  Future<HereGeocodeModel?> _reverseGeocodeBigDataCloud(double lat, double lng) async {
    try {
      final url =
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lng&localityLanguage=ar';
      final response = await dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final country = data['countryName'] as String? ?? '';
        final state = data['principalSubdivision'] as String? ?? '';
        final city = data['city'] as String? ?? '';
        final locality = data['locality'] as String? ?? '';

        final parts = <String>[];
        final seen = <String>{};

        void addPart(String val) {
          final trimmed = val.trim();
          if (trimmed.isNotEmpty && !seen.contains(trimmed.toLowerCase())) {
            seen.add(trimmed.toLowerCase());
            parts.add(trimmed);
          }
        }

        // Extract detailed locality info (streets, sub-areas, landmarks)
        final localityInfo = data['localityInfo'] as Map<String, dynamic>?;
        final informative = localityInfo?['informative'] as List<dynamic>?;
        if (informative != null) {
          for (final item in informative) {
            final map = item as Map<String, dynamic>?;
            final order = (map?['order'] as num?)?.toInt() ?? 0;
            final name = map?['name'] as String? ?? '';
            if (order >= 6 && name.isNotEmpty) {
              addPart(name);
            }
          }
        }

        if (locality.isNotEmpty) addPart(locality);
        if (city.isNotEmpty) addPart(city);
        if (state.isNotEmpty) addPart(state);
        if (country.isNotEmpty) addPart(country);

        final displayAddress = parts.isNotEmpty
            ? parts.join(', ')
            : 'موقع محدد ($lat, $lng)';

        final finalCity = city.isNotEmpty
            ? city
            : (state.isNotEmpty ? state : (country.isNotEmpty ? country : 'بغداد'));

        return HereGeocodeModel(
          latitude: lat,
          longitude: lng,
          address: displayAddress,
          city: finalCity,
        );
      }
    } catch (e) {
      log('[BigDataCloud Error] $e');
    }
    return null;
  }

  Future<HereGeocodeModel> _reverseGeocodeNominatim(double lat, double lng) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1&accept-language=ar';
      final response = await dio.get(
        url,
        options: Options(
          headers: {'User-Agent': 'NagekApp/1.0 (contact@nagek.app)'},
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final addressObj = data['address'] as Map<String, dynamic>?;

        final road = addressObj?['road'] as String? ??
            addressObj?['pedestrian'] as String? ??
            addressObj?['street'] as String? ??
            '';
        final neighbourhood = addressObj?['neighbourhood'] as String? ??
            addressObj?['suburb'] as String? ??
            addressObj?['quarter'] as String? ??
            addressObj?['city_district'] as String? ??
            '';
        final city = addressObj?['city'] as String? ??
            addressObj?['town'] as String? ??
            addressObj?['municipality'] as String? ??
            '';
        final state = addressObj?['state'] as String? ??
            addressObj?['governorate'] as String? ??
            '';
        final country = addressObj?['country'] as String? ?? '';

        final parts = <String>[];
        final seen = <String>{};

        void addPart(String val) {
          final trimmed = val.trim();
          if (trimmed.isNotEmpty && !seen.contains(trimmed.toLowerCase())) {
            seen.add(trimmed.toLowerCase());
            parts.add(trimmed);
          }
        }

        if (road.isNotEmpty) addPart(road);
        if (neighbourhood.isNotEmpty) addPart(neighbourhood);
        if (city.isNotEmpty) addPart(city);
        if (state.isNotEmpty) addPart(state);
        if (country.isNotEmpty) addPart(country);

        final displayAddress = parts.isNotEmpty
            ? parts.join(', ')
            : (data['display_name'] as String? ?? 'موقع على الخريطة');

        final finalCity = city.isNotEmpty
            ? city
            : (state.isNotEmpty ? state : (country.isNotEmpty ? country : 'بغداد'));

        return HereGeocodeModel(
          latitude: lat,
          longitude: lng,
          address: displayAddress,
          city: finalCity,
        );
      }
    } catch (e) {
      log('[Nominatim Error] $e');
    }

    return HereGeocodeModel(
      latitude: lat,
      longitude: lng,
      address: 'موقع محدد على الخريطة ($lat, $lng)',
      city: 'بغداد',
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
            'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(q)}&addressdetails=1&accept-language=ar&limit=5';
        final response = await dio.get(
          url,
          options: Options(
            headers: {'User-Agent': 'NagekApp/1.0 (contact@nagek.app)'},
            sendTimeout: const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 4),
          ),
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
              final city = addressObj?['city'] as String? ??
                  addressObj?['state'] as String? ??
                  addressObj?['county'] as String?;

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

    // Secondary search fallback: Photon Komoot OSM API (No rate limits)
    return await _geocodeAddressPhoton(rawQuery);
  }

  Future<List<HereGeocodeModel>> _geocodeAddressPhoton(String rawQuery) async {
    try {
      final url =
          'https://photon.komoot.io/api/?q=${Uri.encodeComponent(rawQuery)}&limit=5&lang=default';
      final response = await dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>?;
        if (features != null && features.isNotEmpty) {
          final results = <HereGeocodeModel>[];
          for (final f in features) {
            final fMap = f as Map<String, dynamic>;
            final geometry = fMap['geometry'] as Map<String, dynamic>?;
            final coords = geometry?['coordinates'] as List<dynamic>?;
            final props = fMap['properties'] as Map<String, dynamic>?;

            if (coords != null && coords.length >= 2) {
              final lng = (coords[0] as num).toDouble();
              final lat = (coords[1] as num).toDouble();

              final name = props?['name'] as String? ?? '';
              final street = props?['street'] as String? ?? '';
              final district = props?['district'] as String? ?? '';
              final city =
                  props?['city'] as String? ?? props?['state'] as String? ?? 'بغداد';
              final country = props?['country'] as String? ?? '';

              final parts = <String>[];
              if (name.isNotEmpty) parts.add(name);
              if (street.isNotEmpty && street != name) parts.add(street);
              if (district.isNotEmpty && district != name) parts.add(district);
              if (city.isNotEmpty && city != name) parts.add(city);
              if (country.isNotEmpty) parts.add(country);

              results.add(HereGeocodeModel(
                latitude: lat,
                longitude: lng,
                address: parts.isNotEmpty ? parts.join(', ') : rawQuery,
                city: city,
              ));
            }
          }
          if (results.isNotEmpty) return results;
        }
      }
    } catch (e) {
      log('[Photon Search Error] $e');
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
