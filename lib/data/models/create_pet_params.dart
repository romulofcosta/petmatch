import '../../domain/entities/pet_interest.dart';
import '../../domain/entities/pet_sex.dart';
import '../../domain/entities/pet_type.dart';

/// Input parameters for creating a pet (Use Case).
///
/// Location is intentionally excluded — it comes from GeolocationService
/// at creation time and is computed to GeoPoint + Geohash in the entity.
class CreatePetParams {
  CreatePetParams({
    required this.ownerId,
    required this.name,
    required this.type,
    required this.sex,
    required this.breed,
    required this.breedGroup,
    required this.birthDate,
    this.weightKg,
    this.description,
    this.personalityTags = const [],
    required this.interests,
    required this.mainPhotoUrl,
    this.photos = const [],
    this.veterinary = const {},
    this.microchipId,
    this.isActive = true,
  });

  final String ownerId;
  final String name;
  final PetType type;
  final PetSex sex;
  final String breed;
  final String breedGroup;
  final DateTime birthDate;
  final double? weightKg;
  final String? description;
  final List<String> personalityTags;
  final List<PetInterest> interests;
  final String mainPhotoUrl;
  final List<String> photos;
  final Map<String, dynamic> veterinary;
  final String? microchipId;
  final bool isActive;

  /// Converts params to a map suitable for serialization/DTO mapping.
  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'type': type.dbValue,
      'sex': sex.dbValue,
      'breed': breed,
      'breed_group': breedGroup,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'weight_kg': weightKg,
      'description': description,
      'personality_tags': personalityTags,
      'interests': interests.map((e) => e.dbValue).toList(),
      'main_photo_url': mainPhotoUrl,
      'photos': photos,
      'veterinary': veterinary,
      'microchip_id': microchipId,
      'is_active': isActive,
    };
  }

  /// Creates params from JSON.
  ///
  /// Enum columns are resolved strictly through `fromDb`, which throws on
  /// unknown values rather than defaulting: `pets.type` and `pets.sex` are
  /// `CHECK`-constrained, so anything else is corrupt input and must surface
  /// instead of silently becoming `dog`/`male`.
  factory CreatePetParams.fromJson(Map<String, dynamic> json) {
    return CreatePetParams(
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      type: PetType.fromDb(json['type'] as String),
      sex: PetSex.fromDb(json['sex'] as String),
      breed: json['breed'] as String,
      breedGroup: json['breed_group'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      weightKg: json['weight_kg'] as double?,
      description: json['description'] as String?,
      personalityTags: (json['personality_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => PetInterest.fromDb(e as String))
              .toList() ??
          [],
      mainPhotoUrl: json['main_photo_url'] as String,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      veterinary: Map<String, dynamic>.from(json['veterinary'] ?? {}),
      microchipId: json['microchip_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
