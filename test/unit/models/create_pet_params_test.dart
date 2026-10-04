import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/data/models/create_pet_params.dart';
import 'package:petmatch/domain/entities/pet_interest.dart';
import 'package:petmatch/domain/entities/pet_sex.dart';
import 'package:petmatch/domain/entities/pet_type.dart';

void main() {
  CreatePetParams buildParams({
    String ownerId = 'owner-1',
    String name = 'Rex',
    PetType type = PetType.dog,
    PetSex sex = PetSex.male,
    DateTime? birthDate,
    List<PetInterest> interests = const [
      PetInterest.socialization,
      PetInterest.adoption,
    ],
  }) {
    return CreatePetParams(
      ownerId: ownerId,
      name: name,
      type: type,
      sex: sex,
      breed: 'Labrador',
      breedGroup: 'Gundog',
      birthDate: birthDate ?? DateTime(2024, 3, 10),
      weightKg: 12.5,
      description: 'Amigável',
      personalityTags: const ['brincalhão'],
      interests: interests,
      mainPhotoUrl: 'https://example.com/rex.jpg',
      photos: const ['https://example.com/rex-1.jpg'],
      veterinary: const {'clinic': 'Vet Central'},
      microchipId: 'chip-123',
    );
  }

  group('CreatePetParams', () {
    test('não carrega location/geohash — vêm do GeolocationService', () {
      // The whole point of this params object: the device position is resolved
      // at Use Case time, never typed in by the user. If a location field ever
      // shows up here, it would let the form bypass geolocation.
      final params = buildParams();

      expect(params.toJson().containsKey('location'), isFalse);
      expect(params.toJson().containsKey('geohash'), isFalse);
      expect(params.toJson().containsKey('latitude'), isFalse);
      expect(params.toJson().containsKey('longitude'), isFalse);
    });

    test('expõe os enums de domínio tipados, não strings soltas', () {
      final params = buildParams(
        type: PetType.cat,
        sex: PetSex.female,
      );

      expect(params.type, PetType.cat);
      expect(params.sex, PetSex.female);
    });
  });

  group('CreatePetParams.toJson', () {
    test('serializa em snake_case e data como YYYY-MM-DD', () {
      final json = buildParams().toJson();

      expect(json['owner_id'], 'owner-1');
      expect(json['breed_group'], 'Gundog');
      expect(json['birth_date'], '2024-03-10');
      expect(json['main_photo_url'], 'https://example.com/rex.jpg');
    });

    test('serializa type/sex como os valores de banco', () {
      final json = buildParams(type: PetType.cat, sex: PetSex.female).toJson();

      expect(json['type'], 'cat');
      expect(json['sex'], 'female');
    });

    test('serializa interests como os dbValue dos enums', () {
      final json = buildParams(
        interests: const [PetInterest.breeding],
      ).toJson();

      expect(json['interests'], ['breeding']);
    });

    test('mantém campos opcionais nulos como null (não omite a chave)', () {
      final json = buildParams().toJson();

      expect(json.containsKey('microchip_id'), isTrue);
      expect(json['microchip_id'], 'chip-123');
    });
  });

  group('CreatePetParams.fromJson', () {
    test('reidrata os enums de domínio a partir das strings do banco', () {
      final params = CreatePetParams.fromJson(
        buildParams(type: PetType.cat, sex: PetSex.female).toJson(),
      );

      expect(params.type, PetType.cat);
      expect(params.sex, PetSex.female);
    });

    test('reidrata interests como PetInterest', () {
      final params = CreatePetParams.fromJson(buildParams().toJson());

      expect(params.interests, [
        PetInterest.socialization,
        PetInterest.adoption,
      ]);
    });

    test('lança em interest desconhecido em vez de silenciar', () {
      final json = buildParams().toJson();
      json['interests'] = ['not-a-real-interest'];

      expect(
        () => CreatePetParams.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('lança em type desconhecido em vez de assumir dog', () {
      final json = buildParams().toJson();
      json['type'] = 'bird';

      expect(
        () => CreatePetParams.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('lança em sex desconhecido em vez de assumir male', () {
      final json = buildParams().toJson();
      json['sex'] = 'unknown';

      expect(
        () => CreatePetParams.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('round-trip toJson -> fromJson preserva os params', () {
      final original = buildParams();

      final roundTripped = CreatePetParams.fromJson(original.toJson());

      expect(roundTripped.ownerId, original.ownerId);
      expect(roundTripped.name, original.name);
      expect(roundTripped.type, original.type);
      expect(roundTripped.sex, original.sex);
      expect(roundTripped.breed, original.breed);
      expect(roundTripped.breedGroup, original.breedGroup);
      expect(roundTripped.birthDate, original.birthDate);
      expect(roundTripped.weightKg, original.weightKg);
      expect(roundTripped.description, original.description);
      expect(roundTripped.personalityTags, original.personalityTags);
      expect(roundTripped.interests, original.interests);
      expect(roundTripped.mainPhotoUrl, original.mainPhotoUrl);
      expect(roundTripped.photos, original.photos);
      expect(roundTripped.veterinary, original.veterinary);
      expect(roundTripped.microchipId, original.microchipId);
      expect(roundTripped.isActive, original.isActive);
    });
  });
}
