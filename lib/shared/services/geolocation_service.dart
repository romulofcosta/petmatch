import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final bool denied;

  const LocationResult._({required this.latitude, required this.longitude, required this.denied})
      : assert(denied || (latitude != 0 || longitude != 0));

  const LocationResult.denied() : latitude = 0, longitude = 0, denied = true;

  bool get isAvailable => !denied;
}

class LocationUnavailableException implements Exception {
  const LocationUnavailableException();
}

class GeolocationService {
  const GeolocationService();

  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<LocationResult> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationResult.denied();
    }

    if (permission == LocationPermission.unableToDetermine) {
      throw const LocationUnavailableException();
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    return LocationResult._(
      latitude: position.latitude,
      longitude: position.longitude,
      denied: false,
    );
  }
}
