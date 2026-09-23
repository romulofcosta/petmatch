import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/value_objects/geo_point.dart';
import 'package:petmatch/domain/value_objects/geohash.dart';

void main() {
  group('Geohash.encode', () {
    test('codifica São Paulo com precision 9 para 6gyf4bf8m', () {
      final saoPaulo = GeoPoint(latitude: -23.5505, longitude: -46.6333);

      final hash = Geohash.encode(saoPaulo);

      expect(hash.value, '6gyf4bf8m');
      expect(hash.value.length, 9);
    });

    test('default precision é 9', () {
      final saoPaulo = GeoPoint(latitude: -23.5505, longitude: -46.6333);

      expect(Geohash.encode(saoPaulo).value.length, Geohash.defaultPrecision);
    });

    test('precision menor gera prefixo do geohash completo', () {
      final saoPaulo = GeoPoint(latitude: -23.5505, longitude: -46.6333);

      final short = Geohash.encode(saoPaulo, precision: 5);

      expect(short.value, '6gyf4');
      expect(
        Geohash.encode(saoPaulo, precision: 9).value.startsWith('6gyf4'),
        isTrue,
      );
    });

    test('todas as letras do geohash vêm do alfabeto base32', () {
      final hash = Geohash.encode(
        GeoPoint(latitude: 51.5074, longitude: -0.1278),
      );

      for (final char in hash.value.split('')) {
        expect(Geohash.alphabet, contains(char));
      }
    });

    test('rejeita precision fora do intervalo 1..12', () {
      final ponto = GeoPoint(latitude: 0, longitude: 0);

      expect(() => Geohash.encode(ponto, precision: 0), throwsArgumentError);
      expect(() => Geohash.encode(ponto, precision: 13), throwsArgumentError);
    });
  });

  group('Geohash.decode', () {
    test('decode(encode(p)) aproxima p dentro da precisão', () {
      final point = GeoPoint(latitude: -23.5505, longitude: -46.6333);

      final decoded = Geohash.decode(Geohash.encode(point).value);

      expect(decoded.latitude, closeTo(point.latitude, 0.0005));
      expect(decoded.longitude, closeTo(point.longitude, 0.0005));
    });

    test('decode aceita letras minúsculas', () {
      final upper = Geohash.decode('6GYF4BF8M');
      final lower = Geohash.decode('6gyf4bf8m');

      expect(upper, equals(lower));
    });

    test('decode de um prefixo fica próximo do ponto original', () {
      final point = GeoPoint(latitude: -23.5505, longitude: -46.6333);

      final coarsely =
          Geohash.decode(Geohash.encode(point, precision: 4).value);

      expect(coarsely.latitude, closeTo(point.latitude, 0.5));
      expect(coarsely.longitude, closeTo(point.longitude, 0.5));
    });

    test('rejeita geohash vazio', () {
      expect(() => Geohash.decode(''), throwsFormatException);
    });

    test('rejeita caractere fora do alfabeto', () {
      expect(() => Geohash.decode('6gyf4bf8*'), throwsFormatException);
      expect(() => Geohash.decode('6gyf4bf8i'), throwsFormatException);
    });
  });

  group('Geohash.prefix', () {
    test('retorna um prefixo mais curto', () {
      final hash = Geohash.parse('6gyf4bf8m');

      expect(hash.prefix(4).value, '6gyf');
    });

    test('rejeita precision maior que o comprimento', () {
      final hash = Geohash.parse('6gyf4bf8m');

      expect(() => hash.prefix(12), throwsArgumentError);
    });
  });

  group('Geohash equality', () {
    test('igualdade por valor', () {
      final a = Geohash.parse('6gyf4bf8m');
      final same = Geohash.parse('6gyf4bf8m');
      final different = Geohash.parse('6gyf4bf8n');

      expect(a, equals(same));
      expect(a, isNot(equals(different)));
    });
  });
}
