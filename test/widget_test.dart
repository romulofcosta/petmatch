import 'package:flutter_test/flutter_test.dart';

import 'package:petmatch/core/utils/geohash.dart';

void main() {
  group('encodeGeohash', () {
    test('computes a known geohash for São Paulo center', () {
      // São Paulo approx center
      final hash = encodeGeohash(-23.5505, -46.6333, precision: 9);
      expect(hash.length, 9);
      expect(hash, '6gyf4bf8m');
    });

    test('same coordinates produce a stable hash', () {
      final a = encodeGeohash(-23.55, -46.63);
      final b = encodeGeohash(-23.55, -46.63);
      expect(a, b);
    });

    test('adjacent coordinates produce different hashes', () {
      final a = encodeGeohash(-23.55, -46.63);
      final b = encodeGeohash(51.5, -0.12); // London
      expect(a, isNot(b));
    });

    test('uses the requested precision', () {
      expect(encodeGeohash(-23.55, -46.63, precision: 5).length, 5);
      expect(encodeGeohash(-23.55, -46.63, precision: 12).length, 12);
    });
  });
}
