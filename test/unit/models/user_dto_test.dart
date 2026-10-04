import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/data/models/user_dto.dart';
import 'package:petmatch/domain/entities/user.dart';
import 'package:petmatch/domain/value_objects/email.dart';
import 'package:petmatch/domain/value_objects/geo_point.dart';
import 'package:petmatch/domain/value_objects/geohash.dart';

void main() {
  // São Paulo, matching the fixtures used across the other suites.
  const lng = -46.6333;
  const lat = -23.5505;

  /// A row exactly as PostgREST returns it for the `users` table.
  Map<String, dynamic> buildRow({
    String uid = 'user-1',
    String email = 'ana@exemplo.com',
    String displayName = 'Ana',
    String? photoUrl = 'https://example.com/ana.jpg',
    String? phone = '+5511999999999',
    String birthDate = '1995-04-12',
    String? city = 'São Paulo',
    String? state = 'SP',
    String? country = 'BR',
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? subscription,
    Map<String, dynamic>? stats,
    bool? isActive,
    bool? isVerified,
    bool? isBanned,
    String createdAt = '2026-01-10T12:00:00.000Z',
    String updatedAt = '2026-02-11T09:30:00.000Z',
    String? lastActiveAt = '2026-03-01T18:45:00.000Z',
  }) {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'phone': phone,
      'birth_date': birthDate,
      'location': {
        'type': 'Point',
        'coordinates': [lng, lat],
      },
      'geohash': Geohash.encode(
        GeoPoint(latitude: lat, longitude: lng),
      ).value,
      'city': city,
      'state': state,
      'country': country,
      'preferences': preferences ?? {'theme': 'dark'},
      'subscription': subscription ?? {'plan': 'free'},
      'stats': stats ?? {'matches': 7},
      'is_active': isActive,
      'is_verified': isVerified,
      'is_banned': isBanned,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'last_active_at': lastActiveAt,
    };
  }

  group('UserDto.fromJson', () {
    test('mapeia a linha snake_case do banco para o DTO', () {
      final dto = UserDto.fromJson(buildRow());

      expect(dto.uid, 'user-1');
      expect(dto.email, 'ana@exemplo.com');
      expect(dto.displayName, 'Ana');
      expect(dto.photoUrl, 'https://example.com/ana.jpg');
      expect(dto.phone, '+5511999999999');
      expect(dto.birthDate, DateTime(1995, 4, 12));
      expect(dto.city, 'São Paulo');
      expect(dto.state, 'SP');
      expect(dto.country, 'BR');
      expect(dto.createdAt, DateTime.parse('2026-01-10T12:00:00.000Z'));
      expect(dto.updatedAt, DateTime.parse('2026-02-11T09:30:00.000Z'));
      expect(
        dto.lastActiveAt,
        DateTime.parse('2026-03-01T18:45:00.000Z'),
      );
    });

    test('normaliza o GeoJSON Point do PostGIS para WKT', () {
      final dto = UserDto.fromJson(buildRow());

      expect(dto.location, 'POINT($lng $lat)');
    });

    test('aceita location já em WKT (respostas de RPC/SQL cru)', () {
      final row = buildRow()..['location'] = 'POINT($lng $lat)';

      expect(UserDto.fromJson(row).location, 'POINT($lng $lat)');
    });

    test('rejeita location em um formato desconhecido', () {
      final row = buildRow()..['location'] = 42;

      expect(
        () => UserDto.fromJson(row),
        throwsA(isA<FormatException>()),
      );
    });

    test('preserva geohash como string', () {
      final dto = UserDto.fromJson(buildRow());

      expect(dto.geohash, isA<String>());
      expect(dto.geohash, isNotEmpty);
    });

    test('preserva preferences/subscription/stats como maps', () {
      final dto = UserDto.fromJson(buildRow());

      expect(dto.preferences, {'theme': 'dark'});
      expect(dto.subscription, {'plan': 'free'});
      expect(dto.stats, {'matches': 7});
    });

    test('aplica defaults quando city/state/country e os flags vêm nulos', () {
      final dto = UserDto.fromJson(buildRow(
        city: null,
        state: null,
        country: null,
        isActive: null,
        isVerified: null,
        isBanned: null,
      ));

      expect(dto.city, '');
      expect(dto.state, '');
      expect(dto.country, 'BR');
      expect(dto.isActive, isTrue);
      expect(dto.isVerified, isFalse);
      expect(dto.isBanned, isFalse);
    });

    test('lastActiveAt nulo vira null, não erro', () {
      final dto = UserDto.fromJson(buildRow(lastActiveAt: null));

      expect(dto.lastActiveAt, isNull);
    });

    test('lança ao receber um payload sem location', () {
      final row = buildRow()..remove('location');

      expect(
        () => UserDto.fromJson(row),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('UserDto.toJson', () {
    test('serializa em snake_case e data como YYYY-MM-DD', () {
      final json = UserDto.fromJson(buildRow()).toJson();

      expect(json['uid'], 'user-1');
      expect(json['display_name'], 'Ana');
      expect(json['birth_date'], '1995-04-12');
      expect(json['is_verified'], isFalse);
      expect(json['created_at'], '2026-01-10T12:00:00.000Z');
    });

    test('não emite as chaves latitude/longitude avulsas', () {
      final json = UserDto.fromJson(buildRow()).toJson();

      expect(json.containsKey('latitude'), isFalse);
      expect(json.containsKey('longitude'), isFalse);
    });

    test('round-trip fromJson -> toJson -> fromJson preserva o DTO', () {
      final original = UserDto.fromJson(buildRow());

      final roundTripped = UserDto.fromJson(original.toJson());

      expect(roundTripped.uid, original.uid);
      expect(roundTripped.email, original.email);
      expect(roundTripped.displayName, original.displayName);
      expect(roundTripped.birthDate, original.birthDate);
      expect(roundTripped.location, original.location);
      expect(roundTripped.geohash, original.geohash);
      expect(roundTripped.city, original.city);
      expect(roundTripped.state, original.state);
      expect(roundTripped.country, original.country);
      expect(roundTripped.preferences, original.preferences);
      expect(roundTripped.isActive, original.isActive);
      expect(roundTripped.isVerified, original.isVerified);
      expect(roundTripped.isBanned, original.isBanned);
      expect(roundTripped.createdAt, original.createdAt);
      expect(roundTripped.updatedAt, original.updatedAt);
      expect(roundTripped.lastActiveAt, original.lastActiveAt);
    });
  });

  group('UserDto.toDomain', () {
    test('converte o GeoJSON [lng, lat] em GeoPoint', () {
      final user = UserDto.fromJson(buildRow()).toDomain();

      expect(user.location, isA<GeoPoint>());
      expect(user.location.longitude, closeTo(lng, 1e-9));
      expect(user.location.latitude, closeTo(lat, 1e-9));
    });

    test('normaliza o e-mail no VO Email', () {
      final user =
          UserDto.fromJson(buildRow(email: 'Ana@Exemplo.com')).toDomain();

      expect(user.email, isA<Email>());
      expect(user.email.value, 'ana@exemplo.com');
    });

    test('propaga os demais campos para a entidade', () {
      final user = UserDto.fromJson(buildRow()).toDomain();

      expect(user.uid, 'user-1');
      expect(user.displayName, 'Ana');
      expect(user.phone, '+5511999999999');
      expect(user.city, 'São Paulo');
      expect(user.state, 'SP');
      expect(user.country, 'BR');
      expect(user.isActive, isTrue);
      expect(user.isVerified, isFalse);
      expect(user.isBanned, isFalse);
    });

    test('a entidade recalcula o geohash a partir da location', () {
      final user = UserDto.fromJson(buildRow()).toDomain();

      // The DB column is only a cache; the entity treats GeoPoint as the
      // single source of truth, so the two must agree.
      expect(user.geohash.value, Geohash.encode(user.location).value);
    });
  });

  group('UserDto.fromDomain', () {
    User buildUser() {
      return User(
        uid: 'user-9',
        email: Email.parse('carlos@exemplo.com'),
        displayName: 'Carlos',
        photoUrl: null,
        phone: null,
        birthDate: DateTime(1990, 7, 3),
        location: GeoPoint(latitude: lat, longitude: lng),
        city: 'Campinas',
        state: 'SP',
        preferences: const {'theme': 'light'},
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      );
    }

    test('gera o WKT POINT na ordem [lng, lat]', () {
      final dto = UserDto.fromDomain(buildUser());

      expect(dto.location, 'POINT($lng $lat)');
      // Guard against the classic lat/lng swap in the PostGIS column.
      expect(GeoPoint.fromWkt(dto.location).longitude, lng);
    });

    test('deriva geohash do GeoPoint da entidade', () {
      final user = buildUser();
      final dto = UserDto.fromDomain(user);

      expect(dto.geohash, user.geohash.value);
    });

    test('desembrulha o VO Email para string normalizada', () {
      final dto = UserDto.fromDomain(buildUser());

      expect(dto.email, 'carlos@exemplo.com');
    });

    test('round-trip domínio -> DTO -> domínio preserva a entidade', () {
      final original = buildUser();

      final roundTripped = UserDto.fromDomain(original).toDomain();

      expect(roundTripped.uid, original.uid);
      expect(roundTripped.email, original.email);
      expect(roundTripped.displayName, original.displayName);
      expect(roundTripped.birthDate, original.birthDate);
      expect(roundTripped.location, original.location);
      expect(roundTripped.city, original.city);
      expect(roundTripped.state, original.state);
      expect(roundTripped.country, original.country);
      expect(roundTripped.createdAt, original.createdAt);
      expect(roundTripped.updatedAt, original.updatedAt);
    });

    test('toJson do DTO vindo do domínio tem location e geohash preenchidos',
        () {
      final json = UserDto.fromDomain(buildUser()).toJson();

      expect(json['location'], 'POINT($lng $lat)');
      expect(json['geohash'], isA<String>());
      expect((json['geohash'] as String), isNotEmpty);
      expect(json.containsKey('latitude'), isFalse);
      expect(json.containsKey('longitude'), isFalse);
    });
  });
}
