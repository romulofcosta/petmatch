import '../value_objects/email.dart';
import '../value_objects/geo_point.dart';
import '../value_objects/geohash.dart';

/// A PetMatch user (tutor).
///
/// Immutable aggregate root of the auth capability. PostGIS-native: location
/// is a [GeoPoint] and [geohash] is derived from it at construction time, so
/// both can never drift (the database stores both, the entity treats
/// [GeoPoint] as the single source of truth).
class User {
  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phone,
    required this.birthDate,
    required GeoPoint location,
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
  })  : location = location,
        geohash = Geohash.encode(location);

  final String uid;
  final Email email;
  final String displayName;
  final String? photoUrl;
  final String? phone;
  final DateTime birthDate;
  final GeoPoint location;

  /// Derived from [location] — never stored independently on the entity.
  final Geohash geohash;

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

  /// Completed years of age on the current date.
  int get age {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  /// Whether the user has an active paid plan (`monthly` or `yearly`).
  bool get isPremium {
    final plan = subscription['plan'] as String?;
    return plan == 'monthly' || plan == 'yearly';
  }

  User copyWith({
    String? displayName,
    String? photoUrl,
    String? phone,
    GeoPoint? location,
    String? city,
    String? state,
    String? country,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? subscription,
    Map<String, dynamic>? stats,
    bool? isActive,
    bool? isVerified,
    bool? isBanned,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      birthDate: birthDate,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      preferences: preferences ?? this.preferences,
      subscription: subscription ?? this.subscription,
      stats: stats ?? this.stats,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
