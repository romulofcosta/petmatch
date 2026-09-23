import 'geo_point.dart';

/// A [Geohash] value — a short, URL-safe string encoding of a geographic
/// area used for proximity filtering (e.g. "find pets near me").
///
/// Implements the standard geohash algorithm (base32, interleaved
/// longitude/latitude bits). The alphabet omits ambiguous characters
/// (`a`, `i`, `l`, `o`) to avoid confusion (I/1, l/1, 0/O).
///
/// ## Why encode at all?
///
/// Storing a geohash next to the exact [GeoPoint] lets the database filter by
/// string prefix (fast index) and the app refine with exact distance. The
/// default [Geohash.defaultPrecision] (9) yields ~2.5m precision — enough for
/// "nearby pets" without exact radius arithmetic in SQL.
class Geohash {
  const Geohash._(this.value)
      : assert(value.length > 0, 'Geohash cannot be empty');

  /// Characters used by the standard base32 geohash alphabet.
  static const String alphabet = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Default encoding precision (~2.5m per cell side).
  static const int defaultPrecision = 9;

  final String value;

  /// Parses a geohash [value] as stored by the database, validating it.
  ///
  /// Use this when reading a geohash column (e.g. from a DTO). Throws
  /// [FormatException] when [value] is empty or contains a character outside
  /// the base32 [alphabet].
  factory Geohash.parse(String value) {
    if (value.isEmpty) {
      throw const FormatException('Geohash cannot be empty');
    }
    for (final character in value.toLowerCase().split('')) {
      if (!alphabet.contains(character)) {
        throw FormatException('Invalid geohash character: $character');
      }
    }
    return Geohash._(value.toLowerCase());
  }

  /// Encodes a [point] into a geohash with [precision] characters.
  ///
  /// [precision] must be between 1 and 12 (beyond 12 the double-precision
  /// coordinates cannot discriminate further cells).
  factory Geohash.encode(GeoPoint point, {int precision = defaultPrecision}) {
    if (precision < 1 || precision > 12) {
      throw ArgumentError.value(
        precision,
        'precision',
        'must be between 1 and 12',
      );
    }

    final latitudeBits = _CoordinatesBits(
      value: point.latitude,
      min: -90,
      max: 90,
    );
    final longitudeBits = _CoordinatesBits(
      value: point.longitude,
      min: -180,
      max: 180,
    );

    final buffer = StringBuffer();
    var character = 0;
    var bitInCharacter = 0;
    var evenBit = true;

    while (buffer.length < precision) {
      final encodedBit = evenBit
          ? longitudeBits.nextMostSignificantBit()
          : latitudeBits.nextMostSignificantBit();
      character = (character << 1) | (encodedBit ? 1 : 0);
      bitInCharacter += 1;

      if (bitInCharacter == 5) {
        buffer.write(alphabet[character]);
        character = 0;
        bitInCharacter = 0;
      }
      evenBit = !evenBit;
    }

    return Geohash._(buffer.toString());
  }

  /// Decodes a geohash [value] into the centroid of its bounding box.
  ///
  /// The returned [GeoPoint] is the *center* of the encoded cell, so
  /// `decode(encode(point))` slightly rounds [point] within the precision.
  static GeoPoint decode(String value) {
    if (value.isEmpty) {
      throw const FormatException('Geohash cannot be empty');
    }

    var latMin = -90.0;
    var latMax = 90.0;
    var lngMin = -180.0;
    var lngMax = 180.0;
    var evenBit = true;

    for (final rune in value.toLowerCase().codeUnits) {
      final characterIndex = alphabet.indexOf(String.fromCharCode(rune));
      if (characterIndex == -1) {
        throw FormatException('Invalid geohash character: $rune');
      }

      for (var bit = 4; bit >= 0; bit--) {
        final isSet = (characterIndex >> bit) & 1 == 1;
        if (evenBit) {
          if (isSet) {
            lngMin = (lngMin + lngMax) / 2;
          } else {
            lngMax = (lngMin + lngMax) / 2;
          }
        } else {
          if (isSet) {
            latMin = (latMin + latMax) / 2;
          } else {
            latMax = (latMin + latMax) / 2;
          }
        }
        evenBit = !evenBit;
      }
    }

    return GeoPoint(
      latitude: (latMin + latMax) / 2,
      longitude: (lngMin + lngMax) / 2,
    );
  }

  /// Returns the geohash prefix with the given [precision], or this geohash
  /// when it is already shorter/equal.
  Geohash prefix(int precision) {
    if (precision < 1 || precision > value.length) {
      throw ArgumentError.value(
        precision,
        'precision',
        'must be between 1 and ${value.length}',
      );
    }
    return Geohash._(value.substring(0, precision));
  }

  @override
  bool operator ==(Object other) => other is Geohash && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Geohash($value)';
}

/// Narrowing state for one coordinate axis (latitude or longitude) during
/// geohash encoding.
class _CoordinatesBits {
  _CoordinatesBits({required this.value, required this.min, required this.max});

  final double value;
  double min;
  double max;

  /// Returns the next most-significant bit for this axis and narrows the
  /// candidate range accordingly.
  bool nextMostSignificantBit() {
    final midpoint = (min + max) / 2;
    final isAboveMidpoint = value >= midpoint;
    if (isAboveMidpoint) {
      min = midpoint;
    } else {
      max = midpoint;
    }
    return isAboveMidpoint;
  }
}
