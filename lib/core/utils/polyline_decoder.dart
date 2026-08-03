import 'package:latlong2/latlong.dart';

class PolylineDecoder {
  PolylineDecoder._();

  /// Decodes HERE Flexible Polyline string or standard Polyline string into a list of LatLng coordinates.
  /// If HERE Flexible Polyline decoding fails or format differs, handles fallback line string format.
  static List<LatLng> decodePolyline(String encoded) {
    if (encoded.isEmpty) return [];

    try {
      return _decodeFlexiblePolyline(encoded);
    } catch (_) {
      try {
        return _decodeStandardPolyline(encoded, precision: 5);
      } catch (_) {
        return [];
      }
    }
  }

  /// Internal flexible polyline decoder implementation for HERE Flexible Polyline (v8).
  static List<LatLng> _decodeFlexiblePolyline(String encoded) {
    List<LatLng> result = [];
    int index = 0;
    final int len = encoded.length;

    // Header decoding
    final headerResult = _decodeHeader(encoded, index);
    index = headerResult.nextIndex;
    final int precision = headerResult.precision;
    final bool hasZ = headerResult.hasZ;

    final double multiplier = _pow10(precision);

    int lat = 0;
    int lng = 0;

    while (index < len) {
      int deltaLat = 0;
      int shift = 0;
      int b;
      do {
        b = _charToValue(encoded.codeUnitAt(index++));
        deltaLat |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < len);

      lat += (deltaLat & 1) != 0 ? ~(deltaLat >> 1) : (deltaLat >> 1);

      int deltaLng = 0;
      shift = 0;
      do {
        if (index >= len) break;
        b = _charToValue(encoded.codeUnitAt(index++));
        deltaLng |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < len);

      lng += (deltaLng & 1) != 0 ? ~(deltaLng >> 1) : (deltaLng >> 1);

      // Skip Z/elevation if present
      if (hasZ && index < len) {
        shift = 0;
        do {
          if (index >= len) break;
          b = _charToValue(encoded.codeUnitAt(index++));
          shift += 5;
        } while (b >= 0x20 && index < len);
      }

      result.add(LatLng(lat / multiplier, lng / multiplier));
    }

    return result;
  }

  static _HeaderResult _decodeHeader(String encoded, int index) {
    if (encoded.isEmpty) return _HeaderResult(5, false, 0);

    int value = _charToValue(encoded.codeUnitAt(index++));
    int precision = value & 0x0F;
    int thirdDim = (value >> 4) & 0x07;
    bool hasZ = (thirdDim != 0);

    return _HeaderResult(precision, hasZ, index);
  }

  static List<LatLng> _decodeStandardPolyline(String encoded, {int precision = 5}) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    final double factor = _pow10(precision);

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < len);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        if (index >= len) break;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < len);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / factor, lng / factor));
    }
    return polyline;
  }

  static int _charToValue(int codeUnit) {
    const String encodingTable =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    int index = encodingTable.indexOf(String.fromCharCode(codeUnit));
    if (index == -1) {
      return 0;
    }
    return index;
  }

  static double _pow10(int precision) {
    double res = 1.0;
    for (int i = 0; i < precision; i++) {
      res *= 10.0;
    }
    return res;
  }
}

class _HeaderResult {
  final int precision;
  final bool hasZ;
  final int nextIndex;

  _HeaderResult(this.precision, this.hasZ, this.nextIndex);
}
