/// An immutable geographic coordinate (latitude/longitude) on Earth.
///
/// Follows the PostGIS/GeoJSON ordering convention throughout the app:
/// **longitude first** in serialized forms (`POINT(lng lat)`, GeoJSON
/// `coordinates: [lng, lat]`), while the constructor takes latitude first
/// for readability.
class GeoPoint {
  GeoPoint({
    required this.latitude,
    required this.longitude,
  }) {
    _validateRange(latitude, _minLatitude, _maxLatitude, 'latitude');
    _validateRange(longitude, _minLongitude, _maxLongitude, 'longitude');
  }

  /// Earth-wide valid latitude range (degrees, north positive).
  static const double _minLatitude = -90;
  static const double _maxLatitude = 90;

  /// Earth-wide valid longitude range (degrees, east positive).
  static const double _minLongitude = -180;
  static const double _maxLongitude = 180;

  final double latitude;
  final double longitude;

  static void _validateRange(
    double value,
    double min,
    double max,
    String fieldName,
  ) {
    if (value.isNaN || value < min || value > max) {
      throw ArgumentError.value(
        value,
        fieldName,
        'must be a number between $min and $max',
      );
    }
  }

  /// Serializes to PostGIS WKT: `POINT(lng lat)`.
  String toWkt() => 'POINT($longitude $latitude)';

  /// Parses a `POINT(lng lat)` WKT string produced by PostGIS.
  factory GeoPoint.fromWkt(String wkt) {
    final match = RegExp(
      r'^\s*POINT\(\s*(-?[\d.]+)\s+(-?[\d.]+)\s*\)\s*$',
      caseSensitive: false,
    ).firstMatch(wkt);

    if (match == null) {
      throw const FormatException('Invalid WKT point; expected POINT(lng lat)');
    }

    final longitude = double.parse(match.group(1)!);
    final latitude = double.parse(match.group(2)!);
    return GeoPoint(latitude: latitude, longitude: longitude);
  }

  /// Parses a GeoJSON/PostGIS point `Map`, e.g.:
  ///
  /// ```json
  /// {"type": "Point", "coordinates": [-46.6333, -23.5505]}
  /// ```
  factory GeoPoint.fromPostgis(Map<String, dynamic> json) {
    final coordinates = json['coordinates'];
    if (json['type'] != 'Point' ||
        coordinates is! List ||
        coordinates.length != 2) {
      throw const FormatException(
        'Invalid GeoJSON point; expected {"type": "Point", '
        '"coordinates": [lng, lat]}',
      );
    }

    final longitude = _coordinateToDouble(coordinates[0]);
    final latitude = _coordinateToDouble(coordinates[1]);
    return GeoPoint(latitude: latitude, longitude: longitude);
  }

  static double _coordinateToDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    throw const FormatException(
      'Invalid GeoJSON coordinate; expected a number',
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GeoPoint &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint(latitude: $latitude, longitude: $longitude)';
}
