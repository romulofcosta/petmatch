class AppConstants {
  AppConstants._();

  static const String appName = 'PetMatch';
  static const String appVersion = '1.0.0';

  static const int minAge = 18;
  static const int maxPetsFree = 2;
  static const int maxPhotosPerPet = 6;
  static const int maxDescriptionLength = 500;
  static const int minPasswordLength = 8;

  static const double minWeight = 0.5;
  static const double maxWeight = 80.0;
  static const double defaultRadiusKm = 30.0;
  static const double maxRadiusKm = 100.0;

  static const int dailyLikesFree = 20;
  static const int dailySuperLikesFree = 1;
  static const int dailyMessagesFree = 50;
  static const int dailyPhotoMessagesFree = 1;
  static const int dailyLocationMessagesFree = 3;

  static const int maxPushNotificationsPerDay = 5;
  static const int maxEmailNotificationsPerWeek = 2;

  static const Duration tokenRefreshInterval = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 24);
}
