import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.phone,
    required super.birthDate,
    required super.latitude,
    required super.longitude,
    required super.city,
    required super.state,
    super.country,
    super.preferences,
    super.subscription,
    super.stats,
    super.isActive,
    super.isVerified,
    super.isBanned,
    required super.createdAt,
    required super.updatedAt,
    super.lastActiveAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String,
      photoUrl: map['photo_url'] as String?,
      phone: map['phone'] as String?,
      birthDate: DateTime.parse(map['birth_date'] as String),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      country: map['country'] as String? ?? 'BR',
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      subscription: Map<String, dynamic>.from(map['subscription'] ?? {}),
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
      isActive: map['is_active'] as bool? ?? true,
      isVerified: map['is_verified'] as bool? ?? false,
      isBanned: map['is_banned'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastActiveAt: map['last_active_at'] != null
          ? DateTime.parse(map['last_active_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'phone': phone,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'preferences': preferences,
      'subscription': subscription,
      'stats': stats,
      'is_active': isActive,
      'is_verified': isVerified,
      'is_banned': isBanned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  factory UserModel.fromSupabaseUser(Map<String, dynamic> authUser, Map<String, dynamic> profile) {
    return UserModel(
      uid: authUser['id'] as String,
      email: authUser['email'] as String,
      displayName: profile['display_name'] as String? ?? authUser['user_metadata']?['full_name'] as String? ?? '',
      photoUrl: profile['photo_url'] as String? ?? authUser['user_metadata']?['avatar_url'] as String?,
      phone: profile['phone'] as String? ?? authUser['phone'],
      birthDate: profile['birth_date'] != null
          ? DateTime.parse(profile['birth_date'] as String)
          : DateTime.now().subtract(const Duration(days: 365 * 25)),
      latitude: (profile['location']?['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (profile['location']?['longitude'] as num?)?.toDouble() ?? 0,
      city: profile['city'] as String? ?? '',
      state: profile['state'] as String? ?? '',
      country: profile['country'] as String? ?? 'BR',
      preferences: Map<String, dynamic>.from(profile['preferences'] ?? {}),
      subscription: Map<String, dynamic>.from(profile['subscription'] ?? {}),
      stats: Map<String, dynamic>.from(profile['stats'] ?? {}),
      isActive: profile['is_active'] as bool? ?? true,
      isVerified: profile['is_verified'] as bool? ?? false,
      isBanned: profile['is_banned'] as bool? ?? false,
      createdAt: DateTime.parse(profile['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(profile['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      lastActiveAt: profile['last_active_at'] != null
          ? DateTime.parse(profile['last_active_at'] as String)
          : null,
    );
  }
}
