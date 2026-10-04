import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/data/models/pet_dto.dart';
import 'package:petmatch/domain/entities/pet.dart';
import 'package:petmatch/domain/entities/pet_interest.dart';
import 'package:petmatch/domain/entities/pet_sex.dart';
import 'package:petmatch/domain/entities/pet_type.dart';
import 'package:petmatch/domain/value_objects/geo_point.dart';
import 'package:petmatch/domain/value_objects/geohash.dart';

void main() {
  const lng = -46.6333;
  const lat = -23.5505;

  /// A row exactly as PostgREST returns it for the `pets` table.
  Map<String, dynamic> buildRow({
    String id = 'pet-1',
    String ownerId = 'owner-1',
    String name = 'Rex',
    String type = 'dog',
    String sex = 'male',
    String breed = 'Labrador',
    String breedGroup = 'Gundog',
    String birthDate = '2024-03-10',
    double? weightKg = 12.5,
    String? description = 'Amigável',
    List<String>? personalityTags,
    List<String>? interests,
    String mainPhotoUrl = 'https://example.com/rex.jpg',
    List<String>? photos,
    String? microchipId = 'chip-123',
    bool? isActive,
    String createdAt = '2024-05-01T10:00:00.000Z',
    String updatedAt = '2024-05-02T11:00:00.000Z',
  }) {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'type': type,
      'sex': sex,
      'breed': breed,
      'breed_group': breedGroup,
      'birth_date': birthDate,
      'weight_kg': weightKg,
      'description': description,
      'personality_tags': personalityTags ?? ['brincalhão'],
      'interests': interests ?? ['socialization', 'adoption'],
      'main_photo_url': mainPhotoUrl,
      'photos': photos ?? ['https://example.com/rex-1.jpg'],
      'location': {
        'type': 'Point',
        'coordinates': [lng, lat],
      },
      'geohash': Geohash.encode(
        GeoPoint(latitude: lat, longitude: lng),
      ).value,
      'veterinary': {'clinic': 'Vet Central'},
      'microchip_id': microchipId,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  group('PetDto.fromJson', () {
    test('mapeia a linha snake_case do banco para o DTO', () {
      final dto = PetDto.fromJson(buildRow());

      expect(dto.id, 'pet-1');
      expect(dto.ownerId, 'owner-1');
      expect(dto.name, 'Rex');
      expect(dto.type, 'dog');
      expect(dto.sex, 'male');
      expect(dto.breed, 'Labrador');
      expect(dto.breedGroup, 'Gundog');
      expect(dto.birthDate, DateTime(2024, 3, 10));
      expect(dto.weightKg, 12.5);
      expect(dto.description, 'Amigável');
      expect(dto.mainPhotoUrl, 'https://example.com/rex.jpg');
      expect(dto.microchipId, 'chip-123');
      expect(dto.createdAt, DateTime.parse('2024-05-01T10:00:00.000Z'));
    });

    test('normaliza o GeoJSON Point do PostGIS para WKT', () {
      final dto = PetDto.fromJson(buildRow());

      expect(dto.location, 'POINT($lng $lat)');
    });

    test('aceita location já em WKT (respostas de RPC/SQL cru)', () {
      final row = buildRow()..['location'] = 'POINT($lng $lat)';

      expect(PetDto.fromJson(row).location, 'POINT($lng $lat)');
    });

    test('rejeita location em um formato desconhecido', () {
      final row = buildRow()..['location'] = 42;

      expect(
        () => PetDto.fromJson(row),
        throwsA(isA<FormatException>()),
      );
    });

    test('mapeia interests como List<String> (array do Postgres)', () {
      final dto = PetDto.fromJson(buildRow());

      expect(dto.interests, ['socialization', 'adoption']);
    });

    test('aplica defaults para listas ausentes e is_active nulo', () {
      final row = buildRow()
        ..remove('personality_tags')
        ..remove('interests')
        ..remove('photos')
        ..remove('veterinary')
        ..['is_active'] = null;

      final dto = PetDto.fromJson(row);

      expect(dto.personalityTags, isEmpty);
      expect(dto.interests, isEmpty);
      expect(dto.photos, isEmpty);
      expect(dto.veterinary, isEmpty);
      expect(dto.isActive, isTrue);
    });

    test('lança ao receber um payload sem location', () {
      final row = buildRow()..remove('location');

      expect(
        () => PetDto.fromJson(row),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PetDto.toJson', () {
    test('serializa em snake_case e data como YYYY-MM-DD', () {
      final json = PetDto.fromJson(buildRow()).toJson();

      expect(json['owner_id'], 'owner-1');
      expect(json['breed_group'], 'Gundog');
      expect(json['birth_date'], '2024-03-10');
      expect(json['main_photo_url'], 'https://example.com/rex.jpg');
      expect(json['is_active'], isTrue);
    });

    test('não emite as chaves latitude/longitude avulsas', () {
      final json = PetDto.fromJson(buildRow()).toJson();

      expect(json.containsKey('latitude'), isFalse);
      expect(json.containsKey('longitude'), isFalse);
    });

    test('round-trip fromJson -> toJson -> fromJson preserva o DTO', () {
      final original = PetDto.fromJson(buildRow());

      final roundTripped = PetDto.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.ownerId, original.ownerId);
      expect(roundTripped.name, original.name);
      expect(roundTripped.type, original.type);
      expect(roundTripped.sex, original.sex);
      expect(roundTripped.birthDate, original.birthDate);
      expect(roundTripped.interests, original.interests);
      expect(roundTripped.location, original.location);
      expect(roundTripped.geohash, original.geohash);
      expect(roundTripped.isActive, original.isActive);
      expect(roundTripped.createdAt, original.createdAt);
      expect(roundTripped.updatedAt, original.updatedAt);
    });
  });

  group('PetDto.toDomain', () {
    test('converte type/sex para os enums de domínio', () {
      final pet =
          PetDto.fromJson(buildRow(type: 'cat', sex: 'female')).toDomain();

      expect(pet.type, PetType.cat);
      expect(pet.sex, PetSex.female);
    });

    test('converte interests para PetInterest', () {
      final pet = PetDto.fromJson(
        buildRow(interests: ['socialization', 'breeding', 'adoption']),
      ).toDomain();

      expect(pet.interests, [
        PetInterest.socialization,
        PetInterest.breeding,
        PetInterest.adoption,
      ]);
    });

    test('converte o GeoJSON [lng, lat] em GeoPoint', () {
      final pet = PetDto.fromJson(buildRow()).toDomain();

      expect(pet.location, isA<GeoPoint>());
      expect(pet.location.longitude, closeTo(lng, 1e-9));
      expect(pet.location.latitude, closeTo(lat, 1e-9));
    });

    test('a entidade recalcula o geohash a partir da location', () {
      final pet = PetDto.fromJson(buildRow()).toDomain();

      expect(pet.geohash.value, Geohash.encode(pet.location).value);
    });

    test('propaga os demais campos para a entidade', () {
      final pet = PetDto.fromJson(buildRow()).toDomain();

      expect(pet.id, 'pet-1');
      expect(pet.ownerId, 'owner-1');
      expect(pet.name, 'Rex');
      expect(pet.breed, 'Labrador');
      expect(pet.weightKg, 12.5);
      expect(pet.personalityTags, ['brincalhão']);
      expect(pet.mainPhotoUrl, 'https://example.com/rex.jpg');
      expect(pet.microchipId, 'chip-123');
      expect(pet.veterinary, {'clinic': 'Vet Central'});
      expect(pet.isActive, isTrue);
    });

    test('campos opcionais nulos atravessam como null', () {
      final pet = PetDto.fromJson(
        buildRow(weightKg: null, description: null, microchipId: null),
      ).toDomain();

      expect(pet.weightKg, isNull);
      expect(pet.description, isNull);
      expect(pet.microchipId, isNull);
    });
  });

  group('PetDto.fromDomain', () {
    Pet buildPet({
      PetType type = PetType.dog,
      PetSex sex = PetSex.male,
      List<PetInterest> interests = const [
        PetInterest.socialization,
        PetInterest.adoption,
      ],
    }) {
      return Pet(
        id: 'pet-7',
        ownerId: 'owner-2',
        name: 'Mel',
        type: type,
        sex: sex,
        breed: 'Siameses',
        breedGroup: 'Orientação',
        birthDate: DateTime(2023, 1, 5),
        weightKg: 4.2,
        description: 'Quieta',
        personalityTags: const ['dócil'],
        interests: interests,
        mainPhotoUrl: 'https://example.com/mel.jpg',
        photos: const ['https://example.com/mel-1.jpg'],
        location: GeoPoint(latitude: lat, longitude: lng),
        veterinary: const {'clinic': 'Vet B'},
        microchipId: null,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 2),
      );
    }

    test('gera o WKT POINT na ordem [lng, lat]', () {
      final dto = PetDto.fromDomain(buildPet());

      expect(dto.location, 'POINT($lng $lat)');
      expect(GeoPoint.fromWkt(dto.location).longitude, lng);
    });

    test('serializa os enums nos valores de banco', () {
      final dto = PetDto.fromDomain(
        buildPet(type: PetType.cat, sex: PetSex.female),
      );

      expect(dto.type, 'cat');
      expect(dto.sex, 'female');
    });

    test('serializa interests como os dbValue dos enums', () {
      final dto = PetDto.fromDomain(
        buildPet(interests: const [PetInterest.breeding]),
      );

      expect(dto.interests, ['breeding']);
    });

    test('deriva geohash do GeoPoint da entidade', () {
      final pet = buildPet();

      expect(PetDto.fromDomain(pet).geohash, pet.geohash.value);
    });

    test('round-trip domínio -> DTO -> domínio preserva a entidade', () {
      final original = buildPet();

      final roundTripped = PetDto.fromDomain(original).toDomain();

      expect(roundTripped.id, original.id);
      expect(roundTripped.ownerId, original.ownerId);
      expect(roundTripped.name, original.name);
      expect(roundTripped.type, original.type);
      expect(roundTripped.sex, original.sex);
      expect(roundTripped.breed, original.breed);
      expect(roundTripped.breedGroup, original.breedGroup);
      expect(roundTripped.birthDate, original.birthDate);
      expect(roundTripped.weightKg, original.weightKg);
      expect(roundTripped.interests, original.interests);
      expect(roundTripped.location, original.location);
      expect(roundTripped.isActive, original.isActive);
      expect(roundTripped.createdAt, original.createdAt);
      expect(roundTripped.updatedAt, original.updatedAt);
    });

    test('toJson do DTO vindo do domínio tem location e geohash preenchidos',
        () {
      final json = PetDto.fromDomain(buildPet()).toJson();

      expect(json['location'], 'POINT($lng $lat)');
      expect((json['geohash'] as String), isNotEmpty);
      expect(json.containsKey('latitude'), isFalse);
      expect(json.containsKey('longitude'), isFalse);
    });

    test('toDomain falha em interest desconhecido em vez de inventar um', () {
      final dto = PetDto.fromJson(buildRow(interests: ['agility']));

      expect(dto.toDomain, throwsA(isA<FormatException>()));
    });
  });
}
