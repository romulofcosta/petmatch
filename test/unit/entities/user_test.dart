import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/entities/user.dart';
import 'package:petmatch/domain/value_objects/email.dart';
import 'package:petmatch/domain/value_objects/geo_point.dart';
import 'package:petmatch/domain/value_objects/geohash.dart';

void main() {
  final location = GeoPoint(latitude: -23.5505, longitude: -46.6333);

  User buildUser({
    String email = 'user@domain.com',
    DateTime? birthDate,
    Map<String, dynamic>? subscription,
    bool? isVerified,
  }) {
    return User(
      uid: 'user-1',
      email: Email.parse(email),
      displayName: 'Maria',
      photoUrl: 'https://example.com/maria.jpg',
      phone: '(11) 99999-9999',
      birthDate: birthDate ?? DateTime(1990, 5, 20),
      location: location,
      city: 'São Paulo',
      state: 'SP',
      country: 'BR',
      preferences: const {'distance_radius': 30},
      subscription: subscription ?? const {},
      stats: const {'matches': 5},
      isVerified: isVerified ?? false,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
      lastActiveAt: DateTime(2024, 1, 3),
    );
  }

  group('User — contrato PostGIS-native', () {
    test('usa GeoPoint/Geohash em vez de latitude/longitude avulsas', () {
      final user = buildUser();

      expect(user.location, isA<GeoPoint>());
      expect(user.geohash, isA<Geohash>());
      expect(user.location.latitude, closeTo(-23.5505, 1e-9));
      expect(user.location.longitude, closeTo(-46.6333, 1e-9));
    });

    test('geohash é derivado da location (fonte única de verdade)', () {
      final user = buildUser();

      expect(user.geohash.value, Geohash.encode(location).value);
    });

    test('email é um Email value object normalizado', () {
      final user = buildUser(email: '  User@Domain.COM  ');

      expect(user.email, isA<Email>());
      expect(user.email.value, 'user@domain.com');
    });
  });

  group('User — getters derivados', () {
    test('age é calculado a partir da birthDate', () {
      final user = buildUser(birthDate: DateTime(nowYear() - 30, 1, 1));

      expect(user.age, 30);
    });

    test('isPremium é verdadeiro apenas para planos pagos', () {
      expect(buildUser().isPremium, isFalse);
      expect(
        buildUser(subscription: const {'plan': 'monthly'}).isPremium,
        isTrue,
      );
      expect(
        buildUser(subscription: const {'plan': 'yearly'}).isPremium,
        isTrue,
      );
      expect(
        buildUser(subscription: const {'plan': 'free'}).isPremium,
        isFalse,
      );
    });
  });

  group('User.copyWith', () {
    test('preserva objetos quando o parâmetro é null', () {
      final user = buildUser();

      final updated = user.copyWith(displayName: 'João');

      // Objetos de domínio preservados quando não fornecidos:
      expect(identical(updated.location, user.location), isTrue);
      expect(updated.geohash, user.geohash); // valor derivado, igual
      expect(identical(updated.email, user.email), isTrue);
      expect(identical(updated.preferences, user.preferences), isTrue);
      expect(identical(updated.subscription, user.subscription), isTrue);
      expect(identical(updated.stats, user.stats), isTrue);
      // Id e timestamps de criação são imutáveis:
      expect(updated.uid, user.uid);
      expect(updated.createdAt, user.createdAt);
      expect(updated.lastActiveAt, user.lastActiveAt);
    });

    test('aplica os valores fornecidos', () {
      final user = buildUser();
      final newLocation = GeoPoint(latitude: -22.9068, longitude: -43.1729);

      final updated = user.copyWith(
        displayName: 'Ana',
        city: 'Rio de Janeiro',
        state: 'RJ',
        location: newLocation,
        isVerified: true,
      );

      expect(updated.displayName, 'Ana');
      expect(updated.city, 'Rio de Janeiro');
      expect(updated.state, 'RJ');
      expect(updated.location, newLocation);
      expect(updated.geohash.value, Geohash.encode(newLocation).value);
      expect(updated.isVerified, isTrue);
    });

    test(
        'updatedAt é renovado quando não fornecido, preservado quando fornecido',
        () {
      final user = buildUser();
      final fixed = DateTime(2030, 6, 15);

      final withDefault = user.copyWith(displayName: 'A');
      final withExplicit = user.copyWith(displayName: 'B', updatedAt: fixed);

      expect(withExplicit.updatedAt, fixed);
      expect(withDefault.updatedAt.isAfter(user.updatedAt), isTrue);
    });
  });
}

int nowYear() => DateTime.now().year;
