import 'package:flutter_test/flutter_test.dart';

import 'package:petmatch/features/pets/data/models/pet_model.dart';

void main() {
  test('toInsertMap emits location (WKT) and geohash, and no lat/lng keys',
      () {
    final pet = PetModel(
      id: 'pet1',
      ownerId: 'u1',
      name: 'Rex',
      type: 'dog',
      sex: 'male',
      breed: 'Labrador',
      breedGroup: 'Grande',
      birthDate: DateTime(2022, 1, 1),
      interests: ['socialization'],
      mainPhotoUrl: 'https://img/pet1.jpg',
      latitude: -23.5505,
      longitude: -46.6333,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final map = pet.toInsertMap(-23.5505, -46.6333);

    expect(map.containsKey('location'), isTrue);
    expect(map['location'], 'POINT(-46.6333 -23.5505)');
    expect(map.containsKey('geohash'), isTrue);
    expect(map['geohash'], '6gyf4bf8m');
    expect(map.containsKey('latitude'), isFalse);
    expect(map.containsKey('longitude'), isFalse);
  });

  test('fromMap parses a GeoJSON location point into latitude/longitude', () {
    final map = <String, dynamic>{
      'id': 'pet1',
      'owner_id': 'u1',
      'name': 'Rex',
      'type': 'dog',
      'sex': 'male',
      'breed': 'Labrador',
      'breed_group': 'Grande',
      'birth_date': '2022-01-01',
      'interests': ['socialization'],
      'main_photo_url': 'https://img/pet1.jpg',
      'photos': [],
      'location': {'type': 'Point', 'coordinates': [-46.6333, -23.5505]},
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    };

    final pet = PetModel.fromMap(map);

    expect(pet.latitude, closeTo(-23.5505, 0.0001));
    expect(pet.longitude, closeTo(-46.6333, 0.0001));
  });
}
