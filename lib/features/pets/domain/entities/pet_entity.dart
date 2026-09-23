class PetEntity {
  final String id;
  final String ownerId;
  final String name;
  final String type;
  final String sex;
  final String breed;
  final String breedGroup;
  final DateTime birthDate;
  final double? weightKg;
  final String? description;
  final List<String> personalityTags;
  final List<String> interests;
  final String mainPhotoUrl;
  final List<String> photos;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> veterinary;
  final String? microchipId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetEntity({
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
    required this.latitude,
    required this.longitude,
    this.veterinary = const {},
    this.microchipId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  int get ageMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months;
  }

  String get ageText {
    final months = ageMonths;
    if (months < 12) return '$months meses';
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) return '$years ${years == 1 ? 'ano' : 'anos'}';
    return '$years ${years == 1 ? 'ano' : 'anos'} e $remainingMonths meses';
  }

  bool get isEligibleForMatching => ageMonths >= 4;

  bool get canBreed {
    if (!isEligibleForMatching) return false;
    if (type == 'dog') return ageMonths >= 12;
    return ageMonths >= 12;
  }

  bool get isDog => type == 'dog';
  bool get isCat => type == 'cat';
  bool get isMale => sex == 'male';
  bool get isFemale => sex == 'female';

  PetEntity copyWith({
    String? name,
    String? type,
    String? sex,
    String? breed,
    String? breedGroup,
    DateTime? birthDate,
    double? weightKg,
    String? description,
    List<String>? personalityTags,
    List<String>? interests,
    String? mainPhotoUrl,
    List<String>? photos,
    bool? isActive,
  }) {
    return PetEntity(
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
      latitude: latitude,
      longitude: longitude,
      veterinary: veterinary,
      microchipId: microchipId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
