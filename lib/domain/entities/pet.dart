import '../value_objects/geo_point.dart';
import '../value_objects/geohash.dart';
import 'pet_interest.dart';
import 'pet_sex.dart';
import 'pet_type.dart';

/// A pet registered by a tutor (owner).
///
/// Immutable aggregate root of the pets capability. It is PostGIS-native:
/// the location is a [GeoPoint] and the [geohash] is always *derived* from
/// it at construction time, so the two can never drift apart (the database
/// stores both, but the entity treats [GeoPoint] as the single source of
/// truth).
class Pet {
  Pet({
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
    required GeoPoint location,
    this.veterinary = const {},
    this.microchipId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  })  : location = location,
        geohash = Geohash.encode(location);

  final String id;
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
  final GeoPoint location;

  /// Derived from [location] — never stored independently on the entity.
  final Geohash geohash;

  final Map<String, dynamic> veterinary;
  final String? microchipId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get ageMonths {
    final now = DateTime.now();
    var months =
        (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months;
  }

  /// Human-readable age, e.g. `4 meses`, `1 ano`, `1 ano e 2 meses`.
  String get ageText {
    final months = ageMonths;
    if (months < 12) return '$months ${_monthLabel(months)}';
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    final yearsLabel = '$years ${_yearLabel(years)}';
    if (remainingMonths == 0) return yearsLabel;
    return '$yearsLabel e $remainingMonths ${_monthLabel(remainingMonths)}';
  }

  /// Pets need at least 4 months to enter the matching pool
  /// (`pets_with_age` view enforces the same rule server-side).
  bool get isEligibleForMatching => ageMonths >= 4;

  /// Mating requires a pet of reproductive age (12+ months).
  bool get canBreed => ageMonths >= 12;

  bool get isDog => type == PetType.dog;
  bool get isCat => type == PetType.cat;
  bool get isMale => sex == PetSex.male;
  bool get isFemale => sex == PetSex.female;

  static String _yearLabel(int years) => years == 1 ? 'ano' : 'anos';
  static String _monthLabel(int months) => months == 1 ? 'mês' : 'meses';

  Pet copyWith({
    String? name,
    PetType? type,
    PetSex? sex,
    String? breed,
    String? breedGroup,
    DateTime? birthDate,
    double? weightKg,
    String? description,
    List<String>? personalityTags,
    List<PetInterest>? interests,
    String? mainPhotoUrl,
    List<String>? photos,
    GeoPoint? location,
    Map<String, dynamic>? veterinary,
    String? microchipId,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      sex: sex ?? this.sex,
      breed: breed ?? this.breed,
      breedGroup: breedGroup ?? this.breedGroup,
      birthDate: birthDate ?? this.birthDate,
      weightKg: weightKg ?? this.weightKg,
      description: description ?? this.description,
      personalityTags: personalityTags ?? this.personalityTags,
      interests: interests ?? this.interests,
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
      photos: photos ?? this.photos,
      location: location ?? this.location,
      veterinary: veterinary ?? this.veterinary,
      microchipId: microchipId ?? this.microchipId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
