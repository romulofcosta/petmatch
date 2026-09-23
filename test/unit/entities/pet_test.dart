import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/entities/pet.dart';
import 'package:petmatch/domain/entities/pet_interest.dart';
import 'package:petmatch/domain/entities/pet_sex.dart';
import 'package:petmatch/domain/entities/pet_type.dart';
import 'package:petmatch/domain/value_objects/geo_point.dart';
import 'package:petmatch/domain/value_objects/geohash.dart';

void main() {
  final location = GeoPoint(latitude: -23.5505, longitude: -46.6333);

  Pet buildPet({
    String name = 'Rex',
    DateTime? birthDate,
    List<PetInterest> interests = const [PetInterest.socialization],
  }) {
    return Pet(
      id: 'pet-1',
      ownerId: 'owner-1',
      name: name,
      type: PetType.dog,
      sex: PetSex.male,
      breed: 'Labrador',
      breedGroup: 'Gundog',
      birthDate: birthDate ?? DateTime(2024, 3, 10),
      weightKg: 12.5,
      description: 'Amigável',
      personalityTags: const ['brincalhão'],
      interests: interests,
      mainPhotoUrl: 'https://example.com/rex.jpg',
      photos: const ['https://example.com/rex-1.jpg'],
      location: location,
      veterinary: const {'clinic': 'Vet Central'},
      microchipId: 'chip-123',
      createdAt: DateTime(2024, 5, 1),
      updatedAt: DateTime(2024, 5, 2),
    );
  }

  group('Pet — contrato PostGIS-native', () {
    test('usa GeoPoint/Geohash em vez de latitude/longitude avulsas', () {
      final pet = buildPet();

      expect(pet.location, isA<GeoPoint>());
      expect(pet.geohash, isA<Geohash>());
      expect(pet.location.latitude, closeTo(-23.5505, 1e-9));
      expect(pet.location.longitude, closeTo(-46.6333, 1e-9));
    });

    test('geohash é derivado da location (fonte única de verdade)', () {
      final pet = buildPet();

      expect(pet.geohash.value, Geohash.encode(location).value);
    });

    test('tipa os campos com os enums de domínio', () {
      final pet = buildPet(
        interests: const [PetInterest.socialization, PetInterest.adoption],
      );

      expect(pet.type, PetType.dog);
      expect(pet.sex, PetSex.male);
      expect(pet.interests, isA<List<PetInterest>>());
      expect(
        pet.interests,
        containsAll([PetInterest.socialization, PetInterest.adoption]),
      );
    });
  });

  group('Pet — getters derivados', () {
    test('isDog/isCat/isMale/isFemale seguem o tipo e o sexo', () {
      final dogMale = buildPet();
      expect(dogMale.isDog, isTrue);
      expect(dogMale.isCat, isFalse);
      expect(dogMale.isMale, isTrue);
      expect(dogMale.isFemale, isFalse);

      final catFemale =
          buildPet().copyWith(type: PetType.cat, sex: PetSex.female);
      expect(catFemale.isCat, isTrue);
      expect(catFemale.isFemale, isTrue);
    });

    test('ageMonths é calculado a partir da birthDate', () {
      final pet = buildPet(birthDate: monthsAgo(5));

      expect(pet.ageMonths, 5);
    });

    test('ageText formata meses, anos e anos+meses', () {
      expect(buildPet(birthDate: monthsAgo(3)).ageText, '3 meses');
      expect(buildPet(birthDate: monthsAgo(12)).ageText, '1 ano');
      expect(buildPet(birthDate: monthsAgo(14)).ageText, '1 ano e 2 meses');
    });

    test('isEligibleForMatching exige 4+ meses', () {
      expect(buildPet(birthDate: monthsAgo(2)).isEligibleForMatching, isFalse);
      expect(buildPet(birthDate: monthsAgo(4)).isEligibleForMatching, isTrue);
    });

    test('canBreed exige 12+ meses', () {
      expect(buildPet(birthDate: monthsAgo(10)).canBreed, isFalse);
      expect(buildPet(birthDate: monthsAgo(12)).canBreed, isTrue);
    });
  });

  group('Pet.copyWith', () {
    test('preserva objetos quando o parâmetro é null', () {
      final pet = buildPet();

      final updated = pet.copyWith(name: 'Thor');

      // Objetos de domínio preservados quando não fornecidos:
      expect(identical(updated.location, pet.location), isTrue);
      expect(updated.geohash, pet.geohash); // valor derivado, igual
      expect(identical(updated.interests, pet.interests), isTrue);
      expect(identical(updated.personalityTags, pet.personalityTags), isTrue);
      expect(identical(updated.photos, pet.photos), isTrue);
      expect(identical(updated.veterinary, pet.veterinary), isTrue);
      // Ids e timestamps de criação são imutáveis:
      expect(updated.id, pet.id);
      expect(updated.ownerId, pet.ownerId);
      expect(updated.createdAt, pet.createdAt);
    });

    test('aplica os valores fornecidos', () {
      final pet = buildPet();
      final newLocation = GeoPoint(latitude: -22.9068, longitude: -43.1729);

      final updated = pet.copyWith(
        name: 'Bob',
        type: PetType.cat,
        sex: PetSex.female,
        weightKg: 9.0,
        location: newLocation,
        interests: const [PetInterest.breeding],
      );

      expect(updated.name, 'Bob');
      expect(updated.type, PetType.cat);
      expect(updated.sex, PetSex.female);
      expect(updated.weightKg, 9.0);
      expect(updated.location, newLocation);
      expect(updated.geohash.value, Geohash.encode(newLocation).value);
      expect(updated.interests, const [PetInterest.breeding]);
    });

    test(
        'updatedAt é renovado quando não fornecido, preservado quando fornecido',
        () {
      final pet = buildPet();
      final fixed = DateTime(2030, 1, 1);

      final withDefault = pet.copyWith(name: 'A');
      final withExplicit = pet.copyWith(name: 'B', updatedAt: fixed);

      expect(withExplicit.updatedAt, fixed);
      expect(withDefault.updatedAt.isAfter(pet.updatedAt), isTrue);
    });
  });
}

/// Date exactly [months] before the current month, normalized to the 1st —
/// safe against day-of-month overflow and month boundaries.
DateTime monthsAgo(int months) {
  final now = DateTime.now();
  final total = now.year * 12 + (now.month - 1) - months;
  return DateTime(total ~/ 12, total % 12 + 1, 1);
}
