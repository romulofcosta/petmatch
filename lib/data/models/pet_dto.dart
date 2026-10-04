import '../../domain/entities/pet.dart';
import '../../domain/entities/pet_interest.dart';
import '../../domain/entities/pet_sex.dart';
import '../../domain/entities/pet_type.dart';
import '../../domain/value_objects/geo_point.dart';

/// Data Transfer Object (DTO) representing the `pets` table from Supabase.
///
/// Fields are stored in snake_case to match the database schema. The `location`
/// column is a PostGIS `GEOGRAPHY(POINT, 4326)`; it is carried here as WKT
/// (`POINT(lng lat)`), the representation PostgREST accepts on writes. The
/// `interests` column is a Postgres text array.
class PetDto {
  PetDto({
    required this.id,
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
    required this.location,
    required this.geohash,
    this.veterinary = const {},
    this.microchipId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Pet ID
  final String id;

  /// Owner (tutor) ID
  final String ownerId;

  /// Pet name
  final String name;

  /// Pet type (dog/cat) in DB string form
  final String type;

  /// Pet sex (male/female)
  final String sex;

  /// Breed
  final String breed;

  /// Breed group
  final String breedGroup;

  /// Birth date
  final DateTime birthDate;

  /// Weight in kilograms
  final double? weightKg;

  /// Description
  final String? description;

  /// Personality tags
  final List<String> personalityTags;

  /// Interests (as strings)
  final List<String> interests;

  /// Main photo URL
  final String mainPhotoUrl;

  /// Additional photos
  final List<String> photos;

  /// PostGIS point as WKT: `POINT(lng lat)`
  final String location;

  /// Geohash prefix for proximity queries
  final String geohash;

  /// Veterinary information
  final Map<String, dynamic> veterinary;

  /// Microchip ID
  final String? microchipId;

  /// Whether pet is active
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates a [PetDto] from JSON (Supabase row).
  factory PetDto.fromJson(Map<String, dynamic> json) {
    return PetDto(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      sex: json['sex'] as String,
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
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mainPhotoUrl: json['main_photo_url'] as String,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: GeoPoint.fromDbValue(json['location']).toWkt(),
      geohash: json['geohash'] as String,
      veterinary: Map<String, dynamic>.from(json['veterinary'] ?? {}),
      microchipId: json['microchip_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this DTO to JSON (Supabase row).
  Map<String, dynamic> toJson() {
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
      'location': location,
      'geohash': geohash,
      'veterinary': veterinary,
      'microchip_id': microchipId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts this DTO to domain [Pet].
  Pet toDomain() {
    // The `geohash` column is only a cache; `location` is the source of truth
    // and the entity re-derives the geohash from it.
    //
    // PetInterest.fromDb throws on unknown values on purpose: the column has a
    // CHECK constraint, so anything else means corrupt data worth surfacing
    // rather than silently reinterpreting as a real interest.
    final petInterests = interests.map(PetInterest.fromDb).toList();

    return Pet(
      id: id,
      ownerId: ownerId,
      name: name,
      type: PetType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => PetType.dog,
      ),
      sex: PetSex.values.firstWhere(
        (e) => e.name == sex,
        orElse: () => PetSex.male,
      ),
      breed: breed,
      breedGroup: breedGroup,
      birthDate: birthDate,
      weightKg: weightKg,
      description: description,
      personalityTags: personalityTags,
      interests: petInterests,
      mainPhotoUrl: mainPhotoUrl,
      photos: photos,
      location: GeoPoint.fromWkt(location),
      veterinary: veterinary,
      microchipId: microchipId,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [PetDto] from domain [Pet].
  static PetDto fromDomain(Pet pet) {
    return PetDto(
      id: pet.id,
      ownerId: pet.ownerId,
      name: pet.name,
      type: pet.type.name,
      sex: pet.sex.name,
      breed: pet.breed,
      breedGroup: pet.breedGroup,
      birthDate: pet.birthDate,
      weightKg: pet.weightKg,
      description: pet.description,
      personalityTags: pet.personalityTags,
      interests: pet.interests.map((e) => e.dbValue).toList(),
      mainPhotoUrl: pet.mainPhotoUrl,
      photos: pet.photos,
      location: pet.location.toWkt(),
      geohash: pet.geohash.value,
      veterinary: pet.veterinary,
      microchipId: pet.microchipId,
      isActive: pet.isActive,
      createdAt: pet.createdAt,
      updatedAt: pet.updatedAt,
    );
  }
}
