import '../../domain/entities/user.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/geo_point.dart';

/// Data Transfer Object (DTO) representing the `users` table from Supabase.
///
/// Fields are stored in snake_case to match the database schema. The `location`
/// column is a PostGIS `GEOGRAPHY(POINT, 4326)`; it is carried here as WKT
/// (`POINT(lng lat)`), the representation PostgREST accepts on writes.
class UserDto {
  UserDto({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phone,
    required this.birthDate,
    required this.location,
    required this.geohash,
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

  /// Unique identifier (matches auth.users.id)
  final String uid;

  /// Email address (normalized lowercase)
  final String email;

  /// User's display name
  final String displayName;

  /// Profile photo URL
  final String? photoUrl;

  /// Phone number
  final String? phone;

  /// Birth date (YYYY-MM-DD in DB)
  final DateTime birthDate;

  /// PostGIS point as WKT: `POINT(lng lat)`
  final String location;

  /// Geohash prefix for proximity queries
  final String geohash;

  /// City name
  final String city;

  /// State/region
  final String state;

  /// Country code (default: BR)
  final String country;

  /// User preferences
  final Map<String, dynamic> preferences;

  /// Subscription details
  final Map<String, dynamic> subscription;

  /// Usage statistics
  final Map<String, dynamic> stats;

  /// Whether user account is active
  final bool isActive;

  /// Whether email/identity is verified
  final bool isVerified;

  /// Whether user is banned
  final bool isBanned;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Last active timestamp
  final DateTime? lastActiveAt;

  /// Creates a [UserDto] from JSON (Supabase row).
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      phone: json['phone'] as String?,
      birthDate: DateTime.parse(json['birth_date'] as String),
      location: GeoPoint.fromDbValue(json['location']).toWkt(),
      geohash: json['geohash'] as String,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? 'BR',
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      subscription: Map<String, dynamic>.from(json['subscription'] ?? {}),
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      isBanned: json['is_banned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
  }

  /// Converts this DTO to JSON (Supabase row).
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'phone': phone,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'location': location,
      'geohash': geohash,
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

  /// Converts this DTO to domain [User].
  User toDomain() {
    return User(
      uid: uid,
      email: Email.parse(email),
      displayName: displayName,
      photoUrl: photoUrl,
      phone: phone,
      birthDate: birthDate,
      location: GeoPoint.fromWkt(location),
      city: city,
      state: state,
      country: country,
      preferences: preferences,
      subscription: subscription,
      stats: stats,
      isActive: isActive,
      isVerified: isVerified,
      isBanned: isBanned,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastActiveAt: lastActiveAt,
    );
  }

  /// Creates a [UserDto] from domain [User].
  static UserDto fromDomain(User user) {
    return UserDto(
      uid: user.uid,
      email: user.email.value,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      phone: user.phone,
      birthDate: user.birthDate,
      location: user.location.toWkt(),
      geohash: user.geohash.value,
      city: user.city,
      state: user.state,
      country: user.country,
      preferences: user.preferences,
      subscription: user.subscription,
      stats: user.stats,
      isActive: user.isActive,
      isVerified: user.isVerified,
      isBanned: user.isBanned,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastActiveAt: user.lastActiveAt,
    );
  }
}
