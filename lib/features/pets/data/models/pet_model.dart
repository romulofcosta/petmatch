import '../../domain/entities/pet_entity.dart';
import '../../../../core/utils/geohash.dart';

class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.type,
    required super.sex,
    required super.breed,
    required super.breedGroup,
    required super.birthDate,
    super.weightKg,
    super.description,
    super.personalityTags,
    required super.interests,
    required super.mainPhotoUrl,
    super.photos,
    required super.latitude,
    required super.longitude,
    super.veterinary,
    super.microchipId,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PetModel.fromMap(Map<String, dynamic> map) {
    final location = map['location'];
    double latitude = 0;
    double longitude = 0;
    if (location is Map<String, dynamic>) {
      final coordinates = location['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        longitude = (coordinates[0] as num).toDouble();
        latitude = (coordinates[1] as num).toDouble();
      }
    } else if (location is String) {
      final match = RegExp(r'POINT\((-?\d+\.?\d*)\s(-?\d+\.?\d*)\)')
          .firstMatch(location);
      if (match != null) {
        longitude = double.parse(match.group(1)!);
        latitude = double.parse(match.group(2)!);
      }
    }

    return PetModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      sex: map['sex'] as String,
      breed: map['breed'] as String,
      breedGroup: map['breed_group'] as String,
      birthDate: DateTime.parse(map['birth_date'] as String),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      description: map['description'] as String?,
      personalityTags: (map['personality_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      interests: (map['interests'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mainPhotoUrl: map['main_photo_url'] as String,
      photos:
          (map['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      latitude: latitude,
      longitude: longitude,
      veterinary: Map<String, dynamic>.from(map['veterinary'] ?? {}),
      microchipId: map['microchip_id'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'type': type,
      'sex': sex,
      'breed': breed,
      'breed_group': breedGroup,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'weight_kg': weightKg,
      'description': description,
      'personality_tags': personalityTags,
      'interests': interests,
      'main_photo_url': mainPhotoUrl,
      'photos': photos,
      'veterinary': veterinary,
      'microchip_id': microchipId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap(double latitude, double longitude) {
    return {
      'owner_id': ownerId,
      'name': name,
      'type': type,
      'sex': sex,
      'breed': breed,
      'breed_group': breedGroup,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'weight_kg': weightKg,
      'description': description,
      'personality_tags': personalityTags,
      'interests': interests,
      'main_photo_url': mainPhotoUrl,
      'photos': photos,
      'location': 'POINT($longitude $latitude)',
      'geohash': encodeGeohash(latitude, longitude),
    };
  }
}
