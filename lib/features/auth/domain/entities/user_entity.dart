class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phone;
  final DateTime birthDate;
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final String country;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> subscription;
  final Map<String, dynamic> stats;
  final bool isActive;
  final bool isVerified;
  final bool isBanned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phone,
    required this.birthDate,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    this.country = 'BR',
    this.preferences = const {},
    this.subscription = const {},
    this.stats = const {},
    this.isActive = true,
    this.isVerified = false,
    this.isBanned = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool get isPremium {
    final plan = subscription['plan'] as String?;
    return plan == 'monthly' || plan == 'yearly';
  }

  UserEntity copyWith({
    String? displayName,
    String? photoUrl,
    String? phone,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? stats,
    bool? isActive,
    bool? isVerified,
    bool? isBanned,
    DateTime? lastActiveAt,
  }) {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      birthDate: birthDate,
      latitude: latitude,
      longitude: longitude,
      city: city,
      state: state,
      country: country,
      preferences: preferences ?? this.preferences,
      subscription: subscription,
      stats: stats ?? this.stats,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
