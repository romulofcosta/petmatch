import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/value_objects/geo_point.dart';

void main() {
  group('GeoPoint', () {
    group('construção e range', () {
      test('aceita latitudes no intervalo -90..90', () {
        expect(() => GeoPoint(latitude: 90, longitude: 0), returnsNormally);
        expect(() => GeoPoint(latitude: -90, longitude: 0), returnsNormally);
        expect(() => GeoPoint(latitude: 0, longitude: 0), returnsNormally);
      });

      test('rejeita latitude fora do intervalo', () {
        expect(
          () => GeoPoint(latitude: 90.1, longitude: 0),
          throwsArgumentError,
        );
        expect(
          () => GeoPoint(latitude: -90.1, longitude: 0),
          throwsArgumentError,
        );
      });

      test('rejeita longitude fora do intervalo -180..180', () {
        expect(
          () => GeoPoint(latitude: 0, longitude: 180.1),
          throwsArgumentError,
        );
        expect(
          () => GeoPoint(latitude: 0, longitude: -180.1),
          throwsArgumentError,
        );
      });

      test('rejeita NaN', () {
        expect(
          () => GeoPoint(latitude: double.nan, longitude: 0),
          throwsArgumentError,
        );
      });

      test('igualdade por valor', () {
        final point = GeoPoint(latitude: -23.5505, longitude: -46.6333);
        final same = GeoPoint(latitude: -23.5505, longitude: -46.6333);
        final different = GeoPoint(latitude: -23.55, longitude: -46.6333);

        expect(point, equals(same));
        expect(point, isNot(equals(different)));
      });
    });

    group('WKT', () {
      final saoPaulo = GeoPoint(latitude: -23.5505, longitude: -46.6333);

      test('toWkt usa ordem POINT(lng lat)', () {
        expect(saoPaulo.toWkt(), 'POINT(-46.6333 -23.5505)');
      });

      test('round-trip WKT → coordenadas preserva o ponto', () {
        final parsed = GeoPoint.fromWkt(saoPaulo.toWkt());

        expect(parsed, equals(saoPaulo));
      });

      test('round-trip coordenadas → WKT preserva o WKT', () {
        final wkt = GeoPoint.fromWkt('POINT(151.2093 -33.8688)').toWkt();

        expect(wkt, 'POINT(151.2093 -33.8688)');
      });

      test('aceita WKT com espaços extras e letras minúsculas', () {
        expect(
          GeoPoint.fromWkt('  point( -46.6333  -23.5505 )  '),
          equals(saoPaulo),
        );
      });

      test('rejeita WKT malformado', () {
        expect(
          () => GeoPoint.fromWkt('LINESTRING(0 0, 1 1)'),
          throwsFormatException,
        );
        expect(
          () => GeoPoint.fromWkt('POINT(-46.6333)'),
          throwsFormatException,
        );
        expect(() => GeoPoint.fromWkt('nada'), throwsFormatException);
      });
    });

    group('PostGIS/GeoJSON', () {
      test('fromPostgis parseia GeoJSON Point', () {
        final parsed = GeoPoint.fromPostgis(
          <String, dynamic>{
            'type': 'Point',
            'coordinates': [-46.6333, -23.5505],
          },
        );

        expect(parsed.latitude, -23.5505);
        expect(parsed.longitude, -46.6333);
      });

      test('round-trip PostGIS → WKT → GeoJSON é consistente', () {
        final saoPaulo = GeoPoint(latitude: -23.5505, longitude: -46.6333);

        final fromWkt = GeoPoint.fromWkt(saoPaulo.toWkt());
        final viaPostgis = GeoPoint.fromPostgis(
          <String, dynamic>{
            'type': 'Point',
            'coordinates': [-46.6333, -23.5505],
          },
        );

        expect(fromWkt, equals(saoPaulo));
        expect(viaPostgis, equals(saoPaulo));
      });

      test('aceita coordenadas numéricas em formato inteiro', () {
        final parsed = GeoPoint.fromPostgis(
          <String, dynamic>{
            'type': 'Point',
            'coordinates': [-46, -23],
          },
        );

        expect(parsed.latitude, -23);
        expect(parsed.longitude, -46);
      });

      test('rejeita GeoJSON sem type Point ou com coordenadas inválidas', () {
        expect(
          () => GeoPoint.fromPostgis(
            <String, dynamic>{
              'type': 'LineString',
              'coordinates': [0, 0],
            },
          ),
          throwsFormatException,
        );
        expect(
          () => GeoPoint.fromPostgis(
            <String, dynamic>{
              'type': 'Point',
              'coordinates': [0],
            },
          ),
          throwsFormatException,
        );
        expect(
          () => GeoPoint.fromPostgis(
            <String, dynamic>{
              'type': 'Point',
              'coordinates': ['a', 'b'],
            },
          ),
          throwsFormatException,
        );
      });
    });
  });
}
